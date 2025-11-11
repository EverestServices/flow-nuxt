<template>
  <UModal v-model="isOpen" :prevent-close="true">
    <div class="p-6">
      <div class="flex items-center gap-3 mb-4">
        <div class="w-12 h-12 rounded-full bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center">
          <Icon name="i-lucide-alert-triangle" class="w-6 h-6 text-orange-600 dark:text-orange-400" />
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
            {{ $t('survey.unsavedChanges.title') }}
          </h3>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('survey.unsavedChanges.message') }}
          </p>
        </div>
      </div>

      <div class="flex flex-col gap-2 mt-6">
        <UIButtonEnhanced
          variant="primary"
          size="lg"
          @click="handleSaveAndExit"
          class="w-full"
        >
          <Icon name="i-lucide-save" class="w-4 h-4 mr-2" />
          {{ $t('survey.unsavedChanges.saveAndExit') }}
        </UIButtonEnhanced>

        <UIButtonEnhanced
          variant="outline"
          size="lg"
          @click="handleDiscardAndExit"
          class="w-full text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20"
        >
          <Icon name="i-lucide-trash-2" class="w-4 h-4 mr-2" />
          {{ $t('survey.unsavedChanges.discardAndExit') }}
        </UIButtonEnhanced>

        <UIButtonEnhanced
          variant="ghost"
          size="lg"
          @click="handleCancel"
          class="w-full"
        >
          {{ $t('survey.unsavedChanges.cancel') }}
        </UIButtonEnhanced>
      </div>
    </div>
  </UModal>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'save-and-exit': []
  'discard-and-exit': []
  'cancel': []
}>()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const handleSaveAndExit = () => {
  emit('save-and-exit')
  isOpen.value = false
}

const handleDiscardAndExit = () => {
  emit('discard-and-exit')
  isOpen.value = false
}

const handleCancel = () => {
  emit('cancel')
  isOpen.value = false
}
</script>
