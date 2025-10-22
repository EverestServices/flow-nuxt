<template>
  <div :key="$route.fullPath">
    <!-- Header matching dashboard style -->
    <div class="flex h-24 items-center">
      <div class="text-2xl font-light">Flow <span class="font-black">News</span></div>
    </div>

    <div class="flex flex-col space-y-8">
      <!-- Welcome Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">
        <div class="basis-0 flex flex-col items-start justify-center">
          <div class="text-5xl font-thin outfit">
            Stay updated with the <strong class="font-black">latest news</strong> and<br />
            <strong class="font-black">industry insights</strong>
          </div>
          <div class="text-2xl outfit font-thin text-gray-600 dark:text-gray-400 mt-4">
            {{ totalCount }} articles available
          </div>
        </div>

        <!-- Stats Cards -->
        <div class="flex flex-col basis-0 items-start justify-center">
          <div class="grid grid-cols-3 gap-4 w-full">
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-blue-600 dark:text-blue-400">
                {{ totalCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Total Articles</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-purple-600 dark:text-purple-400">
                {{ featuredArticles.length }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Featured</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-green-600 dark:text-green-400">
                {{ categories.length }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Categories</div>
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
              placeholder="Search news..."
              icon="i-lucide-search"
              @update:model-value="handleQuickSearch"
            />
          </div>
          <UISelect
            v-model="filters.category"
            :options="categoryOptions"
            size="sm"
            class="w-40"
            @update:model-value="loadArticles()"
          />
          <UISelect
            v-model="filters.newsType"
            :options="newsTypeOptions"
            size="sm"
            class="w-32"
            @update:model-value="loadArticles()"
          />
          <UISelect
            v-model="filters.sortBy"
            :options="sortOptions"
            size="sm"
            class="w-32"
            @update:model-value="loadArticles()"
          />
          <div class="flex items-center gap-2 whitespace-nowrap">
            <label class="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                v-model="filters.featured"
                @change="loadArticles()"
                class="sr-only peer"
              />
              <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
            </label>
            <span class="text-xs text-gray-600 dark:text-gray-400">Featured</span>
          </div>
          <button
            @click="viewMode = viewMode === 'grid' ? 'list' : 'grid'"
            class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <Icon v-if="viewMode === 'grid'" name="i-lucide-list" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
            <Icon v-else name="i-lucide-grid-3x3" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </button>
        </div>
      </UIBox>

      <!-- Featured Articles Section -->
      <div v-if="featuredArticles.length && !hasActiveFilters">
        <FeaturedNews
          :articles="featuredArticles"
          layout="grid"
        />
      </div>

      <!-- Articles Section Header -->
      <div class="flex items-center justify-between">
        <h2 class="text-2xl font-semibold text-gray-900 dark:text-white">
          {{ getSectionTitle() }}
        </h2>
      </div>

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

      <!-- Articles List -->
      <NewsList
        v-else
        :articles="articles"
        :loading="loading"
        :error="error"
        :layout="viewMode"
        :show-load-more="true"
        :has-more="hasMore"
        :loading-more="loadingMore"
        @load-more="loadMoreArticles"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { NewsArticle, NewsCategory } from '~/composables/useNews'

// Define page meta
definePageMeta({
  layout: 'default',
  key: route => route.fullPath
})

const {
  getArticles,
  getFeaturedArticles,
  getCategories,
  searchArticles
} = useNews()

// SEO
useHead({
  title: 'News - Flow Academy',
  meta: [
    { name: 'description', content: 'Stay updated with the latest company and industry news from Flow Academy.' }
  ]
})

// Reactive state
const articles = ref([])
const featuredArticles = ref([])
const categories = ref([])
const totalCount = ref(0)
const loading = ref(true)
const loadingMore = ref(false)
const error = ref(null)
const searching = ref(false)
const hasMore = ref(false)
const currentPage = ref(1)
const pageSize = 12

// Search and filters
const searchQuery = ref('')
const viewMode = ref('grid')
const filters = ref({
  search: '',
  category: null,
  newsType: 'all',
  featured: false,
  dateRange: 'all',
  sortBy: 'newest'
})

// Filter options
const categoryOptions = computed(() => [
  { label: 'All Categories', value: null },
  ...categories.value.map(cat => ({ label: cat.name, value: cat.id }))
])

const newsTypeOptions = [
  { label: 'All News', value: 'all' },
  { label: 'Global', value: 'global' },
  { label: 'Company', value: 'company' }
]

const sortOptions = [
  { label: 'Newest', value: 'newest' },
  { label: 'Oldest', value: 'oldest' },
  { label: 'Most Popular', value: 'popular' }
]

// Computed
const hasActiveFilters = computed(() => {
  return filters.value.search ||
    filters.value.category ||
    filters.value.newsType !== 'all' ||
    filters.value.featured ||
    (filters.value.dateRange && filters.value.dateRange !== 'all') ||
    filters.value.sortBy !== 'newest'
})

// Methods
const getSectionTitle = () => {
  if (filters.value.search) return 'Search Results'
  if (filters.value.featured) return 'Featured Articles'
  if (filters.value.newsType === 'global') return 'Global News'
  if (filters.value.newsType === 'company') return 'Company News'
  if (filters.value.category) {
    const category = categories.value.find(c => c.id === filters.value.category)
    return category ? category.name : 'All Articles'
  }
  return 'All Articles'
}

const buildFilters = () => {
  const apiFilters = {
    limit: pageSize,
    offset: (currentPage.value - 1) * pageSize
  }

  if (filters.value.search) {
    apiFilters.search = filters.value.search
  }

  if (filters.value.category) {
    apiFilters.category = filters.value.category
  }

  if (filters.value.newsType === 'global') {
    apiFilters.is_global = true
  } else if (filters.value.newsType === 'company') {
    apiFilters.is_global = false
  }

  if (filters.value.featured) {
    apiFilters.is_featured = true
  }

  return apiFilters
}

const loadArticles = async (append = false) => {
  try {
    if (append) {
      loadingMore.value = true
    } else {
      loading.value = true
      currentPage.value = 1
    }

    const apiFilters = buildFilters()
    const { data, error: fetchError, count } = await getArticles(apiFilters)

    if (fetchError) {
      console.error('Error loading articles:', fetchError)
      error.value = fetchError.message
      return
    }

    if (append) {
      articles.value.push(...(data || []))
    } else {
      articles.value = data || []
    }

    totalCount.value = count || 0
    hasMore.value = articles.value.length < totalCount.value

  } catch (err) {
    console.error('Exception loading articles:', err)
    error.value = err.message
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

const loadMoreArticles = async () => {
  currentPage.value++
  await loadArticles(true)
}

const loadFeaturedArticles = async () => {
  try {
    const { data } = await getFeaturedArticles(3)
    featuredArticles.value = data || []
  } catch (err) {
    console.error('Failed to load featured articles:', err)
  }
}

const loadCategories = async () => {
  try {
    const { data } = await getCategories()
    categories.value = data || []
  } catch (err) {
    console.error('Failed to load categories:', err)
  }
}

const updateFilters = (newFilters) => {
  filters.value = { ...newFilters }
  searchQuery.value = newFilters.search || ''
  loadArticles()
}

const handleQuickSearch = useDebounceFn(async (value) => {
  searching.value = true
  filters.value.search = value
  await loadArticles()
  searching.value = false
}, 300)

// Watch for route query parameters
watch(() => useRoute().query, (query) => {
  if (query.search) {
    searchQuery.value = query.search
    filters.value.search = query.search
  }
  if (query.category) {
    filters.value.category = query.category
  }
}, { immediate: true })

// Initialize data function
const initializeData = async () => {
  console.log('Initializing news data...')
  loading.value = true
  try {
    await Promise.all([
      loadCategories(),
      loadFeaturedArticles(),
      loadArticles()
    ])
  } catch (err) {
    console.error('Error initializing data:', err)
  } finally {
    loading.value = false
  }
}

// Load data immediately - this should work for both SSR and client navigation
initializeData()

// Force component refresh on route change
const route = useRoute()
watch(() => route.fullPath, async () => {
  if (route.path === '/academy/news') {
    console.log('Route watcher triggered for news page')
    await initializeData()
  }
})

// Also load on mount as fallback
onMounted(async () => {
  console.log('News page mounted')
  // Always reload on mount to ensure fresh data
  await initializeData()
})
</script>

<style scoped>
/* Custom scrollbar for sidebar */
aside {
  scrollbar-width: thin;
  scrollbar-color: rgba(156, 163, 175, 0.5) transparent;
}

aside::-webkit-scrollbar {
  width: 6px;
}

aside::-webkit-scrollbar-track {
  background: transparent;
}

aside::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

aside::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}
</style>