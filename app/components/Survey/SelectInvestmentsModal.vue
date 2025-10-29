<template>
  <UIModal
    v-model="isOpen"
    :title="mode === 'ai' ? 'Select investments for AI Scenarios' : 'Create New Scenario'"
    size="xl"
    :scrollable="true"
    @close="closeModal"
  >
    <div class="space-y-6">
      <!-- Investments Grid -->
      <div class="grid grid-cols-3 gap-4">
        <button
          v-for="investment in selectedInvestments"
          :key="investment.id"
          class="flex flex-col items-center justify-center p-6 rounded-lg border-2 transition-all hover:scale-105"
          :class="isInvestmentSelected(investment.id)
            ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
            : 'border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700'"
          @click="toggleSelection(investment.id)"
        >
          <!-- Icon -->
          <div
            class="w-16 h-16 rounded-lg flex items-center justify-center mb-3"
            :class="isInvestmentSelected(investment.id)
              ? 'bg-primary-100 dark:bg-primary-800'
              : 'bg-gray-100 dark:bg-gray-800'"
          >
            <UIcon
              :name="investment.icon"
              class="w-8 h-8"
              :class="isInvestmentSelected(investment.id)
                ? 'text-primary-600 dark:text-primary-400'
                : 'text-gray-600 dark:text-gray-400'"
            />
          </div>

          <!-- Name -->
          <span
            class="text-sm font-medium text-center"
            :class="isInvestmentSelected(investment.id)
              ? 'text-primary-700 dark:text-primary-300'
              : 'text-gray-700 dark:text-gray-300'"
          >
            {{ translate(investment.name_translations, investment.name) }}
          </span>

          <!-- Selected Checkmark -->
          <div v-if="isInvestmentSelected(investment.id)" class="mt-2">
            <UIcon
              name="i-lucide-check-circle"
              class="w-5 h-5 text-primary-600 dark:text-primary-400"
            />
          </div>
        </button>
      </div>
    </div>

    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="closeModal"
      >
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="!hasSelectedInvestments"
        @click="handleCreate"
      >
        Create
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

const { translate } = useTranslatableField()

interface Investment {
  id: string
  name: string
  icon: string
}

interface Props {
  modelValue: boolean
  surveyId: string
  selectedInvestments: Investment[]
  mode?: 'ai' | 'manual'
}

const props = withDefaults(defineProps<Props>(), {
  mode: 'ai'
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'create-scenarios': [investmentIds: string[]]
  'create-manual-scenario': [investmentIds: string[]]
}>()

const isOpen = ref(false)

// Local selection state for the modal
const localSelectedIds = ref<string[]>([])

// Initialize local selections with all investments selected
const initializeSelections = () => {
  localSelectedIds.value = props.selectedInvestments.map(inv => inv.id)
}

// Computed
const hasSelectedInvestments = computed(() => localSelectedIds.value.length > 0)

// Methods
const isInvestmentSelected = (investmentId: string) => {
  return localSelectedIds.value.includes(investmentId)
}

const toggleSelection = (investmentId: string) => {
  const index = localSelectedIds.value.indexOf(investmentId)
  if (index > -1) {
    localSelectedIds.value.splice(index, 1)
  } else {
    localSelectedIds.value.push(investmentId)
  }
}

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
  if (value) {
    initializeSelections()
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

const handleCreate = () => {
  if (props.mode === 'ai') {
    emit('create-scenarios', localSelectedIds.value)
  } else {
    emit('create-manual-scenario', localSelectedIds.value)
  }
  closeModal()
}
</script>
