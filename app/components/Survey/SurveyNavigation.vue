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
              : tab.status === 'warning'
                ? 'text-orange-600 dark:text-orange-400 hover:bg-orange-50 dark:hover:bg-orange-900/20'
                : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
          ]"
          @click="$emit('update:modelValue', tab.id)"
        >
          <!-- Tab Number/Icon -->
          <span
            :class="[
              'flex items-center justify-center w-6 h-6 rounded-full text-xs font-semibold',
              modelValue === tab.id
                ? 'bg-white/20 text-white'
                : tab.status === 'completed'
                  ? 'bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300'
                  : tab.status === 'warning'
                    ? 'bg-orange-100 dark:bg-orange-900 text-orange-700 dark:text-orange-300'
                    : 'bg-gray-200 dark:bg-gray-600 text-gray-700 dark:text-gray-200'
            ]"
          >
            <UIcon v-if="tab.status === 'completed'" name="i-lucide-check" class="w-4 h-4" />
            <UIcon v-else-if="tab.status === 'warning'" name="i-lucide-alert-triangle" class="w-4 h-4" />
            <span v-else>{{ tab.number }}</span>
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
  status?: 'pending' | 'warning' | 'completed'
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
