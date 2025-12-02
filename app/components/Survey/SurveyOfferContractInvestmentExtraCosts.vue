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

      <!-- OFP-specific extra costs -->
      <div v-if="getCategoryItems('ofp').length > 0" class="space-y-3">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white uppercase tracking-wide">
          OFP Speciális költségek
        </h3>
        <div class="space-y-4">
          <ExtraCostItem
            v-for="cost in getCategoryItems('ofp')"
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
import { useI18n } from 'vue-i18n'
import ExtraCostItem from './ExtraCostItem.vue'

const { t } = useI18n()

interface Props {
  surveyId: string
  scenarioId: string
  investmentPersistName: string | string[]
}

const props = defineProps<Props>()

interface ExtraCost {
  id: string
  investment_id: string | null
  persist_name: string
  name: string
  name_translations: any
  description: string
  price: number
  is_quantity_based: boolean
  category: string
  info_message_translations: any
  metadata?: {
    is_ofp_specific?: boolean
    mutually_exclusive_group?: string
    ofp_api_key?: string
  }
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

    // Normalize to array for consistent handling
    const persistNames = Array.isArray(props.investmentPersistName)
      ? props.investmentPersistName
      : [props.investmentPersistName]

    // Get investment IDs based on persist_name(s)
    const { data: investmentData, error: investmentError } = await supabase
      .from('investments')
      .select('id')
      .in('persist_name', persistNames)

    if (investmentError || !investmentData) {
      console.error('Error fetching investment:', investmentError)
      loading.value = false
      return
    }

    const investmentIds = investmentData.map(inv => inv.id)

    // Then fetch extra costs for these investment(s)
    const { data, error } = await supabase
      .from('extra_costs')
      .select('*')
      .in('investment_id', investmentIds)
      .not('category', 'is', null)
      .order('sequence', { ascending: true, nullsFirst: false })
      .order('category', { ascending: true })
      .order('name', { ascending: true })

    if (error) {
      console.error('Error fetching extra costs:', error)
      return
    }

    extraCosts.value = data || []

    // Load existing selections from scenario_extra_costs
    await loadExistingSelections()
  } catch (error) {
    console.error('Error loading extra costs:', error)
  } finally {
    loading.value = false
  }
})

// Load existing selections from database
const loadExistingSelections = async () => {
  try {
    const supabase = useSupabaseClient()

    const { data, error } = await supabase
      .from('scenario_extra_costs')
      .select('*')
      .eq('scenario_id', props.scenarioId)

    if (error) {
      console.error('Error loading existing selections:', error)
      return
    }

    // Populate selectedCosts from database
    if (data) {
      selectedCosts.value = data.map(sec => ({
        costId: sec.extra_cost_id,
        quantity: sec.quantity || 1,
        notes: sec.notes || ''
      }))
    }
  } catch (error) {
    console.error('Error loading selections:', error)
  }
}

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
const toggleCost = async (costId: string) => {
  const supabase = useSupabaseClient()
  const index = selectedCosts.value.findIndex(sc => sc.costId === costId)

  if (index >= 0) {
    // Unselect - remove from database
    const { error } = await supabase
      .from('scenario_extra_costs')
      .delete()
      .eq('scenario_id', props.scenarioId)
      .eq('extra_cost_id', costId)

    if (error) {
      console.error('Error removing extra cost:', error)
      return
    }

    selectedCosts.value.splice(index, 1)
  } else {
    // Select - but first check for mutually exclusive group
    const cost = extraCosts.value.find(c => c.id === costId)

    if (cost?.metadata?.mutually_exclusive_group) {
      // Find and deselect ALL items in the same mutually exclusive group
      const exclusiveGroup = cost.metadata.mutually_exclusive_group
      const exclusiveCosts = extraCosts.value.filter(c =>
        c.metadata?.mutually_exclusive_group === exclusiveGroup &&
        c.id !== costId // Exclude the one we're selecting
      )

      // Deselect all items in the same group from database
      for (const exclusiveCost of exclusiveCosts) {
        const exclusiveIndex = selectedCosts.value.findIndex(sc => sc.costId === exclusiveCost.id)
        if (exclusiveIndex >= 0) {
          await supabase
            .from('scenario_extra_costs')
            .delete()
            .eq('scenario_id', props.scenarioId)
            .eq('extra_cost_id', exclusiveCost.id)

          selectedCosts.value.splice(exclusiveIndex, 1)
        }
      }
    }

    // Add the new selection to database
    const { error } = await supabase
      .from('scenario_extra_costs')
      .insert({
        scenario_id: props.scenarioId,
        extra_cost_id: costId,
        quantity: 1,
        notes: ''
      })

    if (error) {
      console.error('Error adding extra cost:', error)
      return
    }

    // Add to local state
    selectedCosts.value.push({
      costId,
      quantity: 1,
      notes: ''
    })
  }
}

// Update quantity
const updateQuantity = async (costId: string, quantity: number) => {
  const supabase = useSupabaseClient()
  const selected = selectedCosts.value.find(sc => sc.costId === costId)

  if (selected) {
    // Update in database
    const { error } = await supabase
      .from('scenario_extra_costs')
      .update({ quantity })
      .eq('scenario_id', props.scenarioId)
      .eq('extra_cost_id', costId)

    if (error) {
      console.error('Error updating quantity:', error)
      return
    }

    // Update local state
    selected.quantity = quantity
  }
}

// Update notes
const updateNotes = async (costId: string, notes: string) => {
  const supabase = useSupabaseClient()
  const selected = selectedCosts.value.find(sc => sc.costId === costId)

  if (selected) {
    // Update in database
    const { error } = await supabase
      .from('scenario_extra_costs')
      .update({ notes })
      .eq('scenario_id', props.scenarioId)
      .eq('extra_cost_id', costId)

    if (error) {
      console.error('Error updating notes:', error)
      return
    }

    // Update local state
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

// Helper to capitalize first letter
const capitalizeFirst = (value: string | string[]) => {
  const str = Array.isArray(value) ? value[0] : value
  return str.charAt(0).toUpperCase() + str.slice(1)
}

// Inject update function from parent (dynamic based on investment)
const updateExtraCostsTotal = inject<(total: number) => void>(`update${capitalizeFirst(props.investmentPersistName)}ExtraCostsTotal`, () => {})

// Watch total cost and notify parent
watch(totalCost, (newTotal) => {
  updateExtraCostsTotal(newTotal)
}, { immediate: true })
</script>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'SurveyOfferContractInvestmentExtraCosts'
})
</script>
