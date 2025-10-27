import { ref, computed } from 'vue'
import type { Subsidy, SurveySubsidy, SubsidyWithEnabled, EligibilityConditions } from '~/types/subsidy'

export const useSubsidies = () => {
  const supabase = useSupabaseClient()

  const subsidies = ref<Subsidy[]>([])
  const surveySubsidies = ref<SurveySubsidy[]>([])
  const eligibilityConditions = ref<EligibilityConditions>({
    builtBefore2010: false,
    energyClassE: false,
    familyHouse: false,
    energyImprovement30Percent: false,
    hasEnergyAudit: false,
    builtBefore2007: false,
    notSmallSettlement: false,
    smallSettlement: false,
    ownershipMinimum50Percent: false,
    hungarianCitizen: false,
    minSelfFunding: false
  })

  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Load all available subsidies from catalog
   */
  const loadSubsidies = async () => {
    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await supabase
        .from('subsidies')
        .select('*')
        .order('sequence', { ascending: true })

      if (fetchError) throw fetchError

      subsidies.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Error loading subsidies:', err)
    } finally {
      loading.value = false
    }
  }

  /**
   * Load survey subsidies for a specific survey
   */
  const loadSurveySubsidies = async (surveyId: string) => {
    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await supabase
        .from('survey_subsidies')
        .select('*')
        .eq('survey_id', surveyId)

      if (fetchError) throw fetchError

      surveySubsidies.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Error loading survey subsidies:', err)
    } finally {
      loading.value = false
    }
  }

  /**
   * Get subsidies with enabled status for a survey
   */
  const getSubsidiesWithStatus = computed((): SubsidyWithEnabled[] => {
    return subsidies.value.map(subsidy => {
      const surveySubsidy = surveySubsidies.value.find(
        ss => ss.subsidy_id === subsidy.id
      )
      return {
        ...subsidy,
        is_enabled: surveySubsidy?.is_enabled || false
      }
    })
  })

  /**
   * Toggle subsidy enabled status for a survey
   */
  const toggleSubsidy = async (surveyId: string, subsidyId: string, isEnabled: boolean) => {
    try {
      error.value = null

      // Check if record exists
      const existing = surveySubsidies.value.find(
        ss => ss.survey_id === surveyId && ss.subsidy_id === subsidyId
      )

      if (existing) {
        // Update existing record
        const { error: updateError } = await supabase
          .from('survey_subsidies')
          .update({ is_enabled: isEnabled })
          .eq('survey_id', surveyId)
          .eq('subsidy_id', subsidyId)

        if (updateError) throw updateError

        // Update local state
        const index = surveySubsidies.value.findIndex(
          ss => ss.survey_id === surveyId && ss.subsidy_id === subsidyId
        )
        if (index !== -1) {
          surveySubsidies.value[index].is_enabled = isEnabled
        }
      } else {
        // Insert new record
        const { data, error: insertError } = await supabase
          .from('survey_subsidies')
          .insert({
            survey_id: surveyId,
            subsidy_id: subsidyId,
            is_enabled: isEnabled
          })
          .select()
          .single()

        if (insertError) throw insertError

        // Add to local state
        if (data) {
          surveySubsidies.value.push(data)
        }
      }
    } catch (err: any) {
      error.value = err.message
      console.error('Error toggling subsidy:', err)
      throw err
    }
  }

  /**
   * Update eligibility condition
   */
  const updateEligibilityCondition = (key: keyof EligibilityConditions, value: boolean) => {
    eligibilityConditions.value[key] = value
  }

  /**
   * Format currency for display
   */
  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('hu-HU', {
      style: 'currency',
      currency: 'HUF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount)
  }

  return {
    // State
    subsidies,
    surveySubsidies,
    eligibilityConditions,
    loading,
    error,

    // Computed
    getSubsidiesWithStatus,

    // Methods
    loadSubsidies,
    loadSurveySubsidies,
    toggleSubsidy,
    updateEligibilityCondition,
    formatCurrency
  }
}
