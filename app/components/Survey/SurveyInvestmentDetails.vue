<template>
  <div class="space-y-4">
    <!-- Loading state -->
    <div v-if="loading" class="flex items-center justify-center py-8">
      <UIcon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-gray-400" />
    </div>

    <!-- Investment Details Table -->
    <div v-else-if="investmentImpacts.length > 0" class="space-y-4">
      <!-- Header -->
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
        Selected Investments
      </h3>

      <!-- Investments List -->
      <div class="space-y-2">
        <div
          v-for="impact in investmentImpacts"
          :key="impact.investmentName"
          class="flex items-center justify-between py-2 px-3 bg-gray-50 dark:bg-gray-800 rounded-lg"
        >
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {{ impact.investmentName }}
          </span>
          <span class="text-sm text-gray-600 dark:text-gray-400 font-mono">
            <template v-if="impact.electricityImpact !== undefined && impact.electricityImpact !== 0">
              {{ formatNumber(Math.abs(impact.electricityImpact)) }} kWh / year
            </template>
            <template v-else-if="impact.gasImpact !== undefined && impact.gasImpact !== 0">
              {{ formatNumber(impact.gasImpact) }} m³ / year
            </template>
            <template v-else>
              -
            </template>
          </span>
        </div>
      </div>

      <!-- Totals Section -->
      <div class="border-t border-gray-200 dark:border-gray-700 pt-4 space-y-2">
        <div
          class="flex items-center justify-between py-2 px-3 rounded-lg cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          @click="showElectricityBreakdown"
        >
          <span class="text-base font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            Electricity Impact
            <UIcon name="i-lucide-bar-chart-3" class="w-4 h-4 text-gray-400" />
          </span>
          <span class="text-base font-bold text-gray-900 dark:text-white font-mono">
            {{ totalElectricityImpact >= 0 ? '+' : '' }}{{ formatNumber(totalElectricityImpact) }} kWh / year
          </span>
        </div>

        <div
          class="flex items-center justify-between py-2 px-3 rounded-lg cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          @click="showGasBreakdown"
        >
          <span class="text-base font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            Natural Gas Impact
            <UIcon name="i-lucide-bar-chart-3" class="w-4 h-4 text-gray-400" />
          </span>
          <span class="text-base font-bold text-gray-900 dark:text-white font-mono">
            {{ totalGasImpact >= 0 ? '+' : '' }}{{ formatNumber(totalGasImpact) }} m³ / year
          </span>
        </div>
      </div>

      <!-- CO₂ Reduction Section -->
      <div class="border-t-2 border-gray-300 dark:border-gray-600 pt-4">
        <div class="text-center space-y-1">
          <div class="text-sm font-medium text-gray-700 dark:text-gray-300">
            Total CO₂ Reduction
          </div>
          <div class="text-2xl font-bold text-green-600 dark:text-green-400">
            {{ formatNumber(totalCO2Reduction) }} kg CO₂ / year
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="text-center py-6">
      <p class="text-sm text-gray-500 dark:text-gray-400">
        No investments in this scenario yet.
      </p>
    </div>

    <!-- Monthly Breakdown Modals -->
    <SurveyMonthlyBreakdownModal
      v-model="showElectricityModal"
      title="Monthly Electricity Impact"
      :monthly-data="monthlyElectricityData"
      unit="kWh"
      :loading="modalLoading"
    />

    <SurveyMonthlyBreakdownModal
      v-model="showGasModal"
      title="Monthly Natural Gas Impact"
      :monthly-data="monthlyGasData"
      unit="m³"
      :loading="modalLoading"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useEnergySavings } from '~/composables/useEnergySavings'

interface Props {
  surveyId: string
  scenarioId?: string
}

interface InvestmentImpact {
  investmentName: string
  investmentPersistName: string
  electricityImpact?: number // kWh/year (positive = production, negative = consumption)
  gasImpact?: number // m³/year (positive = savings)
}

const props = defineProps<Props>()

