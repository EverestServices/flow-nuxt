<template>
  <div class="h-full grid gap-6 " :class="showVisualization ? 'grid-cols-1 lg:grid-cols-2' : 'grid-cols-1'">
    <!-- Left Side: Investment Selection or Survey Questions -->
    <div class="flex flex-col items-center justify-center min-h-screen z-20">
      <!-- Empty State (No investments selected) -->
      <div v-if="!hasInvestments" class="bg-white/50 border-white dark:bg-black/20 dark:border-black/20 rounded-3xl p-8 w-full ">
        <!-- Message -->
        <p class="text-center text-gray-600 dark:text-white mb-8">
          Please select at least one service by clicking the "Add Investment" button.
        </p>

        <!-- Random Investment Icons -->
        <div class="flex items-center justify-center gap-6 mb-8">
          <div
            v-for="icon in randomIcons"
            :key="icon"
            class="w-16 h-16 rounded-lg bg-gray-100 dark:bg-gray-700 flex items-center justify-center"
          >
            <UIcon
              :name="icon"
              class="w-8 h-8 text-gray-400 dark:text-gray-500"
            />
          </div>
        </div>

        <!-- Add Investment Button -->
        <div class="flex justify-center">
          <UIButtonEnhanced
            variant="primary"
            size="lg"
            @click="openInvestmentModal"
          >
            <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
            Add Investment
          </UIButtonEnhanced>
        </div>
      </div>

      <!-- Survey Page Content (When investments are selected) -->
      <div v-else class="h-full flex flex-col w-full space-y-4 pr-2 my-18">
        <!-- Loop through displayed investments -->
        <div
          v-for="investment in displayedInvestments"
          :key="investment.id"
          class="bg-white dark:bg-black/30 rounded-3xl flex flex-col"
        >
          <!-- Investment Header -->
          <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex-shrink-0">
            <!-- Investment Navigation with Arrows (csak ha több investment van ÉS nem 'all' módban vagyunk) -->
            <div v-if="showInvestmentNavigation" class="flex items-center justify-center gap-2">
              <button
                :disabled="!hasPreviousInvestment"
                class="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-30 disabled:cursor-not-allowed"
                @click="goToPreviousInvestment"
              >
                <UIcon name="i-lucide-chevron-left" class="w-5 h-5" />
              </button>
              <div class="flex items-center gap-2 min-w-[200px] justify-center">
                <UIcon
                  :name="investment.icon"
                  class="w-5 h-5 text-gray-600 dark:text-gray-400"
                />
                <span class="text-sm font-semibold text-gray-900 dark:text-white">
                  {{ investment.name }}
                </span>
              </div>
              <button
                :disabled="!hasNextInvestment"
                class="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-30 disabled:cursor-not-allowed"
                @click="goToNextInvestment"
              >
                <UIcon name="i-lucide-chevron-right" class="w-5 h-5" />
              </button>
            </div>

            <!-- Investment címe (ha nincs navigáció) -->
            <div v-else class="flex items-center justify-center gap-2">
              <UIcon
                :name="investment.icon"
                class="w-5 h-5 text-gray-600 dark:text-gray-400"
              />
              <span class="text-sm font-semibold text-gray-900 dark:text-white">
                {{ investment.name }}
              </span>
            </div>
          </div>

          <!-- Loop through displayed pages for this investment -->
          <div
            v-for="page in getDisplayedPagesForInvestment(investment.id)"
            :key="page.id"
            class="border-b border-gray-200 dark:border-gray-700 last:border-b-0"
          >
            <!-- Page Navigation Header (csak 'single' módban, ha több page van) -->
            <div v-if="showPageNavigation" class="p-3 bg-gray-50 dark:bg-gray-900 flex items-center justify-center gap-2">
              <button
                :disabled="!hasPreviousPage"
                class="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-30 disabled:cursor-not-allowed"
                @click="goToPreviousPage"
              >
                <UIcon name="i-lucide-chevron-left" class="w-4 h-4" />
              </button>
              <span class="text-xs font-medium text-gray-600 dark:text-gray-400 min-w-[150px] text-center">
                {{ translatePage(page.name) }}
              </span>
              <button
                :disabled="!hasNextPage"
                class="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-30 disabled:cursor-not-allowed"
                @click="goToNextPage"
              >
                <UIcon name="i-lucide-chevron-right" class="w-4 h-4" />
              </button>
            </div>

            <!-- Page címe (ha nincs single mód) -->
            <div v-else class="p-3 bg-gray-50 dark:bg-gray-900">
              <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 text-center">
                {{ translatePage(page.name) }}
              </h4>
            </div>

            <!-- Survey Questions -->
            <div class="p-6">
              <!-- Allow Multiple: Accordion-based instances -->
              <div v-if="page.allow_multiple" class="space-y-3">
                <!-- Empty state message when no instances -->
                <div v-if="getPageInstances(page.id).length === 0" class="text-center text-gray-500 dark:text-gray-400 py-6">
                  <p class="text-sm">Nincs még hozzáadott elem.</p>
                  <p class="text-xs mt-1">Kattints az alábbi gombra új hozzáadásához.</p>
                </div>

                <UAccordion
                  v-for="(instance, index) in getPageInstances(page.id)"
                  :key="index"
                  :items="[{
                    label: getInstanceName(page, index),
                    slot: `instance-${page.id}-${index}`,
                    defaultOpen: index === 0
                  }]"
                >
                  <template #default="{ item, open }">
                    <div class="flex items-center justify-between w-full">
                      <span class="text-sm font-medium text-gray-900 dark:text-white">
                        {{ getInstanceName(page, index) }}
                      </span>
                      <!-- Delete button -->
                      <button
                        v-if="canDeleteInstance(page, index)"
                        class="ml-2 p-1 rounded hover:bg-red-100 dark:hover:bg-red-900 text-red-600 dark:text-red-400"
                        @click.stop="deleteInstance(page, index)"
                      >
                        <UIcon name="i-lucide-trash-2" class="w-4 h-4" />
                      </button>
                    </div>
                  </template>

                  <template #[`instance-${page.id}-${index}`]>
                    <div class="p-4 space-y-6 bg-gray-50 dark:bg-gray-800 rounded-b-lg">
                      <!-- Normal Questions -->
                      <div
                        v-for="question in getNormalQuestions(page.id)"
                        :key="question.id"
                        class="space-y-2"
                      >
                        <SurveyQuestionRenderer
                          :question="question"
                          :model-value="getInstanceQuestionValue(page.id, index, question.name)"
                          @update:model-value="updateInstanceQuestionValue(page.id, index, question.name, $event)"
                        />
                      </div>

                      <!-- Special Questions Accordion -->
                      <div v-if="getSpecialQuestions(page.id).length > 0" class="mt-4">
                        <UAccordion
                          :items="[{
                            label: 'Egyéb kérdések',
                            slot: `special-${page.id}-${index}`,
                            defaultOpen: false
                          }]"
                        >
                          <template #[`special-${page.id}-${index}`]>
                            <div class="p-4 space-y-6 bg-white dark:bg-gray-900 rounded-b-lg">
                              <div
                                v-for="question in getSpecialQuestions(page.id)"
                                :key="question.id"
                                class="space-y-2"
                              >
                                <SurveyQuestionRenderer
                                  :question="question"
                                  :model-value="getInstanceQuestionValue(page.id, index, question.name)"
                                  @update:model-value="updateInstanceQuestionValue(page.id, index, question.name, $event)"
                                />
                              </div>
                              <!-- Close Button -->
                              <div class="flex justify-end pt-2">
                                <UButton
                                  label="Becsuk"
                                  color="gray"
                                  variant="outline"
                                  size="sm"
                                  @click="closeAccordion"
                                />
                              </div>
                            </div>
                          </template>
                        </UAccordion>
                      </div>
                    </div>
                  </template>
                </UAccordion>

                <!-- Add Instance Button -->
                <div class="flex justify-center pt-2">
                  <UButton
                    :label="`${page.name} hozzáadása`"
                    icon="i-lucide-plus"
                    color="primary"
                    variant="outline"
                    size="sm"
                    @click="addInstance(page.id)"
                  />
                </div>
              </div>

              <!-- No Allow Multiple: Regular question rendering -->
              <div v-else>
                <div v-if="store.surveyQuestions[page.id]?.length > 0" class="space-y-6">
                  <!-- Normal Questions -->
                  <div
                    v-for="question in getNormalQuestions(page.id)"
                    :key="question.id"
                    class="space-y-2"
                  >
                    <SurveyQuestionRenderer
                      :question="question"
                      :model-value="getQuestionValue(question.name)"
                      @update:model-value="updateQuestionValue(question.name, $event)"
                    />
                  </div>

                  <!-- Special Questions Accordion -->
                  <div v-if="getSpecialQuestions(page.id).length > 0" class="mt-4">
                    <UAccordion
                      :items="[{
                        label: 'Egyéb kérdések',
                        slot: `special-${page.id}`,
                        defaultOpen: false
                      }]"
                    >
                      <template #[`special-${page.id}`]>
                        <div class="p-4 space-y-6 bg-gray-50 dark:bg-gray-800 rounded-b-lg">
                          <div
                            v-for="question in getSpecialQuestions(page.id)"
                            :key="question.id"
                            class="space-y-2"
                          >
                            <SurveyQuestionRenderer
                              :question="question"
                              :model-value="getQuestionValue(question.name)"
                              @update:model-value="updateQuestionValue(question.name, $event)"
                            />
                          </div>
                          <!-- Close Button -->
                          <div class="flex justify-end pt-2">
                            <UButton
                              label="Becsuk"
                              color="gray"
                              variant="outline"
                              size="sm"
                              @click="closeAccordion"
                            />
                          </div>
                        </div>
                      </template>
                    </UAccordion>
                  </div>
                </div>
                <div v-else class="text-center text-gray-500 dark:text-gray-400">
                  No questions available for this page.
                </div>
              </div>
            </div>

            <!-- Camera Button (csak 'single' vagy 'investment' módban) -->
            <div v-if="props.pageDisplayMode !== 'all'" class="p-4 border-t border-gray-200 dark:border-gray-700 flex justify-center">
              <button
                class="p-2 rounded-md bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600"
                @click="handleCameraClick"
              >
                <UIcon name="i-lucide-camera" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Side: House Visualization -->
    <div v-if="showVisualization" class="flex items-center justify-center h-screen fixed top-0 right-0 w-[1000px]">
      <SurveyHouseVisualization
        :survey-id="surveyId"
        :selected-investments="selectedInvestments"
        :survey-pages="allSurveyPages"
        :document-categories="allDocumentCategories"
        :view-mode="viewMode"
        :investment-filter="investmentFilter"
        @page-click="handlePageClick"
        @category-click="handleCategoryClick"
        @toggle-list-view="emit('toggle-list-view')"
      />
    </div>
  </div>

  <!-- Investment kiválasztási felugró ablak -->
  <SurveyInvestmentModal
    v-model="showInvestmentModal"
    :survey-id="surveyId"
  />
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import type { Investment, SurveyPage } from '~/stores/surveyInvestments'

