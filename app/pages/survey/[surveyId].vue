<template>
  <div class="min-h-screen flex flex-col overflow-hidden">
    <!-- Header -->
    <SurveyHeader
      :active-tab="activeTab"
      :client-name="clientName"
      :show-mode-toggle="activeTab === 'property-assessment'"
      :selected-investments="selectedInvestments"
      :scenarios="scenarios"
      :active-scenario-id="activeScenario?.id"
      :scenario-investments="scenarioInvestments"
      :contract-mode="contractMode"
      :contracts="contracts"
      :active-contract-id="activeContract?.id"
      :contract-investments="contractInvestments"
      :summary-view-mode="summaryViewMode"
      :hide-investment-controls="isMeasureRoute"
      @back="handleBack"
      @toggle-investment="handleToggleInvestment"
      @edit-client="handleEditClient"
      @toggle-view-mode="handleToggleViewMode"
      @toggle-investment-filter="handleToggleInvestmentFilter"
      @toggle-visualization="handleToggleVisualization"
      @select-scenario="handleSelectScenario"
      @change-contract-mode="handleContractModeChange"
      @select-contract="handleSelectContract"
      @change-summary-view-mode="handleChangeSummaryViewMode"
    />

    <!-- Navigation Tabs (hidden when in marker mode/measure route) -->
    <SurveyNavigation
      v-if="!isMeasureRoute"
      v-model="activeTab"
      :tabs="tabs"
    />

    <!-- Main Content Area -->
    <div class="flex-1">
      <!-- Render nested /measure pages inside the dark content area -->
      <NuxtPage v-if="isMeasureRoute" />

      <!-- Otherwise render the survey tabs content -->
      <template v-else>
        <!-- Property Assessment Tab -->
        <SurveyPropertyAssessment
          v-if="activeTab === 'property-assessment'"
          :survey-id="surveyId"
          :view-mode="viewMode"
          :investment-filter="investmentFilter"
          :show-visualization="showVisualization"
          :page-display-mode="pageDisplayMode"
          v-model:show-investment-modal="showInvestmentModal"
          @toggle-list-view="handleToggleListView"
          @set-display-mode="handleSetDisplayMode"
          @open-photo-upload="handleOpenPhotoUpload"
          @open-camera="handleOpenCamera"
        />

        <!-- Consultation Tab -->
        <SurveyConsultation
          v-else-if="activeTab === 'consultation'"
          :survey-id="surveyId"
          :system-design-open="consultationSystemDesignOpen"
          :consultation-open="consultationPanelOpen"
          @update:system-design-open="(value) => handleConsultationPanelToggle('systemDesign', value)"
          @update:consultation-open="(value) => handleConsultationPanelToggle('consultation', value)"
        />

        <!-- Offer/Contract Tab -->
        <SurveyOfferContract
          v-else-if="activeTab === 'offer-contract'"
          ref="offerContractRef"
          :survey-id="surveyId"
          :contract-mode="contractMode"
        />

        <!-- Contract Data Tab -->
        <SurveyContractData
          v-else-if="activeTab === 'contract-data'"
          :survey-id="surveyId"
          :client-data="clientData"
        />

        <!-- Summary Tab -->
        <SurveySummary
          v-else-if="activeTab === 'summary'"
          :survey-id="surveyId"
          :client-data="clientData"
          :view-mode="summaryViewMode"
          @save-without-send="handleSaveWithoutSend"
          @save-and-send="handleSaveAndSendSingle"
          @sign-now="handleSignNowSingle"
        />
      </template>
    </div>

    <!-- Footer (hidden in marker mode) -->
    <SurveyFooter
      v-if="!isMeasureRoute"
      :active-tab="activeTab"
      :show-property-actions="activeTab === 'property-assessment'"
      :missing-items-count="missingItemsCount"
      :can-proceed="canProceed"
      :active-contract="activeContract"
      :can-save-contract="canSaveContract"
      :contract-count="contracts.length"
      :show-scenario-footer="scenarioFooterVisible"
      @save-exit="handleSaveExit"
      @upload-photos="handleUploadPhotos"
      @fill-all-data="handleFillAllData"
      @generate-assessment="handleGenerateAssessment"
      @show-missing-items="handleShowMissingItems"
      @toggle-scenario-footer="handleToggleScenarioFooter"
      @rename-contract="handleRenameContract"
      @duplicate-contract="handleDuplicateContract"
      @delete-contract="handleDeleteContract"
      @save-investment-contract="handleSaveInvestmentContract"
      @modify-contract="handleModifyContract"
      @save-all-and-send="handleSaveAllAndSend"
      @sign-all-contracts="handleSignAllContracts"
      @next="handleNext"
    >
      <!-- Scenario Footer Content -->
      <template #scenario-footer>
        <div class="flex items-center gap-3">
          <!-- AI Scenarios & New Scenario buttons -->
          <div class="flex items-center gap-2">
            <UIButtonEnhanced
              variant="primary"
              size="sm"
              @click="handleAIScenarios"
              class="whitespace-nowrap"
            >
              <Icon name="i-lucide-zap" class="w-4 h-4 mr-2" />
              {{ t('survey.footer.aiScenarios') }}
            </UIButtonEnhanced>

            <UIButtonEnhanced
              variant="outline"
              size="sm"
              @click="handleNewScenario"
              class="whitespace-nowrap"
            >
              <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
              {{ t('survey.footer.newScenario') }}
            </UIButtonEnhanced>
          </div>

          <!-- Scenario List Dropdown with Management -->
          <div v-if="scenarios.length > 0" class="relative">
            <button
              @click="scenarioDropdownOpen = !scenarioDropdownOpen"
              class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
            >
              <span class="text-sm font-medium text-gray-900 dark:text-white">
                {{ activeScenario?.name || t('survey.header.selectScenario') }}
              </span>
              <Icon name="i-lucide-chevron-down" class="w-4 h-4 text-gray-600 dark:text-gray-400" />
            </button>

            <!-- Dropdown Menu -->
            <Transition name="fade">
              <div
                v-if="scenarioDropdownOpen"
                class="absolute bottom-full mb-2 right-0 w-64 backdrop-blur-md bg-white/95 dark:bg-gray-800/95 rounded-2xl border border-white/20 dark:border-gray-700/20 shadow-2xl overflow-hidden"
              >
                <div class="max-h-64 overflow-y-auto">
                  <button
                    v-for="scenario in scenarios"
                    :key="scenario.id"
                    @click="handleSelectScenario(scenario.id); scenarioDropdownOpen = false"
                    class="w-full px-4 py-3 text-left hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors border-b border-gray-200 dark:border-gray-700 last:border-0"
                    :class="{ 'bg-primary-50 dark:bg-primary-900/20': scenario.id === activeScenario?.id }"
                  >
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-900 dark:text-white">
                        {{ scenario.name }}
                      </span>
                      <Icon
                        v-if="scenario.id === activeScenario?.id"
                        name="i-lucide-check"
                        class="w-4 h-4 text-primary-600 dark:text-primary-400"
                      />
                    </div>
                  </button>
                </div>
              </div>
            </Transition>
          </div>

          <!-- Active Scenario Management Buttons -->
          <div v-if="activeScenario" class="flex items-center gap-2 pl-3 border-l border-gray-300 dark:border-gray-600">
            <UIButtonEnhanced
              size="xs"
              variant="outline"
              @click="handleRenameScenario"
              class="whitespace-nowrap"
            >
              {{ t('survey.footer.rename') }}
            </UIButtonEnhanced>
            <UIButtonEnhanced
              size="xs"
              variant="outline"
              @click="handleDuplicateScenario"
              class="whitespace-nowrap"
            >
              {{ t('survey.footer.duplicate') }}
            </UIButtonEnhanced>
            <UIButtonEnhanced
              size="xs"
              variant="outline"
              @click="handleDeleteScenario"
              class="text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 whitespace-nowrap"
            >
              {{ t('survey.footer.delete') }}
            </UIButtonEnhanced>
          </div>
        </div>
      </template>
    </SurveyFooter>

    <!-- Floating Button Isle - Bottom Right (Only on property-assessment tab) -->
    <div
      v-if="activeTab === 'property-assessment'"
      class="mode-selector-container fixed bottom-3 right-3 flex flex-col items-end gap-3 z-50"
    >
      <!-- Mode Options - Animated popup above button -->
      <Transition
        enter-active-class="transition-all duration-300 ease-out"
        enter-from-class="opacity-0 translate-y-2"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition-all duration-200 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 translate-y-2"
      >
        <div
          v-if="showModeOptions"
          class="flex flex-col gap-2"
        >
          <button
            @click="selectMode('graphic')"
            class="px-4 py-2 rounded-full shadow-lg transition-all duration-200 flex items-center gap-2 whitespace-nowrap"
            :class="displayMode === 'graphic'
              ? 'bg-primary-500 text-white'
              : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'"
          >
            <Icon name="i-lucide-image" class="w-4 h-4" />
            <span class="text-sm font-medium">{{ t('survey.header.graphicMode') }}</span>
          </button>
          <button
            @click="selectMode('marker')"
            class="px-4 py-2 rounded-full shadow-lg transition-all duration-200 flex items-center gap-2 whitespace-nowrap"
            :class="displayMode === 'marker'
              ? 'bg-primary-500 text-white'
              : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'"
          >
            <Icon name="i-lucide-pencil-ruler" class="w-4 h-4" />
            <span class="text-sm font-medium">{{ t('survey.header.markerMode') }}</span>
          </button>
        </div>
      </Transition>

      <!-- Bottom row of floating buttons -->
      <div class="flex items-center gap-3">
        <!-- Mode Selector Button -->
        <button
          @click="toggleModeOptions"
          class="w-12 h-12 rounded-full bg-primary-500 hover:bg-primary-600 text-white shadow-lg hover:shadow-xl transition-all duration-200 flex items-center justify-center group"
        >
          <Icon
            :name="displayMode === 'graphic' ? 'i-lucide-image' : 'i-lucide-pencil-ruler'"
            class="w-6 h-6"
          />
        </button>

        <!-- Missing Items Button -->
        <button
          v-if="missingItemsCount > 0"
          class="w-12 h-12 rounded-full bg-orange-500 hover:bg-orange-600 text-white shadow-lg hover:shadow-xl transition-all duration-200 flex items-center justify-center group"
          @click="handleShowMissingItems"
        >
          <div class="relative">
            <Icon name="i-lucide-alert-triangle" class="w-6 h-6" />
            <span class="absolute -top-3 -right-3 bg-white text-orange-500 text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
              {{ missingItemsCount }}
            </span>
          </div>
        </button>
      </div>
    </div>

    <!-- Fotó feltöltési felugró ablak -->
    <SurveyPhotoUploadModal
      v-model="showPhotoUploadModal"
      :survey-id="surveyId"
      :mode="photoUploadMode"
      :category-id="photoUploadCategoryId"
      :investment-id="photoUploadInvestmentId"
    />

    <!-- Hiányzó elemek felugró ablak -->
    <SurveyMissingItemsModal
      v-model="showMissingItemsModal"
      :survey-id="surveyId"
      @open-photo-upload="handleOpenPhotoUploadFromMissing"
      @open-survey-page="handleOpenSurveyPageFromMissing"
    />

    <!-- Select Investments Modal -->
    <SurveySelectInvestmentsModal
      v-model="showSelectInvestmentsModal"
      :survey-id="surveyId"
      :selected-investments="selectedInvestments"
      :mode="selectInvestmentsModalMode"
      @create-scenarios="handleCreateScenarios"
      @create-manual-scenario="handleCreateManualScenario"
    />

    <!-- Rename Scenario Modal -->
    <SurveyRenameScenarioModal
      v-model="showRenameScenarioModal"
      :scenario-name="activeScenario?.name || ''"
      @rename="handleRenameComplete"
    />

    <!-- Rename Contract Modal -->
    <SurveyRenameContractModal
      v-model="showRenameContractModal"
      :contract-name="activeContract?.name || ''"
      @rename="handleRenameContractComplete"
    />

    <!-- Send Contract Modal (Single) -->
    <SurveySendContractModal
      v-if="selectedContractForSend"
      v-model="showSendContractModal"
      :contract="selectedContractForSend"
      :contract-investments="contractInvestments[selectedContractForSend.id] || []"
      :contract-components="contractsStore.contractMainComponents[selectedContractForSend.id] || []"
      :contract-extra-costs="contractsStore.contractExtraCosts[selectedContractForSend.id] || []"
      :contract-discounts="contractsStore.contractDiscounts[selectedContractForSend.id] || []"
      :investments="investmentsStore.availableInvestments"
      :main-components="scenariosStore.mainComponents"
      :client-data="clientData"
      @send="handleSendContractEmail"
    />

    <!-- Sign Contract Modal (Single) -->
    <SurveySignContractModal
      v-if="selectedContractForSign"
      v-model="showSignContractModal"
      :contract="selectedContractForSign"
      :contract-investments="contractInvestments[selectedContractForSign.id] || []"
      :contract-components="contractsStore.contractMainComponents[selectedContractForSign.id] || []"
      :contract-extra-costs="contractsStore.contractExtraCosts[selectedContractForSign.id] || []"
      :contract-discounts="contractsStore.contractDiscounts[selectedContractForSign.id] || []"
      :investments="investmentsStore.availableInvestments"
      :main-components="scenariosStore.mainComponents"
      :client-data="clientData"
      @sign="handleSignContract"
    />

    <!-- Send All Contracts Modal -->
    <SurveySendAllContractsModal
      v-model="showSendAllContractsModal"
      :contracts="contracts"
      :contract-investments="contractInvestments"
      :contract-components="contractsStore.contractMainComponents"
      :contract-extra-costs="contractsStore.contractExtraCosts"
      :contract-discounts="contractsStore.contractDiscounts"
      :investments="investmentsStore.availableInvestments"
      :main-components="scenariosStore.mainComponents"
      :client-data="clientData"
      @send="handleSendAllContractsEmail"
    />

    <!-- Sign All Contracts Modal -->
    <SurveySignAllContractsModal
      v-model="showSignAllContractsModal"
      :contracts="contracts"
      :contract-investments="contractInvestments"
      :contract-components="contractsStore.contractMainComponents"
      :contract-extra-costs="contractsStore.contractExtraCosts"
      :contract-discounts="contractsStore.contractDiscounts"
      :investments="investmentsStore.availableInvestments"
      :main-components="scenariosStore.mainComponents"
      :client-data="clientData"
      @sign="handleSignAllContractsComplete"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useScenariosStore } from '~/stores/scenarios'
