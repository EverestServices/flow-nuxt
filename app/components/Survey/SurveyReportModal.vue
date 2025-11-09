<template>
  <UIModal
    v-model="isOpen"
    title="Felmérési lap"
    size="4xl"
    :scrollable="false"
    @close="closeModal"
  >
    <!-- PDF Preview -->
    <div class="h-[600px]">
      <SurveyReportPreview />
    </div>

    <template #footer>
      <div class="flex items-center justify-between w-full">
        <!-- Left side: Close button -->
        <UIButtonEnhanced
          variant="outline"
          @click="closeModal"
        >
          Bezárás
        </UIButtonEnhanced>

        <!-- Right side: Action buttons -->
        <div class="flex items-center space-x-3">
          <UIButtonEnhanced
            variant="outline"
            :disabled="true"
            @click="saveWithoutSending"
          >
            Mentés kiküldés nélkül
          </UIButtonEnhanced>

          <UIButtonEnhanced
            variant="outline"
            :disabled="true"
            @click="saveAndSend"
          >
            Mentés és kiküldés
          </UIButtonEnhanced>

          <UIButtonEnhanced
            variant="primary"
            :disabled="true"
            @click="signNow"
          >
            Most aláírom
          </UIButtonEnhanced>
        </div>
      </div>
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

// TODO: Implement these functions in the future
const saveWithoutSending = () => {
  console.log('Save without sending - not implemented yet')
}

const saveAndSend = () => {
  console.log('Save and send - not implemented yet')
}

const signNow = () => {
  console.log('Sign now - not implemented yet')
}
</script>