const scenariosStore = useScenariosStore()
const investmentsStore = useSurveyInvestmentsStore()
const {
  calculateSolarProduction,
  calculateHeatPumpImpact,
  calculateInsulationSavings,
  getCurrentWallUValue,
  getCurrentRoofUValue,
  getCurrentWindowUValue,
  calculateCO2Reduction,
  calculateMonthlySolarProduction,
  calculateMonthlyHeatPumpElectricity,
  calculateMonthlyGasSavings,
  calculateMonthlyElectricityNet
} = useEnergySavings()

const supabase = useSupabaseClient()
const { translate } = useTranslatableField()
const loading = ref(false)
const investmentImpacts = ref<InvestmentImpact[]>([])

// Modal state
const showElectricityModal = ref(false)
const showGasModal = ref(false)
const modalLoading = ref(false)
const monthlyElectricityData = ref<any[]>([])
const monthlyGasData = ref<any[]>([])

// Use provided scenarioId or active scenario
const currentScenarioId = computed(() => {
  return props.scenarioId || scenariosStore.activeScenarioId
})

// Computed totals
const totalElectricityImpact = computed(() => {
  return investmentImpacts.value.reduce((sum, impact) => {
    return sum + (impact.electricityImpact || 0)
  }, 0)
})

const totalGasImpact = computed(() => {
  return investmentImpacts.value.reduce((sum, impact) => {
    return sum + (impact.gasImpact || 0)
  }, 0)
})

const totalCO2Reduction = ref(0)

// Format number with thousand separators
const formatNumber = (num: number): string => {
  return Math.round(num).toLocaleString('en-US')
}

/**
 * Calculate impacts for all investments in the scenario
 */
const calculateImpacts = async () => {
  if (!currentScenarioId.value) return

  loading.value = true
  investmentImpacts.value = []

  try {
    // Get scenario components
    const scenarioComponents = scenariosStore.scenarioComponents[currentScenarioId.value] || []

    if (scenarioComponents.length === 0) {
      loading.value = false
      return
    }

    // Get scenario investments
    const scenarioInvestmentIds = scenariosStore.scenarioInvestments[currentScenarioId.value] || []

    // Get investment details
    const investments = investmentsStore.availableInvestments.filter(inv =>
      scenarioInvestmentIds.includes(inv.id)
    )

    // Group components by investment (through categories)
    const impactPromises = investments.map(async (investment) => {
      const persistName = investment.persist_name
      const translatedName = translate(investment.name_translations, investment.name)

      // Calculate based on investment type
      if (persistName === 'solarPanel' || persistName === 'solarPanelBattery') {
        return await calculateSolarImpact(scenarioComponents, translatedName)
      } else if (persistName === 'heatPump') {
        return await calculateHeatPumpImpactForInvestment(scenarioComponents, translatedName)
      } else if (persistName === 'facadeInsulation') {
        return await calculateFacadeInsulationImpact(scenarioComponents, translatedName)
      } else if (persistName === 'roofInsulation') {
        return await calculateRoofInsulationImpact(scenarioComponents, translatedName)
      } else if (persistName === 'windows') {
        return await calculateWindowsImpact(scenarioComponents, translatedName)
      }

      return null
    })

    const impacts = await Promise.all(impactPromises)
    investmentImpacts.value = impacts.filter(Boolean) as InvestmentImpact[]

    // Calculate total CO₂
    totalCO2Reduction.value = await calculateCO2Reduction(
      totalElectricityImpact.value,
      totalGasImpact.value
    )

  } catch (error) {
    console.error('Error calculating impacts:', error)
  } finally {
    loading.value = false
  }
}

/**
 * Calculate solar panel impact
 */
