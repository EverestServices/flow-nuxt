/**
 * Energy Calculations Composable
 *
 * Handles GJ/kWh energy savings calculations for investments.
 * Calls the calculate-energy-savings Edge Function to get detailed energy savings data.
 */

import { ref } from 'vue'

export interface EnergySavingsPerInvestment {
  annualHeatingSavingsGJ: number
  annualHeatingSavingsKWh: number
  savingsPercentage: number
  actualArea?: number
  capacity?: number
}

export interface KEHOPSummary {
  totalGJ: number
  totalKWh: number
  totalPercentage: number
  meets30Percent: boolean
}

export interface EnergySavingsResult {
  perInvestment: {
    [key: string]: EnergySavingsPerInvestment
  }
  kehopSummary: KEHOPSummary
  theoreticalTotalHeatingEnergyGJ: number
  calculatedAt: string
  usedConsultantMode: boolean // true = used energy_consumption_table (CORRECT), false = used architectural (NOT RECOMMENDED)
  warnings?: string[] // Array of warning messages if calculation is unreliable
}

export function useEnergyCalculations() {
  const supabase = useSupabaseClient()
  const loading = ref(false)
  const error = ref<string | null>(null)
  const result = ref<EnergySavingsResult | null>(null)

  /**
   * Calculate energy savings for a scenario
   * Calls the Edge Function to calculate GJ/kWh savings
   */
  const calculateEnergySavings = async (surveyId: string, scenarioId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase.functions.invoke(
        'calculate-energy-savings',
        {
          body: { surveyId, scenarioId },
        }
      )

      if (fetchError) {
        throw new Error(fetchError.message)
      }

      if (!data.success) {
        throw new Error(data.error || 'Energy savings calculation failed')
      }

      result.value = data.energySavings
      return data.energySavings
    } catch (err: any) {
      error.value = err.message
      console.error('Energy savings calculation error:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Get stored energy savings for a scenario
   */
  const getEnergySavings = async (scenarioId: string): Promise<EnergySavingsResult | null> => {
    try {
      const { data, error: fetchError } = await supabase
        .from('scenarios')
        .select('energy_savings')
        .eq('id', scenarioId)
        .single()

      if (fetchError) {
        throw new Error(fetchError.message)
      }

      result.value = data.energy_savings
      return data.energy_savings
    } catch (err: any) {
      console.error('Failed to get energy savings:', err)
      return null
    }
  }

  /**
   * Format GJ value for display
   */
  const formatGJ = (value: number): string => {
    return `${value.toFixed(3)} GJ`
  }

  /**
   * Format kWh value for display (with thousands separator)
   */
  const formatKWh = (value: number): string => {
    return new Intl.NumberFormat('hu-HU').format(Math.round(value)) + ' kWh'
  }

  /**
   * Format percentage for display
   */
  const formatPercentage = (value: number): string => {
    return `${value.toFixed(1)}%`
  }

  /**
   * Get investment label by key
   */
  const getInvestmentLabel = (key: string): string => {
    const labels: Record<string, string> = {
      facadeInsulation: 'Homlokzati szigetelés',
      roofInsulation: 'Tetőszigetelés',
      windows: 'Nyílászáró csere',
      heatPump: 'Hőszivattyú',
    }
    return labels[key] || key
  }

  /**
   * Get investment icon by key
   */
  const getInvestmentIcon = (key: string): string => {
    const icons: Record<string, string> = {
      facadeInsulation: 'i-lucide-home',
      roofInsulation: 'i-lucide-layers',
      windows: 'i-lucide-door-open',
      heatPump: 'i-lucide-wind',
    }
    return icons[key] || 'i-lucide-package'
  }

  /**
   * Get missing data message for investment
   */
  const getMissingDataMessage = (key: string): string => {
    const messages: Record<string, string> = {
      facadeInsulation: 'A számításhoz adjon meg adatokat a \'Rendszer tervezés\' → \'Homlokzati rendszer\' → \'Homlokzati szigetelés rendszer\' terméknél. Adja meg a szigetelendő felületet (m²).',
      roofInsulation: 'A számításhoz adjon meg adatokat a \'Rendszer tervezés\' → \'Tetőszigetelő rendszer\' terméknél. Adja meg a szigetelendő felületet (m²).',
      windows: 'A számításhoz adjon meg adatokat a \'Felmérő\' oldalon. Rögzítse a nyílászárókat és azok felületét (m²).',
      heatPump: 'A számításhoz válasszon ki egy hőszivattyú terméket a \'Rendszer tervezés\' → \'Hőszivattyú\' szekcióban.',
    }
    return messages[key] || 'Nincs elérhető adat ehhez a beruházáshoz.'
  }

  return {
    loading,
    error,
    result,
    calculateEnergySavings,
    getEnergySavings,
    formatGJ,
    formatKWh,
    formatPercentage,
    getInvestmentLabel,
    getInvestmentIcon,
    getMissingDataMessage,
  }
}
