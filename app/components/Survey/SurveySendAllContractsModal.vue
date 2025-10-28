<template>
  <UIModal
    v-model="isOpen"
    :title="`Send Contracts (${contracts.length})`"
    size="full"
    :scrollable="true"
    @close="close"
  >
    <div class="space-y-8">
      <!-- Contract Previews -->
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

        <!-- Divider -->
        <div
          v-if="index < contracts.length - 1"
          class="border-b-2 border-gray-300 dark:border-gray-600 my-8"
        ></div>
      </div>

      <!-- Email Template Editor -->
      <div class="border-t-2 border-gray-300 dark:border-gray-600 pt-8">
        <EmailTemplateEditor v-model="emailTemplate" />
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
        :disabled="!emailTemplate.trim()"
        @click="handleSend"
      >
        <Icon name="i-lucide-send" class="w-4 h-4 mr-2" />
        Küldés
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import ContractPreview from './ContractPreview.vue'
import EmailTemplateEditor from './EmailTemplateEditor.vue'

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
  'send': [emailTemplate: string]
}>()

const isOpen = ref(false)

const emailTemplate = ref(`Kedves {client_name}!

Csatoltan megküldjük Önnek ajánlatainkat.

Kérem, tekintse át az ajánlatokat, és ha bármilyen kérdése van, keressen minket bizalommal!

Üdvözlettel,
[Az Ön Neve]
[Cég Neve]`)

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
    // Reset email template when modal opens
    emailTemplate.value = `Kedves {client_name}!

Csatoltan megküldjük Önnek ajánlatainkat.

Kérem, tekintse át az ajánlatokat, és ha bármilyen kérdése van, keressen minket bizalommal!

Üdvözlettel,
[Az Ön Neve]
[Cég Neve]`
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

const handleSend = () => {
  emit('send', emailTemplate.value)
  close()
}
</script>
