<template>
  <div class="space-y-4">
    <!-- Loading state -->
    <div v-if="loading" class="text-center text-gray-500 dark:text-gray-400 py-6">
      <p class="text-sm">Extra costs betöltése...</p>
    </div>

    <!-- Extra Costs list -->
    <div v-else class="space-y-3">
      <div
        v-for="extraCost in extraCosts"
        :key="extraCost.id"
        class="border border-gray-200 dark:border-gray-700 rounded-lg p-4"
      >
        <!-- ExtraCost Header -->
        <div class="flex items-center justify-between">
          <div class="flex-1">
            <div class="text-sm font-medium text-gray-900 dark:text-white">
              {{ extraCost.name }}
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">
              {{ formatCurrency(extraCost.price) }}
            </div>
          </div>
          <USwitch
            :model-value="isExtraCostSelected(extraCost.id)"
            @update:model-value="handleExtraCostToggle(extraCost.id, $event)"
          />
        </div>

        <!-- Comment Textarea - shown when selected -->
        <Transition name="expand">
          <div
            v-if="isExtraCostSelected(extraCost.id)"
            class="mt-3 pt-3 border-t border-gray-200 dark:border-gray-700"
          >
            <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-2">
              Megjegyzés:
            </label>
            <UTextarea
              :model-value="getExtraCostComment(extraCost.id)"
              @update:model-value="handleCommentChange(extraCost.id, $event)"
              :rows="3"
              size="sm"
              placeholder="Add your notes here..."
            />
          </div>
        </Transition>
      </div>
    </div>

    <!-- Total extra costs display -->
    <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
      <div class="flex justify-between items-center">
        <span class="text-base font-semibold text-gray-900 dark:text-white">
          Összesen
        </span>
        <span class="text-lg font-bold text-primary-600 dark:text-primary-400">
          {{ formatCurrency(totalExtraCosts) }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, inject } from 'vue'

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

interface ExtraCost {
  id: string
  name: string
  price: number
}

interface SelectedExtraCost {
  extraCostId: string
  comment: string
}

// State
const loading = ref(true)
const extraCosts = ref<ExtraCost[]>([])
const selectedExtraCosts = ref<SelectedExtraCost[]>([])

// Fetch extra costs from database
onMounted(async () => {
  try {
    const supabase = useSupabaseClient()
    const { data, error } = await supabase
      .from('extra_costs')
      .select('id, name, price')
      .order('name')

    if (error) {
      console.error('Error fetching extra costs:', error)
      return
    }

    extraCosts.value = data || []
  } catch (error) {
    console.error('Error loading extra costs:', error)
  } finally {
    loading.value = false
  }
})

// Check if extra cost is selected
const isExtraCostSelected = (extraCostId: string): boolean => {
  return selectedExtraCosts.value.some(sc => sc.extraCostId === extraCostId)
}

// Get comment for extra cost
const getExtraCostComment = (extraCostId: string): string => {
  const selected = selectedExtraCosts.value.find(sc => sc.extraCostId === extraCostId)
  return selected?.comment || ''
}

// Handle extra cost toggle
const handleExtraCostToggle = (extraCostId: string, enabled: boolean) => {
  if (enabled) {
    selectedExtraCosts.value.push({
      extraCostId,
      comment: ''
    })
  } else {
    const index = selectedExtraCosts.value.findIndex(sc => sc.extraCostId === extraCostId)
    if (index >= 0) {
      selectedExtraCosts.value.splice(index, 1)
    }
  }
}

// Handle comment change
const handleCommentChange = (extraCostId: string, comment: string) => {
  const selected = selectedExtraCosts.value.find(sc => sc.extraCostId === extraCostId)
  if (selected) {
    selected.comment = comment
  }
}

// Calculate total extra costs
const totalExtraCosts = computed(() => {
  let total = 0
  selectedExtraCosts.value.forEach(sc => {
    const extraCost = extraCosts.value.find(ec => ec.id === sc.extraCostId)
    if (extraCost) {
      total += extraCost.price
    }
  })
  return total
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    maximumFractionDigits: 0
  }).format(Math.round(amount))
}

// Inject update function from parent
const updateGeneralExtraCostsTotal = inject<(total: number) => void>('updateGeneralExtraCostsTotal', () => {})

// Watch total cost and notify parent
watch(totalExtraCosts, (newTotal) => {
  updateGeneralExtraCostsTotal(newTotal)
}, { immediate: true })
</script>

<style scoped>
.expand-enter-active,
.expand-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
}

.expand-enter-from,
.expand-leave-to {
  max-height: 0;
  opacity: 0;
}

.expand-enter-to,
.expand-leave-from {
  max-height: 200px;
  opacity: 1;
}
</style>
