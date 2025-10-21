/**
 * Scenario Generator Utility
 * Based on FlowFrontend utils/aiScenarioGenerator.ts
 *
 * Generates technical data for scenarios with hardcoded calculations
 * TODO: Replace with real calculations in the future
 */

export enum ScenarioType {
  Optimum = 'optimum',
  Minimum = 'minimum',
  Premium = 'premium'
}

interface ScenarioConfig {
  priceMultiplier: number
  qualityLevel: 'high' | 'medium' | 'low'
  quantityMultiplier: number
  preferredBrands?: string[]
}

const SCENARIO_CONFIGS: Record<ScenarioType, ScenarioConfig> = {
  [ScenarioType.Optimum]: {
    priceMultiplier: 1.0,
    qualityLevel: 'medium',
    quantityMultiplier: 1.0,
    preferredBrands: ['Longi', 'Huawei', 'Daikin']
  },
  [ScenarioType.Minimum]: {
    priceMultiplier: 0.8,
    qualityLevel: 'low',
    quantityMultiplier: 0.9,
    preferredBrands: ['JA Solar', 'Trina Solar']
  },
  [ScenarioType.Premium]: {
    priceMultiplier: 1.3,
    qualityLevel: 'high',
    quantityMultiplier: 1.2,
    preferredBrands: ['Longi', 'Solax', 'Daikin', 'Viessmann']
  }
}

// Base quantities for different investment types and categories
// Based on FlowFrontend BASE_QUANTITIES
const BASE_QUANTITIES: Record<string, Record<string, number>> = {
  'Solar Panel': {
    panel: 12,        // 12 panels (~6.5kW system)
    inverter: 1,      // 1 inverter
    mounting: 1       // 1 mounting set
  },
  'Solar Panel + Battery': {
    panel: 16,        // 16 panels (~8.6kW system)
    inverter: 1,      // 1 hybrid inverter
    mounting: 1,      // 1 mounting set
    battery: 1        // 1 battery
  },
  'Heat Pump': {
    heatpump: 1,      // 1 heat pump
    accessory: 1      // 1 buffer tank
  },
  'Facade Insulation': {
    insulation: 120,  // 120 m² insulation
    adhesive: 8,      // 8 bags adhesive
    plaster: 5        // 5 buckets plaster
  },
  'Roof Insulation': {
    insulation: 80,   // 80 m² insulation
    vapor_barrier: 85 // 85 m² vapor barrier (5% extra)
  },
  'Windows': {
    window: 25        // 25 m² windows
  },
  'Air Conditioner': {
    airconditioner: 2 // 2 air conditioners
  },
  'Battery': {
    battery: 2        // 2 batteries for standalone
  },
  'Car Charger': {
    charger: 1        // 1 EV charger
  }
}

/**
 * Gets the scenario display name
 */
export const getScenarioDisplayName = (scenarioType: ScenarioType, sequence: number): string => {
  switch (scenarioType) {
    case ScenarioType.Optimum:
      return `Version ${sequence} - Optimum`
    case ScenarioType.Minimum:
      return `Version ${sequence} - Minimum`
    case ScenarioType.Premium:
      return `Version ${sequence} - Premium`
    default:
      return `Version ${sequence}`
  }
}

/**
 * Gets the scenario description
 */
export const getScenarioDescription = (scenarioType: ScenarioType): string => {
  switch (scenarioType) {
    case ScenarioType.Optimum:
      return 'Balanced solution with optimal price-performance ratio'
    case ScenarioType.Minimum:
      return 'Cost-effective solution with reliable quality'
    case ScenarioType.Premium:
      return 'High-end solution with premium components'
    default:
      return 'AI generated scenario'
  }
}

/**
 * Gets base quantities for an investment
 */
export const getBaseQuantities = (investmentName: string): Record<string, number> => {
  return BASE_QUANTITIES[investmentName] || {}
}

/**
 * Gets scenario config
 */
export const getScenarioConfig = (scenarioType: ScenarioType): ScenarioConfig => {
  return SCENARIO_CONFIGS[scenarioType]
}

/**
 * Calculates component quantity for a scenario
 */
export const calculateQuantity = (
  baseQuantity: number,
  scenarioType: ScenarioType
): number => {
  const config = SCENARIO_CONFIGS[scenarioType]
  return Math.round(baseQuantity * config.quantityMultiplier)
}

/**
 * Gets all scenario types in order
 */
export const getAllScenarioTypes = (): ScenarioType[] => {
  return [ScenarioType.Optimum, ScenarioType.Minimum, ScenarioType.Premium]
}
