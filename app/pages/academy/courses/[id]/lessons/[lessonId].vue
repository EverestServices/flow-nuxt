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
            <h3 class="font-medium text-red-800 mb-1">Unable to Load Lesson</h3>
            <p class="text-red-700 mb-4">{{ error }}</p>
            <div class="flex gap-3">
              <UButton
                variant="outline"
                size="sm"
                @click="goBackToCourse"
              >
                <UIcon name="i-lucide-arrow-left" class="mr-2" />
                Back to Course
              </UButton>
              <UButton
                variant="outline"
                size="sm"
                @click="$router.push('/academy/courses')"
              >
                <UIcon name="i-lucide-book-open" class="mr-2" />
                Browse Courses
              </UButton>
              <UButton
                size="sm"
                @click="loadLessonData"
              >
                <UIcon name="i-lucide-refresh-cw" class="mr-2" />
                Retry
              </UButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- No Lesson Found State -->
    <div v-else-if="!loading && !error" class="p-6">
      <div class="bg-gray-50 border border-gray-200 rounded-lg p-8 text-center">
        <UIcon name="i-lucide-book-x" class="text-gray-400 mx-auto mb-4" size="xl" />
        <h3 class="font-medium text-gray-900 mb-2">Lesson Not Available</h3>
        <p class="text-slate-600 mb-6">The requested lesson could not be found or may not be published yet.</p>
        <div class="flex justify-center gap-3">
          <UButton
            variant="outline"
            @click="goBackToCourse"
          >
            <UIcon name="i-lucide-arrow-left" class="mr-2" />
            Back to Course
          </UButton>
          <UButton
            @click="$router.push('/academy/courses')"
          >
            <UIcon name="i-lucide-book-open" class="mr-2" />
            Browse Courses
          </UButton>
        </div>
      </div>
    </div>

    <!-- Lesson Content -->
    <div v-else-if="currentLesson" class="pb-8">
      <!-- Header -->
      <div class="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div class="max-w-7xl mx-auto px-6 py-4">
          <div class="flex items-center justify-between">
            <!-- Back Navigation -->
            <div class="flex items-center gap-4">
              <UButton
                variant="ghost"
                size="sm"
                @click="goBackToCourse"
              >
                <UIcon name="i-lucide-arrow-left" class="mr-2" />
                Back to Course
              </UButton>
              <div class="h-6 w-px bg-gray-300"></div>
              <div>
                <h1 class="font-semibold text-gray-900">{{ currentLesson.title }}</h1>
                <p class="text-sm text-slate-600">
                  Lesson {{ currentLesson.lessonOrder }} of {{ totalLessons }}
                </p>
              </div>
            </div>

            <!-- Progress and Navigation -->
            <div class="flex items-center gap-4">
              <!-- Lesson Progress -->
              <div class="flex items-center gap-2 text-sm">
                <span class="text-slate-600">Progress:</span>
                <span class="font-medium">{{ lessonProgressPercentage }}%</span>
              </div>

              <!-- Navigation Buttons -->
              <div class="flex items-center gap-2">
                <UButton
                  v-if="previousLesson"
                  variant="outline"
                  size="sm"
                  @click="navigateToLesson(previousLesson.id)"
                >
                  <UIcon name="i-lucide-chevron-left" class="mr-1" />
                  Previous
                </UButton>

                <UButton
                  v-if="nextLesson"
                  size="sm"
                  @click="navigateToLesson(nextLesson.id)"
                  :disabled="!canProceedToNext"
                >
                  Next
                  <UIcon name="i-lucide-chevron-right" class="ml-1" />
                </UButton>

                <UButton
                  v-else-if="allLessonsCompleted"
                  size="sm"
                  @click="navigateToExam"
                >
                  Take Exam
                  <UIcon name="i-lucide-file-text" class="ml-1" />
                </UButton>
              </div>
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="mt-4">
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="{ width: `${overallCourseProgress}%` }"
              ></div>
            </div>
            <div class="flex justify-between text-xs text-gray-500 mt-1">
              <span>{{ completedLessonsCount }} of {{ totalLessons }} lessons completed</span>
              <span>{{ overallCourseProgress }}% complete</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
          <!-- Lesson Content -->
          <div class="lg:col-span-3">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
              <!-- Video/Media Section -->
              <div v-if="videoResources.length > 0" class="relative">
                <div class="aspect-video bg-black">
                  <video
                    ref="videoPlayer"
                    class="w-full h-full"
                    controls
                    preload="metadata"
                    @timeupdate="onVideoTimeUpdate"
                    @ended="onVideoEnded"
                    @loadedmetadata="onVideoLoaded"
                  >
                    <source :src="currentVideo.url" :type="currentVideo.mimeType || 'video/mp4'">
                    Your browser does not support the video tag.
                  </video>
                </div>

                <!-- Video Controls -->
                <div v-if="videoResources.length > 1" class="p-4 border-b border-gray-200">
                  <div class="flex items-center gap-2 overflow-x-auto">
                    <button
                      v-for="(video, index) in videoResources"
                      :key="video.id"
                      class="flex-shrink-0 px-3 py-2 text-sm rounded-lg border transition-colors"
                      :class="currentVideoIndex === index
                        ? 'bg-blue-50 border-blue-200 text-blue-600'
                        : 'bg-gray-50 border-gray-200 text-slate-600 hover:bg-gray-100'"
                      @click="switchVideo(index)"
                    >
                      {{ video.title }}
                    </button>
                  </div>
                </div>
              </div>

              <!-- Lesson Text Content -->
              <div class="p-6">
                <div class="prose max-w-none">
                  <h2 class="text-2xl font-bold text-gray-900 mb-4">{{ currentLesson.title }}</h2>

                  <div v-if="currentLesson.description" class="text-lg text-slate-600 mb-6">
                    {{ currentLesson.description }}
                  </div>

                  <div
                    v-if="currentLesson.content"
                    class="prose-content"
                    v-html="formattedContent"
                  ></div>

                  <div v-else class="text-gray-500 italic">
                    No text content available for this lesson.
                  </div>
                </div>

                <!-- Additional Resources -->
                <div v-if="documentResources.length > 0 || linkResources.length > 0" class="mt-8 pt-6 border-t border-gray-200">
                  <h3 class="text-lg font-semibold text-gray-900 mb-4">Additional Resources</h3>

                  <!-- Documents -->
                  <div v-if="documentResources.length > 0" class="mb-6">
                    <h4 class="text-md font-medium text-gray-800 mb-3">Documents</h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <a
                        v-for="document in documentResources"
                        :key="document.id"
                        :href="document.url"
                        target="_blank"
                        class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                      >
                        <UIcon name="i-lucide-file-text" class="text-blue-600" />
                        <div class="flex-1">
                          <div class="font-medium text-gray-900">{{ document.title }}</div>
                          <div class="text-sm text-gray-500">
                            {{ document.mimeType }}
                            <span v-if="document.fileSize">
                              • {{ formatFileSize(document.fileSize) }}
                            </span>
                          </div>
                        </div>
                        <UIcon name="i-lucide-external-link" class="text-gray-400" />
                      </a>
                    </div>
                  </div>

                  <!-- Links -->
                  <div v-if="linkResources.length > 0">
                    <h4 class="text-md font-medium text-gray-800 mb-3">Links</h4>
                    <div class="space-y-2">
                      <a
                        v-for="link in linkResources"
                        :key="link.id"
                        :href="link.url"
                        target="_blank"
                        class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                      >
                        <UIcon name="i-lucide-link" class="text-green-600" />
                        <div class="flex-1">
                          <div class="font-medium text-gray-900">{{ link.title }}</div>
                        </div>
                        <UIcon name="i-lucide-external-link" class="text-gray-400" />
                      </a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Mark Complete Button -->
              <div class="p-6 border-t border-gray-200 bg-gray-50">
                <div class="flex items-center justify-between">
                  <div class="text-sm text-slate-600">
                    {{ lessonProgressPercentage === 100 ? 'Lesson completed!' : 'Mark as complete when you finish this lesson' }}
                  </div>
                  <UButton
                    v-if="lessonProgressPercentage < 100"
                    @click="markLessonComplete"
                    :loading="updating"
                  >
                    <UIcon name="i-lucide-check" class="mr-2" />
                    Mark as Complete
                  </UButton>
                  <div v-else class="flex items-center gap-2 text-green-600">
                    <UIcon name="i-lucide-check-circle" />
                    <span class="font-medium">Completed</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="lg:col-span-1">
            <!-- Lesson List -->
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
              <div class="p-4 border-b border-gray-200">
                <h3 class="font-semibold text-gray-900">Course Lessons</h3>
              </div>
              <div class="max-h-96 overflow-y-auto">
                <div
                  v-for="lesson in lessons"
                  :key="lesson.id"
                  class="p-3 border-b border-gray-100 last:border-b-0 cursor-pointer transition-colors"
                  :class="lesson.id === currentLesson.id ? 'bg-blue-50' : 'hover:bg-gray-50'"
                  @click="navigateToLesson(lesson.id)"
                >
                  <div class="flex items-start gap-3">
                    <!-- Status Icon -->
                    <div class="flex-shrink-0 mt-1">
                      <div
                        v-if="isLessonCompleted(lesson.id)"
                        class="w-5 h-5 bg-green-500 rounded-full flex items-center justify-center"
                      >
                        <UIcon name="i-lucide-check" class="text-white text-xs" />
                      </div>
                      <div
                        v-else-if="lesson.id === currentLesson.id"
                        class="w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center"
                      >
                        <UIcon name="i-lucide-play" class="text-white text-xs" />
                      </div>
                      <div
                        v-else
                        class="w-5 h-5 border-2 border-gray-300 rounded-full flex items-center justify-center text-gray-500 text-xs font-medium"
                      >
                        {{ lesson.lessonOrder }}
                      </div>
                    </div>

                    <!-- Lesson Info -->
                    <div class="flex-1 min-w-0">
                      <div class="font-medium text-sm text-gray-900 line-clamp-2">
                        {{ lesson.title }}
                      </div>
                      <div class="text-xs text-gray-500 mt-1">
                        {{ lesson.durationMinutes }} min
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Lesson Stats -->
            <div class="bg-white rounded-lg shadow-sm border border-gray-200">
              <div class="p-4 border-b border-gray-200">
                <h3 class="font-semibold text-gray-900">Your Progress</h3>
              </div>
              <div class="p-4 space-y-3">
                <div class="flex justify-between text-sm">
                  <span class="text-slate-600">Time in this lesson</span>
                  <span class="font-medium">{{ formatDuration(timeSpentInLesson) }}</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span class="text-slate-600">Total time spent</span>
                  <span class="font-medium">{{ formatDuration(totalTimeSpent) }}</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span class="text-slate-600">Course progress</span>
                  <span class="font-medium">{{ overallCourseProgress }}%</span>
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
  currentLesson,
  lessons,
  lessonResources,
  lessonProgress,
  fetchCourse,
  fetchLessons,
  fetchLessonResources,
  fetchLessonProgress,
  updateLessonProgress,
  getLessonProgress,
  isLessonCompleted,
  getNextLesson,
  getPreviousLesson,
  loading,
  error
} = useCourses()

