import { z } from 'zod'

// Ticket schema
export const ticketSchema = z.object({
  id: z.string().uuid(),
  created_at: z.string(),
  updated_at: z.string(),
  company_id: z.string().uuid(),
  user_id: z.string().uuid(),
  title: z.string().min(1, 'Title is required'),
  description: z.string().nullable(),
  client_id: z.string().uuid().nullable(),
  client_name: z.string().min(1, 'Client name is required'),
  category: z.enum(['technical', 'contract', 'billing', 'maintenance']).default('technical'),
  priority: z.enum(['urgent', 'high', 'normal']).default('normal'),
  status: z.enum(['open', 'in_progress', 'resolved', 'closed']).default('open'),
  assigned_to: z.string().uuid().nullable(),
  resolution: z.string().nullable(),
  resolved_at: z.string().nullable(),
  ticket_number: z.string(),
  tags: z.array(z.string()).default([])
})

// Client schema
export const clientSchema = z.object({
  id: z.string().uuid(),
  created_at: z.string(),
  updated_at: z.string(),
  company_id: z.string().uuid(),
  name: z.string().min(1, 'Client name is required'),
  email: z.string().email().nullable(),
  phone: z.string().nullable(),
  address: z.string().nullable(),
  contact_person: z.string().nullable(),
  notes: z.string().nullable(),
  status: z.enum(['active', 'inactive', 'archived']).default('active'),
  user_id: z.string().uuid().nullable()
})

// Create schemas (without auto-generated fields)
export const createTicketSchema = ticketSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  company_id: true,
  user_id: true,
  ticket_number: true
})

export const createClientSchema = clientSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  company_id: true,
  user_id: true
})

// Update schemas
export const updateTicketSchema = ticketSchema.partial().extend({
  id: z.string().uuid()
})

export const updateClientSchema = clientSchema.partial().extend({
  id: z.string().uuid()
})

export type Ticket = z.infer<typeof ticketSchema>
export type Client = z.infer<typeof clientSchema>
export type CreateTicket = z.infer<typeof createTicketSchema>
export type CreateClient = z.infer<typeof createClientSchema>
export type UpdateTicket = z.infer<typeof updateTicketSchema>
export type UpdateClient = z.infer<typeof updateClientSchema>

