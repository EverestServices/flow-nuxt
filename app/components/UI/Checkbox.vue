<template>
  <div class="inline-flex items-start gap-2">
    <div class="relative flex items-center">
      <input
        :id="checkboxId"
        v-model="internalValue"
        type="checkbox"
        :disabled="disabled"
        :required="required"
        :class="computedCheckboxClasses"
        @change="handleChange"
      />
      <div v-if="internalValue && !disabled" class="absolute inset-0 pointer-events-none flex items-center justify-center">
        <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
        </svg>
      </div>
    </div>

    <label v-if="label || $slots.default" :for="checkboxId" :class="computedLabelClasses">
      <slot>{{ label }}</slot>
    </label>
  </div>
</template>

<script setup lang="ts">
type CheckboxSize = 'sm' | 'md' | 'lg'

interface Props {
  modelValue?: boolean
  size?: CheckboxSize
  label?: string
  disabled?: boolean
  required?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false,
  size: 'md',
  disabled: false,
  required: false
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  change: [value: boolean]
}>()

const checkboxId = computed(() => `checkbox-${Math.random().toString(36).substr(2, 9)}`)

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const handleChange = () => {
  emit('change', internalValue.value)
}

const computedCheckboxClasses = computed(() => {
  const classes = [
    'appearance-none',
    'border-2',
    'rounded-md',
    'transition-all',
    'duration-200',
    'cursor-pointer',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-1',
    'focus:ring-blue-500'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-5 h-5',
    lg: 'w-6 h-6'
  }
  classes.push(sizeClasses[props.size])

  // State classes
  if (internalValue.value) {
    classes.push('bg-blue-500', 'border-blue-500')
  } else {
    classes.push('bg-white', 'border-gray-300', 'hover:border-gray-400')
  }

  // Disabled state
  if (props.disabled) {
    classes.push('opacity-50', 'cursor-not-allowed')
  }

  return classes.join(' ')
})

const computedLabelClasses = computed(() => {
  const classes = [
    'outfit',
    'text-gray-700',
    'select-none'
  ]

  // Size-based text
  const sizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg'
  }
  classes.push(sizeClasses[props.size])

  if (props.disabled) {
    classes.push('opacity-50', 'cursor-not-allowed')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
})
</script>
