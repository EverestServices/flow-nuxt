<template>
  <div class="min-h-screen relative overflow-hidden py-20 px-3">
    <!-- Content Area -->
    <div class="flex-1 overflow-y-auto">
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center h-full">
        <div class="text-center">
          <UIcon name="i-lucide-loader-2" class="w-8 h-8 animate-spin text-primary mx-auto mb-2" />
          <p class="text-gray-600 dark:text-gray-400">{{ $t('survey.summary.loadingContracts') }}</p>
        </div>
      </div>

      <!-- No Contracts State -->
      <div v-else-if="!contracts || contracts.length === 0" class="flex items-center justify-center h-full">
        <div class="backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 p-12 text-center">
          <UIcon name="i-lucide-inbox" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p class="text-gray-600 dark:text-gray-400 font-medium">{{ $t('survey.summary.noContracts') }}</p>
        </div>
      </div>

      <!-- Contract Cards -->
      <div
        v-else
        :class="[
          'gap-6',
          props.viewMode === 'list' ? 'flex flex-col' : 'grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3'
        ]"
      >
        <div
          v-for="contract in contracts"
          :key="contract.id"
          class="backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20"
        >
          <!-- Card Header -->
          <div class="m-4 bg-gradient-to-r from-blue-600 to-indigo-600 text-white px-6 py-3 rounded-full">
            <h3 class="text-base font-semibold text-center">
              {{ contract.name }}
            </h3>
          </div>

          <!-- Card Body -->
          <div class="px-6 pb-4 space-y-6">
            <!-- Client Information -->
            <div class="backdrop-blur-sm bg-white/30 dark:bg-gray-900/30 rounded-2xl p-4 border border-white/20 dark:border-gray-700/20">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
                <UIcon name="i-lucide-user" class="w-4 h-4" />
                {{ $t('survey.summary.clientInformation') }}
              </h4>
              <div class="space-y-2 text-sm">
                <div v-if="getClientName(contract)" class="flex items-start">
                  <UIcon name="i-lucide-user" class="w-4 h-4 text-gray-400 mr-2 mt-0.5" />
                  <span class="text-gray-700 dark:text-gray-300">{{ getClientName(contract) }}</span>
                </div>
                <div v-if="getClientAddress(contract)" class="flex items-start">
                  <UIcon name="i-lucide-map-pin" class="w-4 h-4 text-gray-400 mr-2 mt-0.5" />
                  <span class="text-gray-700 dark:text-gray-300">{{ getClientAddress(contract) }}</span>
                </div>
                <div v-if="getClientPhone(contract)" class="flex items-start">
                  <UIcon name="i-lucide-phone" class="w-4 h-4 text-gray-400 mr-2 mt-0.5" />
                  <span class="text-gray-700 dark:text-gray-300">{{ getClientPhone(contract) }}</span>
                </div>
                <div v-if="getClientEmail(contract)" class="flex items-start">
                  <UIcon name="i-lucide-mail" class="w-4 h-4 text-gray-400 mr-2 mt-0.5" />
                  <span class="text-gray-700 dark:text-gray-300">{{ getClientEmail(contract) }}</span>
                </div>
                <div v-if="!getClientName(contract) && !getClientAddress(contract) && !getClientPhone(contract) && !getClientEmail(contract)" class="text-gray-500 dark:text-gray-400 italic">
                  {{ $t('survey.summary.noClientInfo') }}
                </div>
              </div>
            </div>

            <!-- Contract Details -->
            <div class="backdrop-blur-sm bg-white/30 dark:bg-gray-900/30 rounded-2xl p-4 border border-white/20 dark:border-gray-700/20">
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
                <UIcon name="i-lucide-file-text" class="w-4 h-4" />
                {{ $t('survey.summary.contractDetails') }}
              </h4>

              <!-- Selected Investments -->
              <div class="mb-4">
                <p class="text-xs text-gray-500 dark:text-gray-400 mb-2">{{ $t('survey.summary.selectedInvestments') }}</p>
                <div class="flex flex-wrap gap-2">
                  <div
                    v-for="investmentId in getContractInvestments(contract.id)"
                    :key="investmentId"
                    class="flex items-center gap-1.5 px-2.5 py-1 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 rounded-md text-xs"
                  >
                    <UIcon
                      :name="getInvestmentIcon(investmentId)"
                      class="w-4 h-4"
                    />
                    <span>{{ getInvestmentName(investmentId) }}</span>
                  </div>
                  <div
                    v-if="getContractInvestments(contract.id).length === 0"
                    class="text-gray-500 dark:text-gray-400 italic text-xs"
                  >
                    {{ $t('survey.summary.noInvestments') }}
                  </div>
                </div>
              </div>

              <!-- Cost Summary -->
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">{{ $t('survey.summary.implementationFee') }}</p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ formatPrice(contract.total_price) }}
                </p>
              </div>
            </div>
          </div>

          <!-- Card Footer -->
          <div class="px-6 pb-6">
            <div class="flex items-center justify-end gap-2 flex-wrap">
              <!-- Save without send -->
              <button
                class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 bg-white/70 dark:bg-gray-700/70 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-600 hover:scale-105 border-2 border-gray-200 dark:border-gray-600"
                @click="handleSaveWithoutSend(contract.id)"
              >
                <UIcon name="i-lucide-save" class="w-4 h-4" />
                <span v-if="props.viewMode === 'list'">{{ $t('survey.summary.saveWithoutSend') }}</span>
              </button>

              <!-- Save and Send -->
              <button
                class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 bg-white/70 dark:bg-gray-700/70 text-blue-600 dark:text-blue-400 hover:bg-white dark:hover:bg-gray-600 hover:scale-105 border-2 border-blue-500 dark:border-blue-600"
                @click="handleSaveAndSend(contract.id)"
              >
                <UIcon name="i-lucide-send" class="w-4 h-4" />
                <span v-if="props.viewMode === 'list'">{{ $t('survey.summary.saveAndSend') }}</span>
              </button>

              <!-- Sign Now -->
              <button
                class="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 bg-gradient-to-r from-blue-600 to-indigo-600 text-white hover:scale-105"
                @click="handleSignNow(contract.id)"
              >
                <UIcon name="i-lucide-pen-tool" class="w-4 h-4" />
                <span v-if="props.viewMode === 'list'">{{ $t('survey.summary.signNow') }}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useContractsStore } from '~/stores/contracts'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

