<template>
  <div class="bg-white rounded-xl border border-gray-200 p-6 shadow-sm space-y-6">
    <!-- Search -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">
        Search Articles
      </label>
      <UInput
        :model-value="filters.search"
        @update:model-value="updateSearch"
        icon="i-lucide-search"
        placeholder="Search by title, content, or tags..."
        size="lg"
        :debounce="300"
      />
    </div>

    <!-- Categories -->
    <div v-if="categories.length">
      <label class="block text-sm font-medium text-gray-700 mb-3">
        Categories
      </label>
      <div class="space-y-2 max-h-48 overflow-y-auto">
        <UCheckbox
          :checked="!filters.category"
          @change="updateCategory(null)"
          label="All Categories"
          class="text-sm"
        />
        <UCheckbox
          v-for="category in categories"
          :key="category.id"
          :checked="filters.category === category.id"
          @change="updateCategory(category.id)"
          :label="category.name"
          class="text-sm"
        />
      </div>
    </div>

    <!-- News Type -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-3">
        News Type
      </label>
      <URadioGroup
        :model-value="filters.newsType"
        @update:model-value="updateNewsType"
        :options="newsTypeOptions"
        class="space-y-2"
      />
    </div>

    <!-- Featured Filter -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-3">
        Show Featured Only
      </label>
      <UToggle
        :model-value="filters.featured"
        @update:model-value="updateFeatured"
        :ui="{ wrapper: 'flex items-center space-x-2' }"
      >
        <span class="text-sm text-gray-600">Featured articles only</span>
      </UToggle>
    </div>

    <!-- Date Range -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-3">
        Date Range
      </label>
      <USelectMenu
        :model-value="filters.dateRange"
        @update:model-value="updateDateRange"
        :options="dateRangeOptions"
        placeholder="Select date range"
        class="w-full"
      />
    </div>

    <!-- Sort Options -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-3">
        Sort By
      </label>
      <USelectMenu
        :model-value="filters.sortBy"
        @update:model-value="updateSortBy"
        :options="sortOptions"
        placeholder="Sort articles by"
        class="w-full"
      />
    </div>

    <!-- Clear Filters -->
    <div class="pt-4 border-t border-gray-200">
      <UButton
        @click="clearFilters"
        variant="outline"
        color="gray"
        block
        size="sm"
        :disabled="isFiltersEmpty"
      >
        <Icon name="i-lucide-x-circle" class="w-4 h-4 mr-2" />
        Clear All Filters
      </UButton>
    </div>

    <!-- Active Filters Count -->
    <div v-if="activeFiltersCount > 0" class="text-center">
      <UBadge color="primary" variant="soft" size="sm">
        {{ activeFiltersCount }} filter{{ activeFiltersCount === 1 ? '' : 's' }} active
      </UBadge>
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