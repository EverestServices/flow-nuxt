<template>
  <div :class="computedCardClasses">
    <div v-if="$slots.header || title" :class="headerClasses">
      <slot name="header">
        <h3 class="outfit font-bold text-lg">{{ title }}</h3>
      </slot>
    </div>

    <div :class="bodyClasses">
      <slot />
    </div>

    <div v-if="$slots.footer" :class="footerClasses">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
type CardVariant = 'default' | 'glass' | 'outline' | 'elevated'

interface Props {
  variant?: CardVariant
  title?: string
  padding?: string
  hoverable?: boolean
  clickable?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  padding: 'p-6',
  hoverable: false,
  clickable: false
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const handleClick = (event: MouseEvent) => {
  if (props.clickable) {
    emit('click', event)
  }
}

const computedCardClasses = computed(() => {
  const classes = [
    'rounded-2xl',
    'transition-all',
    'duration-200',
    'overflow-hidden'
  ]

  // Variant classes
  const variantClasses = {
    default: ['bg-white', 'border', 'border-gray-200'],
    glass: ['bg-white/30', 'backdrop-blur-xl', 'border', 'border-white', 'shadow-lg'],
    outline: ['bg-transparent', 'border-2', 'border-gray-300'],
    elevated: ['bg-white', 'shadow-xl']
  }
  classes.push(...variantClasses[props.variant])

  // Interactive states
  if (props.hoverable) {
    classes.push('hover:shadow-2xl', 'hover:-translate-y-1')
  }

  if (props.clickable) {
    classes.push('cursor-pointer', 'hover:shadow-lg')
  }

  return classes.join(' ')
})

const headerClasses = computed(() => {
  return `${props.padding} border-b border-gray-200`
})

const bodyClasses = computed(() => {
  return props.padding
})

const footerClasses = computed(() => {
  return `${props.padding} border-t border-gray-200 bg-gray-50`
})
</script>
