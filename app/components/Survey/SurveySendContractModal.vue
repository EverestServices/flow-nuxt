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
              Send Contract
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

          <!-- Email Template Editor -->
          <EmailTemplateEditor v-model="emailTemplate" />
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
              label="Küldés"
              icon="i-lucide-send"
              color="primary"
              :disabled="!emailTemplate.trim()"
              @click="handleSend"
            />
          </div>
        </div>
      </div>
    </div>
  </Transition>
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

const emailTemplate = ref(`Kedves {client_name}!

Csatoltan megküldjük Önnek a(z) {contract_name} ajánlatunkat.

A teljes összeg: {total_price}

Kérem, tekintse át az ajánlatot, és ha bármilyen kérdése van, keressen minket bizalommal!

Üdvözlettel,
[Az Ön Neve]
[Cég Neve]`)

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
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

const close = () => {
  emit('update:modelValue', false)
}

const handleSend = () => {
  emit('send', emailTemplate.value)
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
