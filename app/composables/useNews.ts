// Types - exported outside the composable
export interface NewsCategory {
  id: string
  name: string
  slug: string
  description?: string
  color: string
  is_active: boolean
  sort_order: number
  created_at: string
  updated_at: string
}

export interface NewsArticle {
  id: string
  title: string
  slug: string
  excerpt?: string
  content: string
  featured_image_url?: string
  featured_image_alt?: string
  category_id?: string
  category?: NewsCategory
  tags?: string[]
  company_id?: string
  is_global: boolean
  is_featured: boolean
  is_published: boolean
  author_id: string
  editor_id?: string
  meta_title?: string
  meta_description?: string
  view_count: number
  published_at?: string
  created_at: string
  updated_at: string
}

export interface NewsView {
  id: string
  article_id: string
  user_id?: string
  company_id?: string
  ip_address?: string
  user_agent?: string
  created_at: string
}

export interface NewsFilters {
  category?: string
  search?: string
  is_featured?: boolean
  is_global?: boolean
  company_id?: string
  tags?: string[]
  limit?: number
  offset?: number
}

export const useNews = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  // Categories
  const getCategories = async (): Promise<{ data: NewsCategory[] | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const createCategory = async (category: Partial<NewsCategory>): Promise<{ data: NewsCategory | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_categories')
        .insert([category])
        .select()
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const updateCategory = async (id: string, updates: Partial<NewsCategory>): Promise<{ data: NewsCategory | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_categories')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const deleteCategory = async (id: string): Promise<{ error: any }> => {
    try {
      const { error } = await supabase
        .from('news_categories')
        .delete()
        .eq('id', id)

      return { error }
    } catch (error) {
      return { error }
    }
  }

  // Articles
  const getArticles = async (filters: NewsFilters = {}): Promise<{ data: NewsArticle[] | null; error: any; count?: number }> => {
    try {
      let query = supabase
        .from('news_articles')
        .select(`
          *,
          category:news_categories(*)
        `, { count: 'exact' })
        .eq('is_published', true)
        .lte('published_at', new Date().toISOString())
        .order('published_at', { ascending: false })

      // Apply filters
      if (filters.category) {
        query = query.eq('category_id', filters.category)
      }

      if (filters.is_featured !== undefined) {
        query = query.eq('is_featured', filters.is_featured)
      }

      if (filters.is_global !== undefined) {
        query = query.eq('is_global', filters.is_global)
      }

      if (filters.company_id) {
        query = query.eq('company_id', filters.company_id)
      }

      if (filters.tags && filters.tags.length > 0) {
        query = query.overlaps('tags', filters.tags)
      }

      if (filters.search) {
        query = query.textSearch('title,excerpt,content', filters.search, {
          type: 'websearch',
          config: 'english'
        })
      }

      if (filters.limit) {
        query = query.limit(filters.limit)
      }

      if (filters.offset) {
        query = query.range(filters.offset, filters.offset + (filters.limit || 10) - 1)
      }

      const { data, error, count } = await query

      return { data, error, count: count || 0 }
    } catch (error) {
      return { data: null, error, count: 0 }
    }
  }

  const getFeaturedArticles = async (limit: number = 3): Promise<{ data: NewsArticle[] | null; error: any }> => {
    return getArticles({
      is_featured: true,
      limit
    })
  }

  const getArticleBySlug = async (slug: string): Promise<{ data: NewsArticle | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_articles')
        .select(`
          *,
          category:news_categories(*)
        `)
        .eq('slug', slug)
        .eq('is_published', true)
        .lte('published_at', new Date().toISOString())
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const getArticleById = async (id: string): Promise<{ data: NewsArticle | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_articles')
        .select(`
          *,
          category:news_categories(*)
        `)
        .eq('id', id)
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const createArticle = async (article: Partial<NewsArticle>): Promise<{ data: NewsArticle | null; error: any }> => {
    try {
      const articleData = {
        ...article,
        author_id: user.value?.id
      }

      const { data, error } = await supabase
        .from('news_articles')
        .insert([articleData])
        .select(`
          *,
          category:news_categories(*)
        `)
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const updateArticle = async (id: string, updates: Partial<NewsArticle>): Promise<{ data: NewsArticle | null; error: any }> => {
    try {
      const { data, error } = await supabase
        .from('news_articles')
        .update(updates)
        .eq('id', id)
        .select(`
          *,
          category:news_categories(*)
        `)
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const deleteArticle = async (id: string): Promise<{ error: any }> => {
    try {
      const { error } = await supabase
        .from('news_articles')
        .delete()
        .eq('id', id)

      return { error }
    } catch (error) {
      return { error }
    }
  }

  const publishArticle = async (id: string): Promise<{ data: NewsArticle | null; error: any }> => {
    return updateArticle(id, {
      is_published: true,
      published_at: new Date().toISOString()
    })
  }

  const unpublishArticle = async (id: string): Promise<{ data: NewsArticle | null; error: any }> => {
    return updateArticle(id, {
      is_published: false
    })
  }

  // Views and Analytics
  const recordView = async (articleId: string, additionalData: Partial<NewsView> = {}): Promise<{ data: NewsView | null; error: any }> => {
    try {
      const viewData = {
        article_id: articleId,
        user_id: user.value?.id,
        ...additionalData
      }

      const { data, error } = await supabase
        .from('news_views')
        .insert([viewData])
        .select()
        .single()

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  const getArticleViews = async (articleId: string): Promise<{ data: NewsView[] | null; error: any; count?: number }> => {
    try {
      const { data, error, count } = await supabase
        .from('news_views')
        .select('*', { count: 'exact' })
        .eq('article_id', articleId)
        .order('created_at', { ascending: false })

      return { data, error, count: count || 0 }
    } catch (error) {
      return { data: null, error, count: 0 }
    }
  }

  // Image Upload
  const uploadImage = async (file: File, folder: string = 'articles'): Promise<{ data: { publicUrl: string } | null; error: any }> => {
    try {
      if (!user.value?.id) {
        return { data: null, error: new Error('User not authenticated') }
      }

      const fileExt = file.name.split('.').pop()
      const fileName = `${user.value.id}/${folder}/${Date.now()}.${fileExt}`

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('news-images')
        .upload(fileName, file)

      if (uploadError) {
        return { data: null, error: uploadError }
      }

      const { data: { publicUrl } } = supabase.storage
        .from('news-images')
        .getPublicUrl(fileName)

      return { data: { publicUrl }, error: null }
    } catch (error) {
      return { data: null, error }
    }
  }

  const deleteImage = async (path: string): Promise<{ error: any }> => {
    try {
      const { error } = await supabase.storage
        .from('news-images')
        .remove([path])

      return { error }
    } catch (error) {
      return { error }
    }
  }

  // Search functionality
  const searchArticles = async (query: string, filters: NewsFilters = {}): Promise<{ data: NewsArticle[] | null; error: any }> => {
    return getArticles({
      ...filters,
      search: query
    })
  }

  // Get related articles
  const getRelatedArticles = async (articleId: string, limit: number = 3): Promise<{ data: NewsArticle[] | null; error: any }> => {
    try {
      // First get the current article to find its category and tags
      const { data: currentArticle, error: currentError } = await getArticleById(articleId)

      if (currentError || !currentArticle) {
        return { data: null, error: currentError }
      }

      let query = supabase
        .from('news_articles')
        .select(`
          *,
          category:news_categories(*)
        `)
        .eq('is_published', true)
        .neq('id', articleId)
        .limit(limit)
        .order('published_at', { ascending: false })

      // Prefer articles from the same category
      if (currentArticle.category_id) {
        query = query.eq('category_id', currentArticle.category_id)
      }

      const { data, error } = await query

      return { data, error }
    } catch (error) {
      return { data: null, error }
    }
  }

  return {
    // Categories
    getCategories,
    createCategory,
    updateCategory,
    deleteCategory,

    // Articles
    getArticles,
    getFeaturedArticles,
    getArticleBySlug,
    getArticleById,
    createArticle,
    updateArticle,
    deleteArticle,
    publishArticle,
    unpublishArticle,
    getRelatedArticles,

    // Views and Analytics
    recordView,
    getArticleViews,

    // Images
    uploadImage,
    deleteImage,

    // Search
    searchArticles
  }
}