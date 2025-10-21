<template>
  <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4">
    <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center gap-3">
        <!-- Back Button - Always visible -->
        <UButton
          icon="i-heroicons-arrow-left"
          color="gray"
          variant="soft"
          size="lg"
          @click="$emit('back')"
        />

        <!-- Property Assessment specific buttons -->
        <template v-if="activeTab === 'property-assessment'">
          <!-- Investment Button -->
          <button
            class="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
            @click="$emit('toggle-investment')"
          >
            <!-- Show all icons if investments are selected, otherwise show plus icon -->
            <template v-if="selectedInvestments && selectedInvestments.length > 0">
              <UIcon
                v-for="investment in selectedInvestments"
                :key="investment.id"
                :name="investment.icon"
                class="w-5 h-5 text-gray-600 dark:text-gray-400"
              />
            </template>
            <UIcon v-else name="i-lucide-plus" class="w-5 h-5" />
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Investment</span>
          </button>

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

        <!-- Consultation specific buttons -->
        <template v-if="activeTab === 'consultation'">
          <!-- Scenarios / Independent Investments Toggle -->
          <div class="flex items-center bg-gray-100 dark:bg-gray-700 rounded-lg p-1">
            <button
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium transition-colors',
                consultationViewMode === 'scenarios'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleConsultationViewModeChange('scenarios')"
            >
              Scenarios
            </button>
            <button
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium transition-colors',
                consultationViewMode === 'independent'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleConsultationViewModeChange('independent')"
            >
              Independent Investments
            </button>
          </div>

          <!-- Container 1 -->
          <div class="px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg text-sm text-gray-600 dark:text-gray-400">
            Container 1
          </div>

          <!-- Container 2 - Scenario Buttons - Only in Scenario mode -->
          <template v-if="consultationViewMode === 'scenarios'">
            <!-- Scenario buttons -->
            <template v-if="scenarios && scenarios.length > 0">
              <button
                v-for="scenario in scenarios"
                :key="scenario.id"
                class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm transition-colors"
                :class="scenario.id === activeScenarioId
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'"
                @click="emit('select-scenario', scenario.id)"
              >
                <!-- Investment icons -->
                <div class="flex -space-x-1">
                  <UIcon
                    v-for="(icon, index) in getScenarioInvestmentIcons(scenario.id)"
                    :key="index"
                    :name="icon"
                    class="w-4 h-4"
                  />
                </div>
                <span>{{ scenario.name }}</span>
              </button>
            </template>
          </template>
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

          <!-- Investment Filter Toggle -->
          <div class="flex items-center bg-gray-100 dark:bg-gray-700 rounded-lg p-1 gap-1">
            <!-- All Button -->
            <button
              :class="[
                'px-3 py-2 rounded-md text-sm font-medium transition-colors',
                activeInvestmentFilter === 'all'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleInvestmentFilterChange('all')"
            >
              All
            </button>

            <!-- Individual Investment Buttons -->
            <button
              v-for="investment in selectedInvestments"
              :key="investment.id"
              :class="[
                'px-2 py-2 rounded-md transition-colors flex items-center gap-1',
                activeInvestmentFilter === investment.id
                  ? 'bg-white dark:bg-gray-600 shadow-sm'
                  : 'hover:bg-gray-200 dark:hover:bg-gray-600'
              ]"
              @click="handleInvestmentFilterChange(investment.id)"
            >
              <UIcon
                :name="investment.icon"
                class="w-4 h-4"
                :class="activeInvestmentFilter === investment.id
                  ? 'text-gray-900 dark:text-white'
                  : 'text-gray-600 dark:text-gray-400'"
              />
            </button>
          </div>

          <!-- Hide/Show Visualization Button -->
          <UButton
            :icon="showVisualization ? 'i-heroicons-eye-slash' : 'i-heroicons-eye'"
            color="gray"
            variant="ghost"
            size="lg"
            @click="handleToggleVisualization"
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

interface Investment {
  id: string
  name: string
  icon: string
}

interface Scenario {
  id: string
  name: string
}

interface Props {
  activeTab: string
  clientName: string
  showModeToggle?: boolean
  selectedInvestments?: Investment[]
  consultationViewMode?: 'scenarios' | 'independent'
  scenarios?: Scenario[]
  activeScenarioId?: string | null
  scenarioInvestments?: Record<string, string[]>
}

const props = withDefaults(defineProps<Props>(), {
  showModeToggle: false,
  selectedInvestments: () => [],
  scenarios: () => [],
  scenarioInvestments: () => ({})
})

const emit = defineEmits<{
  back: []
  'toggle-investment': []
  'edit-client': []
  'toggle-view-mode': [mode: 'photos' | 'data' | 'all']
  'toggle-investment-filter': [investmentId: string]
  'toggle-visualization': [show: boolean]
  'toggle-consultation-view-mode': [mode: 'scenarios' | 'independent']
  'select-scenario': [scenarioId: string]
}>()

const viewModes = [
  { value: 'photos', label: 'Photos' },
  { value: 'data', label: 'Data' },
  { value: 'all', label: 'All' }
] as const

const currentViewMode = ref<'photos' | 'data' | 'all'>('all')
const activeInvestmentFilter = ref<string>('all')
const showVisualization = ref<boolean>(true)
const consultationViewMode = ref<'scenarios' | 'independent'>('scenarios')

const handleViewModeChange = (mode: 'photos' | 'data' | 'all') => {
  currentViewMode.value = mode
  emit('toggle-view-mode', mode)
}

const handleInvestmentFilterChange = (investmentId: string) => {
  activeInvestmentFilter.value = investmentId
  emit('toggle-investment-filter', investmentId)
}

const handleToggleVisualization = () => {
  showVisualization.value = !showVisualization.value
  emit('toggle-visualization', showVisualization.value)
}

const handleConsultationViewModeChange = (mode: 'scenarios' | 'independent') => {
  consultationViewMode.value = mode
  emit('toggle-consultation-view-mode', mode)
}

// Helper to get investment icons for a scenario
const getScenarioInvestmentIcons = (scenarioId: string) => {
  const investmentIds = props.scenarioInvestments[scenarioId] || []
  const iconMap: Record<string, string> = {
    'Solar Panel': 'i-lucide-sun',
    'Solar Panel + Battery': 'i-lucide-battery-charging',
    'Heat Pump': 'i-lucide-thermometer',
    'Facade Insulation': 'i-lucide-layers',
    'Roof Insulation': 'i-lucide-home',
    'Windows': 'i-lucide-layout-grid',
    'Air Conditioner': 'i-lucide-wind',
    'Battery': 'i-lucide-battery',
    'Car Charger': 'i-lucide-plug-zap'
  }

  return investmentIds
    .map(id => {
      const investment = props.selectedInvestments.find(inv => inv.id === id)
      return investment ? iconMap[investment.name] || 'i-lucide-package' : null
    })
    .filter(Boolean)
}
</script>
