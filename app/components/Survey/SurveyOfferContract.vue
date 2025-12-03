<template>
  <div class="min-h-screen flex relative overflow-hidden">
    <!-- Left Column - Scenario Selector and Technical Details -->
    <div class="fixed left-3 top-20 bottom-20 w-[48%] backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 shadow-2xl flex flex-col z-20">
      <div class="flex-1 overflow-auto p-6 space-y-4">
        <!-- Scenario Selector Section -->
        <div class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl p-4 shadow-sm">
          <h3 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
            <UIcon name="i-lucide-layers" class="w-5 h-5" />
            {{ t('survey.offerContract.selectScenario') }}
          </h3>

          <!-- Scenario Buttons -->
          <div class="flex gap-2 flex-wrap">
            <button
              v-for="scenario in scenarios"
              :key="scenario.id"
              class="flex items-center gap-1.5 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 whitespace-nowrap shadow-sm"
              :class="selectedScenarioId === scenario.id && !contractsStore.activeContractId
                ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-md hover:shadow-lg hover:scale-105'
                : 'bg-white/80 dark:bg-gray-700/80 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-600 hover:scale-105'"
              @click="handleSelectScenario(scenario.id)"
            >
              <!-- Investment icons -->
              <div class="flex gap-0.5">
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

          <!-- No scenarios message -->
          <div v-if="scenarios.length === 0" class="text-center py-8">
            <UIcon name="i-lucide-inbox" class="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p class="text-sm text-gray-500 dark:text-gray-400">
              {{ t('survey.offerContract.noScenarios') }}
            </p>
          </div>
        </div>

        <!-- Technical Details Accordion -->
        <div v-if="selectedScenarioId" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="technicalDetailsOpen = !technicalDetailsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-settings" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.technicalDetails') }}</span>
            </div>
            <UIcon
              :name="technicalDetailsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="technicalDetailsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Technical Details Content -->
              <SurveyOfferContractTechnicalDetails
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                :read-only="!isOfpSurvey"
                :is-ofp-survey="isOfpSurvey"
              />
            </div>
          </div>
        </div>

        <!-- Tető konfiguráció Accordion - Only for Solar Panel scenarios -->
        <div v-if="selectedScenarioId && hasSolarPanelInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="roofConfigurationOpen = !roofConfigurationOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-home" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.roofConfiguration') }}</span>
            </div>
            <UIcon
              :name="roofConfigurationOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="roofConfigurationOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Roof Configuration Content -->
              <SurveyOfferContractRoofConfiguration
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
              />
            </div>
          </div>
        </div>

        <!-- Compatibility Check Accordion - Only for Solar Panel scenarios -->
        <div v-if="selectedScenarioId && hasSolarPanelInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="compatibilityCheckOpen = !compatibilityCheckOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-check-circle" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.compatibilityCheck') }}</span>
            </div>
            <UIcon
              :name="compatibilityCheckOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="compatibilityCheckOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Compatibility Check Content -->
              <SurveyOfferContractCompatibilityCheck
                v-if="selectedScenarioId"
                :scenario-id="selectedScenarioId"
              />
            </div>
          </div>
        </div>

        <!-- Extra Costs Accordion - Only for Solar Panel scenarios -->
        <div v-if="selectedScenarioId && hasSolarPanelInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="extraCostsOpen = !extraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.solarExtraCosts') }}</span>
            </div>
            <UIcon
              :name="extraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="extraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Extra Costs Content -->
              <SurveyOfferContractInvestmentExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                :investment-persist-name="['solarPanel', 'solarPanelBattery']"
              />
            </div>
          </div>
        </div>

        <!-- Facade Insulation Extra Costs Accordion -->
        <div v-if="selectedScenarioId && hasFacadeInsulationInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="facadeInsulationExtraCostsOpen = !facadeInsulationExtraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.facadeInsulationExtraCosts') }}</span>
            </div>
            <UIcon
              :name="facadeInsulationExtraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="facadeInsulationExtraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Facade Insulation Extra Costs Content -->
              <SurveyOfferContractInvestmentExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                investment-persist-name="facadeInsulation"
              />
            </div>
          </div>
        </div>

        <!-- Attic Floor Insulation Extra Costs Accordion -->
        <div v-if="selectedScenarioId && hasAtticFloorInsulationInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="atticFloorInsulationExtraCostsOpen = !atticFloorInsulationExtraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.atticFloorInsulationExtraCosts') }}</span>
            </div>
            <UIcon
              :name="atticFloorInsulationExtraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="atticFloorInsulationExtraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Attic Floor Insulation Extra Costs Content -->
              <SurveyOfferContractInvestmentExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                investment-persist-name="roofInsulation"
              />
            </div>
          </div>
        </div>

        <!-- Windows Extra Costs Accordion -->
        <div v-if="selectedScenarioId && hasWindowsInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="windowsExtraCostsOpen = !windowsExtraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.windowsExtraCosts') }}</span>
            </div>
            <UIcon
              :name="windowsExtraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="windowsExtraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Windows Extra Costs Content -->
              <SurveyOfferContractInvestmentExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                investment-persist-name="windows"
              />
            </div>
          </div>
        </div>

        <!-- Heat Pump Extra Costs Accordion -->
        <div v-if="selectedScenarioId && hasHeatPumpInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="heatPumpExtraCostsOpen = !heatPumpExtraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>Hőszivattyú járulékos költségei</span>
            </div>
            <UIcon
              :name="heatPumpExtraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="heatPumpExtraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Heat Pump Extra Costs Content -->
              <SurveyOfferContractInvestmentExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                investment-persist-name="heatPump"
              />
            </div>
          </div>
        </div>

        <!-- General Extra Costs Accordion -->
        <div v-if="selectedScenarioId" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="generalExtraCostsOpen = !generalExtraCostsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-dollar-sign" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.extraCosts') }}</span>
            </div>
            <UIcon
              :name="generalExtraCostsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="generalExtraCostsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- General Extra Costs Content -->
              <SurveyOfferContractGeneralExtraCosts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
              />
            </div>
          </div>
        </div>

        <!-- Discounts Accordion - Only for Solar Panel scenarios -->
        <div v-if="selectedScenarioId && hasSolarPanelInvestment" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="discountsOpen = !discountsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-badge-percent" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.discounts') }}</span>
            </div>
            <UIcon
              :name="discountsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="discountsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Discounts Content -->
              <SurveyOfferContractDiscounts
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Column - Contract Details and Prices -->
    <div class="fixed right-3 top-20 bottom-20 w-[48%] backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 shadow-2xl flex flex-col z-20">
      <div class="flex-1 overflow-auto p-6 space-y-4">
        <!-- Contract Details Accordion -->
        <div v-if="selectedScenarioId" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="contractDetailsOpen = !contractDetailsOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-file-text" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.contractDetails') }}</span>
            </div>
            <UIcon
              :name="contractDetailsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="contractDetailsOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Contract Details Content -->
              <SurveyOfferContractDetails
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                :commission-rate="commissionRate"
              />
            </div>
          </div>
        </div>

        <!-- Prices Accordion -->
        <div v-if="selectedScenarioId" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="pricesOpen = !pricesOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-receipt" class="w-5 h-5" />
              <span>{{ t('survey.offerContract.prices') }}</span>
            </div>
            <UIcon
              :name="pricesOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="pricesOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- Prices Content -->
              <SurveyOfferContractPrices
                v-if="selectedScenarioId"
                :survey-id="surveyId"
                :scenario-id="selectedScenarioId"
                :total-price-after-subsidy="totalPriceData"
                :total-discounts="discountsTotal"
                :commission-rate="commissionRate"
              />
            </div>
          </div>
        </div>

        <!-- OFP Calculation Accordion - Only for OFP-relevant investments -->
        <div v-if="selectedScenarioId && hasOfpInvestments" class="backdrop-blur-sm bg-white/50 dark:bg-gray-900/50 border border-white/30 dark:border-gray-700/30 rounded-2xl overflow-hidden shadow-sm">
          <button
            type="button"
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-white/70 dark:hover:bg-gray-800/70 transition-colors"
            @click="ofpCalculationOpen = !ofpCalculationOpen"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-calculator" class="w-5 h-5" />
              <span>OFP Kalkuláció</span>
            </div>
            <UIcon
              :name="ofpCalculationOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>
          <div
            v-show="ofpCalculationOpen"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <!-- OFP Calculation Content -->
              <ScenarioOfpCalculation
                v-if="selectedScenarioId"
                :scenario-id="selectedScenarioId"
                :ofp-calculation="currentOfpCalculation"
                @calculate="handleOfpCalculate"
              />
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, provide, inject, watch, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useContractsStore } from '~/stores/contracts'
import { useOfpCalculation, type OfpCalculationResult } from '~/composables/useOfpCalculation'
import { useExternalApiKeys } from '~/composables/useExternalApiKeys'

