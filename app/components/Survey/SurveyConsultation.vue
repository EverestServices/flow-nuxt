<template>
  <div class="min-h-screen flex relative overflow-hidden">
    <!-- System Design Column - Floating Left -->
    <Transition name="slide-left">
      <div
        v-if="systemDesignOpen"
        :style="{ width: systemDesignWidth + 'px' }"
        class="fixed left-3 top-20 bottom-20 backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 shadow-2xl flex flex-col z-20"
      >
        <!-- Resize Handle -->
        <div
          class="absolute right-0 top-0 bottom-0 w-1 hover:w-2 bg-transparent hover:bg-primary-500/50 cursor-col-resize z-30 transition-all"
          @mousedown="startResizeSystemDesign"
        ></div>
        <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <div class="flex items-center gap-2 text-gray-900 dark:text-white font-medium">
            <UIcon name="i-lucide-ruler" class="w-5 h-5" />
            <span>{{ $t('survey.consultation.systemDesign') }}</span>
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
          <!-- Action Buttons -->
          <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex gap-2">
            <!-- AI Scenarios button -->
            <UIButtonEnhanced
              variant="primary"
              size="sm"
              @click="$emit('ai-scenarios')"
              class="whitespace-nowrap"
            >
              <Icon name="i-lucide-zap" class="w-4 h-4 mr-2" />
              {{ $t('survey.footer.aiScenarios') }}
            </UIButtonEnhanced>

            <!-- New Scenario button -->
            <UIButtonEnhanced
              variant="outline"
              size="sm"
              @click="$emit('new-scenario')"
              class="whitespace-nowrap"
            >
              <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
              {{ $t('survey.footer.newScenario') }}
            </UIButtonEnhanced>
          </div>
          <!-- Technical Data Container -->
          <div v-if="!hasScenarios" class="border-b border-gray-200 dark:border-gray-700">
            <div class="p-4">
              <p class="text-sm text-gray-500 dark:text-gray-400">
                {{ $t('survey.consultation.noScenariosYet') }}
              </p>
            </div>
          </div>

          <!-- Active Scenario Content -->
          <div v-if="activeScenario" class="p-4 border-b border-gray-200 dark:border-gray-700">
            <!-- Investment Accordions -->
            <SurveyScenarioInvestments
              :survey-id="surveyId"
              :scenario-id="activeScenario.id"
              :is-ofp-survey="isOfpSurvey"
            />
          </div>

          <!-- Accordions -->
          <div class="p-4 space-y-3 mt-auto">
            <!-- Subsidy Accordion -->
            <div class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
              <button
                type="button"
                class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                @click="subsidyOpen = !subsidyOpen"
              >
                <div class="flex items-center gap-2">
                  <UIcon name="i-lucide-banknote" class="w-4 h-4" />
                  <span>{{ $t('survey.consultation.subsidy') }}</span>
                </div>
                <div class="flex items-center gap-2">
                  <!-- Info Button with Tooltip -->
                  <div class="relative group">
                    <button
                      class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                      @click.stop
                      type="button"
                    >
                      <UIcon name="i-lucide-alert-circle" class="w-4 h-4" />
                    </button>
                    <!-- Tooltip -->
                    <div class="absolute right-full mr-2 top-1/2 -translate-y-1/2 px-3 py-2 bg-gray-900 dark:bg-gray-700 text-white text-xs rounded whitespace-nowrap opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all pointer-events-none z-50">
                      {{ $t('survey.consultation.subsidiesAvailable') }}
                      <div class="absolute right-0 top-1/2 -translate-y-1/2 translate-x-full w-0 h-0 border-4 border-transparent border-l-gray-900 dark:border-l-gray-700"></div>
                    </div>
                  </div>
                  <UIcon
                    :name="subsidyOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                    class="w-4 h-4"
                  />
                </div>
              </button>
              <div
                v-show="subsidyOpen"
                class="border-t border-gray-200 dark:border-gray-700"
              >
                <div class="p-3">
                  <div v-if="subsidiesLoading" class="flex items-center justify-center py-4">
                    <UIcon name="i-lucide-loader-2" class="w-5 h-5 animate-spin text-gray-400" />
                  </div>
                  <SurveySubsidies
                    v-else
                    :subsidies="getSubsidiesWithStatus"
                    :eligibility-conditions="eligibilityConditions"
                    @toggle="handleSubsidyToggle"
                    @update-condition="handleConditionUpdate"
                  />
                </div>
              </div>
            </div>

            <!-- Household Data Accordion -->
            <div class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
              <button
                type="button"
                class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                @click="householdDataOpen = !householdDataOpen"
              >
                <div class="flex items-center gap-2">
                  <UIcon name="i-lucide-info" class="w-4 h-4" />
                  <span>{{ $t('survey.consultation.householdData') }}</span>
                </div>
                <div class="flex items-center gap-2">
                  <!-- Action Buttons -->
                  <button
                    class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                    @click.stop="showElectricCarsModal = true"
                    :title="$t('survey.consultation.electricCarSettings')"
                  >
                    <UIcon name="i-lucide-car" class="w-4 h-4" />
                  </button>
                  <button
                    class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                    @click.stop="showHeavyConsumersModal = true"
                    :title="$t('survey.consultation.heavyConsumerSettings')"
                  >
                    <UIcon name="i-lucide-plug-zap" class="w-4 h-4" />
                  </button>
                  <UIcon
                    :name="householdDataOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                    class="w-4 h-4"
                  />
                </div>
              </button>
              <div
                v-show="householdDataOpen"
                class="border-t border-gray-200 dark:border-gray-700"
              >
                <div class="p-3">
                  <SurveyHouseholdData
                    :key="`household-${surveyId}-${householdDataKey}`"
                    :survey-id="surveyId"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Reopen System Design Button - Left Edge -->
    <button
      v-if="!systemDesignOpen"
      class="fixed left-3 top-1/2 -translate-y-1/2 backdrop-blur-md bg-white/80 dark:bg-gray-800/80 border border-white/20 dark:border-gray-700/20 rounded-full p-3 hover:bg-white/90 dark:hover:bg-gray-700/90 transition-all shadow-lg z-10 flex cursor-pointer"
      @click="handleSystemDesignToggle(true)"
    >
      <UIcon name="i-lucide-chevron-right" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
    </button>

    <!-- System Visualization Column - Center (Full Width Background) -->
    <div class="w-full flex flex-col">
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

    <!-- Consultation Column - Floating Right -->
    <Transition name="slide-right">
      <div
        v-if="consultationOpen"
        :style="{ width: consultationWidth + 'px' }"
        class="fixed right-3 top-20 bottom-20 backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 shadow-2xl flex flex-col z-20"
      >
        <!-- Resize Handle -->
        <div
          class="absolute left-0 top-0 bottom-0 w-1 hover:w-2 bg-transparent hover:bg-primary-500/50 cursor-col-resize z-30 transition-all"
          @mousedown="startResizeConsultation"
        ></div>
        <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
          <div class="flex items-center gap-2 text-gray-900 dark:text-white font-medium">
            <UIcon name="i-lucide-message-circle" class="w-5 h-5" />
            <span>{{ $t('survey.consultation.consultation') }}</span>
          </div>
          <UButton
            icon="i-lucide-chevron-right"
            color="gray"
            variant="ghost"
            size="sm"
            @click="handleConsultationToggle(false)"
          />
        </div>
        <div class="flex-1 p-4 overflow-auto space-y-3">
          <!-- Investment Details Accordion -->
          <UAccordion
            :items="[{
              label: t('survey.consultation.investmentDetails'),
              icon: 'i-lucide-bar-chart-3',
              slot: 'investment-details',
              defaultOpen: true
            }]"
          >
            <template #investment-details>
              <div class="p-3">
                <SurveyInvestmentDetails :survey-id="surveyId" />
              </div>
            </template>
          </UAccordion>

          <!-- Consultation Accordion -->
          <div class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <button
              type="button"
              class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
              @click="consultationDataOpen = !consultationDataOpen"
            >
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-file-text" class="w-4 h-4" />
                <span>{{ $t('survey.consultation.consultation') }}</span>
              </div>
              <div class="flex items-center gap-2">
                <!-- Info Button -->
                <button
                  class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                  @click.stop="showConsultationInfoModal = true"
                  :title="$t('survey.consultation.information')"
                >
                  <UIcon name="i-lucide-info" class="w-4 h-4" />
                </button>
                <UIcon
                  :name="consultationDataOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                  class="w-4 h-4"
                />
              </div>
            </button>
            <div
              v-show="consultationDataOpen"
              class="border-t border-gray-200 dark:border-gray-700"
            >
              <div class="p-3">
                <SurveyConsultationData
                  :survey-id="surveyId"
                  :show-return-time="showReturnTime"
                />
              </div>
            </div>
          </div>

          <!-- Contract Details Accordion -->
          <div class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <button
              type="button"
              class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
              @click="handleContractDetailsClick"
            >
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-file-check" class="w-4 h-4" />
                <span>{{ $t('survey.consultation.contractDetails') }}</span>
              </div>
              <div class="flex items-center gap-2">
                <!-- Info Button -->
                <button
                  class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                  @click.stop="showContractDetailsInfoModal = true"
                  :title="$t('survey.consultation.information')"
                >
                  <UIcon name="i-lucide-info" class="w-4 h-4" />
                </button>
                <!-- Settings/Gear Button -->
                <button
                  class="p-1.5 text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
                  @click.stop="showFinancingModal = true"
                  :title="$t('survey.consultation.financingSettings')"
                >
                  <UIcon name="i-lucide-settings" class="w-4 h-4" />
                </button>
                <UIcon
                  :name="contractDetailsOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                  class="w-4 h-4"
                />
              </div>
            </button>
            <div
              v-show="contractDetailsOpen"
              class="border-t border-gray-200 dark:border-gray-700"
            >
              <div class="p-3">
                <SurveyContractDetailsCosts
                  v-if="activeScenario"
                  :survey-id="surveyId"
                  :scenario-id="activeScenario.id"
                  :commission-rate="commissionRate"
                />
              </div>
            </div>
          </div>

          <!-- OFP Calculation Accordion - Only for OFP-relevant investments -->
          <div v-if="activeScenario && hasOfpInvestments" class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
            <button
              type="button"
              class="flex items-center justify-between w-full py-2 px-3 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
              @click="ofpCalculationOpen = !ofpCalculationOpen"
            >
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-calculator" class="w-4 h-4" />
                <span>OFP Kalkuláció</span>
              </div>
              <UIcon
                :name="ofpCalculationOpen ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                class="w-4 h-4"
              />
            </button>
            <div
              v-show="ofpCalculationOpen"
              class="border-t border-gray-200 dark:border-gray-700"
            >
              <div class="p-3">
                <!-- OFP Calculation Content -->
                <ScenarioOfpCalculation
                  v-if="activeScenario"
                  :scenario-id="activeScenario.id"
                  :ofp-calculation="currentOfpCalculation"
                  @calculate="handleOfpCalculate"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Reopen Consultation Button - Right Edge -->
    <button
      v-if="!consultationOpen"
      class="fixed right-3 top-1/2 -translate-y-1/2 backdrop-blur-md bg-white/80 dark:bg-gray-800/80 border border-white/20 dark:border-gray-700/20 rounded-full p-3 hover:bg-white/90 dark:hover:bg-gray-700/90 transition-all shadow-lg z-10 flex cursor-pointer"
      @click="handleConsultationToggle(true)"
    >
      <UIcon name="i-lucide-chevron-left" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
    </button>

    <!-- Modals -->
    <SurveyElectricCarsModal
      v-model="showElectricCarsModal"
      :survey-id="surveyId"
      @saved="handleElectricCarsSaved"
    />

    <SurveyHeavyConsumersModal
      v-model="showHeavyConsumersModal"
      :survey-id="surveyId"
      @saved="handleHeavyConsumersSaved"
    />

    <SurveyConsultationInfoModal
      v-model="showConsultationInfoModal"
    />

    <SurveyContractDetailsInfoModal
      v-model="showContractDetailsInfoModal"
    />

    <SurveyFinancingModal
      v-model="showFinancingModal"
      :survey-id="surveyId"
      :scenario-id="activeScenario?.id || null"
      v-model:show-return-time="showReturnTime"
      @commission-changed="handleCommissionChanged"
      @saved="handleFinancingSaved"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeUnmount, computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useSubsidies } from '~/composables/useSubsidies'
