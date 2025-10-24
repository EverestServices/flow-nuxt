<template>
  <div class="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-6 py-4">
    <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center gap-3 flex-1">
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

        <!-- Consultation specific actions -->
        <template v-if="activeTab === 'consultation'">
          <!-- Mentés Button -->
          <UButton
            label="Mentés"
            color="gray"
            variant="outline"
            @click="$emit('consultation-save')"
          />

          <!-- Eye Icon Button - Toggle scenario buttons visibility -->
          <UButton
            :icon="showScenarioButtons ? 'i-lucide-eye' : 'i-lucide-eye-off'"
            color="gray"
            variant="outline"
            @click="showScenarioButtons = !showScenarioButtons"
          />
        </template>
      </div>

      <!-- Center Section - AI Scenarios and New Scenario buttons -->
      <div v-if="activeTab === 'consultation' && showScenarioButtons" class="flex items-center gap-2">
        <!-- AI Scenarios button -->
        <UButton
          color="primary"
          size="sm"
          @click="$emit('ai-scenarios')"
        >
          <template #leading>
            <UIcon name="i-lucide-zap" class="w-4 h-4" />
          </template>
          AI Scenarios
        </UButton>

        <!-- New Scenario button -->
        <UButton
          color="primary"
          variant="outline"
          size="sm"
          @click="$emit('new-scenario')"
        >
          <template #leading>
            <UIcon name="i-lucide-plus" class="w-4 h-4" />
          </template>
          New Scenario
        </UButton>
      </div>

      <!-- Right Section -->
      <div class="flex items-center gap-3 flex-1 justify-end">
        <!-- Offer/Contract specific actions - Only on offer-contract tab -->
        <template v-if="activeTab === 'offer-contract'">
          <!-- Save Investment Contract Button -->
          <UButton
            v-if="canSaveContract"
            label="Save Investment Contract"
            icon="i-lucide-save"
            color="primary"
            variant="outline"
            size="md"
            @click="$emit('save-investment-contract')"
          />

          <!-- Modify Contract Button -->
          <UButton
            v-if="activeContract"
            :label="`Modify ${activeContract.name}`"
            icon="i-lucide-pencil"
            color="gray"
            variant="outline"
            size="md"
            @click="$emit('modify-contract')"
          />
        </template>

        <!-- Property Assessment specific controls -->
        <template v-if="showPropertyActions">
          <!-- Marker Mode Toggle -->
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600 dark:text-gray-300">Marker Mode</span>
            <USwitch
              v-model="markerModeEnabled"
              @update:model-value="$emit('toggle-marker-mode', $event)"
            />
          </div>

          <!-- Missing Items Warning -->
          <UButton
            :label="`Missing Items (${missingItemsCount})`"
            :icon="missingItemsCount > 0 ? 'i-heroicons-exclamation-triangle' : undefined"
            color="orange"
            variant="outline"
            size="md"
            @click="$emit('show-missing-items')"
          />
        </template>

        <!-- Consultation specific Container 3 -->
        <template v-if="activeTab === 'consultation' && activeScenario && showScenarioButtons">
          <div class="flex items-center gap-3 px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ activeScenario.name }}
            </span>
            <div class="flex items-center gap-2">
              <UButton
                size="xs"
                color="gray"
                variant="outline"
                @click="$emit('rename-scenario')"
              >
                Rename
              </UButton>
              <UButton
                size="xs"
                color="gray"
                variant="outline"
                @click="$emit('duplicate-scenario')"
              >
                Duplicate
              </UButton>
              <UButton
                size="xs"
                color="red"
                variant="outline"
                @click="$emit('delete-scenario')"
              >
                Delete
              </UButton>
            </div>
          </div>
        </template>

        <!-- Offer/Contract specific Container - Contract Management - Only on offer-contract tab -->
        <template v-if="activeTab === 'offer-contract' && activeContract">
          <div class="flex items-center gap-3 px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ activeContract.name }}
            </span>
            <div class="flex items-center gap-2">
              <UButton
                size="xs"
                color="gray"
                variant="outline"
                @click="$emit('rename-contract')"
              >
                Rename
              </UButton>
              <UButton
                size="xs"
                color="gray"
                variant="outline"
                @click="$emit('duplicate-contract')"
              >
                Duplicate
              </UButton>
              <UButton
                size="xs"
                color="red"
                variant="outline"
                @click="$emit('delete-contract')"
              >
                Delete
              </UButton>
            </div>
          </div>
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

interface Scenario {
  id: string
  name: string
}

interface Contract {
  id: string
  name: string
}

interface Props {
  activeTab: string
  showPropertyActions?: boolean
  missingItemsCount?: number
  canProceed?: boolean
  activeScenario?: Scenario | null
  activeContract?: Contract | null
  canSaveContract?: boolean
}

withDefaults(defineProps<Props>(), {
  showPropertyActions: false,
  missingItemsCount: 0,
  canProceed: true,
  canSaveContract: false
})

defineEmits<{
  'save-exit': []
  'upload-photos': []
  'fill-all-data': []
  'generate-assessment': []
  'toggle-marker-mode': [enabled: boolean]
  'show-missing-items': []
  'consultation-save': []
  'consultation-preview': []
  'ai-scenarios': []
  'new-scenario': []
  'rename-scenario': []
  'duplicate-scenario': []
  'delete-scenario': []
  'rename-contract': []
  'duplicate-contract': []
  'delete-contract': []
  'save-investment-contract': []
  'modify-contract': []
  next: []
}>()

const markerModeEnabled = ref(false)
const showScenarioButtons = ref(true)
</script>
