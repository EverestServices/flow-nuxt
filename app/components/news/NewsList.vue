<template>
  <div class="space-y-6" key="news-list">
    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <USkeleton
        v-for="i in 6"
        :key="i"
        class="h-64 w-full"
      />
    </div>

    <!-- Error State -->
    <UAlert
      v-else-if="error"
      color="red"
      variant="soft"
      title="Error loading news"
      :description="error"
    />

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
      <UButton
        @click="$emit('load-more')"
        :loading="loadingMore"
        variant="outline"
        size="lg"
      >
        Load More Articles
      </UButton>
    </div>

    <!-- Pagination -->
    <div
      v-if="showPagination && totalPages > 1"
      class="flex justify-center pt-8"
    >
      <UPagination
        :model-value="currentPage"
        :page-count="pageSize"
        :total="totalCount"
        @update:model-value="$emit('page-change', $event)"
      />
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