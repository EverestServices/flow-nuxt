<template>
  <UIModal
    v-model="isOpen"
    size="xl"
    :scrollable="true"
  >
    <template #header>
      <div class="flex items-center gap-3">
        <Icon name="i-lucide-wallet" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
        <h3 class="outfit font-bold text-xl text-gray-900 dark:text-white">
          Financing and Costs
        </h3>
      </div>
    </template>

    <div class="space-y-6">
      <!-- Finanszírozás típusa Section -->
      <div>
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4">
          Finanszírozás típusa
        </h4>
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">Készpénz</label>
            <USwitch v-model="financing.cash" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">Hitel</label>
            <USwitch v-model="financing.loan" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">Lízing</label>
            <USwitch v-model="financing.lease" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">Támogatás</label>
            <USwitch v-model="financing.subsidy" />
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- ExtraCost List -->
      <div v-if="loading" class="flex items-center justify-center py-8">
        <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
      </div>

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
              <textarea
                :value="getExtraCostComment(extraCost.id)"
                @input="handleCommentChange(extraCost.id, ($event.target as HTMLTextAreaElement).value)"
                rows="3"
                class="w-full px-3 py-2 text-sm border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-900 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="Add your notes here..."
              ></textarea>
            </div>
          </Transition>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Price Section -->
      <div class="space-y-3">
        <!-- Price with colored buttons -->
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Price:</span>
            <button
              class="w-6 h-6 rounded-full bg-red-500 hover:bg-red-600 transition-colors"
              :class="{ 'ring-2 ring-offset-2 ring-red-500': commissionColor === 'red' }"
              @click="handlePriceColorClick('red')"
            ></button>
            <button
              class="w-6 h-6 rounded-full bg-yellow-500 hover:bg-yellow-600 transition-colors"
              :class="{ 'ring-2 ring-offset-2 ring-yellow-500': commissionColor === 'yellow' }"
              @click="handlePriceColorClick('yellow')"
            ></button>
            <button
              class="w-6 h-6 rounded-full bg-green-500 hover:bg-green-600 transition-colors"
              :class="{ 'ring-2 ring-offset-2 ring-green-500': commissionColor === 'green' }"
              @click="handlePriceColorClick('green')"
            ></button>
            <button
              class="w-6 h-6 rounded-full bg-black dark:bg-gray-900 hover:bg-gray-800 dark:hover:bg-gray-700 transition-colors border border-gray-300 dark:border-gray-600"
              :class="{ 'ring-2 ring-offset-2 ring-black dark:ring-gray-900': commissionColor === 'black' }"
              @click="handlePriceColorClick('black')"
            ></button>
          </div>
          <button
            class="text-sm font-semibold text-gray-900 dark:text-white border-b-2 pb-1 cursor-pointer hover:opacity-80 transition-opacity"
            :class="priceUnderlineColor"
            @click="handlePriceClick"
          >
            {{ formatCurrency(totalPrice) }}
          </button>
        </div>

        <!-- Show Price -->
        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">Show Price</label>
          <USwitch v-model="showPrice" />
        </div>

        <!-- Show Return Time -->
        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">Show return time</label>
          <USwitch
            :model-value="showReturnTime"
            @update:model-value="$emit('update:show-return-time', $event)"
          />
        </div>
      </div>
    </div>

    <!-- Footer -->
    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="closeModal"
      >
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="saving"
        @click="handleSave"
      >
        <Icon v-if="saving" name="i-lucide-loader-2" class="w-4 h-4 mr-2 animate-spin" />
        Save
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
interface Props {
  modelValue: boolean
  surveyId: string
  scenarioId: string | null
  showReturnTime: boolean
}

interface ExtraCost {
  id: string
  name: string
  price: number
}

interface ExtraCostRelation {
  extra_cost_id: string
  comment: string | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'update:show-return-time': [value: boolean]
  'commission-changed': [rate: number]
  saved: []
}>()

