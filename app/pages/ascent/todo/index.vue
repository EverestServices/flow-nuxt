<template>
  <div class="flex h-24 items-center justify-between">
    <div>
      <div class="text-2xl font-light outfit">{{ $t('todo.title') }}</div>
      <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">{{ $t('todo.subtitle') }}</p>
    </div>
    <Modals-Todo-Create @created="handleTodoCreated" @updated="handleTodoUpdated" />
  </div>

  <!-- Statistics Cards -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">{{ $t('todo.statistics.totalTasks') }}</p>
          <UIH3 class="mt-2">{{ todos?.length || 0 }}</UIH3>
        </div>
        <div class="w-16 h-16 bg-blue-500/20 rounded-full flex items-center justify-center">
          <Icon name="i-lucide-list-todo" class="w-8 h-8 text-blue-500" />
        </div>
      </div>
    </UIBox>

    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">{{ $t('todo.statistics.pending') }}</p>
          <UIH3 class="mt-2">{{ pendingTodos?.length || 0 }}</UIH3>
        </div>
        <div class="w-16 h-16 bg-yellow-500/20 rounded-full flex items-center justify-center">
          <Icon name="i-lucide-clock" class="w-8 h-8 text-yellow-600" />
        </div>
      </div>
    </UIBox>

    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">{{ $t('todo.statistics.completed') }}</p>
          <UIH3 class="mt-2">{{ completedTodos?.length || 0 }}</UIH3>
        </div>
        <div class="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center">
          <Icon name="i-lucide-check-circle" class="w-8 h-8 text-green-500" />
        </div>
      </div>
    </UIBox>
  </div>

  <!-- Filters Section with Grid Layout -->
  <div class="mb-6 grid grid-cols-12 gap-6">
    <!-- Left Column - Filters Label -->
    <div class="col-span-2">
      <div class="flex items-center gap-2 text-gray-700 dark:text-gray-300 font-medium">
        <Icon name="i-lucide-filter" class="w-5 h-5" />
        <span>{{ $t('todo.filters.label') }}</span>
      </div>
    </div>

    <!-- Right Column - Filter Buttons -->
    <div class="col-span-10">
      <div class="flex gap-3 items-center">
        <div class="flex gap-2">
          <UIButtonEnhanced
            @click="currentFilter = 'all'"
            :variant="currentFilter === 'all' ? 'secondary' : 'ghost'"
            size="sm"
          >
            <template #icon>
              <span class="w-2 h-2 rounded-full bg-gray-400"></span>
            </template>
            {{ $t('todo.filters.all') }}
          </UIButtonEnhanced>
          <UIButtonEnhanced
            @click="currentFilter = 'overdue'"
            :variant="currentFilter === 'overdue' ? 'danger' : 'ghost'"
            size="sm"
          >
            <template #icon>
              <span class="w-2 h-2 rounded-full bg-red-500"></span>
            </template>
            {{ $t('todo.filters.overdue') }}
          </UIButtonEnhanced>
          <UIButtonEnhanced
            @click="currentFilter = 'today'"
            :variant="currentFilter === 'today' ? 'primary' : 'ghost'"
            size="sm"
          >
            <template #icon>
              <span class="w-2 h-2 rounded-full bg-yellow-500"></span>
            </template>
            {{ $t('todo.filters.today') }}
          </UIButtonEnhanced>
          <UIButtonEnhanced
            @click="currentFilter = 'next3days'"
            :variant="currentFilter === 'next3days' ? 'success' : 'ghost'"
            size="sm"
          >
            <template #icon>
              <span class="w-2 h-2 rounded-full bg-green-500"></span>
            </template>
            {{ $t('todo.filters.next3days') }}
          </UIButtonEnhanced>
        </div>

        <!-- Search Input -->
        <div class="flex-1 max-w-md">
          <UIInput
            v-model="searchQuery"
            type="text"
            :placeholder="$t('todo.filters.searchPlaceholder')"
            size="sm"
            :block="false"
          >
            <template #prefix>
              <Icon name="i-lucide-search" class="w-4 h-4" />
            </template>
          </UIInput>
        </div>
      </div>
    </div>
  </div>

  <!-- Main Content Grid -->
  <div class="grid grid-cols-12 gap-6">
    <!-- Left Column - Category Buttons -->
    <div class="col-span-2">
      <div class="flex flex-col gap-2">
        <UIButtonEnhanced
          v-for="category in categories"
          :key="category.key"
          variant="ghost"
          size="sm"
          :block="true"
          class="!justify-between"
        >
          <span>{{ category.label }}</span>
          <UIBadge variant="gray" size="xs">{{ category.count }}</UIBadge>
        </UIButtonEnhanced>
      </div>
    </div>

    <!-- Todo List Column -->
    <div class="col-span-10">
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>

      <!-- Error State -->
      <UIAlert v-else-if="error" variant="danger" :title="$t('todo.errors.errorLoadingTasks')" dismissible @dismiss="error = null">
        {{ error }}
      </UIAlert>

      <!-- Empty State -->
      <UIBox v-else-if="!filteredTodos || filteredTodos.length === 0" padding="p-12">
        <div class="flex flex-col items-center justify-center text-center">
          <div class="w-24 h-24 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mb-4">
            <Icon name="i-lucide-inbox" class="w-12 h-12 text-gray-400" />
          </div>
          <UIH2 class="mb-2">{{ $t('todo.emptyStates.noTasksFound') }}</UIH2>
          <p class="text-gray-600 dark:text-gray-400 mb-6">
            {{ getEmptyStateMessage() }}
          </p>
          <UIButtonEnhanced variant="primary" @click="openCreateModal">
            <template #icon>
              <Icon name="i-lucide-plus" class="w-5 h-5" />
            </template>
            {{ $t('todo.actions.createTask') }}
          </UIButtonEnhanced>
        </div>
      </UIBox>

      <!-- Todo List -->
      <UIBox padding="p-6" v-else>
        <!-- Pagination Header -->
        <div class="flex items-center justify-between mb-6">
          <!-- Left: Page Size Selector -->
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600 dark:text-gray-400">{{ $t('todo.pagination.show') }}</span>
            <UISelect
              v-model="pageSize"
              :options="[5, 10, 20, 50]"
              size="sm"
              :block="false"
              class="w-20"
            />
            <span class="text-sm text-gray-600 dark:text-gray-400">{{ $t('todo.pagination.entries') }}</span>
          </div>

          <!-- Center: Pagination Controls -->
          <div class="flex items-center gap-2">
            <UIButtonEnhanced
              @click="currentPage = 1"
              :disabled="currentPage === 1"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevrons-left"
            />
            <UIButtonEnhanced
              @click="currentPage--"
              :disabled="currentPage === 1"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevron-left"
            />

            <div class="flex items-center gap-1">
              <template v-for="page in visiblePages" :key="page">
                <span
                  v-if="page === -1"
                  class="px-3 py-1.5 text-sm text-gray-500 dark:text-gray-400"
                >
                  ...
                </span>
                <UIButtonEnhanced
                  v-else
                  @click="currentPage = page"
                  :variant="currentPage === page ? 'primary' : 'ghost'"
                  size="xs"
                >
                  {{ page }}
                </UIButtonEnhanced>
              </template>
            </div>

            <UIButtonEnhanced
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevron-right"
            />
            <UIButtonEnhanced
              @click="currentPage = totalPages"
              :disabled="currentPage === totalPages"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevrons-right"
            />
          </div>

          <!-- Right: Results Summary -->
          <div class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('todo.pagination.showing', { start: startIndex + 1, end: endIndex, total: filteredTodos.length }) }}
          </div>
        </div>

        <!-- Todo Items -->
        <div class="flex flex-col gap-y-4 min-h-128">
          <TodoItem
            v-for="(todo, index) in paginatedTodos"
            :key="todo?.id || index"
            :todo="todo"
            @toggle="toggleTodoStatus"
            @edit="editTodo"
            @delete="confirmDeleteTodo"
          />
        </div>

        <!-- Pagination Footer -->
        <div class="flex items-center justify-between mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
          <!-- Left: Page Size Selector -->
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600 dark:text-gray-400">{{ $t('todo.pagination.show') }}</span>
            <UISelect
              v-model="pageSize"
              :options="[5, 10, 20, 50]"
              size="sm"
              :block="false"
              class="w-20"
            />
            <span class="text-sm text-gray-600 dark:text-gray-400">{{ $t('todo.pagination.entries') }}</span>
          </div>

          <!-- Center: Pagination Controls -->
          <div class="flex items-center gap-2">
            <UIButtonEnhanced
              @click="currentPage = 1"
              :disabled="currentPage === 1"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevrons-left"
            />
            <UIButtonEnhanced
              @click="currentPage--"
              :disabled="currentPage === 1"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevron-left"
            />

            <div class="flex items-center gap-1">
              <template v-for="page in visiblePages" :key="page">
                <span
                  v-if="page === -1"
                  class="px-3 py-1.5 text-sm text-gray-500 dark:text-gray-400"
                >
                  ...
                </span>
                <UIButtonEnhanced
                  v-else
                  @click="currentPage = page"
                  :variant="currentPage === page ? 'primary' : 'ghost'"
                  size="xs"
                >
                  {{ page }}
                </UIButtonEnhanced>
              </template>
            </div>

            <UIButtonEnhanced
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevron-right"
            />
            <UIButtonEnhanced
              @click="currentPage = totalPages"
              :disabled="currentPage === totalPages"
              variant="ghost"
              size="xs"
              icon="i-lucide-chevrons-right"
            />
          </div>

          <!-- Right: Results Summary -->
          <div class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('todo.pagination.showing', { start: startIndex + 1, end: endIndex, total: filteredTodos.length }) }}
          </div>
        </div>
      </UIBox>
    </div>
  </div>

  <!-- Delete Confirmation Modal -->
  <UIModal
    v-model="showDeleteModal"
    :title="$t('todo.deleteModal.title')"
    size="sm"
  >
    <UIAlert variant="warning" :title="$t('todo.deleteModal.warning')" :hide-icon="false">
      {{ $t('todo.deleteModal.confirmMessage') }}
    </UIAlert>

    <div class="mt-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">{{ $t('todo.deleteModal.taskLabel') }}</p>
      <p class="font-medium text-black dark:text-white">{{ todoToDelete?.title }}</p>
    </div>

    <template #footer>
      <UIButtonEnhanced variant="ghost" @click="showDeleteModal = false">
        {{ $t('todo.actions.cancel') }}
      </UIButtonEnhanced>
      <UIButtonEnhanced variant="danger" @click="handleDeleteTodo">
        <template #icon>
          <Icon name="i-lucide-trash-2" class="w-5 h-5" />
        </template>
        {{ $t('todo.actions.deleteTask') }}
      </UIButtonEnhanced>
    </template>
  </UIModal>

  <!-- Todo Edit Modal -->
  <TodoEditModal
    :todo="editingTodo"
    :is-open="showEditModal"
    @close="closeEditModal"
    @updated="handleTodoUpdated"
  />
