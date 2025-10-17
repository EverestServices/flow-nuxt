/**
 * useScenarios Composable
 * Handles scenario operations for surveys
 */

import type {
  Scenario,
  ScenarioWithRelations,
  InsertScenario,
  ScenarioFormData
} from '~/types/survey-new'

export const useScenarios = () => {
  const supabase = useSupabaseClient()

  // State
  const scenarios = ref<ScenarioWithRelations[]>([])
  const currentScenario = ref<ScenarioWithRelations | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Fetch scenarios for a survey
   */
  const fetchScenariosBySurvey = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('scenarios')
        .select(`
          *,
          survey:surveys(*),
          investments:scenario_investments(
            investment:investments(*)
          ),
          extra_costs:extra_cost_relations(
            extra_cost:extra_costs(*),
            snapshot_price,
            quantity
          )
        `)
        .eq('survey_id', surveyId)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError

      scenarios.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching scenarios:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch a single scenario by ID
   */
  const fetchScenarioById = async (scenarioId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('scenarios')
        .select(`
          *,
          survey:surveys(*),
          investments:scenario_investments(
            investment:investments(*)
          ),
          extra_costs:extra_cost_relations(
            extra_cost:extra_costs(*),
            snapshot_price,
            quantity
          )
        `)
        .eq('id', scenarioId)
        .single()

      if (fetchError) throw fetchError

      currentScenario.value = data
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching scenario:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Create a new scenario
   */
  const createScenario = async (scenarioData: ScenarioFormData) => {
    loading.value = true
    error.value = null

    try {
      // 1. Create scenario
      const { data: scenario, error: scenarioError } = await supabase
        .from('scenarios')
        .insert({
          survey_id: scenarioData.survey_id
        })
        .select()
        .single()

      if (scenarioError) throw scenarioError

      // 2. Link investments
      if (scenarioData.investments.length > 0) {
        const scenarioInvestments = scenarioData.investments.map(investmentId => ({
          scenario_id: scenario.id,
          investment_id: investmentId
        }))

        const { error: investmentsError } = await supabase
          .from('scenario_investments')
          .insert(scenarioInvestments)

        if (investmentsError) throw investmentsError
      }

      // 3. Link extra costs
      if (scenarioData.extra_costs.length > 0) {
        const extraCostRelations = scenarioData.extra_costs.map(ec => ({
          scenario_id: scenario.id,
          extra_cost_id: ec.id,
          snapshot_price: ec.snapshot_price,
          quantity: ec.quantity
        }))

        const { error: costsError } = await supabase
          .from('extra_cost_relations')
          .insert(extraCostRelations)

        if (costsError) throw costsError
      }

      // Fetch complete scenario
      await fetchScenarioById(scenario.id)

      return scenario
    } catch (e: any) {
      error.value = e.message
      console.error('Error creating scenario:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Delete a scenario
   */
  const deleteScenario = async (scenarioId: string) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('scenarios')
        .delete()
        .eq('id', scenarioId)

      if (deleteError) throw deleteError

      // Remove from local state
      scenarios.value = scenarios.value.filter(s => s.id !== scenarioId)
      if (currentScenario.value?.id === scenarioId) {
        currentScenario.value = null
      }

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error deleting scenario:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Add extra cost to scenario
   */
  const addExtraCost = async (
    scenarioId: string,
    extraCostId: string,
    quantity: number,
    snapshotPrice: number
  ) => {
    loading.value = true
    error.value = null

    try {
      const { error: insertError } = await supabase
        .from('extra_cost_relations')
        .insert({
          scenario_id: scenarioId,
          extra_cost_id: extraCostId,
          quantity,
          snapshot_price: snapshotPrice
        })

      if (insertError) throw insertError

      // Refresh scenario
      await fetchScenarioById(scenarioId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error adding extra cost:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Remove extra cost from scenario
   */
  const removeExtraCost = async (relationId: string) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('extra_cost_relations')
        .delete()
        .eq('id', relationId)

      if (deleteError) throw deleteError

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error removing extra cost:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    scenarios: readonly(scenarios),
    currentScenario: readonly(currentScenario),
    loading: readonly(loading),
    error: readonly(error),

    // Methods
    fetchScenariosBySurvey,
    fetchScenarioById,
    createScenario,
    deleteScenario,
    addExtraCost,
    removeExtraCost
  }
}