const calculateSolarImpact = async (
  scenarioComponents: any[],
  investmentName: string
): Promise<InvestmentImpact | null> => {
  // Find solar panels
  const panels = scenarioComponents.filter(sc => {
    const component = scenariosStore.getMainComponentById(sc.main_component_id)
    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === component?.main_component_category_id
    )
    return category?.persist_name === 'panel'
  })

  if (panels.length === 0) return null

  let totalProduction = 0

  for (const panelComponent of panels) {
    const component = scenariosStore.getMainComponentById(panelComponent.main_component_id)
    if (!component) continue

    const power = component.power || 425
    const efficiency = (component.efficiency || 20.5) / 100 // Convert to decimal
    const quantity = panelComponent.quantity

    const production = await calculateSolarProduction(power, quantity, efficiency)
    totalProduction += production
  }

  return {
    investmentName,
    investmentPersistName: 'solarPanel',
    electricityImpact: totalProduction
  }
}

/**
 * Calculate heat pump impact
 */
const calculateHeatPumpImpactForInvestment = async (
  scenarioComponents: any[],
  investmentName: string
): Promise<InvestmentImpact | null> => {
  // Find heat pump
  const heatPumps = scenarioComponents.filter(sc => {
    const component = scenariosStore.getMainComponentById(sc.main_component_id)
    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === component?.main_component_category_id
    )
    return category?.persist_name === 'heatpump'
  })

  if (heatPumps.length === 0) return null

  const heatPumpComponent = heatPumps[0]
  const component = scenariosStore.getMainComponentById(heatPumpComponent.main_component_id)
  if (!component) return null

  // Get current heating type and gas consumption from survey
  const { data: answers } = await supabase
    .from('survey_answers')
    .select(`
      answer,
      survey_question:survey_questions(name)
    `)
    .eq('survey_id', props.surveyId)

  const heatingTypeAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'current_heating_solution'
  )

  // Get household data for consumption
  const { data: survey } = await supabase
    .from('surveys')
    .select('household_data')
    .eq('id', props.surveyId)
    .single()

  const gasConsumption = survey?.household_data?.consumption
    ? parseFloat(survey.household_data.consumption)
    : 1500 // Default assumption

  const impact = await calculateHeatPumpImpact(
    component.power || 14000,
    component.cop || 4.5,
    heatingTypeAnswer?.answer || 'Nyílt égésterű kazán',
    gasConsumption
  )

  return {
    investmentName,
    investmentPersistName: 'heatPump',
    electricityImpact: -impact.electricityIncrease, // Negative because it's consumption
    gasImpact: impact.gasSavings
  }
}

/**
 * Calculate facade insulation impact
 */
const calculateFacadeInsulationImpact = async (
  scenarioComponents: any[],
  investmentName: string
): Promise<InvestmentImpact | null> => {
  // Find insulation components
  const insulations = scenarioComponents.filter(sc => {
    const component = scenariosStore.getMainComponentById(sc.main_component_id)
    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === component?.main_component_category_id
    )
    return category?.persist_name === 'insulation' && component?.persist_name?.startsWith('fi-')
  })

  if (insulations.length === 0) return null

  // Get current wall type from survey
  const { data: answers } = await supabase
    .from('survey_answers')
    .select(`
      answer,
      survey_question:survey_questions(name)
    `)
    .eq('survey_id', props.surveyId)

  const wallTypeAnswer = answers?.find((a: any) => a.survey_question?.name === 'wall_type')
  const heatingTypeAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'current_heating_solution'
  )

  let totalSavings = 0

  for (const insulationComponent of insulations) {
    const component = scenariosStore.getMainComponentById(insulationComponent.main_component_id)
    if (!component) continue

    const currentUValue = await getCurrentWallUValue(
      wallTypeAnswer?.answer || 'Kis méretű tömör tégla',
      false,
      0
    )
    const newUValue = component.u_value || 0.25
    const area = insulationComponent.quantity

    const savings = await calculateInsulationSavings(
      currentUValue,
      newUValue,
      area,
      heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
    )

    totalSavings += savings
  }

  return {
    investmentName,
    investmentPersistName: 'facadeInsulation',
    gasImpact: totalSavings
  }
}

/**
 * Calculate roof insulation impact
 */
