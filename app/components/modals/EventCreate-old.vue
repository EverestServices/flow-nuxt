<template>
  <div>
    <UIBox @click="isOpen = true" class="px-4 py-4 cursor-pointer text-sm text-white" background="bg-green-500">
      Create Event
    </UIBox>

    <div v-if="isOpen" class="modal">
      <div class="modal-content">
        <h3>{{ editingEvent ? 'Edit Event' : 'Create New Event' }}</h3>

        <form @submit.prevent="handleSubmit">
          <!-- Event Title -->
          <div class="form-group">
            <label>Event Title*</label>
            <input
              v-model="formState.title"
              placeholder="Enter event title"
              required
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <!-- Description -->
          <div class="form-group">
            <label>Description</label>
            <textarea
              v-model="formState.description"
              placeholder="Enter event description"
              rows="3"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px; resize: vertical;"
            ></textarea>
          </div>

          <!-- Event Type -->
          <div class="form-group">
            <label>Type*</label>
            <select
              v-model="formState.type"
              required
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            >
              <option value="meeting">Meeting</option>
              <option value="training">Training</option>
              <option value="other">Other</option>
              <option value="on-site-consultation">On-site Consultation</option>
              <option value="online-consultation">Online Consultation</option>
              <option value="personal">Personal</option>
              <option value="holiday">Holiday</option>
            </select>
          </div>

          <!-- Date and Time Row -->
          <div class="date-time-row">
            <!-- Start Date -->
            <div class="form-group">
              <label>Start Date*</label>
              <input
                v-model="formState.start_date"
                type="date"
                required
                style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
              />
            </div>

            <!-- Start Time -->
            <div class="form-group">
              <label>Start Time</label>
              <input
                v-model="formState.start_time"
                type="time"
                :disabled="formState.all_day"
                style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
              />
            </div>
          </div>

          <div class="date-time-row">
            <!-- End Date -->
            <div class="form-group">
              <label>End Date*</label>
              <input
                v-model="formState.end_date"
                type="date"
                required
                style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
              />
            </div>

            <!-- End Time -->
            <div class="form-group">
              <label>End Time</label>
              <input
                v-model="formState.end_time"
                type="time"
                :disabled="formState.all_day"
                style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
              />
            </div>
          </div>

          <!-- All Day Toggle -->
          <div class="form-group">
            <label class="checkbox-label">
              <input
                v-model="formState.all_day"
                type="checkbox"
                @change="toggleAllDay"
              />
              All Day Event
            </label>
          </div>

          <!-- Visibility -->
          <div class="form-group">
            <label>Visibility</label>
            <select
              v-model="formState.visibility"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            >
              <option value="public">Public</option>
              <option value="private">Private</option>
              <option value="confidential">Confidential</option>
            </select>
          </div>

          <!-- Location -->
          <div class="form-group">
            <label>Location</label>
            <input
              v-model="formState.location"
              placeholder="Enter event location"
              @blur="checkTravelTime"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <!-- Travel Time Warning/Info -->
          <div v-if="travelInfo" class="travel-info-box" :class="travelInfo.type">
            <div class="travel-info-icon">
              {{ travelInfo.type === 'warning' ? '⚠️' : travelInfo.type === 'error' ? '❌' : 'ℹ️' }}
            </div>
            <div class="travel-info-content">
              <div class="travel-info-title">{{ travelInfo.title }}</div>
              <div class="travel-info-message">{{ travelInfo.message }}</div>
              <div v-if="travelInfo.departureTime" class="travel-info-departure">
                <strong>Suggested departure:</strong> {{ travelInfo.departureTime }}
              </div>
              <div v-if="travelInfo.distance" class="travel-info-distance">
                <strong>Distance:</strong> {{ formatDistance(travelInfo.distance) }}
              </div>
            </div>
          </div>

          <!-- Attendees -->
          <div class="form-group">
            <label>Invite Attendees</label>

            <!-- Company Colleagues Section -->
            <div class="colleagues-section">
              <div class="colleagues-header">
                <h4>Company Colleagues</h4>
                <button
                  type="button"
                  @click="refreshColleagues"
                  :disabled="loadingColleagues"
                  class="refresh-btn"
                >
                  {{ loadingColleagues ? 'Loading...' : 'Refresh' }}
                </button>
              </div>

              <div v-if="loadingColleagues" class="loading-state">
                <div class="loading-item" v-for="i in 3" :key="i">
                  <div class="loading-avatar"></div>
                  <div class="loading-text">
                    <div class="loading-name"></div>
                    <div class="loading-email"></div>
                  </div>
                </div>
              </div>

              <div v-else-if="colleaguesError" class="error-state">
                Error loading colleagues: {{ colleaguesError }}
              </div>

              <div v-else-if="colleagues.length === 0" class="empty-state">
                No colleagues found
              </div>

              <div v-else class="colleagues-list">
                <div
                  v-for="colleague in colleagues"
                  :key="colleague.user_id"
                  class="colleague-item"
                  :class="{ selected: isColleagueSelected(colleague) }"
                  @click="toggleColleague(colleague)"
                >
                  <div class="colleague-avatar">
                    <div class="avatar">
                      {{ getColleagueInitials(colleague) }}
                    </div>
                    <div v-if="isColleagueOnline(colleague)" class="online-indicator"></div>
                  </div>
                  <div class="colleague-info">
                    <div class="colleague-name">{{ getColleagueName(colleague) }}</div>
                    <div class="colleague-email">{{ colleague.email }}</div>
                  </div>
                  <div class="colleague-status">
                    <span v-if="isColleagueOnline(colleague)" class="status-online">Online</span>
                    <span v-else class="status-offline">Offline</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Manual Email Entry Section -->
            <div class="manual-attendees-section">
              <h4>External Attendees</h4>
              <div class="attendees-input">
                <div v-for="(email, index) in manualAttendees" :key="index" class="attendee-row">
                  <input
                    v-model="manualAttendees[index]"
                    type="email"
                    placeholder="Enter email address"
                    style="flex: 1; padding: 8px; margin-right: 8px;"
                  />
                  <button
                    type="button"
                    @click="removeManualAttendee(index)"
                    style="padding: 8px 12px; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;"
                  >
                    ×
                  </button>
                </div>
                <button
                  type="button"
                  @click="addManualAttendee"
                  style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 8px;"
                >
                  Add External Attendee
                </button>
              </div>
            </div>

            <!-- Selected Attendees Summary -->
            <div v-if="allSelectedAttendees.length > 0" class="selected-summary">
              <h4>Selected Attendees ({{ allSelectedAttendees.length }})</h4>
              <div class="selected-list">
                <div v-for="attendee in allSelectedAttendees" :key="attendee" class="selected-attendee">
                  {{ attendee }}
                </div>
              </div>
            </div>
          </div>

          <!-- Notes -->
          <div class="form-group">
            <label>Notes</label>
            <textarea
              v-model="formState.notes"
              placeholder="Enter any additional notes"
              rows="4"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px; resize: vertical;"
            ></textarea>
          </div>

          <div class="form-actions">
            <button
              type="button"
              @click="closeModal"
              style="padding: 8px 16px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 8px;"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="loading"
              style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;"
            >
              {{ loading ? 'Saving...' : (editingEvent ? 'Update Event' : 'Create Event') }}
            </button>
          </div>
        </form>

        <div v-if="error" style="color: red; margin-top: 16px; padding: 8px; background: #ffebee; border-radius: 4px;">
          {{ error }}
        </div>
      </div>
    </div>
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
const {
  colleagues,
  loading: loadingColleagues,
  error: colleaguesError,
  fetchColleagues,
  getColleagueName,
  getColleagueInitials,
  isColleagueOnline
} = useColleagues()

