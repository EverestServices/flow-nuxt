<template>
  <div class="space-y-3">
    <!-- Investment Accordions -->
    <UAccordion
      v-for="(item, index) in investmentAccordionItems"
      :key="scenarioInvestments[index].id"
      :items="[item]"
      :ui="{
        wrapper: 'w-full',
        item: {
          base: 'w-full',
          padding: 'p-0'
        }
      }"
    >
      <template #[item.slot]>
        <div class="p-3">
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-3">{{ $t('survey.technicalDetails.title') }}</p>

          <!-- Main Component Categories -->
          <SurveyScenarioCategories
            :scenario-id="scenarioId"
            :investment-id="scenarioInvestments[index].id"
          />
        </div>
      </template>
    </UAccordion>

    <!-- No investments message -->
    <p v-if="scenarioInvestments.length === 0" class="text-sm text-gray-500 dark:text-gray-400">
      {{ $t('survey.technicalDetails.noInvestments') }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { getTechnicalDataSummary } from '~/utils/technicalDataSummary'

const { t } = useI18n()

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

// Build packageData for an investment from its scenario components
const buildPackageData = (investmentId: string) => {
  const components = scenariosStore.scenarioComponents[props.scenarioId] || []
  const investmentComponents = components.filter(c => c.investment_id === investmentId)

  const packageData: Record<string, any[]> = {}

  investmentComponents.forEach(scenarioComponent => {
    const mainComponent = scenariosStore.getMainComponentById(scenarioComponent.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === mainComponent.main_component_category_id
    )
    if (!category) return

    const categoryKey = category.persist_name

    if (!packageData[categoryKey]) {
      packageData[categoryKey] = []
    }

    packageData[categoryKey].push({
      product: {
        power: mainComponent.power,
        capacity: mainComponent.capacity,
        efficiency: mainComponent.efficiency,
        uValue: mainComponent.u_value,
        thickness: mainComponent.thickness,
        cop: mainComponent.cop,
        energyClass: mainComponent.energy_class,
        volume: mainComponent.details ? parseVolume(mainComponent.details) : undefined
      },
      quantity: scenarioComponent.quantity
    })
  })

  return packageData
}

// Helper to parse volume from details string (if stored as "200L" or similar)
const parseVolume = (details: string): number | undefined => {
  const match = details.match(/(\d+)\s*[lL]/)
  return match ? parseInt(match[1]) : undefined
}

// Get technical summary for an investment
const getTechnicalSummaryForInvestment = (investmentId: string, investmentType: string): string => {
  const packageData = buildPackageData(investmentId)
  return getTechnicalDataSummary(investmentType, packageData)
}

// Build accordion items with technical summaries
const investmentAccordionItems = computed(() => {
  const { translate } = useTranslatableField()

  return scenarioInvestments.value.map(investment => {
    const technicalSummary = getTechnicalSummaryForInvestment(investment.id, investment.persist_name)

    return {
      label: translate(investment.name_translations, investment.name),
      icon: investment.icon,
      slot: `investment-${investment.id}`,
      defaultOpen: false,
      description: technicalSummary || undefined
    }
  })
})
</script>