const calculateRoofInsulationImpact = async (
  scenarioComponents: any[],
  investmentName: string
): Promise<InvestmentImpact | null> => {
  // Find insulation components
  const insulations = scenarioComponents.filter(sc => {
    const component = scenariosStore.getMainComponentById(sc.main_component_id)
    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === component?.main_component_category_id
    )
    return category?.persist_name === 'insulation' && component?.persist_name?.startsWith('ri-')
  })

  if (insulations.length === 0) return null

  // Get current roof type from survey
  const { data: answers } = await supabase
    .from('survey_answers')
    .select(`
      answer,
      survey_question:survey_questions(name)
    `)
    .eq('survey_id', props.surveyId)

  const roofTypeAnswer = answers?.find((a: any) => a.survey_question?.name === 'roof_type')
  const heatingTypeAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'current_heating_solution'
  )

  let totalSavings = 0

  for (const insulationComponent of insulations) {
    const component = scenariosStore.getMainComponentById(insulationComponent.main_component_id)
    if (!component) continue

    const currentUValue = await getCurrentRoofUValue(
      roofTypeAnswer?.answer || 'Sátortető',
      false,
      0
    )
    const newUValue = component.u_value || 0.21
    const area = insulationComponent.quantity

    const savings = await calculateInsulationSavings(
      currentUValue,
      newUValue,
      area,
      heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
    )

    totalSavings += savings
  }

  return {
    investmentName,
    investmentPersistName: 'roofInsulation',
    gasImpact: totalSavings
  }
}

/**
 * Calculate windows impact
 */
const calculateWindowsImpact = async (
  scenarioComponents: any[],
  investmentName: string
): Promise<InvestmentImpact | null> => {
  // Find window components
  const windows = scenarioComponents.filter(sc => {
    const component = scenariosStore.getMainComponentById(sc.main_component_id)
    const category = scenariosStore.mainComponentCategories.find(
      cat => cat.id === component?.main_component_category_id
    )
    return category?.persist_name === 'window'
  })

  if (windows.length === 0) return null

  // Get current window type from survey
  const { data: answers } = await supabase
    .from('survey_answers')
    .select(`
      answer,
      survey_question:survey_questions(name)
    `)
    .eq('survey_id', props.surveyId)

  const windowMaterialAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'window_material'
  )
  const windowGlazingAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'window_glazing'
  )
  const heatingTypeAnswer = answers?.find(
    (a: any) => a.survey_question?.name === 'current_heating_solution'
  )

  let totalSavings = 0

  for (const windowComponent of windows) {
    const component = scenariosStore.getMainComponentById(windowComponent.main_component_id)
    if (!component) continue

    const currentUValue = await getCurrentWindowUValue(
      windowMaterialAnswer?.answer || 'Fa',
      windowGlazingAnswer?.answer || '2 rétegű üvegezésű'
    )
    const newUValue = component.u_value || 0.72
    const area = windowComponent.quantity

    const savings = await calculateInsulationSavings(
      currentUValue,
      newUValue,
      area,
      heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
    )

    totalSavings += savings
  }

  return {
    investmentName,
    investmentPersistName: 'windows',
    gasImpact: totalSavings
  }
}

/**
 * Show monthly electricity breakdown modal
 */
