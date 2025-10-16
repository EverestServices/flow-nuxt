export interface Colleague {
  user_id: string
  first_name?: string
  last_name?: string
  email?: string
  avatar_url?: string
  is_online?: boolean
  last_activity?: string
}

export const useColleagues = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  const colleagues = ref<Colleague[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Fetch all colleagues from the same company/organization
  const fetchColleagues = async (): Promise<Colleague[]> => {
    if (!user.value) return []

    try {
      loading.value = true
      error.value = null

      // First, let's get the current user's auth record to get their email
      const { data: authData, error: authError } = await client.auth.getUser()
      if (authError) throw authError

      // Get colleagues from user_profiles with email and avatar, excluding current user
      const { data, error: fetchError } = await client
        .from('user_profiles')
        .select('user_id, first_name, last_name, email, avatar_url, is_online, last_activity')
        .neq('user_id', user.value.id)
        .order('first_name', { ascending: true })

      if (fetchError) throw fetchError

      // If email is not available in user_profiles, try to get it via the function
      const colleaguesWithEmails = await Promise.all(
        (data || []).map(async (colleague) => {
          let email = colleague.email

          // If no email in profile, try to get it via the database function
          if (!email) {
            try {
              const { data: emailData, error: emailError } = await client
                .rpc('get_user_email_by_id', { target_user_id: colleague.user_id })

              if (!emailError && emailData) {
                email = emailData
              }
            } catch (err) {
              console.warn('Could not fetch email for colleague:', colleague.user_id)
            }
          }

          // Final fallback to a placeholder email
          if (!email) {
            email = `${(colleague.first_name || 'user').toLowerCase()}@company.com`
          }

          return {
            ...colleague,
            email
          }
        })
      )

      colleagues.value = colleaguesWithEmails
      return colleaguesWithEmails
    } catch (err) {
      console.error('Error fetching colleagues:', err)
      error.value = err.message || 'Failed to fetch colleagues'
      return []
    } finally {
      loading.value = false
    }
  }

  // Get colleague by ID
  const getColleagueById = (userId: string): Colleague | null => {
    return colleagues.value.find(c => c.user_id === userId) || null
  }

  // Format colleague display name
  const getColleagueName = (colleague: Colleague): string => {
    if (colleague.first_name || colleague.last_name) {
      return `${colleague.first_name || ''} ${colleague.last_name || ''}`.trim()
    }
    return colleague.email || 'Unknown User'
  }

  // Get colleague initials
  const getColleagueInitials = (colleague: Colleague): string => {
    const firstName = colleague.first_name
    const lastName = colleague.last_name

    if (!firstName && !lastName) {
      // Fallback to email initials
      if (colleague.email) {
        const emailParts = colleague.email.split('@')[0]
        return emailParts.slice(0, 2).toUpperCase()
      }
      return '??'
    }

    const first = firstName?.[0] || ''
    const last = lastName?.[0] || ''
    return (first + last).toUpperCase()
  }

  // Check if colleague is online (within last 5 minutes)
  const isColleagueOnline = (colleague: Colleague): boolean => {
    if (colleague.is_online === false) return false
    if (!colleague.last_activity) return false

    const now = new Date()
    const lastActivity = new Date(colleague.last_activity)
    const diffMinutes = (now.getTime() - lastActivity.getTime()) / (1000 * 60)

    return diffMinutes < 5
  }

  // Get online colleagues only
  const onlineColleagues = computed(() => {
    return colleagues.value.filter(colleague => isColleagueOnline(colleague))
  })

  // Get offline colleagues
  const offlineColleagues = computed(() => {
    return colleagues.value.filter(colleague => !isColleagueOnline(colleague))
  })

  return {
    // State
    colleagues: readonly(colleagues),
    loading: readonly(loading),
    error: readonly(error),

    // Computed
    onlineColleagues,
    offlineColleagues,

    // Methods
    fetchColleagues,
    getColleagueById,
    getColleagueName,
    getColleagueInitials,
    isColleagueOnline
  }
}