const supabase = useSupabaseClient()
const isOpen = ref(false)

// Sync isOpen with modelValue
watch(() => props.modelValue, (newValue) => {
  isOpen.value = newValue
})

watch(isOpen, (newValue) => {
  emit('update:modelValue', newValue)
})

// Commission rates
const COMMISSION_RATES = {
  red: 0.12,
  yellow: 0.08,
  green: 0.04,
  black: 0
}

const COMMISSION_COLORS = ['red', 'yellow', 'green', 'black'] as const
type CommissionColor = typeof COMMISSION_COLORS[number]

// State
const loading = ref(false)
const saving = ref(false)
const financing = ref({
  cash: false,
  loan: false,
  lease: false,
  subsidy: false
})
const showPrice = ref(false)
const commissionColor = ref<CommissionColor>('red')
const extraCosts = ref<ExtraCost[]>([])
const selectedExtraCosts = ref<Map<string, ExtraCostRelation>>(new Map())
const totalPrice = ref(0)

// Get commission rate as number
const commissionRate = computed(() => COMMISSION_RATES[commissionColor.value])

// Get border color class
const priceUnderlineColor = computed(() => {
  const colors = {
    red: 'border-red-500',
    yellow: 'border-yellow-500',
    green: 'border-green-500',
    black: 'border-black dark:border-gray-900'
  }
  return colors[commissionColor.value]
})

// Load extra costs and existing relations
const loadData = async () => {
  if (!props.scenarioId) return

  loading.value = true

  try {
    // Load scenario to get commission rate
    const { data: scenario, error: scenarioError } = await supabase
      .from('scenarios')
      .select('commission_rate')
      .eq('id', props.scenarioId)
      .single()

    if (scenarioError) throw scenarioError

    // Set commission color based on rate
    const rate = scenario?.commission_rate || 0.12
    const colorEntry = Object.entries(COMMISSION_RATES).find(([_, r]) => r === rate)
    if (colorEntry) {
      commissionColor.value = colorEntry[0] as CommissionColor
    }

    // Load all extra costs
    const { data: extraCostsData, error: extraCostsError } = await supabase
      .from('extra_costs')
      .select('id, name, price')
      .order('name')

    if (extraCostsError) throw extraCostsError
    extraCosts.value = extraCostsData || []

    // Load existing relations for this scenario
    const { data: relationsData, error: relationsError } = await supabase
      .from('extra_cost_relations')
      .select('extra_cost_id, comment')
      .eq('scenario_id', props.scenarioId)

    if (relationsError) throw relationsError

    // Build map of selected extra costs
    selectedExtraCosts.value = new Map(
      (relationsData || []).map(rel => [rel.extra_cost_id, rel])
    )

    // Calculate total price
    await calculateTotalPrice()
  } catch (error) {
    console.error('Error loading financing data:', error)
  } finally {
    loading.value = false
  }
}

// Calculate total price
const calculateTotalPrice = async () => {
  if (!props.scenarioId) return

  try {
    const rate = commissionRate.value

    // Get main components
    const { data: components, error: compError } = await supabase
      .from('scenario_main_components')
      .select('quantity, price_snapshot')
      .eq('scenario_id', props.scenarioId)

    if (compError) throw compError

    const mainTotal = (components || []).reduce((sum: number, c: any) => {
      return sum + (c.quantity * c.price_snapshot * (1 + rate))
    }, 0)

    // Get extra costs
    const { data: extras, error: extraError } = await supabase
      .from('extra_cost_relations')
      .select('quantity, snapshot_price')
      .eq('scenario_id', props.scenarioId)

    if (extraError) throw extraError

    const extraTotal = (extras || []).reduce((sum: number, e: any) => {
      return sum + (e.quantity * e.snapshot_price * (1 + rate))
    }, 0)

    const implementationFee = mainTotal + extraTotal

    // Get subsidies
    const { data: subsidies, error: subsidyError } = await supabase
      .from('survey_subsidies')
      .select('subsidy:subsidies(discount_type, discount_value)')
      .eq('survey_id', props.surveyId)
      .eq('is_enabled', true)

    if (subsidyError) throw subsidyError

    const subsidyTotal = (subsidies || []).reduce((sum: number, s: any) => {
      if (!s.subsidy) return sum

      if (s.subsidy.discount_type === 'percentage') {
        return sum + (implementationFee * s.subsidy.discount_value / 100)
      } else if (s.subsidy.discount_type === 'fixed') {
        return sum + s.subsidy.discount_value
      }
      return sum
    }, 0)

    totalPrice.value = implementationFee - subsidyTotal
  } catch (error) {
    console.error('Error calculating total price:', error)
  }
}

