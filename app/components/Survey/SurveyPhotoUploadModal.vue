<template>
  <UIModal
    v-model="isOpen"
    size="xl"
    :scrollable="true"
    @close="closeModal"
  >
    <template #header>
      <div class="w-full">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              {{ $t('survey.photos.uploadPhotos') }}
            </h3>
            <p v-if="investmentTitle" class="text-sm text-gray-600 dark:text-gray-400 mt-1">
              {{ investmentTitle }}
            </p>
          </div>
        </div>

        <!-- Overall Progress -->
        <div>
          <div class="flex items-center justify-between mb-2">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('survey.photos.overallProgress') }}
            </span>
            <span v-if="!isNaN(overallPercentage)" class="text-sm font-semibold text-primary-600 dark:text-primary-400">
              {{ overallPercentage }}%
            </span>
          </div>
          <div class="flex items-center gap-2 mb-2">
            <span class="text-xs text-gray-600 dark:text-gray-400">
                {{ $t('survey.photos.minPhotos', { count: totalMinPhotos }) }}
            </span>
          </div>
          <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
            <div
              class="bg-primary-600 h-2 rounded-full transition-all duration-300"
              :style="{ width: (isNaN(overallPercentage) ? 0 : overallPercentage) + '%' }"
            />
          </div>
        </div>
      </div>
    </template>

    <div>
          <div class="space-y-3">
            <UAccordion
              v-for="category in paginatedCategories"
              :key="`${category.id}-${accordionKey}`"
              v-model="openAccordions"
              :items="[{
                label: category.name,
                slot: 'category-' + category.id,
                value: category.id
              }]"
              :ui="{
                item: {
                  base: 'flex-1'
                }
              }"
              multiple
            >
              <template #default="{ item, open }">
                <UButton
                  color="gray"
                  variant="ghost"
                  class="w-full"
                  :ui="{ rounded: 'rounded-lg', padding: { sm: 'p-3' } }"
                >
                  <div class="flex items-center justify-between w-full">
                    <div class="flex items-center gap-2 flex-1">
                      <span class="text-sm font-medium text-gray-900 dark:text-white">
                        {{ category.name }}
                      </span>
                      <!-- Related Investment Icons -->
                      <div v-if="mode === 'all'" class="flex items-center gap-1">
                        <UIcon
                          v-for="icon in category.relatedIcons"
                          :key="icon"
                          :name="icon"
                          class="w-4 h-4 text-gray-600 dark:text-gray-400"
                        />
                      </div>
                    </div>
                    <span class="text-sm font-semibold text-primary-600 dark:text-primary-400 text-right ml-auto">
                      {{ getCategoryPercentage(category.id) }}%
                    </span>
                  </div>
                </UButton>
              </template>

              <template #[`category-${category.id}`]>
                <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-b-lg">
                  <!-- Description -->
                  <p class="text-sm text-gray-600 dark:text-gray-400 mb-3">
                    {{ category.description }}
                  </p>

                  <!-- Progress -->
                  <div class="flex items-center justify-between mb-3">
                    <span class="text-xs text-gray-600 dark:text-gray-400">
                      {{ $t('survey.photos.minPhotos', { count: category.min_photos }) }}
                    </span>
                    <span class="text-xs font-semibold text-primary-600 dark:text-primary-400">
                      {{ getCategoryUploadedCount(category.id) }} / {{ category.min_photos }} {{ $t('survey.photos.uploaded') }}
                    </span>
                  </div>
                  <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1.5 mb-4">
                    <div
                      class="bg-primary-600 h-1.5 rounded-full transition-all duration-300"
                      :style="{ width: getCategoryPercentage(category.id) + '%' }"
                    />
                  </div>

                  <!-- Uploaded Photos Grid -->
                  <div v-if="getCategoryUploadedCount(category.id) > 0" class="mb-4">
                    <div class="grid grid-cols-4 gap-2">
                      <div
                        v-for="(photo, index) in getCategoryPhotos(category.id)"
                        :key="index"
                        class="relative aspect-square bg-gray-200 dark:bg-gray-700 rounded-lg overflow-hidden group"
                      >
                        <img
                          :src="photo.url"
                          :alt="$t('survey.photos.photo', { number: index + 1 })"
                          class="w-full h-full object-cover"
                        >
                        <!-- Delete button -->
                        <button
                          class="absolute top-1 right-1 bg-red-500 text-white p-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                          @click="deletePhoto(category.id, index)"
                        >
                          <UIcon name="i-lucide-trash-2" class="w-3 h-3" />
                        </button>
                      </div>
                    </div>
                  </div>

                  <!-- Upload Buttons -->
                  <div class="flex gap-2">
                    <UIButtonEnhanced
                      variant="outline"
                      size="md"
                      class="flex-1"
                      @click="selectPhoto(category.id)"
                    >
                      <Icon name="i-lucide-image" class="w-4 h-4 mr-2" />
                      {{ $t('survey.photos.selectPhoto') }}
                    </UIButtonEnhanced>
                    <UIButtonEnhanced
                      variant="outline"
                      size="md"
                      class="flex-1"
                      @click="takePhoto(category.id)"
                    >
                      <Icon name="i-lucide-camera" class="w-4 h-4 mr-2" />
                      {{ $t('survey.photos.takePhoto') }}
                    </UIButtonEnhanced>
                  </div>

                  <!-- Hidden file input -->
                  <input
                    :ref="el => fileInputRefs[category.id] = el"
                    type="file"
                    accept="image/*"
                    multiple
                    class="hidden"
                    @change="handleFileSelect($event, category.id)"
                  >
                </div>
              </template>
            </UAccordion>
          </div>
    </div>

    <template #footer v-if="showPagination">
      <div class="flex items-center justify-between w-full">
        <button
          class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="currentPage === 0"
          @click="currentPage--"
        >
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-chevron-left" class="w-4 h-4" />
            <span>{{ $t('survey.photos.previous') }}</span>
          </div>
        </button>

        <span class="text-sm font-medium text-gray-600 dark:text-gray-400">
          {{ currentPage + 1 }} / {{ totalPages }}
        </span>

        <button
          class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="currentPage === totalPages - 1"
          @click="currentPage++"
        >
          <div class="flex items-center gap-2">
            <span>{{ $t('survey.photos.next') }}</span>
            <UIcon name="i-lucide-chevron-right" class="w-4 h-4" />
          </div>
        </button>
      </div>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import type { DocumentCategory } from '~/stores/surveyInvestments'