import { useContractsStore } from '~/stores/contracts'

const { t } = useI18n()

const route = useRoute()
const router = useRouter()
const investmentsStore = useSurveyInvestmentsStore()
const scenariosStore = useScenariosStore()
const contractsStore = useContractsStore()

// Ref to SurveyOfferContract component
const offerContractRef = ref<any>(null)

// Show nested measure pages inside the dark content area
const isMeasureRoute = computed(() => route.path.includes('/measure'))

// Get survey ID from route
const surveyId = computed(() => route.params.surveyId as string)

// Get selected investments for header
const selectedInvestments = computed(() => investmentsStore.selectedInvestments)

// Get scenarios for header
const scenarios = computed(() => scenariosStore.scenarios)
const activeScenario = computed(() => scenariosStore.activeScenario)
const scenarioInvestments = computed(() => scenariosStore.scenarioInvestments)

// Get contracts for header
const contracts = computed(() => contractsStore.contracts)
const activeContract = computed(() => contractsStore.activeContract)
const contractInvestments = computed(() => contractsStore.contractInvestments)

// Active tab state
const activeTab = ref<'property-assessment' | 'consultation' | 'offer-contract' | 'contract-data' | 'summary'>('property-assessment')

// Contract mode state (null = not set, 'offer' = Offer mode, 'contract' = Contract mode)
const contractMode = ref<'offer' | 'contract' | null>(null)

