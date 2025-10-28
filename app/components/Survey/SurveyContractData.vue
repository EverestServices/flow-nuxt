<template>
  <div class="h-full flex flex-col bg-gray-50 dark:bg-gray-900">
    <!-- Contract Selector Section -->
    <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 p-6">
      <h3 class="text-sm font-medium text-gray-900 dark:text-white mb-3">
        {{ $t('survey.contractData.selectContracts') }}
      </h3>

      <!-- Contract Buttons -->
      <div class="flex gap-3 flex-wrap">
        <button
          v-for="contract in contracts"
          :key="contract.id"
          class="flex flex-col gap-1.5 px-4 py-2.5 rounded-lg text-sm transition-all border-2 min-w-[200px]"
          :class="isContractSelected(contract.id)
            ? 'bg-primary-600 text-white border-primary-600'
            : 'bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 border-gray-200 dark:border-gray-600'"
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
      <p v-if="contracts.length === 0" class="text-sm text-gray-500 dark:text-gray-400">
        {{ $t('survey.contractData.noContracts') }}
      </p>
    </div>

    <!-- Contract Cards Section -->
    <div v-if="selectedContracts.length > 0" class="flex-1 overflow-auto p-6">
      <div class="grid gap-6" :class="{
        'grid-cols-1': selectedContracts.length === 1,
        'grid-cols-2': selectedContracts.length === 2,
        'grid-cols-3': selectedContracts.length === 3
      }">
        <!-- Contract Card -->
        <div
          v-for="contract in selectedContracts"
          :key="contract.id"
          class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
        >
          <!-- Card Header -->
          <div class="bg-primary-600 text-white px-4 py-3">
            <h4 class="font-medium">{{ contract.name }}</h4>
          </div>

          <!-- Card Content -->
          <div class="p-4 space-y-6">
            <!-- Client Data Section -->
            <div>
              <div class="flex items-center justify-between mb-3">
                <h5 class="text-sm font-medium text-gray-900 dark:text-white">{{ $t('survey.contractData.clientData') }}</h5>
                <div v-if="selectedContracts.length > 1" class="flex items-center gap-2">
                  <span class="text-xs text-gray-500 dark:text-gray-400">{{ $t('survey.contractData.copyTo') }}</span>
                  <div class="flex gap-1">
                    <UButton
                      v-for="otherContract in getOtherContracts(contract.id)"
                      :key="otherContract.id"
                      :label="getContractShortName(otherContract.name)"
                      size="xs"
                      color="gray"
                      variant="outline"
                      @click="copyClientData(contract.id, otherContract.id)"
                    />
                  </div>
                </div>
              </div>

              <div class="space-y-3">
                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Name
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].client_name"
                    size="sm"
                    :placeholder="$t('survey.contractData.clientName')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Address
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].client_address"
                    size="sm"
                    :placeholder="$t('survey.contractData.clientAddress')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Phone
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].client_phone"
                    size="sm"
                    :placeholder="$t('survey.contractData.phoneNumber')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Email
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].client_email"
                    type="email"
                    size="sm"
                    :placeholder="$t('survey.contractData.emailAddress')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>
              </div>
            </div>

            <!-- Personal Details Section -->
            <div>
              <div class="flex items-center justify-between mb-3">
                <h5 class="text-sm font-medium text-gray-900 dark:text-white">{{ $t('survey.contractData.personalDetails') }}</h5>
                <div v-if="selectedContracts.length > 1" class="flex items-center gap-2">
                  <span class="text-xs text-gray-500 dark:text-gray-400">{{ $t('survey.contractData.copyTo') }}</span>
                  <div class="flex gap-1">
                    <UButton
                      v-for="otherContract in getOtherContracts(contract.id)"
                      :key="otherContract.id"
                      :label="getContractShortName(otherContract.name)"
                      size="xs"
                      color="gray"
                      variant="outline"
                      @click="copyPersonalDetails(contract.id, otherContract.id)"
                    />
                  </div>
                </div>
              </div>

              <div class="space-y-3">
                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Birth Place
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].birth_place"
                    size="sm"
                    :placeholder="$t('survey.contractData.birthPlace')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Date of Birth
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].date_of_birth"
                    type="date"
                    size="sm"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    ID Card Number
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].id_card_number"
                    size="sm"
                    :placeholder="$t('survey.contractData.idCardNumber')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Tax ID
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].tax_id"
                    size="sm"
                    :placeholder="$t('survey.contractData.taxId')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Mother's Name
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].mother_birth_name"
                    size="sm"
                    :placeholder="$t('survey.contractData.motherBirthName')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Bank Account Number
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].bank_account_number"
                    size="sm"
                    :placeholder="$t('survey.contractData.bankAccountNumber')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Citizenship
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].citizenship"
                    size="sm"
                    :placeholder="$t('survey.contractData.citizenship')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Marital Status
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].marital_status"
                    size="sm"
                    :placeholder="$t('survey.contractData.maritalStatus')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Residence Card Number
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].residence_card_number"
                    size="sm"
                    :placeholder="$t('survey.contractData.residenceCardNumber')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>

                <div>
                  <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Mailing Address
                  </label>
                  <UInput
                    v-model="contractsData[contract.id].mailing_address"
                    size="sm"
                    :placeholder="$t('survey.contractData.mailingAddress')"
                    class="w-full"
                    @update:model-value="handleFieldUpdate(contract.id)"
                  />
                </div>
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

// Get contract investment icons
const getContractInvestmentIcons = (contractId: string) => {
  const investmentIds = contractsStore.contractInvestments[contractId] || []

  return investmentIds
    .map(id => {
      const investment = investmentsStore.availableInvestments.find(inv => inv.id === id)
      return investment ? investment.icon : null
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
