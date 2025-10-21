<template>
  <div :class="['w-full', block ? '' : 'inline-block']">
    <label v-if="label" :for="inputId" class="outfit font-medium text-sm text-gray-700 dark:text-gray-300 mb-1.5 block">
      {{ label }}
      <span v-if="required" class="text-red-500 ml-1">*</span>
    </label>

    <div class="relative">
      <div v-if="$slots.prefix" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500">
        <slot name="prefix" />
      </div>

      <input
        :id="inputId"
        v-model="internalValue"
        :type="type"
        :placeholder="placeholder"
        :disabled="disabled"
        :readonly="readonly"
        :required="required"
        :autocomplete="autocomplete"
        :class="computedInputClasses"
        @focus="handleFocus"
        @blur="handleBlur"
        @input="handleInput"
      />

      <div v-if="$slots.suffix || clearable && internalValue" class="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-2">
        <button
          v-if="clearable && internalValue"
          type="button"
          @click="handleClear"
          class="text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400 transition-colors"
          aria-label="Clear input"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <div v-if="$slots.suffix" class="text-gray-400 dark:text-gray-500">
          <slot name="suffix" />
        </div>
      </div>
    </div>

    <p v-if="error" class="outfit text-sm text-red-500 mt-1.5">{{ error }}</p>
    <p v-else-if="hint" class="outfit text-sm text-gray-500 dark:text-gray-400 mt-1.5">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
type InputType = 'text' | 'email' | 'password' | 'number' | 'tel' | 'url' | 'search' | 'date' | 'time' | 'datetime-local'
type InputSize = 'sm' | 'md' | 'lg'
type InputVariant = 'default' | 'glass'

interface Props {
  modelValue?: string | number
  type?: InputType
  size?: InputSize
  variant?: InputVariant
  label?: string
  placeholder?: string
  error?: string
  hint?: string
  disabled?: boolean
  readonly?: boolean
  required?: boolean
  clearable?: boolean
  block?: boolean
  autocomplete?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  type: 'text',
  size: 'md',
  variant: 'default',
  disabled: false,
  readonly: false,
  required: false,
  clearable: false,
  block: true,
  autocomplete: 'off'
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  focus: [event: FocusEvent]
  blur: [event: FocusEvent]
  input: [value: string | number]
  clear: []
}>()

const inputId = computed(() => `input-${Math.random().toString(36).substr(2, 9)}`)
const isFocused = ref(false)

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const handleFocus = (event: FocusEvent) => {
  isFocused.value = true
  emit('focus', event)
}

const handleBlur = (event: FocusEvent) => {
  isFocused.value = false
  emit('blur', event)
}

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('input', target.value)
}

const handleClear = () => {
  emit('update:modelValue', '')
  emit('clear')
}

const computedInputClasses = computed(() => {
  const classes = [
    'outfit',
    'w-full',
    'border-2',
    'transition-all',
    'duration-200',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-1'
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
      'placeholder-gray-600',
      'focus:bg-white/50',
      'focus:ring-white'
    )
  } else {
    classes.push(
      'bg-white',
      'dark:bg-gray-800',
      'dark:text-white',
      'placeholder-gray-400',
      'dark:placeholder-gray-500'
    )
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
      'dark:border-blue-400',
      'focus:ring-blue-500',
      'dark:focus:ring-blue-400',
      'focus:border-blue-500',
      'dark:focus:border-blue-400'
    )
  } else {
    classes.push(
      'border-gray-300',
      'dark:border-gray-600',
      'hover:border-gray-400',
      'dark:hover:border-gray-500'
    )
  }

  // Disabled/readonly state
  if (props.disabled) {
    classes.push('opacity-60', 'cursor-not-allowed', 'bg-gray-100', 'dark:bg-gray-900')
  } else if (props.readonly) {
    classes.push('cursor-default', 'bg-gray-50', 'dark:bg-gray-900')
  }

  // Padding adjustments for prefix/suffix
  if ('prefix' in (getCurrentInstance()?.slots || {})) {
    classes.push('pl-10')
  }
  if ('suffix' in (getCurrentInstance()?.slots || {}) || (props.clearable && internalValue.value)) {
    classes.push('pr-10')
  }

  return classes.join(' ')
})
</script>
