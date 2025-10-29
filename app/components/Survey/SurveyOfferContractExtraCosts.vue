<template>
  <div class="space-y-6">
    <!-- Loading state -->
    <div v-if="loading" class="text-center text-gray-500 dark:text-gray-400 py-6">
      <p class="text-sm">{{ $t('survey.extraCosts.loading') }}</p>
    </div>

    <!-- Extra costs by category -->
    <div v-else class="space-y-6">
      <!-- General -->
      <div v-if="getCategoryItems('general').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.general') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('general')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Connections -->
      <div v-if="getCategoryItems('connections').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.connections') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('connections')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Electric Meter -->
      <div v-if="getCategoryItems('electric_meter').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.electricMeter') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('electric_meter')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Lightning Protection -->
      <div v-if="getCategoryItems('lightning_protection').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.lightningProtection') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('lightning_protection')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Cables -->
      <div v-if="getCategoryItems('cables').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.cables') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('cables')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Backup -->
      <div v-if="getCategoryItems('backup').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.backup') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('backup')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Internet -->
      <div v-if="getCategoryItems('internet').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          {{ $t('survey.extraCosts.internet') }}
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('internet')"
            :key="cost.id"
            :cost="cost"
            :selected="isSelected(cost.id)"
            :quantity="getQuantity(cost.id)"
            :notes="getNotes(cost.id)"
            @toggle="toggleCost(cost.id)"
            @update:quantity="updateQuantity(cost.id, $event)"
            @update:notes="updateNotes(cost.id, $event)"
          />
        </div>
      </div>

      <!-- Total Cost Display -->
      <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
        <div class="flex justify-between items-center">
          <span class="text-base font-semibold text-gray-900 dark:text-white">
            {{ $t('survey.extraCosts.total') }}
          </span>
          <span class="text-lg font-bold text-primary-600 dark:text-primary-400">
            {{ formatPrice(totalCost) }}{{ $t('survey.extraCosts.currency') }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, inject } from 'vue'
import ExtraCostItem from './ExtraCostItem.vue'

const { t } = useI18n()

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

interface ExtraCost {
  id: string
  persist_name: string
  name: string
  description: string
  price: number
  is_quantity_based: boolean
  category: string
}

interface SelectedCost {
  costId: string
  quantity: number
  notes: string
}

// State
const loading = ref(true)
const extraCosts = ref<ExtraCost[]>([])
const selectedCosts = ref<SelectedCost[]>([])

// Fetch extra costs from database
onMounted(async () => {
  try {
    const supabase = useSupabaseClient()
    const { data, error } = await supabase
      .from('extra_costs')
      .select('*')
      .not('category', 'is', null)
      .order('category', { ascending: true })
      .order('name', { ascending: true })

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

// Get items by category
const getCategoryItems = (category: string) => {
  return extraCosts.value.filter(cost => cost.category === category)
}

// Check if cost is selected
const isSelected = (costId: string) => {
  return selectedCosts.value.some(sc => sc.costId === costId)
}

// Get quantity for a cost
const getQuantity = (costId: string) => {
  const selected = selectedCosts.value.find(sc => sc.costId === costId)
  return selected?.quantity || 1
}

// Get notes for a cost
const getNotes = (costId: string) => {
  const selected = selectedCosts.value.find(sc => sc.costId === costId)
  return selected?.notes || ''
}

// Toggle cost selection
const toggleCost = (costId: string) => {
  const index = selectedCosts.value.findIndex(sc => sc.costId === costId)
  if (index >= 0) {
    selectedCosts.value.splice(index, 1)
  } else {
    selectedCosts.value.push({
      costId,
      quantity: 1,
      notes: ''
    })
  }
}

// Update quantity
const updateQuantity = (costId: string, quantity: number) => {
  const selected = selectedCosts.value.find(sc => sc.costId === costId)
  if (selected) {
    selected.quantity = quantity
  }
}

// Update notes
const updateNotes = (costId: string, notes: string) => {
  const selected = selectedCosts.value.find(sc => sc.costId === costId)
  if (selected) {
    selected.notes = notes
  }
}

// Calculate total cost
const totalCost = computed(() => {
  let total = 0
  selectedCosts.value.forEach(sc => {
    const cost = extraCosts.value.find(c => c.id === sc.costId)
    if (cost) {
      total += cost.price * (cost.is_quantity_based ? sc.quantity : 1)
    }
  })
  return total
})

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('hu-HU').format(price)
}

// Inject update function from parent
const updateSolarExtraCostsTotal = inject<(total: number) => void>('updateSolarExtraCostsTotal', () => {})

// Watch total cost and notify parent
watch(totalCost, (newTotal) => {
  updateSolarExtraCostsTotal(newTotal)
}, { immediate: true })
</script>

<script lang="ts">
// Extra Cost Item Component
import { defineComponent, computed } from 'vue'

export default defineComponent({
  name: 'SurveyOfferContractExtraCosts'
})
</script>