// Summary view mode state
const summaryViewMode = ref<'list' | 'card'>('list')

// Check if there are any saved contracts
const hasContracts = computed(() => contracts.value.length > 0)

// Tab configuration with dynamic status
const tabs = computed(() => {
  // Determine tab 3 and 4 labels based on contractMode
  let tab3Label = t('survey.tabs.offerContract')
  let tab4Label = t('survey.tabs.contractData')

  if (contractMode.value === 'offer') {
    tab3Label = t('survey.labels.offer')
    tab4Label = t('survey.labels.offerData')
  } else if (contractMode.value === 'contract') {
    tab3Label = t('survey.labels.contract')
    tab4Label = t('survey.labels.contractData')
  }

  return [
    {
      id: 'property-assessment',
      label: t('survey.tabs.propertyAssessment'),
      number: 1,
      status: missingItemsCount.value === 0 ? 'completed' as const : 'warning' as const
    },
    { id: 'consultation', label: t('survey.tabs.consultation'), number: 2 },
    { id: 'offer-contract', label: tab3Label, number: 3 },
    { id: 'contract-data', label: tab4Label, number: 4, disabled: !hasContracts.value },
    { id: 'summary', label: t('survey.tabs.summary'), number: 5, disabled: !hasContracts.value }
  ]
})