const { t } = useI18n()
const { calculateOfp, loading: ofpLoading, error: ofpError } = useOfpCalculation()
const { getOfpApiKey, getUserEmail, hasOfpApiKey } = useExternalApiKeys()

interface Props {
  surveyId: string
  contractMode: 'offer' | 'contract' | null
}

const props = defineProps<Props>()

const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()
const contractsStore = useContractsStore()
const supabase = useSupabaseClient()

// Check if this is an OFP survey
const isOfpSurvey = ref(false)

// Load survey data to check OFP status
const loadSurveyData = async () => {
  const { data: survey } = await supabase
    .from('surveys')
    .select('ofp_survey_id')
    .eq('id', props.surveyId)
    .single()

  isOfpSurvey.value = !!(survey?.ofp_survey_id)
}

// Load on component mount
onMounted(() => {
  loadSurveyData()
})

// Selected scenario state
const selectedScenarioId = ref<string | null>(null)

// Accordion states
const technicalDetailsOpen = ref(true)
const roofConfigurationOpen = ref(true)
const compatibilityCheckOpen = ref(true)
const extraCostsOpen = ref(true)
const facadeInsulationExtraCostsOpen = ref(true)
const atticFloorInsulationExtraCostsOpen = ref(true)
const windowsExtraCostsOpen = ref(true)
const heatPumpExtraCostsOpen = ref(true)
const generalExtraCostsOpen = ref(true)
const discountsOpen = ref(true)
const contractDetailsOpen = ref(true)
const pricesOpen = ref(false)
const ofpCalculationOpen = ref(false)

