<template>
  <UIBox class="overflow-hidden">
    <UCard
    class=""
    @click="navigateToArticle"
  >
    <!-- Featured Image -->
    <div v-if="article.featured_image_url" class="relative aspect-video mb-4 overflow-hidden rounded-xl">
      <img
        :src="article.featured_image_url"
        :alt="article.featured_image_alt || article.title"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
      />
      <div
        v-if="article.is_featured"
        class="absolute top-2 left-2 px-2 py-1 bg-yellow-500 text-white text-xs font-semibold rounded-full"
      >
        Featured
      </div>
    </div>

    <!-- Content -->
    <div class="space-y-3">
      <!-- Category Badge -->
      <div v-if="article.category" class="flex items-center gap-2">
        <UBadge
          :style="{ backgroundColor: article.category.color }"
          class="text-white text-xs px-2 py-1"
        >
          {{ article.category.name }}
        </UBadge>
        <span v-if="article.is_global" class="text-xs text-gray-500 font-medium">
          Global
        </span>
      </div>

      <!-- Title -->
      <h3 class="font-semibold text-lg line-clamp-2 group-hover:text-primary-600 transition-colors">
        {{ article.title }}
      </h3>

      <!-- Excerpt -->
      <p v-if="article.excerpt" class="text-gray-600 text-sm line-clamp-3">
        {{ article.excerpt }}
      </p>

      <!-- Tags -->
      <div v-if="article.tags && article.tags.length" class="flex flex-wrap gap-1">
        <UBadge
          v-for="tag in article.tags.slice(0, 3)"
          :key="tag"
          color="gray"
          variant="soft"
          size="xs"
        >
          {{ tag }}
        </UBadge>
        <UBadge
          v-if="article.tags.length > 3"
          color="gray"
          variant="soft"
          size="xs"
        >
          +{{ article.tags.length - 3 }}
        </UBadge>
      </div>

      <!-- Meta Information -->
      <div class="flex items-center justify-between text-xs text-gray-500 pt-2 border-t border-gray-100">
        <div class="flex items-center gap-4">
          <span>{{ formatDate(article.published_at || article.created_at) }}</span>
          <span v-if="showViewCount" class="flex items-center gap-1">
            <Icon name="i-lucide-eye" class="w-3 h-3" />
            {{ article.view_count || 0 }}
          </span>
        </div>
        <div v-if="article.is_featured" class="flex items-center gap-1 text-yellow-600">
          <Icon name="i-lucide-star" class="w-3 h-3 fill-current" />
        </div>
      </div>
    </div>
  </UCard>
  </UIBox>
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
  article: NewsArticle
  showViewCount?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showViewCount: true
})

const navigateToArticle = () => {
  navigateTo(`/academy/news/${props.article.slug}`)
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}
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