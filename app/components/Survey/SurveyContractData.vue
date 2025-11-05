<template>
  <div class="min-h-screen relative overflow-hidden py-20 px-3">
    <!-- Contract Selector Section -->
    <div class="backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20 p-6 mb-6 z-20">
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
        <UIcon name="i-lucide-file-text" class="w-5 h-5" />
        {{ $t('survey.contractData.selectContracts') }}
        <span class="text-xs font-normal text-gray-500 dark:text-gray-400 ml-auto">
          {{ selectedContractIds.length }}/3
        </span>
      </h3>

      <!-- Contract Buttons -->
      <div class="flex gap-3 flex-wrap">
        <button
          v-for="contract in contracts"
          :key="contract.id"
          class="flex flex-col gap-2 px-5 py-3 rounded-2xl text-sm transition-all duration-200 border-2 min-w-[220px]"
          :class="isContractSelected(contract.id)
            ? 'bg-gradient-to-br from-blue-600 to-indigo-600 text-white border-blue-500 scale-105'
            : 'bg-white/70 dark:bg-gray-700/70 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-600 border-gray-200 dark:border-gray-600 hover:scale-105'"
          :disabled="!isContractSelected(contract.id) && selectedContractIds.length >= 3"
          @click="toggleContractSelection(contract.id)"
        >
          <!-- Top Row: Contract Name + Scenario Name -->
          <div class="flex items-center justify-between gap-2">
            <span class="font-medium">{{ contract.name }}</span>
            <span class="text-xs opacity-80">{{ getScenarioName(contract.scenario_id) }}</span>
          </div>

          <!-- Bottom Row: Investment Icons + Implementation Fee -->
          <div class="flex items-center justify-between gap-2">
            <!-- Investment Icons -->
            <div class="flex gap-1">
              <UIcon
                v-for="(icon, index) in getContractInvestmentIcons(contract.id)"
                :key="index"
                :name="icon"
                class="w-4 h-4"
              />
            </div>

            <!-- Implementation Fee -->
            <span class="text-xs font-medium">
              {{ formatPrice(contract.total_price) }}
            </span>
          </div>
        </button>
      </div>

      <!-- No contracts message -->
      <div v-if="contracts.length === 0" class="text-center py-8">
        <UIcon name="i-lucide-inbox" class="w-12 h-12 text-gray-400 mx-auto mb-3" />
        <p class="text-sm text-gray-500 dark:text-gray-400">
          {{ $t('survey.contractData.noContracts') }}
        </p>
      </div>
    </div>

    <!-- Contract Cards Section -->
    <div v-if="selectedContracts.length > 0" class="flex-1 overflow-auto">
      <div class="grid gap-6" :class="{
        'grid-cols-1': selectedContracts.length === 1,
        'grid-cols-2': selectedContracts.length === 2,
        'grid-cols-3': selectedContracts.length === 3
      }">
        <!-- Contract Card -->
        <div
          v-for="contract in selectedContracts"
          :key="contract.id"
          class="backdrop-blur-md bg-white/80 dark:bg-gray-800/80 rounded-3xl border border-white/20 dark:border-gray-700/20"
        >
          <!-- Card Header -->
          <div class="m-4 bg-gradient-to-r from-blue-600 to-indigo-600 text-white px-6 py-3 rounded-full">
            <h4 class="font-semibold text-base text-center">{{ contract.name }}</h4>
          </div>

          <!-- Card Content -->
          <div class="px-6 pb-6 space-y-6">
            <!-- Client Data Section -->
            <div class="backdrop-blur-sm bg-white/30 dark:bg-gray-900/30 rounded-2xl p-4 border border-white/20 dark:border-gray-700/20">
              <div class="flex items-center justify-between mb-4">
                <h5 class="text-sm font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                  <UIcon name="i-lucide-user" class="w-4 h-4" />
                  {{ $t('survey.contractData.clientData') }}
                </h5>
                <div v-if="selectedContracts.length > 1" class="flex items-center gap-2">
                  <span class="text-xs text-gray-500 dark:text-gray-400">{{ $t('survey.contractData.copyTo') }}</span>
                  <div class="flex gap-1">
                    <button
                      v-for="otherContract in getOtherContracts(contract.id)"
                      :key="otherContract.id"
                      class="px-2 py-1 text-xs font-medium rounded-lg bg-white/80 dark:bg-gray-700/80 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-600 border border-gray-200 dark:border-gray-600 transition-all hover:scale-105"
                      @click="copyClientData(contract.id, otherContract.id)"
                    >
                      {{ getContractShortName(otherContract.name) }}
                    </button>
                  </div>
                </div>
              </div>

              <div class="space-y-3">
                <UIInput
                  v-model="contractsData[contract.id].client_name"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.name')"
                  :placeholder="$t('survey.contractData.clientName')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].client_address"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.address')"
                  :placeholder="$t('survey.contractData.clientAddress')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].client_phone"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.phone')"
                  :placeholder="$t('survey.contractData.phoneNumber')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].client_email"
                  type="email"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.email')"
                  :placeholder="$t('survey.contractData.emailAddress')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />
              </div>
            </div>

            <!-- Personal Details Section -->
            <div class="backdrop-blur-sm bg-white/30 dark:bg-gray-900/30 rounded-2xl p-4 border border-white/20 dark:border-gray-700/20">
              <div class="flex items-center justify-between mb-4">
                <h5 class="text-sm font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                  <UIcon name="i-lucide-id-card" class="w-4 h-4" />
                  {{ $t('survey.contractData.personalDetails') }}
                </h5>
                <div v-if="selectedContracts.length > 1" class="flex items-center gap-2">
                  <span class="text-xs text-gray-500 dark:text-gray-400">{{ $t('survey.contractData.copyTo') }}</span>
                  <div class="flex gap-1">
                    <button
                      v-for="otherContract in getOtherContracts(contract.id)"
                      :key="otherContract.id"
                      class="px-2 py-1 text-xs font-medium rounded-lg bg-white/80 dark:bg-gray-700/80 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-600 border border-gray-200 dark:border-gray-600 transition-all hover:scale-105"
                      @click="copyPersonalDetails(contract.id, otherContract.id)"
                    >
                      {{ getContractShortName(otherContract.name) }}
                    </button>
                  </div>
                </div>
              </div>

              <div class="space-y-3">
                <UIInput
                  v-model="contractsData[contract.id].birth_place"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.birthPlace')"
                  :placeholder="$t('survey.contractData.birthPlace')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].date_of_birth"
                  type="date"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.dateOfBirth')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].id_card_number"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.idCardNumber')"
                  :placeholder="$t('survey.contractData.idCardNumber')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].tax_id"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.taxId')"
                  :placeholder="$t('survey.contractData.taxId')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].mother_birth_name"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.motherBirthName')"
                  :placeholder="$t('survey.contractData.motherBirthName')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].bank_account_number"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.bankAccountNumber')"
                  :placeholder="$t('survey.contractData.bankAccountNumber')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].citizenship"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.citizenship')"
                  :placeholder="$t('survey.contractData.citizenship')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].marital_status"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.maritalStatus')"
                  :placeholder="$t('survey.contractData.maritalStatus')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].residence_card_number"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.residenceCardNumber')"
                  :placeholder="$t('survey.contractData.residenceCardNumber')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />

                <UIInput
                  v-model="contractsData[contract.id].mailing_address"
                  variant="glass"
                  size="sm"
                  :label="$t('survey.contractData.mailingAddress')"
                  :placeholder="$t('survey.contractData.mailingAddress')"
                  @update:model-value="handleFieldUpdate(contract.id)"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useContractsStore, type Contract } from '~/stores/contracts'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface Props {
  surveyId: string
  clientData?: any
}

