export interface UserOnlineStatus {
  user_id: string
  first_name?: string
  last_name?: string
  is_online: boolean
  last_seen: string
  last_activity: string
}

// Global state to ensure single instance across the app
const globalState = {
  onlineUsers: ref<UserOnlineStatus[]>([]),
  currentUserOnline: ref(false),
  loading: ref(false),
  error: ref<string | null>(null),
  initialized: false,
  profileErrorLogged: false,
  updateErrorLogged: false,
  networkErrorLogged: false,
  offlineErrorLogged: false
}

export const useOnlineStatus = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Use global state instead of local state
  const onlineUsers = globalState.onlineUsers
  const currentUserOnline = globalState.currentUserOnline
  const loading = globalState.loading
  const error = globalState.error

  console.log('useOnlineStatus composable called, currentUserOnline:', currentUserOnline.value, 'initialized:', globalState.initialized)

  // Activity tracking
  let activityTimer: NodeJS.Timeout | null = null
  let heartbeatTimer: NodeJS.Timeout | null = null

  // Update current user's activity
  const updateActivity = async () => {
    if (!user.value) return

    try {
      // First try to update the profile
      const { error: updateError } = await client
        .from('user_profiles')
        .update({
          is_online: true,
          last_activity: new Date().toISOString(),
          last_seen: new Date().toISOString()
        })
        .eq('user_id', user.value.id)

      if (updateError) {
        // If update fails, try to create the profile
        if (updateError.message.includes('Load failed') || updateError.message.includes('access control')) {
          console.warn('Profile update failed, attempting to create profile...')

          const { error: insertError } = await client
            .from('user_profiles')
            .insert({
              user_id: user.value.id,
              email: user.value.email,
              is_online: true,
              last_activity: new Date().toISOString(),
              last_seen: new Date().toISOString()
            })

          if (insertError) {
            // Only log error once, don't spam console
            if (!globalState.profileErrorLogged) {
              console.error('Failed to create user profile:', insertError)
              globalState.profileErrorLogged = true
            }
            return
          }
        } else {
          // Only log other errors once
          if (!globalState.updateErrorLogged) {
            console.error('Error updating user activity:', updateError)
            globalState.updateErrorLogged = true
          }
          return
        }
      }

      currentUserOnline.value = true
      // Reset error flags on success
      globalState.profileErrorLogged = false
      globalState.updateErrorLogged = false
    } catch (err) {
      // Only log network errors once
      if (!globalState.networkErrorLogged) {
        console.error('Network error in updateActivity:', err)
        globalState.networkErrorLogged = true
      }
    }
  }

  // Set current user offline
  const setOffline = async () => {
    if (!user.value) return

    try {
      const { error: offlineError } = await client
        .from('user_profiles')
        .update({
          is_online: false,
          last_seen: new Date().toISOString()
        })
        .eq('user_id', user.value.id)

      if (offlineError) {
        // Only log error once per session to avoid spam
        if (!globalState.offlineErrorLogged) {
          console.error('Error setting user offline:', offlineError)
          globalState.offlineErrorLogged = true
        }
      } else {
        currentUserOnline.value = false
        globalState.offlineErrorLogged = false
      }
    } catch (err) {
      // Silently fail for network issues in setOffline
      currentUserOnline.value = false
    }
  }

  // Fetch online users in the same company
  const fetchOnlineUsers = async () => {
    if (!user.value) return

    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await client
        .from('user_profiles')
        .select('user_id, first_name, last_name, is_online, last_seen, last_activity')
        .eq('is_online', true)
        .neq('user_id', user.value.id) // Exclude current user
        .order('last_activity', { ascending: false })

      if (fetchError) {
        throw fetchError
      }

      onlineUsers.value = data || []
      console.log('Fetched online users:', data?.length || 0)
    } catch (err) {
      console.error('Error fetching online users:', err)
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Get online status for specific user
  const getUserOnlineStatus = async (userId: string): Promise<UserOnlineStatus | null> => {
    try {
      const { data, error: fetchError } = await client
        .from('user_profiles')
        .select('user_id, first_name, last_name, is_online, last_seen, last_activity')
        .eq('user_id', userId)
        .single()

      if (fetchError) {
        throw fetchError
      }

      return data
    } catch (err) {
      console.error('Error fetching user online status:', err)
      return null
    }
  }

  // Check if user is online (considers last activity within 5 minutes)
  const isUserOnline = (lastActivity: string): boolean => {
    const now = new Date()
    const lastActivityDate = new Date(lastActivity)
    const diffMinutes = (now.getTime() - lastActivityDate.getTime()) / (1000 * 60)
    return diffMinutes < 5
  }

  // Start tracking user activity
  const startActivityTracking = () => {
    if (!user.value || globalState.initialized) return

    console.log('Starting activity tracking for user:', user.value.id)
    globalState.initialized = true

    // Initial activity update
    updateActivity()

    // Set up heartbeat to update activity every 2 minutes
    // But only if there haven't been persistent errors
    heartbeatTimer = setInterval(() => {
      // Skip heartbeat if there are persistent access errors
      if (!globalState.profileErrorLogged && !globalState.networkErrorLogged) {
        updateActivity()
      }
    }, 2 * 60 * 1000) // 2 minutes

    // Track user interactions
    const trackActivity = () => {
      // Skip if there are persistent errors
      if (globalState.profileErrorLogged || globalState.networkErrorLogged) return

      if (activityTimer) clearTimeout(activityTimer)

      activityTimer = setTimeout(() => {
        updateActivity()
      }, 5000) // Increased debounce to 5 seconds to reduce API calls
    }

    // Listen for user interactions
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']
    events.forEach(event => {
      document.addEventListener(event, trackActivity, { passive: true })
    })

    // Handle page visibility changes
    const handleVisibilityChange = () => {
      if (document.hidden) {
        setOffline()
      } else {
        updateActivity()
      }
    }

    document.addEventListener('visibilitychange', handleVisibilityChange)

    // Handle page unload
    const handleBeforeUnload = () => {
      setOffline()
    }

    window.addEventListener('beforeunload', handleBeforeUnload)

    return () => {
      // Cleanup function
      if (activityTimer) clearTimeout(activityTimer)
      if (heartbeatTimer) clearInterval(heartbeatTimer)

      events.forEach(event => {
        document.removeEventListener(event, trackActivity)
      })
      document.removeEventListener('visibilitychange', handleVisibilityChange)
      window.removeEventListener('beforeunload', handleBeforeUnload)
    }
  }

  // Stop activity tracking
  const stopActivityTracking = () => {
    if (activityTimer) {
      clearTimeout(activityTimer)
      activityTimer = null
    }
    if (heartbeatTimer) {
      clearInterval(heartbeatTimer)
      heartbeatTimer = null
    }
    globalState.initialized = false
    setOffline()
  }

  // Subscribe to online users changes
  const subscribeToOnlineUsers = () => {
    if (!user.value) return

    const subscription = client
      .channel('online_users')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'user_profiles',
          filter: `is_online=eq.true`
        },
        () => {
          fetchOnlineUsers()
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }

  // Format last seen time
  const formatLastSeen = (lastSeen: string): string => {
    const now = new Date()
    const lastSeenDate = new Date(lastSeen)
    const diffMinutes = Math.floor((now.getTime() - lastSeenDate.getTime()) / (1000 * 60))

    if (diffMinutes < 1) return 'Just now'
    if (diffMinutes < 60) return `${diffMinutes} min ago`

    const diffHours = Math.floor(diffMinutes / 60)
    if (diffHours < 24) return `${diffHours}h ago`

    const diffDays = Math.floor(diffHours / 24)
    return `${diffDays}d ago`
  }

  // Computed properties
  const onlineCount = computed(() => onlineUsers.value.length + (currentUserOnline.value ? 1 : 0))

  return {
    // State
    onlineUsers: readonly(onlineUsers),
    currentUserOnline: readonly(currentUserOnline),
    loading: readonly(loading),
    error: readonly(error),

    // Computed
    onlineCount,

    // Methods
    updateActivity,
    setOffline,
    fetchOnlineUsers,
    getUserOnlineStatus,
    isUserOnline,
    startActivityTracking,
    stopActivityTracking,
    subscribeToOnlineUsers,
    formatLastSeen
  }
}