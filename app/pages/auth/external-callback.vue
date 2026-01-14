<script setup lang="ts">
definePageMeta({
  layout: 'nomenu',
  auth: false  // Disable auth middleware
})

const client = useSupabaseClient()
const router = useRouter()
const route = useRoute()

const errorMessage = ref('')
const isProcessing = ref(true)

onMounted(async () => {
  try {
    // Get token and redirect from query params
    const token = route.query.token as string
    const redirectTo = route.query.redirect as string || '/'

    if (!token) {
      errorMessage.value = 'Missing authentication token'
      isProcessing.value = false
      return
    }

    // Verify the OTP token (magic link token from external system)
    const { data, error } = await client.auth.verifyOtp({
      token_hash: token,
      type: 'magiclink'
    })

    if (error) {
      errorMessage.value = 'Authentication failed. Please try again.'
      isProcessing.value = false
      return
    }

    if (!data.session) {
      errorMessage.value = 'Failed to create session'
      isProcessing.value = false
      return
    }

    // Success! Session is automatically set by verifyOtp
    // Redirect to the target page
    await router.push(redirectTo)
  } catch (err) {
    errorMessage.value = 'An unexpected error occurred. Please try again.'
    isProcessing.value = false
  }
})
</script>

<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden">
    <!-- Content Card -->
    <div class="relative z-10 w-full max-w-md px-6">
      <!-- Glass Card -->
      <div class="backdrop-blur-xs bg-white/80 dark:bg-black/80 border border-white/50 dark:border-black dark:border-black-50 rounded-3xl p-8 space-y-8">

        <!-- Logo Section -->
        <div class="text-center space-y-3">
          <div class="flex justify-center mb-6">
            <EverestLogo class="w-16 h-16 text-blue-600 dark:text-blue-400" />
          </div>
          <h1 class="outfit text-3xl font-light text-gray-800 dark:text-white">
            Everest<span class="font-black text-black dark:text-white">Flow</span>
          </h1>
        </div>

        <!-- Loading State -->
        <div v-if="isProcessing" class="text-center space-y-4">
          <div class="flex justify-center">
            <svg class="animate-spin h-12 w-12 text-blue-600 dark:text-blue-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
          </div>
          <p class="outfit text-gray-600 dark:text-gray-400 text-sm">
            Signing you in...
          </p>
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

          <!-- Back to login button -->
          <NuxtLink
            to="/login"
            class="outfit w-full py-3 px-4 font-medium text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-200 transform hover:-translate-y-0.5 flex items-center justify-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to Login
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>