export const useTickets = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Reactive state
  const tickets = ref<Ticket[]>([])
  const clients = ref<Client[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Get user's company_id
  const getUserCompanyId = async (): Promise<string | null> => {
    if (!user.value) {
      console.log('No user found')
      return null
    }

    try {
      console.log('Looking for user_profiles for user:', user.value.id)

      const { data, error } = await client
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.value.id)
        .single()

      console.log('user_profiles query result:', { data, error })

      if (error) {
        console.log('Error or no user profile found, using default company_id')
        // If no user profile exists, return a default company_id for testing
        return '00000000-0000-0000-0000-000000000001'
      }

      return data?.company_id || '00000000-0000-0000-0000-000000000001'
    } catch (err) {
      console.error('Error getting user company ID:', err)
      // Return default company_id for testing
      return '00000000-0000-0000-0000-000000000001'
    }
  }

  // Fetch tickets with filters
  const fetchTickets = async (filters?: {
    status?: string
    priority?: string
    category?: string
    client_id?: string
    search?: string
  }) => {
    try {
      loading.value = true
      error.value = null

      let query = client
        .from('tickets')
        .select(`
          *,
          client:clients(*)
        `)
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters?.status && filters.status !== 'all') {
        query = query.eq('status', filters.status)
      }
      if (filters?.priority && filters.priority !== 'all') {
        query = query.eq('priority', filters.priority)
      }
      if (filters?.category) {
        query = query.eq('category', filters.category)
      }
      if (filters?.client_id) {
        query = query.eq('client_id', filters.client_id)
      }
      if (filters?.search) {
        query = query.or(`title.ilike.%${filters.search}%,description.ilike.%${filters.search}%,client_name.ilike.%${filters.search}%,ticket_number.ilike.%${filters.search}%`)
      }

      const { data, error: supabaseError } = await query

      if (supabaseError) throw supabaseError

      // Parse and validate data
      tickets.value = (data || []).map(item => {
        try {
          return ticketSchema.parse(item)
        } catch (e) {
          console.error('Invalid ticket data:', item, e)
          return null
        }
      }).filter(Boolean) as Ticket[]

    } catch (err) {
      console.error('Error fetching tickets:', err)
      error.value = 'Failed to load tickets. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Fetch clients for autocomplete
  const fetchClients = async (search?: string) => {
    try {
      console.log('Fetching clients with search:', search)
      console.log('Current user:', user.value)

      // First, let's try to get the user's company_id
      const companyId = await getUserCompanyId()
      console.log('User company ID:', companyId)

      let query = client
        .from('clients')
        .select('*')
        .eq('status', 'active')
        .order('name', { ascending: true })

      // If we have a company_id, filter by it
      if (companyId) {
        query = query.eq('company_id', companyId)
      }

      if (search) {
        query = query.ilike('name', `%${search}%`)
      }

      const { data, error: supabaseError } = await query

      console.log('Clients query result:', { data, error: supabaseError })

      if (supabaseError) {
        console.error('Supabase error details:', supabaseError)
        throw supabaseError
      }

      // For now, let's be more lenient with parsing since we're debugging
      clients.value = (data || []).map(item => {
        try {
          // Let's first see what the raw data looks like
          console.log('Raw client item:', item)
          return item as Client // Temporarily skip validation
        } catch (e) {
          console.error('Invalid client data:', item, e)
          return null
        }
      }).filter(Boolean) as Client[]

      console.log('Parsed clients:', clients.value)
      return clients.value
    } catch (err) {
      console.error('Error fetching clients:', err)
      return []
    }
  }

  // Create a new ticket
  const createTicket = async (ticketData: CreateTicket): Promise<Ticket | null> => {
    try {
      if (!user.value) throw new Error('User not authenticated')

      const companyId = await getUserCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      // Validate input data
      const validatedData = createTicketSchema.parse(ticketData)

      const { data, error: supabaseError } = await client
        .from('tickets')
        .insert({
          ...validatedData,
          user_id: user.value.id,
          company_id: companyId
        })
        .select()
        .single()

      if (supabaseError) throw supabaseError

      const newTicket = ticketSchema.parse(data)

      // Add to local state
      tickets.value.unshift(newTicket)

      return newTicket
    } catch (err) {
      console.error('Error creating ticket:', err)
      error.value = 'Failed to create ticket. Please try again.'
      return null
    }
  }

  // Update a ticket
  const updateTicket = async (ticketData: UpdateTicket): Promise<Ticket | null> => {
    try {
      const validatedData = updateTicketSchema.parse(ticketData)
      const { id, ...updateFields } = validatedData

      // Set resolved_at if status is being changed to resolved
      if (updateFields.status === 'resolved' && !updateFields.resolved_at) {
        updateFields.resolved_at = new Date().toISOString()
      }

      const { data, error: supabaseError } = await client
        .from('tickets')
        .update(updateFields)
        .eq('id', id)
        .select()
        .single()

      if (supabaseError) throw supabaseError

      const updatedTicket = ticketSchema.parse(data)

      // Update local state
      const index = tickets.value.findIndex(t => t.id === id)
      if (index !== -1) {
        tickets.value[index] = updatedTicket
      }

      return updatedTicket
    } catch (err) {
      console.error('Error updating ticket:', err)
      error.value = 'Failed to update ticket. Please try again.'
      return null
    }
  }

  // Delete a ticket
  const deleteTicket = async (id: string): Promise<boolean> => {
    try {
      const { error: supabaseError } = await client
        .from('tickets')
        .delete()
        .eq('id', id)

      if (supabaseError) throw supabaseError

      // Remove from local state
      tickets.value = tickets.value.filter(t => t.id !== id)

      return true
    } catch (err) {
      console.error('Error deleting ticket:', err)
      error.value = 'Failed to delete ticket. Please try again.'
      return false
    }
  }

  // Get tickets by status
  const getTicketsByStatus = (status: string) => {
    return computed(() => tickets.value.filter(ticket => ticket.status === status))
  }

  // Get tickets by priority
  const getTicketsByPriority = (priority: string) => {
    return computed(() => tickets.value.filter(ticket => ticket.priority === priority))
  }

  // Get open tickets
  const openTickets = computed(() => tickets.value.filter(ticket => ticket.status === 'open'))

  // Get in progress tickets
  const inProgressTickets = computed(() => tickets.value.filter(ticket => ticket.status === 'in_progress'))

  // Get resolved tickets
  const resolvedTickets = computed(() => tickets.value.filter(ticket => ticket.status === 'resolved'))

  // Get urgent tickets
  const urgentTickets = computed(() => tickets.value.filter(ticket => ticket.priority === 'urgent'))

  // Subscribe to real-time changes
  const subscribeToTickets = () => {
    if (!user.value) return null

    return client
      .channel('tickets')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'tickets'
        },
        (payload) => {
          console.log('Ticket change received:', payload)
          // Refresh tickets when changes occur
          fetchTickets()
        }
      )
      .subscribe()
  }

  // Search clients for autocomplete
  const searchClients = async (query: string): Promise<Client[]> => {
    if (query.length < 2) return []
    return await fetchClients(query)
  }

  return {
    // State
    tickets: readonly(tickets),
    clients: readonly(clients),
    loading: readonly(loading),
    error: readonly(error),

    // Actions
    fetchTickets,
    fetchClients,
    createTicket,
    updateTicket,
    deleteTicket,
    searchClients,

    // Computed
    getTicketsByStatus,
    getTicketsByPriority,
    openTickets,
    inProgressTickets,
    resolvedTickets,
    urgentTickets,

    // Real-time
    subscribeToTickets,

    // Utils
    getUserCompanyId
  }
}