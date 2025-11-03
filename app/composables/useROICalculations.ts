/**
 * ROI (Return on Investment) Calculations Composable
 *
 * Calculates return on investment metrics including:
 * - Energy efficiency improvement percentage
 * - Current and projected energy costs
 * - Payback period
 * - Long-term savings with inflation
 */

import { useEnergySavings } from './useEnergySavings'

export interface ROIData {
  // Investment
  totalInvestmentCost: number // HUF

  // Energy efficiency
  energyEfficiencyImprovement: number // 0-1 (percentage as decimal)

  // Current state
  currentAnnualElectricityCost: number // HUF/year
  currentAnnualGasCost: number // HUF/year
  currentAnnualTotalCost: number // HUF/year

  // Savings
  annualSavings: number // HUF/year
  monthlySavings: number // HUF/month

  // ROI metrics
  returnTime: number // years
  savings10Year: number // HUF (with inflation)
  savings20Year: number // HUF (with inflation)
}

export const useROICalculations = () => {
  const supabase = useSupabaseClient()
  const { loadSettings } = useEnergySavings()

  /**
   * Calculate total investment cost for a scenario
   */
  const calculateTotalInvestmentCost = async (scenarioId: string): Promise<number> => {
    const { data, error } = await supabase
      .from('scenario_main_components')
      .select('quantity, price_snapshot')
      .eq('scenario_id', scenarioId)

    if (error) throw error

    const componentsCost = data?.reduce((sum, item) => {
      return sum + (item.quantity * item.price_snapshot)
    }, 0) || 0

    // Also add extra costs
    const { data: extraCosts, error: extraError } = await supabase
      .from('extra_cost_relations')
      .select('snapshot_price, quantity')
      .eq('scenario_id', scenarioId)

    if (extraError) throw extraError

    const extraCostTotal = extraCosts?.reduce((sum, item) => {
      return sum + ((item.snapshot_price || 0) * (item.quantity || 1))
    }, 0) || 0

    return componentsCost + extraCostTotal
  }

  /**
   * Calculate energy efficiency improvement percentage
   * Based on selected investments using compound logic:
   * - First investment adds its percentage
   * - Subsequent investments add percentage of remaining efficiency
   */
  const calculateEnergyEfficiencyImprovement = async (
    surveyId: string,
    scenarioId?: string
  ): Promise<number> => {
    // Get investments for the scenario or survey
    let query = supabase
      .from(scenarioId ? 'scenario_investments' : 'survey_investments')
      .select('investment:investments(energy_efficiency_improvement)')

    if (scenarioId) {
      query = query.eq('scenario_id', scenarioId)
    } else {
      query = query.eq('survey_id', surveyId)
    }

    const { data, error } = await query

    if (error) throw error

    const improvements = data
      ?.map((item: any) => item.investment?.energy_efficiency_improvement || 0)
      .filter(val => val > 0)
      .sort((a, b) => b - a) // Sort descending to apply highest first

    if (!improvements || improvements.length === 0) return 0

    // Apply compound logic
    let totalImprovement = 0
    let remaining = 1.0

    for (const improvement of improvements) {
      totalImprovement += remaining * improvement
      remaining *= (1 - improvement)
    }

    return totalImprovement
  }

  /**
   * Get current annual electricity consumption from survey answers
   * Note: annual_electricity_consumption question was removed from Basic Data
   * This function now primarily uses household_data or falls back to default
   */
  const getCurrentElectricityConsumption = async (surveyId: string): Promise<number> => {
    // Try to get from household_data first
    const { data: survey } = await supabase
      .from('surveys')
      .select('household_data')
      .eq('id', surveyId)
      .single()

    if (survey?.household_data?.consumption &&
        survey.household_data.consumptionUnit === 'kW') {
      const consumption = parseFloat(survey.household_data.consumption)
      const isAnnual = survey.household_data.consumptionPeriod === 'év'
      return isAnnual ? consumption : consumption * 12
    }

    // Otherwise get from survey answers (fallback for legacy data)
    const { data: answers } = await supabase
      .from('survey_answers')
      .select(`
        answer,
        survey_question:survey_questions(name)
      `)
      .eq('survey_id', surveyId)

    const electricityAnswer = answers?.find(
      (a: any) => a.survey_question?.name === 'annual_electricity_consumption' ||
                  a.survey_question?.name === 'annual_consumption'
    )

    if (electricityAnswer?.answer) {
      return parseFloat(electricityAnswer.answer)
    }

    // Default to Hungarian average household consumption
    return 3500 // kWh/year
  }

  /**
   * Get current annual gas consumption from survey answers
   * Note: annual_gas_consumption question was removed from Basic Data
   * This function now primarily falls back to default or could use household_data if implemented
   */
  const getCurrentGasConsumption = async (surveyId: string): Promise<number> => {
    const { data: survey } = await supabase
      .from('surveys')
      .select('household_data')
      .eq('id', surveyId)
      .single()

    // Check if consumption is in m³ (gas) - this would need additional field
    // For now, get from survey answers (fallback for legacy data)
    const { data: answers } = await supabase
      .from('survey_answers')
      .select(`
        answer,
        survey_question:survey_questions(name)
      `)
      .eq('survey_id', surveyId)

    const gasAnswer = answers?.find(
      (a: any) => a.survey_question?.name === 'annual_gas_consumption'
    )

    if (gasAnswer?.answer) {
      return parseFloat(gasAnswer.answer)
    }

    // Default to Hungarian average household gas consumption
    return 1500 // m³/year
  }

  /**
   * Calculate full ROI data for a scenario
   */
  const calculateROI = async (
    surveyId: string,
    scenarioId: string,
    inflationRate: number = 0.02 // 2% default
  ): Promise<ROIData> => {
    const settings = await loadSettings()

    // Get investment cost
    const totalInvestmentCost = await calculateTotalInvestmentCost(scenarioId)

    // Get energy efficiency improvement
    const energyEfficiencyImprovement = await calculateEnergyEfficiencyImprovement(
      surveyId,
      scenarioId
    )

    // Get current consumption
    const currentElectricityKwh = await getCurrentElectricityConsumption(surveyId)
    const currentGasM3 = await getCurrentGasConsumption(surveyId)

    // Calculate current annual costs
    const currentAnnualElectricityCost = currentElectricityKwh * settings.electricityPrice
    const currentAnnualGasCost = currentGasM3 * settings.gasPrice
    const currentAnnualTotalCost = currentAnnualElectricityCost + currentAnnualGasCost

    // Calculate savings
    const annualSavings = currentAnnualTotalCost * energyEfficiencyImprovement
    const monthlySavings = annualSavings / 12

    // Calculate return time (payback period)
    const returnTime = annualSavings > 0 ? totalInvestmentCost / annualSavings : 0

    // Calculate long-term savings with compound inflation
    const savings10Year = calculateCompoundSavings(annualSavings, 10, inflationRate)
    const savings20Year = calculateCompoundSavings(annualSavings, 20, inflationRate)

    return {
      totalInvestmentCost,
      energyEfficiencyImprovement,
      currentAnnualElectricityCost,
      currentAnnualGasCost,
      currentAnnualTotalCost,
      annualSavings,
      monthlySavings,
      returnTime,
      savings10Year,
      savings20Year
    }
  }

  /**
   * Calculate compound savings over time with inflation
   */
  const calculateCompoundSavings = (
    annualSavings: number,
    years: number,
    inflationRate: number
  ): number => {
    let totalSavings = 0

    for (let year = 1; year <= years; year++) {
      // Each year's savings adjusted for inflation
      const yearSavings = annualSavings * Math.pow(1 + inflationRate, year - 1)
      totalSavings += yearSavings
    }

    return totalSavings
  }

  /**
   * Format currency (HUF)
   */
  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('hu-HU', {
      style: 'currency',
      currency: 'HUF',
      maximumFractionDigits: 0
    }).format(Math.round(amount))
  }

  /**
   * Format percentage
   */
  const formatPercentage = (value: number): string => {
    return `${Math.round(value * 100)}%`
  }

  /**
   * Format years
   */
  const formatYears = (years: number): string => {
    if (years === 0) return 'N/A'
    if (years < 1) return `${Math.round(years * 12)} months`
    return `${years.toFixed(1)} years`
  }

  return {
    calculateTotalInvestmentCost,
    calculateEnergyEfficiencyImprovement,
    getCurrentElectricityConsumption,
    getCurrentGasConsumption,
    calculateROI,
    calculateCompoundSavings,
    formatCurrency,
    formatPercentage,
    formatYears
  }
}
