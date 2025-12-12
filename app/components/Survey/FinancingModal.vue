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
          {{ $t('survey.financing.title') }}
        </h3>
      </div>
    </template>

    <div class="space-y-6">
      <!-- Finanszírozás típusa Section -->
      <div>
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-4">
          {{ $t('survey.financing.financingType') }}
        </h4>
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.cash') }}</label>
            <USwitch v-model="financing.cash" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.loan') }}</label>
            <USwitch v-model="financing.loan" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.lease') }}</label>
            <USwitch v-model="financing.lease" />
          </div>
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.subsidy') }}</label>
            <USwitch v-model="financing.subsidy" />
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Investment Extra Costs Accordions -->
      <div v-if="loading" class="flex items-center justify-center py-8">
        <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
      </div>

      <div v-else-if="scenarioInvestments.length > 0" class="space-y-3">
        <!-- Accordion for each investment -->
        <div
          v-for="investment in scenarioInvestments"
          :key="investment.id"
          class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden"
        >
          <!-- Accordion Header -->
          <button
            class="flex items-center justify-between w-full py-3 px-4 text-sm font-medium text-left text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            @click="toggleInvestmentAccordion(investment.id)"
          >
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="w-5 h-5" />
              <span>{{ getInvestmentName(investment) }} {{ $t('survey.financing.extraCosts') }}</span>
            </div>
            <UIcon
              :name="isInvestmentAccordionOpen(investment.id) ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="w-5 h-5"
            />
          </button>

          <!-- Accordion Body -->
          <div
            v-show="isInvestmentAccordionOpen(investment.id)"
            class="border-t border-gray-200 dark:border-gray-700"
          >
            <div class="p-4">
              <SurveyOfferContractInvestmentExtraCosts
                v-if="props.scenarioId"
                :survey-id="props.surveyId"
                :scenario-id="props.scenarioId"
                :investment-persist-name="investment.persist_name"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="border-t border-gray-200 dark:border-gray-700"></div>

      <!-- Price Section -->
      <div class="space-y-3">
        <!-- Price with colored buttons -->
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('survey.financing.price') }}</span>
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
          <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.showPrice') }}</label>
          <USwitch v-model="showPrice" />
        </div>

        <!-- Show Return Time -->
        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.showReturnTime') }}</label>
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
        {{ $t('survey.financing.cancel') }}
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="saving"
        @click="handleSave"
      >
        <Icon v-if="saving" name="i-lucide-loader-2" class="w-4 h-4 mr-2 animate-spin" />
        {{ $t('survey.financing.save') }}
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import SurveyOfferContractInvestmentExtraCosts from './SurveyOfferContractInvestmentExtraCosts.vue'

interface Props {
  modelValue: boolean
  surveyId: string
  scenarioId: string | null
  showReturnTime: boolean
}

interface Investment {
  id: string
  persist_name: string
  name: string
  name_translations: any
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
const scenarioInvestments = ref<Investment[]>([])
const openAccordions = ref<Set<string>>(new Set())
const totalPrice = ref(0)
const { translate } = useTranslatableField()

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

// Load scenario investments and financing data
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

    // Get scenario's investments with full investment details
    const { data: siData, error: siError } = await supabase
      .from('scenario_investments')
      .select('investment_id')
      .eq('scenario_id', props.scenarioId)

    if (siError) throw siError

    const investmentIds = (siData || []).map(si => si.investment_id)

    if (investmentIds.length === 0) {
      scenarioInvestments.value = []
      loading.value = false
      return
    }

    // Load full investment objects
    const { data: investmentsData, error: investmentsError } = await supabase
      .from('investments')
      .select('id, persist_name, name, name_translations')
      .in('id', investmentIds)
      .order('name')

    if (investmentsError) throw investmentsError
    scenarioInvestments.value = investmentsData || []

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

    // Get extra costs from scenario_extra_costs with prices
    const { data: scenarioExtras, error: extraError } = await supabase
      .from('scenario_extra_costs')
      .select('extra_cost_id, quantity, extra_costs(price)')
      .eq('scenario_id', props.scenarioId)

    if (extraError) throw extraError

    // Calculate extra costs total
    const extraTotal = (scenarioExtras || []).reduce((sum: number, se: any) => {
      if (se.extra_costs?.price) {
        return sum + (se.quantity * se.extra_costs.price * (1 + rate))
      }
      return sum
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

// Investment accordion helper functions
const toggleInvestmentAccordion = (investmentId: string) => {
  if (openAccordions.value.has(investmentId)) {
    openAccordions.value.delete(investmentId)
  } else {
    openAccordions.value.add(investmentId)
  }
}

const isInvestmentAccordionOpen = (investmentId: string): boolean => {
  return openAccordions.value.has(investmentId)
}

const getInvestmentName = (investment: Investment): string => {
  return translate(investment.name_translations, investment.name)
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

    // Note: Extra costs are saved by the child SurveyOfferContractInvestmentExtraCosts components

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
