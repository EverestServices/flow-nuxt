<template>
  <div :class="computedClasses">
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
interface Props {
  rounded?: string
  shadow?: string
  background?: string
  textColor?: string
  border?: string
  hover?: string
  transition?: boolean
  blur?: string
  width?: string
  padding?: string
  class?: string
}

const props = withDefaults(defineProps<Props>(), {
  rounded: 'rounded-4xl',
  shadow: 'shadow-lg',
  background: 'bg-white/30',
  textColor: '',
  border: 'border border-white',
  hover: 'hover:bg-white/30',
  transition: true,
  blur: 'backdrop-blur-md',
  width: '',
  padding: '',
  class: ''
})

const computedClasses = computed(() => {
  const classes = [
    props.rounded,
    props.background,
    props.blur,
    props.border,
    'font-medium',
    props.shadow,
    props.hover,
    props.width,
    props.textColor,
    props.padding,
    props.class
  ]

  if (props.transition) {
    classes.push('transition')
  }

  return classes.filter(Boolean).join(' ')
})
</script>