/**
 * useInvestments Composable
 * Handles investment-related operations
 */

import type { Investment, InvestmentsResponse } from '~/types/survey-new'

export const useInvestments = () => {
  const supabase = useSupabaseClient()

  // State
  const investments = ref<Investment[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Fetch all investments
   */
  const fetchInvestments = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('investments')
        .select('*')
        .order('name', { ascending: true })

      if (fetchError) throw fetchError

      investments.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching investments:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch a single investment by ID
   */
  const fetchInvestmentById = async (investmentId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('investments')
        .select('*')
        .eq('id', investmentId)
        .single()

      if (fetchError) throw fetchError

      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching investment:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch document categories for an investment
   */
  const fetchInvestmentDocumentCategories = async (investmentId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('investment_document_categories')
        .select(`
          position,
          document_category:document_categories(*)
        `)
        .eq('investment_id', investmentId)
        .order('position', { ascending: true })

      if (fetchError) throw fetchError

      return data?.map(item => ({
        ...item.document_category,
        position: item.position
      })) || []
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching investment document categories:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Get investment by name
   */
  const getInvestmentByName = (name: string) => {
    return investments.value.find(inv => inv.name === name)
  }

  /**
   * Get multiple investments by IDs
   */
  const getInvestmentsByIds = (ids: string[]) => {
    return investments.value.filter(inv => ids.includes(inv.id))
  }

  return {
    // State
    investments: readonly(investments),
    loading: readonly(loading),
    error: readonly(error),

    // Methods
    fetchInvestments,
    fetchInvestmentById,
    fetchInvestmentDocumentCategories,
    getInvestmentByName,
    getInvestmentsByIds
  }
}