// Survey data
const clientName = ref(t('survey.page.loading'))
const clientData = ref<any>(null)

// Can proceed logic per tab
const canProceed = computed(() => {
  switch (activeTab.value) {
    case 'property-assessment':
      return true
    case 'consultation':
      return true
    case 'offer-contract':
      return hasContracts.value
    case 'contract-data':
      return true
    case 'summary':
      return missingItemsCount.value === 0
    default:
      return true
  }
})

// Calculate missing items count dynamically
const missingItemsCount = computed(() => {
  let count = 0

  // Count missing photo categories
  investmentsStore.selectedInvestments.forEach(investment => {
    const categories = investmentsStore.documentCategories[investment.id] || []
    categories.forEach(category => {
      // Get actual uploaded photo count from store
      const uploadedCount = investmentsStore.getCategoryPhotoCount(category.id)
      if (uploadedCount < category.min_photos) {
        count++
      }
    })
  })

  // Count unanswered required questions
  investmentsStore.selectedInvestments.forEach(investment => {
    const pages = investmentsStore.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = investmentsStore.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          const response = investmentsStore.getResponse(question.name)
          if (!response || response === '' || response === null || response === undefined) {
            count++
          }
        }
      })
    })
  })

  return count
})

// Filter states
const viewMode = ref<'photos' | 'data' | 'all'>('all')
const investmentFilter = ref<string>('all')
const showVisualization = ref<boolean>(true)