const { t } = useI18n()
const { translate } = useTranslatableField()
const { addDocument, fetchDocumentsBySurveyAndCategory, deleteDocument } = useDocuments()

interface PhotoData {
  url: string
  file: File
  documentId?: string // Track Supabase document ID
}

interface CategoryPhotos {
  [categoryId: string]: PhotoData[]
}

interface Props {
  modelValue: boolean
  surveyId: string
  mode: 'single' | 'investment' | 'all'
  categoryId?: string
  investmentId?: string
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const store = useSurveyInvestmentsStore()

const isOpen = ref(false)

// Sync with parent v-model
watch(() => props.modelValue, (value) => {
  isOpen.value = value
})

watch(isOpen, (value) => {
  if (value !== props.modelValue) {
    emit('update:modelValue', value)
  }
})

const closeModal = () => {
  isOpen.value = false
  emit('update:modelValue', false)
}

// File input refs
const fileInputRefs = ref<Record<string, HTMLInputElement>>({})

// Uploaded photos storage
const categoryPhotos = ref<CategoryPhotos>({})

// Pagination
const currentPage = ref(0)
const itemsPerPage = 1

// Force accordion to re-render when modal opens
const accordionKey = ref(0)

// Keep track of which accordions are open (all should be open by default)
const openAccordions = ref<string[]>([])

// Get categories based on mode
const categories = computed(() => {
  const cats: Array<DocumentCategory & { relatedIcons?: string[] }> = []

  if (props.mode === 'single') {
    // Mode 1: All categories from all investments (for pagination through individual categories)
    store.selectedInvestments.forEach(inv => {
      const invCategories = store.documentCategories[inv.id] || []
      cats.push(...invCategories)
    })
  } else if (props.mode === 'investment' && props.investmentId) {
    // Mode 2: All categories for one investment
    const invCategories = store.documentCategories[props.investmentId] || []
    cats.push(...invCategories)
  } else if (props.mode === 'all') {
    // Mode 3: All categories for all investments
    const categoryMap: Record<string, DocumentCategory & { relatedIcons: string[] }> = {}

    store.selectedInvestments.forEach(inv => {
      const invCategories = store.documentCategories[inv.id] || []
      invCategories.forEach(cat => {
        if (!categoryMap[cat.persist_name]) {
          categoryMap[cat.persist_name] = { ...cat, relatedIcons: [] }
        }
        categoryMap[cat.persist_name].relatedIcons!.push(inv.icon)
      })
    })

    cats.push(...Object.values(categoryMap))
  }

  return cats
})

// Investment groups (for mode 2 pagination)
const investmentGroups = computed(() => {
  if (props.mode !== 'investment') return []

  return store.selectedInvestments.map(inv => ({
    investment: inv,
    categories: store.documentCategories[inv.id] || []
  })).filter(group => group.categories.length > 0)
})

// Investment title
const investmentTitle = computed(() => {
  if (props.mode === 'investment') {
    // In mode 2, show the current page's investment name
    const currentGroup = investmentGroups.value[currentPage.value]
    if (!currentGroup) return ''
    return translate(currentGroup.investment.name_translations, currentGroup.investment.name)
  } else if (props.mode === 'all') {
    return t('survey.photos.allInvestments')
  }
  return ''
})

// Total minimum photos
const totalMinPhotos = computed(() => {
  return categories.value.reduce((sum, cat) => sum + cat.min_photos, 0)
})

// Overall percentage
const overallPercentage = computed(() => {
  if (totalMinPhotos.value === 0) return 0

  const totalUploaded = categories.value.reduce((sum, cat) => {
    const uploaded = getCategoryUploadedCount(cat.id)
    // Csak a minimum photos-ig számolunk, a fölötti képek nem számítanak bele
    return sum + Math.min(uploaded, cat.min_photos)
  }, 0)
  const percentage = (totalUploaded / totalMinPhotos.value) * 100
  return Math.min(100, Math.round(percentage))
})

// Pagination
const totalPages = computed(() => {
  if (props.mode === 'all') {
    return 1
  } else if (props.mode === 'investment') {
    // Mode 2: Number of investments with categories
    return Math.max(1, investmentGroups.value.length)
  } else {
    // Mode 1: Number of categories (1 per page)
    return Math.max(1, categories.value.length)
  }
})

const showPagination = computed(() => {
  return props.mode !== 'all' && totalPages.value > 1
})

const paginatedCategories = computed(() => {
  if (props.mode === 'all') {
    // Mode 3: All categories at once
    return categories.value
  } else if (props.mode === 'investment') {
    // Mode 2: All categories from the current investment
    const currentGroup = investmentGroups.value[currentPage.value]
    return currentGroup?.categories || []
  } else {
    // Mode 1: Single category per page
    return categories.value.slice(currentPage.value, currentPage.value + itemsPerPage)
  }
})

// Category methods
const getCategoryUploadedCount = (categoryId: string) => {
  // Get from local state OR from store (persistent)
  const localCount = categoryPhotos.value[categoryId]?.length || 0
  const storeCount = store.getCategoryPhotoCount(categoryId)
  return Math.max(localCount, storeCount)
}

const getCategoryPercentage = (categoryId: string) => {
  const category = categories.value.find(c => c.id === categoryId)
  if (!category) return 0

  const uploaded = getCategoryUploadedCount(categoryId)
  const percentage = (uploaded / category.min_photos) * 100
  return Math.min(100, Math.round(percentage))
}

const getCategoryPhotos = (categoryId: string) => {
  return categoryPhotos.value[categoryId] || []
}

// Photo handling
const selectPhoto = (categoryId: string) => {
  const input = fileInputRefs.value[categoryId]
  if (input) {
    input.click()
  }
}

const handleFileSelect = async (event: Event, categoryId: string) => {
  const target = event.target as HTMLInputElement
  const files = target.files

  if (!files) return

  // Initialize category photos array if needed
  if (!categoryPhotos.value[categoryId]) {
    categoryPhotos.value[categoryId] = []
  }

  // Upload each file to Supabase
  for (let i = 0; i < files.length; i++) {
    const file = files[i]
    const url = URL.createObjectURL(file)

    // Add to local state immediately for UX
    const photoData: PhotoData = { url, file }
    categoryPhotos.value[categoryId].push(photoData)

    // Upload to Supabase in background
    try {
      console.log('📤 Uploading photo to Supabase:', { surveyId: props.surveyId, categoryId, fileName: file.name })
      const document = await addDocument(props.surveyId, categoryId, file, file.name)
      console.log('✅ Photo uploaded successfully:', document)

      if (document) {
        // Update photo data with document ID
        photoData.documentId = document.id
        photoData.url = document.location // Use Supabase URL
      } else {
        console.error('❌ Upload returned null/undefined')
      }
    } catch (error) {
      console.error('❌ Error uploading photo:', error)
      // Remove from local state if upload failed
      const index = categoryPhotos.value[categoryId].indexOf(photoData)
      if (index > -1) {
        categoryPhotos.value[categoryId].splice(index, 1)
      }
      alert(`Failed to upload photo: ${error}`)
    }
  }

  // Update persistent store
  store.updateCategoryPhotoCount(categoryId, categoryPhotos.value[categoryId].length)

  // Reset input
  target.value = ''
}

const takePhoto = async (categoryId: string) => {
  // Check if camera is available
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    alert(t('survey.photos.cameraNotAvailable'))
    return
  }

