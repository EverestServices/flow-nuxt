<template>
  <div>
    <UIBox @click="isOpen = true" class="px-4 py-2 cursor-pointer text-sm text-white" background="bg-green-500">
      Create Task
    </UIBox>

    <UIModal
      v-model="isOpen"
      size="md"
      :closeable="!submitting"
    >
      <template #header>
        <div class="flex items-center gap-3">
          <Icon name="i-lucide-file-text" class="w-6 h-6 text-gray-700 dark:text-gray-300" />
          <h3 class="outfit font-bold text-xl text-gray-900 dark:text-white">
            {{ editingTodo ? $t('todo.createModal.titleEdit') : $t('todo.createModal.titleNew') }}
          </h3>
        </div>
      </template>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Title -->
        <UIInput
          v-model="formState.title"
          :label="$t('todo.createModal.fields.title')"
          :placeholder="$t('todo.createModal.fields.titlePlaceholder')"
          required
          :disabled="submitting"
          :error="errors.title"
        >
          <template #prefix>
            <Icon name="i-lucide-text" class="w-5 h-5" />
          </template>
        </UIInput>

        <!-- Description -->
        <UITextarea
          v-model="formState.description"
          :label="$t('todo.createModal.fields.description')"
          :placeholder="$t('todo.createModal.fields.descriptionPlaceholder')"
          :rows="4"
          :max-length="500"
          :disabled="submitting"
        />

        <!-- Priority & Category Row -->
        <div class="grid grid-cols-2 gap-4">
          <!-- Priority -->
          <UISelect
            v-model="formState.priority"
            :label="$t('todo.createModal.fields.priority')"
            :options="priorityOptions"
            :disabled="submitting"
          />

          <!-- Category -->
          <UIInput
            v-model="formState.category"
            :label="$t('todo.createModal.fields.category')"
            :placeholder="$t('todo.createModal.fields.categoryPlaceholder')"
            :disabled="submitting"
          >
            <template #prefix>
              <Icon name="i-lucide-tag" class="w-5 h-5" />
            </template>
          </UIInput>
        </div>

        <!-- Due Date -->
        <UIInput
          v-model="formState.due_date"
          :label="$t('todo.createModal.fields.dueDate')"
          type="datetime-local"
          :disabled="submitting"
        >
          <template #prefix>
            <Icon name="i-lucide-calendar" class="w-5 h-5" />
          </template>
        </UIInput>

        <!-- Assigned To (if available) -->
        <div v-if="colleagues.length > 0">
          <UISelect
            v-model="formState.assigned_to"
            :label="$t('todo.createModal.fields.assignTo')"
            :options="colleagueOptions"
            :placeholder="$t('todo.createModal.fields.assignToPlaceholder')"
            :disabled="submitting"
          />
        </div>

        <!-- Tags Input (optional enhancement) -->
        <div>
          <label class="outfit font-medium text-sm text-gray-700 dark:text-gray-300 mb-1.5 block">
            {{ $t('todo.createModal.fields.tags') }}
            <span class="text-gray-500 dark:text-gray-400 font-normal">{{ $t('todo.createModal.fields.tagsOptional') }}</span>
          </label>
          <div class="flex flex-wrap gap-2 mb-2">
            <UIBadge
              v-for="(tag, index) in formState.tags"
              :key="index"
              variant="primary"
              size="md"
              class="cursor-pointer hover:opacity-80"
              @click="removeTag(index)"
            >
              {{ tag }}
              <Icon name="i-lucide-x" class="w-3 h-3 ml-1" />
            </UIBadge>
          </div>
          <div class="flex gap-2">
            <UIInput
              v-model="newTag"
              :placeholder="$t('todo.createModal.fields.addTag')"
              :disabled="submitting"
              @keypress.enter.prevent="addTag"
            />
            <UIButtonEnhanced
              variant="outline"
              size="md"
              type="button"
              @click="addTag"
              :disabled="!newTag.trim() || submitting"
            >
              {{ $t('todo.actions.add') }}
            </UIButtonEnhanced>
          </div>
        </div>

        <!-- Error Alert -->
        <UIAlert v-if="errors.submit" variant="danger" dismissible @dismiss="errors.submit = null">
          {{ errors.submit }}
        </UIAlert>
      </form>

      <template #footer>
        <UIButtonEnhanced
          variant="ghost"
          @click="closeModal"
          :disabled="submitting"
        >
          {{ $t('todo.actions.cancel') }}
        </UIButtonEnhanced>
        <UIButtonEnhanced
          variant="primary"
          @click="handleSubmit"
          :disabled="!formState.title?.trim() || submitting"
          :loading="submitting"
        >
          <template #icon>
            <Icon v-if="!submitting" name="i-lucide-check" class="w-5 h-5" />
          </template>
          {{ editingTodo ? $t('todo.actions.updateTask') : $t('todo.actions.createTask') }}
        </UIButtonEnhanced>
      </template>
    </UIModal>
  </div>
</template>

<script setup lang="ts">
import type { CreateTodo, Todo } from '~/composables/useTodos'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UIModal from '~/components/UI/Modal.vue'
import UIInput from '~/components/UI/Input.vue'
import UITextarea from '~/components/UI/Textarea.vue'
import UISelect from '~/components/UI/Select.vue'
import UIBadge from '~/components/UI/Badge.vue'
import UIAlert from '~/components/UI/Alert.vue'

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
const { t } = useI18n()
const { createTodo, updateTodo } = useTodos()
const { colleagues, fetchColleagues } = useColleagues()

// State
const isOpen = ref(false)
const submitting = ref(false)
const newTag = ref('')
const errors = ref({
  title: null,
  submit: null
})

// Priority options
const priorityOptions = computed(() => [
  { label: t('todo.priority.urgentEmoji'), value: 'urgent' },
  { label: t('todo.priority.highEmoji'), value: 'high' },
  { label: t('todo.priority.mediumEmoji'), value: 'medium' },
  { label: t('todo.priority.lowEmoji'), value: 'low' }
])

// Colleague options for assignment
const colleagueOptions = computed(() => {
  return colleagues.value.map(colleague => ({
    label: `${colleague.first_name} ${colleague.last_name}`.trim() || colleague.email,
    value: colleague.user_id
  }))
})

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
const addTag = () => {
  const tag = newTag.value.trim()
  if (tag && !formState.value.tags?.includes(tag)) {
    formState.value.tags = [...(formState.value.tags || []), tag]
    newTag.value = ''
  }
}

const removeTag = (index: number) => {
  formState.value.tags = formState.value.tags?.filter((_, i) => i !== index) || []
}

const resetForm = () => {
  formState.value = { ...defaultFormState }
  newTag.value = ''
  errors.value = { title: null, submit: null }
}

const closeModal = () => {
  if (!submitting.value) {
    isOpen.value = false
    resetForm()
  }
}

const handleSubmit = async () => {
  // Validate
  errors.value.title = null
  errors.value.submit = null

  if (!formState.value.title?.trim()) {
    errors.value.title = 'Title is required'
    return
  }

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
    errors.value.submit = 'Failed to save task. Please try again.'
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

// Fetch colleagues on mount
onMounted(() => {
  fetchColleagues()
})
</script>