interface Props {
  surveyId: string
  showInvestmentModal?: boolean
  viewMode?: 'photos' | 'data' | 'all'
  investmentFilter?: string
  showVisualization?: boolean
  pageDisplayMode?: 'single' | 'investment' | 'all'
}

const props = withDefaults(defineProps<Props>(), {
  viewMode: 'all',
  investmentFilter: 'all',
  showVisualization: true,
  pageDisplayMode: 'single'
})

const emit = defineEmits<{
  'update:showInvestmentModal': [value: boolean]
  'toggle-list-view': []
  'set-display-mode': [mode: 'single' | 'investment' | 'all']
  'open-photo-upload': [categoryId: string]
  'open-camera': [investmentId: string]
}>()

// Translations
const { translatePage } = useI18n()

// Store
const store = useSurveyInvestmentsStore()

// Modal state (with v-model support)
const showInvestmentModal = computed({
  get: () => props.showInvestmentModal || false,
  set: (value) => emit('update:showInvestmentModal', value)
})

// Sample icons for empty state
const availableIcons = [
  'i-lucide-sun',
  'i-lucide-zap',
  'i-lucide-flame',
  'i-lucide-home',
  'i-lucide-battery',
  'i-lucide-lightbulb',
]

// Get 3 random icons for display
const randomIcons = computed(() => {
  const shuffled = [...availableIcons].sort(() => 0.5 - Math.random())
  return shuffled.slice(0, 3)
})

