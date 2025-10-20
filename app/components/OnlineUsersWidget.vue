<template>
  <UIBox class="p-6">
    <div class="flex justify-between items-center mb-4">
      <UIH2 class="flex items-center gap-2">
        <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
        Online Users
      </UIH2>
      <div class="bg-green-500 text-white text-xs px-2 py-1 rounded-full font-semibold">
        {{ onlineCount }}
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="space-y-3">
      <div v-for="i in 3" :key="i" class="flex items-center gap-3">
        <div class="h-8 w-8 rounded-full bg-gray-200 dark:bg-gray-700 animate-pulse" />
        <div class="flex-1">
          <div class="h-3 w-20 mb-1 bg-gray-200 dark:bg-gray-700 rounded animate-pulse" />
          <div class="h-2 w-12 bg-gray-200 dark:bg-gray-700 rounded animate-pulse" />
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-center py-4">
      <div class="text-red-600 text-sm mb-2">{{ error }}</div>
      <button
        @click="fetchOnlineUsers"
        class="text-xs bg-red-100 text-red-700 px-3 py-1 rounded hover:bg-red-200 transition-colors"
      >
        Retry
      </button>
    </div>

    <!-- Empty State -->
    <div v-else-if="onlineUsers.length === 0" class="text-center py-6 text-gray-500">
      <div class="text-2xl mb-2">👥</div>
      <div class="text-sm">No one else is online</div>
    </div>

    <!-- Online Users List -->
    <div v-else class="space-y-3">
      <div
        v-for="user in displayUsers"
        :key="user.user_id"
        class="flex items-center gap-3"
      >
        <!-- Avatar with online badge -->
        <div class="relative">
          <div class="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-xs font-semibold text-gray-600">
            {{ getInitials(user.first_name, user.last_name) }}
          </div>
          <div class="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
        </div>

        <!-- User info -->
        <div class="flex-1 min-w-0">
          <div class="text-sm font-medium text-gray-900 truncate">
            {{ userName(user) }}
          </div>
          <div class="text-xs text-green-600 font-medium">
            {{ formatLastSeen(user.last_activity) }}
          </div>
        </div>
      </div>

      <!-- Show more indicator -->
      <div v-if="onlineUsers.length > maxDisplay" class="text-center pt-2">
        <div class="text-xs text-gray-500">
          +{{ onlineUsers.length - maxDisplay }} more online
        </div>
      </div>
    </div>

    <!-- Current user indicator -->
    <div class="mt-4 pt-3 border-t border-gray-100">
      <div class="flex items-center gap-3">
        <div class="relative">
          <img
            :src="userAvatar"
            alt="You"
            class="w-8 h-8 rounded-full object-cover"
          />
          <div
            class="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-white"
            :class="currentUserOnline ? 'bg-green-500' : 'bg-gray-400'"
          ></div>
        </div>
        <div class="flex-1">
          <div class="text-sm font-medium text-gray-900">You</div>
          <div class="text-xs font-medium" :class="currentUserOnline ? 'text-green-600' : 'text-gray-500'">
            {{ currentUserOnline ? 'Online now' : 'Offline' }}
          </div>
        </div>
      </div>
    </div>
  </UIBox>
</template>

<script setup lang="ts">
interface Props {
  maxDisplay?: number
}

const props = withDefaults(defineProps<Props>(), {
  maxDisplay: 5
})

// Composables
const {
  onlineUsers,
  onlineCount,
  currentUserOnline,
  loading,
  error,
  fetchOnlineUsers,
  formatLastSeen
} = useOnlineStatus()

const user = useSupabaseUser()

// Computed
const userAvatar = computed(() => user.value?.user_metadata?.avatar_url || 'https://github.com/benjamincanac.png')

const displayUsers = computed(() => {
  return onlineUsers.value.slice(0, props.maxDisplay)
})

// Methods
const userName = (user: any) => {
  if (user.first_name || user.last_name) {
    return `${user.first_name || ''} ${user.last_name || ''}`.trim()
  }
  return 'Unknown User'
}

const getInitials = (firstName?: string, lastName?: string): string => {
  if (!firstName && !lastName) return '?'
  const first = firstName?.[0] || ''
  const last = lastName?.[0] || ''
  return (first + last).toUpperCase()
}

// Initialize
onMounted(() => {
  fetchOnlineUsers()
})
</script>

<style scoped>
/* Custom scrollbar for better UX if list gets long */
.space-y-3::-webkit-scrollbar {
  width: 4px;
}

.space-y-3::-webkit-scrollbar-track {
  background: transparent;
}

.space-y-3::-webkit-scrollbar-thumb {
  background-color: #d1d5db;
  border-radius: 2px;
}
</style>