// Commission rate state
const commissionRate = ref(0.12) // Default 12% (red)

// Get scenarios
const scenarios = computed(() => scenariosStore.scenarios)

// Get scenario investments
const scenarioInvestments = computed(() => scenariosStore.scenarioInvestments)

// Check if selected scenario has Solar Panel investment
const hasSolarPanelInvestment = computed(() => {
  if (!selectedScenarioId.value) return false

  const investmentIds = scenarioInvestments.value[selectedScenarioId.value] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && (investment.persist_name === 'solarPanel' || investment.persist_name === 'solarPanelBattery')
  })
})

// Check if selected scenario has Facade Insulation investment
const hasFacadeInsulationInvestment = computed(() => {
  if (!selectedScenarioId.value) return false

  const investmentIds = scenarioInvestments.value[selectedScenarioId.value] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'facadeInsulation'
  })
})

// Check if selected scenario has Attic Floor Insulation investment
const hasAtticFloorInsulationInvestment = computed(() => {
  if (!selectedScenarioId.value) return false

  const investmentIds = scenarioInvestments.value[selectedScenarioId.value] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'roofInsulation'
  })
})

// Check if selected scenario has Windows investment
const hasWindowsInvestment = computed(() => {
  if (!selectedScenarioId.value) return false

  const investmentIds = scenarioInvestments.value[selectedScenarioId.value] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'windows'
  })
})

// Check if selected scenario has Heat Pump investment
const hasHeatPumpInvestment = computed(() => {
  if (!selectedScenarioId.value) return false

  const investmentIds = scenarioInvestments.value[selectedScenarioId.value] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'heatPump'
  })
})

// Check if selected scenario has any OFP-relevant investments
const hasOfpInvestments = computed(() => {
  return hasFacadeInsulationInvestment.value ||
    hasAtticFloorInsulationInvestment.value ||
    hasWindowsInvestment.value ||
    hasHeatPumpInvestment.value
})

// Get current scenario's OFP calculation
const currentOfpCalculation = computed(() => {
  if (!selectedScenarioId.value) return null
  const scenario = scenarios.value.find(s => s.id === selectedScenarioId.value)
  return scenario?.ofp_calculation || null
})

