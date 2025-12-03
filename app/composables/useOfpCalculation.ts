import { ref } from 'vue'

interface OfpInvestmentCalculation {
  total_cost_gross: number
  total_cost_net: number
  surface?: number
  capacity_kw?: number
  material_cost?: number
  labor_cost?: number
  price_per_m2?: number
  base_price?: number
  refrigerant?: string
  self_strength: number
  non_refundable: number
  interest_free_loan: number
}

interface OfpTotals {
  total_investment_gross: number
  total_investment_net: number
  total_self_strength: number
  total_non_refundable: number
  total_interest_free_loan: number
}

export interface OfpCalculationResult {
  calculated_at: string
  calculations: {
    wall_insulation?: OfpInvestmentCalculation
    roof_insulation?: OfpInvestmentCalculation
    window_replacement?: OfpInvestmentCalculation
    heat_pump?: OfpInvestmentCalculation
  }
  totals: OfpTotals
  percentage: number
}

export function useOfpCalculation() {
  const supabase = useSupabaseClient()
  const loading = ref(false)
  const error = ref<string | null>(null)
  const result = ref<OfpCalculationResult | null>(null)

  /**
   * Calculate OFP costs for a scenario
   */
  const calculateOfp = async (scenarioId: string, apiKey: string, userEmail: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase.functions.invoke(
        'integrations-ofp-calculate',
        {
          body: { scenarioId },
          headers: {
            'X-API-Key': apiKey,
            'X-User-Email': userEmail,
          },
        }
      )

      if (fetchError) {
        throw new Error(fetchError.message)
      }

      if (!data.success) {
        throw new Error(data.error || 'OFP calculation failed')
      }

      result.value = data.ofpCalculation
      return data.ofpCalculation
    } catch (err: any) {
      error.value = err.message
      console.error('OFP calculation error:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Get stored OFP calculation for a scenario
   */
  const getOfpCalculation = async (scenarioId: string): Promise<OfpCalculationResult | null> => {
    try {
      const { data, error: fetchError } = await supabase
        .from('scenarios')
        .select('ofp_calculation')
        .eq('id', scenarioId)
        .single()

      if (fetchError) {
        throw new Error(fetchError.message)
      }

      result.value = data.ofp_calculation
      return data.ofp_calculation
    } catch (err: any) {
      console.error('Failed to get OFP calculation:', err)
      return null
    }
  }

  /**
   * Format currency for display
   */
  const formatCurrency = (value: number): string => {
    return new Intl.NumberFormat('hu-HU', {
      style: 'currency',
      currency: 'HUF',
      maximumFractionDigits: 0,
    }).format(value)
  }

  /**
   * Format date for display
   */
  const formatDate = (dateString: string): string => {
    return new Intl.DateTimeFormat('hu-HU', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    }).format(new Date(dateString))
  }

  return {
    loading,
    error,
    result,
    calculateOfp,
    getOfpCalculation,
    formatCurrency,
    formatDate,
  }
}
