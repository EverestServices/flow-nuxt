<template>
  <UIBox>
  <div class="daily-calendar">
    <!-- Day Header -->
    <div class="calendar-header">
      <h2 class="day-title">
        {{ formatDay(currentDate) }}
      </h2>
      <div class="day-subtitle">
        {{ formatDaySubtitle(currentDate) }}
      </div>
    </div>

    <!-- Time Grid -->
    <div class="time-grid" ref="timeGrid">
      <!-- Time labels and events -->
      <div class="day-schedule">
        <div v-for="hour in hours" :key="hour" class="hour-block">
          <div class="time-label">{{ formatHour(hour) }}</div>
          <div class="hour-content" @click="createEventAt(hour)">
            <!-- Events in this hour -->
            <div
              v-for="event in getEventsForHour(hour)"
              :key="event.id"
              class="event-block"
              :class="`event-${event.type}`"
              :style="getEventStyle(event)"
              @click.stop="$emit('eventClick', event)"
            >
              <div class="event-header">
                <div class="event-title">{{ event.title }}</div>
                <div class="event-time">{{ formatEventTimeRange(event) }}</div>
              </div>

              <div v-if="event.description" class="event-description">
                {{ event.description }}
              </div>

              <div v-if="event.location" class="event-location">
                📍 {{ event.location }}
              </div>

              <div v-if="event.attendees && event.attendees.length > 0" class="event-attendees">
                👥 {{ event.attendees.length }} attendee{{ event.attendees.length > 1 ? 's' : '' }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- All-day events section -->
    <div v-if="allDayEvents.length > 0" class="all-day-section">
      <h3 class="all-day-title">All Day Events</h3>
      <div class="all-day-events">
        <div
          v-for="event in allDayEvents"
          :key="event.id"
          class="all-day-event"
          :class="`event-${event.type}`"
          @click="$emit('eventClick', event)"
        >
          <div class="event-title">{{ event.title }}</div>
          <div v-if="event.description" class="event-description">
            {{ event.description }}
          </div>
        </div>
      </div>
    </div>
  </div></UIBox>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { CalendarEvent } from '~/composables/useCalendar'

interface Props {
  currentDate: Date
  events: CalendarEvent[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  eventClick: [event: CalendarEvent]
  createEvent: [date: Date, hour: number]
}>()

const timeGrid = ref<HTMLElement>()

// Generate hours from 6 AM to 11 PM
const hours = Array.from({ length: 18 }, (_, i) => i + 6)

// Get today's events for the current date
const todayEvents = computed(() => {
  const dateStr = format(props.currentDate, 'yyyy-MM-dd')
  return props.events.filter(event => event.start_date === dateStr)
})

// Separate all-day events
const allDayEvents = computed(() => {
  return todayEvents.value.filter(event => event.all_day)
})

// Timed events
const timedEvents = computed(() => {
  return todayEvents.value.filter(event => !event.all_day)
})

// Get events for a specific hour
const getEventsForHour = (hour: number) => {
  return timedEvents.value
    .filter(event => {
      if (!event.start_time) return false
      const startHour = parseInt(event.start_time.split(':')[0])
      return startHour === hour
    })
    .sort((a, b) => {
      // Sort by start_time (ascending order)
      const timeA = a.start_time || '00:00'
      const timeB = b.start_time || '00:00'
      return timeA.localeCompare(timeB)
    })
}

// Calculate event style for positioning and height
const getEventStyle = (event: CalendarEvent) => {
  if (!event.start_time || !event.end_time) {
    return {
      height: '40px',
      top: '2px'
    }
  }

  const startMinutes = parseTimeToMinutes(event.start_time)
  const endMinutes = parseTimeToMinutes(event.end_time)
  const duration = endMinutes - startMinutes

  const hourHeight = 80 // Height of each hour slot in pixels
  const startOffset = (startMinutes % 60) * (hourHeight / 60)
  const height = Math.max(30, (duration / 60) * hourHeight)

  return {
    height: `${height}px`,
    top: `${startOffset + 2}px`
  }
}

// Helper functions
const parseTimeToMinutes = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  return hours * 60 + minutes
}

const formatDay = (date: Date) => {
  return format(date, 'EEEE')
}

const formatDaySubtitle = (date: Date) => {
  return format(date, 'MMMM d, yyyy')
}

const formatHour = (hour: number) => {
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour % 12 || 12
  return `${displayHour}:00 ${ampm}`
}

const formatEventTimeRange = (event: CalendarEvent) => {
  if (event.all_day) return 'All day'
  if (!event.start_time) return ''

  let timeStr = formatTime(event.start_time)
  if (event.end_time && event.end_time !== event.start_time) {
    timeStr += ` - ${formatTime(event.end_time)}`
  }
  return timeStr
}

const formatTime = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  const ampm = hours >= 12 ? 'PM' : 'AM'
  const displayHour = hours % 12 || 12
  return `${displayHour}:${minutes.toString().padStart(2, '0')} ${ampm}`
}