  // For now, fallback to file input with camera capture
  const input = fileInputRefs.value[categoryId]
  if (input) {
    input.setAttribute('capture', 'environment')
    input.click()
    // Reset capture attribute after
    setTimeout(() => {
      input.removeAttribute('capture')
    }, 100)
  }
}

const deletePhoto = async (categoryId: string, index: number) => {
  if (categoryPhotos.value[categoryId]) {
    const photo = categoryPhotos.value[categoryId][index]

    // Delete from Supabase if it has a document ID
    if (photo.documentId) {
      try {
        await deleteDocument(photo.documentId)
      } catch (error) {
        console.error('Error deleting photo from Supabase:', error)
      }
    }

    // Clean up object URL
    if (photo.url.startsWith('blob:')) {
      URL.revokeObjectURL(photo.url)
    }

    // Remove from local state
    categoryPhotos.value[categoryId].splice(index, 1)

    // Update persistent store
    store.updateCategoryPhotoCount(categoryId, categoryPhotos.value[categoryId].length)
  }
}

// Load existing photos from Supabase for a category
const loadCategoryPhotos = async (categoryId: string) => {
  try {
    console.log('📥 Loading photos from Supabase for category:', categoryId)
    const documents = await fetchDocumentsBySurveyAndCategory(props.surveyId, categoryId)
    console.log('📥 Loaded documents:', documents)

    if (documents && documents.length > 0) {
      categoryPhotos.value[categoryId] = documents.map(doc => ({
        url: doc.location, // Public URL from bucket
        file: new File([], doc.name),
        documentId: doc.id
      }))

      // Update store count
      store.updateCategoryPhotoCount(categoryId, documents.length)
      console.log(`✅ Loaded ${documents.length} photos for category ${categoryId}`)
    } else {
      console.log(`ℹ️ No photos found for category ${categoryId}`)
    }
  } catch (error) {
    console.error('❌ Error loading category photos:', error)
  }
}

