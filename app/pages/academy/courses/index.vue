<template>
  <div>
    <!-- Header matching dashboard style -->
    <div class="flex h-24 items-center">
      <div class="text-2xl font-light">Courses <span class="font-black">& Exams</span></div>
    </div>

    <div class="flex flex-col space-y-8">
      <!-- Welcome Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">
        <div class="basis-0 flex flex-col items-start justify-center">
          <div class="text-5xl font-thin outfit">
            Explore our <strong class="font-black">courses</strong> and<br />
            continue your <strong class="font-black">learning journey</strong>
          </div>
          <div class="text-2xl outfit font-thin text-gray-600 dark:text-gray-400 mt-4">
            {{ filteredCourses.length }} courses available
          </div>
        </div>

        <!-- Stats Cards -->
        <div class="flex flex-col basis-0 items-start justify-center">
          <div class="grid grid-cols-3 gap-4 w-full">
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-blue-600 dark:text-blue-400">
                {{ courses.length }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Total Courses</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-green-600 dark:text-green-400">
                {{ completedCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Completed</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-purple-600 dark:text-purple-400">
                {{ inProgressCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">In Progress</div>
            </UIBox>
          </div>
        </div>
      </div>

      <!-- Filters Section -->
      <UIBox>
        <div class="flex items-center gap-3 p-4">
          <div class="flex-1">
            <UIInput
              v-model="searchQuery"
              placeholder="Search courses..."
              icon="i-lucide-search"
            />
          </div>
          <UISelect
            v-model="selectedCategory"
            :options="categories"
            size="sm"
            class="w-40"
          />
          <UISelect
            v-model="selectedDifficulty"
            :options="difficulties"
            size="sm"
            class="w-32"
          />
          <div class="flex items-center gap-2 whitespace-nowrap">
            <label class="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                v-model="showFeaturedOnly"
                class="sr-only peer"
              />
              <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
            <span class="text-xs text-gray-600 dark:text-gray-400">Featured</span>
          </div>
        </div>
      </UIBox>

      <!-- Loading State -->
      <UIBox v-if="loading" class="p-12">
        <div class="flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      </UIBox>

      <!-- Error State -->
      <UIAlert v-else-if="error" variant="danger">
        {{ error }}
      </UIAlert>

      <!-- Courses Grid -->
      <div v-else-if="filteredCourses.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <UIBox
          v-for="course in filteredCourses"
          :key="course.id"
          class="cursor-pointer hover:shadow-xl transition-all duration-200 overflow-hidden"
          @click="navigateToCourse(course.id)"
        >
          <!-- Course Image/Thumbnail -->
          <div class="h-48 bg-gradient-to-br from-blue-500 to-purple-600 relative overflow-hidden">
            <img
              v-if="course.thumbnailUrl"
              :src="course.thumbnailUrl"
              :alt="course.title"
              class="w-full h-full object-cover"
            />
            <div v-else class="flex items-center justify-center h-full">
              <Icon name="i-lucide-graduation-cap" class="w-16 h-16 text-white" />
            </div>

            <!-- Featured Badge -->
            <div v-if="course.isFeatured" class="absolute top-3 right-3">
              <span class="bg-yellow-400 text-yellow-900 text-xs font-semibold px-3 py-1 rounded-full">
                Featured
              </span>
            </div>

            <!-- Difficulty Badge -->
            <div class="absolute bottom-3 left-3">
              <span
                class="text-xs font-semibold px-3 py-1 rounded-full"
                :class="getDifficultyBadgeClass(course.difficultyLevel)"
              >
                {{ course.difficultyLevel.charAt(0).toUpperCase() + course.difficultyLevel.slice(1) }}
              </span>
            </div>
          </div>

          <!-- Course Content -->
          <div class="p-5">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2">
              {{ course.title }}
            </h3>

            <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">
              {{ course.description }}
            </p>

            <!-- Course Meta -->
            <div class="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-4">
              <div class="flex items-center gap-1">
                <Icon name="i-lucide-clock" class="w-4 h-4" />
                <span>{{ course.durationHours }}h</span>
              </div>
              <div v-if="course.category" class="flex items-center gap-1">
                <Icon name="i-lucide-folder" class="w-4 h-4" />
                <span>{{ course.category }}</span>
              </div>
            </div>

            <!-- Progress Bar (if user has started) -->
            <div v-if="getCourseProgress(course.id)" class="mb-4">
              <div class="flex justify-between text-sm mb-2">
                <span class="text-gray-600 dark:text-gray-400">Progress</span>
                <span class="font-medium text-gray-900 dark:text-white">{{ getCourseProgress(course.id)?.progressPercentage }}%</span>
              </div>
              <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
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
                class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded-full"
              >
                {{ tag }}
              </span>
              <span
                v-if="course.tags.length > 3"
                class="text-xs text-gray-500 dark:text-gray-400"
              >
                +{{ course.tags.length - 3 }} more
              </span>
            </div>

            <!-- Action Button -->
            <UIButtonEnhanced
              :variant="getCourseProgress(course.id)?.status === 'completed' ? 'soft' : 'primary'"
              size="sm"
              class="w-full"
            >
              <Icon v-if="getCourseProgress(course.id)?.status === 'completed'" name="i-lucide-check" class="w-4 h-4 mr-2" />
              <span v-if="!getCourseProgress(course.id)">Start Course</span>
              <span v-else-if="getCourseProgress(course.id)?.status === 'completed'">Completed</span>
              <span v-else>Continue</span>
            </UIButtonEnhanced>
          </div>
        </UIBox>
      </div>

      <!-- Empty State -->
      <UIBox v-else class="p-12">
        <div class="text-center">
          <Icon name="i-lucide-book-open" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">No courses found</h3>
          <p class="text-gray-500 dark:text-gray-400">Try adjusting your search or filters to find what you're looking for.</p>
        </div>
      </UIBox>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Course, UserCourseProgress } from '~/composables/useCourses'

// Page metadata
useHead({
  title: 'Courses & Exams - EverestFlow'
})

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

const completedCount = computed(() => {
  return Object.values(userProgressMap.value).filter(p => p.status === 'completed').length
})

const inProgressCount = computed(() => {
  return Object.values(userProgressMap.value).filter(p => p.status === 'in_progress').length
})

// Methods
const navigateToCourse = (courseId: string) => {
  router.push(`/academy/courses/${courseId}`)
}

const getDifficultyBadgeClass = (difficulty: string) => {
  switch (difficulty) {
    case 'beginner':
      return 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400'
    case 'intermediate':
      return 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-400'
    case 'advanced':
      return 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-400'
    default:
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300'
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

// Load initial data
onMounted(async () => {
  await fetchCourses({ isPublished: true })
})
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}

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
