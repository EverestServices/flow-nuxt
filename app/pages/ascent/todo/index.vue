<template>
  <div class="">
    <heading>ToDo</heading>
    <p>Organize and track your daily tasks efficiently.</p>
    <Modals-Todo-Create @created="handleTodoCreated" @updated="handleTodoUpdated" />
  </div>

  <div>
    <p>Total: {{ todos?.length || 0 }}</p>
    <p>Pending: {{ pendingTodos?.length || 0 }}</p>
    <p>Completed: {{ completedTodos?.length || 0 }}</p>

    <!-- Filter buttons -->
    <div class="flex">
      <UIBox class="px-4 py-2"
        @click="setFilter('all')"
        :style="{ backgroundColor: currentFilter === 'all' ? '#007bff' : '#f8f9fa', color: currentFilter === 'all' ? 'white' : 'black' }"
      >
        All
      </UIBox>
      <UIBox class="px-4 py-2"
        @click="setFilter('pending')"
        :style="{ backgroundColor: currentFilter === 'pending' ? '#007bff' : '#f8f9fa', color: currentFilter === 'pending' ? 'white' : 'black', marginLeft: '10px' }"
      >
        Pending
      </UIBox>
      <UIBox class="px-4 py-2"
        @click="setFilter('completed')"
        :style="{ backgroundColor: currentFilter === 'completed' ? '#007bff' : '#f8f9fa', color: currentFilter === 'completed' ? 'white' : 'black', marginLeft: '10px' }"
      >
        Completed
      </UIBox>
    </div>

    <div v-if="loading">Loading...</div>
    <div v-else-if="error">Error: {{ error }}</div>
    <div v-else-if="!filteredTodos || filteredTodos.length === 0">No todos found</div>

    <UIBox class="p-8" v-else>
      <!--<div>Debug: Found {{ todos.length }} total todos, showing {{ filteredTodos.length }} filtered</div>-->

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
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black/20 z-40" @click="showDeleteModal = false"></div>
    <div v-if="showDeleteModal" class="fixed inset-0 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl p-6 m-4 max-w-md w-full">
        <h3 class="text-lg font-medium text-gray-900 mb-2">Delete Todo</h3>
        <p class="text-gray-600 mb-1">Are you sure you want to delete this todo?</p>
        <p class="text-gray-900 font-medium mb-6">"{{ todoToDelete?.title }}"</p>
        <div class="flex justify-end gap-3">
          <button
            @click="showDeleteModal = false"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Cancel
          </button>
          <button
            @click="handleDeleteTodo"
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  </div>

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

// Try without the composable first to test Supabase connection
const client = useSupabaseClient()
const user = useSupabaseUser()

// Simple state
const todos = ref([])
const loading = ref(false)
const error = ref(null)
const currentFilter = ref('all')

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

// Remove toast for now

// State
const editingTodo = ref<Todo | null>(null)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const todoToDelete = ref<Todo | null>(null)

// Filter methods
const setFilter = (filter: string) => {
  currentFilter.value = filter
}

// Simple methods for testing
const toggleTodoStatus = async (id: number) => {
  try {
    // Find the todo in our local array
    const todoIndex = todos.value.findIndex(todo => todo.id === id)
    if (todoIndex === -1) return

    const todo = todos.value[todoIndex]
    const newCompleted = !todo.completed

    // Update in Supabase
    const { error: updateError } = await client
      .from('todos')
      .update({ completed: newCompleted })
      .eq('id', id)

    if (updateError) {
      console.error('Error updating todo:', updateError)
      return
    }

    // Update local state
    todos.value[todoIndex].completed = newCompleted
    console.log('Todo toggled successfully')
  } catch (err) {
    console.error('Error toggling todo:', err)
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
    // Delete from Supabase
    const { error } = await client
      .from('todos')
      .delete()
      .eq('id', todoToDelete.value.id)

    if (error) {
      console.error('Error deleting todo:', error)
      return
    }

    // Refresh the todo list
    await fetchTodos()
  } catch (err) {
    console.error('Error deleting todo:', err)
  } finally {
    // Close the modal
    showDeleteModal.value = false
    todoToDelete.value = null
  }
}

const handleTodoCreated = async () => {
  // Refresh the todo list
  await fetchTodos()
}

const handleTodoUpdated = async () => {
  // Refresh the todo list and close edit modal
  closeEditModal()
  await fetchTodos()
}

// Fetch todos function
const fetchTodos = async () => {
  try {
    loading.value = true
    console.log('Fetching todos...')
    console.log('User:', user.value)

    // Fetch all todos (RLS will filter by company automatically)
    const { data, error: supabaseError } = await client
      .from('todos')
      .select('*')
      .order('created_at', { ascending: false })

    if (supabaseError) {
      console.error('Supabase error:', supabaseError)
      error.value = 'Failed to fetch todos: ' + supabaseError.message
      return
    }

    console.log('Fetched todos:', data)
    todos.value = data || []
    error.value = null
  } catch (err) {
    console.error('Error:', err)
    error.value = 'Failed to fetch todos: ' + err
  } finally {
    loading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await fetchTodos()
})
</script>