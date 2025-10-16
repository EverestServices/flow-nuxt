<template>
  <div class="" :key="$route.fullPath">
    <div>
      <h1 class="text-4xl font-bold text-gray-900 mb-2 outfit">Flow News</h1>
      <p class="text-lg text-gray-600">Stay updated with the latest company and industry news</p>
    </div>
    <!-- Quick Search -->
    <div class="">
      <UInput
          v-model="searchQuery"
          icon="i-lucide-search"
          placeholder="Search news..."
          size="lg"
          :loading="searching"
          @update:model-value="handleQuickSearch"
      />
    </div>

      <div class="">
        <!-- Sidebar with Filters -->
        <aside class="">
          <div class="sticky top-8">
            <NewsFilters
              :categories="categories"
              :filters="filters"
              @update:filters="updateFilters"
            />
          </div>
        </aside>

        <!-- Main Content -->
        <main class="lg:col-span-3 space-y-8">
          <!-- Featured Articles Section -->
          <FeaturedNews
            v-if="featuredArticles.length && !hasActiveFilters"
            :articles="featuredArticles"
            layout="grid"
          />

          <!-- Articles Section -->
          <div>
            <!-- Section Header -->
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-2xl font-bold text-gray-900">
                {{ getSectionTitle() }}
                <span v-if="totalCount" class="text-lg font-normal text-gray-500">
                  ({{ totalCount }} articles)
                </span>
              </h2>

              <!-- View Toggle -->
              <div class="flex items-center gap-2">
                <UButtonGroup>
                  <UButton
                    :variant="viewMode === 'grid' ? 'solid' : 'outline'"
                    size="sm"
                    @click="viewMode = 'grid'"
                  >
                    <Icon name="i-lucide-grid-3x3" class="w-4 h-4" />
                  </UButton>
                  <UButton
                    :variant="viewMode === 'list' ? 'solid' : 'outline'"
                    size="sm"
                    @click="viewMode = 'list'"
                  >
                    <Icon name="i-lucide-list" class="w-4 h-4" />
                  </UButton>
                </UButtonGroup>
              </div>
            </div>

            <!-- Articles List -->
            <NewsList
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
        </main>
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