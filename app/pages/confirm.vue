<!-- pages/confirm.vue -->
<script setup lang="ts">
definePageMeta({
  layout: 'login'
})

const client = useSupabaseClient()
const router = useRouter()
const isLoading = ref(true)
const errorMessage = ref('')

onMounted(async () => {
  try {
    // Check if this is a password recovery or invite callback
    const hashParams = new URLSearchParams(window.location.hash.substring(1))
    const type = hashParams.get('type')
    const accessToken = hashParams.get('access_token')

    if (type === 'recovery' && accessToken) {
      // This is a password reset - redirect to reset password page
      router.push('/reset-password')
      return
    }

    if (type === 'invite' && accessToken) {
      // This is an invite - redirect to reset password page to set initial password
      router.push('/reset-password')
      return
    }

    // For other auth callbacks (like email confirmation), verify the session
    const { data, error } = await client.auth.getSession()

    if (error) {
      errorMessage.value = error.message
      isLoading.value = false
      return
    }

    if (data.session) {
      // Successfully authenticated, redirect to home
      router.push('/')
    } else {
      // No session found, redirect to login
      router.push('/login')
    }
  } catch (err) {
    console.error('Error in confirm callback:', err)
    errorMessage.value = 'An error occurred during authentication'
    isLoading.value = false
  }
})
</script>

<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 w-full h-full"></div>

    <!-- Confirmation Card -->
    <div class="relative z-10 w-full max-w-xl px-6">
      <div class="backdrop-blur-xs bg-white/80 dark:bg-black/80 border border-white/50 dark:border-black dark:border-black-50 rounded-3xl p-8 space-y-8">

        <!-- Logo Section -->
        <div class="text-center space-y-3">
          <div class="flex justify-center mb-6">
            <EverestLogo class="w-16 h-16 text-white" />
          </div>
          <h1 class="outfit text-4xl font-light text-gray-800 dark:text-white">
            Everest<span class="font-black text-black dark:text-white bg-clip-text text-transparent">Flow</span>
          </h1>
        </div>

        <!-- Loading State -->
        <div v-if="isLoading" class="text-center py-8">
          <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p class="outfit text-gray-600 dark:text-gray-400">Verifying your request...</p>
        </div>

        <!-- Error State -->
        <div v-else-if="errorMessage" class="space-y-4">
          <div class="backdrop-blur-sm bg-red-100/80 dark:bg-red-900/30 border border-red-300 dark:border-red-700 text-red-700 dark:text-red-400 px-4 py-3 rounded-2xl text-sm">
            <div class="flex items-center gap-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {{ errorMessage }}
            </div>
          </div>
          <button
            @click="router.push('/login')"
            class="w-full py-3 px-4 outfit font-medium text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-200"
          >
            Back to Login
          </button>
        </div>
      </div>
    </div>
  </div>
</template>