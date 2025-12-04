<template>
  <div class="space-y-4">
    <div v-if="loading" class="flex items-center justify-center py-8">
      <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
    </div>

    <div v-else class="space-y-6">
      <!-- Investment Switches (Only shown in Consultant Mode) -->
      <div v-if="isConsultantModeActive" class="space-y-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          {{ $t('survey.consultationData.selectInvestments') }}
        </h4>

        <!-- Homlokzati szigetelés -->
        <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-home" class="w-4 h-4 text-gray-600 dark:text-gray-400" />
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              Homlokzati szigetelés
            </span>
          </div>
          <USwitch v-model="facadeInsulationSwitch" />
        </div>

        <!-- Padlásfödém szigetelés -->
        <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-layers" class="w-4 h-4 text-gray-600 dark:text-gray-400" />
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              Padlásfödém szigetelés
            </span>
          </div>
          <USwitch v-model="roofInsulationSwitch" />
        </div>

        <!-- Nyílászárók -->
        <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-door-open" class="w-4 h-4 text-gray-600 dark:text-gray-400" />
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              Nyílászárók
            </span>
          </div>
          <USwitch v-model="windowsSwitch" />
        </div>

        <!-- Hőszivattyú -->
        <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-wind" class="w-4 h-4 text-gray-600 dark:text-gray-400" />
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              Hőszivattyú
            </span>
          </div>
          <USwitch v-model="heatPumpSwitch" />
        </div>
      </div>

      <!-- Divider (csak akkor jelenik meg, ha van Investment switches) -->
      <div v-if="isConsultantModeActive" class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Energy Efficiency Improvement Slider (Readonly) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            {{ $t('survey.consultationData.energyEfficiency') }}
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ isConsultantModeActive ? formatPercentage(totalEnergyEfficiency) : formatPercentage(roiData.energyEfficiencyImprovement) }}
          </span>
        </div>

        <div class="relative">
          <!-- Slider with stacked gradient -->
          <input
            type="range"
            :value="roiData.energyEfficiencyImprovement * 100"
            min="0"
            max="100"
            disabled
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-not-allowed dark:bg-gray-700"
            :style="{ background: sliderGradient }"
          />

          <!-- Interactive overlay for tooltips (only in Consultant Mode) -->
          <div v-if="isConsultantModeActive" class="absolute left-0 w-full h-2 flex pointer-events-auto" style="top: 10px;">
            <div
              v-for="investment in enabledInvestmentsList"
              :key="investment.key"
              :style="{ width: `${investment.percentage}%` }"
              :title="`${investment.name}: ${investment.percentage.toFixed(1)}%`"
              class="h-full cursor-pointer hover:opacity-75 transition-opacity relative group"
            >
              <!-- Tooltip -->
              <div class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-xs rounded whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                {{ investment.name }}: {{ investment.percentage.toFixed(1) }}%
                <!-- Arrow -->
                <div class="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-gray-900 dark:border-t-gray-100"></div>
              </div>
            </div>
          </div>

          <div class="flex justify-between mt-1 text-xs text-gray-500 dark:text-gray-400">
            <span>{{ $t('survey.consultationData.zeroPercent') }}</span>
            <span>{{ $t('survey.consultationData.hundredPercent') }}</span>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Return on Investment -->
      <div class="space-y-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          {{ $t('survey.consultationData.returnOnInvestment') }}
        </h4>

        <div class="grid grid-cols-2 gap-3">
          <!-- Return Time - conditionally shown -->
          <div
            v-if="showReturnTime"
            class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg"
          >
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.returnTime') }}</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ roiData.returnTime.toFixed(1) }} {{ $t('survey.consultationData.years') }}
            </div>
          </div>

          <!-- Monthly Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.monthlySavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.monthlySavings) }}
            </div>
          </div>

          <!-- Annual Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.annualSavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.annualSavings) }}
            </div>
          </div>

          <!-- Current State -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.currentState') }}</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ formatCurrency(roiData.currentAnnualTotalCost) }}/{{ $t('survey.consultationData.perYear').split('/')[1] }}
            </div>
          </div>

          <!-- 10-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.tenYearSavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.savings10Year) }}
            </div>
          </div>

          <!-- 20-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ $t('survey.consultationData.twentyYearSavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.savings20Year) }}
            </div>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Planned Inflation Rate -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-3">
          {{ $t('survey.consultationData.plannedInflation') }}
        </label>
        <div class="grid grid-cols-4 gap-2">
          <button
            v-for="rate in inflationRates"
            :key="rate"
            type="button"
            class="py-2 px-4 rounded-lg border-2 font-medium transition-all text-sm"
            :class="inflationRate === rate
              ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300'
              : 'border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 text-gray-700 dark:text-gray-300'"
            @click="handleInflationChange(rate)"
          >
            {{ rate * 100 }}%
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useROICalculations } from '~/composables/useROICalculations'
import type { ROIData } from '~/composables/useROICalculations'

