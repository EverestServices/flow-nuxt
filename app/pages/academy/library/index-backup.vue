<template>
  <div class="min-h-screen">
    <!-- Header -->
    <div class="flex h-24 items-center justify-between">
      <div class="text-2xl font-light">Academy <span class="font-black">Library</span></div>
      <div class="flex items-center gap-4">
        <!-- Upload Button -->
        <UButton
          icon="i-lucide-upload"
          size="sm"
          color="primary"
          @click="showUploadModal = true"
        >
          Upload Files
        </UButton>
        <!-- New Folder Button -->
        <UButton
          icon="i-lucide-folder-plus"
          size="sm"
          variant="outline"
          @click="showCreateFolderModal = true"
        >
          New Folder
        </UButton>
      </div>
    </div>

    <!-- Content -->
    <div class="py-8">
      <div class="grid grid-cols-12 gap-6">
        <!-- Sidebar -->
        <div class="col-span-3">
          <div class="bg-white rounded-lg shadow-sm border p-6">
            <!-- Search -->
            <div class="mb-6">
              <UInput
                v-model="searchQuery"
                placeholder="Search files and folders..."
                icon="i-lucide-search"
                size="sm"
                @input="handleSearch"
              />
            </div>

            <!-- Categories Filter -->
            <div class="mb-6">
              <h3 class="text-sm font-medium text-gray-900 mb-3">Categories</h3>
              <div class="space-y-2">
                <div
                  v-for="category in categories"
                  :key="category.key"
                  class="flex items-center cursor-pointer p-2 rounded-md hover:bg-gray-50 transition-colors"
                  :class="{ 'bg-blue-50 text-blue-700': selectedCategory === category.key }"
                  @click="selectedCategory = selectedCategory === category.key ? null : category.key"
                >
                  <Icon :name="category.icon" class="w-4 h-4 mr-3" />
                  <span class="text-sm">{{ category.name }}</span>
                  <span class="ml-auto text-xs text-gray-500">{{ category.count }}</span>
                </div>
              </div>
            </div>

            <!-- File Types Filter -->
            <div class="mb-6">
              <h3 class="text-sm font-medium text-gray-900 mb-3">File Types</h3>
              <div class="space-y-2">
                <div
                  v-for="type in fileTypes"
                  :key="type.key"
                  class="flex items-center cursor-pointer p-2 rounded-md hover:bg-gray-50 transition-colors"
                  :class="{ 'bg-blue-50 text-blue-700': selectedFileType === type.key }"
                  @click="selectedFileType = selectedFileType === type.key ? null : type.key"
                >
                  <div class="w-4 h-4 mr-3 rounded" :style="{ backgroundColor: type.color }"></div>
                  <span class="text-sm">{{ type.name }}</span>
                  <span class="ml-auto text-xs text-gray-500">{{ type.count }}</span>
                </div>
              </div>
            </div>

            <!-- Quick Actions -->
            <div>
              <h3 class="text-sm font-medium text-gray-900 mb-3">Quick Actions</h3>
              <div class="space-y-2">
                <button
                  class="w-full text-left p-2 rounded-md hover:bg-gray-50 transition-colors flex items-center"
                  @click="viewMode = 'recent'"
                >
                  <Icon name="i-lucide-clock" class="w-4 h-4 mr-3" />
                  <span class="text-sm">Recent Files</span>
                </button>
                <button
                  class="w-full text-left p-2 rounded-md hover:bg-gray-50 transition-colors flex items-center"
                  @click="viewMode = 'favorites'"
                >
                  <Icon name="i-lucide-star" class="w-4 h-4 mr-3" />
                  <span class="text-sm">Favorites</span>
                </button>
                <button
                  class="w-full text-left p-2 rounded-md hover:bg-gray-50 transition-colors flex items-center"
                  @click="viewMode = 'shared'"
                >
                  <Icon name="i-lucide-users" class="w-4 h-4 mr-3" />
                  <span class="text-sm">Shared</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="col-span-9">
          <div class="bg-white rounded-lg shadow-sm border">
            <!-- Toolbar -->
            <div class="border-b border-gray-200 px-6 py-4">
              <div class="flex items-center justify-between">
                <!-- Breadcrumb -->
                <nav class="flex items-center space-x-2 text-sm">
                  <button
                    v-for="(crumb, index) in breadcrumbs"
                    :key="index"
                    class="text-gray-500 hover:text-gray-700 transition-colors"
                    @click="navigateToFolder(crumb.path)"
                  >
                    {{ crumb.name }}
                    <Icon
                      v-if="index < breadcrumbs.length - 1"
                      name="i-lucide-chevron-right"
                      class="w-4 h-4 inline ml-2"
                    />
                  </button>
                </nav>

                <!-- View Options -->
                <div class="flex items-center gap-2">
                  <div class="flex bg-gray-100 rounded-md p-1">
                    <button
                      class="p-1 rounded transition-colors"
                      :class="viewType === 'grid' ? 'bg-white shadow-sm' : 'text-gray-500 hover:text-gray-700'"
                      @click="viewType = 'grid'"
                    >
                      <Icon name="i-lucide-grid-3x3" class="w-4 h-4" />
                    </button>
                    <button
                      class="p-1 rounded transition-colors"
                      :class="viewType === 'list' ? 'bg-white shadow-sm' : 'text-gray-500 hover:text-gray-700'"
                      @click="viewType = 'list'"
                    >
                      <Icon name="i-lucide-list" class="w-4 h-4" />
                    </button>
                  </div>
                  <UDropdown :items="sortOptions" :popper="{ placement: 'bottom-end' }">
                    <UButton variant="outline" size="sm" icon="i-lucide-arrow-up-down">
                      Sort
                    </UButton>
                  </UDropdown>
                </div>
              </div>
            </div>

            <!-- File Grid/List View -->
            <div class="p-6">
              <!-- Loading State -->
              <div v-if="loading" class="flex justify-center items-center py-12">
                <Icon name="i-lucide-loader-2" class="w-8 h-8 animate-spin text-gray-400" />
              </div>

              <!-- Empty State -->
              <div v-else-if="filteredItems.length === 0" class="text-center py-12">
                <Icon name="i-lucide-folder-open" class="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 class="text-lg font-medium text-gray-900 mb-2">No files found</h3>
                <p class="text-gray-500 mb-4">Start by uploading your first file or creating a folder</p>
                <div class="flex justify-center gap-3">
                  <UButton size="sm" @click="showUploadModal = true">
                    Upload Files
                  </UButton>
                  <UButton variant="outline" size="sm" @click="showCreateFolderModal = true">
                    Create Folder
                  </UButton>
                </div>
              </div>

              <!-- Grid View -->
              <div v-else-if="viewType === 'grid'" class="grid grid-cols-6 gap-4">
                <div
                  v-for="item in filteredItems"
                  :key="item.id"
                  class="group cursor-pointer"
                  @click="handleItemClick(item)"
                  @dblclick="handleItemDoubleClick(item)"
                >
                  <div class="relative bg-gray-50 rounded-lg p-4 border-2 border-transparent group-hover:border-blue-200 group-hover:bg-blue-50 transition-all">
                    <!-- File/Folder Icon -->
                    <div class="flex justify-center mb-3">
                      <div v-if="item.type === 'folder'" class="w-12 h-12 flex items-center justify-center">
                        <Icon name="i-lucide-folder" class="w-10 h-10 text-blue-500" />
                      </div>
                      <div v-else class="w-12 h-12 flex items-center justify-center rounded border bg-white">
                        <Icon :name="getFileIcon(item.fileType)" class="w-8 h-8" :class="getFileColor(item.fileType)" />
                      </div>
                    </div>

                    <!-- File Name -->
                    <div class="text-center">
                      <p class="text-sm font-medium text-gray-900 truncate" :title="item.name">
                        {{ item.name }}
                      </p>
                      <p v-if="item.type === 'file'" class="text-xs text-gray-500 mt-1">
                        {{ formatFileSize(item.size) }} • {{ formatDate(item.updatedAt) }}
                      </p>
                    </div>

                    <!-- Actions Menu -->
                    <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <UDropdown :items="getItemActions(item)" :popper="{ placement: 'bottom-end' }">
                        <UButton variant="ghost" size="xs" icon="i-lucide-more-vertical" />
                      </UDropdown>
                    </div>

                    <!-- Selection Checkbox -->
                    <div class="absolute top-2 left-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <UCheckbox
                        v-model="selectedItems"
                        :value="item.id"
                        @click.stop
                      />
                    </div>
                  </div>
                </div>
              </div>

              <!-- List View -->
              <div v-else class="overflow-hidden">
                <table class="w-full">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        <UCheckbox v-model="selectAll" @change="handleSelectAll" />
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Size</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Modified</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr
                      v-for="item in filteredItems"
                      :key="item.id"
                      class="hover:bg-gray-50 cursor-pointer"
                      @click="handleItemClick(item)"
                      @dblclick="handleItemDoubleClick(item)"
                    >
                      <td class="px-6 py-4 whitespace-nowrap">
                        <UCheckbox
                          v-model="selectedItems"
                          :value="item.id"
                          @click.stop
                        />
                      </td>
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
                          <span class="text-sm font-medium text-gray-900">{{ item.name }}</span>
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {{ item.type === 'folder' ? 'Folder' : item.fileType?.toUpperCase() }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {{ item.type === 'file' ? formatFileSize(item.size) : '-' }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {{ formatDate(item.updatedAt) }}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <UDropdown :items="getItemActions(item)" :popper="{ placement: 'bottom-end' }">
                          <UButton variant="ghost" size="xs" icon="i-lucide-more-vertical" @click.stop />
                        </UDropdown>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- File Preview Modal -->
    <UModal v-model="showPreviewModal" :ui="{ width: 'w-full max-w-6xl' }">
      <div class="p-6">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold">{{ previewFile?.name }}</h3>
          <UButton variant="ghost" size="sm" icon="i-lucide-x" @click="showPreviewModal = false" />
        </div>

        <!-- File Preview Content -->
        <div class="bg-gray-50 rounded-lg p-8 min-h-96 flex items-center justify-center">
          <div v-if="previewFile?.fileType === 'pdf'" class="w-full">
            <iframe :src="previewFile.url" class="w-full h-96 border-0"></iframe>
          </div>
          <div v-else-if="previewFile?.fileType?.startsWith('image')" class="max-w-full max-h-96">
            <img :src="previewFile.url" :alt="previewFile.name" class="max-w-full max-h-full object-contain" />
          </div>
          <div v-else class="text-center text-gray-500">
            <Icon :name="getFileIcon(previewFile?.fileType)" class="w-16 h-16 mx-auto mb-4" />
            <p>Preview not available for this file type</p>
            <UButton class="mt-4" @click="downloadFile(previewFile)">
              Download File
            </UButton>
          </div>
        </div>

        <!-- File Info -->
        <div class="mt-6 grid grid-cols-3 gap-4 text-sm">
          <div>
            <span class="text-gray-500">Size:</span>
            <span class="ml-2">{{ formatFileSize(previewFile?.size) }}</span>
          </div>
          <div>
            <span class="text-gray-500">Type:</span>
            <span class="ml-2">{{ previewFile?.fileType }}</span>
          </div>
          <div>
            <span class="text-gray-500">Modified:</span>
            <span class="ml-2">{{ formatDate(previewFile?.updatedAt) }}</span>
          </div>
        </div>
      </div>
    </UModal>

    <!-- Upload Modal -->
    <UModal v-model="showUploadModal">
      <div class="p-6">
        <h3 class="text-lg font-semibold mb-4">Upload Files</h3>
        <div class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
          <Icon name="i-lucide-upload" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p class="text-gray-600 mb-2">Drag and drop files here, or click to browse</p>
          <UButton>Choose Files</UButton>
        </div>
      </div>
    </UModal>

    <!-- Create Folder Modal -->
    <UModal v-model="showCreateFolderModal">
      <div class="p-6">
        <h3 class="text-lg font-semibold mb-4">Create New Folder</h3>
        <UInput
          v-model="newFolderName"
          placeholder="Folder name"
          class="mb-4"
        />
        <div class="flex justify-end gap-3">
          <UButton variant="outline" @click="showCreateFolderModal = false">Cancel</UButton>
          <UButton @click="createFolder">Create</UButton>
        </div>
      </div>
    </UModal>
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
const selectAll = ref(false)

// Modals
const showPreviewModal = ref(false)
const showUploadModal = ref(false)
const showCreateFolderModal = ref(false)
const previewFile = ref(null)
const newFolderName = ref('')

// Mock static data for categories and file types (these don't come from the composable)
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

// Categories
const categories = ref([
  { key: 'documents', name: 'Documents', icon: 'i-lucide-file-text', count: 15 },
  { key: 'images', name: 'Images', icon: 'i-lucide-image', count: 8 },
  { key: 'videos', name: 'Videos', icon: 'i-lucide-video', count: 3 },
  { key: 'presentations', name: 'Presentations', icon: 'i-lucide-presentation', count: 5 },
  { key: 'spreadsheets', name: 'Spreadsheets', icon: 'i-lucide-sheet', count: 4 }
])

// File types
const fileTypes = ref([
  { key: 'pdf', name: 'PDF', color: '#dc2626', count: 8 },
  { key: 'docx', name: 'Word', color: '#2563eb', count: 5 },
  { key: 'xlsx', name: 'Excel', color: '#059669', count: 4 },
  { key: 'pptx', name: 'PowerPoint', color: '#ea580c', count: 3 },
  { key: 'jpg', name: 'Images', color: '#7c3aed', count: 12 }
])

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
  let items = libraryItems.value

  // Filter by search query
  if (searchQuery.value) {
    items = items.filter(item =>
      item.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  }

  // Filter by category
  if (selectedCategory.value) {
    items = items.filter(item => item.category === selectedCategory.value)
  }

  // Filter by file type
  if (selectedFileType.value) {
    items = items.filter(item => item.fileType === selectedFileType.value)
  }

  return items
})

// Sort options
const sortOptions = [
  [{ label: 'Name A-Z', click: () => sortBy('name', 'asc') }],
  [{ label: 'Name Z-A', click: () => sortBy('name', 'desc') }],
  [{ label: 'Date Modified', click: () => sortBy('updatedAt', 'desc') }],
  [{ label: 'Size', click: () => sortBy('size', 'desc') }]
]

// Methods
const handleSearch = () => {
  // Search is reactive through computed property
}

const sortBy = (field, direction) => {
  libraryItems.value.sort((a, b) => {
    const aVal = a[field]
    const bVal = b[field]

    if (direction === 'asc') {
      return aVal > bVal ? 1 : -1
    } else {
      return aVal < bVal ? 1 : -1
    }
  })
}

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
  // Load folder contents here
}

