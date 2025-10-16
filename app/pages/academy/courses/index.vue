<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Courses</h1>
        <p class="text-gray-600 mt-1">Explore our course library and continue your learning journey</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
      <div class="flex flex-wrap gap-4">
        <div class="flex-1 min-w-64">
          <UInput
            v-model="searchQuery"
            placeholder="Search courses..."
            icon="i-lucide-search"
            size="sm"
          />
        </div>
        <div class="flex gap-2">
          <USelect
            v-model="selectedCategory"
            :options="categories"
            placeholder="All Categories"
            size="sm"
            class="w-40"
          />
          <USelect
            v-model="selectedDifficulty"
            :options="difficulties"
            placeholder="All Levels"
            size="sm"
            class="w-32"
          />
          <UToggle v-model="showFeaturedOnly" />
          <span class="text-sm text-gray-600 self-center">Featured only</span>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">
      {{ error }}
    </div>

    <!-- Courses Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="course in filteredCourses"
        :key="course.id"
        class="bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition-shadow cursor-pointer"
        @click="navigateToCourse(course.id)"
      >
        <!-- Course Image/Thumbnail -->
        <div class="h-48 bg-gradient-to-br from-blue-500 to-purple-600 rounded-t-lg relative overflow-hidden">
          <img
            v-if="course.thumbnailUrl"
            :src="course.thumbnailUrl"
            :alt="course.title"
            class="w-full h-full object-cover"
          />
          <div v-else class="flex items-center justify-center h-full">
            <UIcon name="i-lucide-graduation-cap" class="text-4xl text-white" />
          </div>

          <!-- Featured Badge -->
          <div v-if="course.isFeatured" class="absolute top-3 right-3">
            <span class="bg-yellow-400 text-yellow-900 text-xs font-semibold px-2 py-1 rounded-full">
              Featured
            </span>
          </div>

          <!-- Difficulty Badge -->
          <div class="absolute bottom-3 left-3">
            <span
              class="text-xs font-semibold px-2 py-1 rounded-full"
              :class="getDifficultyBadgeClass(course.difficultyLevel)"
            >
              {{ course.difficultyLevel.charAt(0).toUpperCase() + course.difficultyLevel.slice(1) }}
            </span>
          </div>
        </div>

        <!-- Course Content -->
        <div class="p-5">
          <div class="flex items-start justify-between mb-2">
            <h3 class="text-lg font-semibold text-gray-900 line-clamp-2">
              {{ course.title }}
            </h3>
          </div>

          <p class="text-gray-600 text-sm mb-4 line-clamp-3">
            {{ course.description }}
          </p>

          <!-- Course Meta -->
          <div class="flex items-center gap-4 text-sm text-gray-500 mb-4">
            <div class="flex items-center gap-1">
              <UIcon name="i-lucide-clock" class="text-xs" />
              <span>{{ course.durationHours }}h</span>
            </div>
            <div v-if="course.category" class="flex items-center gap-1">
              <UIcon name="i-lucide-folder" class="text-xs" />
              <span>{{ course.category }}</span>
            </div>
          </div>

          <!-- Progress Bar (if user has started) -->
          <div v-if="getCourseProgress(course.id)" class="mb-3">
            <div class="flex justify-between text-sm mb-1">
              <span class="text-gray-600">Progress</span>
              <span class="font-medium">{{ getCourseProgress(course.id)?.progressPercentage }}%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="{ width: `${getCourseProgress(course.id)?.progressPercentage}%` }"
              ></div>
            </div>
          </div>

          <!-- Tags -->
          <div v-if="course.tags.length > 0" class="flex flex-wrap gap-1 mb-4">
            <span
              v-for="tag in course.tags.slice(0, 3)"
              :key="tag"
              class="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded-full"
            >
              {{ tag }}
            </span>
            <span
              v-if="course.tags.length > 3"
              class="text-xs text-gray-500"
            >
              +{{ course.tags.length - 3 }} more
            </span>
          </div>

          <!-- Action Button -->
          <UButton
            block
            :variant="getCourseProgress(course.id)?.status === 'completed' ? 'soft' : 'solid'"
            size="sm"
          >
            <span v-if="!getCourseProgress(course.id)">Start Course</span>
            <span v-else-if="getCourseProgress(course.id)?.status === 'completed'">
              <UIcon name="i-lucide-check" class="mr-1" />
              Completed
            </span>
            <span v-else>Continue</span>
          </UButton>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="!loading && !error && filteredCourses.length === 0" class="text-center py-12">
      <UIcon name="i-lucide-book-open" class="text-4xl text-gray-400 mx-auto mb-4" />
      <h3 class="text-lg font-medium text-gray-900 mb-2">No courses found</h3>
      <p class="text-gray-500">Try adjusting your search or filters to find what you're looking for.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Course, UserCourseProgress } from '~/composables/useCourses'

