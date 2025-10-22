<template>
  <UIBox class="cursor-pointer hover:shadow-xl transition-all duration-200 overflow-hidden" @click="navigateToArticle">
    <!-- Featured Image -->
    <div class="h-48 bg-gradient-to-br from-blue-500 to-purple-600 relative overflow-hidden">
      <img
        v-if="article.featured_image_url"
        :src="article.featured_image_url"
        :alt="article.featured_image_alt || article.title"
        class="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
      />
      <div v-else class="flex items-center justify-center h-full">
        <Icon name="i-lucide-newspaper" class="w-16 h-16 text-white" />
      </div>

      <!-- Featured Badge -->
      <div v-if="article.is_featured" class="absolute top-3 right-3">
        <span class="bg-yellow-400 text-yellow-900 text-xs font-semibold px-3 py-1 rounded-full">
          Featured
        </span>
      </div>

      <!-- Global Badge -->
      <div v-if="article.is_global" class="absolute top-3 left-3">
        <span class="bg-blue-500 text-white text-xs font-semibold px-3 py-1 rounded-full">
          Global
        </span>
      </div>
    </div>

    <!-- Content -->
    <div class="p-5">
      <!-- Category Badge -->
      <div v-if="article.category" class="mb-3">
        <span
          :style="{ backgroundColor: article.category.color }"
          class="text-white text-xs px-3 py-1 rounded-full font-semibold"
        >
          {{ article.category.name }}
        </span>
      </div>

      <!-- Title -->
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2">
        {{ article.title }}
      </h3>

      <!-- Excerpt -->
      <p v-if="article.excerpt" class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">
        {{ article.excerpt }}
      </p>

      <!-- Meta Information -->
      <div class="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-4">
        <div class="flex items-center gap-1">
          <Icon name="i-lucide-calendar" class="w-4 h-4" />
          <span>{{ formatDate(article.published_at || article.created_at) }}</span>
        </div>
        <div v-if="showViewCount" class="flex items-center gap-1">
          <Icon name="i-lucide-eye" class="w-4 h-4" />
          <span>{{ article.view_count || 0 }}</span>
        </div>
      </div>

      <!-- Tags -->
      <div v-if="article.tags && article.tags.length > 0" class="flex flex-wrap gap-1">
        <span
          v-for="tag in article.tags.slice(0, 3)"
          :key="tag"
          class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded-full"
        >
          {{ tag }}
        </span>
        <span
          v-if="article.tags.length > 3"
          class="text-xs text-gray-500 dark:text-gray-400"
        >
          +{{ article.tags.length - 3 }} more
        </span>
      </div>
    </div>
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