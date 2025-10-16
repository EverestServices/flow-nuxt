<template>
  <div v-if="articles && articles.length > 0" class="mb-12">
    <div class="mb-6">
      <h2 class="text-2xl font-bold text-gray-900 mb-2">Featured News</h2>
      <div class="w-16 h-1 bg-primary-500 rounded-full"></div>
    </div>

    <!-- Single Featured Article Layout -->
    <div v-if="layout === 'single' && articles[0]" class="mb-8">
      <UCard class="overflow-hidden hover:shadow-xl transition-all duration-300 group cursor-pointer" @click="navigateToArticle(articles[0])">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-0">
          <!-- Image -->
          <div class="relative aspect-video lg:aspect-square overflow-hidden">
            <img
              :src="articles[0].featured_image_url"
              :alt="articles[0].featured_image_alt || articles[0].title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
            <div class="absolute top-4 left-4">
              <UBadge color="yellow" class="text-black font-semibold">
                Featured
              </UBadge>
            </div>
          </div>

          <!-- Content -->
          <div class="p-6 lg:p-8 flex flex-col justify-center">
            <div class="space-y-4">
              <!-- Category -->
              <div v-if="articles[0].category" class="flex items-center gap-2">
                <UBadge
                  :style="{ backgroundColor: articles[0].category.color }"
                  class="text-white"
                >
                  {{ articles[0].category.name }}
                </UBadge>
                <span v-if="articles[0].is_global" class="text-sm text-gray-500 font-medium">
                  Global News
                </span>
              </div>

              <!-- Title -->
              <h3 class="text-2xl lg:text-3xl font-bold text-gray-900 group-hover:text-primary-600 transition-colors">
                {{ articles[0].title }}
              </h3>

              <!-- Excerpt -->
              <p v-if="articles[0].excerpt" class="text-gray-600 text-lg leading-relaxed">
                {{ articles[0].excerpt }}
              </p>

              <!-- Meta -->
              <div class="flex items-center justify-between text-sm text-gray-500 pt-4 border-t border-gray-100">
                <span>{{ formatDate(articles[0].published_at || articles[0].created_at) }}</span>
                <span class="flex items-center gap-1">
                  <Icon name="i-lucide-eye" class="w-4 h-4" />
                  {{ articles[0].view_count || 0 }} views
                </span>
              </div>

              <!-- Read More Button -->
              <div class="pt-4">
                <UButton
                  @click.stop="navigateToArticle(articles[0])"
                  size="lg"
                  class="group-hover:scale-105 transition-transform"
                >
                  Read More
                  <Icon name="i-lucide-arrow-right" class="ml-2 w-4 h-4" />
                </UButton>
              </div>
            </div>
          </div>
        </div>
      </UCard>
    </div>

    <!-- Grid Layout for Multiple Featured Articles -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Main Featured Article -->
      <div class="md:col-span-2">
        <UCard class="h-full overflow-hidden hover:shadow-xl transition-all duration-300 group cursor-pointer" @click="navigateToArticle(articles[0])">
          <div class="relative aspect-video mb-4 overflow-hidden rounded-lg">
            <img
              :src="articles[0].featured_image_url"
              :alt="articles[0].featured_image_alt || articles[0].title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
            <div class="absolute bottom-0 left-0 right-0 p-6">
              <div class="mb-3">
                <UBadge color="yellow" class="text-black font-semibold mr-2">
                  Featured
                </UBadge>
                <UBadge
                  v-if="articles[0].category"
                  :style="{ backgroundColor: articles[0].category.color }"
                  class="text-white"
                >
                  {{ articles[0].category.name }}
                </UBadge>
              </div>
              <h3 class="text-xl lg:text-2xl font-bold text-white mb-2">
                {{ articles[0].title }}
              </h3>
              <p v-if="articles[0].excerpt" class="text-gray-200 text-sm line-clamp-2">
                {{ articles[0].excerpt }}
              </p>
            </div>
          </div>
        </UCard>
      </div>

      <!-- Side Featured Articles -->
      <div class="space-y-4">
        <UCard
          v-for="article in articles.slice(1, 3)"
          :key="article.id"
          class="hover:shadow-lg transition-all duration-300 group cursor-pointer"
          @click="navigateToArticle(article)"
        >
          <div class="flex gap-4">
            <!-- Small Image -->
            <div v-if="article.featured_image_url" class="flex-shrink-0">
              <div class="relative w-20 h-20 rounded-lg overflow-hidden">
                <img
                  :src="article.featured_image_url"
                  :alt="article.featured_image_alt || article.title"
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
              </div>
            </div>

            <!-- Content -->
            <div class="flex-1 space-y-2">
              <div v-if="article.category" class="flex items-center gap-1">
                <UBadge
                  :style="{ backgroundColor: article.category.color }"
                  class="text-white text-xs"
                  size="xs"
                >
                  {{ article.category.name }}
                </UBadge>
              </div>

              <h4 class="font-semibold text-sm line-clamp-2 group-hover:text-primary-600 transition-colors">
                {{ article.title }}
              </h4>

              <div class="text-xs text-gray-500">
                {{ formatDate(article.published_at || article.created_at) }}
              </div>
            </div>
          </div>
        </UCard>
      </div>
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
  layout?: 'grid' | 'single'
}

const props = withDefaults(defineProps<Props>(), {
  articles: () => [],
  layout: 'grid'
})

const navigateToArticle = (article: NewsArticle) => {
  navigateTo(`/academy/news/${article.slug}`)
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
</style>