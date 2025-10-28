<template>
  <UIModal
    v-model="isOpen"
    title="Energy Consultation Information"
    size="lg"
    @close="closeModal"
  >
    <p class="text-gray-700 dark:text-gray-300 leading-relaxed">
      This section displays energy efficiency improvements, monthly electricity and gas bills.
      You can adjust these values to see how they affect your energy savings and costs.
      The data shown here is calculated based on your selected investments and property characteristics.
    </p>

    <template #footer>
      <UIButtonEnhanced
        variant="primary"
        @click="closeModal"
      >
        Close
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