const showElectricityBreakdown = async () => {
  if (!currentScenarioId.value) return

  modalLoading.value = true
  showElectricityModal.value = true

  try {
    const scenarioComponents = scenariosStore.scenarioComponents[currentScenarioId.value] || []

    // Calculate monthly solar production
    let monthlySolar: any[] = []
    const panels = scenarioComponents.filter(sc => {
      const component = scenariosStore.getMainComponentById(sc.main_component_id)
      const category = scenariosStore.mainComponentCategories.find(
        cat => cat.id === component?.main_component_category_id
      )
      return category?.persist_name === 'panel'
    })

    if (panels.length > 0) {
      const allMonthlyProduction = await Promise.all(
        panels.map(async (panelComponent) => {
          const component = scenariosStore.getMainComponentById(panelComponent.main_component_id)
          if (!component) return []

          const power = component.power || 425
          const efficiency = (component.efficiency || 20.5) / 100
          const quantity = panelComponent.quantity

          return await calculateMonthlySolarProduction(power, quantity, efficiency)
        })
      )

      // Sum up all panels' production for each month
      monthlySolar = allMonthlyProduction[0].map((_, monthIndex) => ({
        month: monthIndex + 1,
        value: allMonthlyProduction.reduce((sum, panelData) =>
          sum + (panelData[monthIndex]?.value || 0), 0
        )
      }))
    }

    // Calculate monthly heat pump consumption
    let monthlyHeatPump: any[] = []
    const heatPumps = scenarioComponents.filter(sc => {
      const component = scenariosStore.getMainComponentById(sc.main_component_id)
      const category = scenariosStore.mainComponentCategories.find(
        cat => cat.id === component?.main_component_category_id
      )
      return category?.persist_name === 'heatpump'
    })

    if (heatPumps.length > 0) {
      const heatPumpComponent = heatPumps[0]
      const component = scenariosStore.getMainComponentById(heatPumpComponent.main_component_id)

      if (component) {
        // Get current heating type and gas consumption from survey
        const { data: answers } = await supabase
          .from('survey_answers')
          .select(`
            answer,
            survey_question:survey_questions(name)
          `)
          .eq('survey_id', props.surveyId)

        const heatingTypeAnswer = answers?.find(
          (a: any) => a.survey_question?.name === 'current_heating_solution'
        )

        const { data: survey } = await supabase
          .from('surveys')
          .select('household_data')
          .eq('id', props.surveyId)
          .single()

        const gasConsumption = survey?.household_data?.consumption
          ? parseFloat(survey.household_data.consumption)
          : 1500

        monthlyHeatPump = await calculateMonthlyHeatPumpElectricity(
          component.power || 14000,
          component.cop || 4.5,
          heatingTypeAnswer?.answer || 'Nyílt égésterű kazán',
          gasConsumption
        )
      }
    }

    // Calculate net electricity (solar - heat pump)
    if (monthlySolar.length > 0 || monthlyHeatPump.length > 0) {
      // Ensure both arrays have 12 months
      if (monthlySolar.length === 0) {
        monthlySolar = Array.from({ length: 12 }, (_, i) => ({ month: i + 1, value: 0 }))
      }
      if (monthlyHeatPump.length === 0) {
        monthlyHeatPump = Array.from({ length: 12 }, (_, i) => ({ month: i + 1, value: 0 }))
      }

      monthlyElectricityData.value = calculateMonthlyElectricityNet(monthlySolar, monthlyHeatPump)
    } else {
      monthlyElectricityData.value = Array.from({ length: 12 }, (_, i) => ({ month: i + 1, value: 0 }))
    }
  } catch (error) {
    console.error('Error calculating monthly electricity breakdown:', error)
  } finally {
    modalLoading.value = false
  }
}

/**
 * Show monthly gas breakdown modal
 */
