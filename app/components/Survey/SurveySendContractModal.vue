<template>
  <UIModal
    v-model="isOpen"
    title="Send Contract"
    size="xl"
    :scrollable="true"
    @close="close"
  >
    <div class="space-y-6">
      <!-- Contract Preview -->
      <ContractPreview
        :contract="contract"
        :contract-investments="contractInvestments"
        :contract-components="contractComponents"
        :contract-extra-costs="contractExtraCosts"
        :contract-discounts="contractDiscounts"
        :investments="investments"
        :main-components="mainComponents"
        :client-data="clientData"
      />

      <!-- Email Template Editor -->
      <EmailTemplateEditor v-model="emailTemplate" />
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
  contract: any
  contractInvestments: string[]
  contractComponents: any[]
  contractExtraCosts: any[]
  contractDiscounts: any[]
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

Csatoltan megküldjük Önnek a(z) {contract_name} ajánlatunkat.

A teljes összeg: {total_price}

Kérem, tekintse át az ajánlatot, és ha bármilyen kérdése van, keressen minket bizalommal!

Üdvözlettel,
[Az Ön Neve]
[Cég Neve]`)

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
  if (value) {
    // Reset email template when modal opens
    emailTemplate.value = `Kedves {client_name}!

Csatoltan megküldjük Önnek a(z) {contract_name} ajánlatunkat.

A teljes összeg: {total_price}

Kérem, tekintse át az ajánlatot, és ha bármilyen kérdése van, keressen minket bizalommal!

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
