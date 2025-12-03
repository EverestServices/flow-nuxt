<template>
  <UPopover :popper="{ placement: 'bottom-start' }" :ui="{ width: 'max-w-md' }">
    <template #default="{ open }">
      <button
        type="button"
        class="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-800 rounded-lg border-2 transition-all hover:border-gray-300 dark:hover:border-gray-600"
        :class="[
          open ? 'border-primary-500' : 'border-gray-200 dark:border-gray-700',
          disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
        ]"
        :disabled="disabled"
      >
        <!-- Color preview or placeholder -->
        <div
          v-if="modelValue"
          class="w-10 h-10 rounded-md shadow-sm border border-gray-300 dark:border-gray-600"
          :style="{ backgroundColor: selectedColorRgb }"
        />
        <div
          v-else
          class="w-10 h-10 rounded-md shadow-sm border-2 border-dashed border-gray-300 dark:border-gray-600 flex items-center justify-center"
        >
          <UIcon name="i-lucide-palette" class="w-5 h-5 text-gray-400" />
        </div>

        <!-- Selected color info -->
        <div class="flex-1 text-left">
          <div v-if="modelValue" class="text-sm font-medium text-gray-900 dark:text-white">
            {{ modelValue }}
          </div>
          <div v-else class="text-sm text-gray-500 dark:text-gray-400">
            {{ $t('colorPicker.selectColor') }}
          </div>
        </div>

        <!-- Chevron icon -->
        <UIcon
          name="i-lucide-chevron-down"
          class="w-5 h-5 text-gray-400 transition-transform"
          :class="{ 'rotate-180': open }"
        />
      </button>
    </template>

    <template #content>
      <div class="p-4">
        <!-- Color grid -->
        <div class="grid grid-cols-6 gap-2">
          <button
            v-for="color in colors"
            :key="color.code"
            type="button"
            class="color-option group relative flex flex-col items-center justify-center p-2 rounded-lg transition-all hover:scale-105 border-2"
            :class="[
              modelValue === color.code
                ? 'border-primary-500 shadow-lg scale-105'
                : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
            ]"
            @click="selectColor(color.code)"
          >
            <!-- Color swatch -->
            <div
              class="w-12 h-12 rounded-md shadow-sm border border-gray-300 dark:border-gray-600 mb-1"
              :style="{ backgroundColor: color.rgb }"
            />

            <!-- Color code -->
            <span class="text-xs font-medium text-gray-700 dark:text-gray-300 text-center">
              {{ color.code }}
            </span>

            <!-- Selected indicator -->
            <div
              v-if="modelValue === color.code"
              class="absolute -top-1 -right-1 w-5 h-5 bg-primary-500 rounded-full flex items-center justify-center"
            >
              <UIcon name="i-lucide-check" class="w-3 h-3 text-white" />
            </div>
          </button>
        </div>

        <!-- Clear button -->
        <button
          v-if="modelValue"
          type="button"
          class="mt-3 w-full px-3 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md transition-colors flex items-center justify-center gap-2"
          @click="clearSelection"
        >
          <UIcon name="i-lucide-x" class="w-4 h-4" />
          {{ $t('colorPicker.clearSelection') }}
        </button>
      </div>
    </template>
  </UPopover>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface ColorOption {
  code: string
  rgb: string
}

interface Props {
  modelValue?: string
  disabled?: boolean
  colors?: ColorOption[]
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: undefined,
  disabled: false,
  colors: () => [
    // Classic 16-color VGA palette (default fallback, actual colors come from DB)
    { code: 'Black', rgb: 'rgb(0, 0, 0)' },
    { code: 'Maroon', rgb: 'rgb(128, 0, 0)' },
    { code: 'Green', rgb: 'rgb(0, 128, 0)' },
    { code: 'Olive', rgb: 'rgb(128, 128, 0)' },
    { code: 'Navy', rgb: 'rgb(0, 0, 128)' },
    { code: 'Purple', rgb: 'rgb(128, 0, 128)' },
    { code: 'Teal', rgb: 'rgb(0, 128, 128)' },
    { code: 'Silver', rgb: 'rgb(192, 192, 192)' },
    { code: 'Gray', rgb: 'rgb(128, 128, 128)' },
    { code: 'Red', rgb: 'rgb(255, 0, 0)' },
    { code: 'Lime', rgb: 'rgb(0, 255, 0)' },
    { code: 'Yellow', rgb: 'rgb(255, 255, 0)' },
    { code: 'Blue', rgb: 'rgb(0, 0, 255)' },
    { code: 'Fuchsia', rgb: 'rgb(255, 0, 255)' },
    { code: 'Aqua', rgb: 'rgb(0, 255, 255)' },
    { code: 'White', rgb: 'rgb(255, 255, 255)' }
  ]
})

const emit = defineEmits<{
  'update:modelValue': [value: string | undefined]
}>()

const selectedColorRgb = computed(() => {
  if (!props.modelValue) return undefined
  const color = props.colors.find(c => c.code === props.modelValue)
  return color?.rgb
})

const selectColor = (code: string) => {
  if (props.disabled) return
  emit('update:modelValue', code)
}

const clearSelection = () => {
  if (props.disabled) return
  emit('update:modelValue', undefined)
}
</script>

<style scoped>
.color-option:focus {
  outline: 2px solid rgb(var(--color-primary-500));
  outline-offset: 2px;
}
</style>
