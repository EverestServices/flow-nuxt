<template>
  <!-- Backdrop -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black/20 z-40"
    @click="closeModal"
  ></div>

  <!-- Todo edit modal -->
  <Transition name="slide-todo-modal">
    <div
      v-if="isOpen && todo"
      class="fixed bottom-2 right-2 top-2 w-96 bg-white/95 backdrop-blur-xl border border-gray-200 rounded-2xl flex flex-col shadow-2xl z-50"
    >
      <!-- Header -->
      <div class="p-6 pb-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-gray-900 font-semibold text-lg">Edit Todo</h3>
          <button
            @click="closeModal"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6">
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Title</label>
            <input
              v-model="formData.title"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Todo title"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              v-model="formData.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Todo description (optional)"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Priority</label>
            <select
              v-model="formData.priority"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Due Date</label>
            <input
              v-model="formData.due_date"
              type="date"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="flex items-center">
            <input
              v-model="formData.completed"
              type="checkbox"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label class="ml-2 block text-sm text-gray-700">
              Mark as completed
            </label>
          </div>
        </form>
      </div>

      <!-- Footer -->
      <div class="p-6 pt-4 border-t border-gray-200">
        <div class="flex justify-end gap-3">
          <button
            @click="closeModal"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Cancel
          </button>
          <button
            @click="handleSubmit"
            :disabled="!formData.title.trim() || loading"
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading">Saving...</span>
            <span v-else>Save Changes</span>
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { Todo } from '~/composables/useTodos'

// Props
interface Props {
  todo?: Todo | null
  isOpen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  todo: null,
  isOpen: false
})

// Emits
const emit = defineEmits<{
  close: []
  updated: [todo: Todo]
}>()

// State
const loading = ref(false)
const formData = ref({
  title: '',
  description: '',
  priority: 'medium',
  due_date: '',
  completed: false
})

// Watch for todo changes to populate form
watch(() => props.todo, (newTodo) => {
  if (newTodo) {
    formData.value = {
      title: newTodo.title || '',
      description: newTodo.description || '',
      priority: newTodo.priority || 'medium',
      due_date: newTodo.due_date || '',
      completed: newTodo.completed || false
    }
  }
}, { immediate: true })

// Methods
const closeModal = () => {
  emit('close')
}

const handleSubmit = async () => {
  if (!props.todo || !formData.value.title.trim()) return

  try {
    loading.value = true

    const client = useSupabaseClient()
    const { error } = await client
      .from('todos')
      .update({
        title: formData.value.title,
        description: formData.value.description,
        priority: formData.value.priority,
        due_date: formData.value.due_date || null,
        completed: formData.value.completed
      })
      .eq('id', props.todo.id)

    if (error) {
      console.error('Error updating todo:', error)
      return
    }

    // Emit success
    emit('updated', {
      ...props.todo,
      ...formData.value
    })

    closeModal()
  } catch (err) {
    console.error('Error updating todo:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Right-sliding modal animation */
.slide-todo-modal-enter-active,
.slide-todo-modal-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-todo-modal-enter-from,
.slide-todo-modal-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>