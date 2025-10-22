<template>
  <div class="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
    <div class="flex gap-2 px-6 py-3 overflow-x-auto">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors',
          modelValue === tab.key
            ? 'bg-primary-500 text-white'
            : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
        ]"
        @click="$emit('update:modelValue', tab.key)"
      >
        {{ tab.label }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string
}>()

defineEmits<{
  'update:modelValue': [value: string]
}>()

const tabs = [
  { key: 'basicInfo', label: 'Basic Info' },
  { key: 'surveys', label: 'Surveys' },
  { key: 'contracts', label: 'Contracts' },
  { key: 'projects', label: 'Projects' },
  { key: 'events', label: 'Events' },
  { key: 'emails', label: 'Emails' },
  { key: 'logs', label: 'Logs' }
]
</script>