const { fetchExamByCourse } = useExams()

// Reactive data
const courseId = computed(() => route.params.id as string)
const lessonId = computed(() => route.params.lessonId as string)
const videoPlayer = ref<HTMLVideoElement>()
const currentVideoIndex = ref(0)
const timeSpentInLesson = ref(0)
const startTime = ref(Date.now())
const timeSpentInterval = ref<NodeJS.Timeout>()
const updating = ref(false)
const videoProgress = ref(0)
const hasExam = ref(false)

// Computed
const videoResources = computed(() =>
  lessonResources.value.filter(resource => resource.resourceType === 'video')
    .sort((a, b) => a.resourceOrder - b.resourceOrder)
)

const documentResources = computed(() =>
  lessonResources.value.filter(resource => resource.resourceType === 'document')
    .sort((a, b) => a.resourceOrder - b.resourceOrder)
)

const linkResources = computed(() =>
  lessonResources.value.filter(resource => resource.resourceType === 'link')
    .sort((a, b) => a.resourceOrder - b.resourceOrder)
)

const currentVideo = computed(() => videoResources.value[currentVideoIndex.value])

const totalLessons = computed(() => lessons.value.length)

const completedLessonsCount = computed(() =>
  lessonProgress.value.filter(p => p.status === 'completed').length
)

