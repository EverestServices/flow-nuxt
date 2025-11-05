<template>
  <div class="flex flex-col items-center gap-4">
    <div class="relative w-full max-w-2xl">
      <!-- Lista ikon gomb (jobb felső sarok) - csak Data vagy All módban -->
      <button
        v-if="viewMode === 'data' || viewMode === 'all'"
        class="absolute top-4 right-4 w-10 h-10 rounded-full bg-white dark:bg-gray-800 border-2 border-primary-500 shadow-lg hover:scale-110 transition-transform flex items-center justify-center z-10"
        @click="$emit('toggle-list-view')"
      >
        <UIcon name="i-lucide-list" class="w-5 h-5 text-primary-600 dark:text-primary-400" />
      </button>

      <!-- House Image -->
      <img
        src="/images/houseVisualization.png"
        alt="House Visualization"
        class="w-full h-auto"
      />

    <!-- Survey Page Buttons with Progress Indicator -->
    <div
      v-for="page in filteredSurveyPages"
      :key="page.id"
      class="absolute group"
      :style="{
        top: page.position.top + 'px',
        right: page.position.right + 'px'
      }"
    >
      <!-- Button -->
      <button
        class="relative w-10 h-10 rounded-full bg-white dark:bg-gray-800 shadow-lg transition-transform flex items-center justify-center"
        @click="$emit('page-click', page.id)"
      >
        <!-- Investment Icon (smaller) -->
        <UIcon
          :name="getInvestmentIcon(page.investment_id)"
          class="w-5 h-5 text-primary-600 dark:text-primary-400"
        />
      </button>

      <!-- Circular Progress SVG -->
      <svg
        class="absolute inset-0 w-10 h-10 -rotate-90 pointer-events-none"
        viewBox="0 0 40 40"
      >
        <!-- Progress circle -->
        <circle
          cx="20"
          cy="20"
          r="18"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          :class="[
            'transition-all duration-300',
            getPageCompletionPercentage(page) === 100
              ? 'text-green-500 dark:text-green-400'
              : 'text-primary-500'
          ]"
          :stroke-dasharray="113.097"
          :stroke-dashoffset="getProgressDashoffset(getPageCompletionPercentage(page))"
        />
      </svg>
    </div>

    <!-- Document Category Buttons (grouped by persist_name) -->
    <button
      v-for="(categories, persistName, index) in groupedCategories"
      :key="`category-${persistName}`"
      class="absolute rounded-full bg-white/50 dark:bg-gray-800 border-2 shadow-lg hover:scale-110 transition-transform flex items-center justify-center group backdrop-blur-xs"
      :class="[
        getCategoryButtonSizeByCount(categories.length),
        areCategoriesComplete(categories) ? 'border-green-500' : 'border-blue-500'
      ]"
      :style="getCategoryButtonPosition(categories[0]!, index)"
      @click="handleCategoryClick(categories)"
    >
      <!-- Camera Icons (multiple if multiple investments need this category) -->
      <div class="flex items-center justify-center space-x-0.5">
        <UIcon
          v-for="n in categories.length"
          :key="n"
          name="i-lucide-camera"
          :class="[
            'w-4 h-4',
            areCategoriesComplete(categories) ? 'text-green-600 dark:text-green-400' : 'text-blue-600 dark:text-blue-400'
          ]"
        />
      </div>

      <!-- Tooltip -->
      <div class="absolute bottom-full mb-2 hidden group-hover:block z-10">
        <div class="bg-gray-900 dark:bg-gray-700 text-white text-xs rounded px-2 py-1 whitespace-nowrap max-w-xs">
          {{ categories[0]?.name }}
        </div>
      </div>
    </button>
    </div>

    <!-- View Mode Toggle -->
    <div class="flex items-center gap-2 p-2 backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-full border border-white/20 dark:border-gray-700/20 shadow-lg">
      <button
        v-for="mode in viewModes"
        :key="mode.value"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium transition-colors',
          viewMode === mode.value
            ? 'bg-primary-500 text-white shadow-sm'
            : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-700'
        ]"
        @click="$emit('change-view-mode', mode.value)"
      >
        {{ mode.label }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Investment, SurveyPage } from '~/stores/surveyInvestments'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

const { t } = useI18n()

interface DocumentCategoryWithInvestment {
  id: string
  persist_name: string
  name: string
  description: string
  min_photos: number
  position?: { top: number; right: number }
  investmentPosition?: number
  investmentId: string
  investmentIcon: string
}

interface Props {
  surveyId: string
  selectedInvestments: Investment[]
  surveyPages: SurveyPage[]
  documentCategories: DocumentCategoryWithInvestment[]
  viewMode?: 'photos' | 'data' | 'all'
  investmentFilter?: string
}