// Display mode - graphic or marker
const displayMode = ref<'graphic' | 'marker'>('graphic')

// Mode options popup state
const showModeOptions = ref(false)

// Close mode options when clicking outside
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (showModeOptions.value && !target.closest('.mode-selector-container')) {
    showModeOptions.value = false
  }
}

// Watch displayMode changes and trigger marker mode toggle
watch(displayMode, (newMode) => {
  handleToggleMarkerMode(newMode === 'marker')
})

// Add click outside listener when mode options are shown
watch(showModeOptions, (isOpen) => {
  if (isOpen) {
    document.addEventListener('click', handleClickOutside)
  } else {
    document.removeEventListener('click', handleClickOutside)
  }
})

// Sync displayMode with route
watch(isMeasureRoute, (isMeasure) => {
  displayMode.value = isMeasure ? 'marker' : 'graphic'
}, { immediate: true })

// Page display mode - 'single' | 'investment' | 'all'
const pageDisplayMode = ref<'single' | 'investment' | 'all'>('single')

// Felugró ablakok állapota
const showInvestmentModal = ref(false)
const showMissingItemsModal = ref(false)
const showSelectInvestmentsModal = ref(false)
const showRenameScenarioModal = ref(false)
const showRenameContractModal = ref(false)
const selectInvestmentsModalMode = ref<'ai' | 'manual'>('ai')

// Summary modals
const showSendContractModal = ref(false)
const showSignContractModal = ref(false)
const showSendAllContractsModal = ref(false)
const showSignAllContractsModal = ref(false)
const selectedContractForSend = ref<any>(null)
const selectedContractForSign = ref<any>(null)

// Photo upload modal states
const showPhotoUploadModal = ref(false)
const photoUploadMode = ref<'single' | 'investment' | 'all'>('single')
const photoUploadCategoryId = ref<string | undefined>()
const photoUploadInvestmentId = ref<string | undefined>()

// Consultation panel states
const consultationSystemDesignOpen = ref(true)
const consultationPanelOpen = ref(false)
const scenarioFooterVisible = ref(false)
const scenarioDropdownOpen = ref(false)

// Check if we can save contract (scenario must be selected in offer contract tab)
const canSaveContract = computed(() => {
  // This will be checked in the SurveyOfferContract component
  // We just need to show the button when on the offer-contract tab
  return activeTab.value === 'offer-contract'
})

// Use optimized survey data loading
const { loadSurveyWithRelations, refreshSurveyData } = useSurveyData()

// Load survey data
onMounted(async () => {
  await loadSurveyData()
  // Load all survey-related data with a single optimized query
  await loadSurveyWithRelations(surveyId.value)
})

// Cleanup event listeners
onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})

const loadSurveyData = async () => {
  const supabase = useSupabaseClient()

  try {
    const { data: survey, error } = await supabase
      .from('surveys')
      .select(`
        *,
        client:clients (
          id,
          name,
          email,
          phone,
          postal_code,
          city,
          street,
          house_number
        )
      `)
      .eq('id', surveyId.value)
      .single()

    if (error) throw error

    if (survey && survey.client) {
      clientName.value = survey.client.name
      clientData.value = survey.client

      // Load consultation panel states
      if (survey.consultation_system_design_open !== null && survey.consultation_system_design_open !== undefined) {
        consultationSystemDesignOpen.value = survey.consultation_system_design_open
      }
      if (survey.consultation_panel_open !== null && survey.consultation_panel_open !== undefined) {
        consultationPanelOpen.value = survey.consultation_panel_open
      }

      // Set first_opened_at if not already set
      if (!survey.first_opened_at) {
        const { error: updateError } = await supabase
          .from('surveys')
          .update({ first_opened_at: new Date().toISOString() })
          .eq('id', surveyId.value)

        if (updateError) {
          console.error('Error setting first_opened_at:', updateError)
        }
      }
    } else {
      clientName.value = t('survey.page.unknownClient')
      clientData.value = null
    }

  } catch (error) {
    console.error('Error loading survey data:', error)
    clientName.value = t('survey.page.errorLoading')
    // TODO: Show error toast and redirect
  }
}

// Header handlers
const handleBack = () => {
  router.push('/survey')
}

const handleToggleInvestment = () => {
  showInvestmentModal.value = true
}

const handleEditClient = () => {
  router.push(`/survey/client-data?surveyId=${surveyId.value}`)
}

const handleToggleViewMode = (mode: 'photos' | 'data' | 'all') => {
  viewMode.value = mode
  console.log('Toggle view mode:', mode)
}

const handleToggleInvestmentFilter = (investmentId: string) => {
  investmentFilter.value = investmentId
  console.log('Toggle investment filter:', investmentId)
}

