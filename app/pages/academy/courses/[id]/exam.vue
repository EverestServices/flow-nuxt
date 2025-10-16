<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-20">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="p-6">
      <div class="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">
        {{ error }}
      </div>
    </div>

    <!-- No Exam Available -->
    <div v-else-if="!currentExam" class="p-6">
      <div class="max-w-2xl mx-auto text-center py-12">
        <UIcon name="i-lucide-file-text" class="text-4xl text-gray-400 mx-auto mb-4" />
        <h2 class="text-xl font-semibold text-gray-900 mb-2">No Exam Available</h2>
        <p class="text-gray-600 mb-6">This course doesn't have an exam associated with it.</p>
        <UButton @click="goBackToCourse">
          <UIcon name="i-lucide-arrow-left" class="mr-2" />
          Back to Course
        </UButton>
      </div>
    </div>

    <!-- Exam Start Screen -->
    <div v-else-if="!currentAttempt && !showResults" class="p-6">
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
          <div class="text-center mb-8">
            <UIcon name="i-lucide-file-text" class="text-4xl text-blue-600 mx-auto mb-4" />
            <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ currentExam.title }}</h1>
            <p class="text-lg text-gray-600">{{ currentExam.description }}</p>
          </div>

          <!-- Exam Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600">{{ examQuestions.length }}</div>
              <div class="text-sm text-gray-600">Questions</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600">
                {{ currentExam.timeLimitMinutes || 'No limit' }}
              </div>
              <div class="text-sm text-gray-600">
                {{ currentExam.timeLimitMinutes ? 'Minutes' : '' }}
              </div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600">{{ currentExam.passingScore }}%</div>
              <div class="text-sm text-gray-600">Passing Score</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600">{{ remainingAttempts }}</div>
              <div class="text-sm text-gray-600">Attempts Left</div>
            </div>
          </div>

          <!-- Instructions -->
          <div v-if="currentExam.instructions" class="mb-8">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Instructions</h3>
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <p class="text-blue-800">{{ currentExam.instructions }}</p>
            </div>
          </div>

          <!-- Previous Attempts -->
          <div v-if="examAttempts.length > 0" class="mb-8">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Previous Attempts</h3>
            <div class="space-y-2">
              <div
                v-for="attempt in examAttempts.slice(0, 5)"
                :key="attempt.id"
                class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div class="flex items-center gap-3">
                  <span class="text-sm font-medium text-gray-900">
                    Attempt {{ attempt.attemptNumber }}
                  </span>
                  <span
                    class="text-xs px-2 py-1 rounded-full"
                    :class="attempt.passed ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                  >
                    {{ attempt.passed ? 'Passed' : 'Failed' }}
                  </span>
                </div>
                <div class="flex items-center gap-4 text-sm text-gray-600">
                  <span class="font-medium">{{ attempt.score }}%</span>
                  <span>{{ new Date(attempt.completedAt || attempt.startedAt).toLocaleDateString() }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="text-center">
            <div v-if="!canTakeExam" class="mb-4">
              <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 text-yellow-800">
                <p v-if="hasPassedExam" class="font-medium">
                  🎉 Congratulations! You have already passed this exam.
                </p>
                <p v-else class="font-medium">
                  You have reached the maximum number of attempts for this exam.
                </p>
              </div>
            </div>

            <div class="flex items-center justify-center gap-4">
              <UButton
                variant="outline"
                @click="goBackToCourse"
              >
                <UIcon name="i-lucide-arrow-left" class="mr-2" />
                Back to Course
              </UButton>

              <UButton
                v-if="canTakeExam"
                size="lg"
                @click="startExam"
                :loading="loading"
              >
                <UIcon name="i-lucide-play" class="mr-2" />
                Start Exam
              </UButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Exam Taking Screen -->
    <div v-else-if="currentAttempt && !showResults" class="pb-8">
      <!-- Exam Header -->
      <div class="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div class="max-w-4xl mx-auto px-6 py-4">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="font-bold text-gray-900">{{ currentExam.title }}</h1>
              <p class="text-sm text-gray-600">
                Question {{ currentQuestionIndex + 1 }} of {{ examQuestions.length }}
              </p>
            </div>

            <div class="flex items-center gap-4">
              <!-- Timer -->
              <div v-if="currentExam.timeLimitMinutes" class="flex items-center gap-2">
                <UIcon name="i-lucide-clock" class="text-orange-500" />
                <span
                  class="font-mono font-bold"
                  :class="timeRemaining <= 300 ? 'text-red-600' : 'text-gray-900'"
                >
                  {{ formatTime(timeRemaining) }}
                </span>
              </div>

              <!-- Submit Button -->
              <UButton @click="confirmSubmit" variant="outline">
                Submit Exam
              </UButton>
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="mt-3">
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="{ width: `${examProgress}%` }"
              ></div>
            </div>
            <div class="text-xs text-gray-500 mt-1">
              {{ answeredQuestionsCount }} of {{ examQuestions.length }} questions answered
            </div>
          </div>
        </div>
      </div>

      <!-- Question Content -->
      <div class="max-w-4xl mx-auto px-6 py-8">
        <div v-if="currentQuestion" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
          <!-- Question -->
          <div class="mb-6">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">
              {{ currentQuestion.questionText }}
            </h2>
            <div class="text-sm text-gray-600">
              {{ currentQuestion.points }} {{ currentQuestion.points === 1 ? 'point' : 'points' }}
            </div>
          </div>

          <!-- Answer Options -->
          <div class="space-y-4 mb-8">
            <!-- Multiple Choice -->
            <div v-if="currentQuestion.questionType === 'multiple_choice'" class="space-y-3">
              <label
                v-for="(option, key) in currentQuestion.options"
                :key="key"
                class="flex items-start gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="selectedAnswers[currentQuestion.id]?.includes(key) ? 'border-blue-500 bg-blue-50' : ''"
              >
                <input
                  type="checkbox"
                  :value="key"
                  :checked="selectedAnswers[currentQuestion.id]?.includes(key)"
                  @change="toggleMultipleChoiceAnswer(currentQuestion.id, key)"
                  class="mt-1"
                >
                <span class="flex-1">{{ option }}</span>
              </label>
            </div>

            <!-- True/False -->
            <div v-else-if="currentQuestion.questionType === 'true_false'" class="space-y-3">
              <label class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                     :class="selectedAnswers[currentQuestion.id] === 'true' ? 'border-blue-500 bg-blue-50' : ''">
                <input
                  type="radio"
                  name="true_false"
                  value="true"
                  :checked="selectedAnswers[currentQuestion.id] === 'true'"
                  @change="updateAnswer(currentQuestion.id, 'true')"
                >
                <span>True</span>
              </label>
              <label class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                     :class="selectedAnswers[currentQuestion.id] === 'false' ? 'border-blue-500 bg-blue-50' : ''">
                <input
                  type="radio"
                  name="true_false"
                  value="false"
                  :checked="selectedAnswers[currentQuestion.id] === 'false'"
                  @change="updateAnswer(currentQuestion.id, 'false')"
                >
                <span>False</span>
              </label>
            </div>

            <!-- Short Answer -->
            <div v-else-if="currentQuestion.questionType === 'short_answer'">
              <UTextarea
                v-model="selectedAnswers[currentQuestion.id]"
                placeholder="Enter your answer..."
                rows="3"
                @input="updateAnswer(currentQuestion.id, $event.target.value)"
              />
            </div>

            <!-- Essay -->
            <div v-else-if="currentQuestion.questionType === 'essay'">
              <UTextarea
                v-model="selectedAnswers[currentQuestion.id]"
                placeholder="Write your essay answer..."
                rows="8"
                @input="updateAnswer(currentQuestion.id, $event.target.value)"
              />
            </div>
          </div>

          <!-- Navigation -->
          <div class="flex items-center justify-between">
            <UButton
              v-if="currentQuestionIndex > 0"
              variant="outline"
              @click="previousQuestion"
            >
              <UIcon name="i-lucide-chevron-left" class="mr-2" />
              Previous
            </UButton>
            <div v-else></div>

            <UButton
              v-if="currentQuestionIndex < examQuestions.length - 1"
              @click="nextQuestion"
            >
              Next
              <UIcon name="i-lucide-chevron-right" class="ml-2" />
            </UButton>
            <UButton
              v-else
              @click="confirmSubmit"
              :disabled="answeredQuestionsCount === 0"
            >
              Submit Exam
            </UButton>
          </div>
        </div>

        <!-- Question Navigation -->
        <div class="mt-6 bg-white rounded-lg shadow-sm border border-gray-200 p-4">
          <h3 class="font-medium text-gray-900 mb-3">Question Overview</h3>
          <div class="grid grid-cols-8 sm:grid-cols-12 lg:grid-cols-16 gap-2">
            <button
              v-for="(question, index) in examQuestions"
              :key="question.id"
              class="w-8 h-8 rounded-lg text-sm font-medium transition-colors"
              :class="getQuestionStatusClass(question.id, index)"
              @click="goToQuestion(index)"
            >
              {{ index + 1 }}
            </button>
          </div>
          <div class="flex items-center gap-4 mt-3 text-xs text-gray-600">
            <div class="flex items-center gap-1">
              <div class="w-3 h-3 bg-blue-500 rounded"></div>
              <span>Current</span>
            </div>
            <div class="flex items-center gap-1">
              <div class="w-3 h-3 bg-green-500 rounded"></div>
              <span>Answered</span>
            </div>
            <div class="flex items-center gap-1">
              <div class="w-3 h-3 bg-gray-300 rounded"></div>
              <span>Not answered</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Results Screen -->
    <ExamResults
      v-else-if="showResults"
      :result="examResult"
      :exam="currentExam"
      :questions="examQuestions"
      :user-answers="userAnswers"
      @retake="retakeExam"
      @back-to-course="goBackToCourse"
    />

    <!-- Confirm Submit Modal -->
    <UModal v-model="showSubmitConfirm">
      <div class="p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Submit Exam?</h3>
        <p class="text-gray-600 mb-6">
          Are you sure you want to submit your exam? You have answered {{ answeredQuestionsCount }} out of {{ examQuestions.length }} questions.
          <span v-if="answeredQuestionsCount < examQuestions.length" class="block mt-2 text-orange-600 font-medium">
            Warning: {{ examQuestions.length - answeredQuestionsCount }} questions remain unanswered.
          </span>
        </p>
        <div class="flex items-center justify-end gap-3">
          <UButton variant="outline" @click="showSubmitConfirm = false">
            Cancel
          </UButton>
          <UButton @click="submitExam" :loading="loading">
            Submit Exam
          </UButton>
        </div>
      </div>
    </UModal>
  </div>
</template>

<script setup lang="ts">
// Composables
const route = useRoute()
const router = useRouter()
const {
  currentExam,
  examQuestions,
  currentAttempt,
  userAnswers,
  examAttempts,
  timeRemaining,
  loading,
  error,
  canTakeExam,
  getBestAttempt,
  formatTime,
  fetchExamByCourse,
  fetchExamQuestions,
  startExamAttempt,
  updateAnswer,
  submitExam: submitExamAction,
  fetchExamAttempts
} = useExams()

// Reactive data
const courseId = computed(() => route.params.id as string)
const currentQuestionIndex = ref(0)
const selectedAnswers = ref<Record<string, any>>({})
const showSubmitConfirm = ref(false)
const showResults = ref(false)
const examResult = ref<any>(null)

// Computed
const currentQuestion = computed(() => examQuestions.value[currentQuestionIndex.value])

const answeredQuestionsCount = computed(() => {
  return Object.keys(selectedAnswers.value).filter(questionId => {
    const answer = selectedAnswers.value[questionId]
    return answer !== undefined && answer !== null && answer !== ''
  }).length
})

const examProgress = computed(() => {
  if (examQuestions.value.length === 0) return 0
  return Math.round((answeredQuestionsCount.value / examQuestions.value.length) * 100)
})

const remainingAttempts = computed(() => {
  if (!currentExam.value) return 0
  const usedAttempts = examAttempts.value.filter(a => a.status === 'completed').length
  return Math.max(0, currentExam.value.maxAttempts - usedAttempts)
})

const hasPassedExam = computed(() => {
  return examAttempts.value.some(attempt => attempt.passed)
})

// Methods
const startExam = async () => {
  const attempt = await startExamAttempt(currentExam.value!.id, courseId.value)
  if (attempt) {
    await fetchExamQuestions(currentExam.value!.id, currentExam.value!.randomizeQuestions)
    selectedAnswers.value = {}
    currentQuestionIndex.value = 0
  }
}

const toggleMultipleChoiceAnswer = (questionId: string, optionKey: string) => {
  if (!selectedAnswers.value[questionId]) {
    selectedAnswers.value[questionId] = []
  }

  const answers = [...selectedAnswers.value[questionId]]
  const index = answers.indexOf(optionKey)

  if (index > -1) {
    answers.splice(index, 1)
  } else {
    answers.push(optionKey)
  }

  selectedAnswers.value[questionId] = answers
  updateAnswer(questionId, answers)
}

const nextQuestion = () => {
  if (currentQuestionIndex.value < examQuestions.value.length - 1) {
    currentQuestionIndex.value++
  }
}

const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
  }
}

