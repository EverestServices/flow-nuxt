<template>
  <div class="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
    <div class="flex items-start justify-between px-6 py-4">
      <!-- Left Section -->
      <div class="flex-1">
        <button
          @click="$emit('back')"
          class="flex items-center gap-2 mb-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 transition-colors"
        >
          <UIcon name="i-heroicons-arrow-left" class="w-5 h-5" />
          <span class="text-sm font-medium">Back</span>
        </button>

        <div class="mt-1">
          <h1 class="text-2xl font-semibold text-gray-900 dark:text-white">
            {{ clientName }}
          </h1>
          <p v-if="companyName" class="text-base text-gray-500 dark:text-gray-400 mt-1">
            {{ companyName }}
          </p>
        </div>
      </div>

      <!-- Right Section - Edit Button -->
      <UButton
        icon="i-heroicons-pencil-square"
        label="Edit"
        color="primary"
        variant="soft"
        size="sm"
        @click="$emit('edit')"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  clientName: string
  companyName?: string
}>()

defineEmits<{
  back: []
  edit: []
}>()
</script>