// Composables
const { courses, loading, error, fetchCourses } = useCourses()
const router = useRouter()

// Reactive data
const searchQuery = ref('')
const selectedCategory = ref('')
const selectedDifficulty = ref('')
const showFeaturedOnly = ref(false)

// Store user progress for all courses
const userProgressMap = ref<Record<string, UserCourseProgress>>({})

// Filter options
const categories = [
  { label: 'All Categories', value: '' },
  { label: 'Technology', value: 'technology' },
  { label: 'Business', value: 'business' },
  { label: 'Design', value: 'design' },
  { label: 'Marketing', value: 'marketing' },
  { label: 'Personal Development', value: 'personal-development' }
]

const difficulties = [
  { label: 'All Levels', value: '' },
  { label: 'Beginner', value: 'beginner' },
  { label: 'Intermediate', value: 'intermediate' },
  { label: 'Advanced', value: 'advanced' }
]

// Computed
const filteredCourses = computed(() => {
  let filtered = courses.value

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(course =>
      course.title.toLowerCase().includes(query) ||
      course.description?.toLowerCase().includes(query) ||
      course.tags.some(tag => tag.toLowerCase().includes(query))
    )
  }

  // Filter by category
  if (selectedCategory.value) {
    filtered = filtered.filter(course => course.category === selectedCategory.value)
  }

  // Filter by difficulty
  if (selectedDifficulty.value) {
    filtered = filtered.filter(course => course.difficultyLevel === selectedDifficulty.value)
  }

  // Filter by featured
  if (showFeaturedOnly.value) {
    filtered = filtered.filter(course => course.isFeatured)
  }

  return filtered
})

// Methods
const navigateToCourse = (courseId: string) => {
  router.push(`/academy/courses/${courseId}`)
}

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

const getCourseProgress = (courseId: string) => {
  return userProgressMap.value[courseId] || null
}

// Load user progress for visible courses
const loadUserProgress = async () => {
  if (!courses.value.length) return

  const { fetchUserCourseProgress } = useCourses()

  for (const course of courses.value) {
    const progress = await fetchUserCourseProgress(course.id)
    if (progress) {
      userProgressMap.value[course.id] = progress
    }
  }
}

// Watchers
watch(courses, loadUserProgress, { immediate: true })

// Watch filters and refetch
watchDebounced([searchQuery, selectedCategory, selectedDifficulty, showFeaturedOnly], async () => {
  await fetchCourses({
    search: searchQuery.value || undefined,
    category: selectedCategory.value || undefined,
    difficultyLevel: selectedDifficulty.value || undefined,
    isFeatured: showFeaturedOnly.value || undefined,
    isPublished: true
  })
}, { debounce: 300 })

// SEO
definePageMeta({
  title: 'Courses - Academy',
  description: 'Explore our comprehensive course library'
})

// Load initial data
onMounted(async () => {
  await fetchCourses({ isPublished: true })
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>