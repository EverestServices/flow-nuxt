import { getAllScenarioTypes, getScenarioDisplayName, getScenarioDescription, getScenarioConfig, getBaseQuantities, calculateQuantity, type ScenarioType } from '~/utils/scenarioGenerator'

interface Investment {
  id: string
  name: string
}

interface MainComponentCategory {
  id: string
  persist_name: string
  sequence: number
}

interface MainComponent {
  id: string
  name: string
  persist_name: string
  unit: string
  price: number
  main_component_category_id: string
  sequence: number
}

/**
 * Composable for creating AI scenarios
 */
export const useScenarioCreation = () => {
  const supabase = useSupabaseClient()

  /**
   * Creates 3 AI scenarios (Optimum, Minimum, Premium) for selected investments
   */
  const createAIScenarios = async (
    surveyId: string,
    selectedInvestmentIds: string[]
  ) => {
    try {
      // 1. Fetch investments with their names
      const { data: investments, error: investmentsError } = await supabase
        .from('investments')
        .select('id, name')
        .in('id', selectedInvestmentIds)

      if (investmentsError) throw investmentsError
      if (!investments) throw new Error('No investments found')

      // 2. Get existing scenarios count for sequence numbering
      const { data: existingScenarios, error: countError } = await supabase
        .from('scenarios')
        .select('sequence')
        .eq('survey_id', surveyId)
        .order('sequence', { ascending: false })
        .limit(1)

      if (countError) throw countError

      const startSequence = existingScenarios && existingScenarios.length > 0
        ? (existingScenarios[0].sequence || 0) + 1
        : 1

      // 3. Create 3 scenarios
      const scenarioTypes = getAllScenarioTypes()
      const scenariosToCreate = scenarioTypes.map((type, index) => ({
        survey_id: surveyId,
        name: getScenarioDisplayName(type, startSequence + index),
        sequence: startSequence + index,
        description: getScenarioDescription(type)
      }))

      const { data: createdScenarios, error: scenariosError } = await supabase
        .from('scenarios')
        .insert(scenariosToCreate)
        .select()

      if (scenariosError) throw scenariosError
      if (!createdScenarios) throw new Error('Failed to create scenarios')

      // 4. For each scenario, create scenario_investments and scenario_main_components
      for (let i = 0; i < createdScenarios.length; i++) {
        const scenario = createdScenarios[i]
        const scenarioType = scenarioTypes[i]

        // Insert scenario-investment relationships
        const scenarioInvestments = selectedInvestmentIds.map(investmentId => ({
          scenario_id: scenario.id,
          investment_id: investmentId
        }))

        const { error: siError } = await supabase
          .from('scenario_investments')
          .insert(scenarioInvestments)

        if (siError) throw siError

        // Create main components for each investment
        await createScenarioMainComponents(
          scenario.id,
          investments as Investment[],
          scenarioType
        )
      }

      return {
        success: true,
        scenarios: createdScenarios
      }
    } catch (error) {
      console.error('Error creating AI scenarios:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  /**
   * Creates main component records for a scenario
   */
  const createScenarioMainComponents = async (
    scenarioId: string,
    investments: Investment[],
    scenarioType: ScenarioType
  ) => {
    const config = getScenarioConfig(scenarioType)

    // Get all main component categories with their investments
    const { data: categoryInvestments, error: ciError } = await supabase
      .from('main_component_category_investments')
      .select(`
        main_component_category_id,
        investment_id,
        sequence,
        main_component_categories:main_component_category_id (
          id,
          persist_name,
          sequence
        )
      `)
      .in('investment_id', investments.map(inv => inv.id))
      .order('sequence')

    if (ciError) throw ciError
    if (!categoryInvestments) return

    // Get all main components
    const categoryIds = [...new Set(categoryInvestments.map(ci => ci.main_component_category_id))]
    const { data: allComponents, error: componentsError } = await supabase
      .from('main_components')
      .select('*')
      .in('main_component_category_id', categoryIds)
      .order('sequence')

    if (componentsError) throw componentsError
    if (!allComponents) return

    // Collect components to insert
    const componentsToInsert: any[] = []

    // For each investment, select components
    for (const investment of investments) {
      const baseQuantities = getBaseQuantities(investment.name)

      // Get categories for this investment
      const investmentCategories = categoryInvestments.filter(
        ci => ci.investment_id === investment.id
      )

      for (const catInv of investmentCategories) {
        const category = catInv.main_component_categories as unknown as MainComponentCategory
        if (!category) continue

        const categoryKey = category.persist_name
        const baseQuantity = baseQuantities[categoryKey]

        if (!baseQuantity) continue

        // Get components for this category
        const categoryComponents = allComponents.filter(
          c => c.main_component_category_id === category.id
        ) as MainComponent[]

        if (categoryComponents.length === 0) continue

        // Select component based on quality level
        const selectedComponent = selectComponentByQuality(
          categoryComponents,
          config.qualityLevel,
          config.preferredBrands
        )

        if (!selectedComponent) continue

        // Calculate quantity
        const quantity = calculateQuantity(baseQuantity, scenarioType)

        // Add component with investment_id
        componentsToInsert.push({
          scenario_id: scenarioId,
          main_component_id: selectedComponent.id,
          investment_id: investment.id,
          quantity,
          price_snapshot: selectedComponent.price
        })
      }
    }

    // Insert all components
    if (componentsToInsert.length > 0) {
      const { error: insertError } = await supabase
        .from('scenario_main_components')
        .insert(componentsToInsert)

      if (insertError) throw insertError
    }
  }

  /**
   * Selects a component based on quality level
   */
  const selectComponentByQuality = (
    components: MainComponent[],
    qualityLevel: 'high' | 'medium' | 'low',
    preferredBrands?: string[]
  ): MainComponent | null => {
    if (components.length === 0) return null
    if (components.length === 1) return components[0]

    let filteredComponents = [...components]

    // Filter by preferred brands if specified
    if (preferredBrands && preferredBrands.length > 0) {
      const brandFiltered = components.filter(c =>
        preferredBrands.some(brand =>
          c.name?.toLowerCase().includes(brand.toLowerCase())
        )
      )
      if (brandFiltered.length > 0) {
        filteredComponents = brandFiltered
      }
    }

    // Select based on quality level and price
    // Components are already sorted by sequence (premium first)
    switch (qualityLevel) {
      case 'high':
        // Select first (highest quality/price based on sequence)
        return filteredComponents[0]

      case 'low':
        // Select last (lowest quality/price)
        return filteredComponents[filteredComponents.length - 1]

      case 'medium':
      default:
        // Select middle
        const middleIndex = Math.floor(filteredComponents.length / 2)
        return filteredComponents[middleIndex]
    }
  }

  return {
    createAIScenarios
  }
}
