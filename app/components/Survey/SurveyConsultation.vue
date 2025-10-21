<template>
  <div class="h-full flex bg-gray-50 dark:bg-gray-900 relative overflow-hidden">
    <!-- System Design Column - Collapsible Left -->
    <Transition name="slide-left">
      <div
        v-if="systemDesignOpen"
        class="w-1/3 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 flex flex-col"
      >
        <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <div class="flex items-center gap-2 text-gray-900 dark:text-white font-medium">
            <UIcon name="i-lucide-ruler" class="w-5 h-5" />
            <span>System Design</span>
          </div>
          <UButton
            icon="i-lucide-chevron-left"
            color="gray"
            variant="ghost"
            size="sm"
            @click="handleSystemDesignToggle(false)"
          />
        </div>
        <div class="flex-1 overflow-auto">
          <!-- Action Buttons - Only in Scenario mode -->
          <div v-if="viewMode === 'scenarios'" class="p-4 border-b border-gray-200 dark:border-gray-700 flex gap-2">
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
          <!-- Technical Data Container -->
          <div v-if="!hasScenarios && viewMode === 'scenarios'" class="border-b border-gray-200 dark:border-gray-700">
            <div class="p-4">
              <p class="text-sm text-gray-500 dark:text-gray-400">
                No scenarios created yet. Use the buttons above to create scenarios.
              </p>
            </div>
          </div>

          <!-- Active Scenario Content -->
          <div v-if="activeScenario && viewMode === 'scenarios'" class="p-4 border-b border-gray-200 dark:border-gray-700">
            <!-- Investment Accordions -->
            <SurveyScenarioInvestments
              :survey-id="surveyId"
              :scenario-id="activeScenario.id"
            />
          </div>

          <!-- Accordions -->
          <div class="p-4 space-y-3 mt-auto">
            <!-- Subsidy Accordion -->
            <UAccordion
              :items="[{
                label: 'Subsidy',
                icon: 'i-lucide-banknote',
                slot: 'subsidy'
              }]"
            >
              <template #subsidy>
                <div class="p-3">
                  <!-- Empty for now -->
                </div>
              </template>
            </UAccordion>

            <!-- Household Data Accordion -->
            <UAccordion
              :items="[{
                label: 'Household Data',
                icon: 'i-lucide-info',
                slot: 'household-data'
              }]"
            >
              <template #household-data>
                <div class="p-3">
                  <!-- Empty for now -->
                </div>
              </template>
            </UAccordion>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Reopen System Design Button - Left Edge -->
    <button
      v-if="!systemDesignOpen"
      class="absolute left-0 top-1/2 -translate-y-1/2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-r-lg p-2 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors z-10"
      @click="handleSystemDesignToggle(true)"
    >
      <UIcon name="i-lucide-chevron-right" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
    </button>

    <!-- System Visualization Column - Center -->
    <div :class="[
      'bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 flex flex-col transition-all',
      systemDesignOpen && consultationOpen ? 'w-1/3' :
      !systemDesignOpen && !consultationOpen ? 'w-full' :
      'w-2/3'
    ]">
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-2 text-gray-900 dark:text-white font-medium">
          <UIcon name="i-lucide-home" class="w-5 h-5" />
          <span>System Visualization</span>
        </div>
      </div>
      <div class="flex-1 p-4 flex items-center justify-center overflow-auto">
        <div class="w-full h-full flex items-center justify-center">
          <img
            src="/images/houseVisualization.png"
            alt="House Visualization"
            class="max-w-2xl max-h-full object-contain"
          />
        </div>
      </div>
    </div>

    <!-- Consultation Column - Collapsible Right -->
    <Transition name="slide-right">
      <div
        v-if="consultationOpen"
        class="w-1/3 bg-white dark:bg-gray-800 flex flex-col"
      >
        <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <div class="flex items-center gap-2 text-gray-900 dark:text-white font-medium">
            <UIcon name="i-lucide-message-circle" class="w-5 h-5" />
            <span>Consultation</span>
          </div>
          <UButton
            icon="i-lucide-chevron-right"
            color="gray"
            variant="ghost"
            size="sm"
            @click="handleConsultationToggle(false)"
          />
        </div>
        <div class="flex-1 p-4 overflow-auto">
          <!-- Empty for now -->
        </div>
      </div>
    </Transition>

    <!-- Reopen Consultation Button - Right Edge -->
    <button
      v-if="!consultationOpen"
      class="absolute right-0 top-1/2 -translate-y-1/2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-l-lg p-2 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors z-10"
      @click="handleConsultationToggle(true)"
    >
      <UIcon name="i-lucide-chevron-left" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
    </button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed, ref } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'

interface Props {
  surveyId: string
  systemDesignOpen: boolean
  consultationOpen: boolean
  viewMode: 'scenarios' | 'independent'
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:system-design-open': [value: boolean]
  'update:consultation-open': [value: boolean]
  'ai-scenarios': []
  'new-scenario': []
}>()

const scenariosStore = useScenariosStore()

// Accordion states
const subsidyOpen = ref([0])
const householdDataOpen = ref([0])

// Computed
const activeScenario = computed(() => scenariosStore.activeScenario)
const hasScenarios = computed(() => scenariosStore.scenarios.length > 0)

// Load scenarios on mount
onMounted(async () => {
  if (props.viewMode === 'scenarios') {
    await scenariosStore.loadScenarios(props.surveyId)
  }
})

// Methods
const handleSystemDesignToggle = (isOpen: boolean) => {
  emit('update:system-design-open', isOpen)
}

const handleConsultationToggle = (isOpen: boolean) => {
  emit('update:consultation-open', isOpen)
}
</script>

<style scoped>
/* Slide transitions for collapsible columns */
.slide-left-enter-active,
.slide-left-leave-active {
  transition: all 0.3s ease;
}

.slide-left-enter-from {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-left-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-right-enter-active,
.slide-right-leave-active {
  transition: all 0.3s ease;
}

.slide-right-enter-from {
  transform: translateX(100%);
  opacity: 0;
}

.slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>
