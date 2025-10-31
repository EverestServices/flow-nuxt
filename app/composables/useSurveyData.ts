import { ref } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import { useScenariosStore } from '~/stores/scenarios'
import { useContractsStore } from '~/stores/contracts'

/**
 * Composable for loading and managing survey data with all related entities
 * This uses a single optimized query to fetch all related data at once
 */
export function useSurveyData() {
  const supabase = useSupabaseClient()
  const investmentsStore = useSurveyInvestmentsStore()
  const scenariosStore = useScenariosStore()
  const contractsStore = useContractsStore()

  const loading = ref(false)
  const error = ref<Error | null>(null)

  /**
   * Load all survey data with a single optimized query
   */
  async function loadSurveyWithRelations(surveyId: string) {
    loading.value = true
    error.value = null

    try {
      const { data: survey, error: fetchError } = await supabase
        .from('surveys')
        .select(`
          *,
          client:clients (
            id,
            name,
            email,
            phone,
            postal_code,
            city,
            street,
            house_number,
            contact_person,
            notes,
            status
          ),

          scenarios (
            *,
            scenario_investments (
              investment_id
            ),
            scenario_main_components (
              id,
              scenario_id,
              main_component_id,
              investment_id,
              quantity,
              price_snapshot
            )
          ),

          contracts (
            *,
            contract_investments (
              investment_id
            ),
            contract_main_components (
              id,
              contract_id,
              main_component_id,
              investment_id,
              quantity,
              price_snapshot
            ),
            contract_extra_costs (
              id,
              contract_id,
              extra_cost_id,
              snapshot_price,
              quantity,
              comment
            ),
            contract_discounts (
              id,
              contract_id,
              discount_id,
              discount_snapshot
            )
          ),

          survey_investments (
            survey_id,
            investment_id
          ),

          electric_cars (
            id,
            survey_id,
            annual_mileage,
            status
          ),

          survey_heavy_consumers (
            survey_id,
            heavy_consumer_id,
            status
          )
        `)
        .eq('id', surveyId)
        .single()

      if (fetchError) throw fetchError

      if (survey) {
        // Hydrate stores with the fetched data
        await hydrateSurveyData(survey, surveyId)
        return survey
      }

      return null
    } catch (err) {
      error.value = err as Error
      console.error('Error loading survey with relations:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  /**
   * Hydrate stores with the fetched survey data
   */
  async function hydrateSurveyData(survey: any, surveyId: string) {
    // Set scenarios
    if (survey.scenarios && survey.scenarios.length > 0) {
      scenariosStore.scenarios = survey.scenarios.map((s: any) => ({
        id: s.id,
        survey_id: s.survey_id,
        name: s.name,
        sequence: s.sequence,
        description: s.description,
        created_at: s.created_at,
        updated_at: s.updated_at
      }))

      // Set first scenario as active if not already set
      if (!scenariosStore.activeScenarioId && scenariosStore.scenarios.length > 0) {
        scenariosStore.activeScenarioId = scenariosStore.scenarios[0].id
      }

      // Group scenario investments by scenario_id
      scenariosStore.scenarioInvestments = {}
      survey.scenarios.forEach((scenario: any) => {
        const investmentIds = scenario.scenario_investments?.map((si: any) => si.investment_id) || []
        scenariosStore.scenarioInvestments[scenario.id] = investmentIds
      })

      // Group scenario main components by scenario_id
      scenariosStore.scenarioComponents = {}
      survey.scenarios.forEach((scenario: any) => {
        const components = scenario.scenario_main_components || []
        scenariosStore.scenarioComponents[scenario.id] = components
      })
    } else {
      scenariosStore.scenarios = []
      scenariosStore.scenarioInvestments = {}
      scenariosStore.scenarioComponents = {}
    }

    // Set contracts
    if (survey.contracts && survey.contracts.length > 0) {
      contractsStore.contracts = survey.contracts.map((c: any) => ({
        id: c.id,
        survey_id: c.survey_id,
        scenario_id: c.scenario_id,
        name: c.name,
        contract_mode: c.contract_mode,
        commission_rate: c.commission_rate,
        vat: c.vat,
        total_price: c.total_price,
        roof_configuration: c.roof_configuration,
        notes: c.notes,
        status: c.status,
        first_sent_at: c.first_sent_at,
        first_signed_at: c.first_signed_at,
        created_at: c.created_at,
        updated_at: c.updated_at
      }))

      // Set first contract as active if not already set
      if (!contractsStore.activeContractId && contractsStore.contracts.length > 0) {
        contractsStore.activeContractId = contractsStore.contracts[0].id
      }

      // Group contract investments by contract_id
      contractsStore.contractInvestments = {}
      survey.contracts.forEach((contract: any) => {
        const investmentIds = contract.contract_investments?.map((ci: any) => ci.investment_id) || []
        contractsStore.contractInvestments[contract.id] = investmentIds
      })

      // Group contract main components by contract_id
      contractsStore.contractMainComponents = {}
      survey.contracts.forEach((contract: any) => {
        const components = contract.contract_main_components || []
        contractsStore.contractMainComponents[contract.id] = components
      })

      // Group contract extra costs by contract_id
      contractsStore.contractExtraCosts = {}
      survey.contracts.forEach((contract: any) => {
        const extraCosts = contract.contract_extra_costs || []
        contractsStore.contractExtraCosts[contract.id] = extraCosts
      })

      // Group contract discounts by contract_id
      contractsStore.contractDiscounts = {}
      survey.contracts.forEach((contract: any) => {
        const discounts = contract.contract_discounts || []
        contractsStore.contractDiscounts[contract.id] = discounts
      })
    } else {
      contractsStore.contracts = []
      contractsStore.contractInvestments = {}
      contractsStore.contractMainComponents = {}
      contractsStore.contractExtraCosts = {}
      contractsStore.contractDiscounts = {}
    }

    // Set survey investments (selected investments)
    if (survey.survey_investments && survey.survey_investments.length > 0) {
      investmentsStore.selectedInvestmentIds = survey.survey_investments.map((si: any) => si.investment_id)

      // Load investment data (pages, questions, document categories)
      if (investmentsStore.selectedInvestmentIds.length > 0) {
        await investmentsStore.loadInvestmentData(investmentsStore.selectedInvestmentIds)

        // Set first investment and page as active if not already set
        if (!investmentsStore.activeInvestmentId && investmentsStore.selectedInvestmentIds.length > 0) {
          investmentsStore.activeInvestmentId = investmentsStore.selectedInvestmentIds[0]
          const pages = investmentsStore.surveyPages[investmentsStore.activeInvestmentId]
          if (pages && pages.length > 0) {
            investmentsStore.activePageId = pages[0].id
          }
        }
      }
    } else {
      investmentsStore.selectedInvestmentIds = []
    }

    // Load main components data (needed for all stores)
    await scenariosStore.loadMainComponentsData()
  }

  /**
   * Refresh survey data after an operation (scenario/contract save/delete/duplicate)
   */
  async function refreshSurveyData(surveyId: string) {
    return await loadSurveyWithRelations(surveyId)
  }

  return {
    loading,
    error,
    loadSurveyWithRelations,
    refreshSurveyData
  }
}
