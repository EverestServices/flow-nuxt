<template>
  <div class="h-full flex flex-col bg-gray-50 dark:bg-gray-900">
    <!-- View Toggle -->
    <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4">
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('survey.summary.view') }}</span>
        <UButton
          :icon="viewMode === 'list' ? 'i-lucide-list' : 'i-lucide-layout-grid'"
          :color="viewMode === 'list' ? 'primary' : 'gray'"
          variant="outline"
          size="sm"
          @click="viewMode = 'list'"
        >
          {{ $t('survey.summary.list') }}
        </UButton>
        <UButton
          :icon="viewMode === 'card' ? 'i-lucide-layout-grid' : 'i-lucide-layout-grid'"
          :color="viewMode === 'card' ? 'primary' : 'gray'"
          variant="outline"
          size="sm"
          @click="viewMode = 'card'"
        >
          {{ $t('survey.summary.card') }}
        </UButton>
      </div>
    </div>

    <!-- Content Area -->
    <div class="flex-1 overflow-y-auto p-6">
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center h-full">
        <div class="text-center">
          <UIcon name="i-lucide-loader-2" class="w-8 h-8 animate-spin text-primary mx-auto mb-2" />
          <p class="text-gray-600 dark:text-gray-400">{{ $t('survey.summary.loadingContracts') }}</p>
        </div>
      </div>

      <!-- No Contracts State -->
      <div v-else-if="!contracts || contracts.length === 0" class="flex items-center justify-center h-full">
        <div class="text-center">
          <UIcon name="i-lucide-file-text" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p class="text-gray-600 dark:text-gray-400">{{ $t('survey.summary.noContracts') }}</p>
        </div>
      </div>

      <!-- Contract Cards -->
      <div
        v-else
        :class="[
          'gap-6',
          viewMode === 'list' ? 'flex flex-col' : 'grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3'
        ]"
      >
        <div
          v-for="contract in contracts"
          :key="contract.id"
          class="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden"
        >
          <!-- Card Header -->
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-b border-gray-200 dark:border-gray-600">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              {{ contract.name }}
            </h3>
          </div>

          <!-- Card Body -->
          <div class="p-6 space-y-6">
            <!-- Client Information -->
            <div>
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3">
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
            <div>
              <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-3">
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
          <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 border-t border-gray-200 dark:border-gray-600">
            <div class="flex items-center justify-end gap-2">
              <!-- Save without send -->
              <UButton
                :icon="'i-lucide-save'"
                :label="viewMode === 'list' ? $t('survey.summary.saveWithoutSend') : undefined"
                color="gray"
                variant="outline"
                size="sm"
                @click="handleSaveWithoutSend(contract.id)"
              />

              <!-- Save and Send -->
              <UButton
                :icon="'i-lucide-send'"
                :label="viewMode === 'list' ? $t('survey.summary.saveAndSend') : undefined"
                color="primary"
                variant="outline"
                size="sm"
                @click="handleSaveAndSend(contract.id)"
              />

              <!-- Sign Now -->
              <UButton
                :icon="'i-lucide-pen-tool'"
                :label="viewMode === 'list' ? $t('survey.summary.signNow') : undefined"
                color="primary"
                size="sm"
                @click="handleSignNow(contract.id)"
              />
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
}

const props = defineProps<Props>()

const contractsStore = useContractsStore()
const investmentsStore = useSurveyInvestmentsStore()

const viewMode = ref<'list' | 'card'>('list')
const loading = ref(false)

// Computed
const contracts = computed(() => contractsStore.contracts)

const getContractInvestments = (contractId: string): string[] => {
  return contractsStore.contractInvestments[contractId] || []
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
