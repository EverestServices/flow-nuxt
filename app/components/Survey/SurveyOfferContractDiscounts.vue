<template>
  <div class="space-y-4">
    <!-- Loading state -->
    <div v-if="loading" class="text-center text-gray-500 dark:text-gray-400 py-6">
      <p class="text-sm">Kedvezmények betöltése...</p>
    </div>

    <!-- Discounts list -->
    <div v-else class="space-y-3">
      <div
        v-for="discount in discounts"
        :key="discount.id"
        class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700"
      >
        <div class="flex items-start justify-between gap-4">
          <!-- Discount info -->
          <div class="flex-1">
            <h4 class="text-sm font-medium text-gray-900 dark:text-white mb-1">
              {{ discount.name }}
            </h4>
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-2">
              {{ discount.description }}
            </p>
            <p class="text-sm font-semibold text-primary-600 dark:text-primary-400">
              {{ getDiscountValue(discount) }}
            </p>
          </div>

          <!-- Toggle switch -->
          <USwitch
            :model-value="isDiscountEnabled(discount.id)"
            @update:model-value="toggleDiscount(discount.id)"
          />
        </div>
      </div>
    </div>

    <!-- Total discount display -->
    <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
      <div class="flex justify-between items-center">
        <span class="text-base font-semibold text-gray-900 dark:text-white">
          Összes kedvezmény
        </span>
        <span class="text-lg font-bold text-green-600 dark:text-green-400">
          {{ formatPrice(totalDiscount) }} Ft
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, inject } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

interface Discount {
  id: string
  persist_name: string
  name: string
  description: string
  discount_type: 'fixed' | 'percentage' | 'calculated'
  value: number
}

// State
const loading = ref(true)
const discounts = ref<Discount[]>([])
const enabledDiscounts = ref<Set<string>>(new Set())

const scenariosStore = useScenariosStore()

// Fetch discounts from database
onMounted(async () => {
  try {
    const supabase = useSupabaseClient()
    const { data, error } = await supabase
      .from('discounts')
      .select('*')
      .order('created_at', { ascending: true })

    if (error) {
      console.error('Error fetching discounts:', error)
      return
    }

    discounts.value = data || []
  } catch (error) {
    console.error('Error loading discounts:', error)
  } finally {
    loading.value = false
  }
})

// Get scenario components
const scenarioComponents = computed(() => {
  return scenariosStore.scenarioComponents[props.scenarioId] || []
})

// Calculate battery discount (total battery value)
const batteryDiscount = computed(() => {
  if (!scenariosStore.categories || scenariosStore.categories.length === 0) {
    return 0
  }

  let totalBatteryValue = 0

  scenarioComponents.value.forEach(component => {
    const mainComponent = scenariosStore.getMainComponentById(component.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.categories.find(c => c.id === mainComponent.main_component_category_id)
    if (category?.persist_name === 'battery') {
      const quantity = component.quantity || 0
      const price = mainComponent.price || 0
      totalBatteryValue += price * quantity
    }
  })

  return totalBatteryValue
})

// Calculate third panel free discount
const thirdPanelDiscount = computed(() => {
  if (!scenariosStore.categories || scenariosStore.categories.length === 0) {
    return 0
  }

  let totalPanels = 0
  let panelPrice = 0

  scenarioComponents.value.forEach(component => {
    const mainComponent = scenariosStore.getMainComponentById(component.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.categories.find(c => c.id === mainComponent.main_component_category_id)
    if (category?.persist_name === 'panel') {
      totalPanels += component.quantity || 0
      panelPrice = mainComponent.price || 0 // Use the last panel price
    }
  })

  // Calculate free panels: every 3rd panel is free
  const freePanels = Math.floor(totalPanels / 3)
  return freePanels * panelPrice
})

// Check if discount is enabled
const isDiscountEnabled = (discountId: string) => {
  return enabledDiscounts.value.has(discountId)
}

// Toggle discount
const toggleDiscount = (discountId: string) => {
  if (enabledDiscounts.value.has(discountId)) {
    enabledDiscounts.value.delete(discountId)
  } else {
    enabledDiscounts.value.add(discountId)
  }
  // Force reactivity
  enabledDiscounts.value = new Set(enabledDiscounts.value)
}

// Get discount value display
const getDiscountValue = (discount: Discount) => {
  if (discount.discount_type === 'fixed') {
    return formatPrice(discount.value) + ' Ft'
  } else if (discount.discount_type === 'percentage') {
    return discount.value + '%'
  } else if (discount.discount_type === 'calculated') {
    // Calculate based on persist_name
    let calculatedValue = 0
    if (discount.persist_name === 'battery-free') {
      calculatedValue = batteryDiscount.value
    } else if (discount.persist_name === 'third-panel-free') {
      calculatedValue = thirdPanelDiscount.value
    }
    return formatPrice(calculatedValue) + ' Ft'
  }
  return ''
}

// Calculate total discount
const totalDiscount = computed(() => {
  let total = 0

  discounts.value.forEach(discount => {
    if (!isDiscountEnabled(discount.id)) return

    if (discount.discount_type === 'fixed') {
      total += discount.value
    } else if (discount.discount_type === 'calculated') {
      if (discount.persist_name === 'battery-free') {
        total += batteryDiscount.value
      } else if (discount.persist_name === 'third-panel-free') {
        total += thirdPanelDiscount.value
      }
    }
    // Note: Percentage discounts need to be calculated against a base price
    // This will be handled in the parent component or when calculating final price
  })

  return total
})

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('hu-HU').format(price)
}

// Inject update functions from parent
const updateDiscountsTotal = inject<(total: number) => void>('updateDiscountsTotal', () => {})
const updateDiscountsData = inject<(data: any[]) => void>('updateDiscountsData', () => {})

// Compute enabled discounts data for parent
const enabledDiscountsData = computed(() => {
  return discounts.value
    .filter(discount => isDiscountEnabled(discount.id))
    .map(discount => {
      let calculatedValue = 0

      if (discount.discount_type === 'fixed') {
        calculatedValue = discount.value
      } else if (discount.discount_type === 'calculated') {
        if (discount.persist_name === 'battery-free') {
          calculatedValue = batteryDiscount.value
        } else if (discount.persist_name === 'third-panel-free') {
          calculatedValue = thirdPanelDiscount.value
        }
      }

      return {
        id: discount.id,
        name: discount.name,
        discount_type: discount.discount_type,
        value: discount.value,
        calculatedValue
      }
    })
})

// Watch total discount and notify parent
watch(totalDiscount, (newTotal) => {
  updateDiscountsTotal(newTotal)
}, { immediate: true })

// Watch enabled discounts and notify parent
watch(enabledDiscountsData, (newData) => {
  updateDiscountsData(newData)
}, { immediate: true, deep: true })

// Watch for scenario changes and recalculate
watch(() => props.scenarioId, () => {
  // Optionally reset enabled discounts when scenario changes
  // enabledDiscounts.value.clear()
})
</script>
