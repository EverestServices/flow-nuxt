<template>
  <div class="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-6 py-4">
    <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center gap-3">
        <!-- Save and Exit - Always visible -->
        <UButton
          label="Save and Exit"
          color="gray"
          variant="outline"
          size="lg"
          @click="$emit('save-exit')"
        />

        <!-- Property Assessment specific actions -->
        <template v-if="showPropertyActions">
          <!-- Upload All Photos -->
          <UButton
            label="Upload All Photos"
            color="primary"
            variant="outline"
            size="md"
            @click="$emit('upload-photos')"
          />

          <!-- Fill All Data -->
          <UButton
            label="Fill All Data"
            color="primary"
            variant="outline"
            size="md"
            @click="$emit('fill-all-data')"
          />

          <!-- Generate Assessment Sheet -->
          <UButton
            label="Generate Assessment Sheet"
            color="primary"
            variant="outline"
            size="md"
            @click="$emit('generate-assessment')"
          />
        </template>
      </div>

      <!-- Right Section -->
      <div class="flex items-center gap-3">
        <!-- Property Assessment specific controls -->
        <template v-if="showPropertyActions">
          <!-- Marker Mode Toggle -->
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600 dark:text-gray-300">Marker Mode</span>
            <UToggle
              v-model="markerModeEnabled"
              @update:model-value="$emit('toggle-marker-mode', $event)"
            />
          </div>

          <!-- Missing Items Warning -->
          <UButton
            :label="`Missing Items (${missingItemsCount})`"
            icon="i-heroicons-exclamation-triangle"
            color="orange"
            variant="outline"
            size="md"
            @click="$emit('show-missing-items')"
          />
        </template>

        <!-- Next Button - Always visible -->
        <UButton
          label="Next"
          icon="i-heroicons-arrow-right"
          trailing
          color="primary"
          size="lg"
          :disabled="!canProceed"
          @click="$emit('next')"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Props {
  activeTab: string
  showPropertyActions?: boolean
  missingItemsCount?: number
  canProceed?: boolean
}

withDefaults(defineProps<Props>(), {
  showPropertyActions: false,
  missingItemsCount: 0,
  canProceed: true
})

defineEmits<{
  'save-exit': []
  'upload-photos': []
  'fill-all-data': []
  'generate-assessment': []
  'toggle-marker-mode': [enabled: boolean]
  'show-missing-items': []
  next: []
}>()

const markerModeEnabled = ref(false)
</script>