const props = defineProps<Props>()

const contractsStore = useContractsStore()
const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()

// Selected contract IDs (max 3)
const selectedContractIds = ref<string[]>([])

// Contract data for each selected contract
const contractsData = ref<Record<string, any>>({})

// Debounce timers for auto-save
const saveTimers = ref<Record<string, NodeJS.Timeout>>({})

// Get all contracts sorted by created_at (earliest first)
const contracts = computed(() => {
  return [...contractsStore.contracts].sort((a, b) => {
    return new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  })
})

// Get selected contracts in selection order
const selectedContracts = computed(() => {
  return selectedContractIds.value
    .map(id => contracts.value.find(c => c.id === id))
    .filter(Boolean) as Contract[]
})

// Toggle contract selection
const toggleContractSelection = (contractId: string) => {
  const index = selectedContractIds.value.indexOf(contractId)

  if (index > -1) {
    // Deselect
    selectedContractIds.value.splice(index, 1)
  } else {
    // Select (if less than 3 are selected)
    if (selectedContractIds.value.length < 3) {
      selectedContractIds.value.push(contractId)

      // Initialize contract data if not already present
      if (!contractsData.value[contractId]) {
        const contract = contracts.value.find(c => c.id === contractId)
        if (contract) {
          // Build full address from client data if available
          const clientAddress = props.clientData
            ? [
                props.clientData.postal_code,
                props.clientData.city,
                props.clientData.street,
                props.clientData.house_number
              ].filter(Boolean).join(', ')
            : ''

          contractsData.value[contractId] = {
            // Use contract data if available, otherwise use client data as default
            client_name: contract.client_name || props.clientData?.name || '',
            client_address: contract.client_address || clientAddress || '',
            client_phone: contract.client_phone || props.clientData?.phone || '',
            client_email: contract.client_email || props.clientData?.email || '',
            birth_place: contract.birth_place || '',
            date_of_birth: contract.date_of_birth || null,
            id_card_number: contract.id_card_number || '',
            tax_id: contract.tax_id || '',
            mother_birth_name: contract.mother_birth_name || '',
            bank_account_number: contract.bank_account_number || '',
            citizenship: contract.citizenship || '',
            marital_status: contract.marital_status || '',
            residence_card_number: contract.residence_card_number || '',
            mailing_address: contract.mailing_address || ''
          }
        }
      }
    }
  }
}

