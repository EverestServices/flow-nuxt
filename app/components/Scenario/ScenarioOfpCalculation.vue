<script setup lang="ts">
import type { OfpCalculationResult } from '~/composables/useOfpCalculation'

const props = defineProps<{
  scenarioId: string
  ofpCalculation?: OfpCalculationResult | null
}>()

const emit = defineEmits<{
  (e: 'calculate'): void
  (e: 'refresh'): void
}>()

const { formatCurrency, formatDate } = useOfpCalculation()

const hasCalculation = computed(() => !!props.ofpCalculation)

const investmentLabels: Record<string, string> = {
  wall_insulation: 'Homlokzati szigetelés',
  roof_insulation: 'Tetőszigetelés',
  window_replacement: 'Nyílászáró csere',
  heat_pump: 'Hőszivattyú',
}

const calculations = computed(() => {
  if (!props.ofpCalculation?.calculations) return []

  return Object.entries(props.ofpCalculation.calculations).map(([key, value]) => ({
    key,
    label: investmentLabels[key] || key,
    ...value,
  }))
})
</script>

<template>
  <UCard>
    <template #header>
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold">OFP Kalkuláció</h3>
        <div class="flex items-center gap-2">
          <UButton
            v-if="hasCalculation"
            variant="ghost"
            size="sm"
            icon="i-heroicons-arrow-path"
            @click="emit('calculate')"
          >
            Újraszámolás
          </UButton>
          <UButton
            v-else
            color="primary"
            size="sm"
            icon="i-heroicons-calculator"
            @click="emit('calculate')"
          >
            Kalkulálás
          </UButton>
        </div>
      </div>
    </template>

    <div v-if="hasCalculation" class="space-y-6">
      <!-- Summary -->
      <div class="grid grid-cols-2 gap-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Teljes beruházás (bruttó)</p>
          <p class="text-xl font-bold">
            {{ formatCurrency(ofpCalculation!.totals.total_investment_gross) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Önerő ({{ (ofpCalculation!.percentage * 0.143).toFixed(1) }}%)</p>
          <p class="text-xl font-bold text-orange-600 dark:text-orange-400">
            {{ formatCurrency(ofpCalculation!.totals.total_self_strength) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Vissza nem térítendő ({{ ofpCalculation!.percentage }}%)</p>
          <p class="text-xl font-bold text-green-600 dark:text-green-400">
            {{ formatCurrency(ofpCalculation!.totals.total_non_refundable) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-500 dark:text-gray-400">Kamatmentes kölcsön</p>
          <p class="text-xl font-bold text-blue-600 dark:text-blue-400">
            {{ formatCurrency(ofpCalculation!.totals.total_interest_free_loan) }}
          </p>
        </div>
      </div>

      <!-- Per-investment breakdown -->
      <div class="space-y-4">
        <h4 class="font-medium text-gray-700 dark:text-gray-300">Beruházások részletezése</h4>

        <div
          v-for="calc in calculations"
          :key="calc.key"
          class="border rounded-lg p-4 dark:border-gray-700"
        >
          <div class="flex justify-between items-center mb-2">
            <h5 class="font-medium">{{ calc.label }}</h5>
            <span class="text-lg font-semibold">
              {{ formatCurrency(calc.total_cost_gross) }}
            </span>
          </div>

          <div class="grid grid-cols-3 gap-2 text-sm">
            <div v-if="calc.surface">
              <span class="text-gray-500 dark:text-gray-400">Felület:</span>
              <span class="ml-1">{{ calc.surface }} m²</span>
            </div>
            <div v-if="calc.capacity_kw">
              <span class="text-gray-500 dark:text-gray-400">Kapacitás:</span>
              <span class="ml-1">{{ calc.capacity_kw }} kW</span>
            </div>
            <div v-if="calc.price_per_m2">
              <span class="text-gray-500 dark:text-gray-400">Ft/m²:</span>
              <span class="ml-1">{{ formatCurrency(calc.price_per_m2) }}</span>
            </div>
            <div>
              <span class="text-gray-500 dark:text-gray-400">Önerő:</span>
              <span class="ml-1">{{ formatCurrency(calc.self_strength) }}</span>
            </div>
            <div>
              <span class="text-gray-500 dark:text-gray-400">Támogatás:</span>
              <span class="ml-1 text-green-600 dark:text-green-400">{{ formatCurrency(calc.non_refundable) }}</span>
            </div>
            <div>
              <span class="text-gray-500 dark:text-gray-400">Kölcsön:</span>
              <span class="ml-1 text-blue-600 dark:text-blue-400">{{ formatCurrency(calc.interest_free_loan) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Timestamp -->
      <div class="text-xs text-gray-400 text-right">
        Utolsó számítás: {{ formatDate(ofpCalculation!.calculated_at) }}
      </div>
    </div>

    <div v-else class="text-center py-8 text-gray-500 dark:text-gray-400">
      <UIcon name="i-heroicons-calculator" class="w-12 h-12 mx-auto mb-4 opacity-50" />
      <p>Még nincs OFP kalkuláció ehhez a scenario-hoz.</p>
      <p class="text-sm mt-1">Kattints a "Kalkulálás" gombra a számításhoz.</p>
    </div>
  </UCard>
</template>