interface Props {
  surveyId: string
  showReturnTime?: boolean
  isConsultantModeActive?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showReturnTime: true,
  isConsultantModeActive: false
})

const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()
const {
  calculateROI,
  formatCurrency,
  formatPercentage,
  formatYears
} = useROICalculations()

const loading = ref(false)
const inflationRate = ref(0.02) // 2% default
const inflationRates = [0, 0.02, 0.04, 0.06]

// Investment states for Consultant Mode
const investmentStates = ref({
  facadeInsulation: false,
  roofInsulation: false,
  windows: false,
  heatPump: false
})

// Investment colors (matching OFP style)
const investmentColors = {
  facadeInsulation: '#40E0D0', // Turquoise
  roofInsulation: '#FF6347',    // Tomato
  windows: '#4682B4',           // SteelBlue
  heatPump: '#D8BFD8'          // Thistle
}

// Investment names
const investmentNames = {
  facadeInsulation: 'Homlokzati szigetelés',
  roofInsulation: 'Padlásfödém szigetelés',
  windows: 'Nyílászárók',
  heatPump: 'Hőszivattyú'
}

// OFP-based energy efficiency improvements (as decimal: 20.6% = 0.206)
const investmentImprovements = {
  facadeInsulation: 0.206,
  roofInsulation: 0.171,
  windows: 0.001,
  heatPump: 0
}

// Computed properties for each switch (required for USwitch v-model)
const facadeInsulationSwitch = computed({
  get: () => investmentStates.value.facadeInsulation,
  set: (value: boolean) => {
    investmentStates.value.facadeInsulation = value
    handleInvestmentToggle('facadeInsulation', value)
  }
})

const roofInsulationSwitch = computed({
  get: () => investmentStates.value.roofInsulation,
  set: (value: boolean) => {
    investmentStates.value.roofInsulation = value
    handleInvestmentToggle('roofInsulation', value)
  }
})

const windowsSwitch = computed({
  get: () => investmentStates.value.windows,
  set: (value: boolean) => {
    investmentStates.value.windows = value
    handleInvestmentToggle('windows', value)
  }
})

const heatPumpSwitch = computed({
  get: () => investmentStates.value.heatPump,
  set: (value: boolean) => {
    investmentStates.value.heatPump = value
    handleInvestmentToggle('heatPump', value)
  }
})

// Compute list of enabled investments with OFP-based improvement percentages
const enabledInvestmentsList = computed(() => {
  const enabled: Array<{
    key: string
    name: string
    color: string
    improvement: number
    percentage: number
  }> = []

  // Collect all enabled investments with OFP-based improvement values
  for (const [key, isEnabled] of Object.entries(investmentStates.value)) {
    if (isEnabled) {
      // Use OFP-based improvement values
      const improvementValue = investmentImprovements[key as keyof typeof investmentImprovements] || 0
      enabled.push({
        key,
        name: investmentNames[key as keyof typeof investmentNames],
        color: investmentColors[key as keyof typeof investmentColors],
        improvement: improvementValue,
        percentage: improvementValue * 100 // Convert to percentage (0.206 → 20.6%)
      })
    }
  }

  return enabled
})

// Compute stacked gradient background for slider
const sliderGradient = computed(() => {
  if (enabledInvestmentsList.value.length === 0) {
    // No investments enabled - white background
    return 'rgb(229, 231, 235)'
  }

  // Build stacked gradient with investment colors
  const gradientStops: string[] = []
  let currentPosition = 0

  for (const investment of enabledInvestmentsList.value) {
    const startPosition = currentPosition
    const endPosition = currentPosition + investment.percentage

    gradientStops.push(`${investment.color} ${startPosition}%`)
    gradientStops.push(`${investment.color} ${endPosition}%`)

    currentPosition = endPosition
  }

  // Fill remaining with gray
  if (currentPosition < 100) {
    gradientStops.push(`rgb(229, 231, 235) ${currentPosition}%`)
    gradientStops.push(`rgb(229, 231, 235) 100%`)
  }

  return `linear-gradient(to right, ${gradientStops.join(', ')})`
})

