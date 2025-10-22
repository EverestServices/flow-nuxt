<template>
  <div>
    <!-- Trigger Button -->
    <UIButtonEnhanced
      @click="isOpen = true"
      variant="primary"
      size="sm"
      icon="i-lucide-calendar-plus"
    >
      Create Event
    </UIButtonEnhanced>

    <!-- Modal Backdrop with Blur -->
    <Transition name="fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 bg-white/40 dark:bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        @click.self="closeModal"
      >
        <!-- Modal Content -->
        <Transition name="slide-up">
          <UIBox
            v-if="isOpen"
            class="w-full max-w-3xl max-h-[90vh] overflow-y-auto dark:!bg-slate-800"
            @click.stop
          >
            <!-- Modal Header -->
            <div class="sticky top-0 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 p-6 flex items-center justify-between z-50">
              <div class="flex items-center gap-3">
                <div class="bg-blue-500 rounded-full p-2">
                  <Icon name="i-lucide-calendar" class="w-5 h-5 text-white" />
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                  {{ editingEvent ? 'Edit Event' : 'Create New Event' }}
                </h3>
              </div>
              <button
                @click="closeModal"
                class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              >
                <Icon name="i-lucide-x" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
              </button>
            </div>

            <!-- Modal Body -->
            <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
              <!-- Event Title -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Event Title <span class="text-red-500">*</span>
                </label>
                <UIInput
                  v-model="formState.title"
                  placeholder="Enter event title"
                  icon="i-lucide-text"
                  required
                />
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description
                </label>
                <textarea
                  v-model="formState.description"
                  placeholder="Enter event description"
                  rows="3"
                  class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-vertical"
                ></textarea>
              </div>

              <!-- Event Type & Visibility Row -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Type <span class="text-red-500">*</span>
                  </label>
                  <UISelect
                    v-model="formState.type"
                    :options="eventTypeOptions"
                    required
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Visibility
                  </label>
                  <UISelect
                    v-model="formState.visibility"
                    :options="visibilityOptions"
                  />
                </div>
              </div>

              <!-- Date and Time -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Start Date <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formState.start_date"
                    type="date"
                    required
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Start Time
                  </label>
                  <input
                    v-model="formState.start_time"
                    type="time"
                    :disabled="formState.all_day"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                  />
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    End Date <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="formState.end_date"
                    type="date"
                    required
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    End Time
                  </label>
                  <input
                    v-model="formState.end_time"
                    type="time"
                    :disabled="formState.all_day"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                  />
                </div>
              </div>

              <!-- All Day Toggle -->
              <div class="flex items-center gap-2">
                <label class="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    v-model="formState.all_day"
                    @change="toggleAllDay"
                    class="sr-only peer"
                  />
                  <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                </label>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">All Day Event</span>
              </div>

              <!-- Location -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Location
                </label>
                <UIInput
                  v-model="formState.location"
                  placeholder="Enter event location"
                  icon="i-lucide-map-pin"
                  @blur="checkTravelTime"
                />
              </div>

              <!-- Travel Time Warning -->
              <UIAlert v-if="travelInfo" :variant="travelInfo.type === 'error' ? 'danger' : travelInfo.type === 'warning' ? 'warning' : 'info'">
                <div class="flex gap-3">
                  <div class="text-2xl">
                    {{ travelInfo.type === 'warning' ? '⚠️' : travelInfo.type === 'error' ? '❌' : 'ℹ️' }}
                  </div>
                  <div class="flex-1">
                    <div class="font-semibold mb-1">{{ travelInfo.title }}</div>
                    <div class="text-sm mb-2">{{ travelInfo.message }}</div>
                    <div v-if="travelInfo.departureTime" class="text-sm"><strong>Suggested departure:</strong> {{ travelInfo.departureTime }}</div>
                    <div v-if="travelInfo.distance" class="text-sm"><strong>Distance:</strong> {{ formatDistance(travelInfo.distance) }}</div>
                  </div>
                </div>
              </UIAlert>

              <!-- Notes -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Notes
                </label>
                <textarea
                  v-model="formState.notes"
                  placeholder="Enter any additional notes"
                  rows="4"
                  class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-vertical"
                ></textarea>
              </div>

              <!-- Error Message -->
              <UIAlert v-if="error" variant="danger">
                {{ error }}
              </UIAlert>

              <!-- Action Buttons -->
              <div class="flex items-center justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                <UIButtonEnhanced
                  type="button"
                  variant="outline"
                  size="lg"
                  @click="closeModal"
                >
                  Cancel
                </UIButtonEnhanced>
                <UIButtonEnhanced
                  type="submit"
                  variant="primary"
                  size="lg"
                  :disabled="loading"
                  icon="i-lucide-check"
                >
                  {{ loading ? 'Saving...' : (editingEvent ? 'Update Event' : 'Create Event') }}
                </UIButtonEnhanced>
              </div>
            </form>
          </UIBox>
        </Transition>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { CalendarEvent, CreateEventData, UpdateEventData } from '~/composables/useCalendar'

