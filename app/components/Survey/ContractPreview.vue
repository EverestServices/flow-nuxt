<template>
  <div class="bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg p-8 space-y-6">
    <!-- Header -->
    <div class="border-b border-gray-200 dark:border-gray-700 pb-6">
      <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
        {{ contract.name }}
      </h2>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        {{ contract.contract_mode === 'offer' ? 'Ajánlat' : 'Szerződés' }} •
        {{ formatDate(contract.created_at) }}
      </p>
    </div>

    <!-- Client Information -->
    <div>
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
        Ügyfél adatok
      </h3>
      <div class="grid grid-cols-2 gap-4 text-sm">
        <div>
          <span class="text-gray-600 dark:text-gray-400">Név:</span>
          <p class="font-medium text-gray-900 dark:text-white">{{ clientName }}</p>
        </div>
        <div>
          <span class="text-gray-600 dark:text-gray-400">E-mail:</span>
          <p class="font-medium text-gray-900 dark:text-white">{{ clientEmail }}</p>
        </div>
        <div>
          <span class="text-gray-600 dark:text-gray-400">Telefon:</span>
          <p class="font-medium text-gray-900 dark:text-white">{{ clientPhone }}</p>
        </div>
        <div>
          <span class="text-gray-600 dark:text-gray-400">Cím:</span>
          <p class="font-medium text-gray-900 dark:text-white">{{ clientAddress }}</p>
        </div>
      </div>
    </div>

    <!-- Selected Investments -->
    <div>
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
        Kiválasztott beruházások
      </h3>
      <div class="space-y-2">
        <div
          v-for="investmentId in contractInvestments"
          :key="investmentId"
          class="flex items-center gap-2 text-sm"
        >
          <UIcon
            :name="getInvestmentIcon(investmentId)"
            class="w-5 h-5 text-primary"
          />
          <span class="font-medium text-gray-900 dark:text-white">
            {{ getInvestmentName(investmentId) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Components Breakdown -->
    <div v-if="contractComponents.length > 0">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
        Komponensek
      </h3>
      <div class="space-y-2">
        <div
          v-for="component in contractComponents"
          :key="component.id"
          class="flex items-center justify-between text-sm py-2 border-b border-gray-100 dark:border-gray-700"
        >
          <div class="flex-1">
            <span class="font-medium text-gray-900 dark:text-white">
              {{ getComponentName(component.main_component_id) }}
            </span>
            <span class="text-gray-600 dark:text-gray-400 ml-2">
              × {{ component.quantity }}
            </span>
          </div>
          <span class="font-medium text-gray-900 dark:text-white">
            {{ formatPrice(component.price_snapshot * component.quantity) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Extra Costs -->
    <div v-if="contractExtraCosts.length > 0">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
        További költségek
      </h3>
      <div class="space-y-2">
        <div
          v-for="extraCost in contractExtraCosts"
          :key="extraCost.id"
          class="flex items-center justify-between text-sm py-2 border-b border-gray-100 dark:border-gray-700"
        >
          <div class="flex-1">
            <span class="font-medium text-gray-900 dark:text-white">
              {{ extraCost.extra_cost_id }}
            </span>
            <span v-if="extraCost.quantity" class="text-gray-600 dark:text-gray-400 ml-2">
              × {{ extraCost.quantity }}
            </span>
          </div>
          <span class="font-medium text-gray-900 dark:text-white">
            {{ formatPrice(extraCost.snapshot_price * (extraCost.quantity || 1)) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Discounts -->
    <div v-if="contractDiscounts.length > 0">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
        Kedvezmények
      </h3>
      <div class="space-y-2">
        <div
          v-for="discount in contractDiscounts"
          :key="discount.id"
          class="flex items-center justify-between text-sm py-2 border-b border-gray-100 dark:border-gray-700"
        >
          <span class="font-medium text-gray-900 dark:text-white">
            {{ discount.discount_id }}
          </span>
          <span class="font-medium text-green-600 dark:text-green-400">
            -{{ formatPrice(discount.discount_snapshot) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Total Price -->
    <div class="border-t-2 border-gray-300 dark:border-gray-600 pt-4">
      <div class="flex items-center justify-between">
        <h3 class="text-xl font-bold text-gray-900 dark:text-white">
          Összesen
        </h3>
        <p class="text-2xl font-bold text-primary">
          {{ formatPrice(contract.total_price) }}
        </p>
      </div>
      <p class="text-sm text-gray-600 dark:text-gray-400 mt-2">
        ÁFA: {{ contract.vat }}% • Jutalék: {{ (contract.commission_rate * 100).toFixed(2) }}%
      </p>
    </div>

    <!-- Terms and Conditions -->
    <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-2">
        Megjegyzések
      </h4>
      <p class="text-sm text-gray-600 dark:text-gray-300">
        {{ contract.notes || 'Nincsenek megjegyzések' }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const { translate } = useTranslatableField()

interface Contract {
  id: string
  name: string
  contract_mode: 'offer' | 'contract'
  total_price: number
  vat: number
  commission_rate: number
  notes?: string
  created_at: string
  client_name?: string
  client_address?: string
  client_phone?: string
  client_email?: string
}

interface Props {
  contract: Contract
  contractInvestments: string[]
  contractComponents: any[]
  contractExtraCosts: any[]
  contractDiscounts: any[]
  investments: any[]
  mainComponents: any[]
  clientData?: any
}

const props = defineProps<Props>()

const clientName = computed(() => {
  return props.contract.client_name || props.clientData?.name || 'N/A'
})

const clientEmail = computed(() => {
  return props.contract.client_email || props.clientData?.email || 'N/A'
})

const clientPhone = computed(() => {
  return props.contract.client_phone || props.clientData?.phone || 'N/A'
})

const clientAddress = computed(() => {
  if (props.contract.client_address) {
    return props.contract.client_address
  }

  if (props.clientData) {
    const parts = [
      props.clientData.postal_code,
      props.clientData.city,
      props.clientData.street,
      props.clientData.house_number
    ].filter(Boolean)
    return parts.join(', ') || 'N/A'
  }

  return 'N/A'
})

const getInvestmentName = (investmentId: string): string => {
  const investment = props.investments.find(inv => inv.id === investmentId)
  if (!investment) return 'Unknown'
  return translate(investment.name_translations, investment.name)
}

const getInvestmentIcon = (investmentId: string): string => {
  const investment = props.investments.find(inv => inv.id === investmentId)
  return investment?.icon || 'i-lucide-circle'
}

const getComponentName = (componentId: string): string => {
  const component = props.mainComponents.find(c => c.id === componentId)
  return component?.name || 'Unknown Component'
}

const formatPrice = (price: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

const formatDate = (dateString: string): string => {
  return new Date(dateString).toLocaleDateString('hu-HU', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>
