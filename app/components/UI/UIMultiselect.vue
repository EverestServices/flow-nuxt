<template>
  <div class="relative">
    <!-- Trigger button -->
    <button
      type="button"
      :disabled="disabled"
      class="w-full px-3 py-2 text-left bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
      @click="isOpen = !isOpen"
    >
      <span v-if="internalValue.length === 0" class="text-gray-400">
        {{ placeholder }}
      </span>
      <span v-else class="truncate block">
        {{ displayedLabels }}
      </span>
    </button>

    <!-- Dropdown panel -->
    <div
      v-if="isOpen"
      class="absolute z-50 w-full mt-1 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md shadow-lg max-h-60 overflow-y-auto"
    >
      <!-- Search input -->
      <div class="sticky top-0 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 p-2">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Keresés..."
          class="w-full px-3 py-1.5 text-sm bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      <!-- Options list -->
      <div class="p-2">
        <label
          v-for="option in filteredOptions"
          :key="option.value"
          class="flex items-start gap-2 px-2 py-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded cursor-pointer"
        >
          <input
            type="checkbox"
            :checked="internalValue.includes(option.value)"
            :disabled="disabled"
            class="mt-0.5 h-4 w-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            @change="toggleOption(option.value)"
          />
          <span class="text-sm text-gray-900 dark:text-gray-100 flex-1">
            {{ option.label }}
          </span>
        </label>

        <div v-if="filteredOptions.length === 0" class="px-2 py-4 text-sm text-gray-500 text-center">
          Nincs találat
        </div>
      </div>
    </div>
  </div>

  <!-- Click outside to close -->
  <div v-if="isOpen" class="fixed inset-0 z-40" @click="isOpen = false" />
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

interface Option {
  value: string
  label: string
}

interface Props {
  modelValue?: string | string[]
  options: Option[]
  placeholder?: string
  disabled?: boolean
  required?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: undefined,
  placeholder: 'Válasszon egy vagy több opciót',
  disabled: false,
  required: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

// Local state
const isOpen = ref(false)
const searchQuery = ref('')

// Internal value as array
const internalValue = computed((): string[] => {
  const value = props.modelValue
  if (!value) return []

  // If it's already an array, return it
  if (Array.isArray(value)) return value

  // If it's a JSON string array, parse it
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value)
      return Array.isArray(parsed) ? parsed : [value]
    } catch {
      // If not JSON, treat as comma-separated
      return value.split(',').map(v => v.trim()).filter(v => v !== '')
    }
  }

  return []
})

// Toggle an option
const toggleOption = (value: string) => {
  const currentValues = [...internalValue.value]
  const index = currentValues.indexOf(value)

  if (index > -1) {
    // Remove if already selected
    currentValues.splice(index, 1)
  } else {
    // Add if not selected
    currentValues.push(value)
  }

  // Emit as JSON string array for consistency with database storage
  emit('update:modelValue', JSON.stringify(currentValues))
}

// Filter options based on search query
const filteredOptions = computed(() => {
  if (!searchQuery.value.trim()) {
    return props.options
  }

  const query = searchQuery.value.toLowerCase()
  return props.options.filter(option =>
    option.label.toLowerCase().includes(query)
  )
})

// Get displayed labels for selected values
const displayedLabels = computed(() => {
  const selectedValues = internalValue.value
  if (selectedValues.length === 0) return ''

  // Map values to labels
  const labels = selectedValues
    .map(val => {
      const option = props.options.find(opt => opt.value === val)
      return option ? option.label : val
    })

  return labels.join(', ')
})
</script>
