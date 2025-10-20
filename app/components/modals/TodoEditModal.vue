<template>
  <UIModal
    v-model="isOpenInternal"
    title="Edit Task"
    size="md"
    :closeable="!loading"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Title -->
      <UIInput
        v-model="formData.title"
        label="Title"
        placeholder="Task title"
        required
        :disabled="loading"
        clearable
      >
        <template #prefix>
          <Icon name="i-lucide-text" class="w-5 h-5" />
        </template>
      </UIInput>

      <!-- Description -->
      <UITextarea
        v-model="formData.description"
        label="Description"
        placeholder="Task description (optional)"
        :rows="4"
        :max-length="500"
        :disabled="loading"
      />

      <!-- Priority & Status Row -->
      <div class="grid grid-cols-2 gap-4">
        <!-- Priority -->
        <UISelect
          v-model="formData.priority"
          label="Priority"
          :options="priorityOptions"
          :disabled="loading"
        />

        <!-- Category -->
        <UIInput
          v-model="formData.category"
          label="Category"
          placeholder="e.g., Work"
          :disabled="loading"
        >
          <template #prefix>
            <Icon name="i-lucide-tag" class="w-5 h-5" />
          </template>
        </UIInput>
      </div>

      <!-- Due Date -->
      <UIInput
        v-model="formData.due_date"
        label="Due Date"
        type="date"
        :disabled="loading"
      >
        <template #prefix>
          <Icon name="i-lucide-calendar" class="w-5 h-5" />
        </template>
      </UIInput>

      <!-- Completed Status -->
      <div class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800 rounded-xl">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-green-500/20 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-check-circle" class="w-6 h-6 text-green-600" />
          </div>
          <div>
            <p class="font-medium text-gray-900 dark:text-white outfit">Task Status</p>
            <p class="text-sm text-gray-600 dark:text-gray-400">Mark as completed when done</p>
          </div>
        </div>
        <UISwitch
          v-model="formData.completed"
          :disabled="loading"
          size="lg"
        />
      </div>

      <!-- Error Alert -->
      <UIAlert v-if="error" variant="danger" dismissible @dismiss="error = null">
        Failed to update task. Please try again.
      </UIAlert>
    </form>

    <template #footer>
      <UIButtonEnhanced
        variant="ghost"
        @click="handleClose"
        :disabled="loading"
      >
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        @click="handleSubmit"
        :disabled="!formData.title.trim() || loading"
        :loading="loading"
      >
        <template #icon>
          <Icon v-if="!loading" name="i-lucide-save" class="w-5 h-5" />
        </template>
        Save Changes
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import type { Todo } from '~/composables/useTodos'
import UIModal from '~/components/UI/Modal.vue'
import UIInput from '~/components/UI/Input.vue'
import UITextarea from '~/components/UI/Textarea.vue'
import UISelect from '~/components/UI/Select.vue'
import UISwitch from '~/components/UI/Switch.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UIAlert from '~/components/UI/Alert.vue'

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
const error = ref(false)
const isOpenInternal = computed({
  get: () => props.isOpen,
  set: (value) => {
    if (!value) {
      handleClose()
    }
  }
})

// Priority options
const priorityOptions = [
  { label: '🔴 Urgent', value: 'urgent' },
  { label: '🟠 High', value: 'high' },
  { label: '🟡 Medium', value: 'medium' },
  { label: '🟢 Low', value: 'low' }
]

const formData = ref({
  title: '',
  description: '',
  priority: 'medium',
  category: '',
  due_date: '',
  completed: false
})

// Watch for todo changes to populate form
watch(() => props.todo, (newTodo) => {
  if (newTodo) {
    // Format date if exists
    let formattedDate = ''
    if (newTodo.due_date) {
      try {
        const date = new Date(newTodo.due_date)
        formattedDate = date.toISOString().split('T')[0]
      } catch (e) {
        console.error('Error formatting date:', e)
      }
    }

    formData.value = {
      title: newTodo.title || '',
      description: newTodo.description || '',
      priority: newTodo.priority || 'medium',
      category: newTodo.category || '',
      due_date: formattedDate,
      completed: newTodo.completed || false
    }
    error.value = false
  }
}, { immediate: true })

// Methods
const handleClose = () => {
  if (!loading.value) {
    emit('close')
  }
}

const handleSubmit = async () => {
  if (!props.todo || !formData.value.title.trim()) return

  try {
    loading.value = true
    error.value = false

    const client = useSupabaseClient()

    // Prepare update data
    const updateData = {
      title: formData.value.title.trim(),
      description: formData.value.description || null,
      priority: formData.value.priority,
      category: formData.value.category || null,
      due_date: formData.value.due_date || null,
      completed: formData.value.completed
    }

    const { error: updateError } = await client
      .from('todos')
      .update(updateData)
      .eq('id', props.todo.id)

    if (updateError) {
      console.error('Error updating todo:', updateError)
      error.value = true
      return
    }

    // Emit success
    emit('updated', {
      ...props.todo,
      ...updateData
    })

    handleClose()
  } catch (err) {
    console.error('Error updating todo:', err)
    error.value = true
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
