// stores/auth.ts (simplified version)
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {

    state: () => ({
        user: null,
        token: null,
        isLoggedIn: false
    }),

    actions: {
        async login(credentials) {
            try {
                const config = useRuntimeConfig()

                // Attempt login without CSRF
                const response = await $fetch(config.public.apiBaseUrl + '/login', {
                    method: 'POST',
                    body: credentials,
                    headers: {
                        //'Platform' : 'app',
                        //'Referer': 'https://app.easyhaccp.hu/'
                    }
                })

                this.token = response.token
                this.user = response.user
                this.isLoggedIn = true

                // Save token to localStorage for persistence
                if (process.client) {
                    localStorage.setItem('token', response.token)
                }

                return { success: true }
            } catch (error) {
                console.error('Login failed:', error)
                return { success: false, error }
            }
        },

        async logout() {
            try {
                const config = useRuntimeConfig()

                if (this.token) {
                    await $fetch(config.public.apiBaseUrl + '/logout', {
                        method: 'POST',
                        headers: {
                            Authorization: `Bearer ${this.token}`
                        }
                    })
                }
            } catch (error) {
                console.error('Logout error:', error)
            } finally {
                this.user = null
                this.token = null
                this.isLoggedIn = false
                if (process.client) {
                    localStorage.removeItem('token')
                }
            }
        },

        async checkAuth() {
            if (!process.client) {
                return false
            }

            const savedToken = localStorage.getItem('token')

            if (savedToken) {
                try {
                    const config = useRuntimeConfig()

                    const user = await $fetch(config.public.apiBaseUrl + '/user', {
                        headers: {
                            Authorization: `Bearer ${savedToken}`,
                            //'Referer': 'https://app.easyhaccp.hu/'
                        }
                    })

                    this.token = savedToken
                    this.user = user
                    this.isLoggedIn = true
                    return true
                } catch (error) {
                    this.token = null
                    this.user = null
                    this.isLoggedIn = false
                    if (process.client) {
                        localStorage.removeItem('token')
                    }
                    return false
                }
            }
            return false
        }
    }
})