const handleToggleVisualization = (show: boolean) => {
  showVisualization.value = show
  console.log('Toggle visualization:', show)
}

const handleContractModeChange = (mode: 'offer' | 'contract' | null) => {
  contractMode.value = mode
  console.log('Contract mode changed:', mode)
}

const handleChangeSummaryViewMode = (mode: 'list' | 'card') => {
  summaryViewMode.value = mode
}

// Footer handlers
const handleSaveExit = () => {
  console.log('Save and exit')
  router.push('/survey')
}

const handleUploadPhotos = () => {
  photoUploadMode.value = 'all'
  photoUploadCategoryId.value = undefined
  photoUploadInvestmentId.value = undefined
  showPhotoUploadModal.value = true
}

const handleFillAllData = () => {
  pageDisplayMode.value = 'all'
  console.log('Fill all data - switched to all mode')
}

const handleToggleListView = () => {
  if (pageDisplayMode.value === 'investment') {
    pageDisplayMode.value = 'single'
  } else {
    pageDisplayMode.value = 'investment'
  }
  console.log('Toggle list view:', pageDisplayMode.value)
}

const handleSetDisplayMode = (mode: 'single' | 'investment' | 'all') => {
  pageDisplayMode.value = mode
  console.log('Set display mode:', mode)
}

const handleGenerateAssessment = () => {
  console.log('Generate assessment sheet')
}

const handleToggleMarkerMode = (enabled: boolean) => {
  const id = surveyId.value
  if (!id) return
  if (enabled) {
    // ON → jump into measure if not already there
    if (!isMeasureRoute.value) router.push(`/survey/${id}/measure`)
  } else {
    // OFF → leave measure if currently there
    if (isMeasureRoute.value) router.push(`/survey/${id}`)
  }
}

const toggleModeOptions = () => {
  showModeOptions.value = !showModeOptions.value
}

const selectMode = (mode: 'graphic' | 'marker') => {
  displayMode.value = mode
  showModeOptions.value = false
}

const handleShowMissingItems = () => {
  showMissingItemsModal.value = true
}

const handleOpenPhotoUploadFromMissing = (categoryId: string, investmentId: string) => {
  photoUploadMode.value = 'single'
  photoUploadCategoryId.value = categoryId
  photoUploadInvestmentId.value = investmentId
  showPhotoUploadModal.value = true
}

const handleOpenSurveyPageFromMissing = (pageId: string) => {
  // Állítsuk be az aktív page-et (az aktuális display mode marad)
  investmentsStore.setActivePage(pageId)
}

const handleOpenPhotoUpload = (categoryId: string, investmentId: string) => {
  photoUploadMode.value = 'single'
  photoUploadCategoryId.value = categoryId
  photoUploadInvestmentId.value = investmentId
  showPhotoUploadModal.value = true
}

const handleOpenCamera = (investmentId: string) => {
  photoUploadMode.value = 'investment'
  photoUploadCategoryId.value = undefined
  photoUploadInvestmentId.value = investmentId
  showPhotoUploadModal.value = true
}

const handleNext = () => {
  const currentIndex = tabs.value.findIndex(tab => tab.id === activeTab.value)
  if (currentIndex < tabs.value.length - 1) {
    const nextTab = tabs.value[currentIndex + 1]
    // Skip disabled tabs
    if (!nextTab.disabled) {
      activeTab.value = nextTab.id as any
    }
  }
}

// Consultation handlers
const handleSelectScenario = (scenarioId: string) => {
  scenariosStore.setActiveScenario(scenarioId)
}

const handleAIScenarios = () => {
  selectInvestmentsModalMode.value = 'ai'
  showSelectInvestmentsModal.value = true
}

const handleNewScenario = () => {
  selectInvestmentsModalMode.value = 'manual'
  showSelectInvestmentsModal.value = true
}

const handleRenameScenario = () => {
  showRenameScenarioModal.value = true
}

