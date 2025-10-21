/**
 * useSurveys Composable
 * Handles all survey-related operations with the new database structure
 */

import type {
  Survey,
  SurveyWithRelations,
  InsertSurvey,
  UpdateSurvey,
  SurveyFormData,
  SurveysResponse
} from '~/types/survey-new'

export const useSurveys = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  // State
  const surveys = ref<SurveyWithRelations[]>([])
  const currentSurvey = ref<SurveyWithRelations | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Get user's company ID
   */
  const getCompanyId = async (): Promise<string | null> => {
    if (!user.value) return null

    const { data } = await supabase
      .from('user_profiles')
      .select('company_id')
      .eq('user_id', user.value.id)
      .single()

    return data?.company_id || null
  }

  /**
   * Fetch all surveys for the current company
   */
  const fetchSurveys = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('surveys')
        .select(`
          *,
          client:clients(*),
          investments:survey_investments(
            investment:investments(*)
          ),
          electric_cars(*),
          scenarios(*)
        `)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError

      surveys.value = data || []
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching surveys:', e)
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch surveys for a specific client
   */
  const fetchSurveysByClient = async (clientId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('surveys')
        .select(`
          *,
          client:clients(*),
          investments:survey_investments(
            investment:investments(*)
          ),
          electric_cars(*),
          scenarios(*)
        `)
        .eq('client_id', clientId)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError

      surveys.value = data || []
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching surveys by client:', e)
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch a single survey by ID with all relations
   */
  const fetchSurveyById = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('surveys')
        .select(`
          *,
          client:clients(*),
          investments:survey_investments(
            investment:investments(*)
          ),
          electric_cars(*),
          heavy_consumers:survey_heavy_consumers(
            heavy_consumer:heavy_consumers(*),
            status
          ),
          scenarios(*),
          answers:survey_answers(
            *,
            question:survey_questions(*)
          ),
          documents(
            *,
            category:document_categories(*)
          )
        `)
        .eq('id', surveyId)
        .single()

      if (fetchError) throw fetchError

      currentSurvey.value = data
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching survey:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Create a new survey
   */
  const createSurvey = async (surveyData: SurveyFormData) => {
    loading.value = true
    error.value = null

    try {
      const companyId = await getCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      // 1. Create the survey
      const { data: survey, error: surveyError } = await supabase
        .from('surveys')
        .insert({
          client_id: surveyData.client_id,
          user_id: user.value?.id,
          company_id: companyId,
          at: surveyData.at
        })
        .select()
        .single()

      if (surveyError) throw surveyError

      // 2. Link investments
      if (surveyData.investments.length > 0) {
        const surveyInvestments = surveyData.investments.map(investmentId => ({
          survey_id: survey.id,
          investment_id: investmentId
        }))

        const { error: investmentsError } = await supabase
          .from('survey_investments')
          .insert(surveyInvestments)

        if (investmentsError) throw investmentsError
      }

      // 3. Create electric cars
      if (surveyData.electric_cars.length > 0) {
        const electricCars = surveyData.electric_cars.map(car => ({
          ...car,
          survey_id: survey.id
        }))

        const { error: carsError } = await supabase
          .from('electric_cars')
          .insert(electricCars)

        if (carsError) throw carsError
      }

      // 4. Link heavy consumers
      if (surveyData.heavy_consumers.length > 0) {
        const surveyHeavyConsumers = surveyData.heavy_consumers.map(hc => ({
          survey_id: survey.id,
          heavy_consumer_id: hc.id,
          status: hc.status
        }))

        const { error: hcError } = await supabase
          .from('survey_heavy_consumers')
          .insert(surveyHeavyConsumers)

        if (hcError) throw hcError
      }

      // 5. Create answers
      if (Object.keys(surveyData.answers).length > 0) {
        const answers = Object.entries(surveyData.answers).map(([questionId, answer]) => ({
          survey_id: survey.id,
          survey_question_id: questionId,
          answer
        }))

        const { error: answersError } = await supabase
          .from('survey_answers')
          .insert(answers)

        if (answersError) throw answersError
      }

      // Fetch the complete survey with relations
      await fetchSurveyById(survey.id)

      return survey
    } catch (e: any) {
      error.value = e.message
      console.error('Error creating survey:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Update an existing survey
   */
  const updateSurvey = async (surveyId: string, updates: UpdateSurvey) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: updateError } = await supabase
        .from('surveys')
        .update(updates)
        .eq('id', surveyId)
        .select()
        .single()

      if (updateError) throw updateError

      // Refresh current survey if it's the one being updated
      if (currentSurvey.value?.id === surveyId) {
        await fetchSurveyById(surveyId)
      }

      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error updating survey:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Delete a survey
   */
  const deleteSurvey = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('surveys')
        .delete()
        .eq('id', surveyId)

      if (deleteError) throw deleteError

      // Remove from local state
      surveys.value = surveys.value.filter(s => s.id !== surveyId)
      if (currentSurvey.value?.id === surveyId) {
        currentSurvey.value = null
      }

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error deleting survey:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Add investments to a survey
   */
  const addInvestments = async (surveyId: string, investmentIds: string[]) => {
    loading.value = true
    error.value = null

    try {
      const surveyInvestments = investmentIds.map(investmentId => ({
        survey_id: surveyId,
        investment_id: investmentId
      }))

      const { error: insertError } = await supabase
        .from('survey_investments')
        .insert(surveyInvestments)

      if (insertError) throw insertError

      // Refresh survey
      await fetchSurveyById(surveyId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error adding investments:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Remove investments from a survey
   */
  const removeInvestments = async (surveyId: string, investmentIds: string[]) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('survey_investments')
        .delete()
        .eq('survey_id', surveyId)
        .in('investment_id', investmentIds)

      if (deleteError) throw deleteError

      // Refresh survey
      await fetchSurveyById(surveyId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error removing investments:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    surveys: readonly(surveys),
    currentSurvey: readonly(currentSurvey),
    loading: readonly(loading),
    error: readonly(error),

    // Methods
    fetchSurveys,
    fetchSurveysByClient,
    fetchSurveyById,
    createSurvey,
    updateSurvey,
    deleteSurvey,
    addInvestments,
    removeInvestments
  }
}
