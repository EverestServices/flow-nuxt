<template>
  <div
    class="cursor-pointer bg-center bg-cover bg-no-repeat box-border relative rounded-full shrink-0 w-full border-2 border-white dark:border-black/30 overflow-hidden transition-all duration-300 hover:scale-[1.02] hover:shadow-2xl hover:border-blue-400 dark:hover:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-500/50 dark:focus:ring-blue-400/50"
    :style="eventBackgroundStyle"
    @click="emit('click')"
    tabindex="0"
  >
    <!-- Progress overlay -->
    <div
      v-if="meetingProgress > 0 && meetingProgress <= 100"
      class="absolute inset-0 transition-all duration-500 ease-out top-1 left-1 bottom-1 right-1"
      :style="{ zIndex: 0 }"
    >
      <div
        class="h-full rounded-full bg-gradient-to-r from-[#f7f7f7] to-[#efffae]/50 dark:from-gray-700 dark:to-gray-600"
        :style="{
          width: `${meetingProgress}%`,
        }"
      ></div>
    </div>

    <!-- Content wrapper with relative positioning -->
    <div class="relative z-10 flex gap-[10px] items-center p-[10px]">
    <div
        class="rounded-full flex items-center justify-center w-12 h-12
         bg-white/30 dark:bg-black/30
         backdrop-blur-md
         border border-white dark:border-black/50
         text-white font-medium
         shadow-lg
         hover:bg-white/30 dark:hover:bg-black/40
         transition">
      <Icon :name="getMeetingIcon(meetingType)" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
    </div>
    <div class="basis-0 flex flex-col grow items-start leading-[0] min-h-px min-w-px relative shrink-0 text-black dark:text-white">
      <div class="flex flex-col font-bold justify-center relative shrink-0 text-[14px] w-full font-outfit">
        <p class="leading-normal">{{ title }}</p>
      </div>
      <div class="flex flex-col font-normal justify-center relative shrink-0 text-[12px] w-full font-outfit">
        <p class="leading-normal">{{ description }}</p>
      </div>
    </div>

    <!-- Attendees avatars - moved to left of time badge -->
    <div v-if="attendeeColleagues && attendeeColleagues.length > 0" class="flex items-center mr-2">
      <div class="flex -space-x-2">
        <div
          v-for="colleague in attendeeColleagues.slice(0, 3)"
          :key="colleague.user_id"
          class="relative group"
        >
          <img
            :src="colleague.avatar_url || defaultAvatar"
            :alt="colleague.first_name || colleague.email"
            class="w-11 h-11 rounded-full object-cover border-2 border-white dark:border-gray-700 shadow-sm hover:z-10 transition-transform hover:scale-110"
            @error="handleImageError"
          />
          <!-- Online status indicator -->
          <div
            class="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-white dark:border-gray-700"
            :class="isColleagueOnline(colleague) ? 'bg-green-500' : 'bg-gray-400'"
            :title="isColleagueOnline(colleague) ? `${getColleagueName(colleague)} is online` : `${getColleagueName(colleague)} is offline`"
          ></div>
        </div>
        <!-- Show more indicator if there are more than 3 attendees -->
        <div
          v-if="attendeeColleagues.length > 3"
          class="w-7 h-7 rounded-full bg-gray-300 dark:bg-gray-600 flex items-center justify-center text-xs font-bold text-gray-600 dark:text-gray-200 border-2 border-white dark:border-gray-800 shadow-sm"
          :title="`+${attendeeColleagues.length - 3} more attendees`"
        >
          +{{ attendeeColleagues.length - 3 }}
        </div>
      </div>
    </div>
    <div
        class="box-border flex items-center justify-center px-4 py-6 relative rounded-full shrink-0"
        :class="timeClasses"
    >
      <div
          class="flex flex-col font-normal justify-center leading-0 relative shrink-0 text-xs whitespace-pre font-outfit"
          :class="timeTextColor"
      >
        {{ time }}
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  title: String,
  description: String,
  time: String,
  type: {
    type: String,
    default: 'secondary'
  },
  attendees: {
    type: Array,
    default: () => []
  },
  startDate: String,
  startTime: String,
  endDate: String,
  endTime: String,
  allDay: {
    type: Boolean,
    default: false
  },
  meetingType: {
    type: String,
    default: 'meeting'
  }
})

// Emits
const emit = defineEmits(['click'])

// User system
const user = useSupabaseUser()

// Default avatar (same as used in OnlineUsersWidget)
const defaultAvatar = 'https://github.com/benjamincanac.png'

// Colleagues management (simplified for now to avoid timeout issues)
const colleagues = ref([])
const loadingColleagues = ref(false)

// Computed property to get attendee colleagues from the attendees email list (excluding current user)
const attendeeColleagues = computed(() => {
  if (!props.attendees || props.attendees.length === 0) return []

  // Filter out current user's email from attendees
  const currentUserEmail = user.value?.email
  const otherAttendees = props.attendees.filter(email => email !== currentUserEmail)

  if (otherAttendees.length === 0) return []

  // Try to match with actual colleagues from the database
  if (colleagues.value.length > 0) {
    return colleagues.value.filter(colleague =>
      otherAttendees.includes(colleague.email)
    )
  }

  // Fallback: create colleague objects from emails with unique avatars
  return otherAttendees.map((email, index) => ({
    user_id: email.split('@')[0],
    email: email,
    first_name: email.split('@')[0],
    avatar_url: `https://i.pravatar.cc/150?u=${email}`, // Generates unique avatar per email
    is_online: Math.random() > 0.5, // Mock online status
    last_activity: new Date().toISOString()
  }))
})

