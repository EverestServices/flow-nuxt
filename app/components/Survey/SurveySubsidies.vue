<template>
  <div class="space-y-3">
    <div
      v-for="(subsidy, index) in subsidies"
      :key="subsidy.id"
      class="border-b border-gray-200 dark:border-gray-700 pb-3"
    >
      <!-- Main subsidy row -->
      <div class="flex items-start justify-between gap-3">
        <!-- Subsidy info -->
        <div class="flex-1">
          <h4 class="text-sm font-medium text-gray-900 dark:text-white mb-1">
            {{ subsidy.name }}
          </h4>
          <p class="text-xs text-gray-600 dark:text-gray-400 mb-1 leading-relaxed">
            {{ subsidy.description }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-500 italic mb-1">
            Célcsoport: {{ subsidy.target_group }}
          </p>
          <p class="text-xs font-medium text-green-600 dark:text-green-400">
            Támogatás: {{ formatDiscount(subsidy) }}
          </p>
        </div>

        <!-- Toggle switch -->
        <div class="flex-shrink-0 pt-1">
          <USwitch
            :model-value="subsidy.is_enabled"
            @update:model-value="(value) => handleToggle(subsidy.id, value)"
          />
        </div>
      </div>

      <!-- Eligibility conditions collapsible -->
      <div
        v-if="getCollapsibleTitle(subsidy.id, index)"
        class="mt-2"
      >
        <button
          type="button"
          class="flex items-center gap-1 text-xs text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 transition-colors"
          @click="toggleConditions(subsidy.id)"
        >
          <UIcon
            :name="expandedSubsidies[subsidy.id] ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
            class="w-3.5 h-3.5"
          />
          <span>{{ getCollapsibleTitle(subsidy.id, index) }}</span>
        </button>

        <!-- Conditions list -->
        <div
          v-if="expandedSubsidies[subsidy.id]"
          class="mt-2 bg-gray-50 dark:bg-gray-800 rounded-lg p-2 space-y-2"
        >
          <div
            v-for="condition in getConditions(subsidy.id, index)"
            :key="condition.key"
            class="flex items-center justify-between gap-2 py-1.5 border-b border-gray-200 dark:border-gray-700 last:border-0"
          >
            <span class="text-xs text-gray-700 dark:text-gray-300 flex-1">
              {{ condition.label }}
            </span>
            <div class="flex-shrink-0">
              <USwitch
                :model-value="eligibilityConditions[condition.key]"
                size="sm"
                @update:model-value="(value) => updateCondition(condition.key, value)"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { SubsidyWithEnabled, EligibilityConditions } from '~/types/subsidy'

interface Props {
  subsidies: SubsidyWithEnabled[]
  eligibilityConditions: EligibilityConditions
}

interface Emits {
  (e: 'toggle', subsidyId: string, isEnabled: boolean): void
  (e: 'update-condition', key: keyof EligibilityConditions, value: boolean): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Track which subsidies have expanded conditions
const expandedSubsidies = ref<Record<string, boolean>>({})

/**
 * Toggle conditions visibility
 */
const toggleConditions = (subsidyId: string) => {
  expandedSubsidies.value[subsidyId] = !expandedSubsidies.value[subsidyId]
}

/**
 * Handle subsidy toggle
 */
const handleToggle = (subsidyId: string, isEnabled: boolean) => {
  emit('toggle', subsidyId, isEnabled)
}

/**
 * Update eligibility condition
 */
const updateCondition = (key: keyof EligibilityConditions, value: boolean) => {
  emit('update-condition', key, value)
}

/**
 * Format discount display
 */
const formatDiscount = (subsidy: SubsidyWithEnabled): string => {
  if (subsidy.discount_type === 'fixed') {
    return new Intl.NumberFormat('hu-HU', {
      style: 'currency',
      currency: 'HUF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(subsidy.discount_value)
  }
  return `${subsidy.discount_value}%`
}

/**
 * Get collapsible title based on subsidy ID and index
 */
const getCollapsibleTitle = (subsidyId: string, index: number): string | null => {
  // Check if subsidy name contains specific keywords to determine which conditions to show
  const subsidy = props.subsidies[index]

  if (subsidy.name.includes('Otthonfelújítási') || subsidy.name.includes('Energetikai Korszerűsítési')) {
    return 'Pályázati feltételek: Energetikai Otthonfelújítási Program'
  } else if (subsidy.name.includes('Napelem') && index === 1) {
    return 'Pályázati feltételek: Vidéki Otthonfelújítási Program'
  } else if (subsidy.name.includes('Napelem') && index === 2) {
    return 'Pályázati feltételek: Napelem & energetikai csomagok'
  }

  return null
}

/**
 * Get conditions based on subsidy ID and index
 */
const getConditions = (subsidyId: string, index: number): Array<{ key: keyof EligibilityConditions; label: string }> => {
  const subsidy = props.subsidies[index]

  if (!subsidy) return []

  if (subsidy.name.includes('Otthonfelújítási') || subsidy.name.includes('Energetikai Korszerűsítési')) {
    return [
      { key: 'builtBefore2007' as const, label: '2007. január 1. előtt épült ingatlan' },
      { key: 'notSmallSettlement' as const, label: '5000 főnél nagyobb település' },
      { key: 'hungarianCitizen' as const, label: 'Magyar állampolgár / min. 1 éve bejelentett lakcím' },
      { key: 'ownershipMinimum50Percent' as const, label: 'Legalább 50% tulajdonjog/haszonélvezeti jog' },
      { key: 'energyImprovement30Percent' as const, label: 'Minimum 30%-os primerenergia-megtakarítás' },
      { key: 'minSelfFunding' as const, label: 'Legalább 1M Ft (~14%) önerő' }
    ]
  } else if (subsidy.name.includes('Napelem') && index === 1) {
    return [
      { key: 'smallSettlement' as const, label: '5000 fő alatti településen található ingatlan' },
      { key: 'hungarianCitizen' as const, label: 'Magyar állampolgár, bejelentett lakcím' },
      { key: 'energyImprovement30Percent' as const, label: 'Minimum 30%-os primerenergia-megtakarítás' },
      { key: 'notSmallSettlement' as const, label: 'KEHOP Plusz támogatást nem igényelt erre az ingatlanra' }
    ]
  } else if (subsidy.name.includes('Napelem') && index === 2) {
    return [
      { key: 'hasEnergyAudit' as const, label: 'Rendelkezik energetikai tanúsítvánnyal' },
      { key: 'energyImprovement30Percent' as const, label: 'Kombinált támogatást igényel (pl. nyílászárócsere + napelem)' }
    ]
  }

  return []
}
</script>
