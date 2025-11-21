import { getAllScenarioTypes, getScenarioDisplayName, getScenarioDescription, getScenarioConfig, getBaseQuantities, calculateQuantity, ScenarioType } from '~/utils/scenarioGenerator'

interface Investment {
  id: string
  name: string
  persist_name: string
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
  visibility?: {
    ofp_survey?: boolean
    [key: string]: any
  } | null
}

/**
 * Composable for creating AI scenarios
 */
export const useScenarioCreation = () => {
  const supabase = useSupabaseClient()

  /**
   * Calculates total facade area from survey answers (sum of all _facadeNetArea values)
   */
  const calculateFacadeArea = async (surveyId: string, facadeInvestmentId: string): Promise<number> => {
    try {
      // Get the "Falak" (Walls) page for Facade Insulation investment
      const { data: pages, error: pagesError } = await supabase
        .from('survey_pages')
        .select('id')
        .eq('investment_id', facadeInvestmentId)
        .eq('type', 'walls')
        .eq('name', 'Falak')
        .single()

      if (pagesError || !pages) {
        return 0
      }

      // Get question IDs for _facadeNetArea (from marker mode) OR wall_length & wall_height (manual entry)
      const { data: questions, error: questionsError } = await supabase
        .from('survey_questions')
        .select('id, name')
        .eq('survey_page_id', pages.id)
        .in('name', ['_facadeNetArea', 'wall_length', 'wall_height'])

      if (questionsError || !questions || questions.length === 0) {
        return 0
      }

      const facadeNetAreaQuestion = questions.find(q => q.name === '_facadeNetArea')
      const wallLengthQuestion = questions.find(q => q.name === 'wall_length')
      const wallHeightQuestion = questions.find(q => q.name === 'wall_height')

      // Get wall answers - only for questions on the Falak page
      const questionIds = questions.map(q => q.id)
      const { data: answers, error: answersError } = await supabase
        .from('survey_answers')
        .select('answer, survey_question_id, item_group')
        .eq('survey_id', surveyId)
        .in('survey_question_id', questionIds)
        .not('item_group', 'is', null)
        .is('parent_item_group', null)

      if (answersError || !answers) {
        return 0
      }

      let totalArea = 0

      // Strategy 1: Use _facadeNetArea if available (from marker mode)
      if (facadeNetAreaQuestion) {
        for (const answer of answers) {
          if (answer.survey_question_id === facadeNetAreaQuestion.id && answer.answer) {
            const area = parseFloat(answer.answer)
            if (!isNaN(area)) {
              totalArea += area
            }
          }
        }
      }
      // Strategy 2: Calculate from wall_length × wall_height if no marker data
      else if (wallLengthQuestion && wallHeightQuestion) {

        // Group answers by item_group to calculate area per wall
        const wallsByItemGroup: Record<number, { length?: number; height?: number }> = {}

        for (const answer of answers) {
          if (answer.item_group === null) continue

          if (!wallsByItemGroup[answer.item_group]) {
            wallsByItemGroup[answer.item_group] = {}
          }

          if (answer.survey_question_id === wallLengthQuestion.id && answer.answer) {
            wallsByItemGroup[answer.item_group].length = parseFloat(answer.answer)
          }
          if (answer.survey_question_id === wallHeightQuestion.id && answer.answer) {
            wallsByItemGroup[answer.item_group].height = parseFloat(answer.answer)
          }
        }

        // Calculate area for each wall
        for (const [itemGroup, wall] of Object.entries(wallsByItemGroup)) {
          if (wall.length && wall.height && wall.length > 0 && wall.height > 0) {
            const wallArea = wall.length * wall.height
            totalArea += wallArea
          }
        }
      }

      return totalArea
    } catch (error) {
      console.error('Error calculating facade area:', error)
      return 0
    }
  }

  /**
   * Calculates attic insulation area (calculated_surface_area - non_insulated_area)
   * OR (width × length - non_insulated_area) if manual entry
   */
  const calculateAtticArea = async (surveyId: string, atticInvestmentId: string): Promise<number> => {
    try {
      // Get the "Tetőtér adatai" page for Attic Insulation investment
      const { data: pages, error: pagesError } = await supabase
        .from('survey_pages')
        .select('id')
        .eq('investment_id', atticInvestmentId)
        .eq('name', 'Tetőtér adatai')
        .single()

      if (pagesError || !pages) {
        return 0
      }

      // Get questions for calculated_surface_area, non_insulated_area, width, and length
      const { data: questions, error: questionsError } = await supabase
        .from('survey_questions')
        .select('id, name')
        .eq('survey_page_id', pages.id)
        .in('name', ['calculated_surface_area', 'non_insulated_area', 'width', 'length'])

      if (questionsError || !questions) {
        return 0
      }

      const surfaceAreaQuestion = questions.find(q => q.name === 'calculated_surface_area')
      const nonInsulatedQuestion = questions.find(q => q.name === 'non_insulated_area')
      const widthQuestion = questions.find(q => q.name === 'width')
      const lengthQuestion = questions.find(q => q.name === 'length')

      // Get all answer values
      const questionIds = [
        surfaceAreaQuestion?.id,
        nonInsulatedQuestion?.id,
        widthQuestion?.id,
        lengthQuestion?.id
      ].filter(Boolean)

      const { data: answers, error: answersError } = await supabase
        .from('survey_answers')
        .select('answer, survey_question_id')
        .eq('survey_id', surveyId)
        .in('survey_question_id', questionIds)

      if (answersError || !answers) {
        return 0
      }

      let surfaceArea = 0
      let nonInsulatedArea = 0
      let width = 0
      let length = 0

      for (const answer of answers) {
        if (surfaceAreaQuestion && answer.survey_question_id === surfaceAreaQuestion.id && answer.answer) {
          surfaceArea = parseFloat(answer.answer) || 0
        }
        if (nonInsulatedQuestion && answer.survey_question_id === nonInsulatedQuestion.id && answer.answer) {
          nonInsulatedArea = parseFloat(answer.answer) || 0
        }
        if (widthQuestion && answer.survey_question_id === widthQuestion.id && answer.answer) {
          width = parseFloat(answer.answer) || 0
        }
        if (lengthQuestion && answer.survey_question_id === lengthQuestion.id && answer.answer) {
          length = parseFloat(answer.answer) || 0
        }
      }

      // Strategy 1: Use calculated_surface_area if available and > 0
      if (surfaceArea > 0) {
        const result = Math.max(0, surfaceArea - nonInsulatedArea)
        return result
      }
      // Strategy 2: Calculate from width × length if manual entry
      else if (width > 0 && length > 0) {
        const calculatedSurface = width * length
        const result = Math.max(0, calculatedSurface - nonInsulatedArea)
        return result
      }
      else {
        return 0
      }
    } catch (error) {
      console.error('Error calculating attic area:', error)
      return 0
    }
  }

  /**
   * Creates AI scenarios for selected investments
   * - 1 scenario (Optimum) for OFP surveys
   * - 3 scenarios (Optimum, Minimum, Premium) for regular surveys
   */
  const createAIScenarios = async (
    surveyId: string,
    selectedInvestmentIds: string[]
  ) => {
    try {
      // 1. Check if this is an OFP survey
      const { data: survey, error: surveyError } = await supabase
        .from('surveys')
        .select('ofp_survey_id')
        .eq('id', surveyId)
        .single()

      if (surveyError) throw surveyError
      const isOfpSurvey = !!(survey?.ofp_survey_id)

      // 2. Fetch investments with their names and persist_names
      const { data: investments, error: investmentsError } = await supabase
        .from('investments')
        .select('id, name, persist_name')
        .in('id', selectedInvestmentIds)

      if (investmentsError) throw investmentsError
      if (!investments) throw new Error('No investments found')

      // 3. Calculate OFP-specific quantities if this is an OFP survey
      let calculatedQuantities: Record<string, Record<string, number>> = {}

      if (isOfpSurvey) {

        for (const investment of investments) {
          const quantities: Record<string, number> = {}

          // Calculate facade area for Facade Insulation
          if (investment.persist_name === 'facadeInsulation') {
            const facadeArea = await calculateFacadeArea(surveyId, investment.id)
            if (facadeArea > 0) {
              quantities.facade_system = facadeArea
            }
          }

          // Calculate attic area for Roof/Attic Insulation
          if (investment.persist_name === 'roofInsulation') {
            const atticArea = await calculateAtticArea(surveyId, investment.id)
            if (atticArea > 0) {
              quantities.roof_system = atticArea
            }
          }

          if (Object.keys(quantities).length > 0) {
            calculatedQuantities[investment.id] = quantities
          }
        }
      }

      // 4. Get existing scenarios count for sequence numbering
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

      // 5. Create scenarios (1 for OFP surveys, 3 for regular surveys)
      const scenarioTypes = isOfpSurvey ? [ScenarioType.Optimum] : getAllScenarioTypes()

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

      // 6. For each scenario, create scenario_investments and scenario_main_components
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
          scenarioType,
          calculatedQuantities,
          isOfpSurvey
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
    scenarioType: ScenarioType,
    calculatedQuantities: Record<string, Record<string, number>> = {},
    isOfpSurvey: boolean = false
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

    // Get all main components (with visibility field)
    const categoryIds = [...new Set(categoryInvestments.map(ci => ci.main_component_category_id))]
    const { data: allComponents, error: componentsError } = await supabase
      .from('main_components')
      .select('*, visibility')
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

        // Use calculated quantity if available (for OFP surveys), otherwise use base quantity
        let baseQuantity = baseQuantities[categoryKey]
        const hasCalculatedQuantity = !!calculatedQuantities[investment.id]?.[categoryKey]

        if (hasCalculatedQuantity) {
          baseQuantity = calculatedQuantities[investment.id][categoryKey]
        }

        if (!baseQuantity) {
          continue
        }

        // Get components for this category, filtering by visibility rules
        let categoryComponents = allComponents.filter(
          c => c.main_component_category_id === category.id
        ) as MainComponent[]

        // Filter out components based on visibility rules for OFP surveys
        if (isOfpSurvey) {
          categoryComponents = categoryComponents.filter(component => {
            // If no visibility rules, component is visible
            if (!component.visibility) return true

            // Check if component should be hidden for OFP surveys
            const visibility = component.visibility as any
            if (visibility.ofp_survey === false) {
              return false
            }

            return true
          })
        }

        if (categoryComponents.length === 0) {
          continue
        }

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
