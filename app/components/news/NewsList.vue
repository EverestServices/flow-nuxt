<template>
  <div class="space-y-6" key="news-list">
    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="i in 6"
        :key="i"
        class="h-64 w-full bg-gray-200 dark:bg-gray-700 rounded-xl animate-pulse"
      />
    </div>

    <!-- Error State -->
    <UIAlert
      v-else-if="error"
      variant="danger"
    >
      <strong>Error loading news</strong><br />
      {{ error }}
    </UIAlert>

    <!-- Empty State -->
    <div
      v-else-if="!articles || articles.length === 0"
      class="text-center py-12"
    >
      <div class="mx-auto max-w-md">
        <Icon name="i-lucide-newspaper" class="mx-auto h-12 w-12 text-gray-400" />
        <h3 class="mt-4 text-sm font-medium text-gray-900">No news articles found</h3>
        <p class="mt-2 text-sm text-gray-500">
          {{ emptyMessage || 'There are no news articles to display at the moment.' }}
        </p>
      </div>
    </div>

    <!-- Articles Grid -->
    <div
      v-else
      class="grid grid-cols-1 gap-6"
      :class="gridCols"
    >
      <NewsCard
        v-for="article in articles"
        :key="article.id"
        :article="article"
        :show-view-count="showViewCount"
      />
    </div>

    <!-- Load More Button -->
    <div
      v-if="showLoadMore && hasMore"
      class="flex justify-center pt-8"
    >
      <UIButtonEnhanced
        @click="$emit('load-more')"
        :loading="loadingMore"
        variant="outline"
        size="lg"
      >
        Load More Articles
      </UIButtonEnhanced>
    </div>

    <!-- Pagination -->
    <div
      v-if="showPagination && totalPages > 1"
      class="flex justify-center items-center gap-2 pt-8"
    >
      <UIButtonEnhanced
        @click="$emit('page-change', currentPage - 1)"
        :disabled="currentPage === 1"
        variant="ghost"
        size="sm"
      >
        Previous
      </UIButtonEnhanced>
      <span class="text-sm text-gray-600 dark:text-gray-400">
        Page {{ currentPage }} of {{ totalPages }}
      </span>
      <UIButtonEnhanced
        @click="$emit('page-change', currentPage + 1)"
        :disabled="currentPage === totalPages"
        variant="ghost"
        size="sm"
      >
        Next
      </UIButtonEnhanced>
    </div>
  </div>
</template>

<script setup lang="ts">
interface NewsArticle {
  id: string
  title: string
  slug: string
  excerpt?: string
  content: string
  featured_image_url?: string
  featured_image_alt?: string
  category?: {
    id: string
    name: string
    color: string
  }
  tags?: string[]
  is_global: boolean
  is_featured: boolean
  view_count: number
  published_at?: string
  created_at: string
}

interface Props {
  articles?: NewsArticle[]
  loading?: boolean
  error?: string | null
  emptyMessage?: string
  showViewCount?: boolean
  showLoadMore?: boolean
  showPagination?: boolean
  loadingMore?: boolean
  hasMore?: boolean
  currentPage?: number
  totalPages?: number
  totalCount?: number
  pageSize?: number
  layout?: 'grid' | 'list' | 'featured'
}

interface Emits {
  (e: 'load-more'): void
  (e: 'page-change', page: number): void
}

const props = withDefaults(defineProps<Props>(), {
  articles: () => [],
  loading: false,
  error: null,
  emptyMessage: '',
  showViewCount: true,
  showLoadMore: false,
  showPagination: false,
  loadingMore: false,
  hasMore: false,
  currentPage: 1,
  totalPages: 1,
  totalCount: 0,
  pageSize: 10,
  layout: 'grid'
})

defineEmits<Emits>()

const gridCols = computed(() => {
  switch (props.layout) {
    case 'list':
      return 'grid-cols-1'
    case 'featured':
      return 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3'
    default:
      return 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3'
  }
})
</script>