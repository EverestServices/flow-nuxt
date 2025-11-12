<template>
  <div class="survey-question">
    <!-- Title Type (just displays text) -->
    <div v-if="question.type === 'title'" class="font-semibold text-gray-900 dark:text-white">
      {{ questionLabel }}
    </div>

    <!-- Warning Type (displays info/warning message) -->
    <div v-else-if="question.type === 'warning'" class="flex items-start gap-2 p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
      <span class="text-sm text-blue-800 dark:text-blue-200">
        {{ questionLabel }}
      </span>
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
        :model-value="modelValue || question.default_value || ''"
        :options="dropdownOptions"
        :placeholder="question.is_required ? (questionPlaceholder || 'Select an option') : undefined"
        :required="question.is_required"
        :disabled="isEffectivelyReadonly"
        size="md"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>

    <!-- Multiselect -->
    <div v-else-if="question.type === 'multiselect'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <UIMultiselect
        :model-value="modelValue || question.default_value"
        :options="translatedOptions"
        :placeholder="questionPlaceholder || 'Válasszon egy vagy több opciót'"
        :disabled="isEffectivelyReadonly"
        :required="question.is_required"
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

    <!-- Icon Selector (buttons with custom icons) -->
    <div v-else-if="question.type === 'icon_selector'">
      <div class="flex items-center gap-2 mb-2">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
      </div>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="option in translatedOptionsWithIcons"
          :key="option.value"
          :disabled="isEffectivelyReadonly"
          class="px-4 py-3 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative min-w-[100px]"
          :class="[
            (modelValue || question.default_value) === option.value
              ? 'bg-primary-500 text-white shadow-md'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600',
            isEffectivelyReadonly ? 'opacity-60 cursor-not-allowed hover:scale-100' : ''
          ]"
          @click="$emit('update:modelValue', option.value)"
        >
          <UIcon
            v-if="option.icon"
            :name="option.icon"
            class="w-8 h-8 mb-1"
          />
          <span class="text-sm font-medium">{{ option.label }}</span>
        </button>
      </div>
    </div>

    <!-- Calculated Field (read-only card showing computed value) -->
    <div v-else-if="question.type === 'calculated'">
      <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
              {{ questionLabel }}
            </span>
            <SurveyQuestionInfoTooltip :info-message="questionInfoMessage" />
          </div>
          <span class="text-lg font-semibold text-gray-900 dark:text-white">
            {{ calculatedValue }}
            <span v-if="questionUnit" class="text-sm text-gray-500 dark:text-gray-400 ml-1">
              {{ questionUnit }}
            </span>
          </span>
        </div>
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

// Process template variables in text
const processTemplateVariables = (text: string): string => {
  if (!text || !props.question.template_variables) {
    return text
  }

  let processedText = text

  // Find all template variables: {variableName}
  const templateVarRegex = /\{([^}]+)\}/g
  const matches = text.match(templateVarRegex)

  if (!matches) {
    return text
  }

  // Process each template variable
  for (const match of matches) {
    const varName = match.slice(1, -1) // Remove { and }
    const varDef = props.question.template_variables[varName]

    if (!varDef) {
      continue // Variable not defined, skip
    }

    let replacement = ''

    switch (varDef.type) {
      case 'matched_conditional_values': {
        // Get values that match the display_conditions
        if (!props.question.display_conditions) {
          break
        }

        let fieldValue = store.getResponse(varDef.field)

        // If no value found, try to get default value from the question
        if (!fieldValue) {
          for (const investmentId in store.surveyPages) {
            const pages = store.surveyPages[investmentId]
            for (const page of pages) {
              const questions = store.surveyQuestions[page.id] || []
              const question = questions.find(q => q.name === varDef.field)
              if (question && question.default_value) {
                fieldValue = question.default_value
                break
              }
            }
            if (fieldValue) break
          }
        }

        if (!fieldValue) {
          break
        }

        // Parse field value to array
        let fieldArray: string[] = []
        if (Array.isArray(fieldValue)) {
          fieldArray = fieldValue
        } else if (typeof fieldValue === 'string') {
          try {
            const parsed = JSON.parse(fieldValue)
            fieldArray = Array.isArray(parsed) ? parsed : [fieldValue]
          } catch {
            fieldArray = fieldValue.split(',').map(v => v.trim())
          }
        }

        // Get conditional values
        const conditionalValues = Array.isArray(props.question.display_conditions.value)
          ? props.question.display_conditions.value
          : [props.question.display_conditions.value]

        // Find matched values (values that are both selected AND in conditions)
        const matchedValues = fieldArray.filter(fv =>
          conditionalValues.some(cv => fv === cv)
        )

        replacement = matchedValues.join(', ')
        break
      }

      case 'field_value': {
        // Get direct field value
        let fieldValue = store.getResponse(varDef.field)

        // If no value found, try to get default value from the question
        if (!fieldValue) {
          // Find the question by name across all investments and pages
          for (const investmentId in store.surveyPages) {
            const pages = store.surveyPages[investmentId]
            for (const page of pages) {
              const questions = store.surveyQuestions[page.id] || []
              const question = questions.find(q => q.name === varDef.field)
              if (question && question.default_value) {
                fieldValue = question.default_value
                break
              }
            }
            if (fieldValue) break
          }
        }

        replacement = fieldValue ? String(fieldValue) : ''
        break
      }

      case 'conditional_count': {
        // Count how many conditional values are selected
        if (!props.question.display_conditions) {
          replacement = '0'
          break
        }

        let fieldValue = store.getResponse(varDef.field)

        // If no value found, try to get default value from the question
        if (!fieldValue) {
          for (const investmentId in store.surveyPages) {
            const pages = store.surveyPages[investmentId]
            for (const page of pages) {
              const questions = store.surveyQuestions[page.id] || []
              const question = questions.find(q => q.name === varDef.field)
              if (question && question.default_value) {
                fieldValue = question.default_value
                break
              }
            }
            if (fieldValue) break
          }
        }

        if (!fieldValue) {
          replacement = '0'
          break
        }

        let fieldArray: string[] = []
        if (Array.isArray(fieldValue)) {
          fieldArray = fieldValue
        } else if (typeof fieldValue === 'string') {
          try {
            const parsed = JSON.parse(fieldValue)
            fieldArray = Array.isArray(parsed) ? parsed : [fieldValue]
          } catch {
            fieldArray = fieldValue.split(',').map(v => v.trim())
          }
        }

        const conditionalValues = Array.isArray(props.question.display_conditions.value)
          ? props.question.display_conditions.value
          : [props.question.display_conditions.value]

        const matchedCount = fieldArray.filter(fv =>
          conditionalValues.some(cv => fv === cv)
        ).length

        replacement = String(matchedCount)
        break
      }
    }

    // Replace the template variable with the computed value
    processedText = processedText.replace(match, replacement)
  }

  return processedText
}

