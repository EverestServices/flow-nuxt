<template>
  <div class="flex h-24 items-center justify-between">
    <div>
      <div class="text-2xl font-light outfit">Task<span class="font-black">Management</span></div>
      <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">Organize and track your daily tasks efficiently</p>
    </div>
    <Modals-Todo-Create @created="handleTodoCreated" @updated="handleTodoUpdated" />
  </div>

  <!-- Statistics Cards -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">Total Tasks</p>
          <h3 class="text-4xl font-black outfit mt-2 text-black dark:text-white">{{ todos?.length || 0 }}</h3>
        </div>
        <div class="w-16 h-16 bg-blue-500/20 rounded-2xl flex items-center justify-center">
          <Icon name="i-lucide-list-todo" class="w-8 h-8 text-blue-500" />
        </div>
      </div>
    </UIBox>

    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">Pending</p>
          <h3 class="text-4xl font-black outfit mt-2 text-black dark:text-white">{{ pendingTodos?.length || 0 }}</h3>
        </div>
        <div class="w-16 h-16 bg-yellow-500/20 rounded-2xl flex items-center justify-center">
          <Icon name="i-lucide-clock" class="w-8 h-8 text-yellow-600" />
        </div>
      </div>
    </UIBox>

    <UIBox padding="p-6" class="hover:scale-105 transition-transform">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400 outfit">Completed</p>
          <h3 class="text-4xl font-black outfit mt-2 text-black dark:text-white">{{ completedTodos?.length || 0 }}</h3>
        </div>
        <div class="w-16 h-16 bg-green-500/20 rounded-2xl flex items-center justify-center">
          <Icon name="i-lucide-check-circle" class="w-8 h-8 text-green-500" />
        </div>
      </div>
    </UIBox>
  </div>

  <!-- Filter Tabs -->
  <div class="mb-6">
    <UITabs
      :tabs="['All Tasks', 'Pending', 'Completed']"
      v-model="currentFilterIndex"
      variant="pills"
      @change="handleFilterChange"
    />
  </div>

  <!-- Loading State -->
  <div v-if="loading" class="flex items-center justify-center py-12">
    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
  </div>

  <!-- Error State -->
  <UIAlert v-else-if="error" variant="danger" :title="'Error Loading Tasks'" dismissible @dismiss="error = null">
    {{ error }}
  </UIAlert>

  <!-- Empty State -->
  <UIBox v-else-if="!filteredTodos || filteredTodos.length === 0" padding="p-12">
    <div class="flex flex-col items-center justify-center text-center">
      <div class="w-24 h-24 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mb-4">
        <Icon name="i-lucide-inbox" class="w-12 h-12 text-gray-400" />
      </div>
      <UIH2 class="mb-2">No tasks found</UIH2>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        {{ currentFilter === 'all' ? 'Get started by creating your first task' : `No ${currentFilter} tasks` }}
      </p>
      <UIButtonEnhanced variant="primary" @click="openCreateModal">
        <template #icon>
          <Icon name="i-lucide-plus" class="w-5 h-5" />
        </template>
        Create Task
      </UIButtonEnhanced>
    </div>
  </UIBox>

  <!-- Todo List -->
  <UIBox padding="p-6" v-else>
    <div class="flex items-center justify-between mb-6">
      <UIH2>{{ filterTitle }} ({{ filteredTodos.length }})</UIH2>
      <div class="flex gap-2 items-center">
        <UIBadge :variant="currentFilter === 'all' ? 'primary' : 'gray'" size="md">
          {{ filteredTodos.length }} {{ filteredTodos.length === 1 ? 'task' : 'tasks' }}
        </UIBadge>
      </div>
    </div>

    <div class="flex flex-col gap-y-4">
      <TodoItem
        v-for="(todo, index) in filteredTodos"
        :key="todo?.id || index"
        :todo="todo"
        @toggle="toggleTodoStatus"
        @edit="editTodo"
        @delete="confirmDeleteTodo"
      />
    </div>
  </UIBox>

  <!-- Delete Confirmation Modal -->
  <UIModal
    v-model="showDeleteModal"
    title="Delete Task"
    size="sm"
  >
    <UIAlert variant="warning" title="Warning" :hide-icon="false">
      Are you sure you want to delete this task? This action cannot be undone.
    </UIAlert>

    <div class="mt-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Task:</p>
      <p class="font-medium text-black dark:text-white">{{ todoToDelete?.title }}</p>
    </div>

    <template #footer>
      <UIButtonEnhanced variant="ghost" @click="showDeleteModal = false">
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced variant="danger" @click="handleDeleteTodo">
        <template #icon>
          <Icon name="i-lucide-trash-2" class="w-5 h-5" />
        </template>
        Delete Task
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
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UIBadge from '~/components/UI/Badge.vue'
import UIAlert from '~/components/UI/Alert.vue'
import UIModal from '~/components/UI/Modal.vue'
import UITabs from '~/components/UI/Tabs.vue'

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
const currentFilterIndex = ref(0)

// Modal state
const editingTodo = ref<Todo | null>(null)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const todoToDelete = ref<Todo | null>(null)

// Computed
const pendingTodos = computed(() => todos.value.filter(todo => !todo.completed))
const completedTodos = computed(() => todos.value.filter(todo => todo.completed))

const filteredTodos = computed(() => {
  switch (currentFilter.value) {
    case 'pending':
      return pendingTodos.value
    case 'completed':
      return completedTodos.value
    default:
      return todos.value
  }
})

const filterTitle = computed(() => {
  switch (currentFilter.value) {
    case 'pending':
      return 'Pending Tasks'
    case 'completed':
      return 'Completed Tasks'
    default:
      return 'All Tasks'
  }
})

// Methods
const handleFilterChange = (index: number) => {
  const filters = ['all', 'pending', 'completed']
  currentFilter.value = filters[index]
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
      error.value = 'Failed to update task'
      return
    }

    todos.value[todoIndex].completed = newCompleted
  } catch (err) {
    console.error('Error toggling todo:', err)
    error.value = 'Failed to update task'
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
      error.value = 'Failed to delete task'
      return
    }

    await fetchTodos()
  } catch (err) {
    console.error('Error deleting todo:', err)
    error.value = 'Failed to delete task'
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
      error.value = 'Failed to fetch tasks: ' + supabaseError.message
      return
    }

    todos.value = data || []
  } catch (err) {
    console.error('Error:', err)
    error.value = 'Failed to fetch tasks'
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
