<template>
  <div class="survey-question">
    <!-- Title Type (just displays text) -->
    <div v-if="question.type === 'title'" class="font-semibold text-gray-900 dark:text-white">
      {{ questionLabel }}
    </div>

    <!-- Text Input -->
    <div v-else-if="question.type === 'text' || question.type === 'number'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <div class="flex items-center space-x-2">
        <UInput
          :model-value="modelValue || question.default_value"
          :type="question.type === 'number' ? 'number' : 'text'"
          :placeholder="question.placeholder_value"
          :required="question.is_required"
          :min="question.min"
          :max="question.max"
          class="flex-1"
          @update:model-value="$emit('update:modelValue', $event)"
        />
        <span v-if="question.unit" class="text-sm text-gray-500 dark:text-gray-400">
          {{ question.unit }}
        </span>
      </div>
    </div>

    <!-- Textarea -->
    <div v-else-if="question.type === 'textarea'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <UTextarea
        :model-value="modelValue || question.default_value"
        :placeholder="question.placeholder_value"
        :required="question.is_required"
        :rows="4"
        class="w-full"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>

    <!-- Dropdown -->
    <div v-else-if="question.type === 'dropdown'">
      <UISelect
        :model-value="modelValue || question.default_value"
        :label="questionLabel"
        :options="question.options || []"
        :placeholder="question.placeholder_value || 'Select an option'"
        :required="question.is_required"
        size="md"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>

    <!-- Switch/Toggle -->
    <div v-else-if="question.type === 'switch'">
      <div class="flex items-center justify-between">
        <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ questionLabel }}
          <span v-if="question.is_required" class="text-red-500">*</span>
        </label>
        <USwitch v-model="toggleValue" />
      </div>
    </div>

    <!-- Slider -->
    <div v-else-if="question.type === 'slider'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <div class="flex items-center space-x-4">
        <input
          :value="modelValue || question.default_value || question.min || 0"
          type="range"
          :min="question.min || 0"
          :max="question.max || 100"
          :step="question.step || 1"
          class="flex-1"
          @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        />
        <span class="text-sm font-medium text-gray-900 dark:text-white min-w-[60px] text-right">
          {{ modelValue || question.default_value || question.min || 0 }}{{ question.unit || '' }}
        </span>
      </div>
    </div>

    <!-- Dual Toggle (Two options) -->
    <div v-else-if="question.type === 'dual_toggle'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <div class="flex items-center space-x-2">
        <button
          v-for="option in question.options"
          :key="option"
          class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          :class="(modelValue || question.default_value) === option
            ? 'bg-primary-500 text-white'
            : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
          @click="$emit('update:modelValue', option)"
        >
          {{ option }}
        </button>
      </div>
    </div>

    <!-- Phase Toggle (1 or 3) -->
    <div v-else-if="question.type === 'phase_toggle'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <div class="flex items-center space-x-2">
        <button
          v-for="option in question.options"
          :key="option"
          class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          :class="(modelValue || question.default_value) === option
            ? 'bg-primary-500 text-white'
            : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
          @click="$emit('update:modelValue', option)"
        >
          {{ option }} fázis
        </button>
      </div>
    </div>

    <!-- Orientation Selector (8 directions) -->
    <div v-else-if="question.type === 'orientation_selector'">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {{ questionLabel }}
        <span v-if="question.is_required" class="text-red-500">*</span>
      </label>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="option in question.options"
          :key="option"
          class="w-14 h-14 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative"
          :class="(modelValue || question.default_value) === option
            ? 'bg-primary-500 text-white shadow-md'
            : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600'"
          @click="$emit('update:modelValue', option)"
        >
          <UIcon
            name="i-lucide-navigation"
            class="w-6 h-6 transition-transform"
            :style="{ transform: `rotate(${getOrientationAngle(option)}deg)` }"
          />
          <span class="text-xs font-medium mt-0.5">{{ option }}</span>
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

interface Props {
  question: SurveyQuestion
  modelValue?: any
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: any]
}>()

// Translations
const { translateField } = useI18n()

// Get translated label for the question
const questionLabel = computed(() => {
  return props.question.placeholder_value || translateField(props.question.name)
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
</script>