// Compute total energy efficiency from OFP values
const totalEnergyEfficiency = computed(() => {
  return enabledInvestmentsList.value.reduce((sum, inv) => sum + inv.improvement, 0)
})

// Initialize investment states based on active scenario
const initializeInvestmentStates = () => {
  if (!props.isConsultantModeActive) return

  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) return

  const scenarioInvestmentIds = scenariosStore.scenarioInvestments[activeScenarioId] || []

  // Map persist_name to investment state
  const persistNameMap: Record<string, keyof typeof investmentStates.value> = {
    'facadeInsulation': 'facadeInsulation',
    'roofInsulation': 'roofInsulation',
    'windows': 'windows',
    'heatPump': 'heatPump'
  }

  // Get available investments and check which ones are selected
  investmentsStore.availableInvestments.forEach(investment => {
    const stateKey = persistNameMap[investment.persist_name]
    if (stateKey) {
      investmentStates.value[stateKey] = scenarioInvestmentIds.includes(investment.id)
    }
  })
}

// Handle investment toggle
const handleInvestmentToggle = async (persistName: string, enabled: boolean) => {
  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) {
    console.error('No active scenario')
    return
  }

  // Find the investment by persist_name
  const investment = investmentsStore.availableInvestments.find(
    inv => inv.persist_name === persistName
  )

  if (!investment) {
    console.error(`Investment not found: ${persistName}`)
    return
  }

  const supabase = useSupabaseClient()

  try {
    if (enabled) {
      // Add investment to scenario
      const { error } = await supabase
        .from('scenario_investments')
        .insert({
          scenario_id: activeScenarioId,
          investment_id: investment.id
        })

      if (error) throw error

      // Update local state
      investmentStates.value[persistName as keyof typeof investmentStates.value] = true
    } else {
      // Remove investment from scenario
      const { error } = await supabase
        .from('scenario_investments')
        .delete()
        .eq('scenario_id', activeScenarioId)
        .eq('investment_id', investment.id)

      if (error) throw error

      // Update local state
      investmentStates.value[persistName as keyof typeof investmentStates.value] = false
    }

    // Reload scenarios to update the UI
    await scenariosStore.loadScenarios(props.surveyId)
  } catch (error) {
    console.error('Error toggling investment:', error)
    // TODO: Show error toast
  }
}

const roiData = ref<ROIData>({
  totalInvestmentCost: 0,
  energyEfficiencyImprovement: 0,
  currentAnnualElectricityCost: 0,
  currentAnnualGasCost: 0,
  currentAnnualTotalCost: 0,
  annualSavings: 0,
  monthlySavings: 0,
  returnTime: 0,
  savings10Year: 0,
  savings20Year: 0
})

const loadROIData = async () => {
  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) {
    return
  }

  loading.value = true

  try {
    roiData.value = await calculateROI(
      props.surveyId,
      activeScenarioId,
      inflationRate.value
    )
  } catch (error) {
    console.error('Error calculating ROI:', error)
  } finally {
    loading.value = false
  }
}

const handleInflationChange = async (rate: number) => {
  inflationRate.value = rate
  await loadROIData()
}

// Watch for active scenario changes
watch(() => scenariosStore.activeScenarioId, async () => {
  await loadROIData()
  initializeInvestmentStates()
})

// Watch for consultant mode changes
watch(() => props.isConsultantModeActive, () => {
  if (props.isConsultantModeActive) {
    initializeInvestmentStates()
  }
})

// Load data on mount
onMounted(async () => {
  await loadROIData()
  initializeInvestmentStates()
})
</script>

<style scoped>
/* Custom slider styles - hide thumb since we use stacked background */
input[type="range"]:disabled::-webkit-slider-thumb {
  appearance: none;
  width: 0;
  height: 0;
}

input[type="range"]:disabled::-moz-range-thumb {
  width: 0;
  height: 0;
  border: none;
}
</style>