const overallCourseProgress = computed(() => {
  if (totalLessons.value === 0) return 0
  return Math.round((completedLessonsCount.value / totalLessons.value) * 100)
})

const lessonProgressPercentage = computed(() => {
  const progress = getLessonProgress(lessonId.value)
  return progress?.completionPercentage || 0
})

const totalTimeSpent = computed(() => {
  return lessonProgress.value.reduce((total, progress) => {
    return total + (progress.timeSpentSeconds || 0)
  }, 0) + timeSpentInLesson.value
})

const nextLesson = computed(() => {
  if (!currentLesson.value) return null
  return getNextLesson(currentLesson.value.lessonOrder)
})

const previousLesson = computed(() => {
  if (!currentLesson.value) return null
  return getPreviousLesson(currentLesson.value.lessonOrder)
})

const canProceedToNext = computed(() => {
  return lessonProgressPercentage.value === 100
})

const allLessonsCompleted = computed(() => {
  return completedLessonsCount.value === totalLessons.value && hasExam.value
})

const formattedContent = computed(() => {
  if (!currentLesson.value?.content) return ''

  // Simple formatting - convert line breaks to paragraphs
  return currentLesson.value.content
    .split('\n\n')
    .map(paragraph => `<p>${paragraph.replace(/\n/g, '<br>')}</p>`)
    .join('')
})

