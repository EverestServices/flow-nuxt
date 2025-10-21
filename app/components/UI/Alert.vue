<template>
  <div v-if="!dismissed" :class="computedClasses" role="alert">
    <div class="flex items-start gap-3">
      <div v-if="!hideIcon" class="flex-shrink-0">
        <component :is="iconComponent" class="w-5 h-5" />
      </div>

      <div class="flex-1">
        <h4 v-if="title" class="outfit font-bold mb-1">{{ title }}</h4>
        <div class="outfit text-sm">
          <slot />
        </div>
      </div>

      <button
        v-if="dismissible"
        @click="handleDismiss"
        class="flex-shrink-0 text-current opacity-60 hover:opacity-100 transition-opacity"
        aria-label="Dismiss"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { h } from 'vue'

type AlertVariant = 'info' | 'success' | 'warning' | 'danger'

interface Props {
  variant?: AlertVariant
  title?: string
  dismissible?: boolean
  hideIcon?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'info',
  dismissible: false,
  hideIcon: false
})

const emit = defineEmits<{
  dismiss: []
}>()

const dismissed = ref(false)

const handleDismiss = () => {
  dismissed.value = true
  emit('dismiss')
}

const iconComponent = computed(() => {
  const icons = {
    info: h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
      class: 'w-5 h-5'
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
      })
    ]),
    success: h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
      class: 'w-5 h-5'
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
      })
    ]),
    warning: h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
      class: 'w-5 h-5'
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z'
      })
    ]),
    danger: h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
      class: 'w-5 h-5'
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z'
      })
    ])
  }
  return icons[props.variant]
})

const computedClasses = computed(() => {
  const classes = [
    'outfit',
    'rounded-xl',
    'p-4',
    'border-l-4'
  ]

  const variantClasses = {
    info: ['bg-cyan-50', 'border-cyan-500', 'text-cyan-900'],
    success: ['bg-green-50', 'border-green-500', 'text-green-900'],
    warning: ['bg-yellow-50', 'border-yellow-500', 'text-yellow-900'],
    danger: ['bg-red-50', 'border-red-500', 'text-red-900']
  }
  classes.push(...variantClasses[props.variant])

  return classes.join(' ')
})
</script>
