<template>
  <span :class="computedClasses">
    <slot />
  </span>
</template>

<script setup lang="ts">
type BadgeVariant = 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info' | 'gray'
type BadgeSize = 'xs' | 'sm' | 'md' | 'lg'

interface Props {
  variant?: BadgeVariant
  size?: BadgeSize
  rounded?: boolean
  outline?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'sm',
  rounded: false,
  outline: false
})

const computedClasses = computed(() => {
  const classes = [
    'outfit',
    'font-medium',
    'inline-flex',
    'items-center',
    'justify-center',
    'transition-all'
  ]

  // Size classes
  const sizeClasses = {
    xs: 'px-1.5 py-0.5 text-xs',
    sm: 'px-2 py-1 text-xs',
    md: 'px-2.5 py-1 text-sm',
    lg: 'px-3 py-1.5 text-base'
  }
  classes.push(sizeClasses[props.size])

  // Shape
  if (props.rounded) {
    classes.push('rounded-full')
  } else {
    classes.push('rounded-md')
  }

  // Variant classes
  if (props.outline) {
    const outlineVariants = {
      primary: 'border-2 border-blue-500 text-blue-500 bg-transparent',
      secondary: 'border-2 border-gray-500 text-gray-500 bg-transparent',
      success: 'border-2 border-green-500 text-green-500 bg-transparent',
      danger: 'border-2 border-red-500 text-red-500 bg-transparent',
      warning: 'border-2 border-yellow-500 text-yellow-500 bg-transparent',
      info: 'border-2 border-cyan-500 text-cyan-500 bg-transparent',
      gray: 'border-2 border-gray-400 text-gray-600 bg-transparent'
    }
    classes.push(outlineVariants[props.variant])
  } else {
    const solidVariants = {
      primary: 'bg-blue-500 text-white',
      secondary: 'bg-gray-500 text-white',
      success: 'bg-green-500 text-white',
      danger: 'bg-red-500 text-white',
      warning: 'bg-yellow-500 text-white',
      info: 'bg-cyan-500 text-white',
      gray: 'bg-gray-200 text-gray-700'
    }
    classes.push(solidVariants[props.variant])
  }

  return classes.join(' ')
})
</script>
