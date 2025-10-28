<!-- pages/login.vue -->
<script setup lang="ts">

definePageMeta({
  layout: 'login'
})
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const email = ref('')
const password = ref('')
const errorMessage = ref('')
const isLoading = ref(false)
const isClient = ref(false)

// Set isClient to true once mounted to avoid hydration mismatch
onMounted(() => {
  isClient.value = true
  // Check if user is already logged in
  if (user.value) {
    router.push('/')
  }
})

async function handleLogin() {
  if (!email.value || !password.value) {
    errorMessage.value = 'Please enter both email and password'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    const { data, error } = await client.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })

    if (error) {
      errorMessage.value = error.message
      return
    }

    if (data.session) {
      // Redirect to home page after successful login
      router.push('/')
    }
  } catch (err) {
    errorMessage.value = 'An error occurred during login'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden">
    <!-- Background Video -->
    <div class="absolute inset-0 w-full h-full">

      <!-- Video overlay for better text readability -->
    </div>

    <!-- Login Card -->
    <div class="relative z-10 w-full max-w-xl px-6">
      <!-- Glass Card -->
      <div class="backdrop-blur-xs bg-white/80 dark:bg-black/80 border border-white/50 dark:border-black dark:border-black-50 rounded-3xl p-8 space-y-8 transform transition-all duration-500 hover:scale-[1.02]">

        <!-- Logo Section -->
        <div class="text-center space-y-3">
          <div class="flex justify-center mb-6">
              <EverestLogo class="w-16 h-16 text-white" />
          </div>
          <h1 class="outfit text-4xl font-light text-gray-800 dark:text-white">
            Everest<span class="font-black text-black dark:text-white bg-clip-text text-transparent">Flow</span>
          </h1>
          <p class="outfit text-gray-600 dark:text-gray-400 text-sm">Sign in to continue your journey</p>
        </div>

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

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="space-y-6">
          <!-- Email Input -->
          <div class="space-y-2">
            <label for="email" class="outfit block text-sm font-medium text-gray-700 dark:text-gray-300 pl-1">
              Email Address
            </label>
            <div class="relative group">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg class="w-5 h-5 text-gray-400 dark:text-gray-500 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                </svg>
              </div>
              <input
                id="email"
                v-model="email"
                type="email"
                required
                class="outfit w-full pl-12 pr-4 py-3 bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-600 rounded-2xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="you@example.com"
              />
            </div>
          </div>

          <!-- Password Input -->
          <div class="space-y-2">
            <label for="password" class="outfit block text-sm font-medium text-gray-700 dark:text-gray-300 pl-1">
              Password
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
                placeholder="Enter your password"
              />
            </div>
          </div>

          <!-- Remember Me -->
          <div class="flex items-center">
            <input
              id="remember"
              type="checkbox"
              class="w-4 h-4 text-blue-600 bg-white/50 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            />
            <label for="remember" class="ml-2 outfit block text-sm text-gray-700 dark:text-gray-300">
              Remember me
            </label>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="isLoading"
            class="relative w-full py-3 px-4 outfit font-medium text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed transform hover:-translate-y-0.5 overflow-hidden group"
          >
            <!-- Button shine effect -->
            <div class="absolute inset-0 w-full h-full bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-20 transform -skew-x-12 group-hover:translate-x-full transition-all duration-700"></div>

            <span v-if="!isLoading" class="flex items-center justify-center gap-2">
              Sign in
              <svg class="w-5 h-5 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </span>
            <span v-else class="flex items-center justify-center gap-2">
              <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Signing in...
            </span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>