// Methods
const switchVideo = (index: number) => {
  currentVideoIndex.value = index
  videoProgress.value = 0
}

const onVideoTimeUpdate = () => {
  if (videoPlayer.value) {
    const video = videoPlayer.value
    const progress = Math.round((video.currentTime / video.duration) * 100)
    videoProgress.value = Math.max(videoProgress.value, progress)

    // Update lesson progress based on video progress
    updateLessonProgressPercentage()
  }
}

const onVideoEnded = () => {
  videoProgress.value = 100
  updateLessonProgressPercentage()
}

const onVideoLoaded = () => {
  // Start tracking time when video loads
  if (!timeSpentInterval.value) {
    startTimeTracking()
  }
}

const updateLessonProgressPercentage = async () => {
  // Calculate progress based on video completion and content engagement
  let progressPercentage = videoProgress.value

  // If there are multiple videos, calculate based on all videos
  if (videoResources.value.length > 1) {
    progressPercentage = Math.round(videoProgress.value / videoResources.value.length)
  }

  // Consider lesson as started if progress > 0
  const status = progressPercentage >= 100 ? 'completed' :
                 progressPercentage > 0 ? 'in_progress' : 'not_started'

  if (progressPercentage > lessonProgressPercentage.value) {
    await updateLessonProgress(lessonId.value, courseId.value, status, progressPercentage)
  }
}

const markLessonComplete = async () => {
  try {
    updating.value = true
    await updateLessonProgress(lessonId.value, courseId.value, 'completed', 100)
  } finally {
    updating.value = false
  }
}

const startTimeTracking = () => {
  startTime.value = Date.now()
  timeSpentInLesson.value = 0

  timeSpentInterval.value = setInterval(() => {
    timeSpentInLesson.value = Math.floor((Date.now() - startTime.value) / 1000)
  }, 1000)
}