// Props
interface Props {
  editingEvent?: CalendarEvent | null
  initialDate?: Date
  initialHour?: number
}

const props = defineProps<Props>()

// Emits
const emit = defineEmits<{
  created: []
  updated: []
}>()

// Composables
const { createEvent, updateEvent, fetchEvents } = useCalendar()

// State
const isOpen = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)
const travelInfo = ref<{
  type: 'info' | 'warning' | 'error'
  title: string
  message: string
  departureTime?: string
  distance?: number
} | null>(null)

// Select options
const eventTypeOptions = [
  { label: 'Meeting', value: 'meeting' },
  { label: 'Training', value: 'training' },
  { label: 'On-site Consultation', value: 'on-site-consultation' },
  { label: 'Online Consultation', value: 'online-consultation' },
  { label: 'Personal', value: 'personal' },
  { label: 'Holiday', value: 'holiday' },
  { label: 'Other', value: 'other' }
]

const visibilityOptions = [
  { label: 'Public', value: 'public' },
  { label: 'Private', value: 'private' },
  { label: 'Confidential', value: 'confidential' }
]

// Form state
const initialFormState = (): CreateEventData => ({
  title: '',
  description: '',
  type: 'other',
  start_date: props.initialDate ? format(props.initialDate, 'yyyy-MM-dd') : format(new Date(), 'yyyy-MM-dd'),
  start_time: props.initialHour ? `${props.initialHour.toString().padStart(2, '0')}:00` : '09:00',
  end_date: props.initialDate ? format(props.initialDate, 'yyyy-MM-dd') : format(new Date(), 'yyyy-MM-dd'),
  end_time: props.initialHour ? `${(props.initialHour + 1).toString().padStart(2, '0')}:00` : '10:00',
  all_day: false,
  visibility: 'public',
  location: '',
  notes: '',
  attendees: []
})

const formState = ref<CreateEventData>(initialFormState())

// Methods
const closeModal = () => {
  isOpen.value = false
  error.value = null
  formState.value = initialFormState()
  travelInfo.value = null
}

const toggleAllDay = () => {
  if (formState.value.all_day) {
    formState.value.start_time = ''
    formState.value.end_time = ''
  } else {
    formState.value.start_time = '09:00'
    formState.value.end_time = '17:00'
  }
}

// Geocode location to coordinates
const geocodeLocation = async (location: string): Promise<[number, number] | null> => {
  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}`
    )
    const data = await response.json()

    if (data && data.length > 0) {
      return [parseFloat(data[0].lat), parseFloat(data[0].lon)]
    }
    return null
  } catch (error) {
    console.error('Geocoding error:', error)
    return null
  }
}

// Get driving route using OSRM
const getDrivingRoute = async (
  start: [number, number],
  end: [number, number]
): Promise<{ distance: number; duration: number } | null> => {
  try {
    const response = await fetch(
      `https://router.project-osrm.org/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=false`
    )
    const data = await response.json()

    if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
      const route = data.routes[0]
      return {
        distance: route.distance / 1000,
        duration: route.duration
      }
    }
    return null
  } catch (error) {
    console.error('Routing error:', error)
    return null
  }
}

// Format distance
const formatDistance = (km: number): string => {
  if (km < 1) {
    return `${Math.round(km * 1000)} m`
  }
  return `${km.toFixed(1)} km`
}

// Format time
const formatTime = (time: string): string => {
  const [hours, minutes] = time.split(':').map(Number)
  const ampm = hours >= 12 ? 'PM' : 'AM'
  const displayHour = hours % 12 || 12
  return `${displayHour}:${minutes.toString().padStart(2, '0')} ${ampm}`
}

