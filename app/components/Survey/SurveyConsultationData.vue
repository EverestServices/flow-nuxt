<template>
  <div class="space-y-4">
    <div v-if="loading" class="flex items-center justify-center py-8">
      <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
    </div>

    <div v-else class="space-y-6">
      <!-- Energy Efficiency Improvement Slider (Readonly) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            Energy Efficiency Improvement
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ formatPercentage(roiData.energyEfficiencyImprovement) }}
          </span>
        </div>
        <div class="relative">
          <input
            type="range"
            :value="roiData.energyEfficiencyImprovement * 100"
            min="0"
            max="100"
            disabled
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-not-allowed dark:bg-gray-700"
            :style="{
              background: `linear-gradient(to right, rgb(37, 99, 235) 0%, rgb(37, 99, 235) ${roiData.energyEfficiencyImprovement * 100}%, rgb(229, 231, 235) ${roiData.energyEfficiencyImprovement * 100}%, rgb(229, 231, 235) 100%)`
            }"
          />
          <div class="flex justify-between mt-1 text-xs text-gray-500 dark:text-gray-400">
            <span>0%</span>
            <span>100%</span>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Return on Investment -->
      <div class="space-y-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          Return on Investment
        </h4>

        <div class="grid grid-cols-2 gap-3">
          <!-- Return Time - conditionally shown -->
          <div
            v-if="showReturnTime"
            class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg"
          >
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">Return Time</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ formatYears(roiData.returnTime) }}
            </div>
          </div>

          <!-- Monthly Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">Monthly Savings</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.monthlySavings) }}
            </div>
          </div>

          <!-- Annual Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">Annual Savings</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.annualSavings) }}
            </div>
          </div>

          <!-- Current State -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">Current State</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ formatCurrency(roiData.currentAnnualTotalCost) }}/yr
            </div>
          </div>

          <!-- 10-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">10-year Savings</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.savings10Year) }}
            </div>
          </div>

          <!-- 20-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">20-year Savings</div>
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
          Planned Inflation Rate
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
import { useROICalculations } from '~/composables/useROICalculations'
import type { ROIData } from '~/composables/useROICalculations'

interface Props {
  surveyId: string
  showReturnTime?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showReturnTime: true
})

const scenariosStore = useScenariosStore()
const {
  calculateROI,
  formatCurrency,
  formatPercentage,
  formatYears
} = useROICalculations()

const loading = ref(false)
const inflationRate = ref(0.02) // 2% default
const inflationRates = [0, 0.02, 0.04, 0.06]

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
    console.log('[Consultation] No active scenario')
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
})

// Load data on mount
onMounted(async () => {
  await loadROIData()
})
</script>

<style scoped>
/* Custom slider styles */
input[type="range"]:disabled::-webkit-slider-thumb {
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgb(37, 99, 235);
  cursor: not-allowed;
}

input[type="range"]:disabled::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgb(37, 99, 235);
  cursor: not-allowed;
  border: none;
}
</style>
