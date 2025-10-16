import { z } from 'zod'

// Library item schema
export const libraryItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: z.enum(['file', 'folder']),
  path: z.string(),
  parentId: z.string().nullable(),
  fileType: z.string().nullable(),
  mimeType: z.string().nullable(),
  size: z.number().nullable(),
  url: z.string().nullable(),
  category: z.string().nullable(),
  tags: z.array(z.string()).default([]),
  isPublic: z.boolean().default(false),
  isFavorite: z.boolean().default(false),
  createdAt: z.string(),
  updatedAt: z.string(),
  createdBy: z.string(),
  companyId: z.string()
})

export const createLibraryItemSchema = libraryItemSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
  createdBy: true,
  companyId: true
})

export const updateLibraryItemSchema = libraryItemSchema.partial().extend({
  id: z.string()
})

export type LibraryItem = z.infer<typeof libraryItemSchema>
export type CreateLibraryItem = z.infer<typeof createLibraryItemSchema>
export type UpdateLibraryItem = z.infer<typeof updateLibraryItemSchema>

export interface LibraryFilters {
  category?: string
  fileType?: string
  isPublic?: boolean
  isFavorite?: boolean
  search?: string
  path?: string
  parentId?: string
}

export const useLibrary = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Reactive state
  const libraryItems = ref<LibraryItem[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const currentPath = ref('/')

  // Get user's company_id
  const getUserCompanyId = async (): Promise<string | null> => {
    if (!user.value) return null

    try {
      const { data, error } = await client
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.value.id)
        .single()

      if (error) throw error
      return data?.company_id || null
    } catch (err) {
      console.error('Error getting user company ID:', err)
      return null
    }
  }

  // Fetch library items
  const fetchLibraryItems = async (filters: LibraryFilters = {}) => {
    try {
      loading.value = true
      error.value = null

      let query = client
        .from('library_items')
        .select('*')
        .order('type', { ascending: false }) // Folders first
        .order('name', { ascending: true })

      // Apply filters
      if (filters.path) {
        // Get items in specific path
        const pathParts = filters.path.split('/').filter(Boolean)
        if (pathParts.length === 0) {
          // Root level
          query = query.is('parent_id', null)
        } else {
          // Find parent folder by path and get its children
          // This would require a more complex query or recursive approach
          // For now, we'll use parent_id directly if provided
          if (filters.parentId) {
            query = query.eq('parent_id', filters.parentId)
          }
        }
      }

      if (filters.category) {
        query = query.eq('category', filters.category)
      }

      if (filters.fileType) {
        query = query.eq('file_type', filters.fileType)
      }

      if (filters.isPublic !== undefined) {
        query = query.eq('is_public', filters.isPublic)
      }

      if (filters.isFavorite !== undefined) {
        query = query.eq('is_favorite', filters.isFavorite)
      }

      if (filters.search) {
        query = query.ilike('name', `%${filters.search}%`)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      // Validate and parse data
      libraryItems.value = (data || []).map(item => {
        try {
          return libraryItemSchema.parse({
            ...item,
            createdAt: item.created_at,
            updatedAt: item.updated_at,
            createdBy: item.created_by,
            companyId: item.company_id,
            parentId: item.parent_id,
            fileType: item.file_type,
            mimeType: item.mime_type,
            isPublic: item.is_public,
            isFavorite: item.is_favorite
          })
        } catch (e) {
          console.error('Invalid library item data:', item, e)
          return null
        }
      }).filter(Boolean) as LibraryItem[]

    } catch (err) {
      console.error('Error fetching library items:', err)
      error.value = 'Failed to load library items. Please try again later.'
    } finally {
      loading.value = false
    }
  }

  // Create library item (file or folder)
  const createLibraryItem = async (itemData: CreateLibraryItem): Promise<LibraryItem | null> => {
    try {
      if (!user.value) throw new Error('User not authenticated')

      const companyId = await getUserCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      // Validate input data
      const validatedData = createLibraryItemSchema.parse(itemData)

      const { data, error: createError } = await client
        .from('library_items')
        .insert({
          ...validatedData,
          created_by: user.value.id,
          company_id: companyId,
          parent_id: validatedData.parentId,
          file_type: validatedData.fileType,
          mime_type: validatedData.mimeType,
          is_public: validatedData.isPublic,
          is_favorite: validatedData.isFavorite
        })
        .select()
        .single()

      if (createError) throw createError

      const newItem = libraryItemSchema.parse({
        ...data,
        createdAt: data.created_at,
        updatedAt: data.updated_at,
        createdBy: data.created_by,
        companyId: data.company_id,
        parentId: data.parent_id,
        fileType: data.file_type,
        mimeType: data.mime_type,
        isPublic: data.is_public,
        isFavorite: data.is_favorite
      })

      // Add to local state
      libraryItems.value.push(newItem)

      return newItem
    } catch (err) {
      console.error('Error creating library item:', err)
      error.value = 'Failed to create item. Please try again.'
      return null
    }
  }

  // Update library item
  const updateLibraryItem = async (itemData: UpdateLibraryItem): Promise<LibraryItem | null> => {
    try {
      // Validate input data
      const validatedData = updateLibraryItemSchema.parse(itemData)
      const { id, ...updateFields } = validatedData

      const dbUpdateFields: any = { ...updateFields }

      // Map field names to database column names
      if (updateFields.parentId !== undefined) {
        dbUpdateFields.parent_id = updateFields.parentId
        delete dbUpdateFields.parentId
      }
      if (updateFields.fileType !== undefined) {
        dbUpdateFields.file_type = updateFields.fileType
        delete dbUpdateFields.fileType
      }
      if (updateFields.mimeType !== undefined) {
        dbUpdateFields.mime_type = updateFields.mimeType
        delete dbUpdateFields.mimeType
      }
      if (updateFields.isPublic !== undefined) {
        dbUpdateFields.is_public = updateFields.isPublic
        delete dbUpdateFields.isPublic
      }
      if (updateFields.isFavorite !== undefined) {
        dbUpdateFields.is_favorite = updateFields.isFavorite
        delete dbUpdateFields.isFavorite
      }

      const { data, error: updateError } = await client
        .from('library_items')
        .update(dbUpdateFields)
        .eq('id', id)
        .select()
        .single()

      if (updateError) throw updateError

      const updatedItem = libraryItemSchema.parse({
        ...data,
        createdAt: data.created_at,
        updatedAt: data.updated_at,
        createdBy: data.created_by,
        companyId: data.company_id,
        parentId: data.parent_id,
        fileType: data.file_type,
        mimeType: data.mime_type,
        isPublic: data.is_public,
        isFavorite: data.is_favorite
      })

      // Update local state
      const index = libraryItems.value.findIndex(item => item.id === id)
      if (index !== -1) {
        libraryItems.value[index] = updatedItem
      }

      return updatedItem
    } catch (err) {
      console.error('Error updating library item:', err)
      error.value = 'Failed to update item. Please try again.'
      return null
    }
  }

  // Delete library item
  const deleteLibraryItem = async (itemId: string): Promise<boolean> => {
    try {
      const { error: deleteError } = await client
        .from('library_items')
        .delete()
        .eq('id', itemId)

      if (deleteError) throw deleteError

      // Remove from local state
      libraryItems.value = libraryItems.value.filter(item => item.id !== itemId)

      return true
    } catch (err) {
      console.error('Error deleting library item:', err)
      error.value = 'Failed to delete item. Please try again.'
      return false
    }
  }

  // Upload file
  const uploadFile = async (file: File, parentId?: string): Promise<LibraryItem | null> => {
    try {
      if (!user.value) throw new Error('User not authenticated')

      const companyId = await getUserCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      // Upload file to Supabase Storage
      const fileName = `${Date.now()}_${file.name}`
      const filePath = `${companyId}/${fileName}`

      const { data: uploadData, error: uploadError } = await client.storage
        .from('library-files')
        .upload(filePath, file)

      if (uploadError) throw uploadError

      // Get public URL
      const { data: { publicUrl } } = client.storage
        .from('library-files')
        .getPublicUrl(filePath)

      // Create library item record
      const fileExtension = file.name.split('.').pop()?.toLowerCase()
      const category = getCategoryFromFileType(fileExtension)

      const libraryItem = await createLibraryItem({
        name: file.name,
        type: 'file',
        path: currentPath.value + file.name,
        parentId: parentId || null,
        fileType: fileExtension || null,
        mimeType: file.type || null,
        size: file.size,
        url: publicUrl,
        category,
        tags: [],
        isPublic: false,
        isFavorite: false
      })

      return libraryItem
    } catch (err) {
      console.error('Error uploading file:', err)
      error.value = 'Failed to upload file. Please try again.'
      return null
    }
  }

  // Create folder
  const createFolder = async (name: string, parentId?: string): Promise<LibraryItem | null> => {
    const folderPath = currentPath.value === '/' ? `/${name}` : `${currentPath.value}/${name}`

    return await createLibraryItem({
      name,
      type: 'folder',
      path: folderPath,
      parentId: parentId || null,
      fileType: null,
      mimeType: null,
      size: null,
      url: null,
      category: null,
      tags: [],
      isPublic: false,
      isFavorite: false
    })
  }

  // Toggle favorite
  const toggleFavorite = async (itemId: string): Promise<boolean> => {
    const item = libraryItems.value.find(item => item.id === itemId)
    if (!item) return false

    const updated = await updateLibraryItem({
      id: itemId,
      isFavorite: !item.isFavorite
    })

    return updated !== null
  }

  // Move item
  const moveItem = async (itemId: string, newParentId: string | null): Promise<boolean> => {
    const updated = await updateLibraryItem({
      id: itemId,
      parentId: newParentId
    })

    return updated !== null
  }

  // Helper function to determine category from file type
  const getCategoryFromFileType = (fileType?: string): string | null => {
    if (!fileType) return null

    const categoryMap: Record<string, string> = {
      'pdf': 'documents',
      'doc': 'documents',
      'docx': 'documents',
      'txt': 'documents',
      'xls': 'spreadsheets',
      'xlsx': 'spreadsheets',
      'csv': 'spreadsheets',
      'ppt': 'presentations',
      'pptx': 'presentations',
      'jpg': 'images',
      'jpeg': 'images',
      'png': 'images',
      'gif': 'images',
      'svg': 'images',
      'mp4': 'videos',
      'avi': 'videos',
      'mov': 'videos',
      'wmv': 'videos'
    }

    return categoryMap[fileType.toLowerCase()] || null
  }

  // Computed properties
  const folders = computed(() => libraryItems.value.filter(item => item.type === 'folder'))
  const files = computed(() => libraryItems.value.filter(item => item.type === 'file'))
  const favorites = computed(() => libraryItems.value.filter(item => item.isFavorite))
  const publicItems = computed(() => libraryItems.value.filter(item => item.isPublic))

  return {
    // State
    libraryItems: readonly(libraryItems),
    loading: readonly(loading),
    error: readonly(error),
    currentPath: readonly(currentPath),

    // Actions
    fetchLibraryItems,
    createLibraryItem,
    updateLibraryItem,
    deleteLibraryItem,
    uploadFile,
    createFolder,
    toggleFavorite,
    moveItem,

    // Computed
    folders,
    files,
    favorites,
    publicItems,

    // Utils
    getCategoryFromFileType,
    getUserCompanyId
  }
}