// Helper functions
const getColleagueName = (colleague) => {
  if (colleague.first_name && colleague.last_name) {
    return `${colleague.first_name} ${colleague.last_name}`.trim()
  }
  if (colleague.first_name) return colleague.first_name
  if (colleague.email) return colleague.email.split('@')[0]
  return 'Unknown User'
}

const isColleagueOnline = (colleague) => {
  if (colleague.is_online === false) return false
  if (!colleague.last_activity) return false

  const now = new Date()
  const lastActivity = new Date(colleague.last_activity)
  const diffMinutes = (now.getTime() - lastActivity.getTime()) / (1000 * 60)

  return diffMinutes < 5 // Online if active within last 5 minutes
}

const handleImageError = (event) => {
  const target = event.target
  target.src = defaultAvatar
}

// Meeting type icon mapping
const getMeetingIcon = (meetingType) => {
  const iconMap = {
    'meeting': 'i-lucide-users', // General meeting with people
    'training': 'i-lucide-graduation-cap', // Education/training
    'other': 'i-lucide-calendar', // Default calendar icon
    'on-site-consultation': 'i-lucide-map-pin', // Location-based meeting
    'online-consultation': 'i-lucide-video', // Video call
    'personal': 'i-lucide-user', // Personal event
    'holiday': 'i-lucide-plane' // Holiday/vacation
  }
  return iconMap[meetingType] || iconMap['meeting']
}

// Reactive dark mode detection
const isDarkMode = ref(false)

// Event background style with dark mode support
const eventBackgroundStyle = computed(() => {
  if (isDarkMode.value) {
    // Dark mode gradient
    return {
      background: 'linear-gradient(0deg, rgba(30, 41, 59, 0.45) 0%, rgba(30, 41, 59, 0.45) 100%), linear-gradient(90deg, rgba(51, 65, 85, 0.70) 7.65%, rgba(71, 85, 105, 0.70) 92.18%)'
    }
  } else {
    // Light mode gradient (original)
    return {
      background: 'linear-gradient(0deg, rgba(180, 192, 219, 0.45) 0%, rgba(180, 192, 219, 0.45) 100%), linear-gradient(90deg, rgba(249, 249, 249, 0.70) 7.65%, rgba(239, 255, 174, 0.70) 92.18%)'
    }
  }
})

// Watch for dark mode changes
const updateDarkMode = () => {
  isDarkMode.value = document.documentElement.classList.contains('dark')
}

// Observer for dark mode changes
let darkModeObserver = null

// Reactive time reference for real-time updates
const currentTime = ref(new Date())
let timeInterval = null

// Real-time meeting progress calculation
const meetingProgress = computed(() => {
  // If all day event, no progress indication
  if (props.allDay) return 0

  // If no start/end time, no progress indication
  if (!props.startDate || !props.startTime || !props.endTime) return 0

  // Use reactive currentTime for real-time updates
  const now = currentTime.value

  // Create start and end datetime objects
  const startDateTime = new Date(`${props.startDate}T${props.startTime}`)
  const endDateTime = new Date(`${props.endDate || props.startDate}T${props.endTime}`)

  // If meeting hasn't started yet
  if (now < startDateTime) return 0

  // If meeting has ended
  if (now > endDateTime) return 100

  // Calculate progress percentage
  const totalDuration = endDateTime.getTime() - startDateTime.getTime()
  const elapsed = now.getTime() - startDateTime.getTime()
  const progressPercent = Math.round((elapsed / totalDuration) * 100)

  // Ensure it's between 0 and 100
  return Math.max(0, Math.min(100, progressPercent))
})

const timeClasses = computed(() => {
  return 'bg-[#2050e3] dark:bg-blue-600'
})

const timeTextColor = computed(() => {
  return 'text-white dark:text-gray-100'
})

// Update progress every minute
const updateCurrentTime = () => {
  currentTime.value = new Date()
}

// Fetch colleagues safely
const fetchColleagues = async () => {
  try {
    loadingColleagues.value = true
    // This will be filled by the useColleagues composable when it's working
    // For now, keeping it empty to avoid timeout issues
    colleagues.value = []
  } catch (error) {
    console.warn('Could not fetch colleagues:', error)
  } finally {
    loadingColleagues.value = false
  }
}

// Initialize time updates when component mounts
onMounted(() => {
  // Update time every minute for real-time progress
  timeInterval = setInterval(updateCurrentTime, 60000) // 60 seconds

  // Try to fetch colleagues if attendees are present
  if (props.attendees && props.attendees.length > 0) {
    fetchColleagues()
  }

  // Initialize dark mode detection
  updateDarkMode()

  // Watch for dark mode changes using MutationObserver
  darkModeObserver = new MutationObserver(() => {
    updateDarkMode()
  })

  darkModeObserver.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['class']
  })
})

// Cleanup interval when component unmounts
onUnmounted(() => {
  if (timeInterval) {
    clearInterval(timeInterval)
  }
  if (darkModeObserver) {
    darkModeObserver.disconnect()
  }
})
</script>