const showGasBreakdown = async () => {
  if (!currentScenarioId.value) return

  modalLoading.value = true
  showGasModal.value = true

  try {
    const scenarioComponents = scenariosStore.scenarioComponents[currentScenarioId.value] || []

    // Get survey data
    const { data: answers } = await supabase
      .from('survey_answers')
      .select(`
        answer,
        survey_question:survey_questions(name)
      `)
      .eq('survey_id', props.surveyId)

    const heatingTypeAnswer = answers?.find(
      (a: any) => a.survey_question?.name === 'current_heating_solution'
    )
    const wallTypeAnswer = answers?.find((a: any) => a.survey_question?.name === 'wall_type')
    const roofTypeAnswer = answers?.find((a: any) => a.survey_question?.name === 'roof_type')

    let totalMonthlyGas: any[] = Array.from({ length: 12 }, (_, i) => ({ month: i + 1, value: 0 }))

    // Calculate facade insulation savings
    const facadeInsulations = scenarioComponents.filter(sc => {
      const component = scenariosStore.getMainComponentById(sc.main_component_id)
      const category = scenariosStore.mainComponentCategories.find(
        cat => cat.id === component?.main_component_category_id
      )
      return category?.persist_name === 'insulation' && component?.persist_name?.startsWith('fi-')
    })

    for (const insulationComponent of facadeInsulations) {
      const component = scenariosStore.getMainComponentById(insulationComponent.main_component_id)
      if (!component) continue

      const currentUValue = await getCurrentWallUValue(
        wallTypeAnswer?.answer || 'Kis méretű tömör tégla',
        false,
        0
      )
      const newUValue = component.u_value || 0.25
      const area = insulationComponent.quantity

      const monthlySavings = await calculateMonthlyGasSavings(
        currentUValue,
        newUValue,
        area,
        heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
      )

      // Add to total
      monthlySavings.forEach((saving, index) => {
        totalMonthlyGas[index].value += saving.value
      })
    }

    // Calculate roof insulation savings
    const roofInsulations = scenarioComponents.filter(sc => {
      const component = scenariosStore.getMainComponentById(sc.main_component_id)
      const category = scenariosStore.mainComponentCategories.find(
        cat => cat.id === component?.main_component_category_id
      )
      return category?.persist_name === 'insulation' && component?.persist_name?.startsWith('ri-')
    })

    for (const insulationComponent of roofInsulations) {
      const component = scenariosStore.getMainComponentById(insulationComponent.main_component_id)
      if (!component) continue

      const currentUValue = await getCurrentRoofUValue(
        roofTypeAnswer?.answer || 'Sátortető',
        false,
        0
      )
      const newUValue = component.u_value || 0.21
      const area = insulationComponent.quantity

      const monthlySavings = await calculateMonthlyGasSavings(
        currentUValue,
        newUValue,
        area,
        heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
      )

      // Add to total
      monthlySavings.forEach((saving, index) => {
        totalMonthlyGas[index].value += saving.value
      })
    }

    // Calculate window savings
    const windows = scenarioComponents.filter(sc => {
      const component = scenariosStore.getMainComponentById(sc.main_component_id)
      const category = scenariosStore.mainComponentCategories.find(
        cat => cat.id === component?.main_component_category_id
      )
      return category?.persist_name === 'window'
    })

    const windowMaterialAnswer = answers?.find(
      (a: any) => a.survey_question?.name === 'window_material'
    )
    const windowGlazingAnswer = answers?.find(
      (a: any) => a.survey_question?.name === 'window_glazing'
    )

    for (const windowComponent of windows) {
      const component = scenariosStore.getMainComponentById(windowComponent.main_component_id)
      if (!component) continue

      const currentUValue = await getCurrentWindowUValue(
        windowMaterialAnswer?.answer || 'Fa',
        windowGlazingAnswer?.answer || '2 rétegű üvegezésű'
      )
      const newUValue = component.u_value || 0.72
      const area = windowComponent.quantity

      const monthlySavings = await calculateMonthlyGasSavings(
        currentUValue,
        newUValue,
        area,
        heatingTypeAnswer?.answer || 'Nyílt égésterű kazán'
      )

      // Add to total
      monthlySavings.forEach((saving, index) => {
        totalMonthlyGas[index].value += saving.value
      })
    }

    monthlyGasData.value = totalMonthlyGas
  } catch (error) {
    console.error('Error calculating monthly gas breakdown:', error)
  } finally {
    modalLoading.value = false
  }
}

// Watch for scenario changes
watch(currentScenarioId, async () => {
  await calculateImpacts()
})

// Calculate on mount
onMounted(async () => {
  // Load investments if not already loaded
  if (investmentsStore.availableInvestments.length === 0) {
    await investmentsStore.initializeForSurvey(props.surveyId)
  }

  await calculateImpacts()
})
</script>
