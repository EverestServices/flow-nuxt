<template>
  <div class="h-full flex items-center justify-center bg-gray-50 dark:bg-gray-900">
    <div class="text-center">
      <UIcon name="i-heroicons-home" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
        Property Assessment
      </h2>
      <p class="text-gray-500 dark:text-gray-400">
        Content under development
      </p>
      <p class="text-sm text-gray-400 dark:text-gray-500 mt-2">
        Survey ID: {{ surveyId }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  surveyId: string
}

defineProps<Props>()
</script>
