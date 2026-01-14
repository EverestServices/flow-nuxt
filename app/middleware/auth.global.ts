// middleware/auth.global.ts
export default defineNuxtRouteMiddleware(async (to) => {
    // Public routes that don't require authentication
    // Check this FIRST, before anything else
    const publicRoutes = ['/login', '/register', '/forgot-password', '/confirm', '/reset-password', '/auth/external-callback']

    if (publicRoutes.includes(to.path)) {
        return
    }

    // Skip auth check if the route explicitly disables it
    if (to.meta.auth === false) {
        return
    }

    // Get the user state
    const user = useSupabaseUser()

    // ONLY redirect on the client side (not during SSR)
    // This prevents redirect loops and allows auth callbacks to work
    if (process.client && !user.value) {
        return navigateTo('/login')
    }
})