import { useOfpCalculation } from '~/composables/useOfpCalculation'
import { useExternalApiKeys } from '~/composables/useExternalApiKeys'
import type { EligibilityConditions } from '~/types/subsidy'

const { t } = useI18n()

interface Props {
  surveyId: string
  systemDesignOpen: boolean
  consultationOpen: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:system-design-open': [value: boolean]
  'update:consultation-open': [value: boolean]
  'ai-scenarios': []
  'new-scenario': []
}>()

const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()
const {
  loadSubsidies,
  loadSurveySubsidies,
  toggleSubsidy,
  updateEligibilityCondition,
  getSubsidiesWithStatus,
  eligibilityConditions,
  loading: subsidiesLoading
} = useSubsidies()
const { calculateOfp, loading: ofpLoading, error: ofpError } = useOfpCalculation()
const { getOfpApiKey, getUserEmail, hasOfpApiKey } = useExternalApiKeys()

// Check if this is an OFP survey
const isOfpSurvey = ref(false)

// Accordion states
const subsidyOpen = ref(false)
const householdDataOpen = ref(false)
const consultationDataOpen = ref(false)
const contractDetailsOpen = ref(false)
const ofpCalculationOpen = ref(false)

// Panel widths - with localStorage persistence
const STORAGE_KEY_SYSTEM_DESIGN = 'surveyConsultation.systemDesignWidth'
const STORAGE_KEY_CONSULTATION = 'surveyConsultation.consultationWidth'
const DEFAULT_WIDTH = 384 // w-96 = 24rem = 384px
const MIN_WIDTH = 300
const MAX_WIDTH = 800