const { t } = useI18n()

interface Props {
  surveyId: string
  clientData?: any
  viewMode?: 'list' | 'card'
}

const props = withDefaults(defineProps<Props>(), {
  viewMode: 'list'
})

const contractsStore = useContractsStore()
const investmentsStore = useSurveyInvestmentsStore()

const loading = ref(false)

// Computed
const contracts = computed(() => contractsStore.contracts)

const getContractInvestments = (contractId: string): string[] => {
  const investmentIds = contractsStore.contractInvestments[contractId] || []
  // Filter out is_default investments
  return investmentIds.filter(id => {
    const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
    return investment && !investment.is_default
  })
}

const getInvestmentName = (investmentId: string): string => {
  const { translate } = useTranslatableField()
  const investment = investmentsStore.availableInvestments.find(inv => inv.id === investmentId)
  return investment ? translate(investment.name_translations, investment.name) : 'Unknown'
}

const getInvestmentIcon = (investmentId: string): string => {
  const investment = investmentsStore.availableInvestments.find(inv => inv.id === investmentId)
  return investment?.icon || 'i-lucide-circle'
}

const formatPrice = (price: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}

// Get client data with fallback to Survey Client
const getClientName = (contract: any): string => {
  return contract.client_name || props.clientData?.name || ''
}

const getClientAddress = (contract: any): string => {
  if (contract.client_address) {
    return contract.client_address
  }

  // Build from Survey Client data
  if (props.clientData) {
    const parts = [
      props.clientData.postal_code,
      props.clientData.city,
      props.clientData.street,
      props.clientData.house_number
    ].filter(Boolean)
    return parts.join(', ')
  }

  return ''
}

const getClientPhone = (contract: any): string => {
  return contract.client_phone || props.clientData?.phone || ''
}

const getClientEmail = (contract: any): string => {
  return contract.client_email || props.clientData?.email || ''
}

// Emits
const emit = defineEmits<{
  'save-without-send': [contractId: string]
  'save-and-send': [contractId: string]
  'sign-now': [contractId: string]
}>()

// Methods
const handleSaveWithoutSend = (contractId: string) => {
  emit('save-without-send', contractId)
}

const handleSaveAndSend = (contractId: string) => {
  emit('save-and-send', contractId)
}

const handleSignNow = (contractId: string) => {
  emit('sign-now', contractId)
}

// Lifecycle
onMounted(async () => {
  loading.value = true
  try {
    // Load contracts
    await contractsStore.loadContracts(props.surveyId)

    // Load investments data if not already loaded
    if (investmentsStore.availableInvestments.length === 0) {
      await investmentsStore.initializeForSurvey(props.surveyId)
    }
  } catch (error) {
    console.error('Error loading summary data:', error)
  } finally {
    loading.value = false
  }
})
</script>
