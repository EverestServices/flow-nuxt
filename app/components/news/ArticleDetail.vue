<template>
  <article v-if="article" class="pt-10">

    <header class="mb-8">
      <!-- Breadcrumb -->
      <nav class="mb-4">
        <ol class="flex items-center space-x-2 text-sm text-gray-500">
          <li><NuxtLink to="/academy/news" class="hover:text-primary-600">News</NuxtLink></li>
          <Icon name="i-lucide-chevron-right" class="w-4 h-4" />
          <li v-if="article.category" class="truncate">
            <span :style="{ color: article.category.color }" class="font-medium">
              {{ article.category.name }}
            </span>
          </li>
          <Icon v-if="article.category" name="i-lucide-chevron-right" class="w-4 h-4" />
          <li class="text-gray-900 font-medium truncate">{{ article.title }}</li>
        </ol>
      </nav>
    </header>




    <h1 class="text-5xl font-thin outfit mt-24 w-1/2">{{ article.title }}</h1>


    <!-- Excerpt -->
      <p v-if="article.excerpt" class="text-xl text-gray-600 leading-relaxed mb-16">
        {{ article.excerpt }}
      </p>

    <UIBox class="p-8">
      <!-- Header -->
      <!-- Article Meta -->
      <div class="flex flex-wrap items-center gap-4 mb-6">
        <UBadge
            v-if="article.category"
            :style="{ backgroundColor: article.category.color }"
            class="text-white"
        >
          {{ article.category.name }}
        </UBadge>

        <UBadge v-if="article.is_featured" color="yellow" class="text-black">
          Featured
        </UBadge>

        <UBadge v-if="article.is_global" color="blue" variant="soft">
          Global News
        </UBadge>

        <div class="flex items-center gap-4 text-sm text-gray-600">
          <span>{{ formatDate(article.published_at || article.created_at) }}</span>
          <span class="flex items-center gap-1">
            <Icon name="i-lucide-eye" class="w-4 h-4" />
            {{ article.view_count || 0 }} views
          </span>
        </div>
      </div>
      <!-- Featured Image -->
      <div v-if="article.featured_image_url" class="relative  rounded-xl overflow-hidden h-96 mb-8 shadow-lg">
        <img
          :src="article.featured_image_url"
          :alt="article.featured_image_alt || article.title"
          class="w-full h-full object-cover"
        />
        <div
          v-if="article.featured_image_alt"
          class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-4"
        >
          <p class="text-white text-sm">{{ article.featured_image_alt }}</p>
        </div>
      </div>


        <!-- Content -->
        <div class="prose prose-lg max-w-none mb-8">
          <div v-html="article.content"></div>
        </div>

      <!-- Tags -->
      <div v-if="article.tags && article.tags.length" class="mb-8">
        <h3 class="text-sm font-semibold text-gray-700 mb-3">Tags</h3>
        <div class="flex flex-wrap gap-2">
          <UBadge
              v-for="tag in article.tags"
              :key="tag"
              color="gray"
              variant="soft"
              class="cursor-pointer hover:bg-gray-200 transition-colors"
              @click="searchByTag(tag)"
          >
            {{ tag }}
          </UBadge>
        </div>
      </div>
      </UIBox>




    <!-- Article Footer -->
    <footer class="border-t border-gray-200 pt-8">
      <!-- Share Buttons -->
      <div class="flex items-center justify-between mb-8">
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-gray-700">Share:</span>
          <UButton
            size="sm"
            variant="ghost"
            color="gray"
            @click="copyToClipboard"
            :loading="copying"
          >
            <Icon name="i-lucide-copy" class="w-4 h-4" />
            {{ copying ? 'Copied!' : 'Copy Link' }}
          </UButton>
        </div>
      </div>

      <!-- Related Articles -->
      <div v-if="relatedArticles && relatedArticles.length" class="mb-8">
        <h3 class="text-xl font-bold text-gray-900 mb-4">Related Articles</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <NewsCard
            v-for="relatedArticle in relatedArticles"
            :key="relatedArticle.id"
            :article="relatedArticle"
            :show-view-count="false"
          />
        </div>
      </div>

      <!-- Navigation -->
      <div class="flex justify-between items-center">
        <UButton
          to="/academy/news"
          variant="outline"
          color="gray"
        >
          <Icon name="i-lucide-arrow-left" class="w-4 h-4 mr-2" />
          Back to News
        </UButton>

        <div class="flex gap-2">
          <UButton
            v-if="previousArticle"
            :to="`/academy/news/${previousArticle.slug}`"
            variant="outline"
            size="sm"
          >
            <Icon name="i-lucide-chevron-left" class="w-4 h-4 mr-1" />
            Previous
          </UButton>

          <UButton
            v-if="nextArticle"
            :to="`/academy/news/${nextArticle.slug}`"
            variant="outline"
            size="sm"
          >
            Next
            <Icon name="i-lucide-chevron-right" class="w-4 h-4 ml-1" />
          </UButton>
        </div>
      </div>
    </footer>
  </article>
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
  relatedArticles?: NewsArticle[]
  previousArticle?: NewsArticle
  nextArticle?: NewsArticle
}