// Check travel time from previous event
const checkTravelTime = async () => {
  travelInfo.value = null

  const isOfflineEvent = formState.value.type === 'on-site-consultation' ||
                        formState.value.type === 'meeting' ||
                        formState.value.type === 'training'

  if (!isOfflineEvent || !formState.value.location || !formState.value.start_date || !formState.value.start_time) {
    return
  }

  try {
    const events = await fetchEvents({
      start_date: formState.value.start_date,
      end_date: formState.value.start_date
    })

    if (!events || events.length === 0) {
      return
    }

    const currentStartTime = formState.value.start_time
    const previousEvents = events
      .filter(e => e.location && e.start_time && e.start_time < currentStartTime)
      .sort((a, b) => (b.start_time || '').localeCompare(a.start_time || ''))

    if (previousEvents.length === 0) {
      return
    }

    const previousEvent = previousEvents[0]

    const [previousCoords, currentCoords] = await Promise.all([
      geocodeLocation(previousEvent.location!),
      geocodeLocation(formState.value.location)
    ])

    if (!previousCoords || !currentCoords) {
      travelInfo.value = {
        type: 'warning',
        title: 'Unable to verify travel time',
        message: 'Could not find one or both locations. Please verify the addresses are correct.'
      }
      return
    }

    const route = await getDrivingRoute(previousCoords, currentCoords)

    if (!route) {
      travelInfo.value = {
        type: 'warning',
        title: 'Unable to calculate route',
        message: 'Could not find a driving route between locations. Please verify the addresses.'
      }
      return
    }

    const previousEndTime = previousEvent.end_time || previousEvent.start_time
    const [prevEndHours, prevEndMinutes] = previousEndTime!.split(':').map(Number)
    const [currentStartHours, currentStartMinutes] = formState.value.start_time.split(':').map(Number)

    const previousEndMinutesTotal = prevEndHours * 60 + prevEndMinutes
    const currentStartMinutesTotal = currentStartHours * 60 + currentStartMinutes
    const availableTimeMinutes = currentStartMinutesTotal - previousEndMinutesTotal
    const requiredTimeMinutes = Math.ceil(route.duration / 60) + 10

    const departureMinutesTotal = currentStartMinutesTotal - requiredTimeMinutes
    const departureHours = Math.floor(departureMinutesTotal / 60)
    const departureMinutes = departureMinutesTotal % 60
    const departureTime = `${departureHours.toString().padStart(2, '0')}:${departureMinutes.toString().padStart(2, '0')}`

    if (requiredTimeMinutes > availableTimeMinutes) {
      travelInfo.value = {
        type: 'error',
        title: '⚠️ Insufficient travel time',
        message: `You need ${Math.ceil(requiredTimeMinutes)} minutes to reach this location from your previous event at "${previousEvent.title}", but only have ${Math.floor(availableTimeMinutes)} minutes available.`,
        departureTime: formatTime(departureTime),
        distance: route.distance
      }
    } else if (requiredTimeMinutes > availableTimeMinutes * 0.7) {
      travelInfo.value = {
        type: 'warning',
        title: 'Tight schedule',
        message: `You'll need to leave immediately after your previous event "${previousEvent.title}" to arrive on time.`,
        departureTime: formatTime(departureTime),
        distance: route.distance
      }
    } else {
      travelInfo.value = {
        type: 'info',
        title: 'Travel time calculated',
        message: `From your previous event "${previousEvent.title}", you'll need about ${Math.ceil(route.duration / 60)} minutes of travel time.`,
        departureTime: formatTime(departureTime),
        distance: route.distance
      }
    }
  } catch (err) {
    console.error('Error checking travel time:', err)
  }
}

const handleSubmit = async () => {
  loading.value = true
  error.value = null

  try {
    if (props.editingEvent) {
      const updateData: UpdateEventData = {
        id: props.editingEvent.id,
        ...formState.value
      }

      const result = await updateEvent(updateData)

      if (result) {
        emit('updated')
        closeModal()
      } else {
        error.value = 'Failed to update event. Please try again.'
      }
    } else {
      const result = await createEvent(formState.value)

      if (result) {
        emit('created')
        closeModal()
      } else {
        error.value = 'Failed to create event. Please try again.'
      }
    }
  } catch (err) {
    console.error('Error submitting event form:', err)
    error.value = 'An unexpected error occurred. Please try again.'
  } finally {
    loading.value = false
  }
}

// Watch for editing event changes
watch(() => props.editingEvent, (newEvent) => {
  if (newEvent) {
    isOpen.value = true
    formState.value = {
      title: newEvent.title,
      description: newEvent.description || '',
      type: newEvent.type,
      start_date: newEvent.start_date,
      start_time: newEvent.start_time || '',
      end_date: newEvent.end_date,
      end_time: newEvent.end_time || '',
      all_day: newEvent.all_day,
      visibility: newEvent.visibility,
      location: newEvent.location || '',
      notes: newEvent.notes || '',
      attendees: newEvent.attendees || []
    }
  } else if (newEvent === null && isOpen.value) {
    closeModal()
  }
}, { immediate: true })

// Watch for initial date/hour changes
watch(() => [props.initialDate, props.initialHour], () => {
  if (!props.editingEvent && (props.initialDate || props.initialHour)) {
    formState.value.start_date = props.initialDate ? format(props.initialDate, 'yyyy-MM-dd') : formState.value.start_date
    formState.value.end_date = props.initialDate ? format(props.initialDate, 'yyyy-MM-dd') : formState.value.end_date

    if (props.initialHour !== undefined) {
      formState.value.start_time = `${props.initialHour.toString().padStart(2, '0')}:00`
      formState.value.end_time = `${(props.initialHour + 1).toString().padStart(2, '0')}:00`
    }

    isOpen.value = true
  }
})

// Watch for changes that should trigger travel time check
watch([() => formState.value.type, () => formState.value.start_date, () => formState.value.start_time], () => {
  if (formState.value.location) {
    checkTravelTime()
  }
})
</script>

<style scoped>
/* Fade transition for backdrop */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Slide up transition for modal */
.slide-up-enter-active {
  transition: all 0.3s ease;
}

.slide-up-leave-active {
  transition: all 0.2s ease;
}

.slide-up-enter-from {
  transform: translateY(20px);
  opacity: 0;
}

.slide-up-leave-to {
  transform: translateY(-20px);
  opacity: 0;
}
</style>