const createEventAt = (hour: number) => {
  emit('createEvent', props.currentDate, hour)
}

// Scroll to current time on mount
onMounted(() => {
  if (timeGrid.value) {
    const currentHour = new Date().getHours()
    const scrollPosition = Math.max(0, (currentHour - 6) * 80 - 100)
    timeGrid.value.scrollTop = scrollPosition
  }
})
</script>

<style scoped>
.daily-calendar {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.calendar-header {
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
  background: white;
}

.day-title {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.day-subtitle {
  font-size: 16px;
  color: #6b7280;
  margin-top: 4px;
}

.all-day-section {
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
}

.all-day-title {
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
  margin: 0 0 12px 0;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.all-day-events {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.all-day-event {
  padding: 12px;
  border-radius: 8px;
  border-left: 4px solid;
  cursor: pointer;
  transition: opacity 0.2s;
}

.all-day-event:hover {
  opacity: 0.8;
}

.time-grid {
  flex: 1;
  overflow-y: auto;
  padding: 0 20px;
}

.day-schedule {
  padding: 16px 0;
}

.hour-block {
  display: flex;
  min-height: 80px;
  border-bottom: 1px solid #f3f4f6;
  position: relative;
}

.time-label {
  width: 80px;
  padding-right: 16px;
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
  text-align: right;
  padding-top: 4px;
  flex-shrink: 0;
}

.hour-content {
  flex: 1;
  position: relative;
  cursor: pointer;
  transition: background-color 0.2s;
  border-radius: 4px;
  min-height: 80px;
}

.hour-content:hover {
  background: #f9fafb;
}

.event-block {
  position: absolute;
  left: 8px;
  right: 8px;
  border-radius: 6px;
  padding: 8px 12px;
  cursor: pointer;
  transition: all 0.2s;
  border-left: 4px solid;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.event-block:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.event-meeting {
  background: #dbeafe;
  border-left-color: #3b82f6;
  color: #1e40af;
}

.event-training {
  background: #fef3c7;
  border-left-color: #f59e0b;
  color: #92400e;
}

.event-on-site-consultation {
  background: #d1fae5;
  border-left-color: #10b981;
  color: #065f46;
}

.event-online-consultation {
  background: #e0e7ff;
  border-left-color: #6366f1;
  color: #3730a3;
}

.event-personal {
  background: #fce7f3;
  border-left-color: #ec4899;
  color: #be185d;
}

.event-holiday {
  background: #fed7d7;
  border-left-color: #f56565;
  color: #c53030;
}

.event-other {
  background: #f3f4f6;
  border-left-color: #6b7280;
  color: #374151;
}

.event-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 4px;
}

.event-title {
  font-weight: 600;
  font-size: 14px;
  line-height: 1.2;
  flex: 1;
}

.event-time {
  font-size: 12px;
  font-weight: 500;
  opacity: 0.8;
  margin-left: 8px;
  white-space: nowrap;
}

.event-description {
  font-size: 12px;
  line-height: 1.3;
  margin-bottom: 4px;
  opacity: 0.9;
}

.event-location {
  font-size: 11px;
  opacity: 0.7;
  margin-bottom: 2px;
}

.event-attendees {
  font-size: 11px;
  opacity: 0.7;
}
</style>