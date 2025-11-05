<template>
  <UIModal
    v-model="isOpen"
    :title="$t('survey.missingItems.title')"
    size="lg"
    :scrollable="true"
    @close="close"
  >
    <div class="space-y-6">
        <!-- Hiányos fotó kategóriák -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            {{ $t('survey.missingItems.missingPhotoCategories') }} ({{ missingPhotoCategories.length }})
          </h3>
          <div v-if="missingPhotoCategories.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-4">
            {{ $t('survey.missingItems.allPhotoCategoriesFilled') }}
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
                {{ category.uploadedCount }}/{{ category.minPhotos }} {{ $t('survey.missingItems.photosUploaded') }}
              </div>
            </button>
          </div>
        </div>

        <!-- Megválaszolatlan kérdések -->
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            {{ $t('survey.missingItems.unansweredQuestions') }} ({{ unansweredQuestions.length }})
          </h3>
          <div v-if="unansweredQuestions.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-4">
            {{ $t('survey.missingItems.allQuestionsAnswered') }}
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
  </UIModal>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
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
const { translatePage, translateField } = useSurveyTranslations()
const { translate } = useTranslatableField()

const isOpen = ref(false)

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
})

watch(isOpen, (value) => {
  if (value !== props.modelValue) {
    emit('update:modelValue', value)
  }
})

const close = () => {
  isOpen.value = false
  emit('update:modelValue', false)
}

// Compute missing photo categories
const missingPhotoCategories = computed<MissingPhotoCategory[]>(() => {
  const missing: MissingPhotoCategory[] = []

  store.selectedInvestments.forEach(investment => {
    const categories = store.documentCategories[investment.id] || []
    categories.forEach(category => {
      // Get actual uploaded photo count from store
      const uploadedCount = store.getCategoryPhotoCount(category.id)

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
  const seenQuestions = new Set<string>() // Track by investment + question name

  store.selectedInvestments.forEach(investment => {
    const pages = store.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = store.surveyQuestions[page.id] || []
      questions.forEach(question => {
        // Check if required and not answered
        if (question.is_required) {
          // Get investment-specific response
          const response = store.investmentResponses[investment.id]?.[question.name]
          if (!response || response === '' || response === null || response === undefined) {
            // Create unique key: investmentId + questionName
            const questionKey = `${investment.id}:${question.name}`

            // Only add if we haven't seen this investment+question combination before
            if (!seenQuestions.has(questionKey)) {
              seenQuestions.add(questionKey)
              unanswered.push({
                id: question.id,
                label: translate(question.name_translations, translateField(question.name)),
                pageId: page.id,
                pageName: translatePage(page.name),
                investmentId: investment.id,
                investmentName: translate(investment.name_translations, investment.name),
                investmentIcon: investment.icon
              })
            }
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
