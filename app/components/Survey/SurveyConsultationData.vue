<template>
  <div class="space-y-4">
    <div v-if="loading" class="flex items-center justify-center py-8">
      <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
    </div>

    <div v-else class="space-y-6">
      <!-- Investment Switches (Only shown in Consultant Mode) -->
      <div v-if="isConsultantModeActive">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3">
          {{ t('survey.consultationData.selectInvestments') }}
        </h4>

        <div class="flex flex-wrap gap-2">
          <!-- Homlokzati szigetelés -->
          <button
            type="button"
            class="px-4 py-3 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative min-w-[100px]"
            :class="investmentStates.facadeInsulation
              ? 'text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600'"
            :style="investmentStates.facadeInsulation ? { backgroundColor: investmentColors.facadeInsulation } : {}"
            @click="facadeInsulationSwitch = !facadeInsulationSwitch"
          >
            <UIcon name="i-lucide-home" class="w-8 h-8 mb-1" />
            <span class="text-sm font-medium">{{ (investmentImprovements.facadeInsulation * 100).toFixed(1) }}%</span>
          </button>

          <!-- Padlásfödém szigetelés -->
          <button
            type="button"
            class="px-4 py-3 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative min-w-[100px]"
            :class="investmentStates.roofInsulation
              ? 'text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600'"
            :style="investmentStates.roofInsulation ? { backgroundColor: investmentColors.roofInsulation } : {}"
            @click="roofInsulationSwitch = !roofInsulationSwitch"
          >
            <UIcon name="i-lucide-layers" class="w-8 h-8 mb-1" />
            <span class="text-sm font-medium">{{ (investmentImprovements.roofInsulation * 100).toFixed(1) }}%</span>
          </button>

          <!-- Nyílászárók -->
          <button
            type="button"
            class="px-4 py-3 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative min-w-[100px]"
            :class="investmentStates.windows
              ? 'text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600'"
            :style="investmentStates.windows ? { backgroundColor: investmentColors.windows } : {}"
            @click="windowsSwitch = !windowsSwitch"
          >
            <UIcon name="i-lucide-door-open" class="w-8 h-8 mb-1" />
            <span class="text-sm font-medium">{{ (investmentImprovements.windows * 100).toFixed(1) }}%</span>
          </button>

          <!-- Hőszivattyú -->
          <button
            type="button"
            class="px-4 py-3 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative min-w-[100px]"
            :class="investmentStates.heatPump
              ? 'text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600'"
            :style="investmentStates.heatPump ? { backgroundColor: investmentColors.heatPump } : {}"
            @click="heatPumpSwitch = !heatPumpSwitch"
          >
            <UIcon name="i-lucide-wind" class="w-8 h-8 mb-1" />
            <span class="text-sm font-medium">{{ (investmentImprovements.heatPump * 100).toFixed(1) }}%</span>
          </button>
        </div>
      </div>

      <!-- Divider (csak akkor jelenik meg, ha van Investment switches) -->
      <div v-if="isConsultantModeActive" class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Energy Efficiency Improvement Slider (Readonly) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            {{ t('survey.consultationData.energyEfficiency') }}
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ isConsultantModeActive ? (totalEnergyEfficiency * 100).toFixed(1) + '%' : (roiData.energyEfficiencyImprovement * 100).toFixed(1) + '%' }}
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
            class="w-full h-5 bg-gray-200 rounded-lg appearance-none cursor-not-allowed dark:bg-gray-700"
            :style="{ background: sliderGradient }"
          />

          <!-- Interactive overlay for tooltips (only in Consultant Mode) -->
          <div v-if="isConsultantModeActive" class="absolute left-0 top-0 w-full h-5 flex pointer-events-auto">
            <div
              v-for="investment in enabledInvestmentsList"
              :key="investment.key"
              :style="{ width: `${investment.percentage}%` }"
              class="h-full cursor-pointer relative group"
            >
              <!-- Tooltip -->
              <div class="absolute left-full top-1/2 -translate-y-1/2 ml-2 px-3 py-2 bg-gray-900 dark:bg-gray-700 text-white text-xs rounded whitespace-nowrap opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all pointer-events-none z-50">
                {{ investment.name }}: {{ investment.percentage.toFixed(1) }}%
                <!-- Arrow (pointing left) -->
                <div class="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-full w-0 h-0 border-4 border-transparent border-r-gray-900 dark:border-r-gray-700"></div>
              </div>
            </div>
          </div>

          <div class="flex justify-between mt-1 text-xs text-gray-500 dark:text-gray-400">
            <span>{{ t('survey.consultationData.zeroPercent') }}</span>
            <span>{{ t('survey.consultationData.hundredPercent') }}</span>
          </div>
        </div>
      </div>

      <!-- Estimation Accuracy Slider (Only shown in Consultant Mode) -->
      <div v-if="isConsultantModeActive">
        <div class="flex items-center justify-between mb-2">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            {{ t('survey.consultationData.estimationAccuracy') }}
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ formatROIPercentage(estimationAccuracy) }}
          </span>
        </div>

        <div class="relative">
          <!-- Slider with gradient (green for filled, gray for remaining) -->
          <input
            type="range"
            :value="estimationAccuracy * 100"
            min="0"
            max="100"
            disabled
            class="w-full h-5 bg-gray-200 rounded-lg appearance-none cursor-not-allowed dark:bg-gray-700"
            :style="{ background: estimationAccuracyGradient }"
          />
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Energy Savings (GJ/kWh) - Individual Investment Accordions -->
      <div class="space-y-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          Energia megtakarítás (GJ/kWh)
        </h4>

        <!-- Loading state -->
        <div v-if="energyLoading" class="flex items-center justify-center py-4">
          <UIcon name="i-lucide-loader-2" class="w-5 h-5 animate-spin text-gray-400" />
        </div>

        <!-- Energy savings content -->
        <template v-else-if="energySavingsResult">
          <!-- Per-investment accordions -->
          <div v-if="Object.keys(energySavingsResult.perInvestment).length > 0" class="space-y-2">
            <div
              v-for="(data, key) in energySavingsResult.perInvestment"
              :key="key"
              class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden"
            >
              <button
                type="button"
                class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                @click="() => {
                  investmentAccordionStates[key] = !investmentAccordionStates[key]
                }"
              >
                <div class="flex items-center gap-2">
                  <UIcon :name="getInvestmentIcon(key)" class="w-4 h-4" />
                  <span>{{ getInvestmentLabel(key) }}</span>
                  <span class="text-xs font-semibold text-primary-600 dark:text-primary-400">
                    {{ data.savingsPercentage.toFixed(1) }}%
                  </span>
                </div>
                <UIcon
                  :name="investmentAccordionStates[key] ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                  class="w-4 h-4"
                />
              </button>
              <div
                v-show="investmentAccordionStates[key]"
                class="border-t border-gray-200 dark:border-gray-700 p-3 bg-gray-50 dark:bg-gray-900"
              >
                <div class="grid grid-cols-2 gap-3 text-xs">
                  <div>
                    <span class="text-gray-600 dark:text-gray-400">GJ/év:</span>
                    <span class="ml-1 font-semibold text-gray-900 dark:text-white">
                      {{ formatGJ(data.annualHeatingSavingsGJ) }}
                    </span>
                  </div>
                  <div>
                    <span class="text-gray-600 dark:text-gray-400">kWh/év:</span>
                    <span class="ml-1 font-semibold text-gray-900 dark:text-white">
                      {{ formatKWh(data.annualHeatingSavingsKWh) }}
                    </span>
                  </div>
                  <div v-if="data.actualArea">
                    <span class="text-gray-600 dark:text-gray-400">Terület:</span>
                    <span class="ml-1 font-semibold text-gray-900 dark:text-white">
                      {{ data.actualArea }} m²
                    </span>
                  </div>
                  <div v-if="data.capacity">
                    <span class="text-gray-600 dark:text-gray-400">Kapacitás:</span>
                    <span class="ml-1 font-semibold text-gray-900 dark:text-white">
                      {{ data.capacity }} kW
                    </span>
                  </div>
                  <div v-if="getOfpCostForInvestment(key)" class="col-span-2">
                    <span class="text-gray-600 dark:text-gray-400">Bruttó költség:</span>
                    <span class="ml-1 font-semibold text-gray-900 dark:text-white">
                      {{ formatOfpCurrency(getOfpCostForInvestment(key)!) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- No investments message -->
          <div v-else class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg text-center">
            <UIcon name="i-lucide-info" class="w-5 h-5 text-gray-400 mx-auto mb-2" />
            <p class="text-sm text-gray-600 dark:text-gray-400">
              Nincs számítható beruházás. Válasszon beruházásokat és adja meg a mennyiségeket.
            </p>
          </div>

          <!-- Calculate button -->
          <UButton
            v-if="Object.keys(energySavingsResult.perInvestment).length > 0"
            color="primary"
            size="sm"
            variant="outline"
            @click="calculateEnergySavingsForScenario"
            :loading="energyLoading"
            class="w-full"
          >
            <UIcon name="i-lucide-refresh-cw" class="w-4 h-4 mr-2" />
            Újraszámolás
          </UButton>
        </template>

        <!-- Error state -->
        <div v-else-if="energyError" class="p-4 bg-red-50 dark:bg-red-900/20 rounded-lg">
          <div class="flex items-center gap-2 text-red-600 dark:text-red-400 text-sm">
            <UIcon name="i-lucide-alert-triangle" class="w-5 h-5" />
            <span>{{ energyError }}</span>
          </div>
        </div>

        <!-- Initial state - calculate button -->
        <div v-else class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg text-center">
          <UButton
            color="primary"
            @click="calculateEnergySavingsForScenario"
            :loading="energyLoading"
          >
            <UIcon name="i-lucide-calculator" class="w-4 h-4 mr-2" />
            Energia megtakarítás számítása
          </UButton>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- KEHOP Summary Card -->
      <div v-if="energySavingsResult">
        <div
          class="p-4 rounded-lg border-2"
          :class="energySavingsResult.kehopSummary.meets30Percent
            ? 'bg-green-50 dark:bg-green-900/20 border-green-500'
            : 'bg-red-50 dark:bg-red-900/20 border-red-500'"
        >
          <div class="flex items-center justify-between mb-3">
            <h5 class="text-sm font-semibold"
              :class="energySavingsResult.kehopSummary.meets30Percent
                ? 'text-green-900 dark:text-green-100'
                : 'text-red-900 dark:text-red-100'"
            >
              KEHOP Plusz pályázat összesítése
            </h5>
            <UIcon
              :name="energySavingsResult.kehopSummary.meets30Percent
                ? 'i-lucide-check-circle'
                : 'i-lucide-alert-circle'"
              class="w-5 h-5"
              :class="energySavingsResult.kehopSummary.meets30Percent
                ? 'text-green-600 dark:text-green-400'
                : 'text-red-600 dark:text-red-400'"
            />
          </div>

          <div class="grid grid-cols-3 gap-3 mb-3">
            <div>
              <div class="text-xs"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-700 dark:text-green-300'
                  : 'text-red-700 dark:text-red-300'"
              >
                Összesen GJ
              </div>
              <div class="text-sm font-bold"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-900 dark:text-green-100'
                  : 'text-red-900 dark:text-red-100'"
              >
                {{ formatGJ(energySavingsResult.kehopSummary.totalGJ) }}
              </div>
            </div>

            <div>
              <div class="text-xs"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-700 dark:text-green-300'
                  : 'text-red-700 dark:text-red-300'"
              >
                Összesen kWh
              </div>
              <div class="text-sm font-bold"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-900 dark:text-green-100'
                  : 'text-red-900 dark:text-red-100'"
              >
                {{ formatKWh(energySavingsResult.kehopSummary.totalKWh) }}
              </div>
            </div>

            <div>
              <div class="text-xs"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-700 dark:text-green-300'
                  : 'text-red-700 dark:text-red-300'"
              >
                Összesen %
              </div>
              <div class="text-sm font-bold"
                :class="energySavingsResult.kehopSummary.meets30Percent
                  ? 'text-green-900 dark:text-green-100'
                  : 'text-red-900 dark:text-red-100'"
              >
                {{ formatPercentage(energySavingsResult.kehopSummary.totalPercentage) }}
              </div>
            </div>
          </div>

          <div class="text-xs"
            :class="energySavingsResult.kehopSummary.meets30Percent
              ? 'text-green-700 dark:text-green-300'
              : 'text-red-700 dark:text-red-300'"
          >
            <template v-if="energySavingsResult.kehopSummary.meets30Percent">
              ✓ A 30%-os KEHOP követelmény teljesül
            </template>
            <template v-else>
              ✗ A 30%-os KEHOP követelmény nem teljesül ({{ (30 - energySavingsResult.kehopSummary.totalPercentage).toFixed(1) }}% hiányzik)
            </template>
          </div>
        </div>

        <!-- Warning if architectural calculation was used (NOT RECOMMENDED) -->
        <div v-if="energySavingsResult.warnings && energySavingsResult.warnings.length > 0" class="mt-3">
          <div class="p-4 bg-yellow-50 dark:bg-yellow-900/20 border-2 border-yellow-500 rounded-lg">
            <div class="flex items-start gap-3">
              <UIcon name="i-lucide-alert-triangle" class="w-5 h-5 text-yellow-600 dark:text-yellow-400 flex-shrink-0 mt-0.5" />
              <div class="flex-1">
                <h6 class="text-sm font-semibold text-yellow-900 dark:text-yellow-100 mb-2">
                  ⚠️ Figyelmeztetés: Pontatlan számítás
                </h6>
                <ul class="space-y-2">
                  <li
                    v-for="(warning, index) in energySavingsResult.warnings"
                    :key="index"
                    class="text-xs text-yellow-800 dark:text-yellow-200"
                  >
                    {{ warning }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- OFP Summary Box -->
      <div v-if="ofpCalculation">
        <div class="grid grid-cols-2 gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
          <div>
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Teljes beruházás (bruttó)</p>
            <p class="text-lg font-bold text-gray-900 dark:text-white">
              {{ formatOfpCurrency(ofpCalculation.totals.total_investment_gross) }}
            </p>
          </div>
          <div>
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Önerő ({{ (ofpCalculation.percentage * 0.143).toFixed(1) }}%)</p>
            <p class="text-lg font-bold text-orange-600 dark:text-orange-400">
              {{ formatOfpCurrency(ofpCalculation.totals.total_self_strength) }}
            </p>
          </div>
          <div>
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Vissza nem térítendő ({{ ofpCalculation.percentage }}%)</p>
            <p class="text-lg font-bold text-green-600 dark:text-green-400">
              {{ formatOfpCurrency(ofpCalculation.totals.total_non_refundable) }}
            </p>
          </div>
          <div>
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Kamatmentes kölcsön</p>
            <p class="text-lg font-bold text-blue-600 dark:text-blue-400">
              {{ formatOfpCurrency(ofpCalculation.totals.total_interest_free_loan) }}
            </p>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Return on Investment -->
      <div class="space-y-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          {{ t('survey.consultationData.returnOnInvestment') }}
        </h4>

        <div class="grid grid-cols-2 gap-3">
          <!-- Return Time - conditionally shown -->
          <div
            v-if="showReturnTime"
            class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg"
          >
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.returnTime') }}</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ roiData.returnTime.toFixed(1) }} {{ t('survey.consultationData.years') }}
            </div>
          </div>

          <!-- Monthly Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.monthlySavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.monthlySavings) }}
            </div>
          </div>

          <!-- Annual Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.annualSavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.annualSavings) }}
            </div>
          </div>

          <!-- Current State -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.currentState') }}</div>
            <div class="text-sm font-semibold text-gray-900 dark:text-white">
              {{ formatCurrency(roiData.currentAnnualTotalCost) }}/{{ t('survey.consultationData.perYear').split('/')[1] }}
            </div>
          </div>

          <!-- 10-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.tenYearSavings') }}</div>
            <div class="text-sm font-semibold text-green-600 dark:text-green-400">
              {{ formatCurrency(roiData.savings10Year) }}
            </div>
          </div>

          <!-- 20-year Savings -->
          <div class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <div class="text-xs text-gray-600 dark:text-gray-400 mb-1">{{ t('survey.consultationData.twentyYearSavings') }}</div>
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
          {{ t('survey.consultationData.plannedInflation') }}
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
import { useI18n } from 'vue-i18n'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useROICalculations } from '~/composables/useROICalculations'
import type { ROIData } from '~/composables/useROICalculations'
import { useEnergyCalculations } from '~/composables/useEnergyCalculations'
import type { EnergySavingsResult } from '~/composables/useEnergyCalculations'
import { useOfpCalculation } from '~/composables/useOfpCalculation'
import type { OfpCalculationResult } from '~/composables/useOfpCalculation'

