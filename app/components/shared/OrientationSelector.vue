<template>
  <div>
    <div v-if="label || $slots.label" class="flex items-center gap-2 mb-2">
      <slot name="label">
        <label v-if="label" class="text-sm font-medium text-gray-700 dark:text-gray-300">
          {{ label }}
          <span v-if="required" class="text-red-500">*</span>
        </label>
      </slot>
    </div>
    <div class="flex flex-wrap gap-2">
      <button
        v-for="orientation in orientations"
        :key="orientation"
        type="button"
        :disabled="disabled"
        class="w-14 h-14 flex flex-col items-center justify-center rounded-lg transition-all hover:scale-105 relative"
        :class="[
          modelValue === orientation
            ? 'bg-primary-500 text-white shadow-md'
            : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 hover:bg-gray-300 dark:hover:bg-gray-600',
          disabled ? 'opacity-60 cursor-not-allowed hover:scale-100' : ''
        ]"
        @click="$emit('update:modelValue', orientation)"
      >
        <UIcon
          name="i-lucide-navigation"
          class="w-6 h-6 transition-transform"
          :style="{ transform: `rotate(${getOrientationAngle(orientation)}deg)` }"
        />
        <span class="text-[10px] font-semibold mt-0.5">{{ orientation }}</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Orientation } from '@/model/Measure/ArucoWallSurface'

interface Props {
  modelValue?: string | null
  label?: string
  required?: boolean
  disabled?: boolean
}

defineProps<Props>()
defineEmits<{
  'update:modelValue': [value: string]
}>()

const orientations = [
  Orientation.N,   // É
  Orientation.NE,  // ÉK
  Orientation.E,   // K
  Orientation.SE,  // DK
  Orientation.S,   // D
  Orientation.SW,  // DNy
  Orientation.W,   // Ny
  Orientation.NW   // ÉNy
]

const getOrientationAngle = (direction: string): number => {
  const angleMap: Record<string, number> = {
    'É': 0,      // North
    'ÉK': 45,    // Northeast
    'K': 90,     // East
    'DK': 135,   // Southeast
    'D': 180,    // South
    'DNy': 225,  // Southwest
    'Ny': 270,   // West
    'ÉNy': 315   // Northwest
  }
  return angleMap[direction] || 0
}
</script>