</template>

<script setup lang="ts">
import type { Todo } from '~/composables/useTodos'
import TodoEditModal from '~/components/modals/TodoEditModal.vue'
import UIBox from '~/components/UI/Box.vue'
import UIH2 from '~/components/UI/H2.vue'
import UIH3 from '~/components/UI/H3.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UIBadge from '~/components/UI/Badge.vue'
import UIAlert from '~/components/UI/Alert.vue'
import UIModal from '~/components/UI/Modal.vue'
import UIInput from '~/components/UI/Input.vue'
import UISelect from '~/components/UI/Select.vue'

// Page metadata
useHead({
  title: 'Task Management | EverestFlow'
})

// Supabase client
const client = useSupabaseClient()
const user = useSupabaseUser()

// State
const todos = ref([])
const loading = ref(false)
const error = ref(null)
const currentFilter = ref('all')
const searchQuery = ref('')

// Pagination state
const pageSize = ref(10)
const currentPage = ref(1)

// Modal state
const editingTodo = ref<Todo | null>(null)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const todoToDelete = ref<Todo | null>(null)

// Composables
const { t } = useI18n()

// Category menu items
const categories = computed(() => [
  { key: 'all', label: t('todo.categories.all'), count: 0 },
  { key: 'tickets', label: t('todo.categories.tickets'), count: 0 },
  { key: 'news', label: t('todo.categories.news'), count: 0 },
  { key: 'back_in_car', label: t('todo.categories.backInCar'), count: 0 },
  { key: 'courses_exams', label: t('todo.categories.coursesExams'), count: 0 },
  { key: 'energy_consultation', label: t('todo.categories.energyConsultation'), count: 0 },
  { key: 'leads_to_clients', label: t('todo.categories.leadsToClients'), count: 0 },
  { key: 'contract_to_collect', label: t('todo.categories.contractToCollect'), count: 0 },
  { key: 'todo_made_by_me', label: t('todo.categories.todoMadeByMe'), count: 0 },
  { key: 'completed', label: t('todo.categories.completed'), count: 0 }
])