const props = defineProps<Props>()

const copying = ref(false)

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const copyToClipboard = async () => {
  try {
    copying.value = true
    await navigator.clipboard.writeText(window.location.href)
    setTimeout(() => {
      copying.value = false
    }, 2000)
  } catch (error) {
    copying.value = false
    console.error('Failed to copy to clipboard:', error)
  }
}

const searchByTag = (tag: string) => {
  navigateTo(`/academy/news?search=${encodeURIComponent(tag)}`)
}

// Record page view when component mounts
onMounted(async () => {
  try {
    const { recordView } = useNews()
    await recordView(props.article.id)
  } catch (error) {
    console.error('Failed to record view:', error)
  }
})

// SEO Meta
const title = computed(() => props.article.meta_title || props.article.title)
const description = computed(() => props.article.meta_description || props.article.excerpt || '')

useHead({
  title: title.value,
  meta: [
    { name: 'description', content: description.value },
    { property: 'og:title', content: title.value },
    { property: 'og:description', content: description.value },
    { property: 'og:image', content: props.article.featured_image_url },
    { property: 'og:type', content: 'article' },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:title', content: title.value },
    { name: 'twitter:description', content: description.value },
    { name: 'twitter:image', content: props.article.featured_image_url }
  ]
})
</script>

<style>
/* Prose styling for article content */
/*
.prose {
  @apply text-gray-800 leading-relaxed;
}

.prose h1,
.prose h2,
.prose h3,
.prose h4,
.prose h5,
.prose h6 {
  @apply text-gray-900 font-bold mt-8 mb-4;
}

.prose h1 {
  @apply text-3xl;
}

.prose h2 {
  @apply text-2xl;
}

.prose h3 {
  @apply text-xl;
}

.prose p {
  @apply mb-4;
}

.prose a {
  @apply text-primary-600 hover:text-primary-700 underline;
}

.prose ul,
.prose ol {
  @apply mb-4 ml-6;
}

.prose ul {
  @apply list-disc;
}

.prose ol {
  @apply list-decimal;
}

.prose li {
  @apply mb-2;
}

.prose blockquote {
  @apply border-l-4 border-primary-500 pl-4 italic text-gray-700 my-6;
}

.prose img {
  @apply rounded-lg shadow-md my-6;
}

.prose pre {
  @apply bg-gray-100 rounded-lg p-4 overflow-x-auto my-6;
}

.prose code {
  @apply bg-gray-100 rounded px-2 py-1 text-sm;
}

.prose table {
  @apply w-full border-collapse border border-gray-300 my-6;
}

.prose th,
.prose td {
  @apply border border-gray-300 px-4 py-2 text-left;
}

.prose th {
  @apply bg-gray-100 font-semibold;
}*/
</style>