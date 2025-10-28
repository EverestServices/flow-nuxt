<template>
  <UIModal
    v-model="isOpen"
    title="Available Services"
    size="xl"
    :scrollable="true"
    @close="closeModal"
  >
    <div class="space-y-6">
      <!-- Client Type Toggle -->
      <div class="flex items-center justify-center">
        <div class="flex items-center space-x-2">
          <span
            class="text-sm font-medium"
            :class="clientType === 'residential' ? 'text-primary-600 dark:text-primary-400' : 'text-gray-500 dark:text-gray-400'"
          >
            Residential
          </span>
          <USwitch
            v-model="isCorporate"
            size="lg"
          />
          <span
            class="text-sm font-medium"
            :class="clientType === 'corporate' ? 'text-primary-600 dark:text-primary-400' : 'text-gray-500 dark:text-gray-400'"
          >
            Corporate
          </span>
        </div>
      </div>

      <!-- Investments Grid -->
      <div class="grid grid-cols-3 gap-4">
        <button
          v-for="investment in filteredInvestments"
          :key="investment.id"
          class="flex flex-col items-center justify-center p-6 rounded-lg border-2 transition-all hover:scale-105"
          :class="isSelected(investment.id)
            ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
            : 'border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700'"
          @click="toggleInvestment(investment.id)"
        >
          <!-- Icon -->
          <div
            class="w-16 h-16 rounded-lg flex items-center justify-center mb-3"
            :class="isSelected(investment.id)
              ? 'bg-primary-100 dark:bg-primary-800'
              : 'bg-gray-100 dark:bg-gray-800'"
          >
            <UIcon
              :name="investment.icon"
              class="w-8 h-8"
              :class="isSelected(investment.id)
                ? 'text-primary-600 dark:text-primary-400'
                : 'text-gray-600 dark:text-gray-400'"
            />
          </div>

          <!-- Name -->
          <span
            class="text-sm font-medium text-center"
            :class="isSelected(investment.id)
              ? 'text-primary-700 dark:text-primary-300'
              : 'text-gray-700 dark:text-gray-300'"
          >
            {{ investment.name }}
          </span>

          <!-- Selected Checkmark -->
          <div v-if="isSelected(investment.id)" class="mt-2">
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
        :disabled="!hasSelections"
        @click="confirmSelection"
      >
        Done
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface Props {
  modelValue: boolean
  surveyId: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const isOpen = ref(false)
const store = useSurveyInvestmentsStore()

// Client type toggle
const isCorporate = computed({
  get: () => store.clientType === 'corporate',
  set: (value) => store.setClientType(value ? 'corporate' : 'residential')
})

// Computed
const clientType = computed(() => store.clientType)
const filteredInvestments = computed(() => store.filteredInvestments)
const hasSelections = computed(() => store.hasSelectedInvestments)

// Methods
const isSelected = (investmentId: string) => {
  return store.selectedInvestmentIds.includes(investmentId)
}

const toggleInvestment = async (investmentId: string) => {
  try {
    if (isSelected(investmentId)) {
      await store.deselectInvestment(investmentId)
    } else {
      await store.selectInvestment(investmentId)
    }
  } catch (error) {
    console.error('Error toggling investment:', error)
  }
}

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

const confirmSelection = () => {
  closeModal()
}
</script>
