/**
 * useSurveyAnswers Composable
 * Handles survey answers and questions
 */

import type {
  SurveyAnswer,
  SurveyQuestion,
  SurveyPage,
  SurveyPageWithQuestions,
  InsertSurveyAnswer,
  UpdateSurveyAnswer
} from '~/types/survey-new'

export const useSurveyAnswers = () => {
  const supabase = useSupabaseClient()

  // State
  const answers = ref<SurveyAnswer[]>([])
  const questions = ref<SurveyQuestion[]>([])
  const pages = ref<SurveyPageWithQuestions[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Fetch all survey pages with questions
   */
  const fetchSurveyPages = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('survey_pages')
        .select(`
          *,
          questions:survey_questions(*)
        `)
        .order('position', { ascending: true })

      if (fetchError) throw fetchError

      pages.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching survey pages:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch questions for a specific page
   */
  const fetchQuestionsByPage = async (pageId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('survey_questions')
        .select('*')
        .eq('survey_page_id', pageId)

      if (fetchError) throw fetchError

      questions.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching questions:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch answers for a specific survey
   */
  const fetchAnswersBySurvey = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('survey_answers')
        .select(`
          *,
          question:survey_questions(*)
        `)
        .eq('survey_id', surveyId)

      if (fetchError) throw fetchError

      answers.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching answers:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Save or update a single answer
   */
  const saveAnswer = async (surveyId: string, questionId: string, answerValue: string) => {
    loading.value = true
    error.value = null

    try {
      // Check if answer already exists
      const { data: existing } = await supabase
        .from('survey_answers')
        .select('id')
        .eq('survey_id', surveyId)
        .eq('survey_question_id', questionId)
        .single()

      if (existing) {
        // Update existing answer
        const { data, error: updateError } = await supabase
          .from('survey_answers')
          .update({ answer: answerValue })
          .eq('id', existing.id)
          .select()
          .single()

        if (updateError) throw updateError
        return data
      } else {
        // Insert new answer
        const { data, error: insertError } = await supabase
          .from('survey_answers')
          .insert({
            survey_id: surveyId,
            survey_question_id: questionId,
            answer: answerValue
          })
          .select()
          .single()

        if (insertError) throw insertError
        return data
      }
    } catch (e: any) {
      error.value = e.message
      console.error('Error saving answer:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Save multiple answers at once
   */
  const saveAnswers = async (surveyId: string, answersData: Record<string, string>) => {
    loading.value = true
    error.value = null

    try {
      const promises = Object.entries(answersData).map(([questionId, answerValue]) =>
        saveAnswer(surveyId, questionId, answerValue)
      )

      await Promise.all(promises)

      // Refresh answers
      await fetchAnswersBySurvey(surveyId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error saving answers:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Delete an answer
   */
  const deleteAnswer = async (answerId: string) => {
    loading.value = true
    error.value = null

    try {
      const { error: deleteError } = await supabase
        .from('survey_answers')
        .delete()
        .eq('id', answerId)

      if (deleteError) throw deleteError

      // Remove from local state
      answers.value = answers.value.filter(a => a.id !== answerId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error deleting answer:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Get answer value for a specific question
   */
  const getAnswerValue = (questionId: string): string | null => {
    const answer = answers.value.find(a => a.survey_question_id === questionId)
    return answer?.answer || null
  }

  /**
   * Get all answers as a key-value object
   */
  const getAnswersObject = (): Record<string, string> => {
    const obj: Record<string, string> = {}
    answers.value.forEach(answer => {
      if (answer.answer) {
        obj[answer.survey_question_id] = answer.answer
      }
    })
    return obj
  }

  /**
   * Calculate completion percentage
   */
  const getCompletionPercentage = (requiredQuestionIds: string[]): number => {
    if (requiredQuestionIds.length === 0) return 100

    const answeredCount = requiredQuestionIds.filter(qid => {
      const answer = getAnswerValue(qid)
      return answer !== null && answer.trim() !== ''
    }).length

    return Math.round((answeredCount / requiredQuestionIds.length) * 100)
  }

  return {
    // State
    answers: readonly(answers),
    questions: readonly(questions),
    pages: readonly(pages),
    loading: readonly(loading),
    error: readonly(error),

    // Methods
    fetchSurveyPages,
    fetchQuestionsByPage,
    fetchAnswersBySurvey,
    saveAnswer,
    saveAnswers,
    deleteAnswer,
    getAnswerValue,
    getAnswersObject,
    getCompletionPercentage
  }
}
