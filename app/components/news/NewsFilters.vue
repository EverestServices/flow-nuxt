<template>
  <div class="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm space-y-6">
    <!-- Search -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Search Articles
      </label>
      <UIInput
        :model-value="filters.search"
        @update:model-value="updateSearch"
        placeholder="Search by title, content, or tags..."
      >
        <template #prefix>
          <Icon name="i-lucide-search" class="w-5 h-5" />
        </template>
      </UIInput>
    </div>

    <!-- Categories -->
    <div v-if="categories.length">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        Categories
      </label>
      <div class="space-y-2 max-h-48 overflow-y-auto">
        <label class="flex items-center gap-2 cursor-pointer text-sm text-gray-700 dark:text-gray-300">
          <input
            type="checkbox"
            :checked="!filters.category"
            @change="updateCategory(null)"
            class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          />
          All Categories
        </label>
        <label
          v-for="category in categories"
          :key="category.id"
          class="flex items-center gap-2 cursor-pointer text-sm text-gray-700 dark:text-gray-300"
        >
          <input
            type="checkbox"
            :checked="filters.category === category.id"
            @change="updateCategory(category.id)"
            class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          />
          {{ category.name }}
        </label>
      </div>
    </div>

    <!-- News Type -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        News Type
      </label>
      <div class="space-y-2">
        <label
          v-for="option in newsTypeOptions"
          :key="option.value"
          class="flex items-center gap-2 cursor-pointer text-sm text-gray-700 dark:text-gray-300"
        >
          <input
            type="radio"
            :value="option.value"
            :checked="filters.newsType === option.value"
            @change="updateNewsType(option.value)"
            class="w-4 h-4 border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          />
          {{ option.label }}
        </label>
      </div>
    </div>

    <!-- Featured Filter -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        Show Featured Only
      </label>
      <div class="flex items-center gap-2">
        <UISwitch
          v-model="filters.featured"
          @update:model-value="updateFeatured"
        />
        <span class="text-sm text-gray-600 dark:text-gray-400">Featured articles only</span>
      </div>
    </div>

    <!-- Date Range -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        Date Range
      </label>
      <UISelect
        v-model="filters.dateRange"
        :options="dateRangeOptions"
        @update:model-value="updateDateRange"
      />
    </div>

    <!-- Sort Options -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        Sort By
      </label>
      <UISelect
        v-model="filters.sortBy"
        :options="sortOptions"
        @update:model-value="updateSortBy"
      />
    </div>

    <!-- Clear Filters -->
    <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
      <UIButtonEnhanced
        @click="clearFilters"
        variant="outline"
        size="sm"
        :disabled="isFiltersEmpty"
        class="w-full"
      >
        <template #icon>
          <Icon name="i-lucide-x-circle" class="w-4 h-4" />
        </template>
        Clear All Filters
      </UIButtonEnhanced>
    </div>

    <!-- Active Filters Count -->
    <div v-if="activeFiltersCount > 0" class="text-center">
      <span class="inline-block bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 text-xs px-3 py-1 rounded-full font-medium">
        {{ activeFiltersCount }} filter{{ activeFiltersCount === 1 ? '' : 's' }} active
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Category {
  id: string
  name: string
  color: string
}

interface NewsFilters {
  search?: string
  category?: string | null
  newsType: 'all' | 'global' | 'company'
  featured: boolean
  dateRange?: string
  sortBy: string
}

interface Props {
  categories: Category[]
  filters: NewsFilters
}

interface Emits {
  (e: 'update:filters', filters: NewsFilters): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const newsTypeOptions = [
  { label: 'All News', value: 'all' },
  { label: 'Global News', value: 'global' },
  { label: 'Company News', value: 'company' }
]

const dateRangeOptions = [
  { label: 'All Time', value: 'all' },
  { label: 'Last 24 Hours', value: '1day' },
  { label: 'Last Week', value: '1week' },
  { label: 'Last Month', value: '1month' },
  { label: 'Last 3 Months', value: '3months' },
  { label: 'Last Year', value: '1year' }
]

const sortOptions = [
  { label: 'Newest First', value: 'newest' },
  { label: 'Oldest First', value: 'oldest' },
  { label: 'Most Views', value: 'popular' },
  { label: 'Alphabetical', value: 'alphabetical' }
]

const updateSearch = (value: string) => {
  emit('update:filters', {
    ...props.filters,
    search: value
  })
}

const updateCategory = (categoryId: string | null) => {
  emit('update:filters', {
    ...props.filters,
    category: categoryId
  })
}

const updateNewsType = (value: 'all' | 'global' | 'company') => {
  emit('update:filters', {
    ...props.filters,
    newsType: value
  })
}

const updateFeatured = (value: boolean) => {
  emit('update:filters', {
    ...props.filters,
    featured: value
  })
}

const updateDateRange = (value: string) => {
  emit('update:filters', {
    ...props.filters,
    dateRange: value
  })
}

const updateSortBy = (value: string) => {
  emit('update:filters', {
    ...props.filters,
    sortBy: value
  })
}

const clearFilters = () => {
  emit('update:filters', {
    search: '',
    category: null,
    newsType: 'all',
    featured: false,
    dateRange: 'all',
    sortBy: 'newest'
  })
}

const isFiltersEmpty = computed(() => {
  return !props.filters.search &&
    !props.filters.category &&
    props.filters.newsType === 'all' &&
    !props.filters.featured &&
    (!props.filters.dateRange || props.filters.dateRange === 'all') &&
    props.filters.sortBy === 'newest'
})

const activeFiltersCount = computed(() => {
  let count = 0
  if (props.filters.search) count++
  if (props.filters.category) count++
  if (props.filters.newsType !== 'all') count++
  if (props.filters.featured) count++
  if (props.filters.dateRange && props.filters.dateRange !== 'all') count++
  if (props.filters.sortBy !== 'newest') count++
  return count
})
</script>