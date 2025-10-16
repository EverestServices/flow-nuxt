<template>
  <div class="online-users-list">
    <!-- Header -->
    <div class="online-users-header">
      <div class="flex items-center gap-2">
        <div class="online-indicator"></div>
        <h3 class="title">Online Now</h3>
        <div class="online-count">{{ onlineCount }}</div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="flex items-center gap-3 p-3">
        <USkeleton class="h-10 w-10 rounded-full" />
        <div class="flex-1">
          <USkeleton class="h-4 w-24 mb-1" />
          <USkeleton class="h-3 w-16" />
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-message">{{ error }}</div>
      <button @click="fetchOnlineUsers" class="retry-button">
        Try Again
      </button>
    </div>

    <!-- Empty State -->
    <div v-else-if="onlineUsers.length === 0" class="empty-state">
      <div class="empty-icon">👥</div>
      <div class="empty-message">No one else is online</div>
    </div>

    <!-- Online Users -->
    <div v-else class="users-list">
      <div
        v-for="user in onlineUsers"
        :key="user.user_id"
        class="user-item"
      >
        <!-- User Avatar -->
        <div class="user-avatar">
          <div class="avatar-placeholder">
            {{ getInitials(user.first_name, user.last_name) }}
          </div>
          <OnlineStatusBadge
            :is-online="true"
            :last-seen="user.last_activity"
            size="sm"
            variant="dot"
            class="avatar-badge"
          />
        </div>

        <!-- User Info -->
        <div class="user-info">
          <div class="user-name">
            {{ user.first_name || user.last_name ? `${user.first_name || ''} ${user.last_name || ''}`.trim() : 'Unknown User' }}
          </div>
          <div class="user-status">
            <OnlineStatusBadge
              :is-online="true"
              :last-seen="user.last_activity"
              show-text
              size="sm"
              variant="subtle"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Refresh Button -->
    <div class="refresh-section">
      <button
        @click="refreshUsers"
        :disabled="loading"
        class="refresh-button"
      >
        <Icon name="i-lucide-refresh-cw" class="w-4 h-4" :class="{ 'animate-spin': loading }" />
        Refresh
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const {
  onlineUsers,
  onlineCount,
  loading,
  error,
  fetchOnlineUsers,
  subscribeToOnlineUsers
} = useOnlineStatus()

// Get user initials for avatar placeholder
const getInitials = (firstName?: string, lastName?: string): string => {
  if (!firstName && !lastName) return '?'
  const first = firstName?.[0] || ''
  const last = lastName?.[0] || ''
  return (first + last).toUpperCase()
}

// Refresh users list
const refreshUsers = async () => {
  await fetchOnlineUsers()
}

// Set up real-time subscription
let unsubscribe: (() => void) | undefined

onMounted(async () => {
  // Initial fetch
  await fetchOnlineUsers()

  // Set up subscription
  unsubscribe = subscribeToOnlineUsers()
})

onUnmounted(() => {
  if (unsubscribe) {
    unsubscribe()
  }
})
</script>

<style scoped>
.online-users-list {
  background: white;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.online-users-header {
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
  padding: 12px 16px;
}

.online-indicator {
  width: 8px;
  height: 8px;
  background-color: #10b981;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.online-count {
  background: #10b981;
  color: white;
  font-size: 11px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

.loading-state,
.error-state,
.empty-state {
  padding: 16px;
}

.error-state {
  text-align: center;
}

.error-message {
  color: #dc2626;
  font-size: 14px;
  margin-bottom: 12px;
}

.retry-button {
  background: #dc2626;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 12px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.retry-button:hover {
  background: #b91c1c;
}

.empty-state {
  text-align: center;
  color: #6b7280;
}

.empty-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.empty-message {
  font-size: 14px;
}

.users-list {
  max-height: 300px;
  overflow-y: auto;
}

.user-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-bottom: 1px solid #f3f4f6;
  transition: background-color 0.2s;
}

.user-item:last-child {
  border-bottom: none;
}

.user-item:hover {
  background: #f9fafb;
}

.user-avatar {
  position: relative;
  flex-shrink: 0;
}

.avatar-image,
.avatar-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}

.avatar-image {
  object-fit: cover;
}

.avatar-placeholder {
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
}

.avatar-badge {
  position: absolute;
  bottom: -2px;
  right: -2px;
  background: white;
  border-radius: 50%;
  padding: 2px;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #1f2937;
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-status {
  font-size: 12px;
  color: #6b7280;
}

.refresh-section {
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
  padding: 12px 16px;
  text-align: center;
}

.refresh-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: white;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: 6px 12px;
  font-size: 12px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-button:hover:not(:disabled) {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.refresh-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Animations */
@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.2);
    opacity: 0.7;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

/* Scrollbar styling */
.users-list::-webkit-scrollbar {
  width: 4px;
}

.users-list::-webkit-scrollbar-track {
  background: transparent;
}

.users-list::-webkit-scrollbar-thumb {
  background-color: #d1d5db;
  border-radius: 2px;
}

.users-list::-webkit-scrollbar-thumb:hover {
  background-color: #9ca3af;
}
</style>