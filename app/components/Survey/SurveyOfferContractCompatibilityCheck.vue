<template>
  <div class="space-y-4">
    <!-- Disable Compatibility Check Toggle -->
    <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
      <span class="text-sm font-medium text-gray-900 dark:text-white">
        {{ $t('survey.offerContract.disableCompatibilityCheck') }}
      </span>
      <USwitch
        v-model="disableCheck"
        @update:model-value="handleToggleCheck"
      />
    </div>

    <!-- Compatibility Table -->
    <div v-if="!disableCheck" class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-800">
          <tr>
            <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              <!-- Empty header for row labels -->
            </th>
            <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('survey.offerContract.selectedValues') }}
            </th>
            <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('survey.offerContract.compatibleValues') }}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
          <!-- Panel number -->
          <tr :class="getRowClass('panel_number')">
            <td class="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
              {{ $t('survey.offerContract.panelNumber') }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.panel_number.selected }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.panel_number.compatible }}
            </td>
          </tr>

          <!-- Inverter number -->
          <tr :class="getRowClass('inverter_number')">
            <td class="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
              {{ $t('survey.offerContract.inverterNumber') }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.inverter_number.selected }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.inverter_number.compatible }}
            </td>
          </tr>

          <!-- Install power -->
          <tr :class="getRowClass('install_power')">
            <td class="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
              {{ $t('survey.offerContract.installPower') }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.install_power.selected }} kW
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.install_power.compatible }}
            </td>
          </tr>

          <!-- Inverter kWp -->
          <tr :class="getRowClass('inverter_kwp')">
            <td class="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
              {{ $t('survey.offerContract.inverterKwp') }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.inverter_kwp.selected }} kW
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.inverter_kwp.compatible }}
            </td>
          </tr>

          <!-- Panel kWp -->
          <tr :class="getRowClass('panel_kwp')">
            <td class="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
              {{ $t('survey.offerContract.panelKwp') }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.panel_kwp.selected }} kW
            </td>
            <td class="px-4 py-3 text-sm text-gray-900 dark:text-white">
              {{ calculations.panel_kwp.compatible }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Info message when check is disabled -->
    <div v-else class="p-4 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg">
      <p class="text-sm text-yellow-800 dark:text-yellow-200">
        {{ $t('survey.offerContract.compatibilityDisabledWarning') }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'

interface Props {
  scenarioId: string
}

const props = defineProps<Props>()

const scenariosStore = useScenariosStore()

// Disable check toggle
const disableCheck = ref(false)

// Get scenario components
const scenarioComponents = computed(() => {
  const components = scenariosStore.scenarioComponents[props.scenarioId] || []
  return components
})

// Calculate panel count and power
const panelData = computed(() => {
  let count = 0
  let totalPower = 0

  if (!scenariosStore.mainComponentCategories || scenariosStore.mainComponentCategories.length === 0) {
    return { count, totalPower }
  }

  scenarioComponents.value.forEach(component => {
    const mainComponent = scenariosStore.getMainComponentById(component.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.mainComponentCategories.find(c => c.id === mainComponent.main_component_category_id)
    if (category?.persist_name === 'panel') {
      count += component.quantity || 0
      totalPower += (mainComponent.power || 0) * (component.quantity || 0)
    }
  })

  return { count, totalPower }
})

// Calculate inverter count and power
const inverterData = computed(() => {
  let count = 0
  let totalPower = 0
  let minPanels = 0
  let maxPanels = 999

  if (!scenariosStore.mainComponentCategories || scenariosStore.mainComponentCategories.length === 0) {
    return { count, totalPower, minPanels, maxPanels }
  }

  scenarioComponents.value.forEach(component => {
    const mainComponent = scenariosStore.getMainComponentById(component.main_component_id)
    if (!mainComponent) return

    const category = scenariosStore.mainComponentCategories.find(c => c.id === mainComponent.main_component_category_id)
    if (category?.persist_name === 'inverter') {
      count += component.quantity || 0
      totalPower += (mainComponent.power || 0) * (component.quantity || 0)

      // Get compatibility specs from specifications JSONB
      const specs = mainComponent.specifications as any
      if (specs?.compatibility) {
        minPanels = specs.compatibility.min_panels || 0
        maxPanels = specs.compatibility.max_panels || 999
      }
    }
  })

  return { count, totalPower, minPanels, maxPanels }
})

// Calculations
const calculations = computed(() => {
  const panelCount = panelData.value.count
  const panelPower = panelData.value.totalPower
  const inverterCount = inverterData.value.count
  const inverterPower = inverterData.value.totalPower
  const minPanelsPerInverter = inverterData.value.minPanels
  const maxPanelsPerInverter = inverterData.value.maxPanels

  // Panel kWp (same as install power)
  const panelKwp = panelPower / 1000

  // Inverter kWp
  const inverterKwp = inverterPower / 1000

  return {
    panel_number: {
      selected: panelCount,
      compatible: inverterCount > 0
        ? `${minPanelsPerInverter * inverterCount}-${maxPanelsPerInverter * inverterCount}`
        : 'N/A',
      isCompatible: inverterCount === 0 || (
        panelCount >= minPanelsPerInverter * inverterCount &&
        panelCount <= maxPanelsPerInverter * inverterCount
      )
    },
    inverter_number: {
      selected: inverterCount,
      compatible: panelCount > 0 && maxPanelsPerInverter > 0
        ? `<${Math.ceil(panelCount / minPanelsPerInverter) + 1}`
        : 'N/A',
      isCompatible: inverterCount === 0 || panelCount === 0 || (
        inverterCount >= Math.ceil(panelCount / maxPanelsPerInverter) &&
        inverterCount <= Math.floor(panelCount / minPanelsPerInverter) + 1
      )
    },
    install_power: {
      selected: panelKwp.toFixed(1),
      compatible: inverterCount > 0
        ? `<${(inverterKwp * 1.3).toFixed(1)} kW`
        : 'N/A',
      isCompatible: inverterCount === 0 || panelKwp <= inverterKwp * 1.3
    },
    inverter_kwp: {
      selected: inverterKwp.toFixed(1),
      compatible: panelKwp > 0
        ? `>=${(panelKwp * 0.8).toFixed(1)} kW`
        : 'N/A',
      isCompatible: inverterKwp === 0 || inverterKwp >= panelKwp * 0.8
    },
    panel_kwp: {
      selected: panelKwp.toFixed(1),
      compatible: inverterKwp > 0
        ? `>=${(inverterKwp * 0.77).toFixed(1)} kW`
        : 'N/A',
      isCompatible: panelKwp === 0 || panelKwp >= inverterKwp * 0.77
    }
  }
})

// Get row class based on compatibility
const getRowClass = (key: keyof typeof calculations.value) => {
  const calc = calculations.value[key]
  if (disableCheck.value) return ''

  return calc.isCompatible
    ? 'bg-green-50 dark:bg-green-900/20'
    : 'bg-red-50 dark:bg-red-900/20'
}

// Handle toggle
const handleToggleCheck = (value: boolean) => {
  // Toggle handled
}

// Watch for scenario changes
watch(() => props.scenarioId, () => {
  // Reset disable check when scenario changes
  disableCheck.value = false
})
</script>
