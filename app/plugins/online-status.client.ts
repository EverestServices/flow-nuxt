export default defineNuxtPlugin(() => {
  const { startActivityTracking, stopActivityTracking } = useOnlineStatus()
  const user = useSupabaseUser()

  // Watch for user authentication state changes
  watch(user, (newUser, oldUser) => {
    // Stop tracking for previous user
    if (oldUser) {
      stopActivityTracking()
    }

    // Start tracking for new user
    if (newUser) {
      startActivityTracking()
    }
  }, { immediate: true })

  // Cleanup on app unmount
  if (process.client) {
    window.addEventListener('beforeunload', () => {
      stopActivityTracking()
    })
  }
})