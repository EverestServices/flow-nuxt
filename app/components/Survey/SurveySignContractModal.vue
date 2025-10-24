<template>
  <!-- Backdrop -->
  <div
    v-if="modelValue"
    class="fixed inset-0 bg-black/50 z-40"
    @click="close"
  ></div>

  <!-- Modal -->
  <Transition name="modal-fade">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      @click.self="close"
    >
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-2xl max-w-5xl w-full max-h-[90vh] flex flex-col">
        <!-- Header -->
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              Szerződés aláírása
            </h3>
            <button
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
              @click="close"
            >
              <UIcon name="i-lucide-x" class="w-5 h-5" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="flex-1 overflow-y-auto p-6 space-y-6">
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

        <!-- Footer -->
        <div class="p-6 border-t border-gray-200 dark:border-gray-700">
          <div class="flex justify-end space-x-3">
            <UButton
              label="Mégse"
              color="gray"
              variant="outline"
              @click="close"
            />
            <UButton
              label="Aláírás"
              icon="i-lucide-pen-tool"
              color="primary"
              :disabled="!canSign"
              @click="handleSign"
            />
          </div>
        </div>
      </div>
    </div>
  </Transition>
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

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
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

const close = () => {
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

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active > div,
.modal-fade-leave-active > div {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-fade-enter-from > div,
.modal-fade-leave-to > div {
  transform: scale(0.95);
  opacity: 0;
}
</style>
