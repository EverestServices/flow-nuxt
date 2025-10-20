<template>
  <div :class="['w-full', block ? '' : 'inline-block']">
    <label v-if="label" :for="selectId" class="outfit font-medium text-sm text-gray-700 mb-1.5 block">
      {{ label }}
      <span v-if="required" class="text-red-500 ml-1">*</span>
    </label>

    <div class="relative">
      <select
        :id="selectId"
        v-model="internalValue"
        :disabled="disabled"
        :required="required"
        :class="computedSelectClasses"
        @change="handleChange"
        @focus="handleFocus"
        @blur="handleBlur"
      >
        <option v-if="placeholder" value="" disabled>{{ placeholder }}</option>
        <option
          v-for="option in options"
          :key="getOptionValue(option)"
          :value="getOptionValue(option)"
        >
          {{ getOptionLabel(option) }}
        </option>
      </select>

      <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </div>

    <p v-if="error" class="outfit text-sm text-red-500 mt-1.5">{{ error }}</p>
    <p v-else-if="hint" class="outfit text-sm text-gray-500 mt-1.5">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
type SelectSize = 'sm' | 'md' | 'lg'
type SelectVariant = 'default' | 'glass'
type Option = string | number | { label: string; value: any; [key: string]: any }

interface Props {
  modelValue?: any
  size?: SelectSize
  variant?: SelectVariant
  label?: string
  placeholder?: string
  options?: Option[]
  error?: string
  hint?: string
  disabled?: boolean
  required?: boolean
  block?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  size: 'md',
  variant: 'default',
  options: () => [],
  disabled: false,
  required: false,
  block: true
})

const emit = defineEmits<{
  'update:modelValue': [value: any]
  change: [value: any]
  focus: [event: FocusEvent]
  blur: [event: FocusEvent]
}>()

const selectId = computed(() => `select-${Math.random().toString(36).substr(2, 9)}`)
const isFocused = ref(false)

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const getOptionValue = (option: Option) => {
  if (typeof option === 'object' && option !== null) {
    return option.value
  }
  return option
}

const getOptionLabel = (option: Option) => {
  if (typeof option === 'object' && option !== null) {
    return option.label
  }
  return String(option)
}

const handleChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  emit('change', target.value)
}

const handleFocus = (event: FocusEvent) => {
  isFocused.value = true
  emit('focus', event)
}

const handleBlur = (event: FocusEvent) => {
  isFocused.value = false
  emit('blur', event)
}

const computedSelectClasses = computed(() => {
  const classes = [
    'outfit',
    'w-full',
    'border-2',
    'transition-all',
    'duration-200',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-1',
    'appearance-none',
    'pr-10'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm rounded-lg',
    md: 'px-4 py-2.5 text-base rounded-xl',
    lg: 'px-5 py-3 text-lg rounded-xl'
  }
  classes.push(sizeClasses[props.size])

  // Variant classes
  if (props.variant === 'glass') {
    classes.push(
      'bg-white/30',
      'backdrop-blur-xl',
      'border-white',
      'focus:bg-white/50',
      'focus:ring-white'
    )
  } else {
    classes.push('bg-white')
  }

  // Error state
  if (props.error) {
    classes.push(
      'border-red-500',
      'focus:ring-red-500',
      'focus:border-red-500'
    )
  } else if (isFocused.value) {
    classes.push(
      'border-blue-500',
      'focus:ring-blue-500',
      'focus:border-blue-500'
    )
  } else {
    classes.push(
      'border-gray-300',
      'hover:border-gray-400'
    )
  }

  // Disabled state
  if (props.disabled) {
    classes.push('opacity-60', 'cursor-not-allowed', 'bg-gray-100')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
})
</script>
