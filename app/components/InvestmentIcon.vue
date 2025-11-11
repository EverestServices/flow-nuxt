<template>
  <IconWindow
    v-if="name === 'custom-window'"
    :size="size"
    :stroke-width="strokeWidth"
    :class="$attrs.class"
  />
  <UIcon
    v-else
    :name="name"
    :class="[sizeClass, $attrs.class]"
  />
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  name: string
  size?: string | number
  strokeWidth?: string | number
}

const props = withDefaults(defineProps<Props>(), {
  size: 24,
  strokeWidth: 1.5
})

// Convert size to Tailwind class for UIcon
const sizeClass = computed(() => {
  const sizeNum = typeof props.size === 'string' ? parseInt(props.size) : props.size

  // Map pixel sizes to Tailwind classes
  const sizeMap: Record<number, string> = {
    16: 'w-4 h-4',
    20: 'w-5 h-5',
    24: 'w-6 h-6',
    32: 'w-8 h-8',
    40: 'w-10 h-10',
    48: 'w-12 h-12'
  }

  return sizeMap[sizeNum] || 'w-6 h-6'
})
</script>
