<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-20">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="p-6">
      <div class="bg-red-50 border border-red-200 rounded-lg p-4">
        <div class="flex items-start gap-3">
          <UIcon name="i-lucide-alert-circle" class="text-red-600 mt-0.5" />
          <div class="flex-1">
            <h3 class="font-medium text-red-800 mb-1">Unable to Load Course</h3>
            <p class="text-red-700 mb-2">{{ error }}</p>
            <p class="text-sm text-red-600 mb-4">Course ID: {{ courseId }}</p>
            <div class="flex gap-3">
              <UButton
                variant="outline"
                size="sm"
                @click="$router.push('/academy/courses')"
              >
                <UIcon name="i-lucide-arrow-left" class="mr-2" />
                Back to Courses
              </UButton>
              <UButton
                size="sm"
                @click="loadCourseData"
              >
                <UIcon name="i-lucide-refresh-cw" class="mr-2" />
                Retry
              </UButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- No Course Found State -->
    <div v-else-if="!loading && !error" class="p-6">
      <div class="bg-gray-50 border border-gray-200 rounded-lg p-8 text-center">
        <UIcon name="i-lucide-book-x" class="text-gray-400 mx-auto mb-4" size="xl" />
        <h3 class="font-medium text-gray-900 mb-2">Course Not Found</h3>
        <p class="text-gray-600 mb-2">The requested course could not be found.</p>
        <p class="text-sm text-gray-500 mb-6">Course ID: {{ courseId }}</p>
        <div class="flex justify-center gap-3">
          <UButton
            variant="outline"
            @click="$router.push('/academy/courses')"
          >
            <UIcon name="i-lucide-arrow-left" class="mr-2" />
            Browse Courses
          </UButton>
          <UButton
            @click="loadCourseData"
          >
            <UIcon name="i-lucide-refresh-cw" class="mr-2" />
            Retry
          </UButton>
        </div>
      </div>
    </div>

    <!-- Course Content -->
    <div v-else-if="currentCourse" class="pb-8">
      <!-- Course Header -->
      <div class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-6 py-8">
          <div class="flex items-start gap-6">
            <!-- Course Thumbnail -->
            <div class="w-64 h-40 rounded-lg overflow-hidden bg-gradient-to-br from-blue-500 to-purple-600 flex-shrink-0">
              <img
                v-if="currentCourse.thumbnailUrl"
                :src="currentCourse.thumbnailUrl"
                :alt="currentCourse.title"
                class="w-full h-full object-cover"
              />
              <div v-else class="flex items-center justify-center h-full">
                <UIcon name="i-lucide-graduation-cap" class="text-4xl text-white" />
              </div>
            </div>

            <!-- Course Info -->
            <div class="flex-1">
              <div class="flex items-start justify-between mb-4">
                <div>
                  <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ currentCourse.title }}</h1>
                  <p class="text-lg text-gray-600">{{ currentCourse.description }}</p>
                </div>
                <div class="flex items-center gap-2">
                  <span
                    class="text-sm font-semibold px-3 py-1 rounded-full"
                    :class="getDifficultyBadgeClass(currentCourse.difficultyLevel)"
                  >
                    {{ currentCourse.difficultyLevel.charAt(0).toUpperCase() + currentCourse.difficultyLevel.slice(1) }}
                  </span>
                  <span v-if="currentCourse.isFeatured" class="bg-yellow-400 text-yellow-900 text-sm font-semibold px-3 py-1 rounded-full">
                    Featured
                  </span>
                </div>
              </div>

              <!-- Course Meta -->
              <div class="flex items-center gap-6 text-sm text-gray-600 mb-6">
                <div class="flex items-center gap-1">
                  <UIcon name="i-lucide-clock" />
                  <span>{{ currentCourse.durationHours }} hours</span>
                </div>
                <div class="flex items-center gap-1">
                  <UIcon name="i-lucide-book-open" />
                  <span>{{ lessons.length }} lessons</span>
                </div>
                <div v-if="currentCourse.category" class="flex items-center gap-1">
                  <UIcon name="i-lucide-folder" />
                  <span>{{ currentCourse.category }}</span>
                </div>
              </div>

              <!-- Progress -->
              <div v-if="userProgress" class="mb-6">
                <div class="flex justify-between text-sm mb-2">
                  <span class="font-medium text-gray-700">Your Progress</span>
                  <span class="font-semibold text-blue-600">{{ userProgress.progressPercentage }}% Complete</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-3">
                  <div
                    class="bg-blue-600 h-3 rounded-full transition-all duration-300"
                    :style="{ width: `${userProgress.progressPercentage}%` }"
                  ></div>
                </div>
                <div class="flex justify-between text-xs text-gray-500 mt-1">
                  <span>{{ getCompletedLessonsCount() }} of {{ lessons.length }} lessons completed</span>
                  <span>{{ userProgress.status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()) }}</span>
                </div>
              </div>

              <!-- Action Buttons -->
              <div v-if="lessons.length > 0" class="flex gap-3">
                <UButton
                  v-if="!userProgress || userProgress.status === 'not_started'"
                  size="lg"
                  @click="startCourse"
                >
                  Start Course
                </UButton>
                <UButton
                  v-else-if="userProgress.status === 'in_progress'"
                  size="lg"
                  @click="continueToNextLesson"
                >
                  Continue Learning
                </UButton>
                <UButton
                  v-else-if="userProgress.status === 'completed'"
                  size="lg"
                  variant="soft"
                  @click="reviewCourse"
                >
                  <UIcon name="i-lucide-check" class="mr-2" />
                  Review Course
                </UButton>

                <!-- Take Exam Button -->
                <UButton
                  v-if="canTakeExam"
                  size="lg"
                  variant="outline"
                  @click="navigateToExam"
                >
                  <UIcon name="i-lucide-file-text" class="mr-2" />
                  Take Exam
                </UButton>
              </div>

              <!-- Tags -->
              <div v-if="currentCourse.tags.length > 0" class="flex flex-wrap gap-2 mt-6">
                <span
                  v-for="tag in currentCourse.tags"
                  :key="tag"
                  class="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded-full"
                >
                  {{ tag }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Course Content -->
      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Lessons List -->
          <div class="lg:col-span-2">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200">
              <div class="p-6 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">Course Content</h2>
                <p class="text-gray-600 mt-1">{{ lessons.length }} lessons • {{ currentCourse.durationHours }} hours total</p>
              </div>

              <div v-if="lessons.length > 0" class="divide-y divide-gray-200">
                <div
                  v-for="(lesson, index) in lessons"
                  :key="lesson.id"
                  class="p-6 hover:bg-gray-50 cursor-pointer transition-colors"
                  @click="navigateToLesson(lesson.id)"
                >
                  <div class="flex items-start gap-4">
                    <!-- Lesson Status Icon -->
                    <div class="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center mt-1">
                      <div
                        v-if="isLessonCompleted(lesson.id)"
                        class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center"
                      >
                        <UIcon name="i-lucide-check" class="text-white text-sm" />
                      </div>
                      <div
                        v-else-if="getLessonProgress(lesson.id)?.status === 'in_progress'"
                        class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center"
                      >
                        <UIcon name="i-lucide-play" class="text-white text-sm" />
                      </div>
                      <div
                        v-else
                        class="w-8 h-8 border-2 border-gray-300 rounded-full flex items-center justify-center text-gray-500 font-medium text-sm"
                      >
                        {{ index + 1 }}
                      </div>
                    </div>

                    <!-- Lesson Content -->
                    <div class="flex-1">
                      <h3 class="font-medium text-gray-900 mb-1">{{ lesson.title }}</h3>
                      <p v-if="lesson.description" class="text-gray-600 text-sm mb-2">{{ lesson.description }}</p>

                      <div class="flex items-center gap-4 text-sm text-gray-500">
                        <div class="flex items-center gap-1">
                          <UIcon name="i-lucide-clock" class="text-xs" />
                          <span>{{ lesson.durationMinutes }} min</span>
                        </div>

                        <!-- Progress for this lesson -->
                        <div v-if="getLessonProgress(lesson.id)" class="flex items-center gap-1">
                          <UIcon name="i-lucide-trending-up" class="text-xs" />
                          <span>{{ getLessonProgress(lesson.id)?.completionPercentage }}% complete</span>
                        </div>
                      </div>
                    </div>

                    <!-- Navigation Arrow -->
                    <div class="flex-shrink-0">
                      <UIcon name="i-lucide-chevron-right" class="text-gray-400" />
                    </div>
                  </div>
                </div>
              </div>

              <!-- No Lessons State -->
              <div v-else class="p-8 text-center">
                <UIcon name="i-lucide-book-x" class="text-gray-400 mx-auto mb-4" size="xl" />
                <h3 class="font-medium text-gray-900 mb-2">No Lessons Available</h3>
                <p class="text-gray-600 mb-2">This course doesn't have any lessons yet, or they haven't been published.</p>
                <div class="bg-gray-100 border border-gray-200 rounded p-3 mb-4 text-sm text-left">
                  <p><strong>Debug Info:</strong></p>
                  <p>Course ID: {{ courseId }}</p>
                  <p>Course Title: {{ currentCourse?.title || 'Unknown' }}</p>
                  <p>Lessons Count: {{ lessons.length }}</p>
                  <p>Loading: {{ loading }}</p>
                  <p>Error: {{ error || 'None' }}</p>
                </div>
                <UButton
                  variant="outline"
                  @click="$router.push('/academy/courses')"
                >
                  <UIcon name="i-lucide-arrow-left" class="mr-2" />
                  Browse Other Courses
                </UButton>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="space-y-6">
            <!-- Exam Information -->
            <div v-if="hasExam" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 class="font-semibold text-gray-900 mb-4">Course Exam</h3>
              <div v-if="examAttempts && examAttempts.length > 0" class="space-y-3">
                <div v-for="attempt in examAttempts.slice(0, 3)" :key="attempt.id" class="text-sm">
                  <div class="flex justify-between items-center">
                    <span class="text-gray-600">Attempt {{ attempt.attemptNumber }}</span>
                    <span
                      class="font-medium"
                      :class="attempt.passed ? 'text-green-600' : 'text-red-600'"
                    >
                      {{ attempt.score }}%
                    </span>
                  </div>
                  <div class="flex items-center gap-2 mt-1">
                    <span
                      class="text-xs px-2 py-1 rounded-full"
                      :class="attempt.passed ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                    >
                      {{ attempt.passed ? 'Passed' : 'Failed' }}
                    </span>
                    <span class="text-xs text-gray-500">
                      {{ new Date(attempt.completedAt || attempt.startedAt).toLocaleDateString() }}
                    </span>
                  </div>
                </div>
              </div>
              <div v-else class="text-sm text-gray-600">
                Complete all lessons to unlock the exam
              </div>
            </div>

            <!-- Course Stats -->
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <h3 class="font-semibold text-gray-900 mb-4">Your Statistics</h3>
              <div class="space-y-3">
                <div class="flex justify-between">
                  <span class="text-gray-600">Lessons Completed</span>
                  <span class="font-medium">{{ getCompletedLessonsCount() }}/{{ lessons.length }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-600">Time Spent</span>
                  <span class="font-medium">{{ getTotalTimeSpent() }}</span>
                </div>
                <div v-if="userProgress?.startedAt" class="flex justify-between">
                  <span class="text-gray-600">Started</span>
                  <span class="font-medium">{{ new Date(userProgress.startedAt).toLocaleDateString() }}</span>
                </div>
                <div v-if="userProgress?.completedAt" class="flex justify-between">
                  <span class="text-gray-600">Completed</span>
                  <span class="font-medium">{{ new Date(userProgress.completedAt).toLocaleDateString() }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Composables
const route = useRoute()
const router = useRouter()
const {
  currentCourse,
  lessons,
  userProgress,
  lessonProgress,
  loading,
  error,
  fetchCourse,
  fetchLessons,
  fetchUserCourseProgress,
  fetchLessonProgress,
  updateCourseProgress,
  getLessonProgress,
  isLessonCompleted
} = useCourses()

const {
  fetchExamByCourse,
  fetchExamAttempts,
  canTakeExam,
  examAttempts
} = useExams()

// Reactive data
const courseId = computed(() => route.params.id as string)
const hasExam = ref(false)

// Methods
const getDifficultyBadgeClass = (difficulty: string) => {
  switch (difficulty) {
    case 'beginner':
      return 'bg-green-100 text-green-800'
    case 'intermediate':
      return 'bg-yellow-100 text-yellow-800'
    case 'advanced':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getCompletedLessonsCount = () => {
  return lessonProgress.value.filter(p => p.status === 'completed').length
}

const getTotalTimeSpent = () => {
  const totalSeconds = lessonProgress.value.reduce((total, progress) => {
    return total + (progress.timeSpentSeconds || 0)
  }, 0)

  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)

  if (hours > 0) {
    return `${hours}h ${minutes}m`
  }
  return `${minutes}m`
}

const startCourse = async () => {
  await updateCourseProgress(courseId.value, 'in_progress')

  // Navigate to first lesson
  if (lessons.value.length > 0) {
    router.push(`/academy/courses/${courseId.value}/lessons/${lessons.value[0].id}`)
  }
}

const continueToNextLesson = () => {
  // Find the next incomplete lesson
  const nextLesson = lessons.value.find(lesson => {
    const progress = getLessonProgress(lesson.id)
    return !progress || progress.status !== 'completed'
  })

  if (nextLesson) {
    router.push(`/academy/courses/${courseId.value}/lessons/${nextLesson.id}`)
  } else {
    // All lessons completed, go to first lesson for review
    router.push(`/academy/courses/${courseId.value}/lessons/${lessons.value[0].id}`)
  }
}

const reviewCourse = () => {
  // Navigate to first lesson for review
  if (lessons.value.length > 0) {
    router.push(`/academy/courses/${courseId.value}/lessons/${lessons.value[0].id}`)
  }
}

const navigateToLesson = (lessonId: string) => {
  router.push(`/academy/courses/${courseId.value}/lessons/${lessonId}`)
}

const navigateToExam = () => {
  router.push(`/academy/courses/${courseId.value}/exam`)
}

// Load data
const loadCourseData = async () => {
  if (!courseId.value) return

  console.log('Loading course data for ID:', courseId.value)

  // Load course details
  await fetchCourse(courseId.value)
  console.log('Current course:', currentCourse.value)

  if (currentCourse.value) {
    // Load lessons
    await fetchLessons(courseId.value)
    console.log('Lessons loaded:', lessons.value.length, lessons.value)

    // Load user progress
    await fetchUserCourseProgress(courseId.value)
    await fetchLessonProgress(courseId.value)

    // Check for exam
    const exam = await fetchExamByCourse(courseId.value)
    hasExam.value = !!exam

    if (exam) {
      await fetchExamAttempts(exam.id)
    }
  } else {
    console.log('No course found for ID:', courseId.value)
  }
}

// SEO
definePageMeta({
  title: 'Course Details',
  description: 'View course details and track your progress'
})

// Load data on mount and route change
onMounted(loadCourseData)
watch(() => route.params.id, loadCourseData)
</script>