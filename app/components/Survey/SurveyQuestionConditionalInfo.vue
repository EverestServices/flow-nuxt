<!--
  SurveyQuestionConditionalInfo Component

  Displays a conditional info/warning/danger icon with a tooltip that appears when
  a question's condition is met (e.g., when a defect switch is enabled).

  Props:
  - type: 'info' | 'warning' | 'danger' - Determines icon color and tooltip border
  - message: string - Translated message to display in tooltip

  Features:
  - Uses UPopover for hover-based tooltip (no TooltipProvider context required)
  - Colored icons based on type (blue/yellow/red)
  - Danger type shows red border on tooltip
  - Supports multiline messages with whitespace-pre-line
-->
<template>
  <UPopover mode="hover" :ui="{ content: 'max-w-sm' }">
    <UIcon
      :name="iconName"
      :class="iconClass"
      class="w-5 h-5 cursor-help"
    />
    <template #content>
      <div
        class="p-3 text-sm whitespace-pre-line"
        :class="contentClass"
      >
        {{ message }}
      </div>
    </template>
  </UPopover>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  type: 'info' | 'warning' | 'danger'
  message: string
}

const props = defineProps<Props>()

// Get icon name based on type
const iconName = computed(() => {
  switch (props.type) {
    case 'info':
      return 'i-lucide-info'
    case 'warning':
      return 'i-lucide-triangle-alert'
    case 'danger':
      return 'i-lucide-circle-alert'
    default:
      return 'i-lucide-info'
  }
})

// Get icon color class based on type
const iconClass = computed(() => {
  switch (props.type) {
    case 'info':
      return 'text-blue-500 dark:text-blue-400'
    case 'warning':
      return 'text-yellow-500 dark:text-yellow-400'
    case 'danger':
      return 'text-red-500 dark:text-red-400'
    default:
      return 'text-gray-500 dark:text-gray-400'
  }
})

// Get content border class for danger type
const contentClass = computed(() => {
  if (props.type === 'danger') {
    return 'border-2 border-red-500 dark:border-red-400'
  }
  return ''
})
</script>
