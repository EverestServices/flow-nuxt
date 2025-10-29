<template>
  <UIModal
    v-model="isOpen"
    :title="$t('survey.scenarios.renameScenario')"
    size="md"
    @close="closeModal"
  >
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          {{ $t('survey.scenarios.scenarioName') }}
        </label>
        <UInput
          v-model="newName"
          :placeholder="$t('survey.scenarios.scenarioName')"
          @keyup.enter="handleRename"
        />
      </div>
    </div>

    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="closeModal"
      >
        {{ $t('common.cancel') }}
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="!newName.trim()"
        @click="handleRename"
      >
        {{ $t('survey.footer.rename') }}
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  modelValue: boolean
  scenarioName: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'rename': [name: string]
}>()

const newName = ref('')
const isOpen = ref(false)

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
  if (value) {
    newName.value = props.scenarioName
  }
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

const handleRename = () => {
  if (!newName.value.trim()) return

  emit('rename', newName.value.trim())
}
</script>
