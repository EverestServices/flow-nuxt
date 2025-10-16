// middleware/auth.global.ts
export default defineNuxtRouteMiddleware(async (to) => {
    // Public routes that don't require authentication
    const publicRoutes = ['/login', '/register', '/forgot-password']

    // If the route is public, we don't need to check authentication
    if (publicRoutes.includes(to.path)) {
        return
    }

    // Get the user state
    const user = useSupabaseUser()

    // If we're on the client side and no user, redirect to login
    if (process.client && !user.value) {
        return navigateTo('/login')
    }
})