const handleDuplicateScenario = async () => {
  if (!activeScenario.value) return

  try {
    const supabase = useSupabaseClient()

    // Get the highest sequence number
    const maxSequence = Math.max(...scenarios.value.map(s => s.sequence || 0))

    // Create duplicate scenario
    const { data: newScenario, error: scenarioError } = await supabase
      .from('scenarios')
      .insert({
        survey_id: surveyId.value,
        name: `${activeScenario.value.name} (Copy)`,
        sequence: maxSequence + 1,
        description: activeScenario.value.description
      })
      .select()
      .single()

    if (scenarioError) throw scenarioError

    // Copy scenario investments
    const investmentIds = scenarioInvestments.value[activeScenario.value.id] || []
    if (investmentIds.length > 0) {
      const { error: invError } = await supabase
        .from('scenario_investments')
        .insert(
          investmentIds.map(invId => ({
            scenario_id: newScenario.id,
            investment_id: invId
          }))
        )

      if (invError) throw invError
    }

    // Copy scenario components
    const components = scenariosStore.scenarioComponents[activeScenario.value.id] || []
    if (components.length > 0) {
      const { error: compError } = await supabase
        .from('scenario_main_components')
        .insert(
          components.map(c => ({
            scenario_id: newScenario.id,
            main_component_id: c.main_component_id,
            quantity: c.quantity,
            price_snapshot: c.price_snapshot
          }))
        )

      if (compError) throw compError
    }

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)
    // Set the new scenario as active
    scenariosStore.setActiveScenario(newScenario.id)

    // TODO: Show success message
  } catch (error) {
    console.error('Error duplicating scenario:', error)
    // TODO: Show error message
  }
}

const handleDeleteScenario = async () => {
  if (!activeScenario.value) return

  // TODO: Add confirmation dialog
  if (!confirm(t('survey.scenarios.deleteConfirm'))) {
    return
  }

  try {
    const supabase = useSupabaseClient()

    const { error } = await supabase
      .from('scenarios')
      .delete()
      .eq('id', activeScenario.value.id)

    if (error) throw error

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)

    // Set first scenario as active if any scenarios remain
    if (scenarios.value.length > 0) {
      scenariosStore.setActiveScenario(scenarios.value[0].id)
    }

    // TODO: Show success message
  } catch (error) {
    console.error('Error deleting scenario:', error)
    // TODO: Show error message
  }
}

const handleCreateScenarios = async (investmentIds: string[]) => {
  try {
    const { createAIScenarios } = useScenarioCreation()
    const result = await createAIScenarios(surveyId.value, investmentIds)

    if (result.success) {
      console.log('Scenarios created successfully:', result.scenarios)
      // Close modal
      showSelectInvestmentsModal.value = false
      // Refresh all survey data
      await refreshSurveyData(surveyId.value)
      // TODO: Show success message
    } else {
      console.error('Failed to create scenarios:', result.error)
      // TODO: Show error message to user
    }
  } catch (error) {
    console.error('Error in handleCreateScenarios:', error)
  }
}

const handleCreateManualScenario = async (investmentIds: string[]) => {
  try {
    const supabase = useSupabaseClient()

    // Get the highest sequence number
    const maxSequence = Math.max(...scenarios.value.map(s => s.sequence || 0), 0)

    // Create empty scenario
    const { data: newScenario, error: scenarioError } = await supabase
      .from('scenarios')
      .insert({
        survey_id: surveyId.value,
        name: `Scenario ${maxSequence + 1}`,
        sequence: maxSequence + 1,
        description: null
      })
      .select()
      .single()

    if (scenarioError) throw scenarioError

    // Add scenario investments (but no main components)
    if (investmentIds.length > 0) {
      const { error: invError } = await supabase
        .from('scenario_investments')
        .insert(
          investmentIds.map(invId => ({
            scenario_id: newScenario.id,
            investment_id: invId
          }))
        )

      if (invError) throw invError
    }

    // Close modal
    showSelectInvestmentsModal.value = false

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)

    // Set the new scenario as active
    scenariosStore.setActiveScenario(newScenario.id)

    // TODO: Show success message
  } catch (error) {
    console.error('Error creating manual scenario:', error)
    // TODO: Show error message
  }
}

const handleRenameComplete = async (newName: string) => {
  if (!activeScenario.value) return

  try {
    const supabase = useSupabaseClient()

    const { error } = await supabase
      .from('scenarios')
      .update({ name: newName })
      .eq('id', activeScenario.value.id)

    if (error) throw error

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)
    showRenameScenarioModal.value = false

    // TODO: Show success message
  } catch (error) {
    console.error('Error renaming scenario:', error)
    // TODO: Show error message
  }
}

const handleToggleScenarioFooter = () => {
  scenarioFooterVisible.value = !scenarioFooterVisible.value
}

const handleConsultationPanelToggle = async (panelName: 'systemDesign' | 'consultation', isOpen: boolean) => {
  const supabase = useSupabaseClient()

  try {
    const updateData: any = {}

    if (panelName === 'systemDesign') {
      consultationSystemDesignOpen.value = isOpen
      updateData.consultation_system_design_open = isOpen
    } else if (panelName === 'consultation') {
      consultationPanelOpen.value = isOpen
      updateData.consultation_panel_open = isOpen
    }

    const { error } = await supabase
      .from('surveys')
      .update(updateData)
      .eq('id', surveyId.value)

    if (error) {
      console.error('Error updating consultation panel state:', error)
    }
  } catch (error) {
    console.error('Error saving consultation panel state:', error)
  }
}

