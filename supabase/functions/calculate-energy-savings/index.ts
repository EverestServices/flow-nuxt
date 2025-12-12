import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Energy calculation constants (from OFP)
const ENERGY_CONSTANTS = {
  // Average outside temperature (°C)
  AVERAGE_OUTSIDE_TEMP: 3.6,

  // Annual heating duration (hours)
  ANNUAL_HEATING_DURATION: 4392,

  // Conversion factors
  GJ_TO_KWH: 277.778, // 1 GJ = 277.778 kWh
  KWH_TO_GJ: 0.0036,  // 1 kWh = 0.0036 GJ
  MJ_TO_GJ: 0.001,    // 1 MJ = 0.001 GJ

  // Efficiency factors
  EFFICIENCY_FACTOR: 0.9,
  EFFICIENCY_FACTOR_PRIMARY: 0.86, // For primary energy calculation
  FLOOR_HEAT_TRANSFER_COEFFICIENT: 1.15, // W/m²K for floors
  WINDOW_EFFICIENCY_FACTOR: 0.9,
}

// Heating values (MJ per unit) - from OFP Sherpa EnergyBalanceProvider
const HEATING_VALUES = {
  'Villamos energia': 3.6,        // MJ/kWh (1 kWh = 3.6 MJ)
  'Földgáz': 35,                  // MJ/m³
  'PB gáz': 46,                   // MJ/kg
  'Tűzifa, vegyes tüzelő': 16,   // MJ/kg
  'Szén': 22,                     // MJ/kg
  'Napkollektorok éves hőtermelése': 3.6, // MJ/kWh (same as electricity)
}

// Material thermal conductivity (λ) values (W/mK) - from OFP
const MATERIAL_LAMBDA: Record<string, number> = {
  'Tégla 38cm': 0.7,
  'Tégla 50cm': 0.7,
  'Mészhomok tégla': 0.56,
  'B30 tégla': 0.42,
  'Poroton': 0.31,
  'Gázsilikát': 0.14,
  'Vasbeton panel': 1.74,
  'Vályog': 0.7,
  'Könnyűszerkezetes': 0.35,
}

// Insulation thermal conductivity (λ) values (W/mK)
const INSULATION_LAMBDA: Record<string, number> = {
  'EPS': 0.039,
  'XPS': 0.036,
  'Ásványgyapot': 0.040,
  'Grafitos EPS': 0.032,
  'PIR': 0.023,
  'Nincs': 0,
}

// Window U-values (W/m²K) based on material and glazing type - from OFP
const WINDOW_U_VALUES: Record<string, Record<string, number>> = {
  'Fa': {
    '1 rétegű üvegezésű': 5.0,
    '2 rétegű üvegezésű': 2.8,
    '3 rétegű üvegezésű': 1.7,
    '2 rétegű csavaros teschauer': 3.5,
    '2 rétegű kapcsolt gerébtokos': 3.0,
  },
  'Műanyag': {
    '1 rétegű üvegezésű': 5.0,
    '2 rétegű üvegezésű': 2.4,
    '3 rétegű üvegezésű': 1.4,
  },
  'Fém': {
    '1 rétegű üvegezésű': 5.5,
    '2 rétegű üvegezésű': 3.2,
    '3 rétegű üvegezésű': 1.9,
  },
}

// Window size category to m² mapping (from OFP)
const WINDOW_SIZE_TO_AREA: Record<string, number> = {
  'Kisablak (90 cm × 90 cm-nél kisebb)': 0.64, // ~0.8m × 0.8m
  'Átlagos ablak (90-150 cm × 90-150 cm közötti)': 1.44, // ~1.2m × 1.2m
  'Nagyablak (150 cm × 150 cm-nél nagyobb)': 3.24, // ~1.8m × 1.8m
  'Bejárati ajtó': 1.96, // ~1.0m × 1.96m
  'Terasz/erkélyajtó (üvegezett)': 3.92, // ~2.0m × 1.96m
}

interface CalculateEnergySavingsRequest {
  surveyId: string
  scenarioId: string
}

interface EnergySavingsPerInvestment {
  annualHeatingSavingsGJ: number
  annualHeatingSavingsKWh: number
  savingsPercentage: number
  actualArea?: number
  capacity?: number
}

interface KEHOPSummary {
  totalGJ: number
  totalKWh: number
  totalPercentage: number
  meets30Percent: boolean
}

interface EnergySavingsResult {
  perInvestment: {
    [key: string]: EnergySavingsPerInvestment
  }
  kehopSummary: KEHOPSummary
  theoreticalTotalHeatingEnergyGJ: number
  calculatedAt: string
  usedConsultantMode: boolean // true = used energy_consumption_table (CORRECT), false = used architectural (NOT RECOMMENDED)
  warnings?: string[] // Array of warning messages if calculation is unreliable
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Parse request body
    const body: CalculateEnergySavingsRequest = await req.json()

