<!-- pages/reset-password.vue -->
<script setup lang="ts">
definePageMeta({
  layout: 'login'
})

const client = useSupabaseClient()
const router = useRouter()
const password = ref('')
const confirmPassword = ref('')
const errorMessage = ref('')
const successMessage = ref('')
const isLoading = ref(false)

async function handlePasswordReset() {
  errorMessage.value = ''
  successMessage.value = ''

  // Validation
  if (!password.value || !confirmPassword.value) {
    errorMessage.value = 'Please enter both password fields'
    return
  }

  if (password.value.length < 6) {
    errorMessage.value = 'Password must be at least 6 characters long'
    return
  }

  if (password.value !== confirmPassword.value) {
    errorMessage.value = 'Passwords do not match'
    return
  }

  isLoading.value = true

  try {
    const { data, error } = await client.auth.updateUser({
      password: password.value
    })

    if (error) {
      errorMessage.value = error.message
      return
    }

    successMessage.value = 'Password updated successfully! Redirecting...'

    // Wait a moment to show success message, then redirect
    setTimeout(() => {
      router.push('/')
    }, 2000)
  } catch (err) {
    errorMessage.value = 'An error occurred while updating password'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden">
    <!-- Background -->
    <div class="absolute inset-0 w-full h-full"></div>

    <!-- Reset Password Card -->
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
          <p class="outfit text-gray-600 dark:text-gray-400 text-sm">Set your new password</p>
        </div>

        <!-- Success Message -->
        <Transition name="slide-down">
          <div v-if="successMessage" class="backdrop-blur-sm bg-green-100/80 dark:bg-green-900/30 border border-green-300 dark:border-green-700 text-green-700 dark:text-green-400 px-4 py-3 rounded-2xl text-sm">
            <div class="flex items-center gap-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {{ successMessage }}
            </div>
          </div>
        </Transition>

        <!-- Error Message -->
        <Transition name="slide-down">
          <div v-if="errorMessage" class="backdrop-blur-sm bg-red-100/80 dark:bg-red-900/30 border border-red-300 dark:border-red-700 text-red-700 dark:text-red-400 px-4 py-3 rounded-2xl text-sm">
            <div class="flex items-center gap-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {{ errorMessage }}
            </div>
          </div>
        </Transition>

        <!-- Password Reset Form -->
        <form @submit.prevent="handlePasswordReset" class="space-y-6">
          <!-- New Password Input -->
          <div class="space-y-2">
            <label for="password" class="outfit block text-sm font-medium text-gray-700 dark:text-gray-300 pl-1">
              New Password
            </label>
            <div class="relative group">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg class="w-5 h-5 text-gray-400 dark:text-gray-500 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <input
                id="password"
                v-model="password"
                type="password"
                required
                class="outfit w-full pl-12 pr-4 py-3 bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-600 rounded-2xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="Enter new password"
              />
            </div>
          </div>

          <!-- Confirm Password Input -->
          <div class="space-y-2">
            <label for="confirm-password" class="outfit block text-sm font-medium text-gray-700 dark:text-gray-300 pl-1">
              Confirm Password
            </label>
            <div class="relative group">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg class="w-5 h-5 text-gray-400 dark:text-gray-500 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <input
                id="confirm-password"
                v-model="confirmPassword"
                type="password"
                required
                class="outfit w-full pl-12 pr-4 py-3 bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-600 rounded-2xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="Confirm new password"
              />
            </div>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="isLoading || !!successMessage"
            class="relative w-full py-3 px-4 outfit font-medium text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed transform hover:-translate-y-0.5 overflow-hidden group"
          >
            <!-- Button shine effect -->
            <div class="absolute inset-0 w-full h-full bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-20 transform -skew-x-12 group-hover:translate-x-full transition-all duration-700"></div>

            <span v-if="!isLoading" class="flex items-center justify-center gap-2">
              Update Password
              <svg class="w-5 h-5 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </span>
            <span v-else class="flex items-center justify-center gap-2">
              <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Updating...
            </span>
          </button>

          <!-- Back to Login Link -->
          <div class="text-center">
            <button
              type="button"
              @click="router.push('/login')"
              class="outfit text-sm text-gray-600 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
            >
              Back to Login
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
