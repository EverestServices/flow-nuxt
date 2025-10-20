<template>
  <div class="inline-flex items-center gap-3">
    <button
      type="button"
      role="switch"
      :aria-checked="internalValue"
      :aria-label="label || ariaLabel"
      :disabled="disabled"
      :class="computedSwitchClasses"
      @click="toggle"
    >
      <span :class="computedThumbClasses" />
    </button>

    <label v-if="label || $slots.default" :class="computedLabelClasses" @click="toggle">
      <slot>{{ label }}</slot>
    </label>
  </div>
</template>

<script setup lang="ts">
type SwitchSize = 'sm' | 'md' | 'lg'

interface Props {
  modelValue?: boolean
  size?: SwitchSize
  label?: string
  ariaLabel?: string
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false,
  size: 'md',
  disabled: false
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  change: [value: boolean]
}>()

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const toggle = () => {
  if (!props.disabled) {
    internalValue.value = !internalValue.value
    emit('change', internalValue.value)
  }
}

const computedSwitchClasses = computed(() => {
  const classes = [
    'relative',
    'inline-flex',
    'items-center',
    'rounded-full',
    'transition-all',
    'duration-200',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-2',
    'focus:ring-blue-500'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'w-9 h-5',
    md: 'w-11 h-6',
    lg: 'w-14 h-7'
  }
  classes.push(sizeClasses[props.size])

  // State classes
  if (internalValue.value) {
    classes.push('bg-blue-500')
  } else {
    classes.push('bg-gray-300')
  }

  // Disabled state
  if (props.disabled) {
    classes.push('opacity-50', 'cursor-not-allowed')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
})

const computedThumbClasses = computed(() => {
  const classes = [
    'inline-block',
    'rounded-full',
    'bg-white',
    'shadow-lg',
    'transition-transform',
    'duration-200'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-5 h-5',
    lg: 'w-6 h-6'
  }
  classes.push(sizeClasses[props.size])

  // Position based on state
  const positionClasses = {
    sm: internalValue.value ? 'translate-x-4' : 'translate-x-0.5',
    md: internalValue.value ? 'translate-x-5' : 'translate-x-0.5',
    lg: internalValue.value ? 'translate-x-7' : 'translate-x-0.5'
  }
  classes.push(positionClasses[props.size])

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