// State
const isOpen = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)
const selectedColleagues = ref<Set<string>>(new Set())
const manualAttendees = ref<string[]>([''])
const travelInfo = ref<{
  type: 'info' | 'warning' | 'error'
  title: string
  message: string
  departureTime?: string
  distance?: number
} | null>(null)

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
  attendees: ['']
})

const formState = ref<CreateEventData>(initialFormState())

// Computed property to combine all selected attendees
const allSelectedAttendees = computed(() => {
  const colleagueEmails = Array.from(selectedColleagues.value)
    .map(userId => {
      const colleague = colleagues.value.find(c => c.user_id === userId)
      return colleague?.email
    })
    .filter(email => email) as string[]

  const manualEmails = manualAttendees.value.filter(email => email.trim() !== '')

  return [...colleagueEmails, ...manualEmails]
})

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
      attendees: [] // We'll populate this via colleagues and manual attendees
    }

    // Parse existing attendees into colleagues and manual attendees
    if (newEvent.attendees && newEvent.attendees.length > 0) {
      const eventAttendees = [...newEvent.attendees]
      selectedColleagues.value.clear()
      manualAttendees.value = []

      eventAttendees.forEach(email => {
        // Check if this email belongs to a colleague
        const colleague = colleagues.value.find(c => c.email === email)
        if (colleague) {
          selectedColleagues.value.add(colleague.user_id)
        } else {
          manualAttendees.value.push(email)
        }
      })

      // Ensure at least one manual attendee field
      if (manualAttendees.value.length === 0) {
        manualAttendees.value = ['']
      }
    }
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

    // Automatically open modal when date/hour is set
    isOpen.value = true
  }
})