// Contract handlers
const handleSelectContract = (contractId: string) => {
  contractsStore.setActiveContract(contractId)
}

const handleSaveInvestmentContract = async () => {
  if (offerContractRef.value) {
    await offerContractRef.value.handleSaveContract()
    // Refresh all survey data after saving contract
    await refreshSurveyData(surveyId.value)
  }
}

const handleModifyContract = async () => {
  if (offerContractRef.value) {
    await offerContractRef.value.handleModifyContract()
    // Refresh all survey data after modifying contract
    await refreshSurveyData(surveyId.value)
  }
}

const handleRenameContract = () => {
  showRenameContractModal.value = true
}

const handleRenameContractComplete = async (newName: string) => {
  if (!activeContract.value) return

  try {
    await contractsStore.renameContract(activeContract.value.id, newName)
    // Refresh all survey data
    await refreshSurveyData(surveyId.value)
    showRenameContractModal.value = false

    // TODO: Show success message
  } catch (error) {
    console.error('Error renaming contract:', error)
    // TODO: Show error message
  }
}

const handleDuplicateContract = async () => {
  if (!activeContract.value) return

  try {
    const newContractId = await contractsStore.duplicateContract(activeContract.value.id)

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)

    // Set the new contract as active
    if (newContractId) {
      contractsStore.setActiveContract(newContractId)
    }

    // TODO: Show success message
  } catch (error) {
    console.error('Error duplicating contract:', error)
    // TODO: Show error message
  }
}

const handleDeleteContract = async () => {
  if (!activeContract.value) return

  // TODO: Add confirmation dialog
  if (!confirm(t('survey.contracts.deleteConfirm'))) {
    return
  }

  try {
    await contractsStore.deleteContract(activeContract.value.id)

    // Refresh all survey data
    await refreshSurveyData(surveyId.value)

    // Set first contract as active if any contracts remain
    if (contracts.value.length > 0) {
      contractsStore.setActiveContract(contracts.value[0].id)
    }

    // TODO: Show success message
  } catch (error) {
    console.error('Error deleting contract:', error)
    // TODO: Show error message
  }
}

// Summary handlers
const handleSaveWithoutSend = (contractId: string) => {
  console.log('Save without send:', contractId)
  // TODO: Implement - Auto-save contract data
}

const handleSaveAndSendSingle = (contractId: string) => {
  const contract = contracts.value.find(c => c.id === contractId)
  if (contract) {
    selectedContractForSend.value = contract
    showSendContractModal.value = true
  }
}

const handleSignNowSingle = (contractId: string) => {
  const contract = contracts.value.find(c => c.id === contractId)
  if (contract) {
    selectedContractForSign.value = contract
    showSignContractModal.value = true
  }
}

const handleSendContractEmail = async (emailTemplate: string) => {
  if (!selectedContractForSend.value) return

  try {
    // Mark contract as sent (sets first_sent_at if not already set)
    await contractsStore.markContractAsSent(selectedContractForSend.value.id)

    console.log('Send contract email:', selectedContractForSend.value.id, emailTemplate)
    // TODO: Implement - Send email with contract
  } catch (error) {
    console.error('Error sending contract:', error)
    // TODO: Show error message
  }
}

const handleSignContract = async (data: any) => {
  if (!selectedContractForSign.value) return

  try {
    // Mark contract as sent (sets first_sent_at if not already set)
    await contractsStore.markContractAsSent(selectedContractForSign.value.id)

    // Mark contract as signed (sets first_signed_at if not already set)
    await contractsStore.markContractAsSigned(selectedContractForSign.value.id)

    console.log('Sign contract:', selectedContractForSign.value.id, data)
    // TODO: Implement - Save signature and update contract status
  } catch (error) {
    console.error('Error signing contract:', error)
    // TODO: Show error message
  }
}

const handleSaveAllAndSend = () => {
  showSendAllContractsModal.value = true
}

const handleSendAllContractsEmail = (emailTemplate: string) => {
  console.log('Send all contracts email:', emailTemplate)
  // TODO: Implement - Send email with all contracts
}

const handleSignAllContracts = () => {
  showSignAllContractsModal.value = true
}

const handleSignAllContractsComplete = (data: any) => {
  console.log('Sign all contracts:', data)
  // TODO: Implement - Save all signatures and update contract statuses
}

definePageMeta({
  layout: 'fullwidth'
})

// Watch for contract count changes and redirect if necessary
watch(() => hasContracts.value, (hasContracts) => {
  // If no contracts exist and we're on a disabled tab, redirect to offer-contract
  if (!hasContracts && (activeTab.value === 'contract-data' || activeTab.value === 'summary')) {
    activeTab.value = 'offer-contract'
  }
})
</script>