const systemDesignWidth = ref(DEFAULT_WIDTH)
const consultationWidth = ref(DEFAULT_WIDTH)

// Load widths from localStorage on mount
if (process.client) {
  const savedSystemDesignWidth = localStorage.getItem(STORAGE_KEY_SYSTEM_DESIGN)
  const savedConsultationWidth = localStorage.getItem(STORAGE_KEY_CONSULTATION)

  if (savedSystemDesignWidth) {
    systemDesignWidth.value = parseInt(savedSystemDesignWidth)
  }
  if (savedConsultationWidth) {
    consultationWidth.value = parseInt(savedConsultationWidth)
  }
}

// Resize functionality for System Design panel
const startResizeSystemDesign = (e: MouseEvent) => {
  e.preventDefault()
  const startX = e.clientX
  const startWidth = systemDesignWidth.value

  // Set cursor for entire document during resize
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'

  const onMouseMove = (e: MouseEvent) => {
    const delta = e.clientX - startX
    const newWidth = Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, startWidth + delta))
    systemDesignWidth.value = newWidth
  }

  const onMouseUp = () => {
    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)

    // Restore cursor
    document.body.style.cursor = ''
    document.body.style.userSelect = ''

    // Save to localStorage
    if (process.client) {
      localStorage.setItem(STORAGE_KEY_SYSTEM_DESIGN, systemDesignWidth.value.toString())
    }
  }

  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)
}

