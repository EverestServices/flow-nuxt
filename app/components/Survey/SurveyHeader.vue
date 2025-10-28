<template>
  <div class="bg-white/20 dark:bg-black/20 border py-1 border-white dark:border-black/10 rounded-full fixed top-3 left-3 backdrop-blur-xs flex h-12 z-30 pr-3 pl-2">
    <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center border-r mr-0 pr-4 border-white dark:border-white/20 h-9">
        <!-- Back Button - Always visible -->
        <UButton
          icon="i-heroicons-arrow-left"
          color="gray"
          variant="soft"
          size="lg"
          @click="$emit('back')"
        />

        <!-- Property Assessment specific buttons -->
        <template v-if="activeTab === 'property-assessment'" >
          <!-- Investment Button -->
          <button
            class="inline-flex items-center gap-2 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors border-l border-white pl-4 pr-4 h-8"
            @click="$emit('toggle-investment')"
          >
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Investments</span>

            <!-- Show all icons if investments are selected, otherwise show plus icon -->
            <!--
            <template v-if="selectedInvestments && selectedInvestments.length > 0">
              <UIcon
                v-for="investment in selectedInvestments"
                :key="investment.id"
                :name="investment.icon"
                class="w-5 h-5 text-gray-600 dark:text-gray-400"
              />
            </template>-->
          </button>

          <!-- Edit Client Button -->
          <!--
          <UButton
            icon="i-heroicons-user"
            label="Edit Client Data"
            color="gray"
            variant="outline"
            size="md"
            @click="$emit('edit-client')"
          />-->
        </template>

        <!-- Investment Filter Toggle -->
        <div class="flex items-center rounded-full gap-1">
          <!-- Individual Investment Buttons -->
          <button
              v-for="investment in selectedInvestments"
              :key="investment.id"
              :class="[
                'px-2 py-2 rounded-full transition-colors flex items-center gap-1 cursor-pointer',
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
          <!-- All Button -->
          <button
              :class="[
                'px-3 py-1 rounded-md text-sm font-medium transition-colors',
                activeInvestmentFilter === 'all'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleInvestmentFilterChange('all')"
          >
            All
          </button>
        </div>

        <!-- Consultation specific buttons -->
        <template v-if="activeTab === 'consultation'">
          <!-- Scenario buttons - Scrollable container -->
          <div v-if="scenarios && scenarios.length > 0" class="flex gap-2 overflow-x-auto flex-1 scrollbar-hide">
            <button
              v-for="scenario in scenarios"
              :key="scenario.id"
              class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm transition-colors whitespace-nowrap flex-shrink-0"
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
          </div>
        </template>

        <!-- Offer/Contract Toggle - Only on offer-contract and contract-data tabs -->
        <template v-if="activeTab === 'offer-contract' || activeTab === 'contract-data'">
          <div class="flex items-center bg-gray-100 dark:bg-gray-700 rounded-lg p-1">
            <button
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium transition-colors',
                contractMode === 'offer'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleContractModeChange('offer')"
            >
              Offer
            </button>
            <button
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium transition-colors',
                contractMode === 'contract'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleContractModeChange('contract')"
            >
              Contract
            </button>
          </div>

          <!-- Contract Selector Buttons - Only on offer-contract tab -->
          <div v-if="activeTab === 'offer-contract' && contracts && contracts.length > 0" class="flex gap-2 overflow-x-auto flex-1 scrollbar-hide">
            <button
              v-for="contract in sortedContracts"
              :key="contract.id"
              class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm transition-colors whitespace-nowrap flex-shrink-0"
              :class="contract.id === activeContractId
                ? 'bg-primary-600 text-white'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'"
              @click="emit('select-contract', contract.id)"
            >
              <!-- Investment icons -->
              <div class="flex gap-0.5">
                <UIcon
                  v-for="(icon, index) in getContractInvestmentIcons(contract.id)"
                  :key="index"
                  :name="icon"
                  class="w-4 h-4"
                />
              </div>
              <span>{{ contract.name }}</span>
            </button>
          </div>
        </template>
      </div>

      <!-- Right Section -->
      <div class="flex items-center gap-4">
        <!-- Property Assessment specific controls -->
        <template v-if="showModeToggle">
          <!-- View Mode Toggle -->
          <div class="flex items-center p-1 border-r border-white/20 pr-3 h-9">
            <button
              v-for="mode in viewModes"
              :key="mode.value"
              :class="[
                'px-4 py-2 rounded-full text-sm font-medium transition-colors',
                currentViewMode === mode.value
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow-sm'
                  : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
              ]"
              @click="handleViewModeChange(mode.value)"
            >
              {{ mode.label }}
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
import { ref, computed } from 'vue'

interface Investment {
  id: string
  name: string
  icon: string
}

interface Scenario {
  id: string
  name: string
}

interface Contract {
  id: string
  name: string
  created_at: string
}

interface Props {
  activeTab: string
  clientName: string
  showModeToggle?: boolean
  selectedInvestments?: Investment[]
  scenarios?: Scenario[]
  activeScenarioId?: string | null
  scenarioInvestments?: Record<string, string[]>
  contractMode?: 'offer' | 'contract' | null
  contracts?: Contract[]
  activeContractId?: string | null
  contractInvestments?: Record<string, string[]>
}

const props = withDefaults(defineProps<Props>(), {
  showModeToggle: false,
  selectedInvestments: () => [],
  scenarios: () => [],
  scenarioInvestments: () => ({}),
  contractMode: null,
  contracts: () => [],
  contractInvestments: () => ({})
})

const emit = defineEmits<{
  back: []
  'toggle-investment': []
  'edit-client': []
  'toggle-view-mode': [mode: 'photos' | 'data' | 'all']
  'toggle-investment-filter': [investmentId: string]
  'toggle-visualization': [show: boolean]
  'select-scenario': [scenarioId: string]
  'change-contract-mode': [mode: 'offer' | 'contract' | null]
  'select-contract': [contractId: string]
}>()

const viewModes = [
  { value: 'photos', label: 'Photos' },
  { value: 'data', label: 'Data' },
  { value: 'all', label: 'All' }
] as const

const currentViewMode = ref<'photos' | 'data' | 'all'>('all')
const activeInvestmentFilter = ref<string>('all')
const showVisualization = ref<boolean>(true)

// Sort contracts by created_at (earliest first)
const sortedContracts = computed(() => {
  return [...props.contracts].sort((a, b) => {
    return new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  })
})

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

const handleContractModeChange = (mode: 'offer' | 'contract') => {
  emit('change-contract-mode', mode)
}

// Helper to get investment icons for a scenario
const getScenarioInvestmentIcons = (scenarioId: string) => {
  const investmentIds = props.scenarioInvestments[scenarioId] || []

  return investmentIds
    .map(id => {
      const investment = props.selectedInvestments.find(inv => inv.id === id)
      return investment ? investment.icon : null
    })
    .filter(Boolean)
}

// Helper to get investment icons for a contract
const getContractInvestmentIcons = (contractId: string) => {
  const investmentIds = props.contractInvestments[contractId] || []

  return investmentIds
    .map(id => {
      const investment = props.selectedInvestments.find(inv => inv.id === id)
      return investment ? investment.icon : null
    })
    .filter(Boolean)
}
</script>
