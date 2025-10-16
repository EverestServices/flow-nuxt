<!-- components/AuthProvider.vue -->
<script setup>
const user = useSupabaseUser()
const client = useSupabaseClient()
const authChecked = ref(false)
const isClient = ref(false)

// Only run on client-side
onMounted(async () => {
  isClient.value = true
  try {
    await client.auth.getSession()
  } catch (error) {
    console.error('Error checking auth:', error)
  } finally {
    authChecked.value = true
  }
})
</script>

<template>
  <div>
    <div v-if="!isClient || !authChecked" class="fixed inset-0 bg-white flex items-center justify-center">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500 mx-auto"></div>
        <p class="mt-4 text-gray-600">Loading...</p>
      </div>
    </div>
    <slot v-else />
  </div>
</template>