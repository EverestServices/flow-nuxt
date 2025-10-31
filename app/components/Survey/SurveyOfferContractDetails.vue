<template>
  <div class="space-y-4">
    <!-- Loading state -->
    <div v-if="loading" class="flex items-center justify-center py-8">
      <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
    </div>

    <div v-else class="space-y-4">
      <!-- MainComponents grouped by category -->
      <div v-if="groupedComponents.length > 0" class="space-y-3">
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

      <!-- Solar Extra Costs -->
      <div v-if="solarExtraCostsTotal > 0" class="flex justify-between text-sm border-t border-gray-200 dark:border-gray-700 pt-3">
        <span class="text-gray-700 dark:text-gray-300">{{ $t('survey.offerContract.solarExtraCosts') }}</span>
        <span class="text-gray-900 dark:text-white font-medium">
          {{ formatCurrency(solarExtraCostsTotal) }}
        </span>
      </div>

      <!-- General Extra Costs -->
      <div v-if="generalExtraCostsTotal > 0" class="flex justify-between text-sm border-t border-gray-200 dark:border-gray-700 pt-3">
        <span class="text-gray-700 dark:text-gray-300">{{ $t('survey.offerContract.extraCosts') }}</span>
        <span class="text-gray-900 dark:text-white font-medium">
          {{ formatCurrency(generalExtraCostsTotal) }}
        </span>
      </div>

      <!-- Implementation Fee -->
      <div class="flex justify-between text-base font-semibold border-t border-gray-300 dark:border-gray-600 pt-3">
        <span class="text-gray-900 dark:text-white">{{ $t('survey.costs.implementationFee') }}</span>
        <span class="text-gray-900 dark:text-white">
          {{ formatCurrency(implementationFee) }}
        </span>
      </div>

      <!-- Discounts List -->
      <div v-if="discounts.length > 0" class="space-y-2 border-t border-gray-200 dark:border-gray-700 pt-3">
        <div v-for="discount in discounts" :key="discount.id" class="flex justify-between text-sm">
          <span class="text-green-600 dark:text-green-400 font-medium">{{ discount.name }}</span>
          <span class="text-green-600 dark:text-green-400 font-medium">
            {{ formatCurrency(discount.calculatedValue) }}
          </span>
        </div>
      </div>

      <!-- Total Discounts -->
      <div v-if="discountsTotal > 0" class="flex justify-between text-sm font-semibold">
        <span class="text-green-600 dark:text-green-400">{{ $t('survey.offerContract.discounts') }}</span>
        <span class="text-green-600 dark:text-green-400">
          {{ formatCurrency(discountsTotal) }}
        </span>
      </div>

      <!-- Subsidies -->
      <div v-if="subsidies.length > 0" class="space-y-2 border-t border-gray-200 dark:border-gray-700 pt-3">
        <div v-for="subsidy in subsidies" :key="subsidy.id" class="flex justify-between text-sm">
          <span class="text-green-600 dark:text-green-400 font-medium">{{ subsidy.name }}</span>
          <span class="text-green-600 dark:text-green-400 font-medium">
            -{{ formatCurrency(subsidy.calculatedPrice) }}
          </span>
        </div>
      </div>

      <!-- Total -->
      <div class="flex justify-between text-lg font-bold border-t-2 border-gray-300 dark:border-gray-600 pt-3">
        <span class="text-gray-900 dark:text-white">{{ $t('survey.costs.total') }}</span>
        <span class="text-gray-900 dark:text-white">
          {{ formatCurrency(total) }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, provide, inject } from 'vue'
import { useI18n } from 'vue-i18n'
import { useScenariosStore } from '~/stores/scenarios'

const { t } = useI18n()

interface Props {
  surveyId: string
  scenarioId: string
  commissionRate: number
}

const props = defineProps<Props>()

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

interface Discount {
  id: string
  name: string
  discount_type: 'fixed' | 'percentage' | 'calculated'
  value: number
  calculatedValue: number
}

const supabase = useSupabaseClient()
const scenariosStore = useScenariosStore()

const loading = ref(false)
const mainComponents = ref<MainComponent[]>([])
const subsidies = ref<Subsidy[]>([])
const discounts = ref<Discount[]>([])
const solarExtraCostsTotal = ref(0)
const generalExtraCostsTotal = ref(0)
const discountsTotal = ref(0)

// Provide functions for child components to update totals
provide('updateSolarExtraCostsTotal', (total: number) => {
  solarExtraCostsTotal.value = total
})

provide('updateGeneralExtraCostsTotal', (total: number) => {
  generalExtraCostsTotal.value = total
})

provide('updateDiscountsTotal', (total: number) => {
  discountsTotal.value = total
})

provide('updateDiscountsData', (data: Discount[]) => {
  discounts.value = data
})

// Inject function to update total price in parent
const updateTotalPriceData = inject<(total: number) => void>('updateTotalPriceData', () => {})

// Group components by category
const groupedComponents = computed(() => {
  const groups = new Map<string, { name: string; components: MainComponent[] }>()

  mainComponents.value.forEach(component => {
    const categoryName = component.category_name || t('survey.categories.other', 'Egyéb')
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
  return mainTotal + solarExtraCostsTotal.value + generalExtraCostsTotal.value
})

const subsidyTotal = computed(() => {
  return subsidies.value.reduce((sum, s) => sum + s.calculatedPrice, 0)
})

const total = computed(() => {
  return implementationFee.value - subsidyTotal.value - discountsTotal.value
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
          'panel': t('survey.categories.panel', 'Napelemek'),
          'inverter': t('survey.categories.inverter', 'Inverterek'),
          'battery': t('survey.categories.battery', 'Akkumulátorok'),
          'mounting': t('survey.categories.mounting', 'Rögzítőrendszerek'),
          'insulation': t('survey.categories.insulation', 'Szigetelés'),
          'adhesive': t('survey.categories.adhesive', 'Ragasztó'),
          'plaster': t('survey.categories.plaster', 'Vakolat'),
          'heat_pump': t('survey.categories.heatPump', 'Hőszivattyúk'),
          'water_heater': t('survey.categories.waterHeater', 'Vízmelegítők'),
          'ventilation': t('survey.categories.ventilation', 'Szellőztetés'),
          'other': t('survey.categories.other', 'Egyéb')
        }

        categoriesMap = Object.fromEntries(
          categoriesData.map((cat: any) => [
            cat.id,
            categoryTranslations[cat.persist_name] || t('survey.categories.other', 'Egyéb')
          ])
        )
      }
    }

    mainComponents.value = (componentsData || []).map((item: any) => {
      const categoryId = item.main_component?.main_component_category_id
      const categoryName = categoryId ? (categoriesMap[categoryId] || t('survey.categories.other', 'Egyéb')) : t('survey.categories.other', 'Egyéb')

      return {
        id: item.id,
        name: item.main_component?.name || t('common.unknown', 'Unknown'),
        category_name: categoryName,
        totalCost: item.quantity * item.price_snapshot * (1 + props.commissionRate)
      }
    })

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

// Watch total and notify parent
watch(total, (newTotal) => {
  updateTotalPriceData(newTotal)
}, { immediate: true })
</script>
