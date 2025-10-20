<template>
  <div class="h-screen flex flex-col overflow-hidden">
    <!-- Header -->
    <SurveyHeader
      :active-tab="activeTab"
      :client-name="clientName"
      :show-mode-toggle="activeTab === 'property-assessment'"
      @back="handleBack"
      @toggle-investment="handleToggleInvestment"
      @edit-client="handleEditClient"
      @toggle-view-mode="handleToggleViewMode"
      @toggle-hidden="handleToggleHidden"
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

// Get survey ID from route
const surveyId = computed(() => route.params.surveyId as string)

// Active tab state
const activeTab = ref<'property-assessment' | 'consultation' | 'offer-contract' | 'contract-data' | 'summary'>('property-assessment')

// Tab configuration
const tabs = [
  { id: 'property-assessment', label: 'Property Assessment', number: 1 },
  { id: 'consultation', label: 'Consultation', number: 2 },
  { id: 'offer-contract', label: 'Offer/Contract', number: 3 },
  { id: 'contract-data', label: 'Contract Data', number: 4 },
  { id: 'summary', label: 'Summary', number: 5 }
]

// Survey data
const clientName = ref('Loading...')
const missingItemsCount = ref(0)
const canProceed = ref(false)

// Load survey data
onMounted(async () => {
  await loadSurveyData()
})

const loadSurveyData = async () => {
  // TODO: Load survey and client data from Supabase
  // For now, using placeholder
  clientName.value = 'Client Name'
}

// Header handlers
const handleBack = () => {
  router.push('/survey')
}

const handleToggleInvestment = () => {
  console.log('Toggle investment mode')
}

const handleEditClient = () => {
  console.log('Edit client data')
}

const handleToggleViewMode = (mode: 'photos' | 'data' | 'all') => {
  console.log('Toggle view mode:', mode)
}

const handleToggleHidden = () => {
  console.log('Toggle hidden items')
}

// Footer handlers
const handleSaveExit = () => {
  console.log('Save and exit')
  router.push('/survey')
}

const handleUploadPhotos = () => {
  console.log('Upload all photos')
}

const handleFillAllData = () => {
  console.log('Fill all data')
}

const handleGenerateAssessment = () => {
  console.log('Generate assessment sheet')
}

const handleToggleMarkerMode = (enabled: boolean) => {
  console.log('Toggle marker mode:', enabled)
}

const handleShowMissingItems = () => {
  console.log('Show missing items')
}

const handleNext = () => {
  const currentIndex = tabs.findIndex(tab => tab.id === activeTab.value)
  if (currentIndex < tabs.length - 1) {
    activeTab.value = tabs[currentIndex + 1].id as any
  }
}
</script>
