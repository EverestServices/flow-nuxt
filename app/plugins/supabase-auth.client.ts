// plugins/supabase-auth.client.ts
export default defineNuxtPlugin(async (nuxtApp) => {
    const client = useSupabaseClient()
    const user = useSupabaseUser()
    const router = useRouter()

    // Check if URL has auth hash parameters (password reset, invite, etc)
    // If so, redirect to /confirm to handle them properly
    if (typeof window !== 'undefined') {
        const hash = window.location.hash
        if (hash && (hash.includes('access_token') || hash.includes('type=recovery') || hash.includes('type=invite'))) {
            const currentPath = window.location.pathname
            // Only redirect if not already on confirm or reset-password page
            if (currentPath !== '/confirm' && currentPath !== '/reset-password') {
                await router.push('/confirm' + hash)
                return
            }
        }
    }

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