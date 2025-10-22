<template>
  <div class="flex flex-col items-center justify-center py-20">
    <UIcon name="i-heroicons-wrench-screwdriver" class="w-12 h-12 text-gray-400 mb-4" />
    <p class="text-lg font-medium text-gray-500 dark:text-gray-400">
      {{ tabName }} - Under Development
    </p>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  tabName: string
}>()
</script>