const { t } = useI18n()

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
  formatPercentage: formatROIPercentage,
  formatYears
} = useROICalculations()

const {
  calculateEnergySavings,
  getEnergySavings,
  formatGJ,
  formatKWh,
  formatPercentage,
  getInvestmentLabel,
  getInvestmentIcon,
  getMissingDataMessage
} = useEnergyCalculations()

const { formatCurrency: formatOfpCurrency } = useOfpCalculation()

// Energy savings state
const energyLoading = ref(false)
const energyError = ref<string | null>(null)
const energySavingsResult = ref<EnergySavingsResult | null>(null)
const energySavingsOpen = ref(true) // Collapsible state
const investmentAccordionStates = ref<Record<string, boolean>>({})

// OFP calculation state
const ofpCalculation = ref<OfpCalculationResult | null>(null)

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

// Energy efficiency improvements from database (as decimal: 10% = 0.10)
const investmentImprovements = ref({
  facadeInsulation: 0.10,
  roofInsulation: 0.08,
  windows: 0.05,
  heatPump: 0.15
})

// Load actual energy efficiency values from available investments
const loadInvestmentImprovements = () => {
  investmentsStore.availableInvestments.forEach(investment => {
    if (investment.persist_name && investment.energy_efficiency_improvement) {
      const key = investment.persist_name as keyof typeof investmentImprovements.value
      if (key in investmentImprovements.value) {
        investmentImprovements.value[key] = investment.energy_efficiency_improvement
      }
    }
  })
}

