<template>
  <!-- Backdrop -->
  <div
    v-if="modelValue"
    class="fixed inset-0 bg-black/50 z-40"
    @click="closeModal"
  ></div>

  <!-- Modal -->
  <Transition name="modal-fade">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      @click.self="closeModal"
    >
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col">
        <!-- Header -->
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              Available Services
            </h3>
            <button
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
              @click="closeModal"
            >
              <UIcon name="i-lucide-x" class="w-5 h-5" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="flex-1 overflow-y-auto p-6">
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
        </div>

        <!-- Footer -->
        <div class="p-6 border-t border-gray-200 dark:border-gray-700">
          <div class="flex justify-end space-x-3">
            <button
              class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600"
              @click="closeModal"
            >
              Cancel
            </button>
            <button
              class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
              :disabled="!hasSelections"
              @click="confirmSelection"
            >
              Done
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface Props {
  modelValue: boolean
  surveyId: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

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

const closeModal = () => {
  emit('update:modelValue', false)
}

const confirmSelection = () => {
  closeModal()
}
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active > div,
.modal-fade-leave-active > div {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-fade-enter-from > div,
.modal-fade-leave-to > div {
  transform: scale(0.95);
  opacity: 0;
}
</style>
