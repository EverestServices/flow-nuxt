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
  <!-- Keep your existing template, but you might want to conditionally render based on isClient -->
  <div class="flex min-h-screen items-center justify-center">
    <div class="w-full max-w-md p-8 space-y-8 bg-white rounded-lg shadow">
      <!-- Login form content -->

        <div class="text-center">
          <h1 class="text-2xl font-black">Everest:Flow</h1>
          <p class="mt-2 text-gray-600">Sign in to your account</p>
        </div>

        <form @submit.prevent="handleLogin" class="mt-8 space-y-6">
          <div v-if="errorMessage" class="bg-red-100 text-red-700 p-3 rounded">
            {{ errorMessage }}
          </div>

          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
            <input
                id="email"
                v-model="email"
                type="email"
                required
                class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm"
            />
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
            <input
                id="password"
                v-model="password"
                type="password"
                required
                class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm"
            />
          </div>

          <button
              type="submit"
              :disabled="isLoading"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none"
          >
            {{ isLoading ? 'Signing in...' : 'Sign in' }}
          </button>
        </form>

    </div>
  </div>
</template>