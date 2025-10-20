<template>
  <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
    <div class="px-6 py-3">
      <div class="flex items-center gap-2 overflow-x-auto">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          :class="[
            'flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors',
            modelValue === tab.id
              ? 'bg-primary-500 text-white'
              : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
          ]"
          @click="$emit('update:modelValue', tab.id)"
        >
          <!-- Tab Number -->
          <span
            :class="[
              'flex items-center justify-center w-6 h-6 rounded-full text-xs font-semibold',
              modelValue === tab.id
                ? 'bg-white/20 text-white'
                : 'bg-gray-200 dark:bg-gray-600 text-gray-700 dark:text-gray-200'
            ]"
          >
            {{ tab.number }}
          </span>

          <!-- Tab Label -->
          <span>{{ tab.label }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Tab {
  id: string
  label: string
  number: number
}

interface Props {
  modelValue: string
  tabs: Tab[]
}

defineProps<Props>()

defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>
