<template>
  <div class="survey-question">
    <!-- Title Type (just displays text) -->
    <div v-if="question.type === 'title'" class="font-semibold text-gray-900 dark:text-white">
      {{ questionLabel }}
    </div>

    <!-- Text Input -->
    <div v-else-if="question.type === 'text' || question.type === 'number'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex items-center space-x-2">
        <UIInput
          :model-value="modelValue || question.default_value"
          :type="question.type === 'number' ? 'number' : 'text'"
          :placeholder="questionPlaceholder"
          :required="question.is_required"
          :min="question.min"
          :max="question.max"
          :readonly="isEffectivelyReadonly"
          :disabled="isEffectivelyReadonly"
          class="flex-1"
          @update:model-value="$emit('update:modelValue', $event)"
        />
        <span v-if="questionUnit" class="text-sm text-gray-500 dark:text-gray-400">
          {{ questionUnit }}
        </span>
      </div>
    </div>

    <!-- Textarea -->
    <div v-else-if="question.type === 'textarea'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <UITextarea
        :model-value="modelValue || question.default_value"
        :placeholder="questionPlaceholder"
        :required="question.is_required"
        :rows="4"
        :readonly="isEffectivelyReadonly"
        :disabled="isEffectivelyReadonly"
        class="w-full"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>

    <!-- Dropdown -->
    <div v-else-if="question.type === 'dropdown'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <UISelect
        :model-value="modelValue || question.default_value"
        :options="translatedOptions.map(opt => opt.value)"
        :placeholder="questionPlaceholder || 'Select an option'"
        :required="question.is_required"
        :disabled="isEffectivelyReadonly"
        size="md"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>

    <!-- Switch/Toggle -->
    <div v-else-if="question.type === 'switch'">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {{ questionLabel }}
            <span v-if="question.is_required" class="text-red-500">*</span>
          </label>
          <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
        </div>
        <USwitch v-model="toggleValue" :disabled="isEffectivelyReadonly" />
      </div>
    </div>

    <!-- Slider -->
    <div v-else-if="question.type === 'slider'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex items-center space-x-4">
        <input
          :value="modelValue || question.default_value || question.min || 0"
          type="range"
          :min="question.min || 0"
          :max="question.max || 100"
          :step="question.step || 1"
          :disabled="isEffectivelyReadonly"
          class="flex-1"
          @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        />
        <span class="text-sm font-medium text-gray-900 dark:text-white min-w-[60px] text-right">
          {{ modelValue || question.default_value || question.min || 0 }}{{ questionUnit || '' }}
        </span>
      </div>
    </div>

    <!-- Dual Toggle (Two options) -->
    <div v-else-if="question.type === 'dual_toggle'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex items-center space-x-2">
        <button
          v-for="option in translatedOptions"
          :key="option.value"
          :disabled="isEffectivelyReadonly"
          class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          :class="[
            (modelValue || question.default_value) === option.value
              ? 'bg-primary-500 text-white'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600',
            isEffectivelyReadonly ? 'opacity-60 cursor-not-allowed' : ''
          ]"
          @click="$emit('update:modelValue', option.value)"
        >
          {{ option.label }}
        </button>
      </div>
    </div>

    <!-- Phase Toggle (1 or 3) -->
    <div v-else-if="question.type === 'phase_toggle'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex items-center space-x-2">
        <button
          v-for="option in translatedOptions"
          :key="option.value"
          :disabled="isEffectivelyReadonly"
          class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          :class="[
            (modelValue || question.default_value) === option.value
              ? 'bg-primary-500 text-white'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600',
            isEffectivelyReadonly ? 'opacity-60 cursor-not-allowed' : ''
          ]"
          @click="$emit('update:modelValue', option.value)"
        >
          {{ option.label }}
        </button>
      </div>
    </div>

    <!-- Orientation Selector (8 directions) -->
    <div v-else-if="question.type === 'orientation_selector'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="option in translatedOptions"
          :key="option.value"
          :disabled="isEffectivelyReadonly"
          class="w-14 h-14 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative"
          :class="[
            (modelValue || question.default_value) === option.value
              ? 'bg-primary-500 text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600',
            isEffectivelyReadonly ? 'opacity-60 cursor-not-allowed hover:scale-100' : ''
          ]"
          @click="$emit('update:modelValue', option.value)"
        >
          <UIcon
            name="i-lucide-navigation"
            class="w-6 h-6 transition-transform"
            :style="{ transform: `rotate(${getOrientationAngle(option.value)}deg)` }"
          />
          <span class="text-xs font-medium mt-0.5">{{ option.label }}</span>
        </button>
      </div>
    </div>

    <!-- Fallback for unknown types -->
    <div v-else class="text-sm text-gray-500 dark:text-gray-400">
      Unsupported question type: {{ question.type }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { SurveyQuestion } from '~/stores/surveyInvestments'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface Props {
  question: SurveyQuestion
  modelValue?: any
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: any]
}>()