// Auto-trigger OFP calculation for OFP surveys when scenario is selected
watch([selectedScenarioId, isOfpSurvey], async ([newScenarioId, isOfp]) => {
  if (!newScenarioId || !isOfp) return
  if (currentOfpCalculation.value) return // Already calculated
  if (!hasOfpInvestments.value) return // No OFP investments

  // Check if API key is available
  const hasApiKey = await hasOfpApiKey()
  if (!hasApiKey) {
    console.log('[OFP Auto-Calc] Skipping: No API key configured')
    return
  }

  // Automatically trigger calculation
  console.log('[OFP Auto-Calc] Automatically calculating OFP for scenario:', newScenarioId)
  await handleOfpCalculate()
}, { immediate: true })

// Handle OFP calculation
const handleOfpCalculate = async () => {
  if (!selectedScenarioId.value) return

  const toast = useToast()

  // Get API key from user profile
  const apiKey = await getOfpApiKey()
  const userEmail = getUserEmail()

  if (!apiKey) {
    toast.add({
      title: 'OFP Kalkuláció',
      description: 'Az OFP API key nincs beállítva. Kérjük, állítsa be a profil beállításokban.',
      color: 'yellow',
    })
    return
  }

  if (!userEmail) {
    toast.add({
      title: 'OFP Kalkuláció',
      description: 'Felhasználói email nem található.',
      color: 'red',
    })
    return
  }

  // Call OFP calculation
  const result = await calculateOfp(selectedScenarioId.value, apiKey, userEmail)

  if (result) {
    toast.add({
      title: 'OFP Kalkuláció',
      description: 'A kalkuláció sikeresen elkészült.',
      color: 'green',
    })

    // Refresh scenario data to get updated ofp_calculation
    await scenariosStore.loadScenarios(props.surveyId)
  } else if (ofpError.value) {
    toast.add({
      title: 'OFP Kalkuláció hiba',
      description: ofpError.value,
      color: 'red',
    })
  }
}

// Calculate total discounts
const discountsTotal = computed(() => {
  return discountsData.value.reduce((sum, discount) => sum + (discount.calculatedValue || 0), 0)
})

// Get scenario investment icons (filter out is_default investments)
const getScenarioInvestmentIcons = (scenarioId: string) => {
  const investmentIds = scenarioInvestments.value[scenarioId] || []

  return investmentIds
    .map(id => {
      const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
      return investment && !investment.is_default ? investment.icon : null
    })
    .filter(Boolean)
}

// Handle scenario selection
const handleSelectScenario = (scenarioId: string) => {
  selectedScenarioId.value = scenarioId
  // Clear active contract when selecting a scenario for exclusive selection
  contractsStore.activeContractId = null
}

// ===================================================================
// CONTRACT DATA COLLECTION
// ===================================================================

// Data from child components (via provide/inject)
const solarExtraCostsData = ref<any[]>([])
const generalExtraCostsData = ref<any[]>([])
const discountsData = ref<any[]>([])
const roofConfigurationData = ref<any>([])
const vatData = ref(27)
const totalPriceData = ref(0)

// Provide functions for child components to update data
provide('updateSolarExtraCostsData', (data: any[]) => {
  solarExtraCostsData.value = data
})

provide('updateGeneralExtraCostsData', (data: any[]) => {
  generalExtraCostsData.value = data
})

provide('updateDiscountsData', (data: any[]) => {
  discountsData.value = data
})

provide('updateRoofConfigurationData', (data: any) => {
  roofConfigurationData.value = data
})

provide('updateVatData', (vat: number) => {
  vatData.value = vat
})

provide('updateTotalPriceData', (total: number) => {
  totalPriceData.value = total
})

// Extra costs totals (for investment-specific components)
provide('updateSolarExtraCostsTotal', (total: number) => {
  // Can be used for validation or display purposes in the future
})

provide('updateFacadeInsulationExtraCostsTotal', (total: number) => {
  // Can be used for validation or display purposes in the future
})

provide('updateRoofInsulationExtraCostsTotal', (total: number) => {
  // Can be used for validation or display purposes in the future
})

provide('updateWindowsExtraCostsTotal', (total: number) => {
  // Can be used for validation or display purposes in the future
})

// ===================================================================
// CONTRACT DATA LOADING ON SELECTION
// ===================================================================