// Resize functionality for Consultation panel
const startResizeConsultation = (e: MouseEvent) => {
  e.preventDefault()
  const startX = e.clientX
  const startWidth = consultationWidth.value

  // Set cursor for entire document during resize
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'

  const onMouseMove = (e: MouseEvent) => {
    const delta = startX - e.clientX // Reversed for right-side panel
    const newWidth = Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, startWidth + delta))
    consultationWidth.value = newWidth
  }

  const onMouseUp = () => {
    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)

    // Restore cursor
    document.body.style.cursor = ''
    document.body.style.userSelect = ''

    // Save to localStorage
    if (process.client) {
      localStorage.setItem(STORAGE_KEY_CONSULTATION, consultationWidth.value.toString())
    }
  }

  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)
}
const contractDetailsFirstClick = ref(true)

// Key to force remount household data when investments change
const householdDataKey = ref(0)

// Modal states
const showElectricCarsModal = ref(false)
const showHeavyConsumersModal = ref(false)
const showConsultationInfoModal = ref(false)
const showContractDetailsInfoModal = ref(false)
const showFinancingModal = ref(false)

// UI states
const showReturnTime = ref(true)
const commissionRate = ref(0.12) // Default 12%

// Computed
const activeScenario = computed(() => scenariosStore.activeScenario)
const hasScenarios = computed(() => scenariosStore.scenarios.length > 0)

// Get scenario investments
const scenarioInvestments = computed(() => scenariosStore.scenarioInvestments)

// Check if active scenario has Facade Insulation investment
const hasFacadeInsulationInvestment = computed(() => {
  if (!activeScenario.value) return false

  const investmentIds = scenarioInvestments.value[activeScenario.value.id] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'facadeInsulation'
  })
})