// Computed from store
const hasInvestments = computed(() => store.hasSelectedInvestments)
const selectedInvestments = computed(() => store.selectedInvestments)
const activeInvestmentId = computed(() => store.activeInvestmentId)
const activeInvestment = computed(() => store.activeInvestment)
const activePageId = computed(() => store.activePageId)
const activePage = computed(() => store.activePage)
const activeSurveyPages = computed(() => store.activeSurveyPages)
const activePageQuestions = computed(() => store.activePageQuestions)

// All survey pages (for visualization)
const allSurveyPages = computed(() => {
  const pages: SurveyPage[] = []
  selectedInvestments.value.forEach(inv => {
    const invPages = store.surveyPages[inv.id] || []
    pages.push(...invPages)
  })
  return pages
})

// All document categories (for visualization)
const allDocumentCategories = computed(() => {
  const categories: Array<{
    id: string
    persist_name: string
    name: string
    description: string
    min_photos: number
    position?: { top: number; right: number }
    investmentPosition?: number
    investmentId: string
    investmentIcon: string
  }> = []
  selectedInvestments.value.forEach(inv => {
    const invCategories = store.documentCategories[inv.id] || []
    invCategories.forEach(cat => {
      categories.push({ ...cat, investmentId: inv.id, investmentIcon: inv.icon })
    })
  })
  return categories
})

