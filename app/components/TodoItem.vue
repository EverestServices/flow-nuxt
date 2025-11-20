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
        <UIH3
          :class="{ 'line-through opacity-60': todo?.completed }"
        >
          {{ todo?.title || $t('todo.item.noTitle') }}
        </UIH3>

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
        <div
          v-if="assignedColleague"
          class="group"
          :title="isColleagueOnline(assignedColleague)
            ? `${getColleagueName(assignedColleague)} ${$t('todo.item.isOnline')}`
            : `${getColleagueName(assignedColleague)} ${$t('todo.item.lastSeen', { time: formatLastActivity(assignedColleague.last_activity) })}`"
        >
          <UIAvatar
            :src="assignedColleague.avatar_url"
            :name="getColleagueName(assignedColleague)"
            size="md"
            :status="isColleagueOnline(assignedColleague) ? 'online' : 'offline'"
            class="transition-transform group-hover:scale-105 shadow-md"
          />
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
import UIH3 from '~/components/UI/H3.vue'
import UIAvatar from '~/components/UI/Avatar.vue'

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
const { t } = useI18n()
const {
  colleagues,
  loading: loadingColleagues,
  fetchColleagues,
  getColleagueName,
  isColleagueOnline
} = useColleagues()

// Computed property to get assigned colleague
const assignedColleague = computed((): Colleague | null => {
  if (!props.todo?.assigned_to) return null
  return colleagues.value.find(colleague => colleague.user_id === props.todo!.assigned_to) || null
})

const formatLastActivity = (lastActivity?: string): string => {
  if (!lastActivity) return 'unknown'

  const now = new Date()
  const lastActivityDate = new Date(lastActivity)
  const diffMinutes = Math.floor((now.getTime() - lastActivityDate.getTime()) / (1000 * 60))

  if (diffMinutes < 1) return t('todo.time.justNow')
  if (diffMinutes < 60) return t('todo.time.minutesAgo', { n: diffMinutes })

  const diffHours = Math.floor(diffMinutes / 60)
  if (diffHours < 24) return t('todo.time.hoursAgo', { n: diffHours })

  const diffDays = Math.floor(diffHours / 24)
  if (diffDays < 7) return t('todo.time.daysAgo', { n: diffDays })

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
  if (!priority) return t('todo.priority.noPriority')

  switch (priority) {
    case 'urgent':
      return t('todo.priority.urgent')
    case 'high':
      return t('todo.priority.high')
    case 'medium':
      return t('todo.priority.medium')
    case 'low':
      return t('todo.priority.low')
    default:
      return priority.charAt(0).toUpperCase() + priority.slice(1)
  }
}

// Format due date
const formatDueDate = (dueDate?: string): string => {
  if (!dueDate) return t('todo.item.noDueDate')

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