// Helper functions for date filtering
const isToday = (date: string | null): boolean => {
  if (!date) return false
  const today = new Date()
  const dueDate = new Date(date)
  return (
    dueDate.getDate() === today.getDate() &&
    dueDate.getMonth() === today.getMonth() &&
    dueDate.getFullYear() === today.getFullYear()
  )
}

const isOverdue = (date: string | null): boolean => {
  if (!date) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const dueDate = new Date(date)
  dueDate.setHours(0, 0, 0, 0)
  return dueDate < today
}

const isNext3Days = (date: string | null): boolean => {
  if (!date) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const dueDate = new Date(date)
  dueDate.setHours(0, 0, 0, 0)
  const threeDaysFromNow = new Date(today)
  threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3)
  return dueDate >= today && dueDate <= threeDaysFromNow
}

// Computed
const pendingTodos = computed(() => todos.value.filter(todo => !todo.completed))
const completedTodos = computed(() => todos.value.filter(todo => todo.completed))

const filteredTodos = computed(() => {
  const pending = pendingTodos.value
  let filtered: typeof todos.value = []

  // Apply date filter
  switch (currentFilter.value) {
    case 'overdue':
      filtered = pending.filter(todo => isOverdue(todo.due_date))
      break
    case 'today':
      filtered = pending.filter(todo => isToday(todo.due_date))
      break
    case 'next3days':
      filtered = pending.filter(todo => isNext3Days(todo.due_date))
      break
    default:
      filtered = todos.value
  }

  // Apply search filter
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim()
    filtered = filtered.filter(todo => {
      // Search in title
      if (todo.title?.toLowerCase().includes(query)) return true

      // Search in description
      if (todo.description?.toLowerCase().includes(query)) return true

      // Search in category
      if (todo.category?.toLowerCase().includes(query)) return true

      // Search in tags
      if (todo.tags?.some(tag => tag.toLowerCase().includes(query))) return true

      // Search in priority
      if (todo.priority?.toLowerCase().includes(query)) return true

      return false
    })
  }

  return filtered
})

