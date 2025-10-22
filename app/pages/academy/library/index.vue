<template>
  <div>
    <!-- Header -->
    <div class="flex h-24 items-center justify-between">
      <div class="text-2xl font-light">Academy <span class="font-black">Library</span></div>
      <div class="flex items-center gap-3">
        <UIButtonEnhanced
          icon="i-lucide-upload"
          variant="primary"
          size="md"
          @click="showUploadModal = true"
        >
          Upload Files
        </UIButtonEnhanced>
        <UIButtonEnhanced
          icon="i-lucide-folder-plus"
          variant="outline"
          size="md"
          @click="showCreateFolderModal = true"
        >
          New Folder
        </UIButtonEnhanced>
      </div>
    </div>

    <div class="flex flex-col space-y-8">
      <!-- Welcome Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">
        <!-- Stats Cards -->
        <div class="flex flex-col basis-0 items-start justify-center">
          <div class="grid grid-cols-3 gap-4 w-full">
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-blue-600 dark:text-blue-400">
                {{ folderCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Folders</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-purple-600 dark:text-purple-400">
                {{ fileCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Files</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-green-600 dark:text-green-400">
                {{ formatFileSize(totalSize) }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Total Size</div>
            </UIBox>
          </div>
        </div>
      </div>

      <!-- Filters & Search -->
      <UIBox>
        <div class="flex items-center gap-3 p-4">
          <div class="flex-1">
            <UIInput
              v-model="searchQuery"
              placeholder="Search files and folders..."
              icon="i-lucide-search"
            />
          </div>
          <UISelect
            v-model="selectedCategory"
            :options="categoryOptions"
            size="sm"
            class="w-40"
          />
          <UISelect
            v-model="selectedFileType"
            :options="fileTypeOptions"
            size="sm"
            class="w-32"
          />
          <button
            @click="viewType = viewType === 'grid' ? 'list' : 'grid'"
            class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <Icon v-if="viewType === 'grid'" name="i-lucide-list" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
            <Icon v-else name="i-lucide-grid-3x3" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </button>
        </div>
      </UIBox>

      <!-- Breadcrumb -->
      <nav class="flex items-center space-x-2 text-sm px-2">
        <button
          v-for="(crumb, index) in breadcrumbs"
          :key="index"
          class="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 transition-colors flex items-center"
          @click="navigateToFolder(crumb.path)"
        >
          {{ crumb.name }}
          <Icon
            v-if="index < breadcrumbs.length - 1"
            name="i-lucide-chevron-right"
            class="w-4 h-4 ml-2"
          />
        </button>
      </nav>

      <!-- Loading State -->
      <UIBox v-if="loading" class="p-12">
        <div class="flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      </UIBox>

      <!-- Empty State -->
      <UIBox v-else-if="filteredItems.length === 0" class="p-12">
        <div class="text-center">
          <Icon name="i-lucide-folder-open" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">No files found</h3>
          <p class="text-gray-500 dark:text-gray-400 mb-4">
            Start by uploading your first file or creating a folder
          </p>
          <div class="flex justify-center gap-3">
            <UIButtonEnhanced @click="showUploadModal = true">
              Upload Files
            </UIButtonEnhanced>
            <UIButtonEnhanced variant="outline" @click="showCreateFolderModal = true">
              Create Folder
            </UIButtonEnhanced>
          </div>
        </div>
      </UIBox>

      <!-- Grid View -->
      <div v-else-if="viewType === 'grid'" class="grid grid-cols-6 gap-4">
        <UIBox
          v-for="item in filteredItems"
          :key="item.id"
          class="cursor-pointer hover:shadow-xl transition-all duration-200"
          @click="handleItemClick(item)"
          @dblclick="handleItemDoubleClick(item)"
        >
          <div class="p-4">
            <!-- File/Folder Icon -->
            <div class="flex justify-center mb-3">
              <div v-if="item.type === 'folder'" class="w-12 h-12 flex items-center justify-center">
                <Icon name="i-lucide-folder" class="w-10 h-10 text-blue-500" />
              </div>
              <div v-else class="w-12 h-12 flex items-center justify-center rounded border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800">
                <Icon :name="getFileIcon(item.fileType)" class="w-8 h-8" :class="getFileColor(item.fileType)" />
              </div>
            </div>

            <!-- File Name -->
            <div class="text-center">
              <p class="text-sm font-medium text-gray-900 dark:text-white truncate" :title="item.name">
                {{ item.name }}
              </p>
              <p v-if="item.type === 'file'" class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                {{ formatFileSize(item.size) }}
              </p>
              <p class="text-xs text-gray-400 dark:text-gray-500">
                {{ formatDate(item.updatedAt) }}
              </p>
            </div>
          </div>
        </UIBox>
      </div>

      <!-- List View -->
      <UIBox v-else class="overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-700/50 border-b border-gray-200 dark:border-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Name
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Type
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Size
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Modified
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="item in filteredItems"
              :key="item.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-700/30 cursor-pointer transition-colors"
              @click="handleItemClick(item)"
              @dblclick="handleItemDoubleClick(item)"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <Icon
                    v-if="item.type === 'folder'"
                    name="i-lucide-folder"
                    class="w-5 h-5 text-blue-500 mr-3"
                  />
                  <Icon
                    v-else
                    :name="getFileIcon(item.fileType)"
                    class="w-5 h-5 mr-3"
                    :class="getFileColor(item.fileType)"
                  />
                  <span class="text-sm font-medium text-gray-900 dark:text-white">{{ item.name }}</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ item.type === 'folder' ? 'Folder' : item.fileType?.toUpperCase() }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ item.type === 'file' ? formatFileSize(item.size) : '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                {{ formatDate(item.updatedAt) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <button
                  @click.stop="downloadFile(item)"
                  class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <Icon name="i-lucide-download" class="w-4 h-4" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </UIBox>
    </div>

    <!-- File Preview Modal -->
    <Transition name="fade">
      <div
        v-if="showPreviewModal"
        class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        @click.self="showPreviewModal = false"
      >
        <UIBox class="w-full max-w-4xl max-h-[90vh] overflow-y-auto" @click.stop>
          <div class="p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ previewFile?.name }}</h3>
              <button
                @click="showPreviewModal = false"
                class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              >
                <Icon name="i-lucide-x" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
              </button>
            </div>

            <!-- File Preview Content -->
            <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-8 min-h-96 flex items-center justify-center">
              <div class="text-center text-gray-500 dark:text-gray-400">
                <Icon :name="getFileIcon(previewFile?.fileType)" class="w-16 h-16 mx-auto mb-4" />
                <p>Preview not available for this file type</p>
                <UIButtonEnhanced class="mt-4" @click="downloadFile(previewFile)">
                  Download File
                </UIButtonEnhanced>
              </div>
            </div>

            <!-- File Info -->
            <div class="mt-6 grid grid-cols-3 gap-4 text-sm">
              <div>
                <span class="text-gray-500 dark:text-gray-400">Size:</span>
                <span class="ml-2 text-gray-900 dark:text-white">{{ formatFileSize(previewFile?.size) }}</span>
              </div>
              <div>
                <span class="text-gray-500 dark:text-gray-400">Type:</span>
                <span class="ml-2 text-gray-900 dark:text-white">{{ previewFile?.fileType }}</span>
              </div>
              <div>
                <span class="text-gray-500 dark:text-gray-400">Modified:</span>
                <span class="ml-2 text-gray-900 dark:text-white">{{ formatDate(previewFile?.updatedAt) }}</span>
              </div>
            </div>
          </div>
        </UIBox>
      </div>
    </Transition>

    <!-- Upload Modal -->
    <Transition name="fade">
      <div
        v-if="showUploadModal"
        class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        @click.self="showUploadModal = false"
      >
        <UIBox class="w-full max-w-lg" @click.stop>
          <div class="p-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Upload Files</h3>
            <div class="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg p-8 text-center">
              <Icon name="i-lucide-upload" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p class="text-gray-600 dark:text-gray-400 mb-4">Drag and drop files here, or click to browse</p>
              <UIButtonEnhanced>Choose Files</UIButtonEnhanced>
            </div>
          </div>
        </UIBox>
      </div>
    </Transition>

    <!-- Create Folder Modal -->
    <Transition name="fade">
      <div
        v-if="showCreateFolderModal"
        class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        @click.self="showCreateFolderModal = false"
      >
        <UIBox class="w-full max-w-md" @click.stop>
          <div class="p-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Create New Folder</h3>
            <UIInput
              v-model="newFolderName"
              placeholder="Folder name"
              class="mb-4"
            />
            <div class="flex justify-end gap-3">
              <UIButtonEnhanced variant="outline" @click="showCreateFolderModal = false">
                Cancel
              </UIButtonEnhanced>
              <UIButtonEnhanced @click="createFolder">
                Create
              </UIButtonEnhanced>
            </div>
          </div>
        </UIBox>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useLibrary } from '~/composables/useLibrary'

// Page meta
useHead({
  title: 'Library - EverestFlow'
})

// Library composable
const {
  libraryItems,
  loading,
  error,
  fetchLibraryItems,
  createFolder: createLibraryFolder,
  uploadFile,
  deleteLibraryItem,
  toggleFavorite
} = useLibrary()

// State
const searchQuery = ref('')
const selectedCategory = ref(null)
const selectedFileType = ref(null)
const viewType = ref('grid')
const viewMode = ref('all')
const currentPath = ref('/')
const selectedItems = ref([])

// Modals
const showPreviewModal = ref(false)
const showUploadModal = ref(false)
const showCreateFolderModal = ref(false)
const previewFile = ref(null)
const newFolderName = ref('')

// Mock static data
const staticLibraryItems = ref([
  {
    id: '1',
    name: 'Documents',
    type: 'folder',
    path: '/documents',
    createdAt: new Date('2024-01-15'),
    updatedAt: new Date('2024-01-20')
  },
  {
    id: '2',
    name: 'Images',
    type: 'folder',
    path: '/images',
    createdAt: new Date('2024-01-10'),
    updatedAt: new Date('2024-01-18')
  },
  {
    id: '3',
    name: 'Training Materials',
    type: 'folder',
    path: '/training',
    createdAt: new Date('2024-01-05'),
    updatedAt: new Date('2024-01-25')
  },
  {
    id: '4',
    name: 'Project Report.pdf',
    type: 'file',
    fileType: 'pdf',
    category: 'documents',
    size: 2048576,
    url: '/files/project-report.pdf',
    createdAt: new Date('2024-01-22'),
    updatedAt: new Date('2024-01-22')
  },
  {
    id: '5',
    name: 'Presentation.pptx',
    type: 'file',
    fileType: 'pptx',
    category: 'presentations',
    size: 5242880,
    url: '/files/presentation.pptx',
    createdAt: new Date('2024-01-20'),
    updatedAt: new Date('2024-01-21')
  },
  {
    id: '6',
    name: 'Budget Spreadsheet.xlsx',
    type: 'file',
    fileType: 'xlsx',
    category: 'documents',
    size: 1048576,
    url: '/files/budget.xlsx',
    createdAt: new Date('2024-01-18'),
    updatedAt: new Date('2024-01-19')
  }
])

// Select options
const categoryOptions = [
  { label: 'All Categories', value: null },
  { label: 'Documents', value: 'documents' },
  { label: 'Images', value: 'images' },
  { label: 'Videos', value: 'videos' },
  { label: 'Presentations', value: 'presentations' }
]

const fileTypeOptions = [
  { label: 'All Types', value: null },
  { label: 'PDF', value: 'pdf' },
  { label: 'Word', value: 'docx' },
  { label: 'Excel', value: 'xlsx' },
  { label: 'PowerPoint', value: 'pptx' }
]

// Breadcrumbs
const breadcrumbs = computed(() => {
  const parts = currentPath.value.split('/').filter(Boolean)
  const crumbs = [{ name: 'Library', path: '/' }]

  parts.forEach((part, index) => {
    const path = '/' + parts.slice(0, index + 1).join('/')
    crumbs.push({ name: part, path })
  })

  return crumbs
})

// Filtered items
const filteredItems = computed(() => {
  let items = libraryItems.value.length ? libraryItems.value : staticLibraryItems.value

  if (searchQuery.value) {
    items = items.filter(item =>
      item.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  }

  if (selectedCategory.value) {
    items = items.filter(item => item.category === selectedCategory.value)
  }

  if (selectedFileType.value) {
    items = items.filter(item => item.fileType === selectedFileType.value)
  }

  return items
})

// Stats
const folderCount = computed(() => filteredItems.value.filter(i => i.type === 'folder').length)
const fileCount = computed(() => filteredItems.value.filter(i => i.type === 'file').length)
const totalSize = computed(() => filteredItems.value.reduce((sum, item) => sum + (item.size || 0), 0))

// Methods
const handleItemClick = (item) => {
  if (selectedItems.value.includes(item.id)) {
    selectedItems.value = selectedItems.value.filter(id => id !== item.id)
  } else {
    selectedItems.value.push(item.id)
  }
}

const handleItemDoubleClick = (item) => {
  if (item.type === 'folder') {
    navigateToFolder(item.path)
  } else {
    previewFile.value = item
    showPreviewModal.value = true
  }
}

const navigateToFolder = (path) => {
  currentPath.value = path
}

const downloadFile = (item) => {
  console.log('Downloading:', item.name)
}

const createFolder = async () => {
  if (newFolderName.value.trim()) {
    await createLibraryFolder(newFolderName.value)
    newFolderName.value = ''
    showCreateFolderModal.value = false
  }
}

const getFileIcon = (fileType) => {
  const iconMap = {
    'pdf': 'i-lucide-file-text',
    'docx': 'i-lucide-file-text',
    'doc': 'i-lucide-file-text',
    'xlsx': 'i-lucide-sheet',
    'xls': 'i-lucide-sheet',
    'pptx': 'i-lucide-presentation',
    'ppt': 'i-lucide-presentation',
    'jpg': 'i-lucide-image',
    'jpeg': 'i-lucide-image',
    'png': 'i-lucide-image',
    'gif': 'i-lucide-image',
    'mp4': 'i-lucide-video',
    'avi': 'i-lucide-video',
    'mov': 'i-lucide-video'
  }
  return iconMap[fileType?.toLowerCase()] || 'i-lucide-file'
}

const getFileColor = (fileType) => {
  const colorMap = {
    'pdf': 'text-red-500',
    'docx': 'text-blue-500',
    'doc': 'text-blue-500',
    'xlsx': 'text-green-500',
    'xls': 'text-green-500',
    'pptx': 'text-orange-500',
    'ppt': 'text-orange-500',
    'jpg': 'text-purple-500',
    'jpeg': 'text-purple-500',
    'png': 'text-purple-500',
    'gif': 'text-purple-500',
    'mp4': 'text-pink-500',
    'avi': 'text-pink-500',
    'mov': 'text-pink-500'
  }
  return colorMap[fileType?.toLowerCase()] || 'text-gray-500'
}

const formatFileSize = (bytes) => {
  if (!bytes || bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Initialize
onMounted(async () => {
  await fetchLibraryItems()
  setTimeout(() => {
    loading.value = false
  }, 1000)
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
