/**
 * useContracts Composable
 * Handles contract operations
 */

import type {
  Contract,
  ContractWithRelations,
  InsertContract,
  UpdateContract,
  ContractFormData
} from '~/types/survey-new'

export const useContracts = () => {
  const supabase = useSupabaseClient()

  // State
  const contracts = ref<ContractWithRelations[]>([])
  const currentContract = ref<ContractWithRelations | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Fetch contracts for a survey
   */
  const fetchContractsBySurvey = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('contracts')
        .select(`
          *,
          survey:surveys(*),
          investments:contract_investments(
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

      contracts.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching contracts:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch a single contract by ID
   */
  const fetchContractById = async (contractId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('contracts')
        .select(`
          *,
          survey:surveys(*),
          investments:contract_investments(
            investment:investments(*)
          ),
          extra_costs:extra_cost_relations(
            extra_cost:extra_costs(*),
            snapshot_price,
            quantity
          )
        `)
        .eq('id', contractId)
        .single()

      if (fetchError) throw fetchError

      currentContract.value = data
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching contract:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Create a new contract
   */
  const createContract = async (contractData: ContractFormData) => {
    loading.value = true
    error.value = null

    try {
      // 1. Create contract
      const { data: contract, error: contractError } = await supabase
        .from('contracts')
        .insert({
          survey_id: contractData.survey_id,
          client_name: contractData.client_name,
          client_address: contractData.client_address,
          client_phone: contractData.client_phone,
          client_email: contractData.client_email,
          birth_place: contractData.birth_place,
          date_of_birth: contractData.date_of_birth,
          id_card_number: contractData.id_card_number,
          tax_id: contractData.tax_id,
          mother_birth_name: contractData.mother_birth_name,
          bank_account_number: contractData.bank_account_number,
          citizenship: contractData.citizenship,
          marital_status: contractData.marital_status,
          residence_card_number: contractData.residence_card_number,
          mailing_address: contractData.mailing_address
        })
        .select()
        .single()

      if (contractError) throw contractError

      // 2. Link investments
      if (contractData.investments.length > 0) {
        const contractInvestments = contractData.investments.map(investmentId => ({
          contract_id: contract.id,
          investment_id: investmentId
        }))

        const { error: investmentsError } = await supabase
          .from('contract_investments')
          .insert(contractInvestments)

        if (investmentsError) throw investmentsError
      }

      // 3. Link extra costs
      if (contractData.extra_costs.length > 0) {
        const extraCostRelations = contractData.extra_costs.map(ec => ({
          contract_id: contract.id,
          extra_cost_id: ec.id,
          snapshot_price: ec.snapshot_price,
          quantity: ec.quantity
        }))

        const { error: costsError } = await supabase
          .from('extra_cost_relations')
          .insert(extraCostRelations)

        if (costsError) throw costsError
      }

      // Fetch complete contract
      await fetchContractById(contract.id)

      return contract
    } catch (e: any) {
      error.value = e.message
      console.error('Error creating contract:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Update an existing contract
   */
  const updateContract = async (contractId: string, updates: UpdateContract) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: updateError } = await supabase
        .from('contracts')
        .update(updates)
        .eq('id', contractId)
        .select()
        .single()

      if (updateError) throw updateError

      // Refresh current contract if it's the one being updated
      if (currentContract.value?.id === contractId) {
        await fetchContractById(contractId)
      }

      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error updating contract:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Delete a contract
   */
  const deleteContract = async (contractId: string) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('contracts')
        .delete()
        .eq('id', contractId)

      if (deleteError) throw deleteError

      // Remove from local state
      contracts.value = contracts.value.filter(c => c.id !== contractId)
      if (currentContract.value?.id === contractId) {
        currentContract.value = null
      }

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error deleting contract:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Add extra cost to contract
   */
  const addExtraCost = async (
    contractId: string,
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
          contract_id: contractId,
          extra_cost_id: extraCostId,
          quantity,
          snapshot_price: snapshotPrice
        })

      if (insertError) throw insertError

      // Refresh contract
      await fetchContractById(contractId)

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
   * Remove extra cost from contract
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
    contracts: readonly(contracts),
    currentContract: readonly(currentContract),
    loading: readonly(loading),
    error: readonly(error),

    // Methods
    fetchContractsBySurvey,
    fetchContractById,
    createContract,
    updateContract,
    deleteContract,
    addExtraCost,
    removeExtraCost
  }
}
