<template>
  <UIModal
    v-model="isOpen"
    :title="$t('survey.consultation.contractDetailsInfoTitle')"
    size="lg"
    @close="closeModal"
  >
    <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
      {{ $t('survey.consultation.contractDetailsInfoText') }}
    </p>

    <template #footer>
      <UIButtonEnhanced
        variant="primary"
        @click="closeModal"
      >
        {{ $t('survey.consultation.close') }}
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  modelValue: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const isOpen = ref(false)

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
})

watch(isOpen, (value) => {
  if (value !== props.modelValue) {
    emit('update:modelValue', value)
  }
})

const closeModal = () => {
  isOpen.value = false
  emit('update:modelValue', false)
}
</script>
