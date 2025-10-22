<template>
  <NuxtLink
    v-if="to && !disabled && !loading"
    :to="to"
    :class="computedClasses"
  >
    <Icon v-if="icon && iconPosition === 'left'" :name="icon" class="mr-2" />
    <span v-if="$slots.icon && iconPosition === 'left'" class="inline-flex mr-2">
      <slot name="icon" />
    </span>
    <slot />
    <span v-if="$slots.icon && iconPosition === 'right'" class="inline-flex ml-2">
      <slot name="icon" />
    </span>
    <Icon v-if="icon && iconPosition === 'right'" :name="icon" class="ml-2" />
  </NuxtLink>
  <button
    v-else
    :type="type"
    :disabled="disabled || loading"
    :class="computedClasses"
    @click="handleClick"
  >
    <span v-if="loading" class="inline-block mr-2">
      <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </span>
    <Icon v-if="icon && iconPosition === 'left'" :name="icon" class="mr-2" />
    <span v-if="$slots.icon && iconPosition === 'left'" class="inline-flex mr-2">
      <slot name="icon" />
    </span>
    <slot />
    <span v-if="$slots.icon && iconPosition === 'right'" class="inline-flex ml-2">
      <slot name="icon" />
    </span>
    <Icon v-if="icon && iconPosition === 'right'" :name="icon" class="ml-2" />
  </button>
</template>

<script setup lang="ts">
type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'success' | 'glass'
type ButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl'
type ButtonType = 'button' | 'submit' | 'reset'
type IconPosition = 'left' | 'right'

interface Props {
  variant?: ButtonVariant
  size?: ButtonSize
  type?: ButtonType
  disabled?: boolean
  loading?: boolean
  block?: boolean
  iconPosition?: IconPosition
  to?: string
  icon?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  type: 'button',
  disabled: false,
  loading: false,
  block: false,
  iconPosition: 'left'
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const handleClick = (event: MouseEvent) => {
  if (!props.disabled && !props.loading) {
    emit('click', event)
  }
}

const computedClasses = computed(() => {
  const classes = [
    'outfit',
    'font-medium',
    'inline-flex',
    'items-center',
    'justify-center',
    'transition-all',
    'duration-200',
    'focus:outline-none',
    'focus:ring-2',
    'focus:ring-offset-2'
  ]

  // Size classes
  const sizeClasses = {
    xs: 'px-2 py-1 text-xs rounded-lg',
    sm: 'px-3 py-1.5 text-sm rounded-lg',
    md: 'px-4 py-2 text-base rounded-xl',
    lg: 'px-6 py-3 text-lg rounded-2xl',
    xl: 'px-8 py-4 text-xl rounded-2xl'
  }
  classes.push(sizeClasses[props.size])

  // Variant classes
  const variantClasses = {
    primary: [
      'bg-blue-500',
      'text-white',
      'border-2',
      'border-blue-500',
      'hover:bg-blue-600',
      'hover:border-blue-600',
      'focus:ring-blue-500',
      'active:bg-blue-700',
      'shadow-md',
      'hover:shadow-lg'
    ],
    secondary: [
      'bg-gray-500',
      'text-white',
      'border-2',
      'border-gray-500',
      'hover:bg-gray-600',
      'hover:border-gray-600',
      'focus:ring-gray-500',
      'active:bg-gray-700',
      'shadow-md',
      'hover:shadow-lg'
    ],
    outline: [
      'bg-transparent',
      'text-blue-500',
      'border-2',
      'border-blue-500',
      'hover:bg-blue-50',
      'hover:border-blue-600',
      'hover:text-blue-600',
      'focus:ring-blue-500',
      'active:bg-blue-100'
    ],
    ghost: [
      'bg-transparent',
      'text-gray-700',
      'border-2',
      'border-transparent',
      'hover:bg-gray-100',
      'focus:ring-gray-400',
      'active:bg-gray-200'
    ],
    danger: [
      'bg-red-500',
      'text-white',
      'border-2',
      'border-red-500',
      'hover:bg-red-600',
      'hover:border-red-600',
      'focus:ring-red-500',
      'active:bg-red-700',
      'shadow-md',
      'hover:shadow-lg'
    ],
    success: [
      'bg-green-500',
      'text-white',
      'border-2',
      'border-green-500',
      'hover:bg-green-600',
      'hover:border-green-600',
      'focus:ring-green-500',
      'active:bg-green-700',
      'shadow-md',
      'hover:shadow-lg'
    ],
    glass: [
      'bg-white/30',
      'text-gray-800',
      'border-2',
      'border-white',
      'backdrop-blur-xl',
      'hover:bg-white/50',
      'focus:ring-white',
      'shadow-lg',
      'hover:shadow-xl'
    ]
  }
  classes.push(...variantClasses[props.variant])

  // Block class
  if (props.block) {
    classes.push('w-full')
  }

  // Disabled/Loading state
  if (props.disabled || props.loading) {
    classes.push('opacity-50', 'cursor-not-allowed')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
})
</script>
