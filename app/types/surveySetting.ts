/**
 * Survey Settings Types
 * Configuration values for energy calculations and survey defaults
 */

export interface SurveySetting {
  id: string
  created_at: string
  updated_at: string
  persist_name: string
  value: string
  description?: string
}

/**
 * Typed survey settings with parsed values
 */
export interface SurveySettings {
  // Solar panel calculations
  solarIrradianceAnnual: number // kWh/m²/year
  solarPerformanceRatio: number // 0-1 (percentage as decimal)

  // Energy conversion
  gasEnergyConversion: number // kWh/m³

  // Heating calculations
  heatingDegreeDays: number // degree days/year

  // Heating system efficiency
  heatingEfficiencyOpenFlue: number // 0-1
  heatingEfficiencyCondensing: number // 0-1
  heatingEfficiencyConvector: number // 0-1
  heatingEfficiencyMixedFuel: number // 0-1
  heatingEfficiencyDefault: number // 0-1

  // Emission factors
  emissionFactorElectricity: number // kg CO₂/kWh
  emissionFactorGasM3: number // kg CO₂/m³
  emissionFactorGasKwh: number // kg CO₂/kWh

  // Energy prices
  electricityPrice: number // HUF/kWh
  gasPrice: number // HUF/m³

  // Wall U-values (uninsulated) - W/m²K
  uValueWallSmallBrick: number
  uValueWallLimeSand: number
  uValueWallB30: number
  uValueWallPoroton: number
  uValueWallGasSilicate: number
  uValueWallBautherm: number
  uValueWallPorotherm: number
  uValueWallYtong: number
  uValueWallConcretePanel: number
  uValueWallWattle: number
  uValueWallLightweight: number

  // Roof U-values (uninsulated) - W/m²K
  uValueRoofUninsulatedHipped: number
  uValueRoofUninsulatedFlat: number

  // Window U-values - W/m²K
  uValueWindowWoodSingle: number
  uValueWindowWoodDouble: number
  uValueWindowWoodTriple: number
  uValueWindowPlasticSingle: number
  uValueWindowPlasticDouble: number
  uValueWindowPlasticTriple: number
  uValueWindowMetalSingle: number
  uValueWindowMetalDouble: number
  uValueWindowMetalTriple: number
}

/**
 * Map persist_name to typed property names
 */
export const SETTING_KEY_MAP: Record<string, keyof SurveySettings> = {
  solar_irradiance_annual: 'solarIrradianceAnnual',
  solar_performance_ratio: 'solarPerformanceRatio',
  gas_energy_conversion: 'gasEnergyConversion',
  heating_degree_days: 'heatingDegreeDays',
  heating_efficiency_open_flue: 'heatingEfficiencyOpenFlue',
  heating_efficiency_condensing: 'heatingEfficiencyCondensing',
  heating_efficiency_convector: 'heatingEfficiencyConvector',
  heating_efficiency_mixed_fuel: 'heatingEfficiencyMixedFuel',
  heating_efficiency_default: 'heatingEfficiencyDefault',
  emission_factor_electricity: 'emissionFactorElectricity',
  emission_factor_gas_m3: 'emissionFactorGasM3',
  emission_factor_gas_kwh: 'emissionFactorGasKwh',
  electricity_price: 'electricityPrice',
  gas_price: 'gasPrice',
  u_value_wall_small_brick: 'uValueWallSmallBrick',
  u_value_wall_lime_sand: 'uValueWallLimeSand',
  u_value_wall_b30: 'uValueWallB30',
  u_value_wall_poroton: 'uValueWallPoroton',
  u_value_wall_gas_silicate: 'uValueWallGasSilicate',
  u_value_wall_bautherm: 'uValueWallBautherm',
  u_value_wall_porotherm: 'uValueWallPorotherm',
  u_value_wall_ytong: 'uValueWallYtong',
  u_value_wall_concrete_panel: 'uValueWallConcretePanel',
  u_value_wall_wattle: 'uValueWallWattle',
  u_value_wall_lightweight: 'uValueWallLightweight',
  u_value_roof_uninsulated_hipped: 'uValueRoofUninsulatedHipped',
  u_value_roof_uninsulated_flat: 'uValueRoofUninsulatedFlat',
  u_value_window_wood_single: 'uValueWindowWoodSingle',
  u_value_window_wood_double: 'uValueWindowWoodDouble',
  u_value_window_wood_triple: 'uValueWindowWoodTriple',
  u_value_window_plastic_single: 'uValueWindowPlasticSingle',
  u_value_window_plastic_double: 'uValueWindowPlasticDouble',
  u_value_window_plastic_triple: 'uValueWindowPlasticTriple',
  u_value_window_metal_single: 'uValueWindowMetalSingle',
  u_value_window_metal_double: 'uValueWindowMetalDouble',
  u_value_window_metal_triple: 'uValueWindowMetalTriple'
}