// Displayed investments based on page display mode
const displayedInvestments = computed(() => {
  if (props.pageDisplayMode === 'single') {
    // Mode 1: Only active investment
    return activeInvestment.value ? [activeInvestment.value] : []
  } else if (props.pageDisplayMode === 'investment') {
    // Mode 2: Only active investment
    return activeInvestment.value ? [activeInvestment.value] : []
  } else {
    // Mode 3: All selected investments
    return selectedInvestments.value
  }
})

// Displayed pages for each investment based on page display mode
const getDisplayedPagesForInvestment = (investmentId: string) => {
  const pages = store.surveyPages[investmentId] || []

  if (props.pageDisplayMode === 'single') {
    // Mode 1: Only active page
    return pages.filter(p => p.id === activePageId.value)
  } else {
    // Mode 2 & 3: All pages for this investment
    return pages
  }
}

// Show Investment navigation arrows
const showInvestmentNavigation = computed(() => {
  return props.pageDisplayMode !== 'all' && selectedInvestments.value.length > 1
})

// Show Page navigation arrows
const showPageNavigation = computed(() => {
  return props.pageDisplayMode === 'single' && activeSurveyPages.value.length > 1
})

// Investment navigation
const currentInvestmentIndex = computed(() => {
  return selectedInvestments.value.findIndex(inv => inv.id === activeInvestmentId.value)
})

const hasPreviousInvestment = computed(() => currentInvestmentIndex.value > 0)
const hasNextInvestment = computed(() => currentInvestmentIndex.value < selectedInvestments.value.length - 1)

const goToPreviousInvestment = () => {
  if (hasPreviousInvestment.value) {
    const prevInvestment = selectedInvestments.value[currentInvestmentIndex.value - 1]
    store.setActiveInvestment(prevInvestment.id)
  }
}

const goToNextInvestment = () => {
  if (hasNextInvestment.value) {
    const nextInvestment = selectedInvestments.value[currentInvestmentIndex.value + 1]
    store.setActiveInvestment(nextInvestment.id)
  }
}

// Page navigation
const currentPageIndex = computed(() => {
  return activeSurveyPages.value.findIndex(page => page.id === activePageId.value)
})

