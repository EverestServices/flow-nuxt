<template>
  <div class="space-y-3">
    <!-- Investment Accordions -->
    <UAccordion
      v-for="investment in scenarioInvestments"
      :key="investment.id"
      :items="[{
        label: investment.name,
        icon: investment.icon,
        slot: `investment-${investment.id}`,
        defaultOpen: false
      }]"
      :ui="{
        wrapper: 'w-full',
        item: {
          base: 'w-full',
          padding: 'p-0'
        }
      }"
    >
      <template #[`investment-${investment.id}`]>
        <div class="p-3">
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-3">Technikai adatok</p>

          <!-- Main Component Categories -->
          <SurveyScenarioCategories
            :scenario-id="scenarioId"
            :investment-id="investment.id"
          />
        </div>
      </template>
    </UAccordion>

    <!-- No investments message -->
    <p v-if="scenarioInvestments.length === 0" class="text-sm text-gray-500 dark:text-gray-400">
      No investments in this scenario.
    </p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()

// Get investment IDs for this scenario
const scenarioInvestmentIds = computed(() => {
  return scenariosStore.scenarioInvestments[props.scenarioId] || []
})

// Get full investment details
const scenarioInvestments = computed(() => {
  return scenarioInvestmentIds.value
    .map(id => investmentsStore.availableInvestments.find(inv => inv.id === id))
    .filter(Boolean)
})
</script>
