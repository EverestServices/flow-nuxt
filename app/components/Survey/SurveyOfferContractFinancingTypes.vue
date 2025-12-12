<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between">
      <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.cash') }}</label>
      <USwitch v-model="financing.cash" />
    </div>
    <div class="flex items-center justify-between">
      <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.loan') }}</label>
      <USwitch v-model="financing.loan" />
    </div>
    <div class="flex items-center justify-between">
      <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.lease') }}</label>
      <USwitch v-model="financing.lease" />
    </div>
    <div class="flex items-center justify-between">
      <label class="text-sm text-gray-700 dark:text-gray-300">{{ $t('survey.financing.subsidy') }}</label>
      <USwitch v-model="financing.subsidy" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

// State
const financing = ref({
  cash: false,
  loan: false,
  lease: false,
  subsidy: false
})

// TODO: Load/save financing types from/to database when needed
// This is a placeholder component that follows the design from FinancingModal
</script>
