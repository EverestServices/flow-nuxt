<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        @click.self="handleBackdropClick"
      >
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-white/50 backdrop-blur-xs" />

        <!-- Modal Container -->
        <div :class="computedModalClasses" role="dialog" aria-modal="true">
          <!-- Header -->
          <div v-if="$slots.header || title" class="p-6 border-b border-gray-200 dark:border-gray-700">
            <div class="flex items-start justify-between gap-4">
              <div class="flex-1">
                <slot name="header">
                  <h3 class="outfit font-bold text-xl text-gray-900 dark:text-white">{{ title }}</h3>
                </slot>
              </div>
              <button
                v-if="closeable"
                @click="handleClose"
                class="text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors flex-shrink-0"
                aria-label="Close modal"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Body -->
          <div :class="bodyClasses">
            <slot />
          </div>

          <!-- Footer -->
          <div v-if="$slots.footer" class="flex items-center justify-end gap-3 p-6 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
type ModalSize = 'sm' | 'md' | 'lg' | 'xl' | 'full'

interface Props {
  modelValue: boolean
  title?: string
  size?: ModalSize
  closeable?: boolean
  closeOnBackdrop?: boolean
  scrollable?: boolean
  glass?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  closeable: true,
  closeOnBackdrop: true,
  scrollable: false,
  glass: false
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  close: []
}>()

const handleClose = () => {
  emit('update:modelValue', false)
  emit('close')
}

const handleBackdropClick = () => {
  if (props.closeOnBackdrop) {
    handleClose()
  }
}

const computedModalClasses = computed(() => {
  const classes = [
    'relative',
    'rounded-2xl',
    'shadow-2xl',
    'w-full',
    'overflow-hidden'
  ]

  // Size classes
  const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl',
    full: 'max-w-full h-full m-0 rounded-none'
  }
  classes.push(sizeClasses[props.size])

  // Glass variant
  if (props.glass) {
    classes.push('bg-white/90', 'dark:bg-gray-900/90', 'backdrop-blur-2xl', 'border', 'border-white', 'dark:border-gray-700')
  } else {
    classes.push('bg-white', 'dark:bg-gray-900')
  }

  return classes.join(' ')
})

const bodyClasses = computed(() => {
  const classes = ['p-6']

  if (props.scrollable) {
    classes.push('max-h-[60vh]', 'overflow-y-auto')
  }

  return classes.join(' ')
})

// Prevent body scroll when modal is open
watch(() => props.modelValue, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})

// Cleanup on unmount
onUnmounted(() => {
  document.body.style.overflow = ''
})
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active > div:last-child,
.modal-leave-active > div:last-child {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-enter-from > div:last-child {
  transform: scale(0.9);
  opacity: 0;
}

.modal-leave-to > div:last-child {
  transform: scale(0.9);
  opacity: 0;
}
</style>
