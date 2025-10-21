<template>
  <div class="relative inline-block">
    <div :class="computedAvatarClasses">
      <!-- Image -->
      <img
        v-if="src"
        :src="src"
        :alt="alt || name"
        class="w-full h-full object-cover"
      />

      <!-- Initials -->
      <span v-else-if="name" class="outfit font-bold text-white">
        {{ initials }}
      </span>

      <!-- Default Icon -->
      <svg v-else class="w-2/3 h-2/3 text-white" fill="currentColor" viewBox="0 0 24 24">
        <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
    </div>

    <!-- Status Badge -->
    <span
      v-if="status"
      :class="computedStatusClasses"
      :aria-label="`Status: ${status}`"
    />
  </div>
</template>

<script setup lang="ts">
type AvatarSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
type AvatarStatus = 'online' | 'offline' | 'away' | 'busy'

interface Props {
  src?: string
  name?: string
  alt?: string
  size?: AvatarSize
  status?: AvatarStatus
  rounded?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  rounded: true
})

const initials = computed(() => {
  if (!props.name) return ''

  const names = props.name.trim().split(' ')
  if (names.length === 1) {
    return names[0].substring(0, 2).toUpperCase()
  }
  return (names[0][0] + names[names.length - 1][0]).toUpperCase()
})

const computedAvatarClasses = computed(() => {
  const classes = [
    'flex',
    'items-center',
    'justify-center',
    'overflow-hidden',
    'bg-gradient-to-br',
    'from-blue-500',
    'to-purple-600'
  ]

  // Size classes
  const sizeClasses = {
    xs: 'w-6 h-6 text-xs',
    sm: 'w-8 h-8 text-sm',
    md: 'w-10 h-10 text-base',
    lg: 'w-12 h-12 text-lg',
    xl: 'w-16 h-16 text-xl',
    '2xl': 'w-20 h-20 text-2xl'
  }
  classes.push(sizeClasses[props.size])

  // Shape
  if (props.rounded) {
    classes.push('rounded-full')
  } else {
    classes.push('rounded-lg')
  }

  return classes.join(' ')
})

const computedStatusClasses = computed(() => {
  const classes = [
    'absolute',
    'bottom-0',
    'right-0',
    'rounded-full',
    'ring-2',
    'ring-white'
  ]

  // Size-based positioning
  const sizeClasses = {
    xs: 'w-1.5 h-1.5',
    sm: 'w-2 h-2',
    md: 'w-2.5 h-2.5',
    lg: 'w-3 h-3',
    xl: 'w-4 h-4',
    '2xl': 'w-5 h-5'
  }
  classes.push(sizeClasses[props.size])

  // Status colors
  const statusColors = {
    online: 'bg-green-500',
    offline: 'bg-gray-400',
    away: 'bg-yellow-500',
    busy: 'bg-red-500'
  }
  if (props.status) {
    classes.push(statusColors[props.status])
  }

  return classes.join(' ')
})
</script>
