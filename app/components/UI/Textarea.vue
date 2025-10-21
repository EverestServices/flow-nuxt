<template>
  <div :class="['w-full', block ? '' : 'inline-block']">
    <label v-if="label" :for="textareaId" class="outfit font-medium text-sm text-gray-700 dark:text-gray-300 mb-1.5 block">
      {{ label }}
      <span v-if="required" class="text-red-500 ml-1">*</span>
    </label>

    <div class="relative">
      <textarea
        :id="textareaId"
        v-model="internalValue"
        :placeholder="placeholder"
        :disabled="disabled"
        :readonly="readonly"
        :required="required"
        :rows="rows"
        :maxlength="maxLength"
        :class="computedTextareaClasses"
        @focus="handleFocus"
        @blur="handleBlur"
        @input="handleInput"
      />

      <div v-if="maxLength" class="absolute bottom-2 right-3 text-xs text-gray-400 dark:text-gray-500">
        {{ characterCount }} / {{ maxLength }}
      </div>
    </div>

    <p v-if="error" class="outfit text-sm text-red-500 mt-1.5">{{ error }}</p>
    <p v-else-if="hint" class="outfit text-sm text-gray-500 dark:text-gray-400 mt-1.5">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
type TextareaSize = 'sm' | 'md' | 'lg'
type TextareaVariant = 'default' | 'glass'

interface Props {
  modelValue?: string
  size?: TextareaSize
  variant?: TextareaVariant
  label?: string
  placeholder?: string
  error?: string
  hint?: string
  disabled?: boolean
  readonly?: boolean
  required?: boolean
  block?: boolean
  rows?: number
  maxLength?: number
  autoResize?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  size: 'md',
  variant: 'default',
  disabled: false,
  readonly: false,
  required: false,
  block: true,
  rows: 4,
  autoResize: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  focus: [event: FocusEvent]
  blur: [event: FocusEvent]
  input: [value: string]
}>()

const textareaId = computed(() => `textarea-${Math.random().toString(36).substr(2, 9)}`)
const isFocused = ref(false)

const internalValue = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const characterCount = computed(() => (props.modelValue || '').length)

const handleFocus = (event: FocusEvent) => {
  isFocused.value = true
  emit('focus', event)
}

const handleBlur = (event: FocusEvent) => {
  isFocused.value = false
  emit('blur', event)
}

const handleInput = (event: Event) => {
  const target = event.target as HTMLTextAreaElement
  emit('input', target.value)

  // Auto resize logic
  if (props.autoResize) {
    target.style.height = 'auto'
    target.style.height = `${target.scrollHeight}px`
  }
}

const computedTextareaClasses = computed(() => {
  const classes = [
    'outfit',
    'w-full',
    'border-2',
    'transition-all',
    'duration-200',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-1',
    'resize-none'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'px-3 py-2 text-sm rounded-lg',
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

  // Extra padding for character count
  if (props.maxLength) {
    classes.push('pb-6')
  }

  return classes.join(' ')
})
</script>
