<template>
  <UIBox v-if="todo" shadow="none" class="hover:shadow-md transition-shadow">
    <div class="flex items-start gap-4 w-full px-6 py-4">
      <!-- Checkbox -->
      <input
        type="checkbox"
        :checked="todo?.completed || false"
        @change="$emit('toggle', todo?.id)"
        class="mt-1 flex-shrink-0"
      />

      <!-- Content Section -->
      <div class="grow space-y-2">
        <!-- Row 1: Priority Badge -->
        <div>
          <UIBadge :variant="getPriorityVariant(todo.priority)" size="sm">
            {{ formatPriority(todo.priority) }}
          </UIBadge>
        </div>

        <!-- Row 2: Title -->
        <h3
          class="text-base font-semibold text-gray-900 dark:text-white outfit"
          :class="{ 'line-through opacity-60': todo?.completed }"
        >
          {{ todo?.title || 'No title' }}
        </h3>

        <!-- Row 3: Description -->
        <p
          v-if="todo?.description"
          class="text-sm text-gray-600 dark:text-gray-400 outfit"
          :class="{ 'line-through opacity-60': todo?.completed }"
        >
          {{ todo.description }}
        </p>

        <!-- Row 4: Due Date -->
        <div v-if="todo?.due_date" class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
          <Icon name="i-lucide-calendar" class="w-4 h-4" />
          <span>{{ formatDueDate(todo.due_date) }}</span>
        </div>
      </div>

      <!-- Right Side: Avatar & Actions -->
      <div class="flex items-center gap-3 flex-shrink-0">
        <!-- Assigned colleague avatar -->
        <div v-if="assignedColleague" class="relative group">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-sm font-bold text-white shadow-md overflow-hidden transition-transform group-hover:scale-105">
            <img
              v-if="assignedColleague.avatar_url"
              :src="assignedColleague.avatar_url"
              :alt="getColleagueName(assignedColleague)"
              class="w-full h-full object-cover"
              @error="handleImageError"
            />
            <span v-else class="select-none">{{ getColleagueInitials(assignedColleague) }}</span>
          </div>
          <!-- Online status indicator -->
          <div
            v-if="isColleagueOnline(assignedColleague)"
            class="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-green-500 rounded-full border-2 border-white shadow-sm animate-pulse"
            :title="`${getColleagueName(assignedColleague)} is online`"
          ></div>
          <div
            v-else
            class="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-gray-400 rounded-full border-2 border-white shadow-sm"
            :title="`${getColleagueName(assignedColleague)} was last seen ${formatLastActivity(assignedColleague.last_activity)}`"
          ></div>
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-2">
          <UIButton @click="$emit('edit', todo)">
            <Icon name="uil:edit" />
          </UIButton>
          <UIButtonEnhanced
            @click="$emit('delete', todo)"
            variant="ghost"
            size="xs"
          >
            <template #icon>
              <Icon name="i-lucide-trash-2" class="w-4 h-4" />
            </template>
          </UIButtonEnhanced>
        </div>
      </div>
    </div>
  </UIBox>
</template>

<script setup lang="ts">
import type { Todo } from '~/composables/useTodos'
import type { Colleague } from '~/composables/useColleagues'
import UIBadge from '~/components/UI/Badge.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'

interface Props {
  todo?: Todo | null
}

const props = defineProps<Props>()

defineEmits<{
  toggle: [id: number]
  edit: [todo: Todo]
  delete: [todo: Todo]
}>()

// Composables
const {
  colleagues,
  loading: loadingColleagues,
  fetchColleagues,
  getColleagueName,
  getColleagueInitials,
  isColleagueOnline
} = useColleagues()

// Computed property to get assigned colleague
const assignedColleague = computed((): Colleague | null => {
  if (!props.todo?.assigned_to) return null
  return colleagues.value.find(colleague => colleague.user_id === props.todo!.assigned_to) || null
})

// Methods
const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement
  target.style.display = 'none'
}

const formatLastActivity = (lastActivity?: string): string => {
  if (!lastActivity) return 'unknown'

  const now = new Date()
  const lastActivityDate = new Date(lastActivity)
  const diffMinutes = Math.floor((now.getTime() - lastActivityDate.getTime()) / (1000 * 60))

  if (diffMinutes < 1) return 'just now'
  if (diffMinutes < 60) return `${diffMinutes}m ago`

  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours < 24) return `${diffHours}h ago`

  const diffDays = Math.floor(diffHours / 24)
  if (diffDays < 7) return `${diffDays}d ago`

  return lastActivityDate.toLocaleDateString()
}

// Priority badge variant mapping
const getPriorityVariant = (priority?: string): 'danger' | 'warning' | 'info' | 'gray' => {
  switch (priority) {
    case 'urgent':
      return 'danger'
    case 'high':
      return 'warning'
    case 'medium':
      return 'info'
    case 'low':
    default:
      return 'gray'
  }
}

// Format priority text
const formatPriority = (priority?: string): string => {
  if (!priority) return 'No Priority'
  return priority.charAt(0).toUpperCase() + priority.slice(1)
}

// Format due date
const formatDueDate = (dueDate?: string): string => {
  if (!dueDate) return 'No due date'

  const date = new Date(dueDate)
  const now = new Date()

  // Format: "Jan 15, 2025 at 2:30 PM"
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  }

  return date.toLocaleString('en-US', options)
}

// Initialize colleagues data when component mounts
onMounted(() => {
  if (colleagues.value.length === 0 && !loadingColleagues.value) {
    fetchColleagues()
  }
})
</script>