// Update investment improvements from energy savings result
const updateInvestmentImprovementsFromEnergySavings = () => {
  if (!energySavingsResult.value?.perInvestment) return

  for (const [key, data] of Object.entries(energySavingsResult.value.perInvestment)) {
    const investmentKey = key as keyof typeof investmentImprovements.value
    if (investmentKey in investmentImprovements.value) {
      // Convert percentage (e.g., 24.0) to decimal (e.g., 0.24)
      investmentImprovements.value[investmentKey] = data.savingsPercentage / 100
    }
  }
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
      const improvementValue = investmentImprovements.value[key as keyof typeof investmentImprovements.value] || 0
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

// Calculate estimation accuracy based on answered required questions
const totalRequiredQuestions = computed(() => {
  if (!props.isConsultantModeActive) return 0

  let count = 0

  // Filter investments based on mode - in Consultant Mode, exclude basicData
  const filteredInvestments = investmentsStore.selectedInvestments.filter(investment => {
    return investment.persist_name !== 'basicData'
  })

  // Count required questions for filtered investments
  filteredInvestments.forEach(investment => {
    const pages = investmentsStore.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = investmentsStore.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          count++
        }
      })
    })
  })

  return count
})

const answeredRequiredQuestions = computed(() => {
  if (!props.isConsultantModeActive) return 0

  let answered = 0

  // Filter investments based on mode - in Consultant Mode, exclude basicData
  const filteredInvestments = investmentsStore.selectedInvestments.filter(investment => {
    return investment.persist_name !== 'basicData'
  })

  // Count answered required questions for filtered investments
  filteredInvestments.forEach(investment => {
    const pages = investmentsStore.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = investmentsStore.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          const response = investmentsStore.investmentResponses[investment.id]?.[question.name]
          if (response && response !== '' && response !== null && response !== undefined) {
            answered++
          }
        }
      })
    })
  })

  return answered
})