// Lapozás visszaállítása és photo counts inicializálása a felugró ablak megnyitásakor
watch(() => props.modelValue, async (newValue, oldValue) => {
  if (newValue && !oldValue) {
    console.log('🔄 Photo upload modal opened')

    // Force accordion to re-render with defaultOpen: true
    accordionKey.value++

    // If categoryId is provided in single mode, find its index and set currentPage
    if (props.mode === 'single' && props.categoryId) {
      const categoryIndex = categories.value.findIndex(cat => cat.id === props.categoryId)
      if (categoryIndex !== -1) {
        currentPage.value = categoryIndex
        console.log(`📍 Opening modal to category at index ${categoryIndex}:`, props.categoryId)
      } else {
        currentPage.value = 0
        console.warn(`⚠️ Category ${props.categoryId} not found, defaulting to first category`)
      }
    } else {
      currentPage.value = 0
    }

    // Clear old local-only photos (blob URLs) and reload from Supabase
    Object.keys(categoryPhotos.value).forEach(catId => {
      const photos = categoryPhotos.value[catId] || []
      photos.forEach(photo => {
        if (photo.url.startsWith('blob:')) {
          URL.revokeObjectURL(photo.url)
        }
      })
    })
    categoryPhotos.value = {} // Clear all local state

    // Load existing photos from Supabase for all categories
    console.log('📂 Loading photos for', categories.value.length, 'categories')
    for (const category of categories.value) {
      await loadCategoryPhotos(category.id)
    }

    // Open all accordions by default after categories are loaded
    await nextTick()
    openAccordions.value = categories.value.map(cat => cat.id)
    console.log('🔓 Opening all accordions:', openAccordions.value)
  }
})
</script>

<style scoped>
/* Make accordion label span full width */
:deep(.text-start.break-words) {
  flex: 1;
  min-width: 0;
}
</style>