// Check if extra cost is selected
const isExtraCostSelected = (extraCostId: string): boolean => {
  return selectedExtraCosts.value.has(extraCostId)
}

// Get comment for extra cost
const getExtraCostComment = (extraCostId: string): string => {
  return selectedExtraCosts.value.get(extraCostId)?.comment || ''
}

// Handle extra cost toggle
const handleExtraCostToggle = (extraCostId: string, enabled: boolean) => {
  if (enabled) {
    selectedExtraCosts.value.set(extraCostId, {
      extra_cost_id: extraCostId,
      comment: null
    })
  } else {
    selectedExtraCosts.value.delete(extraCostId)
  }
}

// Handle comment change
const handleCommentChange = (extraCostId: string, comment: string) => {
  const relation = selectedExtraCosts.value.get(extraCostId)
  if (relation) {
    relation.comment = comment
  }
}

// Handle price color button clicks
const handlePriceColorClick = async (color: CommissionColor) => {
  commissionColor.value = color
  await calculateTotalPrice()
}

// Handle price value click - cycle through colors
const handlePriceClick = async () => {
  const currentIndex = COMMISSION_COLORS.indexOf(commissionColor.value)
  const nextIndex = (currentIndex + 1) % COMMISSION_COLORS.length
  commissionColor.value = COMMISSION_COLORS[nextIndex]
  await calculateTotalPrice()
}

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    maximumFractionDigits: 0
  }).format(Math.round(amount))
}

// Save changes
const handleSave = async () => {
  if (!props.scenarioId) return

  saving.value = true

  try {
    // Update scenario commission rate
    const { error: scenarioError } = await supabase
      .from('scenarios')
      .update({ commission_rate: commissionRate.value })
      .eq('id', props.scenarioId)

    if (scenarioError) throw scenarioError

    // Delete all existing relations for this scenario
    const { error: deleteError } = await supabase
      .from('extra_cost_relations')
      .delete()
      .eq('scenario_id', props.scenarioId)

    if (deleteError) throw deleteError

    // Insert new relations
    if (selectedExtraCosts.value.size > 0) {
      const relationsToInsert = Array.from(selectedExtraCosts.value.entries()).map(
        ([extraCostId, relation]) => ({
          scenario_id: props.scenarioId,
          extra_cost_id: extraCostId,
          comment: relation.comment || null,
          quantity: 1,
          snapshot_price: extraCosts.value.find(ec => ec.id === extraCostId)?.price || 0
        })
      )

      const { error: insertError } = await supabase
        .from('extra_cost_relations')
        .insert(relationsToInsert)

      if (insertError) throw insertError
    }

    // Emit commission changed event
    emit('commission-changed', commissionRate.value)
    emit('saved')
    closeModal()
  } catch (error) {
    console.error('Error saving financing data:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  isOpen.value = false
}

// Watch for modal open to load data
watch(isOpen, (newValue) => {
  if (newValue) {
    loadData()
  }
})

// Watch for commission rate changes to recalculate price
watch(() => commissionColor.value, () => {
  if (props.scenarioId && isOpen.value) {
    calculateTotalPrice()
  }
})
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
