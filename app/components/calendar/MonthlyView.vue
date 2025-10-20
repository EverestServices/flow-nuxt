<template>
  <div class="monthly-calendar overflow-hidden">
    <!-- Month Header -->

    <div class="calendar-header">
      <h2 class="month-title">
        {{ formatMonth(currentDate) }}
      </h2>
    </div>

    <!-- Days of Week Header -->
    <div class="days-header">
      <div v-for="day in daysOfWeek" :key="day" class="day-header">
        {{ day }}
      </div>
    </div>

    <!-- Calendar Grid -->
    <div class="calendar-grid">
      <div
        v-for="day in calendarDays"
        :key="`${day.date.getMonth()}-${day.date.getDate()}`"
        class="calendar-day"
        :class="{
          'other-month': !day.isCurrentMonth,
          'today': day.isToday,
          'selected': day.isSelected
        }"
        @click="selectDay(day.date)"
      >
        <div class="day-number">
          {{ day.date.getDate() }}
        </div>

        <!-- Events for this day -->
        <UIBox class="day-events">
          <div
            v-for="event in day.events"
            :key="event.id"
            class="event-item"
            :class="`event-${event.type}`"
            @click.stop="$emit('eventClick', event)"
          >
            <div class="event-time" v-if="!event.all_day">
              {{ formatEventTime(event) }}
            </div>
            <div class="event-title">
              {{ event.title }}
            </div>
          </div>

          <!-- Show more indicator if too many events -->
          <div v-if="day.events.length > 3" class="more-events">
            +{{ day.events.length - 3 }} more
          </div>
        </UIBox>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { CalendarEvent } from '~/composables/useCalendar'

interface Props {
  currentDate: Date
  events: CalendarEvent[]
  selectedDate?: Date
}

const props = defineProps<Props>()

const emit = defineEmits<{
  dayClick: [date: Date]
  eventClick: [event: CalendarEvent]
  createEvent: [date: Date]
}>()

const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

// Generate calendar days for the month view
const calendarDays = computed(() => {
  const year = props.currentDate.getFullYear()
  const month = props.currentDate.getMonth()

  // First day of the month
  const firstDay = new Date(year, month, 1)
  // Last day of the month
  const lastDay = new Date(year, month + 1, 0)

  // Start from the first Sunday of the week containing the first day
  const startDate = new Date(firstDay)
  startDate.setDate(firstDay.getDate() - firstDay.getDay())

  // End at the last Saturday of the week containing the last day
  const endDate = new Date(lastDay)
  endDate.setDate(lastDay.getDate() + (6 - lastDay.getDay()))

  const days = []
  const currentDay = new Date(startDate)

  while (currentDay <= endDate) {
    const dayEvents = getEventsForDay(currentDay)

    days.push({
      date: new Date(currentDay),
      isCurrentMonth: currentDay.getMonth() === month,
      isToday: isToday(currentDay),
      isSelected: props.selectedDate && isSameDay(currentDay, props.selectedDate),
      events: dayEvents.slice(0, 3) // Limit to 4 events for display
    })

    currentDay.setDate(currentDay.getDate() + 1)
  }

  return days
})

// Get events for a specific day
const getEventsForDay = (date: Date) => {
  const dateStr = format(date, 'yyyy-MM-dd')
  return props.events
    .filter(event => event.start_date === dateStr)
    .sort((a, b) => {
      // Sort by start_time (ascending order)
      const timeA = a.start_time || '00:00'
      const timeB = b.start_time || '00:00'
      return timeA.localeCompare(timeB)
    })
}

// Helper functions
const isToday = (date: Date) => {
  const today = new Date()
  return isSameDay(date, today)
}

const isSameDay = (date1: Date, date2: Date) => {
  return date1.getFullYear() === date2.getFullYear() &&
         date1.getMonth() === date2.getMonth() &&
         date1.getDate() === date2.getDate()
}

const formatMonth = (date: Date) => {
  return format(date, 'MMMM yyyy')
}

const formatEventTime = (event: CalendarEvent) => {
  if (event.all_day) return 'All day'
  if (!event.start_time) return ''

  const time = event.start_time.split(':')
  const hour = parseInt(time[0])
  const minute = time[1]
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const displayHour = hour % 12 || 12

  return `${displayHour}:${minute} ${ampm}`
}

const selectDay = (date: Date) => {
  emit('dayClick', date)
  emit('createEvent', date)
}
</script>

<style scoped>
.monthly-calendar {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.calendar-header {
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
}

.dark .calendar-header {
  border-bottom-color: rgb(55, 65, 81);
}

.month-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.dark .month-title {
  color: white;
}

.days-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  border-bottom: 1px solid #e5e7eb;
}

.dark .days-header {
  border-bottom-color: rgb(55, 65, 81);
}

.day-header {
  padding: 12px 8px;
  text-align: center;
  font-weight: 600;
  font-size: 14px;
  color: #6b7280;
  background: #f9fafb;
}

.dark .day-header {
  color: rgb(156, 163, 175);
  background: rgb(31, 41, 55);
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  grid-template-rows: repeat(6, 1fr);
  flex: 1;
  border-right: 1px solid #e5e7eb;
  border-bottom: 1px solid #e5e7eb;
}

.dark .calendar-grid {
  border-right-color: rgb(55, 65, 81);
  border-bottom-color: rgb(55, 65, 81);
}

.calendar-day {
  border-left: 1px solid #e5e7eb;
  border-top: 1px solid #e5e7eb;
  padding: 8px;
  min-height: 90px;
  background: white;
  cursor: pointer;
  transition: background-color 0.2s;
  overflow: hidden;
}

.dark .calendar-day {
  background: rgb(17, 24, 39);
  border-left-color: rgb(55, 65, 81);
  border-top-color: rgb(55, 65, 81);
  color: white;
}

.calendar-day:hover {
  background: #f9fafb;
}

.dark .calendar-day:hover {
  background: rgb(31, 41, 55);
}

.calendar-day.other-month {
  background: #f9fafb;
  color: #9ca3af;
}

.dark .calendar-day.other-month {
  background: rgb(31, 41, 55);
  color: rgb(107, 114, 128);
}

.calendar-day.today {
  background: #eff6ff;
}

.dark .calendar-day.today {
  background: rgba(59, 130, 246, 0.2);
}

.calendar-day.selected {
  background: #dbeafe;
  border-color: #3b82f6;
}

.dark .calendar-day.selected {
  background: rgba(59, 130, 246, 0.3);
  border-color: rgb(96, 165, 250);
}

.day-number {
  font-weight: 600;
  margin-bottom: 4px;
  font-size: 14px;
}

.day-events {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.event-item {
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 11px;
  line-height: 1.2;
  cursor: pointer;
  transition: opacity 0.2s;
  border-left: 3px solid;
}

.event-item:hover {
  opacity: 0.8;
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

.event-time {
  font-weight: 600;
  margin-bottom: 1px;
}

.event-title {
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.more-events {
  color: #6b7280;
  font-size: 10px;
  margin-top: 2px;
  font-weight: 500;
}

.dark .more-events {
  color: rgb(156, 163, 175);
}
</style>