const props = withDefaults(defineProps<Props>(), {
  viewMode: 'all',
  investmentFilter: 'all'
})

const emit = defineEmits<{
  'page-click': [pageId: string]
  'category-click': [categoryId: string, investmentId: string]
  'toggle-list-view': []
  'change-view-mode': [mode: 'photos' | 'data' | 'all']
}>()

const store = useSurveyInvestmentsStore()

// View mode options
const viewModes = computed(() => [
  { value: 'photos' as const, label: t('survey.header.photos') },
  { value: 'data' as const, label: t('survey.header.data') },
  { value: 'all' as const, label: t('survey.header.all') }
])

// Calculate completion percentage for a page
const getPageCompletionPercentage = (page: SurveyPage): number => {
  const questions = store.surveyQuestions[page.id] || []

  // Get only required questions
  const requiredQuestions = questions.filter(q => q.is_required)

  if (requiredQuestions.length === 0) {
    return 100 // If no required questions, consider it complete
  }

  // Count answered required questions (investment-specific)
  const answeredCount = requiredQuestions.filter(question => {
    const response = store.investmentResponses[page.investment_id]?.[question.name]
    return response !== null && response !== undefined && response !== ''
  }).length

  return Math.round((answeredCount / requiredQuestions.length) * 100)
}

// Calculate SVG stroke-dashoffset for circular progress
const getProgressDashoffset = (percentage: number): number => {
  const circumference = 2 * Math.PI * 18 // radius is 18
  return circumference - (percentage / 100) * circumference
}

// Filter survey pages based on view mode and investment filter
const filteredSurveyPages = computed(() => {
  // View mode filter (data mode shows pages, photos mode hides them)
  if (props.viewMode === 'photos') {
    return []
  }

  let pages = props.surveyPages

  // Investment filter
  if (props.investmentFilter !== 'all') {
    pages = pages.filter(page => page.investment_id === props.investmentFilter)
  }

  return pages
})

// Filter document categories based on view mode and investment filter
const filteredDocumentCategories = computed(() => {
  // View mode filter (photos mode shows categories, data mode hides them)
  if (props.viewMode === 'data') {
    return []
  }

  let categories = props.documentCategories

  // Investment filter
  if (props.investmentFilter !== 'all') {
    categories = categories.filter(cat => cat.investmentId === props.investmentFilter)
  }

  return categories
})

// Get investment icon by ID
const getInvestmentIcon = (investmentId: string) => {
  const investment = props.selectedInvestments.find(inv => inv.id === investmentId)
  return investment?.icon || 'i-lucide-help-circle'
}

// Group document categories by persist_name to count duplicates
const groupedCategories = computed(() => {
  const groups: Record<string, DocumentCategoryWithInvestment[]> = {}

  filteredDocumentCategories.value.forEach(cat => {
    if (!groups[cat.persist_name]) {
      groups[cat.persist_name] = []
    }
    groups[cat.persist_name].push(cat)
  })

  return groups
})

// Get button size based on camera count
const getCategoryButtonSizeByCount = (count: number) => {
  if (count === 1) return 'w-8 h-8'
  if (count === 2) return 'w-10 h-8'
  if (count === 3) return 'w-12 h-8'
  return 'w-14 h-8'
}

// Get button position - use position from database if available
const getCategoryButtonPosition = (category: DocumentCategoryWithInvestment, index: number) => {
  // If category has a position from the document_categories table, use it
  if (category.position && category.position.top && category.position.right) {
    return {
      top: `${category.position.top}px`,
      right: `${category.position.right}px`
    }
  }

  // Otherwise, distribute around the house
  const baseTop = 150
  const baseRight = 50
  const offset = index * 60

  return {
    top: `${baseTop + offset}px`,
    right: `${baseRight}px`
  }
}

// Handle category click - select the correct category based on investment filter
const handleCategoryClick = (categories: DocumentCategoryWithInvestment[]) => {
  if (categories.length === 0) return

  // If investment filter is set and not 'all', find the category for that investment
  if (props.investmentFilter && props.investmentFilter !== 'all') {
    const category = categories.find(cat => cat.investmentId === props.investmentFilter)
    if (category) {
      emit('category-click', category.id, category.investmentId)
      return
    }
  }

  // Otherwise, use the first category (default behavior)
  const category = categories[0]!
  emit('category-click', category.id, category.investmentId)
}

// Check if all categories in the group have sufficient photos
const areCategoriesComplete = (categories: DocumentCategoryWithInvestment[]): boolean => {
  return categories.every(cat => {
    const uploadedCount = store.getCategoryPhotoCount(cat.id)
    return uploadedCount >= cat.min_photos
  })
}
</script>