// Watch for contract selection and load its data
watch(() => contractsStore.activeContractId, async (contractId) => {
  if (!contractId) return

  const contract = contractsStore.activeContract
  if (!contract) return

  // Set scenario from contract
  if (contract.scenario_id) {
    selectedScenarioId.value = contract.scenario_id
  }

  // Set commission rate
  commissionRate.value = contract.commission_rate

  // Set VAT
  vatData.value = contract.vat

  // Set total price
  totalPriceData.value = contract.total_price

  // Set roof configuration
  if (contract.roof_configuration) {
    roofConfigurationData.value = contract.roof_configuration
  }

  // Load extra costs from contract
  const contractExtraCosts = contractsStore.activeContractExtraCosts

  // Separate solar and general extra costs (need to check investment type)
  const solarCosts: any[] = []
  const generalCosts: any[] = []

  for (const ec of contractExtraCosts) {
    // Get the extra cost details to determine if it's solar or general
    const supabase = useSupabaseClient()
    const { data: extraCost } = await supabase
      .from('extra_costs')
      .select('*')
      .eq('id', ec.extra_cost_id)
      .single()

    const costData = {
      extra_cost_id: ec.extra_cost_id,
      snapshot_price: ec.snapshot_price,
      quantity: ec.quantity,
      comment: ec.comment,
      is_selected: true
    }

    // Check if it's a solar extra cost based on investment_id
    if (extraCost && extraCost.investment_id) {
      const investment = investmentsStore.availableInvestments.find(inv => inv.id === extraCost.investment_id)
      if (investment && (investment.persist_name === 'solarPanel' || investment.persist_name === 'solarPanelBattery')) {
        solarCosts.push(costData)
      } else {
        generalCosts.push(costData)
      }
    } else {
      generalCosts.push(costData)
    }
  }

  solarExtraCostsData.value = solarCosts
  generalExtraCostsData.value = generalCosts

  // Load discounts from contract
  const contractDiscounts = contractsStore.activeContractDiscounts
  discountsData.value = contractDiscounts.map(cd => ({
    discount_id: cd.discount_id,
    discount_snapshot: cd.discount_snapshot,
    is_enabled: true
  }))
})

// Collect all contract data
const collectContractData = () => {
  if (!selectedScenarioId.value) {
    throw new Error('No scenario selected')
  }

  // Get scenario components
  const scenarioComponents = scenariosStore.scenarioComponents[selectedScenarioId.value] || []
  const investments = scenarioInvestments.value[selectedScenarioId.value] || []

  return {
    scenario_id: selectedScenarioId.value,
    survey_id: props.surveyId,
    contract_mode: props.contractMode || 'offer',
    commission_rate: commissionRate.value,
    vat: vatData.value,
    total_price: totalPriceData.value,
    roof_configuration: roofConfigurationData.value,
    notes: '',

    // Main components with price snapshots
    main_components: scenarioComponents.map(sc => {
      const mainComponent = scenariosStore.getMainComponentById(sc.main_component_id)
      return {
        main_component_id: sc.main_component_id,
        investment_id: sc.investment_id,
        quantity: sc.quantity,
        price_snapshot: mainComponent?.price || sc.price_snapshot
      }
    }),

    // Investments
    investments,

    // Solar extra costs (only selected ones)
    solar_extra_costs: solarExtraCostsData.value,

    // General extra costs (only selected ones)
    general_extra_costs: generalExtraCostsData.value,

    // Discounts (only enabled ones)
    discounts: discountsData.value
  }
}

// ===================================================================
// CONTRACT SAVE/MODIFY
// ===================================================================

// Save new contract
const handleSaveContract = async () => {
  if (!selectedScenarioId.value) {
    alert(t('survey.offerContract.selectScenarioFirst'))
    return
  }

  try {
    const contractData = collectContractData()

    // Generate automatic name
    const contractName = contractsStore.getNextContractName()

    // Create new contract
    await contractsStore.createContract({
      ...contractData,
      name: contractName
    })
  } catch (error) {
    console.error('Error saving contract:', error)
    alert(t('survey.offerContract.saveError'))
  }
}

// Modify existing contract
const handleModifyContract = async () => {
  if (!contractsStore.activeContractId) return

  try {
    const contractData = collectContractData()

    // Update existing contract
    await contractsStore.updateContract(contractsStore.activeContractId, {
      ...contractData,
      name: contractsStore.activeContract?.name
    })

    alert(t('survey.offerContract.modifySuccess'))
  } catch (error) {
    console.error('Error modifying contract:', error)
    alert(t('survey.offerContract.modifyError'))
  }
}

// Expose functions to parent component
defineExpose({
  handleSaveContract,
  handleModifyContract
})
</script>
