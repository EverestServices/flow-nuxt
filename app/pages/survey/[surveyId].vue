<template>
  <div class="h-screen flex flex-col overflow-hidden">
    <!-- Header -->
    <SurveyHeader
      :active-tab="activeTab"
      :client-name="clientName"
      :show-mode-toggle="activeTab === 'property-assessment'"
      :selected-investments="selectedInvestments"
      @back="handleBack"
      @toggle-investment="handleToggleInvestment"
      @edit-client="handleEditClient"
      @toggle-view-mode="handleToggleViewMode"
      @toggle-investment-filter="handleToggleInvestmentFilter"
      @toggle-visualization="handleToggleVisualization"
    />

    <!-- Navigation Tabs -->
    <SurveyNavigation
      v-model="activeTab"
      :tabs="tabs"
    />

    <!-- Main Content Area -->
    <div class="flex-1 overflow-hidden bg-gray-50 dark:bg-gray-900">
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
      <div v-else-if="activeTab === 'consultation'" class="h-full flex items-center justify-center">
        <p class="text-gray-500">Consultation Tab - Under Development</p>
      </div>

      <!-- Offer/Contract Tab -->
      <div v-else-if="activeTab === 'offer-contract'" class="h-full flex items-center justify-center">
        <p class="text-gray-500">Offer/Contract Tab - Under Development</p>
      </div>

      <!-- Contract Data Tab -->
      <div v-else-if="activeTab === 'contract-data'" class="h-full flex items-center justify-center">
        <p class="text-gray-500">Contract Data Tab - Under Development</p>
      </div>

      <!-- Summary Tab -->
      <div v-else-if="activeTab === 'summary'" class="h-full flex items-center justify-center">
        <p class="text-gray-500">Summary Tab - Under Development</p>
      </div>
    </div>

    <!-- Footer -->
    <SurveyFooter
      :active-tab="activeTab"
      :show-property-actions="activeTab === 'property-assessment'"
      :missing-items-count="missingItemsCount"
      :can-proceed="canProceed"
      @save-exit="handleSaveExit"
      @upload-photos="handleUploadPhotos"
      @fill-all-data="handleFillAllData"
      @generate-assessment="handleGenerateAssessment"
      @toggle-marker-mode="handleToggleMarkerMode"
      @show-missing-items="handleShowMissingItems"
      @next="handleNext"
    />

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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

const route = useRoute()
const router = useRouter()
const investmentsStore = useSurveyInvestmentsStore()

// Get survey ID from route
const surveyId = computed(() => route.params.surveyId as string)

// Get selected investments for header
const selectedInvestments = computed(() => investmentsStore.selectedInvestments)

// Active tab state
const activeTab = ref<'property-assessment' | 'consultation' | 'offer-contract' | 'contract-data' | 'summary'>('property-assessment')

// Tab configuration with dynamic status
const tabs = computed(() => [
  {
    id: 'property-assessment',
    label: 'Property Assessment',
    number: 1,
    status: missingItemsCount.value === 0 ? 'completed' as const : 'warning' as const
  },
  { id: 'consultation', label: 'Consultation', number: 2 },
  { id: 'offer-contract', label: 'Offer/Contract', number: 3 },
  { id: 'contract-data', label: 'Contract Data', number: 4 },
  { id: 'summary', label: 'Summary', number: 5 }
])

// Survey data
const clientName = ref('Loading...')

// Can proceed - always true for property-assessment tab
const canProceed = computed(() => {
  if (activeTab.value === 'property-assessment') {
    return true
  }
  // For other tabs, check if there are missing items
  return missingItemsCount.value === 0
})

// Calculate missing items count dynamically
const missingItemsCount = computed(() => {
  let count = 0

  // Count missing photo categories
  investmentsStore.selectedInvestments.forEach(investment => {
    const categories = investmentsStore.documentCategories[investment.id] || []
    categories.forEach(category => {
      // TODO: Get actual uploaded photo count from store/database
      const uploadedCount = 0 // Placeholder
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

// Page display mode - 'single' | 'investment' | 'all'
const pageDisplayMode = ref<'single' | 'investment' | 'all'>('single')

// Felugró ablakok állapota
const showInvestmentModal = ref(false)
const showMissingItemsModal = ref(false)

// Photo upload modal states
const showPhotoUploadModal = ref(false)
const photoUploadMode = ref<'single' | 'investment' | 'all'>('single')
const photoUploadCategoryId = ref<string | undefined>()
const photoUploadInvestmentId = ref<string | undefined>()

// Load survey data
onMounted(async () => {
  await loadSurveyData()
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
    } else {
      clientName.value = 'Unknown Client'
    }

  } catch (error) {
    console.error('Error loading survey data:', error)
    clientName.value = 'Error Loading'
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
  console.log('Toggle marker mode:', enabled)
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

const handleOpenPhotoUpload = (categoryId: string) => {
  photoUploadMode.value = 'single'
  photoUploadCategoryId.value = categoryId
  photoUploadInvestmentId.value = undefined
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
    activeTab.value = tabs.value[currentIndex + 1].id as any
  }
}
</script>
