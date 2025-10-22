<template>
  <!-- Backdrop -->
  <div
    v-if="modelValue"
    class="fixed inset-0 bg-black/50 z-40"
    @click="close"
  ></div>

  <!-- Modal -->
  <Transition name="modal-fade">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      @click.self="close"
    >
      <div
        class="bg-white dark:bg-gray-800 rounded-lg shadow-xl w-full max-w-2xl max-h-[80vh] flex flex-col"
        @click.stop
      >
      <!-- Header -->
      <div class="p-6 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
          Hiányzó elemek listája
        </h2>
        <button
          class="p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700"
          @click="close"
        >
          <UIcon name="i-heroicons-x-mark" class="w-6 h-6 text-gray-500" />
        </button>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 space-y-6">
        <!-- Hiányos fotó kategóriák -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Hiányos fotó kategóriák ({{ missingPhotoCategories.length }})
          </h3>
          <div v-if="missingPhotoCategories.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-4">
            Minden fotó kategória kitöltve
          </div>
          <div v-else class="space-y-3">
            <button
              v-for="category in missingPhotoCategories"
              :key="category.id"
              class="w-full p-4 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors text-left"
              @click="handleCategoryClick(category.id, category.investmentId)"
            >
              <div class="flex items-center gap-2 mb-2">
                <!-- Investment icons -->
                <UIcon
                  :name="category.investmentIcon"
                  class="w-4 h-4 text-gray-600 dark:text-gray-400"
                />
                <span class="font-medium text-gray-900 dark:text-white">
                  {{ category.name }}
                </span>
              </div>
              <div class="text-sm text-gray-600 dark:text-gray-400">
                {{ category.uploadedCount }}/{{ category.minPhotos }} fénykép feltöltve
              </div>
            </button>
          </div>
        </div>

        <!-- Megválaszolatlan kérdések -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Megválaszolatlan kérdések ({{ unansweredQuestions.length }})
          </h3>
          <div v-if="unansweredQuestions.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-4">
            Minden kérdés megválaszolva
          </div>
          <div v-else class="space-y-3">
            <button
              v-for="question in unansweredQuestions"
              :key="question.id"
              class="w-full p-4 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors text-left"
              @click="handleQuestionClick(question.pageId)"
            >
              <div class="flex items-center gap-2 mb-2">
                <UIcon
                  :name="question.investmentIcon"
                  class="w-4 h-4 text-gray-600 dark:text-gray-400"
                />
                <span class="font-medium text-gray-700 dark:text-gray-300 text-sm">
                  {{ question.investmentName }} - {{ question.pageName }}
                </span>
              </div>
              <div class="text-sm text-gray-900 dark:text-white">
                {{ question.label }}
              </div>
            </button>
          </div>
        </div>
      </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface MissingPhotoCategory {
  id: string
  name: string
  investmentId: string
  investmentIcon: string
  uploadedCount: number
  minPhotos: number
}

interface UnansweredQuestion {
  id: string
  label: string
  pageId: string
  pageName: string
  investmentId: string
  investmentName: string
  investmentIcon: string
}

interface Props {
  modelValue: boolean
  surveyId: string
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'open-photo-upload': [categoryId: string, investmentId: string]
  'open-survey-page': [pageId: string]
}>()

const store = useSurveyInvestmentsStore()
const { translatePage, translateQuestion } = useI18n()

const close = () => {
  emit('update:modelValue', false)
}

// Compute missing photo categories
const missingPhotoCategories = computed<MissingPhotoCategory[]>(() => {
  const missing: MissingPhotoCategory[] = []

  store.selectedInvestments.forEach(investment => {
    const categories = store.documentCategories[investment.id] || []
    categories.forEach(category => {
      // TODO: Get actual uploaded photo count from store/database
      const uploadedCount = 0 // Placeholder

      if (uploadedCount < category.min_photos) {
        missing.push({
          id: category.id,
          name: category.name,
          investmentId: investment.id,
          investmentIcon: investment.icon,
          uploadedCount,
          minPhotos: category.min_photos
        })
      }
    })
  })

  return missing
})

// Compute unanswered questions
const unansweredQuestions = computed<UnansweredQuestion[]>(() => {
  const unanswered: UnansweredQuestion[] = []

  store.selectedInvestments.forEach(investment => {
    const pages = store.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = store.surveyQuestions[page.id] || []
      questions.forEach(question => {
        // Check if required and not answered
        if (question.is_required) {
          const response = store.getResponse(question.name)
          if (!response || response === '' || response === null || response === undefined) {
            unanswered.push({
              id: question.id,
              label: translateQuestion(question.name),
              pageId: page.id,
              pageName: translatePage(page.name),
              investmentId: investment.id,
              investmentName: investment.name,
              investmentIcon: investment.icon
            })
          }
        }
      })
    })
  })

  return unanswered
})

const handleCategoryClick = (categoryId: string, investmentId: string) => {
  close()
  emit('open-photo-upload', categoryId, investmentId)
}

const handleQuestionClick = (pageId: string) => {
  close()
  emit('open-survey-page', pageId)
}
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active > div,
.modal-fade-leave-active > div {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-fade-enter-from > div,
.modal-fade-leave-to > div {
  transform: scale(0.95);
  opacity: 0;
}
</style>
