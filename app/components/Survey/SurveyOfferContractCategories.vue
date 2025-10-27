<template>
  <div class="space-y-4">
    <!-- Category Container -->
    <div
      v-for="category in categories"
      :key="category.id"
      class="border border-gray-200 dark:border-gray-700 rounded-lg p-3"
    >
      <!-- Category Header -->
      <div class="flex items-center justify-between mb-3">
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-gray-900 dark:text-white">
            {{ getCategoryDisplayName(category.persist_name) }}
          </span>
          <UButton
            icon="i-lucide-info"
            color="gray"
            variant="ghost"
            size="xs"
            @click="showCategoryInfo(category)"
          />
        </div>
        <UButton
          v-if="!readOnly"
          icon="i-lucide-plus"
          color="primary"
          variant="outline"
          size="xs"
          :loading="loadingCategories[category.id]"
          :disabled="loadingCategories[category.id]"
          @click="handleAddRow(category.id)"
        >
          Add Component
        </UButton>
      </div>

      <!-- Component Rows -->
      <div class="space-y-2">
        <div
          v-for="scenarioComponent in getCategoryComponents(category.id)"
          :key="scenarioComponent.id"
          class="flex items-center gap-2"
        >
          <!-- Component Dropdown -->
          <UISelect
            :model-value="scenarioComponent.main_component_id"
            :options="getComponentOptions(category.id)"
            :disabled="readOnly"
            class="flex-1"
            size="sm"
            @update:model-value="(value) => handleComponentChange(scenarioComponent.id, value)"
          />

          <!-- Quantity Input -->
          <UInput
            :model-value="scenarioComponent.quantity"
            :disabled="readOnly"
            type="number"
            min="1"
            size="sm"
            class="w-24"
            @update:model-value="(value) => handleQuantityChange(scenarioComponent.id, Number(value))"
          />

          <!-- Delete Button -->
          <UButton
            v-if="!readOnly"
            icon="i-lucide-trash-2"
            color="red"
            variant="ghost"
            size="sm"
            @click="handleDeleteRow(scenarioComponent.id)"
          />
        </div>

        <!-- Empty state -->
        <p
          v-if="getCategoryComponents(category.id).length === 0"
          class="text-sm text-gray-500 dark:text-gray-400 text-center py-2"
        >
          No components added. Click "Add Component" to add components.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useScenariosStore } from '~/stores/scenarios'

interface Props {
  scenarioId: string
  investmentId: string
  readOnly?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  readOnly: true  // Default to read-only since this is used on Offer/Contract page
})

const scenariosStore = useScenariosStore()

// Loading states for each category
const loadingCategories = ref<Record<string, boolean>>({})

// Get categories for this investment
const categories = computed(() => {
  return scenariosStore.getCategoriesForInvestment(props.investmentId)
})

// Get scenario components for a category (filtered by investment)
const getCategoryComponents = (categoryId: string) => {
  return scenariosStore.getScenarioComponentForCategory(categoryId, props.scenarioId, props.investmentId)
}

// Get available components for a category
const getComponentOptions = (categoryId: string) => {
  const components = scenariosStore.getComponentsByCategoryId(categoryId)
  // Transform to format USelect expects: array of objects with value and label
  return components.map(c => ({
    value: c.id,
    label: c.name
  }))
}

// Get component name by ID
const getComponentName = (componentId: string) => {
  const component = scenariosStore.getMainComponentById(componentId)
  return component?.name || 'Select component'
}

// Get display name for category
const getCategoryDisplayName = (persistName: string): string => {
  const nameMap: Record<string, string> = {
    'panel': 'Solar Panels',
    'inverter': 'Inverter',
    'mounting': 'Mounting System',
    'regulator': 'Charge Regulator',
    'ac_surge_protector': 'AC Surge Protector',
    'dc_surge_protector': 'DC Surge Protector',
    'optimizer': 'Power Optimizer',
    'rapid_shutdown': 'Rapid Shutdown',
    'battery': 'Battery',
    'heatpump': 'Heat Pump',
    'accessory': 'Accessories',
    'insulation': 'Insulation',
    'adhesive': 'Adhesive',
    'plaster': 'Plaster',
    'vapor_barrier': 'Vapor Barrier',
    'window': 'Windows',
    'airconditioner': 'Air Conditioner',
    'charger': 'EV Charger'
  }
  return nameMap[persistName] || persistName
}

// Show category info
const showCategoryInfo = (category: any) => {
  // TODO: Implement info modal
  console.log('Show info for category:', category)
}

// Add new row
const handleAddRow = async (categoryId: string) => {
  // Prevent duplicate requests
  if (loadingCategories.value[categoryId]) {
    return
  }

  try {
    loadingCategories.value[categoryId] = true

    // Get all available components for this category
    const components = getComponentOptions(categoryId)
    if (components.length === 0) {
      console.warn('No components available for this category')
      return
    }

    // Get already added components for this category
    const existingComponents = getCategoryComponents(categoryId)
    const existingComponentIds = existingComponents.map(c => c.main_component_id)

    // Find first component that hasn't been added yet
    const availableComponent = components.find(c => !existingComponentIds.includes(c.value))

    if (!availableComponent) {
      console.warn('All components from this category have already been added')
      // TODO: Show info toast to user
      return
    }

    // TODO: In the future, this should add to contract_components instead of scenario_main_components
    await scenariosStore.addScenarioComponent(availableComponent.value, 1, props.investmentId, props.scenarioId)
  } catch (error) {
    console.error('Error adding component:', error)
    // TODO: Show error toast
  } finally {
    loadingCategories.value[categoryId] = false
  }
}

// Handle component change
const handleComponentChange = async (scenarioComponentId: string, newComponentId: string) => {
  try {
    // TODO: In the future, this should update contract_components instead of scenario_main_components
    await scenariosStore.updateScenarioComponent(scenarioComponentId, newComponentId, undefined, props.scenarioId)
  } catch (error) {
    console.error('Error changing component:', error)
    // TODO: Show error toast
  }
}

// Handle quantity change
const handleQuantityChange = async (componentId: string, quantity: number) => {
  if (quantity < 1) return

  try {
    // TODO: In the future, this should update contract_components instead of scenario_main_components
    await scenariosStore.updateComponentQuantity(componentId, quantity, props.scenarioId)
  } catch (error) {
    console.error('Error updating quantity:', error)
    // TODO: Show error toast
  }
}

// Delete row
const handleDeleteRow = async (componentId: string) => {
  try {
    // TODO: In the future, this should delete from contract_components instead of scenario_main_components
    await scenariosStore.removeScenarioComponent(componentId, props.scenarioId)
  } catch (error) {
    console.error('Error deleting component:', error)
    // TODO: Show error toast
  }
}
</script>
