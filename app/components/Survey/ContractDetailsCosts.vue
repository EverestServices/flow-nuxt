<template>
  <div v-if="loading" class="flex items-center justify-center py-8">
    <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
  </div>

  <!-- OFP Mode -->
  <div v-else-if="isOfpMode" class="space-y-4">
    <h4 class="text-sm font-semibold text-gray-900 dark:text-white">{{ $t('survey.costs.costs') }}</h4>

    <!-- OFP Components -->
    <div v-if="ofpComponentsList.length > 0" class="space-y-3">
      <div v-for="component in ofpComponentsList" :key="component.key" class="space-y-1">
        <div class="flex justify-between items-start text-sm">
          <div class="flex-1">
            <div class="text-gray-900 dark:text-white font-medium">{{ component.label }}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 space-x-3">
              <span v-if="component.surface">Terület: {{ component.surface }} m²</span>
              <span v-if="component.pricePerM2">Ár: {{ formatCurrency(component.pricePerM2) }}/m²</span>
              <span v-if="component.capacityKw">Kapacitás: {{ component.capacityKw }} kW</span>
            </div>
          </div>
          <span class="text-gray-900 dark:text-white font-medium">
            {{ formatCurrency(component.totalCostGross) }}
          </span>
        </div>
      </div>
    </div>

    <!-- No components message -->
    <div v-else class="text-sm text-gray-500 dark:text-gray-400 py-2">
      {{ $t('survey.costs.noComponents') }}
    </div>

    <!-- Implementation Fee (Total Gross) -->
    <div class="flex justify-between text-base font-semibold border-t border-gray-300 dark:border-gray-600 pt-3">
      <span class="text-gray-900 dark:text-white">{{ $t('survey.costs.implementationFee') }}</span>
      <span class="text-gray-900 dark:text-white">
        {{ formatCurrency(ofpTotalGross) }}
      </span>
    </div>

    <!-- OFP Financing -->
    <div class="space-y-2 border-t border-gray-200 dark:border-gray-700 pt-3">
      <div class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
        OFP Finanszírozás
      </div>

      <div class="flex justify-between text-sm">
        <span class="text-gray-700 dark:text-gray-300">
          Önerő ({{ (ofpPercentage * 0.143).toFixed(1) }}%)
        </span>
        <span class="text-orange-600 dark:text-orange-400 font-medium">
          {{ formatCurrency(ofpSelfStrength) }}
        </span>
      </div>

      <div class="flex justify-between text-sm">
        <span class="text-gray-700 dark:text-gray-300">
          Vissza nem térítendő ({{ ofpPercentage }}%)
        </span>
        <span class="text-green-600 dark:text-green-400 font-medium">
          -{{ formatCurrency(ofpNonRefundable) }}
        </span>
      </div>

      <div class="flex justify-between text-sm">
        <span class="text-gray-700 dark:text-gray-300">Kamatmentes kölcsön</span>
        <span class="text-blue-600 dark:text-blue-400 font-medium">
          {{ formatCurrency(ofpInterestFreeLoan) }}
        </span>
      </div>
    </div>

    <!-- Flow Subsidies (if any) -->
    <div v-if="subsidies.length > 0" class="space-y-2 border-t border-gray-200 dark:border-gray-700 pt-3">
      <div class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
        További támogatások
      </div>
      <div v-for="subsidy in subsidies" :key="subsidy.id" class="flex justify-between text-sm">
        <span class="text-green-600 dark:text-green-400 font-medium">{{ subsidy.name }}</span>
        <span class="text-green-600 dark:text-green-400 font-medium">
          -{{ formatCurrency(subsidy.calculatedPrice) }}
        </span>
      </div>
    </div>

    <!-- Total (Self Strength) -->
    <div class="flex justify-between text-base font-bold border-t-2 border-gray-300 dark:border-gray-600 pt-3">
      <span class="text-gray-900 dark:text-white">Összesen fizetendő (önerő)</span>
      <span class="text-gray-900 dark:text-white">
        {{ formatCurrency(ofpSelfStrength - subsidyTotal) }}
      </span>
    </div>
  </div>

  <!-- Flow Mode -->
  <div v-else class="space-y-4">
    <h4 class="text-sm font-semibold text-gray-900 dark:text-white">{{ $t('survey.costs.costs') }}</h4>

    <!-- No components message -->
    <div v-if="mainComponents.length === 0 && !loading" class="text-sm text-gray-500 dark:text-gray-400 py-2">
      {{ $t('survey.costs.noComponents') }}
    </div>

    <!-- MainComponents grouped by category -->
    <div v-if="mainComponents.length > 0" class="space-y-3">
      <div v-for="category in groupedComponents" :key="category.name" class="space-y-1">
        <div class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">
          {{ category.name }}
        </div>
        <div v-for="component in category.components" :key="component.id" class="flex justify-between text-sm">
          <span class="text-gray-700 dark:text-gray-300">{{ component.name }}</span>
          <span class="text-gray-900 dark:text-white font-medium">
            {{ formatCurrency(component.totalCost) }}
          </span>
        </div>
      </div>
    </div>

    <!-- ExtraCosts -->
    <div v-if="extraCostTotal > 0" class="flex justify-between text-sm border-t border-gray-200 dark:border-gray-700 pt-3">
      <span class="text-gray-700 dark:text-gray-300">{{ $t('survey.costs.extraCosts') }}</span>
      <span class="text-gray-900 dark:text-white font-medium">
        {{ formatCurrency(extraCostTotal) }}
      </span>
    </div>

    <!-- Implementation Fee -->
    <div class="flex justify-between text-base font-semibold border-t border-gray-300 dark:border-gray-600 pt-3">
      <span class="text-gray-900 dark:text-white">{{ $t('survey.costs.implementationFee') }}</span>
      <span class="text-gray-900 dark:text-white">
        {{ formatCurrency(implementationFee) }}
      </span>
    </div>

    <!-- Subsidies -->
    <div v-if="subsidies.length > 0" class="space-y-2 border-t border-gray-200 dark:border-gray-700 pt-3">
      <div v-for="subsidy in subsidies" :key="subsidy.id" class="flex justify-between">
        <span class="text-green-600 dark:text-green-400 font-medium">{{ subsidy.name }}</span>
        <span class="text-green-600 dark:text-green-400 font-medium">
          -{{ formatCurrency(subsidy.calculatedPrice) }}
        </span>
      </div>
    </div>

    <!-- Total -->
    <div class="flex justify-between text-base font-bold border-t-2 border-gray-300 dark:border-gray-600 pt-3">
      <span class="text-gray-900 dark:text-white">{{ $t('survey.costs.total') }}</span>
      <span class="text-gray-900 dark:text-white">
        {{ formatCurrency(total) }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { OfpCalculationResult } from '~/composables/useOfpCalculation'

interface Props {
  surveyId: string
  scenarioId: string | null
  commissionRate: number
  ofpCalculation?: OfpCalculationResult | null
}

interface MainComponent {
  id: string
  name: string
  totalCost: number
  category_name: string
}

interface Subsidy {
  id: string
  name: string
  discount_type: 'percentage' | 'fixed'
  discount_value: number
  calculatedPrice: number
}

const props = defineProps<Props>()

const supabase = useSupabaseClient()

const loading = ref(false)
const mainComponents = ref<MainComponent[]>([])
const extraCostTotal = ref(0)
const subsidies = ref<Subsidy[]>([])

// Check if we should use OFP mode
const isOfpMode = computed(() => {
  return !!props.ofpCalculation
})

// OFP investment labels
const ofpInvestmentLabels: Record<string, string> = {
  wall_insulation: 'Homlokzati szigetelés',
  roof_insulation: 'Tetőszigetelés',
  window_replacement: 'Nyílászáró csere',
  heat_pump: 'Hőszivattyú',
}

// Format OFP calculations as a list
const ofpComponentsList = computed(() => {
  if (!props.ofpCalculation?.calculations) return []

  return Object.entries(props.ofpCalculation.calculations).map(([key, value]) => ({
    key,
    label: ofpInvestmentLabels[key] || key,
    totalCostGross: value.total_cost_gross,
    totalCostNet: value.total_cost_net,
    surface: value.surface,
    capacityKw: value.capacity_kw,
    pricePerM2: value.price_per_m2,
    selfStrength: value.self_strength,
    nonRefundable: value.non_refundable,
    interestFreeLoan: value.interest_free_loan,
  }))
})

// OFP totals
const ofpTotalGross = computed(() => {
  return props.ofpCalculation?.totals.total_investment_gross || 0
})

const ofpSelfStrength = computed(() => {
  return props.ofpCalculation?.totals.total_self_strength || 0
})

const ofpNonRefundable = computed(() => {
  return props.ofpCalculation?.totals.total_non_refundable || 0
})

const ofpInterestFreeLoan = computed(() => {
  return props.ofpCalculation?.totals.total_interest_free_loan || 0
})

const ofpPercentage = computed(() => {
  return props.ofpCalculation?.percentage || 0
})

// Group components by category
const groupedComponents = computed(() => {
  const groups = new Map<string, { name: string; components: MainComponent[] }>()

  mainComponents.value.forEach(component => {
    const categoryName = component.category_name || 'Other'
    if (!groups.has(categoryName)) {
      groups.set(categoryName, { name: categoryName, components: [] })
    }
    groups.get(categoryName)!.components.push(component)
  })

  return Array.from(groups.values())
})

// Calculate totals
const implementationFee = computed(() => {
  const mainTotal = mainComponents.value.reduce((sum, c) => sum + c.totalCost, 0)
  return mainTotal + extraCostTotal.value
})

const subsidyTotal = computed(() => {
  return subsidies.value.reduce((sum, s) => sum + s.calculatedPrice, 0)
})

const total = computed(() => {
  return implementationFee.value - subsidyTotal.value
})

// Load data
const loadData = async () => {
  if (!props.scenarioId) {
    return
  }

  loading.value = true

  try {
    // Load main components
    const { data: componentsData, error: componentsError } = await supabase
      .from('scenario_main_components')
      .select(`
        id,
        quantity,
        price_snapshot,
        main_component:main_components (
          id,
          name,
          main_component_category_id
        )
      `)
      .eq('scenario_id', props.scenarioId)

    if (componentsError) throw componentsError

    // Load categories to get names
    const categoryIds = [...new Set(componentsData?.map((item: any) => item.main_component?.main_component_category_id).filter(Boolean))]
    let categoriesMap: Record<string, string> = {}

    if (categoryIds.length > 0) {
      const { data: categoriesData, error: categoriesError } = await supabase
        .from('main_component_categories')
        .select('id, persist_name')
        .in('id', categoryIds)

      if (!categoriesError && categoriesData) {
        // Category translations based on persist_name
        const categoryTranslations: Record<string, string> = {
          'solar_panels': 'Napelemek',
          'inverters': 'Inverterek',
          'batteries': 'Akkumulátorok',
          'mounting_systems': 'Rögzítőrendszerek',
          'insulation': 'Szigetelés',
          'adhesive': 'Ragasztó',
          'plaster': 'Vakolat',
          'heat_pumps': 'Hőszivattyúk',
          'water_heaters': 'Vízmelegítők',
          'ventilation': 'Szellőztetés',
          'other': 'Egyéb'
        }

        categoriesMap = Object.fromEntries(
          categoriesData.map((cat: any) => [
            cat.id,
            categoryTranslations[cat.persist_name] || 'Egyéb'
          ])
        )
      }
    }

    mainComponents.value = (componentsData || []).map((item: any) => {
      const categoryId = item.main_component?.main_component_category_id
      const categoryName = categoryId ? (categoriesMap[categoryId] || 'Other') : 'Other'

      return {
        id: item.id,
        name: item.main_component?.name || 'Unknown',
        category_name: categoryName,
        totalCost: item.quantity * item.price_snapshot * (1 + props.commissionRate)
      }
    })

    // Load extra costs
    const { data: extraCostsData, error: extraCostsError } = await supabase
      .from('extra_cost_relations')
      .select('quantity, snapshot_price')
      .eq('scenario_id', props.scenarioId)

    if (extraCostsError) throw extraCostsError

    extraCostTotal.value = (extraCostsData || []).reduce((sum: number, item: any) => {
      return sum + (item.quantity * item.snapshot_price * (1 + props.commissionRate))
    }, 0)

    // Load subsidies
    const { data: subsidiesData, error: subsidiesError } = await supabase
      .from('survey_subsidies')
      .select(`
        subsidy:subsidies (
          id,
          name,
          discount_type,
          discount_value
        )
      `)
      .eq('survey_id', props.surveyId)
      .eq('is_enabled', true)

    if (subsidiesError) throw subsidiesError

    subsidies.value = (subsidiesData || [])
      .map((item: any) => {
        const subsidy = item.subsidy
        if (!subsidy) return null

        // Calculate subsidy price based on implementation fee
        let calculatedPrice = 0
        if (subsidy.discount_type === 'percentage') {
          calculatedPrice = implementationFee.value * subsidy.discount_value / 100
        } else if (subsidy.discount_type === 'fixed') {
          calculatedPrice = subsidy.discount_value
        }

        return {
          id: subsidy.id,
          name: subsidy.name,
          discount_type: subsidy.discount_type,
          discount_value: subsidy.discount_value,
          calculatedPrice
        }
      })
      .filter((s: any) => s !== null)

  } catch (error) {
    console.error('Error loading contract details:', error)
  } finally {
    loading.value = false
  }
}

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    maximumFractionDigits: 0
  }).format(Math.round(amount))
}

// Watch for changes
watch(() => [props.scenarioId, props.commissionRate], () => {
  loadData()
}, { immediate: true })
</script>
