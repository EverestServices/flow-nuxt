<template>
  <div class="px-2 py-1 border border-white dark:border-black/20 rounded-full backdrop-blur-xs bg-white/20 dark:bg-black/20 flex fixed right-24 top-3 h-12 z-[100] pointer-events-auto">
    <div class="flex items-center gap-1 overflow-x-auto">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        type="button"
        :class="[
          'flex items-center gap-2 px-2 py-2 rounded-full text-xs font-medium whitespace-nowrap transition-colors relative',
          tab.disabled
            ? 'opacity-50 cursor-not-allowed text-gray-400 dark:text-gray-500 pointer-events-none'
            : 'cursor-pointer pointer-events-auto',
          !tab.disabled && modelValue === tab.id
            ? 'bg-primary-500 text-white'
            : !tab.disabled && tab.status === 'warning'
              ? 'text-orange-600 dark:text-orange-400 hover:bg-orange-50 dark:hover:bg-orange-900/20'
              : !tab.disabled
                ? 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                : ''
        ]"
        @click.stop="handleTabClick(tab)"
      >
        <!-- Tab Number/Icon -->
        <span
          :class="[
            'flex items-center justify-center w-4 h-4 rounded-full text-xs font-semibold',
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

        <!-- Tab Label - csak az aktív tab-nál -->
        <span v-if="modelValue === tab.id">{{ tab.label }}</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Tab {
  id: string
  label: string
  number: number
  status?: 'pending' | 'warning' | 'completed'
  disabled?: boolean
}

interface Props {
  modelValue: string
  tabs: Tab[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const handleTabClick = (tab: Tab) => {
  // Ha a tab nincs letiltva, akkor váltunk rá
  if (!tab.disabled) {
    emit('update:modelValue', tab.id)
  }
}
</script>