// Methods
const closeModal = () => {
  isOpen.value = false
  error.value = null
  formState.value = initialFormState()
  selectedColleagues.value.clear()
  manualAttendees.value = ['']
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

// Colleague management methods
const refreshColleagues = async () => {
  await fetchColleagues()
}

const toggleColleague = (colleague: any) => {
  if (selectedColleagues.value.has(colleague.user_id)) {
    selectedColleagues.value.delete(colleague.user_id)
  } else {
    selectedColleagues.value.add(colleague.user_id)
  }
}

const isColleagueSelected = (colleague: any) => {
  return selectedColleagues.value.has(colleague.user_id)
}

// Manual attendees methods
const addManualAttendee = () => {
  manualAttendees.value.push('')
}

const removeManualAttendee = (index: number) => {
  if (manualAttendees.value.length > 1) {
    manualAttendees.value.splice(index, 1)
  }
}

// Legacy methods for backward compatibility
const addAttendee = () => {
  addManualAttendee()
}

const removeAttendee = (index: number) => {
  removeManualAttendee(index)
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
        distance: route.distance / 1000, // Convert meters to km
        duration: route.duration // Duration in seconds
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

  // Only check for offline events with location
  const isOfflineEvent = formState.value.type === 'on-site-consultation' ||
                         formState.value.type === 'meeting' ||
                         formState.value.type === 'training'

  if (!isOfflineEvent || !formState.value.location || !formState.value.start_date || !formState.value.start_time) {
    return
  }

  try {
    // Fetch events for the same day
    const events = await fetchEvents({
      start_date: formState.value.start_date,
      end_date: formState.value.start_date
    })

    if (!events || events.length === 0) {
      return
    }

    // Find the event immediately before this one
    const currentStartTime = formState.value.start_time
    const previousEvents = events
      .filter(e => e.location && e.start_time && e.start_time < currentStartTime)
      .sort((a, b) => (b.start_time || '').localeCompare(a.start_time || ''))

    if (previousEvents.length === 0) {
      return
    }

    const previousEvent = previousEvents[0]

    // Geocode both locations
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

    // Get driving route
    const route = await getDrivingRoute(previousCoords, currentCoords)

    if (!route) {
      travelInfo.value = {
        type: 'warning',
        title: 'Unable to calculate route',
        message: 'Could not find a driving route between locations. Please verify the addresses.'
      }
      return
    }

    // Calculate required departure time
    const previousEndTime = previousEvent.end_time || previousEvent.start_time
    const [prevEndHours, prevEndMinutes] = previousEndTime!.split(':').map(Number)
    const [currentStartHours, currentStartMinutes] = formState.value.start_time.split(':').map(Number)

    const previousEndMinutesTotal = prevEndHours * 60 + prevEndMinutes
    const currentStartMinutesTotal = currentStartHours * 60 + currentStartMinutes
    const availableTimeMinutes = currentStartMinutesTotal - previousEndMinutesTotal
    const requiredTimeMinutes = Math.ceil(route.duration / 60) + 10 // Add 10 min buffer

    // Calculate suggested departure time
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
    // Use the combined attendees from colleagues and manual entries
    const eventData = {
      ...formState.value,
      attendees: allSelectedAttendees.value
    }

    if (props.editingEvent) {
      // Update existing event
      const updateData: UpdateEventData = {
        id: props.editingEvent.id,
        ...eventData
      }

      const result = await updateEvent(updateData)

      if (result) {
        emit('updated')
        closeModal()
      } else {
        error.value = 'Failed to update event. Please try again.'
      }
    } else {
      // Create new event
      const result = await createEvent(eventData)

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

// Close modal when editing event becomes null
watch(() => props.editingEvent, (newEvent) => {
  if (newEvent === null && isOpen.value) {
    closeModal()
  }
})

// Watch for changes that should trigger travel time check
watch([() => formState.value.type, () => formState.value.start_date, () => formState.value.start_time], () => {
  if (formState.value.location) {
    checkTravelTime()
  }
})

// Initialize colleagues when component mounts
onMounted(() => {
  fetchColleagues()
})
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 24px;
  border-radius: 8px;
  width: 90%;
  max-width: 700px;
  max-height: 90vh;
  overflow-y: auto;
}

.dark .modal-content {
  background: rgb(17, 24, 39);
}

.modal-content h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 24px;
}

.dark .modal-content h3 {
  color: white;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.dark .form-group label {
  color: rgb(209, 213, 219);
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.checkbox-label input {
  margin-right: 8px;
}

.date-time-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.attendees-input {
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 12px;
  background: #f9f9f9;
  margin-top: 4px;
}

.dark .attendees-input {
  background: rgb(31, 41, 55);
  border-color: rgb(75, 85, 99);
}

.attendee-row {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.attendee-row:last-child {
  margin-bottom: 0;
}

/* Colleagues section styles */
.colleagues-section {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin-top: 8px;
  margin-bottom: 16px;
  background: #fafafa;
}

.dark .colleagues-section {
  background: rgb(31, 41, 55);
  border-color: rgb(75, 85, 99);
}

.colleagues-header {
  display: flex;
  justify-content: between;
  align-items: center;
  margin-bottom: 12px;
}

.colleagues-header h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #333;
  flex: 1;
}

.dark .colleagues-header h4 {
  color: white;
}

.refresh-btn {
  padding: 6px 12px;
  background: #f0f0f0;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.refresh-btn:hover:not(:disabled) {
  background: #e0e0e0;
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-state {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.loading-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.loading-avatar {
  width: 32px;
  height: 32px;
  background: #e0e0e0;
  border-radius: 50%;
  animation: pulse 1.5s ease-in-out infinite;
}

.loading-text {
  flex: 1;
}

.loading-name {
  height: 12px;
  background: #e0e0e0;
  border-radius: 4px;
  width: 120px;
  margin-bottom: 4px;
  animation: pulse 1.5s ease-in-out infinite;
}

.loading-email {
  height: 10px;
  background: #e0e0e0;
  border-radius: 4px;
  width: 180px;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.error-state {
  color: #dc3545;
  font-size: 14px;
  text-align: center;
  padding: 16px;
}

.dark .error-state {
  color: rgb(248, 113, 113);
}

.empty-state {
  color: #666;
  font-size: 14px;
  text-align: center;
  padding: 16px;
}

.dark .empty-state {
  color: rgb(156, 163, 175);
}

.colleagues-list {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background: white;
}

.dark .colleagues-list {
  background: rgb(17, 24, 39);
  border-color: rgb(55, 65, 81);
}

.colleague-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background-color 0.2s;
}

.dark .colleague-item {
  border-bottom-color: rgb(55, 65, 81);
}

.colleague-item:last-child {
  border-bottom: none;
}

.colleague-item:hover {
  background: #f8f9fa;
}

.dark .colleague-item:hover {
  background: rgb(31, 41, 55);
}

.colleague-item.selected {
  background: #e3f2fd;
  border-color: #2196f3;
}

.dark .colleague-item.selected {
  background: rgba(59, 130, 246, 0.2);
  border-color: rgb(96, 165, 250);
}

.colleague-avatar {
  position: relative;
  margin-right: 12px;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #6c757d;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
}

.online-indicator {
  position: absolute;
  bottom: -2px;
  right: -2px;
  width: 10px;
  height: 10px;
  background: #28a745;
  border: 2px solid white;
  border-radius: 50%;
}

.colleague-info {
  flex: 1;
  min-width: 0;
}

.colleague-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dark .colleague-name {
  color: white;
}

.colleague-email {
  font-size: 12px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dark .colleague-email {
  color: rgb(156, 163, 175);
}

.colleague-status {
  font-size: 11px;
  font-weight: 500;
  margin-left: 8px;
}

.status-online {
  color: #28a745;
}

.status-offline {
  color: #6c757d;
}

.manual-attendees-section {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  background: #fafafa;
}

.dark .manual-attendees-section {
  background: rgb(31, 41, 55);
  border-color: rgb(75, 85, 99);
}

.manual-attendees-section h4 {
  margin: 0 0 12px 0;
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.dark .manual-attendees-section h4 {
  color: white;
}

.selected-summary {
  border: 1px solid #28a745;
  border-radius: 8px;
  padding: 16px;
  background: #f8fff8;
}

.dark .selected-summary {
  background: rgba(34, 197, 94, 0.1);
  border-color: rgb(34, 197, 94);
}

.selected-summary h4 {
  margin: 0 0 12px 0;
  font-size: 14px;
  font-weight: 600;
  color: #28a745;
}

.dark .selected-summary h4 {
  color: rgb(34, 197, 94);
}

.selected-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.selected-attendee {
  background: #28a745;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

.form-group input,
.form-group select,
.form-group textarea {
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background: white;
  color: #333;
}

.dark .form-group input,
.dark .form-group select,
.dark .form-group textarea {
  background: rgb(31, 41, 55);
  color: white;
  border-color: rgb(75, 85, 99);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.dark .form-group input:focus,
.dark .form-group select:focus,
.dark .form-group textarea:focus {
  border-color: rgb(96, 165, 250);
  box-shadow: 0 0 0 2px rgba(96, 165, 250, 0.25);
}

.form-group input:disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.dark .form-group input:disabled {
  background: rgb(55, 65, 81);
  color: rgb(156, 163, 175);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.form-actions button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Travel Info Box */
.travel-info-box {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 16px;
  border-left: 4px solid;
}

.travel-info-box.info {
  background: #e3f2fd;
  border-left-color: #2196f3;
}

.dark .travel-info-box.info {
  background: rgba(59, 130, 246, 0.1);
  border-left-color: rgb(96, 165, 250);
}

.travel-info-box.warning {
  background: #fff3e0;
  border-left-color: #ff9800;
}

.dark .travel-info-box.warning {
  background: rgba(251, 146, 60, 0.1);
  border-left-color: rgb(251, 146, 60);
}

.travel-info-box.error {
  background: #ffebee;
  border-left-color: #f44336;
}

.dark .travel-info-box.error {
  background: rgba(248, 113, 113, 0.1);
  border-left-color: rgb(248, 113, 113);
}

.travel-info-icon {
  font-size: 24px;
  flex-shrink: 0;
}

.travel-info-content {
  flex: 1;
}

.travel-info-title {
  font-weight: 600;
  font-size: 14px;
  margin-bottom: 4px;
  color: #1f2937;
}

.dark .travel-info-title {
  color: white;
}

.travel-info-message {
  font-size: 13px;
  color: #4b5563;
  margin-bottom: 8px;
  line-height: 1.4;
}

.dark .travel-info-message {
  color: rgb(209, 213, 219);
}

.travel-info-departure,
.travel-info-distance {
  font-size: 13px;
  color: #1f2937;
  margin-top: 6px;
}

.dark .travel-info-departure,
.dark .travel-info-distance {
  color: rgb(229, 231, 235);
}

.travel-info-departure strong,
.travel-info-distance strong {
  font-weight: 600;
}

@media (max-width: 768px) {
  .date-time-row {
    grid-template-columns: 1fr;
  }

  .modal-content {
    width: 95%;
    padding: 16px;
  }
}
</style>