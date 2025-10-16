export interface Client {
  id: string
  name: string
  email?: string
  phone?: string
  address?: string
  contact_person?: string
  notes?: string
  status: 'active' | 'inactive' | 'prospect' | 'archived'
  created_at: string
  updated_at: string
}

export interface CreateClientData {
  name: string
  email?: string
  phone?: string
  address?: string
  contact_person?: string
  notes?: string
  status?: 'active' | 'inactive' | 'prospect' | 'archived'
}

export interface UpdateClientData extends Partial<CreateClientData> {
  id: string
}

export interface ClientFilters {
  search?: string
  status?: string
}

export const useClients = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const clients = ref<Client[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Computed properties for different client statuses
  const activeClients = computed(() =>
    clients.value.filter(client => client.status === 'active')
  )

  const prospectClients = computed(() =>
    clients.value.filter(client => client.status === 'prospect')
  )

  const inactiveClients = computed(() =>
    clients.value.filter(client => client.status === 'inactive')
  )

  const archivedClients = computed(() =>
    clients.value.filter(client => client.status === 'archived')
  )

  // Fetch all clients
  const fetchClients = async (filters?: ClientFilters): Promise<Client[]> => {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('clients')
        .select('*')
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters?.status && filters.status !== 'all') {
        query = query.eq('status', filters.status)
      }

      if (filters?.search && filters.search.trim()) {
        const searchTerm = filters.search.trim()
        query = query.or(`name.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%,contact_person.ilike.%${searchTerm}%`)
      }

      const { data, error: fetchError } = await query

      if (fetchError) {
        console.error('Error fetching clients:', fetchError)
        error.value = fetchError.message
        return []
      }

      clients.value = data || []
      return data || []
    } catch (err) {
      console.error('Error in fetchClients:', err)
      error.value = 'Failed to fetch clients'
      return []
    } finally {
      loading.value = false
    }
  }

  // Create a new client
  const createClient = async (clientData: CreateClientData): Promise<Client | null> => {
    loading.value = true
    error.value = null

    try {
      const { data, error: createError } = await supabase
        .from('clients')
        .insert([{
          ...clientData,
          status: clientData.status || 'active',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select()
        .single()

      if (createError) {
        console.error('Error creating client:', createError)
        error.value = createError.message
        return null
      }

      // Add to local clients array
      clients.value.unshift(data)

      return data
    } catch (err) {
      console.error('Error in createClient:', err)
      error.value = 'Failed to create client'
      return null
    } finally {
      loading.value = false
    }
  }

  // Update an existing client
  const updateClient = async (clientData: UpdateClientData): Promise<Client | null> => {
    loading.value = true
    error.value = null

    try {
      const { data, error: updateError } = await supabase
        .from('clients')
        .update({
          ...clientData,
          updated_at: new Date().toISOString()
        })
        .eq('id', clientData.id)
        .select()
        .single()

      if (updateError) {
        console.error('Error updating client:', updateError)
        error.value = updateError.message
        return null
      }

      // Update local clients array
      const index = clients.value.findIndex(c => c.id === clientData.id)
      if (index !== -1) {
        clients.value[index] = data
      }

      return data
    } catch (err) {
      console.error('Error in updateClient:', err)
      error.value = 'Failed to update client'
      return null
    } finally {
      loading.value = false
    }
  }

  // Delete a client
  const deleteClient = async (clientId: string): Promise<boolean> => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('clients')
        .delete()
        .eq('id', clientId)

      if (deleteError) {
        console.error('Error deleting client:', deleteError)
        error.value = deleteError.message
        return false
      }

      // Remove from local clients array
      clients.value = clients.value.filter(c => c.id !== clientId)

      return true
    } catch (err) {
      console.error('Error in deleteClient:', err)
      error.value = 'Failed to delete client'
      return false
    } finally {
      loading.value = false
    }
  }

  // Get a single client by ID
  const getClientById = async (clientId: string): Promise<Client | null> => {
    try {
      const { data, error: fetchError } = await supabase
        .from('clients')
        .select('*')
        .eq('id', clientId)
        .single()

      if (fetchError) {
        console.error('Error fetching client:', fetchError)
        return null
      }

      return data
    } catch (err) {
      console.error('Error in getClientById:', err)
      return null
    }
  }

  // Search clients
  const searchClients = async (searchTerm: string): Promise<Client[]> => {
    if (!searchTerm.trim()) {
      return clients.value
    }

    try {
      const { data, error: searchError } = await supabase
        .from('clients')
        .select('*')
        .or(`name.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%,contact_person.ilike.%${searchTerm}%`)
        .order('created_at', { ascending: false })

      if (searchError) {
        console.error('Error searching clients:', searchError)
        return []
      }

      return data || []
    } catch (err) {
      console.error('Error in searchClients:', err)
      return []
    }
  }

  return {
    // State
    clients: readonly(clients),
    loading: readonly(loading),
    error: readonly(error),

    // Computed
    activeClients,
    prospectClients,
    inactiveClients,
    archivedClients,

    // Methods
    fetchClients,
    createClient,
    updateClient,
    deleteClient,
    getClientById,
    searchClients
  }
}