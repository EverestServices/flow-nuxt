<template>
  <div class="space-y-6">
    <!-- VAT Selection -->
    <div class="flex items-center gap-4">
      <UISelect
        v-model="selectedVAT"
        :options="vatOptions"
        size="sm"
        label="ÁFA:"
        :block="false"
        class="w-32"
      />
    </div>

    <!-- Price Values -->
    <div class="space-y-3 bg-gray-50 dark:bg-gray-900 rounded-lg p-4">
      <div class="flex justify-between items-center">
        <span class="text-sm text-gray-700 dark:text-gray-300">Minimális ár:</span>
        <span class="text-sm font-medium text-gray-900 dark:text-white">
          {{ formatCurrency(prices.totalMinimumPrice) }}
        </span>
      </div>

      <div class="flex justify-between items-center">
        <span class="text-sm text-gray-700 dark:text-gray-300">Nettó ár:</span>
        <span class="text-sm font-medium text-gray-900 dark:text-white">
          {{ formatCurrency(prices.totalNetPrice) }}
        </span>
      </div>

      <div class="flex justify-between items-center">
        <span class="text-sm text-gray-700 dark:text-gray-300">Kedvezmény:</span>
        <span class="text-sm font-medium text-gray-900 dark:text-white">
          {{ formatCurrency(prices.discount) }}
        </span>
      </div>

      <div class="flex justify-between items-center">
        <span class="text-sm text-gray-700 dark:text-gray-300">Várható haszon:</span>
        <span class="text-sm font-medium text-gray-900 dark:text-white">
          {{ formatCurrency(prices.expectedMargin) }}
        </span>
      </div>

      <div class="flex justify-between items-center border-t border-gray-200 dark:border-gray-700 pt-2">
        <span class="text-sm text-gray-700 dark:text-gray-300">Várható haszon %:</span>
        <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
          {{ formatPercentage(prices.expectedMarginPercent) }}
        </span>
      </div>
    </div>

    <!-- Component Breakdown Table -->
    <div v-if="componentItems.length > 0" class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
      <div class="bg-gray-50 dark:bg-gray-800 px-4 py-3">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">Komponensek részletezése</h4>
      </div>

      <!-- Table -->
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Kategória
              </th>
              <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Név
              </th>
              <th scope="col" class="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Db
              </th>
              <th scope="col" class="px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Ár
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="(item, index) in componentItems" :key="index">
              <td class="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">
                {{ item.category }}
              </td>
              <td class="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">
                {{ item.name }}
              </td>
              <td class="px-4 py-3 text-sm text-center text-gray-700 dark:text-gray-300">
                {{ item.quantity !== null ? item.quantity : '-' }}
              </td>
              <td class="px-4 py-3 text-sm text-right font-medium text-primary-600 dark:text-primary-400">
                {{ formatCurrency(item.price) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'

interface Props {
  surveyId: string
  scenarioId: string
  totalPriceAfterSubsidy: number
  totalDiscounts: number
  commissionRate: number
}

const props = defineProps<Props>()

interface ComponentItem {
  category: string
  name: string
  quantity: number | null
  price: number
}

const scenariosStore = useScenariosStore()

// VAT selection
const selectedVAT = ref(27)
const vatOptions = [
  { label: '27%', value: 27 },
  { label: '21%', value: 21 },
  { label: '15%', value: 15 },
  { label: '12%', value: 12 },
  { label: '5%', value: 5 },
  { label: '0%', value: 0 }
]

// Calculate prices
const prices = computed(() => {
  // Total minimum price (0% margin) - this would be the base cost
  const totalMinimumPrice = props.totalPriceAfterSubsidy * 0.85 // Assuming 15% margin currently

  // Total net price (excluding VAT)
  const totalNetPrice = props.totalPriceAfterSubsidy / (1 + selectedVAT.value / 100)

  // Discount from DiscountsPanel
  const discount = props.totalDiscounts

  // Expected margin (mocked)
  const expectedMargin = props.totalPriceAfterSubsidy - totalMinimumPrice

  // Expected margin percentage
  const expectedMarginPercent = ((expectedMargin / totalMinimumPrice) * 100)

  return {
    totalMinimumPrice,
    totalNetPrice,
    discount,
    expectedMargin,
    expectedMarginPercent
  }
})

// Get category name translation
const getCategoryName = (persistName: string): string => {
  const categoryTranslations: Record<string, string> = {
    'panel': 'Napelem',
    'inverter': 'Inverter',
    'battery': 'Akkumulátor',
    'mounting': 'Tartószerkezet',
    'insulation': 'Szigetelés',
    'adhesive': 'Ragasztó',
    'plaster': 'Vakolat',
    'heat_pump': 'Hőszivattyú',
    'water_heater': 'Vízmelegítő',
    'ventilation': 'Szellőztetés',
    'other': 'Egyéb'
  }

  return categoryTranslations[persistName] || 'Egyéb'
}

// Extract component items from scenario
const componentItems = computed(() => {
  const items: ComponentItem[] = []

  if (!props.scenarioId || !scenariosStore.categories) return items

  const components = scenariosStore.scenarioComponents[props.scenarioId] || []

  components.forEach(component => {
    const mainComponent = scenariosStore.getMainComponentById(component.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.categories.find(c => c.id === mainComponent.main_component_category_id)
    const categoryName = category ? getCategoryName(category.persist_name) : 'Egyéb'

    const quantity = component.quantity || 0
    const price = (mainComponent.price || 0) * quantity * (1 + props.commissionRate)

    items.push({
      category: categoryName,
      name: mainComponent.name,
      quantity: quantity > 0 ? quantity : null,
      price
    })
  })

  return items
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount)
}

// Format percentage
const formatPercentage = (percent: number): string => {
  return `${percent.toFixed(1)}%`
}
</script>
