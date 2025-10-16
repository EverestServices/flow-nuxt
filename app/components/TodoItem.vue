<template>
  <UIBox v-if="todo" shadow="none" class="hover:shadow-md transition-shadow">
    <div class="flex items-center gap-3 w-full px-6 py-2">
      <input
          type="checkbox"
          :checked="todo?.completed || false"
          @change="$emit('toggle', todo?.id)"
      />
      <div class="grow">
        <UIH3 :class="{ 'line-through opacity-60': todo?.completed }">
          {{ todo?.title || 'No title' }}
        </UIH3>
        <p v-if="todo?.description" class="outfit text-sm font-normal" :class="{ 'line-through opacity-60': todo?.completed }">
          {{ todo.description }}
        </p>
      </div>

      <!-- Assigned colleague avatar -->
      <div v-if="assignedColleague" class="flex items-center gap-3">
        <div class="relative group">
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
        <div class="flex flex-col">
          <span class="text-sm text-gray-800 font-semibold leading-tight">
            {{ getColleagueName(assignedColleague) }}
          </span>
          <span class="text-xs text-gray-500 leading-tight">
            {{ isColleagueOnline(assignedColleague) ? 'Online now' : `Last seen ${formatLastActivity(assignedColleague.last_activity)}` }}
          </span>
        </div>
      </div>

      <div class="flex gap-2">
        <UIButton @click="$emit('edit', todo)" >
          <Icon name="uil:edit" />
        </UIButton>
        <button @click="$emit('delete', todo)" class="text-xs text-red-600 hover:text-red-800">Delete</button>
      </div>
    </div>
  </UIBox>

</template>

<script setup lang="ts">
import type { Todo } from '~/composables/useTodos'
import type { Colleague } from '~/composables/useColleagues'

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

// Initialize colleagues data when component mounts
onMounted(() => {
  if (colleagues.value.length === 0 && !loadingColleagues.value) {
    fetchColleagues()
  }
})
</script>