const filterTitle = computed(() => {
  switch (currentFilter.value) {
    case 'overdue':
      return 'Overdue Tasks'
    case 'today':
      return "Today's Tasks"
    case 'next3days':
      return 'Next 3 Days Tasks'
    default:
      return 'All Tasks'
  }
})

// Pagination computed
const totalPages = computed(() => Math.ceil(filteredTodos.value.length / pageSize.value) || 1)

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, filteredTodos.value.length))

const paginatedTodos = computed(() => {
  return filteredTodos.value.slice(startIndex.value, endIndex.value)
})

const visiblePages = computed(() => {
  const total = totalPages.value
  const current = currentPage.value
  const pages: number[] = []

  if (total <= 7) {
    // Show all pages if 7 or fewer
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Always show first page
    pages.push(1)

    if (current > 3) {
      pages.push(-1) // Ellipsis
    }

    // Show pages around current
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
      pages.push(i)
    }

    if (current < total - 2) {
      pages.push(-1) // Ellipsis
    }

    // Always show last page
    pages.push(total)
  }

  return pages
})

// Watch for changes that should reset pagination
watch([currentFilter, pageSize, searchQuery], () => {
  currentPage.value = 1
})

// Methods
const getEmptyStateMessage = () => {
  switch (currentFilter.value) {
    case 'overdue':
      return t('todo.emptyStates.noOverdueTasks')
    case 'today':
      return t('todo.emptyStates.noTasksToday')
    case 'next3days':
      return t('todo.emptyStates.noTasksNext3Days')
    default:
      return t('todo.emptyStates.getStarted')
  }
}

const openCreateModal = () => {
  // Trigger the create modal (it's already in the header)
  // You can emit an event or call a method if needed
}

const toggleTodoStatus = async (id: number) => {
  try {
    const todoIndex = todos.value.findIndex(todo => todo.id === id)
    if (todoIndex === -1) return

    const todo = todos.value[todoIndex]
    const newCompleted = !todo.completed

    const { error: updateError } = await client
      .from('todos')
      .update({ completed: newCompleted })
      .eq('id', id)

    if (updateError) {
      console.error('Error updating todo:', updateError)
      error.value = t('todo.errors.failedToUpdate')
      return
    }

    todos.value[todoIndex].completed = newCompleted
  } catch (err) {
    console.error('Error toggling todo:', err)
    error.value = t('todo.errors.failedToUpdate')
  }
}

const editTodo = (todo: Todo) => {
  editingTodo.value = todo
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
  editingTodo.value = null
}

const confirmDeleteTodo = (todo: Todo) => {
  todoToDelete.value = todo
  showDeleteModal.value = true
}

const handleDeleteTodo = async () => {
  if (!todoToDelete.value) return

  try {
    const { error: deleteError } = await client
      .from('todos')
      .delete()
      .eq('id', todoToDelete.value.id)

    if (deleteError) {
      console.error('Error deleting todo:', deleteError)
      error.value = t('todo.errors.failedToDelete')
      return
    }

    await fetchTodos()
  } catch (err) {
    console.error('Error deleting todo:', err)
    error.value = t('todo.errors.failedToDelete')
  } finally {
    showDeleteModal.value = false
    todoToDelete.value = null
  }
}

const handleTodoCreated = async () => {
  await fetchTodos()
}

const handleTodoUpdated = async () => {
  closeEditModal()
  await fetchTodos()
}

const fetchTodos = async () => {
  try {
    loading.value = true
    error.value = null

    const { data, error: supabaseError } = await client
      .from('todos')
      .select('*')
      .order('created_at', { ascending: false })

    if (supabaseError) {
      console.error('Supabase error:', supabaseError)
      error.value = t('todo.errors.failedToFetch') + ': ' + supabaseError.message
      return
    }

    todos.value = data || []
  } catch (err) {
    console.error('Error:', err)
    error.value = t('todo.errors.failedToFetch')
  } finally {
    loading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await fetchTodos()
})
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