// Compute estimation accuracy percentage (0-1)
const estimationAccuracy = computed(() => {
  if (totalRequiredQuestions.value === 0) return 0
  return answeredRequiredQuestions.value / totalRequiredQuestions.value
})

// Compute gradient for estimation accuracy slider
const estimationAccuracyGradient = computed(() => {
  const percentage = estimationAccuracy.value * 100

  // Green for filled, gray for remaining
  return `linear-gradient(to right, rgb(34, 197, 94) 0%, rgb(34, 197, 94) ${percentage}%, rgb(229, 231, 235) ${percentage}%, rgb(229, 231, 235) 100%)`
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

    // Recalculate energy savings after investment toggle
    await calculateEnergySavingsForScenario()
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

// Calculate energy savings for the active scenario
const calculateEnergySavingsForScenario = async () => {
  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) {
    energyError.value = 'Nincs aktív szcenárió'
    return
  }

  energyLoading.value = true
  energyError.value = null

  try {
    const result = await calculateEnergySavings(props.surveyId, activeScenarioId)
    if (result) {
      energySavingsResult.value = result
      // Update button percentages
      updateInvestmentImprovementsFromEnergySavings()
    } else {
      energyError.value = 'Nem sikerült kiszámítani az energia megtakarítást'
    }
  } catch (error: any) {
    energyError.value = error.message || 'Hiba történt a számítás során'
  } finally {
    energyLoading.value = false
  }
}

// Load stored energy savings for the active scenario
const loadEnergySavings = async () => {
  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) return

  energyLoading.value = true
  try {
    const result = await getEnergySavings(activeScenarioId)
    energySavingsResult.value = result
    // Update button percentages
    updateInvestmentImprovementsFromEnergySavings()
  } catch (error: any) {
    console.error('Failed to load energy savings:', error)
  } finally {
    energyLoading.value = false
  }
}

