<template>
  <UIModal
    v-model="isOpen"
    title="Szerződés aláírása"
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

      <!-- Switches -->
      <div class="space-y-4 bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">
            Elfogadom az Adatkezelési Tájékoztatót
          </label>
          <USwitch v-model="acceptPrivacyPolicy" />
        </div>

        <div class="flex items-center justify-between">
          <label class="text-sm text-gray-700 dark:text-gray-300">
            Elfogadom a szerződésben foglaltakat
          </label>
          <USwitch v-model="acceptContract" />
        </div>

        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700 dark:text-gray-300">
            Szerződés elküldése e-mailben
            <span class="text-gray-500 dark:text-gray-400 ml-2">
              ({{ clientEmail }})
            </span>
          </div>
          <USwitch v-model="sendByEmail" />
        </div>
      </div>

      <!-- Signature Pad -->
      <SignaturePad ref="signaturePadRef" v-model="signature" />
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
        :disabled="!canSign"
        @click="handleSign"
      >
        <Icon name="i-lucide-pen-tool" class="w-4 h-4 mr-2" />
        Aláírás
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import ContractPreview from './ContractPreview.vue'
import SignaturePad from './SignaturePad.vue'

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
  'sign': [data: { signature: string; acceptPrivacyPolicy: boolean; acceptContract: boolean; sendByEmail: boolean }]
}>()

const isOpen = ref(false)
const signaturePadRef = ref<InstanceType<typeof SignaturePad> | null>(null)
const acceptPrivacyPolicy = ref(false)
const acceptContract = ref(false)
const sendByEmail = ref(false)
const signature = ref('')

const clientEmail = computed(() => {
  return props.contract.client_email || props.clientData?.email || 'N/A'
})

const canSign = computed(() => {
  return acceptPrivacyPolicy.value &&
    acceptContract.value &&
    signature.value &&
    signaturePadRef.value &&
    !signaturePadRef.value.isEmpty()
})

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
  if (value) {
    // Reset form when modal opens
    acceptPrivacyPolicy.value = false
    acceptContract.value = false
    sendByEmail.value = false
    signature.value = ''
    if (signaturePadRef.value) {
      signaturePadRef.value.clear()
    }
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

const handleSign = () => {
  if (!canSign.value) return

  emit('sign', {
    signature: signature.value,
    acceptPrivacyPolicy: acceptPrivacyPolicy.value,
    acceptContract: acceptContract.value,
    sendByEmail: sendByEmail.value
  })
  close()
}
</script>
