/**
 * Energy Savings Calculations Composable
 *
 * This composable provides methods to calculate energy savings, costs, and CO₂ reductions
 * for different investment types (Solar, Heat Pump, Insulation, Windows).
 */

import type { SurveySetting, SurveySettings } from '~/types/surveySetting'
import { SETTING_KEY_MAP } from '~/types/surveySetting'

export interface EnergySavings {
  // Energy impact by type
  electricityImpact: number // kWh/year (positive = production, negative = consumption)
  naturalGasImpact: number // m³/year (positive = savings, negative = increase)

  // CO₂ reduction
  co2Reduction: number // kg CO₂/year

  // Investment breakdown (for display)
  investmentDetails: InvestmentDetail[]
}

export interface InvestmentDetail {
  investmentName: string
  electricityImpact?: number // kWh/year
  gasImpact?: number // m³/year
}

export interface MonthlyClimateData {
  month: number // 1-12
  solar_irradiance: number // kWh/m²/month
  heating_degree_days: number // degree days/month
}

export interface MonthlyBreakdown {
  month: number
  value: number
}

export const useEnergySavings = () => {
  const supabase = useSupabaseClient()

  // Cache for survey settings
  const settings = ref<SurveySettings | null>(null)

  /**
   * Load survey settings from database
   */
  const loadSettings = async (): Promise<SurveySettings> => {
    if (settings.value) return settings.value

    const { data, error } = await supabase
      .from('survey_settings')
      .select('*')

    if (error) throw error

    // Parse settings into typed object
    const parsedSettings: Partial<SurveySettings> = {}

    data.forEach((setting: SurveySetting) => {
      const key = SETTING_KEY_MAP[setting.persist_name]
      if (key) {
        parsedSettings[key] = parseFloat(setting.value)
      }
    })

    settings.value = parsedSettings as SurveySettings
    return settings.value
  }

  /**
   * Calculate solar panel energy production
   *
   * Formula: Annual Production (kWh) = Panel Power (kW) × Panel Count ×
   *          Annual Irradiance (kWh/m²/year) × Performance Ratio
   *
   * @param panelPowerW - Power per panel in Watts
   * @param panelCount - Number of panels
   * @param efficiency - Panel efficiency (decimal, e.g., 0.205 for 20.5%)
   * @returns Annual electricity production in kWh
   */
  const calculateSolarProduction = async (
    panelPowerW: number,
    panelCount: number,
    efficiency: number
  ): Promise<number> => {
    const config = await loadSettings()

    const panelPowerKW = panelPowerW / 1000
    const totalPowerKW = panelPowerKW * panelCount

    // Annual production = Power × Irradiance × Performance Ratio
    const annualProduction =
      totalPowerKW *
      config.solarIrradianceAnnual *
      config.solarPerformanceRatio

    return Math.round(annualProduction)
  }

  /**
   * Calculate heat pump energy impact
   *
   * Calculates both gas savings and electricity increase when replacing
   * a gas-based heating system with a heat pump.
   *
   * @param heatPumpPowerW - Heat pump power in Watts
   * @param currentHeatingType - Current heating system type
   * @param annualGasConsumptionM3 - Current annual gas consumption in m³
   * @returns Gas savings (m³) and electricity increase (kWh)
   */
  const calculateHeatPumpImpact = async (
    heatPumpPowerW: number,
    heatPumpCOP: number,
    currentHeatingType: string,
    annualGasConsumptionM3?: number
  ): Promise<{ gasSavings: number; electricityIncrease: number }> => {
    const config = await loadSettings()

    // Get current heating system efficiency
    let currentEfficiency = config.heatingEfficiencyDefault
    switch (currentHeatingType.toLowerCase()) {
      case 'nyílt égésterű kazán':
        currentEfficiency = config.heatingEfficiencyOpenFlue
        break
      case 'kondenzációs kazán':
        currentEfficiency = config.heatingEfficiencyCondensing
        break
      case 'konvektor':
        currentEfficiency = config.heatingEfficiencyConvector
        break
      case 'vegyestüzelésű kazán':
        currentEfficiency = config.heatingEfficiencyMixedFuel
        break
    }

    // If no gas consumption provided, assume no impact
    if (!annualGasConsumptionM3) {
      return { gasSavings: 0, electricityIncrease: 0 }
    }

    // Calculate heat demand from current gas consumption
    // Heat demand (kWh) = Gas consumption (m³) × Energy content (kWh/m³) × Efficiency
    const heatDemandKWh =
      annualGasConsumptionM3 *
      config.gasEnergyConversion *
      currentEfficiency

    // Calculate heat pump electricity consumption
    // Electricity (kWh) = Heat demand (kWh) / COP
    const heatPumpElectricityKWh = heatDemandKWh / heatPumpCOP

    return {
      gasSavings: Math.round(annualGasConsumptionM3),
      electricityIncrease: Math.round(heatPumpElectricityKWh)
    }
  }

  /**
   * Calculate insulation energy savings
   *
   * Formula: Annual Savings (kWh) = (U_old - U_new) × Area (m²) ×
   *          Heating Degree Days × 24 hours / 1000
   *
   * @param currentUValue - Current U-value W/m²K
   * @param newUValue - New U-value after insulation W/m²K
   * @param areaM2 - Insulated area in m²
   * @returns Annual gas savings in m³
   */
  const calculateInsulationSavings = async (
    currentUValue: number,
    newUValue: number,
    areaM2: number,
    currentHeatingType: string
  ): Promise<number> => {
    const config = await loadSettings()

    // Get current heating efficiency
    let currentEfficiency = config.heatingEfficiencyDefault
    switch (currentHeatingType.toLowerCase()) {
      case 'nyílt égésterű kazán':
        currentEfficiency = config.heatingEfficiencyOpenFlue
        break
      case 'kondenzációs kazán':
        currentEfficiency = config.heatingEfficiencyCondensing
        break
      case 'konvektor':
        currentEfficiency = config.heatingEfficiencyConvector
        break
      case 'vegyestüzelésű kazán':
        currentEfficiency = config.heatingEfficiencyMixedFuel
        break
    }

    // Calculate annual heat loss reduction (kWh)
    const heatLossReductionKWh =
      (currentUValue - newUValue) *
      areaM2 *
      config.heatingDegreeDays *
      24 /
      1000

    // Convert to gas savings (m³)
    const gasSavingsM3 =
      heatLossReductionKWh /
      config.gasEnergyConversion /
      currentEfficiency

    return Math.round(gasSavingsM3)
  }

  /**
   * Get current wall U-value based on wall type and existing insulation
   *
   * @param wallType - Type of wall construction
   * @param hasInsulation - Whether wall already has insulation
   * @param insulationThickness - Existing insulation thickness in cm
   * @returns Current U-value in W/m²K
   */
  const getCurrentWallUValue = async (
    wallType: string,
    hasInsulation: boolean = false,
    insulationThickness: number = 0
  ): Promise<number> => {
    const config = await loadSettings()

    // Get base U-value for wall type
    let baseUValue = 1.6 // default

    switch (wallType.toLowerCase()) {
      case 'kis méretű tömör tégla':
        baseUValue = config.uValueWallSmallBrick
        break
      case 'mészhomok tégla':
        baseUValue = config.uValueWallLimeSand
        break
      case 'b30 tégla':
        baseUValue = config.uValueWallB30
        break
      case 'poroton':
        baseUValue = config.uValueWallPoroton
        break
      case 'gázsilikát':
        baseUValue = config.uValueWallGasSilicate
        break
      case 'bautherm':
        baseUValue = config.uValueWallBautherm
        break
      case 'porotherm n+f':
        baseUValue = config.uValueWallPorotherm
        break
      case 'ytong':
        baseUValue = config.uValueWallYtong
        break
      case 'vasbeton panel':
        baseUValue = config.uValueWallConcretePanel
        break
      case 'vályog':
        baseUValue = config.uValueWallWattle
        break
      case 'könnyűszerkezetes':
        baseUValue = config.uValueWallLightweight
        break
    }

    // If there's existing insulation, calculate combined U-value
    if (hasInsulation && insulationThickness > 0) {
      // R = 1/U, total R = R_wall + R_insulation
      const rWall = 1 / baseUValue
      const rInsulation = insulationThickness / 100 / 0.037 // assume λ = 0.037 W/mK
      const totalR = rWall + rInsulation
      return 1 / totalR
    }

    return baseUValue
  }

  /**
   * Get current roof U-value based on roof type and existing insulation
   */
  const getCurrentRoofUValue = async (
    roofType: string,
    hasInsulation: boolean = false,
    insulationThickness: number = 0
  ): Promise<number> => {
    const config = await loadSettings()

    let baseUValue =
      roofType.toLowerCase() === 'lapostető'
        ? config.uValueRoofUninsulatedFlat
        : config.uValueRoofUninsulatedHipped

    // If there's existing insulation, calculate combined U-value
    if (hasInsulation && insulationThickness > 0) {
      const rRoof = 1 / baseUValue
      const rInsulation = insulationThickness / 100 / 0.037
      const totalR = rRoof + rInsulation
      return 1 / totalR
    }

    return baseUValue
  }

  /**
   * Get current window U-value based on material and glazing type
   */
  const getCurrentWindowUValue = async (
    material: string,
    glazing: string
  ): Promise<number> => {
    const config = await loadSettings()

    const materialLower = material.toLowerCase()
    const glazingLower = glazing.toLowerCase()

    // Determine glazing layers
    let layers = 'double'
    if (glazingLower.includes('1 réteg') || glazingLower.includes('single')) {
      layers = 'single'
    } else if (glazingLower.includes('3 réteg') || glazingLower.includes('triple')) {
      layers = 'triple'
    }

    // Get U-value based on material and layers
    if (materialLower.includes('fa') || materialLower.includes('wood')) {
      if (layers === 'single') return config.uValueWindowWoodSingle
      if (layers === 'triple') return config.uValueWindowWoodTriple
      return config.uValueWindowWoodDouble
    } else if (materialLower.includes('műanyag') || materialLower.includes('plastic') || materialLower.includes('pvc')) {
      if (layers === 'single') return config.uValueWindowPlasticSingle
      if (layers === 'triple') return config.uValueWindowPlasticTriple
      return config.uValueWindowPlasticDouble
    } else if (materialLower.includes('fém') || materialLower.includes('metal')) {
      if (layers === 'single') return config.uValueWindowMetalSingle
      if (layers === 'triple') return config.uValueWindowMetalTriple
      return config.uValueWindowMetalDouble
    }

    // Default to plastic double
    return config.uValueWindowPlasticDouble
  }

  /**
   * Calculate total CO₂ reduction
   *
   * @param electricityImpactKWh - Electricity impact (positive = production, negative = consumption)
   * @param gasImpactM3 - Gas impact (positive = savings)
   * @returns CO₂ reduction in kg/year
   */
  const calculateCO2Reduction = async (
    electricityImpactKWh: number,
    gasImpactM3: number
  ): Promise<number> => {
    const config = await loadSettings()

    const co2FromElectricity = electricityImpactKWh * config.emissionFactorElectricity
    const co2FromGas = gasImpactM3 * config.emissionFactorGasM3

    return Math.round(co2FromElectricity + co2FromGas)
  }

  /**
   * Load monthly climate data from database
   */
  const loadMonthlyClimateData = async (
    region: string = 'hungary'
  ): Promise<MonthlyClimateData[]> => {
    const { data, error } = await supabase
      .from('monthly_climate_data')
      .select('month, solar_irradiance, heating_degree_days')
      .eq('region', region)
      .order('month')

    if (error) throw error

    return data as MonthlyClimateData[]
  }

  /**
   * Calculate monthly solar production breakdown
   *
   * Distributes annual production across months based on actual monthly solar irradiance
   *
   * @param panelPowerW - Power per panel in Watts
   * @param panelCount - Number of panels
   * @param efficiency - Panel efficiency (decimal)
   * @returns Array of 12 monthly values (kWh)
   */
  const calculateMonthlySolarProduction = async (
    panelPowerW: number,
    panelCount: number,
    efficiency: number
  ): Promise<MonthlyBreakdown[]> => {
    const config = await loadSettings()
    const monthlyClimate = await loadMonthlyClimateData()

    const panelPowerKW = panelPowerW / 1000
    const totalPowerKW = panelPowerKW * panelCount

    return monthlyClimate.map(climate => ({
      month: climate.month,
      value: Math.round(
        totalPowerKW *
        climate.solar_irradiance *
        config.solarPerformanceRatio
      )
    }))
  }

  /**
   * Calculate monthly heat pump electricity consumption
   *
   * Distributes annual electricity consumption based on heating degree days
   *
   * @param heatPumpPowerW - Heat pump power in Watts
   * @param heatPumpCOP - Heat pump COP
   * @param currentHeatingType - Current heating system type
   * @param annualGasConsumptionM3 - Current annual gas consumption
   * @returns Array of 12 monthly values (kWh)
   */
  const calculateMonthlyHeatPumpElectricity = async (
    heatPumpPowerW: number,
    heatPumpCOP: number,
    currentHeatingType: string,
    annualGasConsumptionM3?: number
  ): Promise<MonthlyBreakdown[]> => {
    const config = await loadSettings()
    const monthlyClimate = await loadMonthlyClimateData()

    if (!annualGasConsumptionM3) {
      return monthlyClimate.map(climate => ({ month: climate.month, value: 0 }))
    }

    // Get current heating efficiency
    let currentEfficiency = config.heatingEfficiencyDefault
    switch (currentHeatingType.toLowerCase()) {
      case 'nyílt égésterű kazán':
        currentEfficiency = config.heatingEfficiencyOpenFlue
        break
      case 'kondenzációs kazán':
        currentEfficiency = config.heatingEfficiencyCondensing
        break
      case 'konvektor':
        currentEfficiency = config.heatingEfficiencyConvector
        break
      case 'vegyestüzelésű kazán':
        currentEfficiency = config.heatingEfficiencyMixedFuel
        break
    }

    // Calculate total heat demand
    const heatDemandKWh =
      annualGasConsumptionM3 *
      config.gasEnergyConversion *
      currentEfficiency

    // Total heating degree days for the year
    const totalHDD = monthlyClimate.reduce(
      (sum, climate) => sum + climate.heating_degree_days,
      0
    )

    // Distribute electricity consumption proportionally to heating degree days
    return monthlyClimate.map(climate => ({
      month: climate.month,
      value: Math.round(
        (heatDemandKWh / heatPumpCOP) * (climate.heating_degree_days / totalHDD)
      )
    }))
  }

  /**
   * Calculate monthly gas savings breakdown
   *
   * Distributes annual gas savings based on heating degree days
   *
   * @param currentUValue - Current U-value W/m²K
   * @param newUValue - New U-value after insulation W/m²K
   * @param areaM2 - Insulated area in m²
   * @param currentHeatingType - Current heating system type
   * @returns Array of 12 monthly values (m³)
   */
  const calculateMonthlyGasSavings = async (
    currentUValue: number,
    newUValue: number,
    areaM2: number,
    currentHeatingType: string
  ): Promise<MonthlyBreakdown[]> => {
    const config = await loadSettings()
    const monthlyClimate = await loadMonthlyClimateData()

    // Get current heating efficiency
    let currentEfficiency = config.heatingEfficiencyDefault
    switch (currentHeatingType.toLowerCase()) {
      case 'nyílt égésterű kazán':
        currentEfficiency = config.heatingEfficiencyOpenFlue
        break
      case 'kondenzációs kazán':
        currentEfficiency = config.heatingEfficiencyCondensing
        break
      case 'konvektor':
        currentEfficiency = config.heatingEfficiencyConvector
        break
      case 'vegyestüzelésű kazán':
        currentEfficiency = config.heatingEfficiencyMixedFuel
        break
    }

    return monthlyClimate.map(climate => {
      // Calculate monthly heat loss reduction (kWh)
      const monthlyHeatLossReductionKWh =
        (currentUValue - newUValue) *
        areaM2 *
        climate.heating_degree_days *
        24 /
        1000

      // Convert to gas savings (m³)
      const monthlyGasSavingsM3 =
        monthlyHeatLossReductionKWh /
        config.gasEnergyConversion /
        currentEfficiency

      return {
        month: climate.month,
        value: Math.round(monthlyGasSavingsM3)
      }
    })
  }

  /**
   * Calculate net monthly electricity impact
   *
   * Combines solar production (positive) and heat pump consumption (negative)
   *
   * @param solarMonthly - Monthly solar production values
   * @param heatPumpMonthly - Monthly heat pump electricity consumption values
   * @returns Array of 12 monthly net values (kWh)
   */
  const calculateMonthlyElectricityNet = (
    solarMonthly: MonthlyBreakdown[],
    heatPumpMonthly: MonthlyBreakdown[]
  ): MonthlyBreakdown[] => {
    return solarMonthly.map((solar, index) => ({
      month: solar.month,
      value: solar.value - (heatPumpMonthly[index]?.value || 0)
    }))
  }

  return {
    loadSettings,
    calculateSolarProduction,
    calculateHeatPumpImpact,
    calculateInsulationSavings,
    getCurrentWallUValue,
    getCurrentRoofUValue,
    getCurrentWindowUValue,
    calculateCO2Reduction,
    loadMonthlyClimateData,
    calculateMonthlySolarProduction,
    calculateMonthlyHeatPumpElectricity,
    calculateMonthlyGasSavings,
    calculateMonthlyElectricityNet
  }
}