const stopTimeTracking = async () => {
  if (timeSpentInterval.value) {
    clearInterval(timeSpentInterval.value)
    timeSpentInterval.value = undefined
  }

  // Save time spent to database
  if (timeSpentInLesson.value > 0) {
    const currentProgress = getLessonProgress(lessonId.value)
    const totalTime = (currentProgress?.timeSpentSeconds || 0) + timeSpentInLesson.value

    // Update with accumulated time
    await updateLessonProgress(
      lessonId.value,
      courseId.value,
      currentProgress?.status || 'in_progress',
      currentProgress?.completionPercentage,
    )
  }
}

const navigateToLesson = (targetLessonId: string) => {
  router.push(`/academy/courses/${courseId.value}/lessons/${targetLessonId}`)
}

const goBackToCourse = () => {
  router.push(`/academy/courses/${courseId.value}`)
}

const navigateToExam = () => {
  router.push(`/academy/courses/${courseId.value}/exam`)
}

const formatDuration = (seconds: number): string => {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const remainingSeconds = seconds % 60

  if (hours > 0) {
    return `${hours}h ${minutes}m ${remainingSeconds}s`
  } else if (minutes > 0) {
    return `${minutes}m ${remainingSeconds}s`
  }
  return `${remainingSeconds}s`
}

const formatFileSize = (bytes: number): string => {
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  if (bytes === 0) return '0 Bytes'
  const i = Math.floor(Math.log(bytes) / Math.log(1024))
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i]
}

// Load lesson data
const loadLessonData = async () => {
  if (!courseId.value || !lessonId.value) {
    error.value = 'Invalid course or lesson ID'
    return
  }

  try {
    loading.value = true
    error.value = null

    // Load course and lessons if not already loaded
    if (!currentCourse.value) {
      await fetchCourse(courseId.value)
      if (!currentCourse.value) {
        error.value = 'Course not found. Please check if the course exists.'
        return
      }
    }

    if (!lessons.value.length) {
      await fetchLessons(courseId.value)
      if (!lessons.value.length) {
        error.value = 'No lessons found for this course.'
        return
      }
    }

    // Find and set current lesson
    const lesson = lessons.value.find(l => l.id === lessonId.value)
    if (!lesson) {
      error.value = 'Lesson not found. Please check if the lesson exists in this course.'
      return
    }

    currentLesson.value = lesson

    // Load lesson resources and progress
    await fetchLessonResources(lessonId.value)
    await fetchLessonProgress(courseId.value)

    // Check for exam
    try {
      const exam = await fetchExamByCourse(courseId.value)
      hasExam.value = !!exam
    } catch (examError) {
      console.warn('Could not load exam information:', examError)
      hasExam.value = false
    }

    // Start time tracking
    startTimeTracking()

    // Mark lesson as started if not already
    const progress = getLessonProgress(lessonId.value)
    if (!progress || progress.status === 'not_started') {
      await updateLessonProgress(lessonId.value, courseId.value, 'in_progress', 0)
    }
  } catch (err) {
    console.error('Error loading lesson data:', err)
    error.value = 'Failed to load lesson. Please try refreshing the page.'
  } finally {
    loading.value = false
  }
}

// Cleanup
onUnmounted(() => {
  stopTimeTracking()
})

// Watch for route changes
watch(() => route.params.lessonId, async (newLessonId) => {
  if (newLessonId) {
    await stopTimeTracking()
    await loadLessonData()
  }
})

// SEO
definePageMeta({
  title: 'Lesson',
  description: 'Learn with interactive lessons and track your progress'
})

// Load data on mount
onMounted(loadLessonData)
</script>

<style scoped>
.prose-content {
  color: rgb(75 85 99); /* text-gray-600 equivalent */
  line-height: 1.625;
}

.prose-content p {
  margin-bottom: 1rem;
}

.prose-content h1,
.prose-content h2,
.prose-content h3,
.prose-content h4,
.prose-content h5,
.prose-content h6 {
  font-weight: 600;
  color: rgb(17 24 39); /* text-gray-900 equivalent */
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
}

.prose-content ul,
.prose-content ol {
  margin-bottom: 1rem;
  padding-left: 1.5rem;
}

.prose-content li {
  margin-bottom: 0.25rem;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>