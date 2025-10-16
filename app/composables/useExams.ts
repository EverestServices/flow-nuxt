import { z } from 'zod'

// Exam schemas
export const examSchema = z.object({
  id: z.string(),
  courseId: z.string(),
  title: z.string(),
  description: z.string().nullable(),
  instructions: z.string().nullable(),
  timeLimitMinutes: z.number().nullable(),
  passingScore: z.number().min(0).max(100).default(70),
  maxAttempts: z.number().default(3),
  randomizeQuestions: z.boolean().default(true),
  isPublished: z.boolean().default(false),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const examQuestionSchema = z.object({
  id: z.string(),
  examId: z.string(),
  questionText: z.string(),
  questionType: z.enum(['multiple_choice', 'true_false', 'short_answer', 'essay']).default('multiple_choice'),
  options: z.record(z.string()).nullable(),
  correctAnswer: z.array(z.string()).nullable(),
  points: z.number().default(1),
  explanation: z.string().nullable(),
  questionOrder: z.number().default(0),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const examAttemptSchema = z.object({
  id: z.string(),
  userId: z.string(),
  examId: z.string(),
  courseId: z.string(),
  attemptNumber: z.number(),
  answers: z.record(z.any()).nullable(),
  score: z.number().min(0).max(100).default(0),
  maxScore: z.number().default(100),
  status: z.enum(['in_progress', 'completed', 'abandoned']).default('in_progress'),
  startedAt: z.string(),
  completedAt: z.string().nullable(),
  timeTakenSeconds: z.number().nullable(),
  passed: z.boolean().default(false),
  createdAt: z.string(),
  updatedAt: z.string()
})

export type Exam = z.infer<typeof examSchema>
export type ExamQuestion = z.infer<typeof examQuestionSchema>
export type ExamAttempt = z.infer<typeof examAttemptSchema>

export interface ExamSubmissionAnswer {
  questionId: string
  answer: string | string[]
}

export interface ExamResult {
  score: number
  maxScore: number
  passed: boolean
  timeTaken: number
  answers: Record<string, any>
  correctAnswers: Record<string, any>
}

export const useExams = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Reactive state
  const currentExam = ref<any>(null)
  const examQuestions = ref<any[]>([])
  const currentAttempt = ref<any>(null)
  const userAnswers = ref<Record<string, any>>({})
  const examAttempts = ref<any[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const timeRemaining = ref<number>(0)
  const examTimer = ref<NodeJS.Timeout | null>(null)

  // Fetch exam by course ID
  const fetchExamByCourse = async (courseId: string) => {
    try {
      loading.value = true
      error.value = null

      const { data, error: fetchError } = await client
        .from('exams')
        .select('*')
        .eq('course_id', courseId)
        .eq('is_published', true)
        .single()

      if (fetchError) {
        if (fetchError.code === 'PGRST116') {
          // No exam found for this course
          currentExam.value = null
          return null
        }
        throw fetchError
      }

      currentExam.value = examSchema.parse({
        ...data,
        courseId: data.course_id,
        timeLimitMinutes: data.time_limit_minutes,
        passingScore: data.passing_score,
        maxAttempts: data.max_attempts,
        randomizeQuestions: data.randomize_questions,
        isPublished: data.is_published,
        createdAt: data.created_at,
        updatedAt: data.updated_at
      })

      return currentExam.value

    } catch (err) {
      console.error('Error fetching exam:', err)
      error.value = 'Failed to load exam. Please try again later.'
      return null
    } finally {
      loading.value = false
    }
  }

  // Fetch exam questions
  const fetchExamQuestions = async (examId: string, randomize = true) => {
    try {
      loading.value = true
      error.value = null

      let query = client
        .from('exam_questions')
        .select('*')
        .eq('exam_id', examId)

      if (!randomize) {
        query = query.order('question_order', { ascending: true })
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      let questions = (data || []).map(item => examQuestionSchema.parse({
        ...item,
        examId: item.exam_id,
        questionText: item.question_text,
        questionType: item.question_type,
        correctAnswer: item.correct_answer,
        questionOrder: item.question_order,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))

      // Randomize if requested
      if (randomize) {
        questions = questions.sort(() => Math.random() - 0.5)
      }

      examQuestions.value = questions

    } catch (err) {
      console.error('Error fetching exam questions:', err)
      error.value = 'Failed to load exam questions.'
    } finally {
      loading.value = false
    }
  }

  // Start exam attempt
  const startExamAttempt = async (examId: string, courseId: string) => {
    if (!user.value) {
      error.value = 'User not authenticated'
      return null
    }

    try {
      loading.value = true
      error.value = null

      // Check if user has reached max attempts
      const { data: existingAttempts, error: attemptsError } = await client
        .from('exam_attempts')
        .select('attempt_number')
        .eq('user_id', user.value.id)
        .eq('exam_id', examId)
        .order('attempt_number', { ascending: false })

      if (attemptsError) throw attemptsError

      const attemptNumber = (existingAttempts?.[0]?.attempt_number || 0) + 1

      // Check max attempts
      if (currentExam.value?.maxAttempts && attemptNumber > currentExam.value.maxAttempts) {
        error.value = 'Maximum number of attempts reached'
        return null
      }

      // Create new attempt
      const { data, error: createError } = await client
        .from('exam_attempts')
        .insert({
          user_id: user.value.id,
          exam_id: examId,
          course_id: courseId,
          attempt_number: attemptNumber,
          status: 'in_progress'
        })
        .select()
        .single()

      if (createError) throw createError

      currentAttempt.value = examAttemptSchema.parse({
        ...data,
        userId: data.user_id,
        examId: data.exam_id,
        courseId: data.course_id,
        attemptNumber: data.attempt_number,
        maxScore: data.max_score,
        startedAt: data.started_at,
        completedAt: data.completed_at,
        timeTakenSeconds: data.time_taken_seconds,
        createdAt: data.created_at,
        updatedAt: data.updated_at
      })

      // Initialize timer if exam has time limit
      if (currentExam.value?.timeLimitMinutes) {
        timeRemaining.value = currentExam.value.timeLimitMinutes * 60
        startTimer()
      }

      // Reset user answers
      userAnswers.value = {}

      return currentAttempt.value

    } catch (err) {
      console.error('Error starting exam attempt:', err)
      error.value = 'Failed to start exam. Please try again.'
      return null
    } finally {
      loading.value = false
    }
  }

  // Start timer
  const startTimer = () => {
    if (examTimer.value) {
      clearInterval(examTimer.value)
    }

    examTimer.value = setInterval(() => {
      timeRemaining.value--

      if (timeRemaining.value <= 0) {
        // Auto-submit exam when time runs out
        submitExam()
      }
    }, 1000)
  }

  // Stop timer
  const stopTimer = () => {
    if (examTimer.value) {
      clearInterval(examTimer.value)
      examTimer.value = null
    }
  }

  // Update answer
  const updateAnswer = (questionId: string, answer: any) => {
    userAnswers.value[questionId] = answer
  }

  // Submit exam
  const submitExam = async (): Promise<ExamResult | null> => {
    if (!currentAttempt.value || !user.value) {
      error.value = 'No active exam attempt'
      return null
    }

    try {
      loading.value = true
      error.value = null

      stopTimer()

      const timeTaken = currentExam.value?.timeLimitMinutes ?
        (currentExam.value.timeLimitMinutes * 60) - timeRemaining.value :
        Math.floor((Date.now() - new Date(currentAttempt.value.startedAt).getTime()) / 1000)

      // Calculate score
      const result = calculateScore(userAnswers.value, examQuestions.value)

      // Update attempt record
      const { error: updateError } = await client
        .from('exam_attempts')
        .update({
          answers: userAnswers.value,
          score: result.score,
          status: 'completed',
          completed_at: new Date().toISOString(),
          time_taken_seconds: timeTaken,
          passed: result.passed
        })
        .eq('id', currentAttempt.value.id)

      if (updateError) throw updateError

      // If exam is passed, mark course as completed
      if (result.passed) {
        const { useCourses } = await import('./useCourses')
        const { updateCourseProgress } = useCourses()
        await updateCourseProgress(currentAttempt.value.courseId, 'completed', 100)
      }

      return {
        ...result,
        timeTaken
      }

    } catch (err) {
      console.error('Error submitting exam:', err)
      error.value = 'Failed to submit exam. Please try again.'
      return null
    } finally {
      loading.value = false
    }
  }

  // Calculate score
  const calculateScore = (answers: Record<string, any>, questions: any[]): ExamResult => {
    let totalPoints = 0
    let earnedPoints = 0
    const correctAnswers: Record<string, any> = {}

    questions.forEach(question => {
      totalPoints += question.points
      correctAnswers[question.id] = question.correctAnswer

      const userAnswer = answers[question.id]

      if (question.questionType === 'multiple_choice') {
        // For multiple choice, compare arrays
        const correct = Array.isArray(question.correctAnswer) ? question.correctAnswer : [question.correctAnswer]
        const user = Array.isArray(userAnswer) ? userAnswer : [userAnswer]

        if (JSON.stringify(correct.sort()) === JSON.stringify(user.sort())) {
          earnedPoints += question.points
        }
      } else if (question.questionType === 'true_false') {
        if (userAnswer === question.correctAnswer?.[0]) {
          earnedPoints += question.points
        }
      } else if (question.questionType === 'short_answer') {
        // For short answer, do case-insensitive comparison
        const correctText = question.correctAnswer?.[0]?.toLowerCase().trim()
        const userText = userAnswer?.toLowerCase().trim()

        if (correctText === userText) {
          earnedPoints += question.points
        }
      }
      // Essay questions would need manual grading
    })

    const score = totalPoints > 0 ? Math.round((earnedPoints / totalPoints) * 100) : 0
    const passed = score >= (currentExam.value?.passingScore || 70)

    return {
      score,
      maxScore: 100,
      passed,
      timeTaken: 0, // This will be set by submitExam
      answers,
      correctAnswers
    }
  }

  // Fetch user's exam attempts
  const fetchExamAttempts = async (examId: string) => {
    if (!user.value) return

    try {
      const { data, error: fetchError } = await client
        .from('exam_attempts')
        .select('*')
        .eq('user_id', user.value.id)
        .eq('exam_id', examId)
        .order('attempt_number', { ascending: false })

      if (fetchError) throw fetchError

      examAttempts.value = (data || []).map(item => examAttemptSchema.parse({
        ...item,
        userId: item.user_id,
        examId: item.exam_id,
        courseId: item.course_id,
        attemptNumber: item.attempt_number,
        maxScore: item.max_score,
        startedAt: item.started_at,
        completedAt: item.completed_at,
        timeTakenSeconds: item.time_taken_seconds,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))

    } catch (err) {
      console.error('Error fetching exam attempts:', err)
    }
  }

  // Check if user can take exam
  const canTakeExam = computed(() => {
    if (!currentExam.value || !user.value) return false

    const completedAttempts = examAttempts.value.filter(attempt => attempt.status === 'completed')
    const passedAttempts = completedAttempts.filter(attempt => attempt.passed)

    // If user has passed, they can't take it again
    if (passedAttempts.length > 0) return false

    // Check max attempts
    if (currentExam.value.maxAttempts && completedAttempts.length >= currentExam.value.maxAttempts) {
      return false
    }

    return true
  })

  // Get best attempt
  const getBestAttempt = computed(() => {
    if (examAttempts.value.length === 0) return null

    return examAttempts.value
      .filter(attempt => attempt.status === 'completed')
      .sort((a, b) => b.score - a.score)[0] || null
  })

  // Format time
  const formatTime = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
  }

  // Cleanup on unmount
  onUnmounted(() => {
    stopTimer()
  })

  return {
    // State
    currentExam: readonly(currentExam),
    examQuestions: readonly(examQuestions),
    currentAttempt: readonly(currentAttempt),
    userAnswers,
    examAttempts: readonly(examAttempts),
    loading: readonly(loading),
    error: readonly(error),
    timeRemaining: readonly(timeRemaining),

    // Actions
    fetchExamByCourse,
    fetchExamQuestions,
    startExamAttempt,
    updateAnswer,
    submitExam,
    fetchExamAttempts,

    // Computed
    canTakeExam,
    getBestAttempt,

    // Utils
    formatTime,
    stopTimer
  }
}