    if (!body.surveyId || !body.scenarioId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing surveyId or scenarioId' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 2. Create Supabase client with service role (admin access)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // 3. Get scenario
    const { data: scenario, error: scenarioError } = await supabaseAdmin
      .from('scenarios')
      .select('*')
      .eq('id', body.scenarioId)
      .single()

    if (scenarioError || !scenario) {
      console.error('Scenario not found:', scenarioError)
      return new Response(
        JSON.stringify({ success: false, error: 'Scenario not found' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 404,
        }
      )
    }

    // Get survey answers with question names for calculations
    const { data: surveyAnswers } = await supabaseAdmin
      .from('survey_answers')
      .select(`
        answer,
        item_group,
        survey_question:survey_questions(name)
      `)
      .eq('survey_id', body.surveyId)

    // 4. Get scenario investments
    const { data: scenarioInvestments } = await supabaseAdmin
      .from('scenario_investments')
      .select(`
        investment:investments(
          id,
          name,
          persist_name,
          energy_efficiency_improvement
        )
      `)
      .eq('scenario_id', body.scenarioId)

    // 5. Get scenario main components with quantities
    const { data: scenarioComponents } = await supabaseAdmin
      .from('scenario_main_components')
      .select(`
        *,
        main_component:main_components(
          *,
          category:main_component_categories(*)
        )
      `)
      .eq('scenario_id', body.scenarioId)

    // Helper function to get survey answer by question name
    function getSurveyAnswer(questionName: string, itemGroup?: string): any {
      if (!surveyAnswers) return null

      const answer = surveyAnswers.find(a => {
        const nameMatch = a.survey_question?.name === questionName
        if (itemGroup !== undefined) {
          return nameMatch && a.item_group === itemGroup
        }
        return nameMatch
      })

      if (!answer?.answer) return null

      // Parse JSON string if answer is stored as TEXT (not JSONB)
      if (typeof answer.answer === 'string') {
        try {
          return JSON.parse(answer.answer)
        } catch (e) {
          // If parsing fails, return as-is (might be plain text answer)
          return answer.answer
        }
      }

      return answer.answer
    }

    // Helper function to calculate wall U-value
    function calculateWallUValue(
      materialType: string,
      thickness: number,
      hasInsulation: boolean,
      insulationThickness: number,
      insulationType: string
    ): number {
      // U = 1 / (R_surface_inside + R_wall + R_insulation + R_surface_outside)
      // R = d / λ (d = thickness in meters, λ = thermal conductivity)

      const R_si = 0.13 // Internal surface resistance (m²K/W)
      const R_se = 0.04 // External surface resistance (m²K/W)

      // Wall resistance
      const materialLambda = MATERIAL_LAMBDA[materialType] || 0.7
      const R_wall = (thickness / 100) / materialLambda // Convert cm to m

      // Insulation resistance
      let R_insulation = 0
      if (hasInsulation && insulationThickness > 0) {
        const insulationLambda = INSULATION_LAMBDA[insulationType] || 0.04
        R_insulation = (insulationThickness / 100) / insulationLambda
      }

      const R_total = R_si + R_wall + R_insulation + R_se
      return 1 / R_total
    }

    // Helper function to calculate roof U-value
    function calculateRoofUValue(
      hasInsulation: boolean,
      insulationThickness: number,
      insulationType: string
    ): number {
      const R_si = 0.10 // Internal surface resistance for roofs (m²K/W)
      const R_se = 0.04 // External surface resistance (m²K/W)

      // Base roof structure resistance (typical value)
      const R_structure = 0.25

      // Insulation resistance
      let R_insulation = 0
      if (hasInsulation && insulationThickness > 0) {
        const insulationLambda = INSULATION_LAMBDA[insulationType] || 0.04
        R_insulation = (insulationThickness / 100) / insulationLambda
      }

      const R_total = R_si + R_structure + R_insulation + R_se
      return 1 / R_total
    }

    // Helper function to calculate basement U-value
    function calculateBasementUValue(
      hasInsulation: boolean,
      insulationThickness: number,
      insulationType: string
    ): number {
      const R_si = 0.17 // Internal surface resistance for floors (m²K/W)
      const R_se = 0.04 // External surface resistance (m²K/W)

      // Base basement slab resistance
      const R_slab = 0.20

      // Insulation resistance
      let R_insulation = 0
      if (hasInsulation && insulationThickness > 0) {
        const insulationLambda = INSULATION_LAMBDA[insulationType] || 0.04
        R_insulation = (insulationThickness / 100) / insulationLambda
      }

      const R_total = R_si + R_slab + R_insulation + R_se
      return 1 / R_total
    }

    // Helper function to calculate total energy from Consultant Mode (energy_consumption_table)
    function calculateTotalEnergyFromConsultantMode(): number | null {
      console.log('=== CONSULTANT MODE: Energy Consumption Table ===')

      // Get energy_consumption_table answer
      const energyTableAnswer = getSurveyAnswer('energy_consumption_table')

      if (!energyTableAnswer || typeof energyTableAnswer !== 'object') {
        console.log('❌ energy_consumption_table not found or invalid')
        return null
      }

      console.log('✅ energy_consumption_table found')

      // Check if total_annual_consumption row exists
      const totalAnnualConsumption = energyTableAnswer['total_annual_consumption']

      if (!totalAnnualConsumption || typeof totalAnnualConsumption !== 'object') {
        console.log('❌ total_annual_consumption row not found')
        return null
      }

      console.log('✅ total_annual_consumption row found')
      console.log('Energy carriers:')

      let totalGJ = 0

      // Iterate through each energy carrier column
      for (const [energyCarrier, value] of Object.entries(totalAnnualConsumption)) {
        const consumption = parseFloat(String(value)) || 0
        if (consumption === 0) {
          console.log(`  - ${energyCarrier}: 0 (skipped)`)
          continue
        }

        // Get heating value for this energy carrier
        const heatingValueMJ = HEATING_VALUES[energyCarrier]
        if (!heatingValueMJ) {
          console.warn(`  ⚠️ Unknown energy carrier: ${energyCarrier}`)
          continue
        }

        // Convert to GJ: consumption × heatingValue (MJ) × 0.001 (MJ to GJ)
        const energyGJ = consumption * heatingValueMJ * ENERGY_CONSTANTS.MJ_TO_GJ
        totalGJ += energyGJ

        console.log(`  - ${energyCarrier}: ${consumption} units × ${heatingValueMJ} MJ/unit = ${energyGJ.toFixed(3)} GJ`)
      }

      console.log(`📊 Total from Consultant Mode: ${totalGJ.toFixed(3)} GJ`)

      // Return null if no data found (will fallback to architectural calculation)
      return totalGJ > 0 ? totalGJ : null
    }

    // Helper function to calculate theoretical heating energy loss
    function calculateTheoreticalTotalHeatingEnergy(): number {
      console.log('\n=== ARCHITECTURAL CALCULATION: Detailed Heat Loss ===')

      // Get internal temperature from survey answers
      const internalTemp = parseFloat(getSurveyAnswer('internal_temperature')) || 20
      const temperatureDifference = internalTemp - ENERGY_CONSTANTS.AVERAGE_OUTSIDE_TEMP

      console.log(`🌡️  Internal temperature: ${internalTemp}°C`)
      console.log(`🌡️  Temperature difference: ${temperatureDifference}°C`)

      let totalGJ = 0

      // 1. Wall heat loss
      console.log('\n📐 WALL HEAT LOSS CALCULATION')
      // Calculate from survey answers (wall types 0-4)
      // Get total wall area from scenario components if available, otherwise estimate
      let totalWallArea = 0

      const wallComponents = scenarioComponents?.filter(sc =>
        sc.main_component?.persist_name?.includes('wall') ||
        sc.main_component?.category?.persist_name === 'walls'
      ) || []

      // Sum wall areas from components
      for (const wallComp of wallComponents) {
        totalWallArea += parseFloat(wallComp.quantity?.toString() || '0')
      }

      // If no wall area in components, estimate from floor area
      if (totalWallArea === 0) {
        const floorArea = parseFloat(getSurveyAnswer('floor_nm_ground')) || 0
        console.log(`  floor_nm_ground: ${floorArea} m²`)

        if (floorArea > 0) {
          // Estimate: assuming square house, perimeter = 4 × sqrt(area)
          // Average wall height = 2.8m (typical)
          const perimeter = 4 * Math.sqrt(floorArea)
          const avgHeight = 2.8
          totalWallArea = perimeter * avgHeight
          console.log(`  ✅ Estimated wall area: ${totalWallArea.toFixed(2)} m² (from floor area)`)
        } else {
          console.log(`  ❌ No floor area data - cannot estimate wall area`)
        }
      } else {
        console.log(`  ✅ Wall area from components: ${totalWallArea.toFixed(2)} m²`)
      }

      // Process each wall surface type (0-4) from survey answers
      let wallGJ = 0
      for (let i = 0; i < 5; i++) {
        const materialType = getSurveyAnswer(`wall_material_type_${i}`)
        const thickness = parseFloat(getSurveyAnswer(`wall_surface_thickness_${i}`)) || 0
        const areaRatio = parseFloat(getSurveyAnswer(`wall_area_ratio_${i}`)) || 0
        const hasInsulation = getSurveyAnswer(`wall_thermal_insulation_${i}`) === true || getSurveyAnswer(`wall_thermal_insulation_${i}`) === 'true'
        const insulationThickness = parseFloat(getSurveyAnswer(`wall_thermal_insulation_thickness_${i}`)) || 0
        const insulationType = getSurveyAnswer(`wall_thermal_insulation_type_${i}`) || 'EPS'

        console.log(`\n  Wall type ${i}:`)
        console.log(`    - wall_material_type_${i}: ${materialType || '(empty)'}`)
        console.log(`    - wall_surface_thickness_${i}: ${thickness} cm`)
        console.log(`    - wall_area_ratio_${i}: ${areaRatio}%`)
        console.log(`    - wall_thermal_insulation_${i}: ${hasInsulation}`)
        console.log(`    - wall_thermal_insulation_thickness_${i}: ${insulationThickness} cm`)
        console.log(`    - wall_thermal_insulation_type_${i}: ${insulationType}`)

        if (!materialType || thickness === 0 || areaRatio === 0 || totalWallArea === 0) {
          console.log(`    ⏭️  Skipped (missing data)`)
          continue // Skip this wall surface if no data
        }

        // Calculate U-value for this wall type
        const uValue = calculateWallUValue(materialType, thickness, hasInsulation, insulationThickness, insulationType)

        // Calculate area for this wall surface (from ratio)
        const area = totalWallArea * (areaRatio / 100)

        // Calculate heat loss for this wall
        const kWh = (area * uValue * temperatureDifference * ENERGY_CONSTANTS.ANNUAL_HEATING_DURATION) / 1000
        const gj = (kWh * 3.6) / 1000
        const gjPrimary = gj / ENERGY_CONSTANTS.EFFICIENCY_FACTOR_PRIMARY
        totalGJ += gjPrimary
        wallGJ += gjPrimary

        console.log(`    ✅ U-value: ${uValue.toFixed(3)} W/(m²K)`)
        console.log(`    ✅ Area: ${area.toFixed(2)} m²`)
        console.log(`    ✅ Heat loss: ${gjPrimary.toFixed(3)} GJ/year`)
      }

      console.log(`\n  📊 Total wall heat loss: ${wallGJ.toFixed(3)} GJ`)

      // 2. Roof heat loss
      console.log('\n🏠 ROOF HEAT LOSS CALCULATION')
      // Get roof data from survey answers
      const roofArea = parseFloat(getSurveyAnswer('roof_average_size')) || 0
      const hasRoofInsulation = getSurveyAnswer('roof_thermal_insulation') === true || getSurveyAnswer('roof_thermal_insulation') === 'true'
      const roofInsulationThickness = parseFloat(getSurveyAnswer('roof_insulation_thickness')) || 0
      const roofInsulationType = getSurveyAnswer('roof_insulation_type') || 'EPS'

      console.log(`  - roof_average_size: ${roofArea} m²`)
      console.log(`  - roof_thermal_insulation: ${hasRoofInsulation}`)
      console.log(`  - roof_insulation_thickness: ${roofInsulationThickness} cm`)
      console.log(`  - roof_insulation_type: ${roofInsulationType}`)

      if (roofArea > 0) {
        // Calculate U-value for roof
        const roofUValue = calculateRoofUValue(hasRoofInsulation, roofInsulationThickness, roofInsulationType)

        // Calculate heat loss
        const kWh = (roofArea * roofUValue * temperatureDifference * ENERGY_CONSTANTS.ANNUAL_HEATING_DURATION) / 1000
        const gj = (kWh * 3.6) / 1000
        const gjPrimary = gj / ENERGY_CONSTANTS.EFFICIENCY_FACTOR_PRIMARY
        totalGJ += gjPrimary

        console.log(`  ✅ U-value: ${roofUValue.toFixed(3)} W/(m²K)`)
        console.log(`  ✅ Heat loss: ${gjPrimary.toFixed(3)} GJ/year`)
      } else {
        console.log(`  ⏭️  Skipped (no roof area data)`)
      }

      // 3. Floor heat loss (ground floor)
      console.log('\n🔽 FLOOR HEAT LOSS CALCULATION')
      // Get floor area from survey answers
      const floorArea = parseFloat(getSurveyAnswer('floor_nm_ground')) || 0

      console.log(`  - floor_nm_ground: ${floorArea} m²`)

      if (floorArea > 0) {
        // Use standard floor heat transfer coefficient
        const kWh = (floorArea * ENERGY_CONSTANTS.FLOOR_HEAT_TRANSFER_COEFFICIENT * temperatureDifference * ENERGY_CONSTANTS.ANNUAL_HEATING_DURATION) / 1000
        const gj = (kWh * 3.6) / 1000
        const gjPrimary = gj / ENERGY_CONSTANTS.EFFICIENCY_FACTOR_PRIMARY
        totalGJ += gjPrimary

        console.log(`  ✅ U-value: ${ENERGY_CONSTANTS.FLOOR_HEAT_TRANSFER_COEFFICIENT} W/(m²K) (standard)`)
        console.log(`  ✅ Heat loss: ${gjPrimary.toFixed(3)} GJ/year`)
      } else {
        console.log(`  ⏭️  Skipped (no floor area data)`)
      }

      // 4. Window heat loss
      console.log('\n🪟 WINDOW HEAT LOSS CALCULATION')
      // Process windows_doors repeatable rows from survey answers
      let totalWindowArea = 0
      let totalWindowHeatLoss = 0

      // Find all windows_doors answers (they have item_group)
      const windowsDoorsAnswers = surveyAnswers?.filter(a =>
        a.survey_question?.name === 'windows_doors' && a.item_group !== null
      ) || []

      console.log(`  Found ${windowsDoorsAnswers.length} window/door answers`)

      // Group by item_group
      const windowGroups = new Map<string, any>()
      for (const answer of windowsDoorsAnswers) {
        const group = answer.item_group!
        if (!windowGroups.has(group)) {
          windowGroups.set(group, {})
        }
        // Answer is a JSON object with fields: size, type, glazing, quantity
        const data = answer.answer
        if (data && typeof data === 'object') {
          Object.assign(windowGroups.get(group), data)
        }
      }

      console.log(`  Grouped into ${windowGroups.size} window groups`)

      // Calculate heat loss for each window group
      let windowIndex = 0
      for (const [group, windowData] of windowGroups) {
        windowIndex++
        const size = windowData.size
        const type = windowData.type
        const glazing = windowData.glazing
        const quantity = parseInt(windowData.quantity) || 0

        console.log(`\n  Window group ${windowIndex}:`)
        console.log(`    - size: ${size || '(empty)'}`)
        console.log(`    - type: ${type || '(empty)'}`)
        console.log(`    - glazing: ${glazing || '(empty)'}`)
        console.log(`    - quantity: ${quantity}`)

        if (!size || !type || !glazing || quantity === 0) {
          console.log(`    ⏭️  Skipped (missing data)`)
          continue
        }

        // Get area from size category
        const areaPerWindow = WINDOW_SIZE_TO_AREA[size] || 1.44 // Default to average window
        const totalArea = areaPerWindow * quantity

        // Get U-value from type and glazing
        const uValue = WINDOW_U_VALUES[type]?.[glazing] || 2.8 // Default U-value

        // Calculate heat loss
        const powerRequirement = totalArea * uValue * temperatureDifference
        const fuelConsumptionGj = (powerRequirement * ENERGY_CONSTANTS.ANNUAL_HEATING_DURATION * 3.6) / 1000
        const heatLoss = fuelConsumptionGj / ENERGY_CONSTANTS.WINDOW_EFFICIENCY_FACTOR
        totalWindowHeatLoss += heatLoss

        totalWindowArea += totalArea

        console.log(`    ✅ Area per window: ${areaPerWindow} m²`)
        console.log(`    ✅ Total area: ${totalArea.toFixed(2)} m²`)
        console.log(`    ✅ U-value: ${uValue.toFixed(3)} W/(m²K)`)
        console.log(`    ✅ Heat loss: ${heatLoss.toFixed(3)} GJ/year`)
      }

      totalGJ += totalWindowHeatLoss

      console.log(`\n  📊 Total window area: ${totalWindowArea.toFixed(2)} m²`)
      console.log(`  📊 Total window heat loss: ${totalWindowHeatLoss.toFixed(3)} GJ`)

      // 5. Basement heat loss (if has basement)
      console.log('\n⬇️  BASEMENT HEAT LOSS CALCULATION')
      const hasBasement = getSurveyAnswer('has_basement') === true || getSurveyAnswer('has_basement') === 'true'

      console.log(`  - has_basement: ${hasBasement}`)

      if (hasBasement) {
        const basementArea = parseFloat(getSurveyAnswer('floor_nm_basement')) || 0
        const hasBasementInsulation = getSurveyAnswer('basement_slab_thermal_insulation') === true || getSurveyAnswer('basement_slab_thermal_insulation') === 'true'
        const basementInsulationThickness = parseFloat(getSurveyAnswer('basement_slab_thickness')) || 0
        const basementInsulationType = getSurveyAnswer('basement_slab_type') || 'EPS'

        console.log(`  - floor_nm_basement: ${basementArea} m²`)
        console.log(`  - basement_slab_thermal_insulation: ${hasBasementInsulation}`)
        console.log(`  - basement_slab_thickness: ${basementInsulationThickness} cm`)
        console.log(`  - basement_slab_type: ${basementInsulationType}`)

        if (basementArea > 0) {
          // Calculate U-value for basement slab
          const basementUValue = calculateBasementUValue(hasBasementInsulation, basementInsulationThickness, basementInsulationType)

          // Calculate heat loss
          const kWh = (basementArea * basementUValue * temperatureDifference * ENERGY_CONSTANTS.ANNUAL_HEATING_DURATION) / 1000
          const gj = (kWh * 3.6) / 1000
          const gjPrimary = gj / ENERGY_CONSTANTS.EFFICIENCY_FACTOR_PRIMARY
          totalGJ += gjPrimary

          console.log(`  ✅ U-value: ${basementUValue.toFixed(3)} W/(m²K)`)
          console.log(`  ✅ Heat loss: ${gjPrimary.toFixed(3)} GJ/year`)
        } else {
          console.log(`  ⏭️  Skipped (no basement area data)`)
        }
      } else {
        console.log(`  ⏭️  Skipped (no basement)`)
      }

      console.log(`\n📊 TOTAL THEORETICAL HEATING ENERGY: ${totalGJ.toFixed(3)} GJ`)

      return Math.max(totalGJ, 0.1) // Minimum 0.1 GJ to avoid division by zero
    }

    // 6. Calculate theoretical total heating energy
    console.log('\n\n╔════════════════════════════════════════════════╗')
    console.log('║  THEORETICAL TOTAL HEATING ENERGY CALCULATION  ║')
    console.log('╚════════════════════════════════════════════════╝')

    // IMPORTANT: We MUST use Consultant Mode (energy_consumption_table) for percentage calculation
    // Using architectural calculation leads to incorrect percentages (often >100%)
    // as it calculates theoretical heat loss, not actual energy consumption
    let theoreticalTotalHeatingEnergyGJ = calculateTotalEnergyFromConsultantMode()
    let usedConsultantMode = theoreticalTotalHeatingEnergyGJ !== null
    const warnings: string[] = []

    if (theoreticalTotalHeatingEnergyGJ === null) {
      console.log('\n❌ CRITICAL: Consultant Mode data (energy_consumption_table) is REQUIRED for percentage calculation!')
      console.log('   The architectural calculation is NOT suitable for percentage calculation.')
      console.log('   Running architectural calculation for diagnostic purposes only...\n')

      // Run architectural calculation for diagnostic purposes only
      const architecturalGJ = calculateTheoreticalTotalHeatingEnergy()

      console.log(`\n⚠️  Architectural calculation result: ${architecturalGJ.toFixed(3)} GJ`)
      console.log('   This value is NOT used for percentage calculation.')
      console.log('   Please fill in the energy_consumption_table to get accurate percentages.\n')

      // Use a reasonable minimum to avoid division by zero, but flag this
      theoreticalTotalHeatingEnergyGJ = architecturalGJ
      console.log(`⚠️  Using architectural calculation as fallback (NOT RECOMMENDED)`)

      warnings.push('Az energia megtakarítási százalékok PONTATLANOK! Az "Energiafogyasztás" táblázat kitöltése szükséges a pontos számításhoz.')
      warnings.push('Az építészeti számítás (fal, tető, padló hőveszteség) NEM alkalmas százalék számításra, mert az elméleti hőveszteséget használja, nem a valós energiafogyasztást.')
    }

    console.log('\n\n╔════════════════════════════════════════════════╗')
    console.log(`║  FINAL THEORETICAL TOTAL: ${theoreticalTotalHeatingEnergyGJ.toFixed(3)} GJ       ║`)
    console.log(`║  Method: ${usedConsultantMode ? 'CONSULTANT MODE ✅' : 'ARCHITECTURAL ⚠️'}        ║`)
    console.log('╚════════════════════════════════════════════════╝')

    // 7. Calculate energy savings per investment
    console.log('\n\n╔════════════════════════════════════════════════╗')
    console.log('║      INVESTMENT ENERGY SAVINGS CALCULATION     ║')
    console.log('╚════════════════════════════════════════════════╝')
    const perInvestment: { [key: string]: EnergySavingsPerInvestment } = {}

    for (const si of scenarioInvestments || []) {
      const investment = si.investment
      const persistName = investment.persist_name

      console.log(`\n\n━━━ Investment: ${investment.name} (${persistName}) ━━━`)

      // Map persist_name to component persist_name
      let componentPersistName = ''
      let investmentKey = ''

      if (persistName === 'facadeInsulation') {
        componentPersistName = 'default-facade-insulation'
        investmentKey = 'facadeInsulation'
      } else if (persistName === 'roofInsulation') {
        componentPersistName = 'default-roof-insulation'
        investmentKey = 'roofInsulation'
      } else if (persistName === 'windows') {
        componentPersistName = 'window-surface-area'
        investmentKey = 'windows'
      } else if (persistName === 'heatPump') {
        // Heat pump uses multiple possible persist_names
        investmentKey = 'heatPump'
      }

      if (!investmentKey) {
        console.log(`⏭️  Skipped - unknown investment type`)
        continue
      }

      console.log(`Investment key: ${investmentKey}`)

      // Find the component for this investment
      console.log(`\nSearching for component with persist_name: ${componentPersistName}`)

      const component = scenarioComponents?.find(sc => {
        if (investmentKey === 'heatPump') {
          // Heat pump components have persist_name like 'hp-unit-004' or 'heatpump-air-water-10kw'
          return sc.main_component?.persist_name?.startsWith('hp-') ||
                 sc.main_component?.persist_name?.startsWith('heatpump-')
        } else if (investmentKey === 'windows') {
          // Window components have persist_name like 'window-001' or 'window-surface-area'
          return sc.main_component?.persist_name?.startsWith('window-')
        }
        return sc.main_component?.persist_name === componentPersistName
      })

      if (component) {
        console.log(`✅ Component found: ${component.main_component?.name} (persist_name: ${component.main_component?.persist_name})`)
        console.log(`   Quantity: ${component.quantity}`)
      } else {
        console.log(`❌ Component not found in scenario_main_components`)
      }

      // Get quantity from component OR fallback to survey answers (Consultant Mode)
      let quantity = 0
      let capacityKw = 0

      if (component && component.quantity && component.quantity > 0) {
        // Use component quantity if available
        quantity = parseFloat(component.quantity.toString())
        console.log(`✅ Using quantity from component: ${quantity}`)

        if (investmentKey === 'heatPump' && component.main_component?.power) {
          capacityKw = Math.round(component.main_component.power / 1000)
          console.log(`✅ Heat pump capacity: ${capacityKw} kW`)
        }
      } else {
        console.log(`⚠️  No component quantity, trying fallback from survey answers...`)

        // Fallback to survey answers (Consultant Mode)
        if (investmentKey === 'facadeInsulation') {
          // Calculate total wall area from survey answers
          const floorArea = parseFloat(getSurveyAnswer('floor_nm_ground')) || 0
          console.log(`  - floor_nm_ground: ${floorArea} m²`)

          if (floorArea > 0) {
            // Estimate: assuming square house, perimeter = 4 × sqrt(area)
            // Average wall height = 2.8m (typical)
            const perimeter = 4 * Math.sqrt(floorArea)
            const avgHeight = 2.8
            quantity = perimeter * avgHeight
            console.log(`  ✅ Estimated wall area: ${quantity.toFixed(2)} m²`)
          } else {
            console.log(`  ❌ Cannot estimate - no floor area`)
          }
        } else if (investmentKey === 'roofInsulation') {
          // Get roof area from survey answers
          quantity = parseFloat(getSurveyAnswer('roof_average_size')) || 0
          console.log(`  - roof_average_size: ${quantity} m²`)
        } else if (investmentKey === 'windows') {
          // Calculate total window area from windows_doors repeatable rows
          const windowsDoorsAnswers = surveyAnswers?.filter(a =>
            a.survey_question?.name === 'windows_doors' && a.item_group !== null
          ) || []

          console.log(`  - Found ${windowsDoorsAnswers.length} window/door answers`)

          const windowGroups = new Map<string, any>()
          for (const answer of windowsDoorsAnswers) {
            const group = answer.item_group!
            if (!windowGroups.has(group)) {
              windowGroups.set(group, {})
            }
            const data = answer.answer
            if (data && typeof data === 'object') {
              Object.assign(windowGroups.get(group), data)
            }
          }

          let totalWindowArea = 0
          for (const [group, windowData] of windowGroups) {
            const size = windowData.size
            const windowQuantity = parseInt(windowData.quantity) || 0
            if (size && windowQuantity > 0) {
              const areaPerWindow = WINDOW_SIZE_TO_AREA[size] || 1.44
              totalWindowArea += areaPerWindow * windowQuantity
            }
          }
          quantity = totalWindowArea
          console.log(`  ✅ Total window area from survey: ${quantity.toFixed(2)} m²`)
        } else if (investmentKey === 'heatPump') {
          // Use default capacity for heat pump (12 kW typical for residential)
          capacityKw = 12
          quantity = 1 // Just a flag to indicate heat pump is present
          console.log(`  ⚠️  Using default capacity: ${capacityKw} kW`)
        }
      }

      if (quantity === 0 && investmentKey !== 'heatPump') {
        // No data for this investment, skip
        console.log(`❌ No quantity data available - SKIPPING`)
        continue
      }

      console.log(`\n📊 Final quantity: ${quantity}`)

      // Calculate GJ/kWh based on investment type
      // Simplified model based on OFP formulas but using area/capacity directly
      console.log(`\n💰 CALCULATING SAVINGS:`)

      let annualHeatingSavingsGJ = 0
      let annualHeatingSavingsKWh = 0
      let savingsPercentage = 0

      if (investmentKey === 'facadeInsulation') {
        // Facade insulation: ~0.26 GJ/m²/year (based on OFP averages)
        // Formula simplified from: performanceReduction × ANNUAL_HEATING_DURATION × 3.6 / 1000
        const gjPerM2 = 0.26
        annualHeatingSavingsGJ = quantity * gjPerM2
        annualHeatingSavingsKWh = annualHeatingSavingsGJ * ENERGY_CONSTANTS.GJ_TO_KWH
        console.log(`  Formula: ${quantity.toFixed(2)} m² × ${gjPerM2} GJ/m²/year = ${annualHeatingSavingsGJ.toFixed(3)} GJ`)
      } else if (investmentKey === 'roofInsulation') {
        // Roof insulation: ~0.28 GJ/m²/year (based on OFP averages)
        const gjPerM2 = 0.28
        annualHeatingSavingsGJ = quantity * gjPerM2
        annualHeatingSavingsKWh = annualHeatingSavingsGJ * ENERGY_CONSTANTS.GJ_TO_KWH
        console.log(`  Formula: ${quantity.toFixed(2)} m² × ${gjPerM2} GJ/m²/year = ${annualHeatingSavingsGJ.toFixed(3)} GJ`)
      } else if (investmentKey === 'windows') {
        // Windows: ~0.0086 GJ/m²/year (minimal savings)
        const gjPerM2 = 0.0086
        annualHeatingSavingsGJ = quantity * gjPerM2
        annualHeatingSavingsKWh = annualHeatingSavingsGJ * ENERGY_CONSTANTS.GJ_TO_KWH
        console.log(`  Formula: ${quantity.toFixed(2)} m² × ${gjPerM2} GJ/m²/year = ${annualHeatingSavingsGJ.toFixed(3)} GJ`)
      } else if (investmentKey === 'heatPump') {
        // Heat pump: capacity-based calculation ~0.116 GJ per kW
        // Use capacityKw from component or fallback (already set above)
        if (capacityKw === 0) {
          capacityKw = component?.main_component?.power
            ? Math.round(component.main_component.power / 1000)
            : 12
          console.log(`  ⚠️  Using fallback capacity: ${capacityKw} kW`)
        }
        annualHeatingSavingsGJ = capacityKw * 0.116
        annualHeatingSavingsKWh = annualHeatingSavingsGJ * ENERGY_CONSTANTS.GJ_TO_KWH
        console.log(`  Formula: ${capacityKw} kW × 0.116 GJ/kW = ${annualHeatingSavingsGJ.toFixed(3)} GJ`)
      }

      // Calculate percentage based on theoretical total heating energy
      savingsPercentage = theoreticalTotalHeatingEnergyGJ > 0
        ? (annualHeatingSavingsGJ / theoreticalTotalHeatingEnergyGJ) * 100
        : 0

      console.log(`  ✅ Annual heating savings: ${annualHeatingSavingsGJ.toFixed(3)} GJ (${annualHeatingSavingsKWh} kWh)`)
      console.log(`  ✅ Percentage: ${savingsPercentage.toFixed(1)}% (${annualHeatingSavingsGJ.toFixed(3)} / ${theoreticalTotalHeatingEnergyGJ.toFixed(3)} GJ)`)

      perInvestment[investmentKey] = {
        annualHeatingSavingsGJ: Math.round(annualHeatingSavingsGJ * 1000) / 1000,
        annualHeatingSavingsKWh: Math.round(annualHeatingSavingsKWh),
        savingsPercentage: Math.round(savingsPercentage * 10) / 10,
        actualArea: investmentKey !== 'heatPump' ? quantity : undefined,
        capacity: investmentKey === 'heatPump' ? capacityKw : undefined,
      }
    }

    // 8. Calculate KEHOP summary
    console.log('\n\n╔════════════════════════════════════════════════╗')
    console.log('║           KEHOP SUMMARY CALCULATION            ║')
    console.log('╚════════════════════════════════════════════════╝')

    let totalGJ = 0
    let totalKWh = 0
    let totalPercentage = 0

    for (const [key, data] of Object.entries(perInvestment)) {
      console.log(`\n${key}:`)
      console.log(`  - GJ: ${data.annualHeatingSavingsGJ}`)
      console.log(`  - kWh: ${data.annualHeatingSavingsKWh}`)
      console.log(`  - Percentage: ${data.savingsPercentage}%`)

      totalGJ += data.annualHeatingSavingsGJ
      totalKWh += data.annualHeatingSavingsKWh
      totalPercentage += data.savingsPercentage
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log(`📊 TOTAL GJ: ${totalGJ.toFixed(3)}`)
    console.log(`📊 TOTAL kWh: ${totalKWh}`)
    console.log(`📊 TOTAL Percentage: ${totalPercentage.toFixed(1)}%`)
    console.log(`📊 Meets 30% KEHOP requirement: ${totalPercentage >= 30 ? '✅ YES' : '❌ NO'}`)

    const kehopSummary: KEHOPSummary = {
      totalGJ: Math.round(totalGJ * 1000) / 1000,
      totalKWh: Math.round(totalKWh),
      totalPercentage: Math.round(totalPercentage * 10) / 10,
      meets30Percent: totalPercentage >= 30,
    }

    // 9. Build result
    const result: EnergySavingsResult = {
      perInvestment,
      kehopSummary,
      theoreticalTotalHeatingEnergyGJ: Math.round(theoreticalTotalHeatingEnergyGJ * 1000) / 1000,
      calculatedAt: new Date().toISOString(),
      usedConsultantMode,
      warnings: warnings.length > 0 ? warnings : undefined,
    }

    // 10. Store result in scenario
    const { error: updateError } = await supabaseAdmin
      .from('scenarios')
      .update({ energy_savings: result })
      .eq('id', body.scenarioId)

    if (updateError) {
      console.error('Failed to store energy savings:', updateError)
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to store calculation result',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 11. Return result
    return new Response(
      JSON.stringify({
        success: true,
        scenarioId: body.scenarioId,
        energySavings: result,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Energy savings calculation error:', error)

    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
