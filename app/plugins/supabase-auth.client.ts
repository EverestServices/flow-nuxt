// plugins/supabase-auth.client.ts
export default defineNuxtPlugin(async (nuxtApp) => {
    // Use the useSupabaseClient composable to get the client
    const client = useSupabaseClient()
    const user = useSupabaseUser()

    // Add a flag to track when initial auth check is complete
    const authInitialized = useState('auth-initialized', () => false)

    // Check and refresh the auth state
    if (!authInitialized.value) {
        try {
            // This will update the user ref if a session exists
            const { data } = await client.auth.getSession()

            // Listen for auth state changes
            const { data: { subscription } } = client.auth.onAuthStateChange((event, session) => {
                // Update the user ref when auth state changes
                user.value = session?.user || null
            })

            // Cleanup on app unmount
            nuxtApp.hook('app:unmount', () => {
                subscription.unsubscribe()
            })
        } catch (e) {
            console.error('Error checking auth state:', e)
        } finally {
            // Mark auth as initialized
            authInitialized.value = true
        }
    }
})