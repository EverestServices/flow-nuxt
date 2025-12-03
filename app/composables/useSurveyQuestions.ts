/**
 * Composable for survey question visibility and display conditions
 *
 * Handles complex visibility logic including:
 * - Field-based conditions (equals, not_equals, etc.)
 * - External source restrictions (OFP/EKR only)
 * - Combined conditions
 */

export interface DisplayConditions {
  field?: string
  operator?: 'equals' | 'not_equals' | 'greater_than' | 'less_than' | 'greater_or_equal' | 'less_or_equal' | 'contains' | 'contains_any'
  value?: any
  visible_for_sources?: ('OFP' | 'EKR')[]
}

export interface SurveyQuestion {
  id: string
  name: string
  type: string
  display_conditions?: DisplayConditions
  // ... other fields
}

export interface Survey {
  id: string
  ofp_survey_id?: string | null
  ekr_survey_id?: string | null
  // ... other fields
}

export function useSurveyQuestions() {
  /**
   * Check if a question should be visible based on display conditions
   *
   * @param question - The survey question
   * @param survey - The current survey
   * @param currentAnswers - Current survey answers (for field-based conditions)
   * @returns true if question should be visible
   */
  function isQuestionVisible(
    question: SurveyQuestion,
    survey: Survey,
    currentAnswers: Record<string, any> = {}
  ): boolean {
    if (!question.display_conditions) {
      return true // No conditions = always visible
    }

    const conditions = question.display_conditions

    // 1. Check external source visibility
    if (conditions.visible_for_sources && Array.isArray(conditions.visible_for_sources)) {
      const isOFPSurvey = !!survey.ofp_survey_id
      const isEKRSurvey = !!survey.ekr_survey_id
      const isNormalSurvey = !isOFPSurvey && !isEKRSurvey

      if (isNormalSurvey) {
        // Normal Flow survey - check only field conditions
        return evaluateFieldCondition(conditions, currentAnswers)
      }

      // External survey - check if source is in list
      const shouldShowForOFP = isOFPSurvey && conditions.visible_for_sources.includes('OFP')
      const shouldShowForEKR = isEKRSurvey && conditions.visible_for_sources.includes('EKR')

      if (!shouldShowForOFP && !shouldShowForEKR) {
        return false // Hide question for this external source
      }

      // Source matches - now check field conditions if any
      if (conditions.field) {
        return evaluateFieldCondition(conditions, currentAnswers)
      }

      return true // Source matches and no field conditions
    }

    // 2. Check field-based conditions only
    if (conditions.field) {
      return evaluateFieldCondition(conditions, currentAnswers)
    }

    return true // No applicable conditions
  }

  /**
   * Evaluate field-based condition
   */
  function evaluateFieldCondition(
    conditions: DisplayConditions,
    currentAnswers: Record<string, any>
  ): boolean {
    if (!conditions.field || conditions.operator === undefined) {
      return true
    }

    const fieldValue = currentAnswers[conditions.field]
    const targetValue = conditions.value

    switch (conditions.operator) {
      case 'equals':
        return fieldValue === targetValue

      case 'not_equals':
        return fieldValue !== targetValue

      case 'greater_than':
        return Number(fieldValue) > Number(targetValue)

      case 'less_than':
        return Number(fieldValue) < Number(targetValue)

      case 'greater_or_equal':
        return Number(fieldValue) >= Number(targetValue)

      case 'less_or_equal':
        return Number(fieldValue) <= Number(targetValue)

      case 'contains':
        if (typeof fieldValue === 'string') {
          return fieldValue.includes(String(targetValue))
        }
        if (Array.isArray(fieldValue)) {
          return fieldValue.includes(targetValue)
        }
        return false

      case 'contains_any':
        if (!Array.isArray(fieldValue) || !Array.isArray(targetValue)) {
          return false
        }
        return targetValue.some(val => fieldValue.includes(val))

      default:
        console.warn('Unknown operator:', conditions.operator)
        return true
    }
  }

  /**
   * Filter visible questions from a list
   */
  function filterVisibleQuestions(
    questions: SurveyQuestion[],
    survey: Survey,
    currentAnswers: Record<string, any> = {}
  ): SurveyQuestion[] {
    return questions.filter(question =>
      isQuestionVisible(question, survey, currentAnswers)
    )
  }

  /**
   * Check if survey is from an external source
   */
  function isExternalSurvey(survey: Survey): boolean {
    return !!(survey.ofp_survey_id || survey.ekr_survey_id)
  }

  /**
   * Get external survey source
   */
  function getExternalSource(survey: Survey): 'OFP' | 'EKR' | null {
    if (survey.ofp_survey_id) return 'OFP'
    if (survey.ekr_survey_id) return 'EKR'
    return null
  }

  return {
    isQuestionVisible,
    evaluateFieldCondition,
    filterVisibleQuestions,
    isExternalSurvey,
    getExternalSource
  }
}