// Get translated label for the question
const questionLabel = computed(() => {
  // Priority: name_translations > translateField > name
  const rawLabel = translate(props.question.name_translations, translateField(props.question.name))

  // Process template variables if any
  return processTemplateVariables(rawLabel)
})

// Get translated placeholder
const questionPlaceholder = computed(() => {
  const rawPlaceholder = translate(props.question.placeholder_translations, props.question.placeholder_value)

  // Process template variables in placeholder if enabled
  if (props.question.apply_template_to_placeholder && rawPlaceholder) {
    return processTemplateVariables(rawPlaceholder)
  }

  return rawPlaceholder
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

// Get translated options with icons (for icon_selector type)
const translatedOptionsWithIcons = computed(() => {
  if (!props.question.options_translations || props.question.options_translations.length === 0) {
    return []
  }

  // Return options with icon field preserved
  return props.question.options_translations.map(opt => ({
    value: opt.value,
    label: translate(opt.label, opt.value),
    icon: opt.icon
  }))
})

// Get options with empty option for non-required dropdowns
const dropdownOptions = computed(() => {
  const options = [...translatedOptions.value]

  // Add placeholder as empty option at the beginning if not required
  if (!props.question.is_required && props.question.type === 'dropdown') {
    const placeholderText = questionPlaceholder.value || 'Válasszon opciót'
    options.unshift({ value: '', label: placeholderText })
  }

  return options
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

// Calculate value for calculated fields
const calculatedValue = computed(() => {
  if (props.question.type !== 'calculated' || !props.question.options) {
    return '—'
  }

  try {
    const formula = props.question.options as { operation: string; fields: string[]; decimals?: number }

    if (!formula.operation || !formula.fields || formula.fields.length === 0) {
      return '—'
    }

    // Get values for all fields in the formula
    const values: number[] = []
    for (const fieldName of formula.fields) {
      const value = store.getResponse(fieldName)
      const numValue = parseFloat(value)

      if (isNaN(numValue) || value === null || value === undefined || value === '') {
        return '—'
      }

      values.push(numValue)
    }

    // Perform the calculation
    let result = 0
    switch (formula.operation) {
      case 'multiply':
        result = values.reduce((acc, val) => acc * val, 1)
        break
      case 'add':
        result = values.reduce((acc, val) => acc + val, 0)
        break
      case 'subtract':
        result = values.reduce((acc, val, idx) => idx === 0 ? val : acc - val, 0)
        break
      case 'divide':
        result = values.reduce((acc, val, idx) => {
          if (idx === 0) return val
          if (val === 0) return 0 // Prevent division by zero
          return acc / val
        }, 0)
        break
      default:
        return '—'
    }

    // Format with specified decimals (default 2)
    const decimals = formula.decimals ?? 2
    return result.toFixed(decimals)
  } catch (error) {
    console.error('Error calculating value:', error)
    return '—'
  }
})
</script>