// Check if active scenario has Attic Floor Insulation investment
const hasAtticFloorInsulationInvestment = computed(() => {
  if (!activeScenario.value) return false

  const investmentIds = scenarioInvestments.value[activeScenario.value.id] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'roofInsulation'
  })
})

// Check if active scenario has Windows investment
const hasWindowsInvestment = computed(() => {
  if (!activeScenario.value) return false

  const investmentIds = scenarioInvestments.value[activeScenario.value.id] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'windows'
  })
})

// Check if active scenario has Heat Pump investment
const hasHeatPumpInvestment = computed(() => {
  if (!activeScenario.value) return false

  const investmentIds = scenarioInvestments.value[activeScenario.value.id] || []

  return investmentIds.some(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && investment.persist_name === 'heatPump'
  })
})

// Check if active scenario has any OFP-relevant investments
const hasOfpInvestments = computed(() => {
  return hasFacadeInsulationInvestment.value ||
    hasAtticFloorInsulationInvestment.value ||
    hasWindowsInvestment.value ||
    hasHeatPumpInvestment.value
})

// Get current scenario's OFP calculation
const currentOfpCalculation = computed(() => {
  if (!activeScenario.value) return null
  return activeScenario.value.ofp_calculation || null
})

// Realtime subscription ref
const supabase = useSupabaseClient()
let subscription: any = null

// Load scenarios and subsidies on mount
onMounted(async () => {
  // Check if OFP survey
  const { data: survey } = await supabase
    .from('surveys')
    .select('ofp_survey_id')
    .eq('id', props.surveyId)
    .single()

  isOfpSurvey.value = !!(survey?.ofp_survey_id)

  // Load scenarios
  await scenariosStore.loadScenarios(props.surveyId)

  // Load subsidies
  await loadSubsidies()
  await loadSurveySubsidies(props.surveyId)

  // Subscribe to survey_investments changes to refresh household data
  subscription = supabase
    .channel('survey-investments-changes')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'survey_investments',
        filter: `survey_id=eq.${props.surveyId}`
      },
      () => {
        // Force remount household data component
        householdDataKey.value++
      }
    )
    .subscribe()
})

// Cleanup on unmount
onBeforeUnmount(() => {
  if (subscription) {
    subscription.unsubscribe()
  }
})

// Methods
const handleSystemDesignToggle = (isOpen: boolean) => {
  emit('update:system-design-open', isOpen)
}

const handleConsultationToggle = (isOpen: boolean) => {
  emit('update:consultation-open', isOpen)
}

const handleSubsidyToggle = async (subsidyId: string, isEnabled: boolean) => {
  try {
    await toggleSubsidy(props.surveyId, subsidyId, isEnabled)
  } catch (error) {
    console.error('Error toggling subsidy:', error)
    // TODO: Show error toast
  }
}

const handleConditionUpdate = (key: keyof EligibilityConditions, value: boolean) => {
  updateEligibilityCondition(key, value)
}

const handleElectricCarsSaved = () => {
  // TODO: Show success toast or refresh data if needed
}

const handleHeavyConsumersSaved = () => {
  // TODO: Show success toast or refresh data if needed
}

const handleContractDetailsClick = () => {
  // On first click, open financing modal instead of toggling accordion
  if (contractDetailsFirstClick.value) {
    contractDetailsFirstClick.value = false
    showFinancingModal.value = true
  } else {
    contractDetailsOpen.value = !contractDetailsOpen.value
  }
}

const handleFinancingSaved = () => {
  // TODO: Show success toast or refresh data if needed
}

const handleCommissionChanged = (rate: number) => {
  commissionRate.value = rate
}

// Handle OFP calculation
const handleOfpCalculate = async () => {
  if (!activeScenario.value) return

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
  const result = await calculateOfp(activeScenario.value.id, apiKey, userEmail)

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

// Load commission rate when active scenario changes
const loadCommissionRate = async () => {
  if (!activeScenario.value) {
    commissionRate.value = 0.12
    return
  }

  try {
    const { data, error } = await supabase
      .from('scenarios')
      .select('commission_rate')
      .eq('id', activeScenario.value.id)
      .single()

    if (error) throw error

    commissionRate.value = data?.commission_rate || 0.12
  } catch (error) {
    console.error('Error loading commission rate:', error)
    commissionRate.value = 0.12
  }
}

// Watch for active scenario changes
watch(() => activeScenario.value?.id, () => {
  loadCommissionRate()
}, { immediate: true })
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