const handleSelectAll = () => {
  if (selectAll.value) {
    selectedItems.value = filteredItems.value.map(item => item.id)
  } else {
    selectedItems.value = []
  }
}

const getItemActions = (item) => {
  const baseActions = [
    [{ label: 'Download', icon: 'i-lucide-download', click: () => downloadFile(item) }],
    [{ label: 'Rename', icon: 'i-lucide-edit-2', click: () => renameItem(item) }],
    [{ label: 'Move', icon: 'i-lucide-move', click: () => moveItem(item) }],
    [{ label: 'Delete', icon: 'i-lucide-trash-2', click: () => deleteItem(item) }]
  ]

  if (item.type === 'file') {
    baseActions.unshift([{ label: 'Preview', icon: 'i-lucide-eye', click: () => previewFileAction(item) }])
  }

  return baseActions
}

const previewFileAction = (item) => {
  previewFile.value = item
  showPreviewModal.value = true
}

const downloadFile = (item) => {
  // Implementation for file download
  console.log('Downloading:', item.name)
}

const renameItem = (item) => {
  // Implementation for renaming
  console.log('Renaming:', item.name)
}

const moveItem = (item) => {
  // Implementation for moving
  console.log('Moving:', item.name)
}

const deleteItem = async (item) => {
  await deleteLibraryItem(item.id)
}

const createFolder = async () => {
  if (newFolderName.value.trim()) {
    await createLibraryFolder(newFolderName.value)
    newFolderName.value = ''
    showCreateFolderModal.value = false
  }
}

// Initialize data on mount
onMounted(async () => {
  await fetchLibraryItems()
})

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
  if (bytes === 0) return '0 Bytes'
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
onMounted(() => {
  // Simulate loading
  setTimeout(() => {
    loading.value = false
  }, 1000)
})
</script>