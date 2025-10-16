<template>
  <div>
    <button @click="isOpen = true">
      Add Todo
    </button>

    <div v-if="isOpen" class="modal">
      <div class="modal-content">
        <h3>{{ editingTodo ? 'Edit Todo' : 'Create New Todo' }}</h3>

        <form @submit.prevent="handleSubmit">
          <div>
            <label>Title*</label>
            <input
              v-model="formState.title"
              placeholder="Enter todo title"
              required
            />
          </div>

          <div>
            <label>Description</label>
            <textarea
              v-model="formState.description"
              placeholder="Enter todo description (optional)"
            ></textarea>
          </div>

          <div>
            <label>Priority</label>
            <select v-model="formState.priority">
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>

          <div>
            <label>Category</label>
            <input
              v-model="formState.category"
              placeholder="e.g., Work, Personal, Project"
            />
          </div>

          <div>
            <label>Due Date</label>
            <input
              v-model="formState.due_date"
              type="datetime-local"
            />
          </div>

          <div>
            <button type="button" @click="closeModal">Cancel</button>
            <button type="submit" :disabled="!formState.title?.trim()">
              {{ editingTodo ? 'Update' : 'Create' }} Todo
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { CreateTodo, Todo } from '~/composables/useTodos'

// Props
interface Props {
  editingTodo?: Todo | null
}

const props = withDefaults(defineProps<Props>(), {
  editingTodo: null
})

// Emits
const emit = defineEmits<{
  created: [todo: Todo]
  updated: [todo: Todo]
}>()

// Composables
const { createTodo, updateTodo } = useTodos()

// State
const isOpen = ref(false)
const submitting = ref(false)

// Form state
const defaultFormState: CreateTodo = {
  title: '',
  description: null,
  priority: 'medium',
  category: null,
  due_date: null,
  tags: [],
  entity_type: null,
  source_entity_id: null,
  assigned_to: null,
  order_index: 0
}

const formState = ref<CreateTodo>({ ...defaultFormState })

// Methods
const resetForm = () => {
  formState.value = { ...defaultFormState }
}

const closeModal = () => {
  isOpen.value = false
  resetForm()
}

const handleSubmit = async () => {
  try {
    submitting.value = true

    if (props.editingTodo) {
      // Update existing todo
      const updated = await updateTodo({
        id: props.editingTodo.id,
        ...formState.value
      })

      if (updated) {
        emit('updated', updated)
        closeModal()
      }
    } else {
      // Create new todo
      const created = await createTodo(formState.value)

      if (created) {
        emit('created', created)
        closeModal()
      }
    }
  } catch (error) {
    console.error('Error submitting todo:', error)
  } finally {
    submitting.value = false
  }
}

// Watch for editing todo changes
watch(
  () => props.editingTodo,
  (todo) => {
    if (todo) {
      // Populate form with existing todo data
      formState.value = {
        title: todo.title,
        description: todo.description,
        priority: todo.priority,
        category: todo.category,
        due_date: todo.due_date,
        tags: [...(todo.tags || [])],
        entity_type: todo.entity_type,
        source_entity_id: todo.source_entity_id,
        assigned_to: todo.assigned_to,
        order_index: todo.order_index
      }
      isOpen.value = true
    }
  },
  { immediate: true }
)
</script>