<template>
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

    <!-- Survey Page Buttons -->
    <button
      v-for="page in filteredSurveyPages"
      :key="page.id"
      class="absolute w-10 h-10 rounded-full bg-white dark:bg-gray-800 border-2 border-primary-500 shadow-lg hover:scale-110 transition-transform flex items-center justify-center group"
      :style="{
        top: page.position.top + 'px',
        right: page.position.right + 'px'
      }"
      @click="$emit('page-click', page.id)"
    >
      <!-- Investment Icon (smaller) -->
      <UIcon
        :name="getInvestmentIcon(page.investment_id)"
        class="w-5 h-5 text-primary-600 dark:text-primary-400"
      />

      <!-- Tooltip -->
      <div class="absolute bottom-full mb-2 hidden group-hover:block">
        <div class="bg-gray-900 dark:bg-gray-700 text-white text-xs rounded px-2 py-1 whitespace-nowrap">
          {{ page.name }}
        </div>
      </div>
    </button>

    <!-- Document Category Buttons (grouped by persist_name) -->
    <button
      v-for="(categories, persistName, index) in groupedCategories"
      :key="`category-${persistName}`"
      class="absolute rounded-full bg-white dark:bg-gray-800 border-2 border-blue-500 shadow-lg hover:scale-110 transition-transform flex items-center justify-center group"
      :class="getCategoryButtonSizeByCount(categories.length)"
      :style="getCategoryButtonPosition(categories[0], index)"
      @click="$emit('category-click', categories[0].id)"
    >
      <!-- Camera Icons (multiple if multiple investments need this category) -->
      <div class="flex items-center justify-center space-x-0.5">
        <UIcon
          v-for="n in categories.length"
          :key="n"
          name="i-lucide-camera"
          class="w-4 h-4 text-blue-600 dark:text-blue-400"
        />
      </div>

      <!-- Tooltip -->
      <div class="absolute bottom-full mb-2 hidden group-hover:block z-10">
        <div class="bg-gray-900 dark:bg-gray-700 text-white text-xs rounded px-2 py-1 whitespace-nowrap max-w-xs">
          {{ categories[0].name }}
        </div>
      </div>
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Investment, SurveyPage } from '~/stores/surveyInvestments'

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

defineEmits<{
  'page-click': [pageId: string]
  'category-click': [categoryId: string]
  'toggle-list-view': []
}>()

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
  console.log('Filtered document categories:', filteredDocumentCategories.value)
  const groups: Record<string, DocumentCategoryWithInvestment[]> = {}

  filteredDocumentCategories.value.forEach(cat => {
    if (!groups[cat.persist_name]) {
      groups[cat.persist_name] = []
    }
    groups[cat.persist_name].push(cat)
  })

  console.log('Grouped categories:', groups)
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
</script>