const store = useSurveyInvestmentsStore()

// Translations composables
const { translateField } = useSurveyTranslations()
const { translate, translateOptions } = useTranslatableField()

// Get translated label for the question
const questionLabel = computed(() => {
  // Priority: name_translations > translateField > name
  return translate(props.question.name_translations, translateField(props.question.name))
})

// Get translated placeholder
const questionPlaceholder = computed(() => {
  return translate(props.question.placeholder_translations, props.question.placeholder_value)
})

// Get translated unit (post-text)
const questionUnit = computed(() => {
  return translate(props.question.unit_translations, props.question.unit)
})

// Get translated info message for tooltip
const questionInfoMessage = computed(() => {
  if (!props.question.info_message_translations) return null
  const message = translate(props.question.info_message_translations, null)
  // Convert escaped newlines to actual newlines
  return message ? message.replace(/\\n/g, '\n') : null
})

// Get translated options for dropdowns and toggles
const translatedOptions = computed(() => {
  // If we have translated options, use those
  if (props.question.options_translations && props.question.options_translations.length > 0) {
    return translateOptions(props.question.options_translations)
  }

  // Fallback to old options array (string[])
  if (props.question.options && props.question.options.length > 0) {
    return props.question.options.map(opt => ({ value: opt, label: opt }))
  }

  return []
})

// Create a computed v-model for the toggle
const toggleValue = computed({
  get: () => parseBoolean(props.modelValue ?? props.question.default_value),
  set: (value: boolean) => emit('update:modelValue', value)
})

// Helper to parse boolean values from strings
const parseBoolean = (value: any): boolean => {
  if (typeof value === 'boolean') return value
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true'
  }
  return false
}

// Helper to get rotation angle for orientation selector
const getOrientationAngle = (direction: string): number => {
  const angleMap: Record<string, number> = {
    'É': 0,      // North
    'ÉK': 45,    // Northeast
    'K': 90,     // East
    'DK': 135,   // Southeast
    'D': 180,    // South
    'DNy': 225,  // Southwest
    'Ny': 270,   // West
    'ÉNy': 315   // Northwest
  }
  return angleMap[direction] || 0
}

// Determine if the field should be readonly
// Only readonly if:
// 1. is_readonly is true AND
// 2. If has default_value_source, only readonly if the SOURCE field has a value
const isEffectivelyReadonly = computed(() => {
  if (!props.question.is_readonly) return false

  // If has default_value_source, check if the source field has a value
  if (props.question.default_value_source_question_id) {
    // Find the source question
    let sourceQuestion: SurveyQuestion | null = null
    let sourcePageId: string | null = null

    // Search through all pages to find the source question
    for (const investmentId in store.surveyPages) {
      const pages = store.surveyPages[investmentId]
      for (const page of pages) {
        const questions = store.surveyQuestions[page.id] || []
        const found = questions.find(q => q.id === props.question.default_value_source_question_id)
        if (found) {
          sourceQuestion = found
          sourcePageId = page.id
          break
        }
      }
      if (sourceQuestion) break
    }

    if (!sourceQuestion || !sourcePageId) {
      // Source question not found, don't make readonly
      return false
    }

    // Find which investment the source page belongs to
    let sourceInvestmentId: string | null = null
    for (const investmentId in store.surveyPages) {
      const pages = store.surveyPages[investmentId]
      if (pages.find(p => p.id === sourcePageId)) {
        sourceInvestmentId = investmentId
        break
      }
    }

    if (!sourceInvestmentId) {
      return false
    }

    // Check if the source field has a value
    // Get the value from the correct investment context
    const sourceValue = store.investmentResponses[sourceInvestmentId]?.[sourceQuestion.name]

    const hasSourceValue = sourceValue !== undefined &&
                          sourceValue !== null &&
                          sourceValue !== ''

    return hasSourceValue
  }

  // Otherwise, just use is_readonly
  return true
})
</script>
