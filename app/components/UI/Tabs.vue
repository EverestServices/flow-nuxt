<template>
  <div class="w-full">
    <!-- Tab Headers -->
    <div :class="computedTabListClasses" role="tablist">
      <button
        v-for="(tab, index) in tabs"
        :key="index"
        :class="computedTabClasses(index)"
        :aria-selected="activeTab === index"
        :aria-controls="`tab-panel-${index}`"
        role="tab"
        @click="selectTab(index)"
      >
        {{ tab }}
      </button>
    </div>

    <!-- Tab Panels -->
    <div class="mt-4">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
type TabVariant = 'default' | 'pills' | 'underline'

interface Props {
  tabs: string[]
  modelValue?: number
  variant?: TabVariant
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: 0,
  variant: 'default'
})

const emit = defineEmits<{
  'update:modelValue': [value: number]
  change: [index: number]
}>()

const activeTab = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const selectTab = (index: number) => {
  activeTab.value = index
  emit('change', index)
}

const computedTabListClasses = computed(() => {
  const classes = ['flex']

  if (props.variant === 'default' || props.variant === 'underline') {
    classes.push('border-b', 'border-gray-200', 'gap-6')
  } else if (props.variant === 'pills') {
    classes.push('gap-2', 'p-1', 'bg-gray-100', 'rounded-xl', 'inline-flex')
  }

  return classes.join(' ')
})

const computedTabClasses = (index: number) => {
  const classes = [
    'outfit',
    'font-medium',
    'transition-all',
    'duration-200',
    'focus:outline-none'
  ]

  const isActive = activeTab.value === index

  if (props.variant === 'pills') {
    classes.push('px-4', 'py-2', 'rounded-lg')
    if (isActive) {
      classes.push('bg-white', 'text-blue-600', 'shadow-sm')
    } else {
      classes.push('text-gray-600', 'hover:text-gray-900')
    }
  } else if (props.variant === 'underline') {
    classes.push('pb-3', 'border-b-2', '-mb-px')
    if (isActive) {
      classes.push('border-blue-500', 'text-blue-600')
    } else {
      classes.push('border-transparent', 'text-gray-600', 'hover:text-gray-900', 'hover:border-gray-300')
    }
  } else {
    classes.push('px-4', 'py-2', 'border-b-2', '-mb-px')
    if (isActive) {
      classes.push('border-blue-500', 'text-blue-600')
    } else {
      classes.push('border-transparent', 'text-gray-600', 'hover:text-gray-900', 'hover:border-gray-300')
    }
  }

  return classes.join(' ')
}
</script>
