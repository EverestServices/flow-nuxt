<template>
  <div class="inline-flex items-start gap-2">
    <div class="relative flex items-center">
      <input
        :id="radioId"
        v-model="internalValue"
        type="radio"
        :value="value"
        :name="name"
        :disabled="disabled"
        :required="required"
        :class="computedRadioClasses"
        @change="handleChange"
      />
      <div v-if="isChecked && !disabled" class="absolute inset-0 pointer-events-none flex items-center justify-center">
        <div :class="['rounded-full bg-white', dotSizeClass]"></div>
      </div>
    </div>

    <label v-if="label || $slots.default" :for="radioId" :class="computedLabelClasses">
      <slot>{{ label }}</slot>
    </label>
  </div>
</template>

<script setup lang="ts">
type RadioSize = 'sm' | 'md' | 'lg'

interface Props {
  modelValue?: any
  value: any
  size?: RadioSize
  label?: string
  name?: string
  disabled?: boolean
  required?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  disabled: false,
  required: false
})

const emit = defineEmits<{
  'update:modelValue': [value: any]
  change: [value: any]
}>()

const radioId = computed(() => `radio-${Math.random().toString(36).substr(2, 9)}`)

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const isChecked = computed(() => props.modelValue === props.value)

const handleChange = () => {
  emit('change', props.value)
}

const dotSizeClass = computed(() => {
  const sizes = {
    sm: 'w-1.5 h-1.5',
    md: 'w-2 h-2',
    lg: 'w-2.5 h-2.5'
  }
  return sizes[props.size]
})

const computedRadioClasses = computed(() => {
  const classes = [
    'appearance-none',
    'border-2',
    'rounded-full',
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
  if (isChecked.value) {
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
