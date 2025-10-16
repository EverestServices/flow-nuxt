<template>
  <div class="weekly-calendar">
    <!-- Week Header -->
    <div class="calendar-header">
      <h2 class="week-title">
        {{ formatWeekRange(currentDate) }}
      </h2>
    </div>

    <!-- Days Header -->
    <div class="week-header">
      <div class="time-column-header"></div>
      <div v-for="day in weekDays" :key="day.dateStr" class="day-column-header">
        <div class="day-name">{{ day.dayName }}</div>
        <div class="day-number" :class="{ 'today': day.isToday }">
          {{ day.dayNumber }}
        </div>
      </div>
    </div>

    <!-- Time Grid -->
    <div class="time-grid" ref="timeGrid">
      <!-- Time labels column -->
      <div class="time-column">
        <div v-for="hour in hours" :key="hour" class="time-slot">
          <div class="time-label">{{ formatHour(hour) }}</div>
        </div>
      </div>

      <!-- Days columns -->
      <div v-for="day in weekDays" :key="day.dateStr" class="day-column">
        <!-- Hourly slots -->
        <div
          v-for="hour in hours"
          :key="`${day.dateStr}-${hour}`"
          class="hour-slot"
          @click="createEventAt(day.date, hour)"
        >
          <!-- Events in this hour -->
          <div
            v-for="event in getEventsForDayHour(day.dateStr, hour)"
            :key="event.id"
            class="event-block"
            :class="`event-${event.type}`"
            :style="getEventStyle(event)"
            @click.stop="$emit('eventClick', event)"
          >
            <div class="event-title">{{ event.title }}</div>
            <div class="event-time">{{ formatEventTimeRange(event) }}</div>
            <div v-if="event.location" class="event-location">📍 {{ event.location }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { format, startOfWeek, addDays } from 'date-fns'
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

// Generate week days
const weekDays = computed(() => {
  const startDate = startOfWeek(props.currentDate, { weekStartsOn: 0 })
  const today = new Date()

  return Array.from({ length: 7 }, (_, i) => {
    const date = addDays(startDate, i)
    const dateStr = format(date, 'yyyy-MM-dd')

    return {
      date,
      dateStr,
      dayName: format(date, 'EEE'),
      dayNumber: format(date, 'd'),
      isToday: format(date, 'yyyy-MM-dd') === format(today, 'yyyy-MM-dd')
    }
  })
})

// Get events for a specific day and hour
const getEventsForDayHour = (dateStr: string, hour: number) => {
  return props.events
    .filter(event => {
      if (event.start_date !== dateStr) return false
      if (event.all_day) return hour === 6 // Show all-day events at the top

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
  if (event.all_day) {
    return {
      height: '20px',
      top: '2px',
      left: '2px',
      right: '2px'
    }
  }

  if (!event.start_time || !event.end_time) {
    return {
      height: '40px',
      top: '2px',
      left: '2px',
      right: '2px'
    }
  }

  const startMinutes = parseTimeToMinutes(event.start_time)
  const endMinutes = parseTimeToMinutes(event.end_time)
  const duration = endMinutes - startMinutes

  const hourHeight = 60 // Height of each hour slot in pixels
  const startOffset = (startMinutes % 60) * (hourHeight / 60)
  const height = Math.max(20, (duration / 60) * hourHeight)

  return {
    height: `${height}px`,
    top: `${startOffset + 2}px`,
    left: '2px',
    right: '2px'
  }
}

// Helper functions
const parseTimeToMinutes = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  return hours * 60 + minutes
}

const formatWeekRange = (date: Date) => {
  const startDate = startOfWeek(date, { weekStartsOn: 0 })
  const endDate = addDays(startDate, 6)

  if (startDate.getMonth() === endDate.getMonth()) {
    return `${format(startDate, 'MMM d')} - ${format(endDate, 'd, yyyy')}`
  } else {
    return `${format(startDate, 'MMM d')} - ${format(endDate, 'MMM d, yyyy')}`
  }
}

const formatHour = (hour: number) => {
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour % 12 || 12
  return `${displayHour} ${ampm}`
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

const createEventAt = (date: Date, hour: number) => {
  emit('createEvent', date, hour)
}

// Scroll to current time on mount
onMounted(() => {
  if (timeGrid.value) {
    const currentHour = new Date().getHours()
    const scrollPosition = Math.max(0, (currentHour - 6) * 60 - 100)
    timeGrid.value.scrollTop = scrollPosition
  }
})
</script>

<style scoped>
.weekly-calendar {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.calendar-header {
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.week-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.week-header {
  display: grid;
  grid-template-columns: 80px repeat(7, 1fr);
  border-bottom: 1px solid #e5e7eb;
}

.time-column-header {
  border-right: 1px solid #e5e7eb;
  background: #f9fafb;
}

.day-column-header {
  padding: 12px 8px;
  text-align: center;
  background: #f9fafb;
  border-right: 1px solid #e5e7eb;
}

.day-name {
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
}

.day-number {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin-top: 4px;
}

.day-number.today {
  background: #3b82f6;
  color: white;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 4px auto 0;
}

.time-grid {
  display: grid;
  grid-template-columns: 80px repeat(7, 1fr);
  flex: 1;
  overflow-y: auto;
}

.time-column {
  border-right: 1px solid #e5e7eb;
  background: #f9fafb;
}

.time-slot {
  height: 60px;
  border-bottom: 1px solid #e5e7eb;
  position: relative;
}

.time-label {
  position: absolute;
  top: -8px;
  right: 8px;
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.day-column {
  border-right: 1px solid #e5e7eb;
  position: relative;
}

.hour-slot {
  height: 60px;
  border-bottom: 1px solid #e5e7eb;
  position: relative;
  cursor: pointer;
  transition: background-color 0.2s;
}

.hour-slot:hover {
  background: #f9fafb;
}

.event-block {
  position: absolute;
  border-radius: 4px;
  padding: 4px 6px;
  font-size: 11px;
  line-height: 1.2;
  cursor: pointer;
  transition: opacity 0.2s;
  border-left: 3px solid;
  overflow: hidden;
  z-index: 1;
}

.event-block:hover {
  opacity: 0.9;
  z-index: 2;
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

.event-title {
  font-weight: 600;
  margin-bottom: 1px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.event-time {
  font-weight: 500;
  opacity: 0.8;
  margin-bottom: 1px;
}

.event-location {
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>