const hasPreviousPage = computed(() => currentPageIndex.value > 0)
const hasNextPage = computed(() => currentPageIndex.value < activeSurveyPages.value.length - 1)

const goToPreviousPage = () => {
  if (hasPreviousPage.value) {
    const prevPage = activeSurveyPages.value[currentPageIndex.value - 1]
    store.setActivePage(prevPage.id)
  }
}

const goToNextPage = () => {
  if (hasNextPage.value) {
    const nextPage = activeSurveyPages.value[currentPageIndex.value + 1]
    store.setActivePage(nextPage.id)
  }
}

// Metódusok
const openInvestmentModal = () => {
  emit('update:showInvestmentModal', true)
}

const setActiveInvestment = (investmentId: string) => {
  store.setActiveInvestment(investmentId)
}

const setActivePage = (pageId: string) => {
  store.setActivePage(pageId)
}

const getQuestionValue = (questionName: string) => {
  return store.getResponse(questionName)
}

const updateQuestionValue = async (questionName: string, value: any) => {
  await store.saveResponse(questionName, value)
}

const handlePageClick = (pageId: string) => {
  store.setActivePage(pageId)
  // Amikor egy SurveyPage gombra kattintunk, vissza váltunk 'single' módra
  emit('set-display-mode', 'single')
}

const handleCategoryClick = (categoryId: string) => {
  emit('open-photo-upload', categoryId)
}

const handleCameraClick = () => {
  if (!activeInvestmentId.value) return
  emit('open-camera', activeInvestmentId.value)
}

// ========================================================================
// Instance Management (for allow_multiple pages)
// ========================================================================

const getPageInstances = (pageId: string) => {
  return store.getPageInstances(pageId)
}

const getInstanceName = (page: SurveyPage, index: number) => {
  if (!page.item_name_template) {
    return `${page.name} ${index + 1}`
  }
  // Replace {index} placeholder with actual index (1-based)
  return page.item_name_template.replace('{index}', (index + 1).toString())
}

const canDeleteInstance = (page: SurveyPage, index: number) => {
  const instances = store.getPageInstances(page.id)

  // If allow_delete_first is true, can delete any instance (even the last one)
  if (page.allow_delete_first) {
    return true
  }

  // Otherwise, can only delete non-first instances, and must keep at least one
  return index > 0
}

const addInstance = (pageId: string) => {
  store.addPageInstance(pageId)
}

const deleteInstance = (page: SurveyPage, index: number) => {
  store.removePageInstance(page.id, index, page.allow_delete_first || false)
}

const getInstanceQuestionValue = (pageId: string, instanceIndex: number, questionName: string) => {
  return store.getInstanceResponse(pageId, instanceIndex, questionName)
}

const updateInstanceQuestionValue = async (pageId: string, instanceIndex: number, questionName: string, value: any) => {
  await store.saveInstanceResponse(pageId, instanceIndex, questionName, value)
}

// ========================================================================
// Special Questions Handling
// ========================================================================

const getNormalQuestions = (pageId: string) => {
  const questions = store.surveyQuestions[pageId] || []
  return questions.filter(q => !q.is_special)
}

const getSpecialQuestions = (pageId: string) => {
  const questions = store.surveyQuestions[pageId] || []
  return questions.filter(q => q.is_special === true)
}

const closeAccordion = (event: MouseEvent) => {
  // Navigate up the DOM to find the accordion and click its header button
  const target = event.target as HTMLElement

  // Find the parent accordion wrapper (looking for the mt-4 div that wraps the UAccordion)
  let current = target.parentElement
  while (current) {
    // Look for the accordion header button - it should be a sibling of the content area
    const buttons = current.querySelectorAll('button')
    for (const button of Array.from(buttons)) {
      // Find the button that contains "Egyéb kérdések" text or is an accordion header
      if (button.textContent?.includes('Egyéb kérdések')) {
        button.click()
        return
      }
    }
    current = current.parentElement
  }
}

// Inicializálás
onMounted(async () => {
  await store.initializeForSurvey(props.surveyId)
})
</script>
