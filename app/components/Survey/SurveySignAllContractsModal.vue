<template>
  <UIModal
    v-model="isOpen"
    :title="$t('survey.footer.signAllContracts', { count: contracts.length })"
    size="full"
    :scrollable="true"
    @close="close"
  >
    <div class="space-y-8">
      <!-- Contract Previews with individual signature pads -->
      <div
        v-for="(contract, index) in contracts"
        :key="contract.id"
        class="space-y-4"
      >
        <div class="flex items-center gap-3 mb-4">
          <div class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-white text-sm font-semibold">
            {{ index + 1 }}
          </div>
          <h4 class="text-lg font-semibold text-gray-900 dark:text-white">
            {{ contract.name }}
          </h4>
        </div>

        <ContractPreview
          :contract="contract"
          :contract-investments="getContractInvestments(contract.id)"
          :contract-components="getContractComponents(contract.id)"
          :contract-extra-costs="getContractExtraCosts(contract.id)"
          :contract-discounts="getContractDiscounts(contract.id)"
          :investments="investments"
          :main-components="mainComponents"
          :client-data="clientData"
        />

        <!-- Per-Contract Acceptance and Signature -->
        <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-6 space-y-4">
          <div class="flex items-center justify-between">
            <label class="text-sm text-gray-700 dark:text-gray-300">
              Elfogadom a szerződésben foglaltakat
            </label>
            <USwitch v-model="acceptContracts[contract.id]" />
          </div>

          <SignaturePad
            :ref="(el) => setSignaturePadRef(contract.id, el)"
            v-model="signatures[contract.id]"
          />
        </div>

        <!-- Divider -->
        <div
          v-if="index < contracts.length - 1"
          class="border-b-2 border-gray-300 dark:border-gray-600 my-8"
        ></div>
      </div>

      <!-- Global Switches -->
      <div class="border-t-2 border-gray-300 dark:border-gray-600 pt-8 space-y-4 bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">
            Elfogadom az Adatkezelési Tájékoztatót
          </label>
          <USwitch v-model="acceptPrivacyPolicy" />
        </div>

        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700 dark:text-gray-300">
            Szerződések elküldése e-mailben
            <span class="text-gray-500 dark:text-gray-400 ml-2">
              ({{ clientEmail }})
            </span>
          </div>
          <USwitch v-model="sendByEmail" />
        </div>
      </div>
    </div>

    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="close"
      >
        Mégse
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="!canSignAll"
        @click="handleSignAll"
      >
        <Icon name="i-lucide-pen-tool" class="w-4 h-4 mr-2" />
        Összes aláírása
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, computed, watch, reactive } from 'vue'
import ContractPreview from './ContractPreview.vue'
import SignaturePad from './SignaturePad.vue'

interface Props {
  modelValue: boolean
  contracts: any[]
  contractInvestments: Record<string, string[]>
  contractComponents: Record<string, any[]>
  contractExtraCosts: Record<string, any[]>
  contractDiscounts: Record<string, any[]>
  investments: any[]
  mainComponents: any[]
  clientData?: any
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'sign': [data: {
    signatures: Record<string, string>
    acceptContracts: Record<string, boolean>
    acceptPrivacyPolicy: boolean
    sendByEmail: boolean
  }]
}>()

const isOpen = ref(false)
const signaturePadRefs = ref<Record<string, InstanceType<typeof SignaturePad>>>({})
const acceptContracts = reactive<Record<string, boolean>>({})
const signatures = reactive<Record<string, string>>({})
const acceptPrivacyPolicy = ref(false)
const sendByEmail = ref(false)

const clientEmail = computed(() => {
  // Try to get email from first contract or client data
  const firstContract = props.contracts[0]
  return firstContract?.client_email || props.clientData?.email || 'N/A'
})

const canSignAll = computed(() => {
  // Check if privacy policy is accepted
  if (!acceptPrivacyPolicy.value) return false

  // Check if all contracts are accepted and signed
  for (const contract of props.contracts) {
    const isAccepted = acceptContracts[contract.id]
    const signature = signatures[contract.id]
    const signaturePad = signaturePadRefs.value[contract.id]

    if (!isAccepted || !signature || !signaturePad || signaturePad.isEmpty()) {
      return false
    }
  }

  return true
})

const setSignaturePadRef = (contractId: string, el: any) => {
  if (el) {
    signaturePadRefs.value[contractId] = el
  }
}

const getContractInvestments = (contractId: string): string[] => {
  return props.contractInvestments[contractId] || []
}

const getContractComponents = (contractId: string): any[] => {
  return props.contractComponents[contractId] || []
}

const getContractExtraCosts = (contractId: string): any[] => {
  return props.contractExtraCosts[contractId] || []
}

const getContractDiscounts = (contractId: string): any[] => {
  return props.contractDiscounts[contractId] || []
}

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
  if (value) {
    // Reset form when modal opens
    acceptPrivacyPolicy.value = false
    sendByEmail.value = false

    // Reset per-contract data
    props.contracts.forEach(contract => {
      acceptContracts[contract.id] = false
      signatures[contract.id] = ''
      const signaturePad = signaturePadRefs.value[contract.id]
      if (signaturePad) {
        signaturePad.clear()
      }
    })
  }
})

watch(isOpen, (value) => {
  if (value !== props.modelValue) {
    emit('update:modelValue', value)
  }
})

const close = () => {
  isOpen.value = false
  emit('update:modelValue', false)
}

const handleSignAll = () => {
  if (!canSignAll.value) return

  emit('sign', {
    signatures: { ...signatures },
    acceptContracts: { ...acceptContracts },
    acceptPrivacyPolicy: acceptPrivacyPolicy.value,
    sendByEmail: sendByEmail.value
  })
  close()
}
</script>