const goToQuestion = (index: number) => {
  currentQuestionIndex.value = index
}

const getQuestionStatusClass = (questionId: string, index: number) => {
  const isAnswered = selectedAnswers.value[questionId] !== undefined &&
                    selectedAnswers.value[questionId] !== null &&
                    selectedAnswers.value[questionId] !== ''

  if (index === currentQuestionIndex.value) {
    return 'bg-blue-500 text-white'
  } else if (isAnswered) {
    return 'bg-green-500 text-white'
  } else {
    return 'bg-gray-300 text-gray-700 hover:bg-gray-400'
  }
}

const confirmSubmit = () => {
  showSubmitConfirm.value = true
}

const submitExam = async () => {
  showSubmitConfirm.value = false
  const result = await submitExamAction()

  if (result) {
    examResult.value = result
    showResults.value = true
  }
}

const retakeExam = () => {
  showResults.value = false
  selectedAnswers.value = {}
  currentQuestionIndex.value = 0
  examResult.value = null
}

const goBackToCourse = () => {
  router.push(`/academy/courses/${courseId.value}`)
}

// Load exam data
const loadExamData = async () => {
  if (!courseId.value) return

  const exam = await fetchExamByCourse(courseId.value)
  if (exam) {
    await fetchExamAttempts(exam.id)
    await fetchExamQuestions(exam.id, false) // Don't randomize for preview
  }
}