// Load OFP calculation for the active scenario
const loadOfpCalculation = async () => {
  const activeScenarioId = scenariosStore.activeScenarioId
  if (!activeScenarioId) return

  try {
    const supabase = useSupabaseClient()
    const { data, error } = await supabase
      .from('scenarios')
      .select('ofp_calculation')
      .eq('id', activeScenarioId)
      .single()

    if (error) throw error

    ofpCalculation.value = data?.ofp_calculation || null
  } catch (error: any) {
    console.error('Failed to load OFP calculation:', error)
    ofpCalculation.value = null
  }
}

// Map OFP investment keys to energy savings keys
const ofpKeyMap: Record<string, string> = {
  'wall_insulation': 'facadeInsulation',
  'roof_insulation': 'roofInsulation',
  'window_replacement': 'windows',
  'heat_pump': 'heatPump'
}

// Get OFP cost for an investment by energy savings key
const getOfpCostForInvestment = (energySavingsKey: string): number | null => {
  if (!ofpCalculation.value?.calculations) return null

  // Find the OFP key that maps to this energy savings key
  const ofpKey = Object.entries(ofpKeyMap).find(([_, value]) => value === energySavingsKey)?.[0]
  if (!ofpKey) return null

  const calculation = ofpCalculation.value.calculations[ofpKey]
  return calculation?.total_cost_gross || null
}

// Watch for active scenario changes
watch(() => scenariosStore.activeScenarioId, async () => {
  await loadROIData()
  initializeInvestmentStates()
  await loadEnergySavings()
  await loadOfpCalculation()
})

// Watch for consultant mode changes
watch(() => props.isConsultantModeActive, () => {
  if (props.isConsultantModeActive) {
    initializeInvestmentStates()
  }
})

// Load data on mount
onMounted(async () => {
  loadInvestmentImprovements()
  await loadROIData()
  initializeInvestmentStates()
  await loadEnergySavings()
  await loadOfpCalculation()
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
