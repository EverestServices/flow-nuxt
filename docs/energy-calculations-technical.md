# Energy Savings Calculations - Technical Documentation

## Table of Contents
1. [System Overview](#system-overview)
2. [Database Schema](#database-schema)
3. [TypeScript Types](#typescript-types)
4. [Composable API](#composable-api)
5. [Calculation Formulas](#calculation-formulas)
6. [Implementation Examples](#implementation-examples)
7. [Testing](#testing)
8. [Performance Considerations](#performance-considerations)

---

## System Overview

The energy savings calculation system provides methods to calculate annual energy production, consumption, and CO₂ reduction for various investment types.

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Survey Components                     │
│  (SurveyConsultation, SurveyHouseholdData, Scenarios)   │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              useEnergySavings Composable                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  - calculateSolarProduction()                    │   │
│  │  - calculateHeatPumpImpact()                     │   │
│  │  - calculateInsulationSavings()                  │   │
│  │  - calculateCO2Reduction()                       │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Supabase Database                      │
│  ┌──────────────────┐  ┌──────────────────────────┐    │
│  │ survey_settings  │  │ main_components          │    │
│  │ - persist_name   │  │ - power, efficiency      │    │
│  │ - value          │  │ - u_value, cop           │    │
│  └──────────────────┘  └──────────────────────────┘    │
│                                                          │
│  ┌──────────────────┐  ┌──────────────────────────┐    │
│  │ survey_answers   │  │ scenario_main_components │    │
│  │ - answer data    │  │ - quantity               │    │
│  └──────────────────┘  └──────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Configuration Loading**: Load system-wide settings from `survey_settings` table
2. **Survey Data Retrieval**: Fetch survey answers and scenario components
3. **Calculation**: Apply formulas using configuration and survey data
4. **Aggregation**: Sum up impacts by investment type
5. **Display**: Show energy impacts and CO₂ reduction

---

## Database Schema

### `survey_settings` Table

Stores system-wide configuration values for energy calculations.

```sql
CREATE TABLE public.survey_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    persist_name VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT
);
```

#### Key Settings

| persist_name | Type | Description | Default Value |
|--------------|------|-------------|---------------|
| `solar_irradiance_annual` | number | Annual solar irradiance (kWh/m²/year) | 1200 |
| `solar_performance_ratio` | decimal | System performance ratio (0-1) | 0.80 |
| `gas_energy_conversion` | number | Energy content of gas (kWh/m³) | 10.55 |
| `heating_degree_days` | number | Annual heating degree days | 3200 |
| `emission_factor_electricity` | decimal | CO₂ emission factor for electricity (kg/kWh) | 0.27 |
| `emission_factor_gas_m3` | decimal | CO₂ emission factor for gas (kg/m³) | 1.98 |
| `u_value_wall_*` | decimal | U-values for different wall types (W/m²K) | varies |
| `u_value_window_*` | decimal | U-values for window types (W/m²K) | varies |

### `main_components` Table (Extended)

Added fields for energy calculations:

```sql
ALTER TABLE public.main_components ADD COLUMN efficiency DECIMAL(5, 2);
-- Solar panel efficiency (18-22%)
-- Already has: power, capacity, u_value, cop, thickness
```

---

## TypeScript Types

### Location
`/app/types/surveySetting.ts`

### Interfaces

```typescript
export interface SurveySetting {
  id: string
  created_at: string
  updated_at: string
  persist_name: string
  value: string
  description?: string
}

export interface SurveySettings {
  // Solar
  solarIrradianceAnnual: number
  solarPerformanceRatio: number

  // Energy conversion
  gasEnergyConversion: number

  // Heating
  heatingDegreeDays: number
  heatingEfficiencyOpenFlue: number
  heatingEfficiencyCondensing: number
  // ... (see full file)

  // U-values
  uValueWallSmallBrick: number
  uValueWindowPlasticDouble: number
  // ... (see full file)
}
```

### Constant Mappings

```typescript
export const SETTING_KEY_MAP: Record<string, keyof SurveySettings>
```

Maps database `persist_name` values to TypeScript property names (snake_case → camelCase).

---

## Composable API

### Location
`/app/composables/useEnergySavings.ts`

### Methods

#### 1. `loadSettings()`

Loads and caches survey settings from database.

```typescript
const loadSettings = async (): Promise<SurveySettings>
```

**Returns:** Typed `SurveySettings` object with all configuration values
**Caching:** Results are cached in `settings` ref to avoid redundant DB queries

---

#### 2. `calculateSolarProduction()`

Calculates annual electricity production from solar panels.

```typescript
const calculateSolarProduction = async (
  panelPowerW: number,
  panelCount: number,
  efficiency: number
): Promise<number>
```

**Parameters:**
- `panelPowerW` - Power per panel in Watts (e.g., 425)
- `panelCount` - Number of panels (e.g., 12)
- `efficiency` - Panel efficiency as decimal (e.g., 0.205 for 20.5%)

**Returns:** Annual production in kWh

**Formula:**
```typescript
production = (panelPowerW / 1000) * panelCount *
             solarIrradianceAnnual *
             solarPerformanceRatio
```

**Example:**
```typescript
const { calculateSolarProduction } = useEnergySavings()
const production = await calculateSolarProduction(425, 12, 0.205)
// Returns: ~4896 kWh/year
```

---

#### 3. `calculateHeatPumpImpact()`

Calculates gas savings and electricity increase when replacing gas heating with heat pump.

```typescript
const calculateHeatPumpImpact = async (
  heatPumpPowerW: number,
  heatPumpCOP: number,
  currentHeatingType: string,
  annualGasConsumptionM3?: number
): Promise<{ gasSavings: number; electricityIncrease: number }>
```

**Parameters:**
- `heatPumpPowerW` - Heat pump power in Watts (not used in current formula, reserved for future)
- `heatPumpCOP` - Coefficient of Performance (e.g., 4.5)
- `currentHeatingType` - Type of current heating system (e.g., "Kondenzációs kazán")
- `annualGasConsumptionM3` - Current annual gas consumption in m³

**Returns:** Object with `gasSavings` (m³/year) and `electricityIncrease` (kWh/year)

**Formula:**
```typescript
heatDemand = gasConsumption * gasEnergyConversion * currentEfficiency
electricityConsumption = heatDemand / COP
gasSavings = gasConsumption (entire consumption eliminated)
```

**Example:**
```typescript
const { calculateHeatPumpImpact } = useEnergySavings()
const impact = await calculateHeatPumpImpact(
  14000, // 14kW heat pump
  4.5,   // COP
  "Kondenzációs kazán",
  1500   // 1500 m³ gas/year
)
// Returns: { gasSavings: 1500, electricityIncrease: 3341 }
```

---

#### 4. `calculateInsulationSavings()`

Calculates annual gas savings from wall or roof insulation.

```typescript
const calculateInsulationSavings = async (
  currentUValue: number,
  newUValue: number,
  areaM2: number,
  currentHeatingType: string
): Promise<number>
```

**Parameters:**
- `currentUValue` - Current U-value in W/m²K (before insulation)
- `newUValue` - New U-value in W/m²K (after insulation)
- `areaM2` - Insulated area in m²
- `currentHeatingType` - Type of current heating system

**Returns:** Annual gas savings in m³

**Formula:**
```typescript
heatLossReduction = (currentU - newU) * area * heatingDegreeDays * 24 / 1000
gasSavings = heatLossReduction / gasEnergyConversion / heatingEfficiency
```

**Example:**
```typescript
const { calculateInsulationSavings } = useEnergySavings()
const savings = await calculateInsulationSavings(
  1.7,   // Old wall U-value
  0.25,  // New U-value with 15cm insulation
  120,   // 120 m² facade
  "Nyílt égésterű kazán"
)
// Returns: ~1408 m³/year
```

---

#### 5. `getCurrentWallUValue()`, `getCurrentRoofUValue()`, `getCurrentWindowUValue()`

Helper methods to determine current U-values based on building construction.

```typescript
const getCurrentWallUValue = async (
  wallType: string,
  hasInsulation: boolean = false,
  insulationThickness: number = 0
): Promise<number>

const getCurrentRoofUValue = async (
  roofType: string,
  hasInsulation: boolean = false,
  insulationThickness: number = 0
): Promise<number>

const getCurrentWindowUValue = async (
  material: string,
  glazing: string
): Promise<number>
```

**Example:**
```typescript
const { getCurrentWallUValue } = useEnergySavings()
const uValue = await getCurrentWallUValue("Kis méretű tömör tégla", false, 0)
// Returns: 1.7 W/m²K
```

---

#### 6. `calculateCO2Reduction()`

Calculates total CO₂ reduction based on electricity and gas impacts.

```typescript
const calculateCO2Reduction = async (
  electricityImpactKWh: number,
  gasImpactM3: number
): Promise<number>
```

**Parameters:**
- `electricityImpactKWh` - Annual electricity impact (positive = production, negative = consumption)
- `gasImpactM3` - Annual gas impact (positive = savings)

**Returns:** CO₂ reduction in kg/year

**Formula:**
```typescript
co2Reduction = electricityImpact * emissionFactorElectricity +
               gasImpact * emissionFactorGasM3
```

**Example:**
```typescript
const { calculateCO2Reduction } = useEnergySavings()
const co2 = await calculateCO2Reduction(4896, 2546)
// Returns: ~6363 kg CO₂/year
```

---

## Calculation Formulas

### Solar Panel Production

```
Annual Production (kWh) =
  Panel Power (kW) ×
  Panel Count ×
  Annual Irradiance (kWh/m²/year) ×
  Performance Ratio
```

**Variables:**
- Panel Power: From `main_components.power` (W) / 1000
- Panel Count: From `scenario_main_components.quantity`
- Annual Irradiance: From `survey_settings.solar_irradiance_annual` (1200)
- Performance Ratio: From `survey_settings.solar_performance_ratio` (0.80)

---

### Heat Pump Impact

```
Heat Demand (kWh) =
  Gas Consumption (m³) ×
  Gas Energy Content (kWh/m³) ×
  Current Heating Efficiency

Electricity Consumption (kWh) =
  Heat Demand (kWh) / COP

Gas Savings = Gas Consumption (entire amount)
Electricity Increase = Electricity Consumption
```

**Variables:**
- Gas Consumption: From survey answers `household_data.consumption`
- Gas Energy Content: From `survey_settings.gas_energy_conversion` (10.55)
- Current Heating Efficiency: From `survey_settings.heating_efficiency_*` (0.85-1.00)
- COP: From `main_components.cop` (4.1-4.6)

---

### Insulation Savings

```
Heat Loss Reduction (kWh/year) =
  (U_old - U_new) ×
  Area (m²) ×
  Heating Degree Days ×
  24 hours /
  1000

Gas Savings (m³/year) =
  Heat Loss Reduction /
  Gas Energy Content /
  Heating Efficiency
```

**Variables:**
- U_old: From survey answers or `survey_settings.u_value_*`
- U_new: From `main_components.u_value` (insulation material)
- Area: From `scenario_main_components.quantity`
- Heating Degree Days: From `survey_settings.heating_degree_days` (3200)

---

### CO₂ Reduction

```
CO₂ Reduction (kg/year) =
  Electricity Impact (kWh) × Emission Factor Electricity +
  Gas Impact (m³) × Emission Factor Gas
```

**Variables:**
- Emission Factor Electricity: From `survey_settings.emission_factor_electricity` (0.27)
- Emission Factor Gas: From `survey_settings.emission_factor_gas_m3` (1.98)

---

## Implementation Examples

### Example 1: Calculate Solar Production for a Scenario

```typescript
import { useEnergySavings } from '~/composables/useEnergySavings'
import { useScenariosStore } from '~/stores/scenarios'

const { calculateSolarProduction } = useEnergySavings()
const scenariosStore = useScenariosStore()

// Get scenario components
const components = scenariosStore.scenarioComponents[scenarioId]

// Find solar panels
const panels = components.filter(c =>
  c.main_component.main_component_category.persist_name === 'panel'
)

if (panels.length > 0) {
  const panel = panels[0]
  const power = panel.main_component.power || 425
  const efficiency = panel.main_component.efficiency || 20.5
  const quantity = panel.quantity

  const production = await calculateSolarProduction(
    power,
    quantity,
    efficiency / 100 // Convert percentage to decimal
  )

  console.log(`Annual solar production: ${production} kWh`)
}
```

---

### Example 2: Calculate Heat Pump Impact

```typescript
const { calculateHeatPumpImpact } = useEnergySavings()
const supabase = useSupabaseClient()

// Get household data
const { data: survey } = await supabase
  .from('surveys')
  .select('household_data')
  .eq('id', surveyId)
  .single()

// Get current heating type from survey answers
const { data: answers } = await supabase
  .from('survey_answers')
  .select(`
    answer,
    survey_question:survey_questions(name)
  `)
  .eq('survey_id', surveyId)

const heatingTypeAnswer = answers.find(
  a => a.survey_question.name === 'current_heating_solution'
)

const gasConsumption = parseFloat(survey.household_data?.consumption || '0')

// Get heat pump from scenario
const heatPump = components.find(c =>
  c.main_component.main_component_category.persist_name === 'heatpump'
)

if (heatPump) {
  const impact = await calculateHeatPumpImpact(
    heatPump.main_component.power || 14000,
    heatPump.main_component.cop || 4.5,
    heatingTypeAnswer?.answer || 'Nyílt égésterű kazán',
    gasConsumption
  )

  console.log(`Gas savings: ${impact.gasSavings} m³/year`)
  console.log(`Electricity increase: ${impact.electricityIncrease} kWh/year`)
}
```

---

### Example 3: Aggregate All Impacts for a Scenario

```typescript
async function calculateScenarioImpacts(scenarioId: string) {
  const {
    calculateSolarProduction,
    calculateHeatPumpImpact,
    calculateInsulationSavings,
    calculateCO2Reduction
  } = useEnergySavings()

  let totalElectricity = 0
  let totalGas = 0
  const details: InvestmentDetail[] = []

  // Get all components for this scenario
  const components = await getScenarioComponents(scenarioId)

  // Calculate solar impact
  const solarPanels = components.filter(c => c.category === 'panel')
  if (solarPanels.length > 0) {
    const production = await calculateSolarProduction(...)
    totalElectricity += production
    details.push({
      investmentName: 'PV System',
      electricityImpact: production
    })
  }

  // Calculate heat pump impact
  const heatPumps = components.filter(c => c.category === 'heatpump')
  if (heatPumps.length > 0) {
    const impact = await calculateHeatPumpImpact(...)
    totalElectricity -= impact.electricityIncrease
    totalGas += impact.gasSavings
    details.push({
      investmentName: 'Heat Pump',
      electricityImpact: -impact.electricityIncrease,
      gasImpact: impact.gasSavings
    })
  }

  // Calculate insulation impacts...
  // (similar pattern for facade, roof, windows)

  // Calculate CO₂
  const co2 = await calculateCO2Reduction(totalElectricity, totalGas)

  return {
    electricityImpact: totalElectricity,
    naturalGasImpact: totalGas,
    co2Reduction: co2,
    investmentDetails: details
  }
}
```

---

## Testing

### Unit Tests

Location: `tests/composables/useEnergySavings.spec.ts`

```typescript
describe('useEnergySavings', () => {
  describe('calculateSolarProduction', () => {
    it('should calculate correct production for 12 panels', async () => {
      const { calculateSolarProduction } = useEnergySavings()
      const production = await calculateSolarProduction(425, 12, 0.205)
      expect(production).toBeCloseTo(4896, 0)
    })
  })

  describe('calculateHeatPumpImpact', () => {
    it('should calculate gas savings and electricity increase', async () => {
      const { calculateHeatPumpImpact } = useEnergySavings()
      const impact = await calculateHeatPumpImpact(
        14000, 4.5, 'Kondenzációs kazán', 1500
      )
      expect(impact.gasSavings).toBe(1500)
      expect(impact.electricityIncrease).toBeCloseTo(3341, 0)
    })
  })
})
```

---

## Performance Considerations

### Caching

The `settings` ref caches survey settings after first load:
```typescript
const settings = ref<SurveySettings | null>(null)

const loadSettings = async (): Promise<SurveySettings> => {
  if (settings.value) return settings.value // Return cached
  // ... load from DB
}
```

**Benefits:**
- Avoid repeated DB queries
- Faster calculations
- Reduced network load

### Batch Calculations

When calculating for multiple scenarios, batch database queries:

```typescript
// ❌ Bad - Multiple round trips
for (const scenario of scenarios) {
  const components = await getComponents(scenario.id)
  // calculate...
}

// ✅ Good - Single query
const allComponents = await supabase
  .from('scenario_main_components')
  .select('*')
  .in('scenario_id', scenarios.map(s => s.id))

// Group by scenario and calculate
```

### Memoization

For repeated calculations with same inputs, consider memoization:

```typescript
const calculationCache = new Map<string, number>()

const calculateWithCache = async (key: string, fn: () => Promise<number>) => {
  if (calculationCache.has(key)) return calculationCache.get(key)!
  const result = await fn()
  calculationCache.set(key, result)
  return result
}
```

---

## Future Enhancements

### Planned Features

1. **Regional Solar Irradiance**: Different values based on postal code
2. **Seasonal Breakdown**: Monthly energy production/consumption
3. **Cost Calculations**: Financial ROI based on energy prices
4. **Grid Feed-in**: Model surplus solar energy sold to grid
5. **Battery Storage**: Optimize self-consumption with battery systems

### Migration Path

When adding new features:
1. Add new settings to `survey_settings` via migration
2. Update `SurveySettings` interface in types
3. Update `SETTING_KEY_MAP` constant
4. Extend composable methods
5. Update documentation
6. Add tests

---

## Troubleshooting

### Common Issues

**Issue:** Calculations return 0 or NaN
**Solution:** Check that survey_settings are populated and types are correct

**Issue:** U-values not found for building type
**Solution:** Ensure survey_settings has all wall/window types seeded

**Issue:** COP or efficiency missing
**Solution:** Check main_components table has these values populated

---

## References

- [Energy Calculations Functional Documentation](./energy-calculations-functional.md)
- [Supabase Schema Documentation](../supabase/migrations/)
- [TypeScript Types](../app/types/surveySetting.ts)
- [Composable Source](../app/composables/useEnergySavings.ts)