// Check if contract is selected
const isContractSelected = (contractId: string) => {
  return selectedContractIds.value.includes(contractId)
}

// Get scenario name by ID
const getScenarioName = (scenarioId: string | null | undefined) => {
  if (!scenarioId) return ''
  const scenario = scenariosStore.scenarios.find(s => s.id === scenarioId)
  return scenario?.name || ''
}

// Get contract investment icons (filter out is_default investments)
const getContractInvestmentIcons = (contractId: string) => {
  const investmentIds = contractsStore.contractInvestments[contractId] || []

  return investmentIds
    .map(id => {
      const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
      return investment && !investment.is_default ? investment.icon : null
    })
    .filter(Boolean)
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    maximumFractionDigits: 0
  }).format(price)
}

// Get other contracts (excluding current one)
const getOtherContracts = (currentContractId: string) => {
  return selectedContracts.value.filter(c => c.id !== currentContractId)
}

// Get contract short name (always return full name)
const getContractShortName = (name: string) => {
  return name
}

// Copy Client Data from one contract to another
const copyClientData = (fromContractId: string, toContractId: string) => {
  const fromData = contractsData.value[fromContractId]
  if (!fromData) return

  contractsData.value[toContractId].client_name = fromData.client_name
  contractsData.value[toContractId].client_address = fromData.client_address
  contractsData.value[toContractId].client_phone = fromData.client_phone
  contractsData.value[toContractId].client_email = fromData.client_email

  // Trigger save for the target contract
  handleFieldUpdate(toContractId)
}

// Copy Personal Details from one contract to another
const copyPersonalDetails = (fromContractId: string, toContractId: string) => {
  const fromData = contractsData.value[fromContractId]
  if (!fromData) return

  contractsData.value[toContractId].birth_place = fromData.birth_place
  contractsData.value[toContractId].date_of_birth = fromData.date_of_birth
  contractsData.value[toContractId].id_card_number = fromData.id_card_number
  contractsData.value[toContractId].tax_id = fromData.tax_id
  contractsData.value[toContractId].mother_birth_name = fromData.mother_birth_name
  contractsData.value[toContractId].bank_account_number = fromData.bank_account_number
  contractsData.value[toContractId].citizenship = fromData.citizenship
  contractsData.value[toContractId].marital_status = fromData.marital_status
  contractsData.value[toContractId].residence_card_number = fromData.residence_card_number
  contractsData.value[toContractId].mailing_address = fromData.mailing_address

  // Trigger save for the target contract
  handleFieldUpdate(toContractId)
}

// Handle field update with debounced auto-save
const handleFieldUpdate = (contractId: string) => {
  // Clear existing timer
  if (saveTimers.value[contractId]) {
    clearTimeout(saveTimers.value[contractId])
  }

  // Set new timer for auto-save (1 second delay)
  saveTimers.value[contractId] = setTimeout(async () => {
    await saveContractData(contractId)
  }, 1000)
}

// Save contract data to database
const saveContractData = async (contractId: string) => {
  try {
    const data = contractsData.value[contractId]
    if (!data) return

    await contractsStore.updateContract(contractId, {
      client_name: data.client_name,
      client_address: data.client_address,
      client_phone: data.client_phone,
      client_email: data.client_email,
      birth_place: data.birth_place,
      date_of_birth: data.date_of_birth || null, // Convert empty string to null
      id_card_number: data.id_card_number,
      tax_id: data.tax_id,
      mother_birth_name: data.mother_birth_name,
      bank_account_number: data.bank_account_number,
      citizenship: data.citizenship,
      marital_status: data.marital_status,
      residence_card_number: data.residence_card_number,
      mailing_address: data.mailing_address
    })

    console.log(`Contract ${contractId} data saved successfully`)
  } catch (error) {
    console.error(`Error saving contract ${contractId} data:`, error)
  }
}

// Initialize selected contracts on mount (select first contract by default)
watch(() => contracts.value, (newContracts) => {
  if (newContracts.length > 0 && selectedContractIds.value.length === 0) {
    // Auto-select first contract
    toggleContractSelection(newContracts[0].id)
  }
}, { immediate: true })
</script>
