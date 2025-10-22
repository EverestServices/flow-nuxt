/**
 * useDocuments Composable
 * Handles document and photo uploads for surveys
 */

import type {
  Document,
  DocumentCategory,
  DocumentCategoryWithDocuments,
  InsertDocument
} from '~/types/survey-new'

export const useDocuments = () => {
  const supabase = useSupabaseClient()

  // State
  const documents = ref<Document[]>([])
  const categories = ref<DocumentCategoryWithDocuments[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const uploadProgress = ref(0)

  /**
   * Fetch all document categories
   */
  const fetchDocumentCategories = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('document_categories')
        .select(`
          *,
          investments:investment_document_categories(
            position,
            investment:investments(*)
          )
        `)

      if (fetchError) throw fetchError

      categories.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching document categories:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch document categories for a specific investment
   */
  const fetchCategoriesByInvestment = async (investmentId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('investment_document_categories')
        .select(`
          position,
          document_category:document_categories(*)
        `)
        .eq('investment_id', investmentId)
        .order('position', { ascending: true })

      if (fetchError) throw fetchError

      return data?.map(item => item.document_category) || []
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching categories by investment:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch documents for a specific survey
   */
  const fetchDocumentsBySurvey = async (surveyId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('documents')
        .select(`
          *,
          category:document_categories(*)
        `)
        .eq('survey_id', surveyId)

      if (fetchError) throw fetchError

      documents.value = data || []
      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching documents:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Fetch documents for a survey and category
   */
  const fetchDocumentsBySurveyAndCategory = async (surveyId: string, categoryId: string) => {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('documents')
        .select('*')
        .eq('survey_id', surveyId)
        .eq('document_category_id', categoryId)

      if (fetchError) throw fetchError

      return data || []
    } catch (e: any) {
      error.value = e.message
      console.error('Error fetching documents by category:', e)
      return []
    } finally {
      loading.value = false
    }
  }

  /**
   * Upload a file to Supabase Storage
   */
  const uploadFile = async (file: File, surveyId: string, categoryId: string): Promise<string | null> => {
    try {
      uploadProgress.value = 0

      // Generate unique filename
      const fileExt = file.name.split('.').pop()
      const fileName = `${surveyId}/${categoryId}/${Date.now()}.${fileExt}`

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from('survey-documents')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (uploadError) throw uploadError

      uploadProgress.value = 100

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('survey-documents')
        .getPublicUrl(fileName)

      return urlData.publicUrl
    } catch (e: any) {
      error.value = e.message
      console.error('Error uploading file:', e)
      return null
    }
  }

  /**
   * Create document record and upload file
   */
  const addDocument = async (
    surveyId: string,
    categoryId: string,
    file: File,
    name?: string
  ): Promise<Document | null> => {
    loading.value = true
    error.value = null

    try {
      // 1. Upload file to storage
      const location = await uploadFile(file, surveyId, categoryId)
      if (!location) throw new Error('File upload failed')

      // 2. Create document record
      const { data, error: insertError } = await supabase
        .from('documents')
        .insert({
          survey_id: surveyId,
          document_category_id: categoryId,
          name: name || file.name,
          location
        })
        .select()
        .single()

      if (insertError) throw insertError

      // Add to local state
      documents.value.push(data)

      return data
    } catch (e: any) {
      error.value = e.message
      console.error('Error adding document:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Delete a document (file and record)
   */
  const deleteDocument = async (documentId: string) => {
    loading.value = true
    error.value = null

    try {
      // 1. Get document to find file path
      const { data: doc, error: fetchError } = await supabase
        .from('documents')
        .select('location')
        .eq('id', documentId)
        .single()

      if (fetchError) throw fetchError

      // 2. Delete from storage
      if (doc?.location) {
        const fileName = doc.location.split('/').slice(-3).join('/')
        const { error: storageError } = await supabase.storage
          .from('survey-documents')
          .remove([fileName])

        if (storageError) console.warn('Error deleting file from storage:', storageError)
      }

      // 3. Delete database record
      const { error: deleteError } = await supabase
        .from('documents')
        .delete()
        .eq('id', documentId)

      if (deleteError) throw deleteError

      // Remove from local state
      documents.value = documents.value.filter(d => d.id !== documentId)

      return true
    } catch (e: any) {
      error.value = e.message
      console.error('Error deleting document:', e)
      return false
    } finally {
      loading.value = false
    }
  }

  /**
   * Get documents count by category
   */
  const getDocumentsCountByCategory = (categoryId: string): number => {
    return documents.value.filter(d => d.document_category_id === categoryId).length
  }

  /**
   * Check if category has minimum required photos
   */
  const hasSufficientPhotos = (categoryId: string, minPhotos: number): boolean => {
    return getDocumentsCountByCategory(categoryId) >= minPhotos
  }

  /**
   * Get completion status for all categories
   */
  const getCategoryCompletionStatus = (requiredCategories: { id: string; minPhotos: number }[]) => {
    return requiredCategories.map(cat => ({
      categoryId: cat.id,
      count: getDocumentsCountByCategory(cat.id),
      required: cat.minPhotos,
      isComplete: hasSufficientPhotos(cat.id, cat.minPhotos)
    }))
  }

  return {
    // State
    documents: readonly(documents),
    categories: readonly(categories),
    loading: readonly(loading),
    error: readonly(error),
    uploadProgress: readonly(uploadProgress),

    // Methods
    fetchDocumentCategories,
    fetchCategoriesByInvestment,
    fetchDocumentsBySurvey,
    fetchDocumentsBySurveyAndCategory,
    addDocument,
    deleteDocument,
    getDocumentsCountByCategory,
    hasSufficientPhotos,
    getCategoryCompletionStatus
  }
}
