<template>
  <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4">
    <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center gap-3">
        <!-- Back Button - Always visible -->
        <UButton
          icon="i-heroicons-arrow-left"
          color="gray"
          variant="ghost"
          size="lg"
          @click="$emit('back')"
        />

        <!-- Property Assessment specific buttons -->
        <template v-if="activeTab === 'property-assessment'">
          <!-- Investment Button -->
          <UButton
            icon="i-heroicons-plus"
            label="Investment"
            color="gray"
            variant="outline"
            size="md"
            @click="$emit('toggle-investment')"
          />

          <!-- Edit Client Button -->
          <UButton
            icon="i-heroicons-user"
            label="Edit Client Data"
            color="gray"
            variant="outline"
            size="md"
            @click="$emit('edit-client')"
          />
        </template>
      </div>

      <!-- Right Section -->
      <div class="flex items-center gap-4">
        <!-- Property Assessment specific controls -->
        <template v-if="showModeToggle">
          <!-- View Mode Toggle -->
          <div class="flex items-center bg-gray-100 dark:bg-gray-700 rounded-lg p-1">
            <button
              v-for="mode in viewModes"
              :key="mode.value"
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium transition-colors',
                currentViewMode === mode.value
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleViewModeChange(mode.value)"
            >
              {{ mode.label }}
            </button>
          </div>

          <!-- Container placeholder -->
          <div class="px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
            <span class="text-sm text-gray-600 dark:text-gray-300">Container</span>
          </div>

          <!-- Hide/Show Button -->
          <UButton
            icon="i-heroicons-eye-slash"
            color="gray"
            variant="ghost"
            size="lg"
            @click="$emit('toggle-hidden')"
          />
        </template>

        <!-- Client Name - Always visible -->
        <div class="text-right">
          <p class="text-sm font-semibold text-gray-900 dark:text-white">
            {{ clientName }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Props {
  activeTab: string
  clientName: string
  showModeToggle?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showModeToggle: false
})

const emit = defineEmits<{
  back: []
  'toggle-investment': []
  'edit-client': []
  'toggle-view-mode': [mode: 'photos' | 'data' | 'all']
  'toggle-hidden': []
}>()

const viewModes = [
  { value: 'photos', label: 'Photos' },
  { value: 'data', label: 'Data' },
  { value: 'all', label: 'All' }
] as const

const currentViewMode = ref<'photos' | 'data' | 'all'>('all')

const handleViewModeChange = (mode: 'photos' | 'data' | 'all') => {
  currentViewMode.value = mode
  emit('toggle-view-mode', mode)
}
</script>
