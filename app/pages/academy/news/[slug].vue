<template>

    <!-- Loading State -->
    <div v-if="pending" class="max-w-4xl mx-auto">
      <USkeleton class="h-8 w-3/4 mb-4" />
      <USkeleton class="h-6 w-1/2 mb-8" />
      <USkeleton class="h-64 w-full mb-8 rounded-xl" />
      <div class="space-y-4">
        <USkeleton v-for="i in 8" :key="i" class="h-4 w-full" />
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error || !article" class="max-w-2xl mx-auto">
      <UAlert
        color="red"
        variant="soft"
        title="Article not found"
        description="The requested article could not be found."
      >
        <template #actions>
          <UButton to="/academy/news" variant="outline" color="red">
            Back to News
          </UButton>
        </template>
      </UAlert>
    </div>

    <!-- Article Content -->
    <NewsArticleDetail
      v-else
      :article="article"
      :related-articles="relatedArticles"
    />

</template>

<script setup lang="ts">
import type { NewsArticle } from '~/composables/useNews'

// Define page meta
definePageMeta({
  layout: 'default',
  key: route => route.fullPath
})

const route = useRoute()
const { getArticleBySlug, getRelatedArticles } = useNews()

// Reactive data
const article = ref<NewsArticle | null>(null)
const relatedArticles = ref<NewsArticle[]>([])
const pending = ref(true)
const error = ref(false)

// Load article data
const loadArticle = async () => {
  const slug = route.params.slug as string

  if (!slug) {
    error.value = true
    pending.value = false
    return
  }

  try {
    pending.value = true
    console.log('Loading article:', slug)

    // Get the main article
    const { data: articleData, error: articleError } = await getArticleBySlug(slug)

    if (articleError || !articleData) {
      console.error('Article not found:', slug, articleError)
      error.value = true
      return
    }

    article.value = articleData
    console.log('Article loaded:', articleData.title)

    // Get related articles
    try {
      const { data: related } = await getRelatedArticles(articleData.id, 3)
      relatedArticles.value = related || []
    } catch (relatedError) {
      console.warn('Failed to load related articles:', relatedError)
      relatedArticles.value = []
    }

  } catch (err) {
    console.error('Error loading article:', err)
    error.value = true
  } finally {
    pending.value = false
  }
}

// Load data on mount
onMounted(async () => {
  console.log('Article page mounted')
  await loadArticle()
})

// Watch for route changes
watch(() => route.params.slug, async (newSlug, oldSlug) => {
  if (newSlug && newSlug !== oldSlug) {
    console.log('Route changed, loading new article:', newSlug)
    await loadArticle()
  }
}, { immediate: true })

// SEO Meta
watchEffect(() => {
  if (article.value) {
    useHead({
      title: article.value.meta_title || article.value.title || 'Article - Flow Academy',
      meta: [
        { name: 'description', content: article.value.meta_description || article.value.excerpt || 'Read the latest news from Flow Academy.' }
      ]
    })
  }
})
</script>