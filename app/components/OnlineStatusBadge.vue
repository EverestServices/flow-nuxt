<template>
  <div class="online-status-badge" :class="badgeClass" :title="tooltipText">
    <div class="status-dot" :class="dotClass"></div>
    <span v-if="showText" class="status-text">{{ statusText }}</span>
  </div>
</template>

<script setup lang="ts">
interface Props {
  isOnline?: boolean
  lastSeen?: string
  showText?: boolean
  size?: 'sm' | 'md' | 'lg'
  variant?: 'dot' | 'pill' | 'subtle'
}

const props = withDefaults(defineProps<Props>(), {
  isOnline: false,
  showText: false,
  size: 'md',
  variant: 'dot'
})

const { formatLastSeen, isUserOnline } = useOnlineStatus()

// Determine if user is actually online based on last activity
const actuallyOnline = computed(() => {
  console.log('OnlineStatusBadge - isOnline prop:', props.isOnline, 'lastSeen:', props.lastSeen)
  if (!props.isOnline) return false
  if (!props.lastSeen) return props.isOnline
  return isUserOnline(props.lastSeen)
})

// Badge classes based on variant and size
const badgeClass = computed(() => {
  const classes = ['online-status-badge']

  // Size classes
  switch (props.size) {
    case 'sm':
      classes.push('badge-sm')
      break
    case 'lg':
      classes.push('badge-lg')
      break
    default:
      classes.push('badge-md')
  }

  // Variant classes
  switch (props.variant) {
    case 'pill':
      classes.push('badge-pill')
      break
    case 'subtle':
      classes.push('badge-subtle')
      break
    default:
      classes.push('badge-dot')
  }

  return classes.join(' ')
})

// Dot color classes
const dotClass = computed(() => {
  return actuallyOnline.value ? 'dot-online' : 'dot-offline'
})

// Status text
const statusText = computed(() => {
  if (actuallyOnline.value) {
    return 'Online'
  } else if (props.lastSeen) {
    return formatLastSeen(props.lastSeen)
  } else {
    return 'Offline'
  }
})

// Tooltip text
const tooltipText = computed(() => {
  if (actuallyOnline.value) {
    return 'Currently online'
  } else if (props.lastSeen) {
    return `Last seen ${formatLastSeen(props.lastSeen)}`
  } else {
    return 'Offline'
  }
})
</script>

<style scoped>
.online-status-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

/* Size variants */
.badge-sm .status-dot {
  width: 6px;
  height: 6px;
}

.badge-sm .status-text {
  font-size: 10px;
}

.badge-md .status-dot {
  width: 8px;
  height: 8px;
}

.badge-md .status-text {
  font-size: 12px;
}

.badge-lg .status-dot {
  width: 10px;
  height: 10px;
}

.badge-lg .status-text {
  font-size: 14px;
}

/* Dot variant */
.badge-dot {
  /* Default styling for dot variant */
}

/* Pill variant */
.badge-pill {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 12px;
  padding: 4px 8px;
}

.badge-pill.badge-sm {
  padding: 2px 6px;
}

.badge-pill.badge-lg {
  padding: 6px 10px;
}

/* Subtle variant */
.badge-subtle {
  opacity: 0.8;
}

/* Status dot */
.status-dot {
  border-radius: 50%;
  position: relative;
  flex-shrink: 0;
}

.dot-online {
  background-color: #10b981; /* Green */
  box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
}

.dot-online::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 50%;
  background-color: #10b981;
  animation: pulse 2s infinite;
}

.dot-offline {
  background-color: #6b7280; /* Gray */
}

/* Status text */
.status-text {
  font-weight: 500;
  color: #374151;
}

.badge-pill .status-text {
  color: #1f2937;
}

/* Pulse animation for online status */
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

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .badge-pill {
    background: rgba(255, 255, 255, 0.1);
  }

  .status-text {
    color: #d1d5db;
  }

  .badge-pill .status-text {
    color: #f9fafb;
  }
}
</style>