// SEO
definePageMeta({
  title: 'Course Exam',
  description: 'Take the course exam to test your knowledge'
})

// ExamResults component definition
const ExamResults = defineComponent({
  props: {
    result: Object,
    exam: Object,
    questions: Array,
    userAnswers: Object
  },
  emits: ['retake', 'back-to-course'],
  template: `
    <div class="p-6">
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 text-center">
          <div class="mb-6">
            <div v-if="result.passed" class="text-6xl text-green-500 mb-4">🎉</div>
            <div v-else class="text-6xl text-red-500 mb-4">😔</div>

            <h1 class="text-3xl font-bold text-gray-900 mb-2">
              {{ result.passed ? 'Congratulations!' : 'Better luck next time' }}
            </h1>
            <p class="text-lg text-gray-600">
              {{ result.passed ? 'You passed the exam!' : 'You did not pass the exam this time.' }}
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="text-center">
              <div class="text-3xl font-bold" :class="result.passed ? 'text-green-600' : 'text-red-600'">
                {{ result.score }}%
              </div>
              <div class="text-sm text-gray-600">Your Score</div>
            </div>
            <div class="text-center">
              <div class="text-3xl font-bold text-blue-600">{{ exam.passingScore }}%</div>
              <div class="text-sm text-gray-600">Passing Score</div>
            </div>
            <div class="text-center">
              <div class="text-3xl font-bold text-gray-600">{{ formatTime(result.timeTaken) }}</div>
              <div class="text-sm text-gray-600">Time Taken</div>
            </div>
          </div>

          <div class="flex items-center justify-center gap-4">
            <UButton variant="outline" @click="$emit('back-to-course')">
              <UIcon name="i-lucide-arrow-left" class="mr-2" />
              Back to Course
            </UButton>

            <UButton v-if="!result.passed" @click="$emit('retake')">
              <UIcon name="i-lucide-refresh-cw" class="mr-2" />
              Retake Exam
            </UButton>
          </div>
        </div>
      </div>
    </div>
  `,
  methods: {
    formatTime(seconds: number) {
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
    }
  }
})

// Load data on mount
onMounted(loadExamData)
</script>