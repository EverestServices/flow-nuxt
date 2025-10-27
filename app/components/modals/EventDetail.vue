<template>
  <!-- Backdrop -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-white/20 z-50 backdrop-blur-sm"
    @click="closeModal"
  ></div>

  <!-- Event detail modal -->
  <Transition name="slide-event-modal">
    <div
      v-if="isOpen && event"
      class="fixed bottom-2 right-2 top-2 w-1/3 bg-white/60 dark:bg-black/40 backdrop-blur-2xl backdrop-saturate-180 border border-white/10 dark:border-white/5 rounded-2xl flex flex-col shadow-2xl z-50"
      style="backdrop-filter: blur(20px) saturate(180%);"
    >
      <!-- Header -->
      <div class="p-6 pb-4 border-b border-white/10 dark:border-white/5">
        <div class="flex items-center justify-between">
          <h3 class="text-black font-semibold text-lg drop-shadow-sm">Event Details</h3>
          <button
            @click="closeModal"
            class="text-white/70 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 space-y-6">
        <!-- Basic Info -->
        <div class="space-y-4">
          <div>
            <label class="text-white/60 text-sm font-medium">Title</label>
            <p class="text-black text-lg font-semibold">{{ event.title }}</p>
          </div>

          <div v-if="event.description">
            <label class="text-white/60 text-sm font-medium">Description</label>
            <p class="text-black">{{ event.description }}</p>
          </div>

          <div>
            <label class="text-white/60 text-sm font-medium">Type</label>
            <span
              class="inline-block px-3 py-1 rounded-full text-xs font-semibold"
              :class="getTypeClass(event.type)"
            >
              {{ formatType(event.type) }}
            </span>
          </div>

          <div>
            <label class="text-white/60 text-sm font-medium">Date & Time</label>
            <p class="text-white">{{ formatEventDateTime(event) }}</p>
          </div>

          <div v-if="event.location">
            <label class="text-white/60 text-sm font-medium">Location</label>
            <p class="text-white">📍 {{ event.location }}</p>
          </div>

          <div>
            <label class="text-white/60 text-sm font-medium">Visibility</label>
            <span
              class="inline-block px-3 py-1 rounded-full text-xs font-semibold"
              :class="getVisibilityClass(event.visibility)"
            >
              {{ formatVisibility(event.visibility) }}
            </span>
          </div>
        </div>

        <!-- Attendees -->
        <div v-if="event.attendees && event.attendees.length > 0" class="space-y-2">
          <label class="text-white/60 text-sm font-medium">Attendees</label>
          <div class="bg-white/10 rounded-lg p-4">
            <div v-for="attendee in event.attendees" :key="attendee" class="text-white/90 text-sm mb-1">
              👤 {{ attendee }}
            </div>
          </div>
        </div>

        <!-- Notes -->
        <div v-if="event.notes" class="space-y-2">
          <label class="text-white/60 text-sm font-medium">Notes</label>
          <div class="bg-white/10 rounded-lg p-4">
            <p class="text-white/90 text-sm leading-relaxed">{{ event.notes }}</p>
          </div>
        </div>

        <!-- Meta Info -->
        <div class="space-y-2 pt-4 border-t border-white/10">
          <div class="flex justify-between text-xs">
            <span class="text-white/60">Created</span>
            <span class="text-white/80">{{ formatDate(event.created_at) }}</span>
          </div>
          <div class="flex justify-between text-xs">
            <span class="text-white/60">Last Updated</span>
            <span class="text-white/80">{{ formatDate(event.updated_at) }}</span>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="p-6 pt-4 border-t border-white/10 dark:border-white/5">
        <div class="flex gap-3">
          <button
            @click="editEvent"
            class="flex-1 bg-white/15 hover:bg-white/20 text-white px-4 py-2 rounded-lg transition-colors text-sm font-medium"
          >
            Edit Event
          </button>
          <button
            @click="deleteEvent"
            class="flex-1 bg-red-500/80 hover:bg-red-500 text-white px-4 py-2 rounded-lg transition-colors text-sm font-medium"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { CalendarEvent } from '~/composables/useCalendar'

// Props
interface Props {
  event?: CalendarEvent | null
  isOpen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  event: null,
  isOpen: false
})

// Emits
const emit = defineEmits<{
  close: []
  editEvent: [event: CalendarEvent]
  deleteEvent: [event: CalendarEvent]
}>()

// Methods
const closeModal = () => {
  emit('close')
}

const editEvent = () => {
  if (props.event) {
    emit('editEvent', props.event)
  }
}

const deleteEvent = () => {
  if (props.event) {
    emit('deleteEvent', props.event)
  }
}

const formatDate = (dateString: string) => {
  try {
    return format(new Date(dateString), 'MMM d, yyyy')
  } catch (e) {
    return dateString
  }
}

const formatType = (type: string) => {
  return type.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
}

const formatVisibility = (visibility: string) => {
  return visibility.charAt(0).toUpperCase() + visibility.slice(1)
}

const formatEventDateTime = (event: CalendarEvent) => {
  try {
    const startDate = format(new Date(event.start_date), 'MMM d, yyyy')

    if (event.all_day) {
      if (event.start_date === event.end_date) {
        return `${startDate} (All day)`
      } else {
        const endDate = format(new Date(event.end_date), 'MMM d, yyyy')
        return `${startDate} - ${endDate} (All day)`
      }
    }

    let timeStr = ''
    if (event.start_time) {
      timeStr = formatTime(event.start_time)
      if (event.end_time && event.end_time !== event.start_time) {
        timeStr += ` - ${formatTime(event.end_time)}`
      }
    }

    if (event.start_date === event.end_date) {
      return `${startDate} ${timeStr}`.trim()
    } else {
      const endDate = format(new Date(event.end_date), 'MMM d, yyyy')
      return `${startDate} - ${endDate} ${timeStr}`.trim()
    }
  } catch (e) {
    return `${event.start_date} - ${event.end_date}`
  }
}

const formatTime = (time: string) => {
  try {
    const [hours, minutes] = time.split(':').map(Number)
    const ampm = hours >= 12 ? 'PM' : 'AM'
    const displayHour = hours % 12 || 12
    return `${displayHour}:${minutes.toString().padStart(2, '0')} ${ampm}`
  } catch (e) {
    return time
  }
}

const getTypeClass = (type: string) => {
  const classes = {
    meeting: 'bg-blue-500/80 text-white',
    training: 'bg-yellow-500/80 text-white',
    'on-site-consultation': 'bg-green-500/80 text-white',
    'online-consultation': 'bg-indigo-500/80 text-white',
    personal: 'bg-pink-500/80 text-white',
    holiday: 'bg-red-500/80 text-white',
    other: 'bg-gray-500/80 text-white'
  }
  return classes[type] || 'bg-gray-500/80 text-white'
}

const getVisibilityClass = (visibility: string) => {
  const classes = {
    public: 'bg-green-500/80 text-white',
    private: 'bg-yellow-500/80 text-white',
    confidential: 'bg-red-500/80 text-white'
  }
  return classes[visibility] || 'bg-gray-500/80 text-white'
}
</script>

<style scoped>
/* Right-sliding modal animation */
.slide-event-modal-enter-active,
.slide-event-modal-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-event-modal-enter-from,
.slide-event-modal-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.slide-event-modal-enter-to,
.slide-event-modal-leave-from {
  transform: translateX(0);
  opacity: 1;
}
</style>