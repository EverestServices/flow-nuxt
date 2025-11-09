<template>
  <ClientOnly>
    <div class="relative w-full h-full bg-gray-100 dark:bg-gray-900 rounded-lg overflow-hidden">
    <!-- Loading state -->
    <div
      v-if="isLoading"
      class="absolute inset-0 flex items-center justify-center bg-gray-100 dark:bg-gray-900"
    >
      <div class="text-center">
        <UIcon
          name="i-lucide-loader-2"
          class="w-12 h-12 text-primary-600 dark:text-primary-400 animate-spin mb-4"
        />
        <p class="text-sm text-gray-600 dark:text-gray-400">
          PDF előnézet generálása...
        </p>
      </div>
    </div>

    <!-- Error state -->
    <div
      v-else-if="error"
      class="absolute inset-0 flex items-center justify-center bg-gray-100 dark:bg-gray-900"
    >
      <div class="text-center max-w-md px-4">
        <UIcon
          name="i-lucide-alert-circle"
          class="w-12 h-12 text-red-600 dark:text-red-400 mb-4 mx-auto"
        />
        <p class="text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
          Hiba történt a PDF generálása során
        </p>
        <p class="text-xs text-gray-600 dark:text-gray-400">
          {{ error }}
        </p>
      </div>
    </div>

    <!-- PDF Preview -->
    <iframe
      v-else-if="pdfUrl"
      :src="pdfUrl"
      class="w-full h-full border-0"
      title="PDF Preview"
    />
    </div>
  </ClientOnly>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const { generatePDFBlob } = useSurveyReport()

const isLoading = ref(true)
const error = ref<string | null>(null)
const pdfUrl = ref<string | null>(null)

onMounted(async () => {
  try {
    isLoading.value = true
    error.value = null

    // Generate PDF blob
    const blob = await generatePDFBlob()

    // Create object URL for the blob
    pdfUrl.value = URL.createObjectURL(blob)

    isLoading.value = false
  } catch (err) {
    console.error('Error generating PDF preview:', err)
    error.value = err instanceof Error ? err.message : 'Ismeretlen hiba'
    isLoading.value = false
  }
})

onUnmounted(() => {
  // Clean up object URL
  if (pdfUrl.value) {
    URL.revokeObjectURL(pdfUrl.value)
  }
})
</script>
