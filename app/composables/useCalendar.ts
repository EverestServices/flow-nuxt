export interface CalendarEvent {
  id: string
  title: string
  description?: string
  type: 'meeting' | 'training' | 'other' | 'on-site-consultation' | 'online-consultation' | 'personal' | 'holiday'
  start_date: string
  start_time?: string
  end_date: string
  end_time?: string
  all_day: boolean
  visibility: 'public' | 'private' | 'confidential'
  notes?: string
  location?: string
  attendees?: string[] // Array of email addresses
  created_at: string
  updated_at: string
  user_id: string
}

export interface CreateEventData {
  title: string
  description?: string
  type: 'meeting' | 'training' | 'other' | 'on-site-consultation' | 'online-consultation' | 'personal' | 'holiday'
  start_date: string
  start_time?: string
  end_date: string
  end_time?: string
  all_day?: boolean
  visibility?: 'public' | 'private' | 'confidential'
  notes?: string
  location?: string
  attendees?: string[]
}

export interface UpdateEventData extends Partial<CreateEventData> {
  id: string
}

export interface CalendarFilters {
  type?: string
  visibility?: string
  start_date?: string
  end_date?: string
}

export type CalendarView = 'daily' | 'weekly' | 'monthly' | 'map'

export const useCalendar = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const events = ref<CalendarEvent[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const currentView = ref<CalendarView>('monthly')
  const currentDate = ref(new Date())

  // Computed properties for different event types
  const meetingEvents = computed(() =>
    events.value.filter(event => event.type === 'meeting')
  )

  const consultationEvents = computed(() =>
    events.value.filter(event =>
      event.type === 'on-site-consultation' || event.type === 'online-consultation'
    )
  )

  const personalEvents = computed(() =>
    events.value.filter(event => event.type === 'personal')
  )

  const holidayEvents = computed(() =>
    events.value.filter(event => event.type === 'holiday')
  )

  // Get events for current view
  const viewEvents = computed(() => {
    const now = currentDate.value
    let startDate: Date
    let endDate: Date

    switch (currentView.value) {
      case 'daily':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
        break
      case 'weekly':
        const startOfWeek = new Date(now)
        startOfWeek.setDate(now.getDate() - now.getDay())
        startDate = new Date(startOfWeek.getFullYear(), startOfWeek.getMonth(), startOfWeek.getDate())
        endDate = new Date(startOfWeek.getFullYear(), startOfWeek.getMonth(), startOfWeek.getDate() + 7)
        break
      case 'monthly':
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0)
        break
    }

    return events.value.filter(event => {
      const eventDate = new Date(event.start_date)
      return eventDate >= startDate && eventDate <= endDate
    })
  })

  // Get today's events
  const todayEvents = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    return events.value.filter(event => event.start_date === today)
  })

  // Get upcoming events (next 7 days)
  const upcomingEvents = computed(() => {
    const today = new Date()
    const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)

    return events.value
      .filter(event => {
        const eventDate = new Date(event.start_date)
        return eventDate >= today && eventDate <= nextWeek
      })
      .sort((a, b) => new Date(a.start_date).getTime() - new Date(b.start_date).getTime())
      .slice(0, 5) // Limit to 5 upcoming events
  })

  // Fetch events
  const fetchEvents = async (filters?: CalendarFilters): Promise<CalendarEvent[]> => {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('calendar_events')
        .select('*')
        .order('start_date', { ascending: true })

      // Apply filters
      if (filters?.type && filters.type !== 'all') {
        query = query.eq('type', filters.type)
      }

      if (filters?.visibility && filters.visibility !== 'all') {
        query = query.eq('visibility', filters.visibility)
      }

      if (filters?.start_date) {
        query = query.gte('start_date', filters.start_date)
      }

      if (filters?.end_date) {
        query = query.lte('start_date', filters.end_date)
      }

      const { data, error: fetchError } = await query

      if (fetchError) {
        console.error('Error fetching events:', fetchError)
        error.value = fetchError.message
        return []
      }

      events.value = data || []
      return data || []
    } catch (err) {
      console.error('Error in fetchEvents:', err)
      error.value = 'Failed to fetch events'
      return []
    } finally {
      loading.value = false
    }
  }

  // Create a new event
  const createEvent = async (eventData: CreateEventData): Promise<CalendarEvent | null> => {
    loading.value = true
    error.value = null

    try {
      const { data, error: createError } = await supabase
        .from('calendar_events')
        .insert([{
          ...eventData,
          all_day: eventData.all_day || false,
          visibility: eventData.visibility || 'public',
          attendees: eventData.attendees || [],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          user_id: user.value?.id
        }])
        .select()
        .single()

      if (createError) {
        console.error('Error creating event:', createError)
        error.value = createError.message
        return null
      }

      // Add to local events array
      events.value.push(data)
      // Sort events by date
      events.value.sort((a, b) => new Date(a.start_date).getTime() - new Date(b.start_date).getTime())

      return data
    } catch (err) {
      console.error('Error in createEvent:', err)
      error.value = 'Failed to create event'
      return null
    } finally {
      loading.value = false
    }
  }

  // Update an existing event
  const updateEvent = async (eventData: UpdateEventData): Promise<CalendarEvent | null> => {
    loading.value = true
    error.value = null

    try {
      const { data, error: updateError } = await supabase
        .from('calendar_events')
        .update({
          ...eventData,
          updated_at: new Date().toISOString()
        })
        .eq('id', eventData.id)
        .select()
        .single()

      if (updateError) {
        console.error('Error updating event:', updateError)
        error.value = updateError.message
        return null
      }

      // Update local events array
      const index = events.value.findIndex(e => e.id === eventData.id)
      if (index !== -1) {
        events.value[index] = data
      }

      return data
    } catch (err) {
      console.error('Error in updateEvent:', err)
      error.value = 'Failed to update event'
      return null
    } finally {
      loading.value = false
    }
  }

  // Delete an event
  const deleteEvent = async (eventId: string): Promise<boolean> => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('calendar_events')
        .delete()
        .eq('id', eventId)

      if (deleteError) {
        console.error('Error deleting event:', deleteError)
        error.value = deleteError.message
        return false
      }

      // Remove from local events array
      events.value = events.value.filter(e => e.id !== eventId)

      return true
    } catch (err) {
      console.error('Error in deleteEvent:', err)
      error.value = 'Failed to delete event'
      return false
    } finally {
      loading.value = false
    }
  }

  // Get event by ID
  const getEventById = async (eventId: string): Promise<CalendarEvent | null> => {
    try {
      const { data, error: fetchError } = await supabase
        .from('calendar_events')
        .select('*')
        .eq('id', eventId)
        .single()

      if (fetchError) {
        console.error('Error fetching event:', fetchError)
        return null
      }

      return data
    } catch (err) {
      console.error('Error in getEventById:', err)
      return null
    }
  }

  // Navigate calendar
  const navigateCalendar = (direction: 'prev' | 'next' | 'today') => {
    const current = currentDate.value

    switch (direction) {
      case 'prev':
        if (currentView.value === 'daily') {
          currentDate.value = new Date(current.getTime() - 24 * 60 * 60 * 1000)
        } else if (currentView.value === 'weekly') {
          currentDate.value = new Date(current.getTime() - 7 * 24 * 60 * 60 * 1000)
        } else {
          currentDate.value = new Date(current.getFullYear(), current.getMonth() - 1, current.getDate())
        }
        break
      case 'next':
        if (currentView.value === 'daily') {
          currentDate.value = new Date(current.getTime() + 24 * 60 * 60 * 1000)
        } else if (currentView.value === 'weekly') {
          currentDate.value = new Date(current.getTime() + 7 * 24 * 60 * 60 * 1000)
        } else {
          currentDate.value = new Date(current.getFullYear(), current.getMonth() + 1, current.getDate())
        }
        break
      case 'today':
        currentDate.value = new Date()
        break
    }
  }

  // Set calendar view
  const setView = (view: CalendarView) => {
    currentView.value = view
  }

  return {
    // State
    events: readonly(events),
    loading: readonly(loading),
    error: readonly(error),
    currentView: readonly(currentView),
    currentDate: readonly(currentDate),

    // Computed
    meetingEvents,
    consultationEvents,
    personalEvents,
    holidayEvents,
    viewEvents,
    todayEvents,
    upcomingEvents,

    // Methods
    fetchEvents,
    createEvent,
    updateEvent,
    deleteEvent,
    getEventById,
    navigateCalendar,
    setView
  }
}