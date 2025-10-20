<template>
  <div class="">

    <!-- Days header -->
    <div class="flex space-x-2">
      <UIBox
        v-for="day in weekDays"
        :key="day.dateStr"
        class="flex flex-col justify-center items-center py-2 cursor-pointer grow"
        :class="{ 'today': day.isToday, 'selected': day.isSelected }"
        @click="selectDay(day)"
        shadow="none"
      >
        <div class="outfit text-sm font-bold">{{ day.dayName }}</div>
        <div class="outfit text-xs font-normal">{{ day.dayNumber }}</div>
      </UIBox>
    </div>

    <!-- Events display -->
    <div class="">
      <div v-if="selectedDayEvents.length === 0" class="no-events text-gray-600 dark:text-gray-400">
        No events for {{ selectedDay.dayName }}, {{ selectedDay.dayNumber }}
      </div>
      <div v-else class="my-6 gap-y-3 flex flex-col">
        <UIBox
          v-for="event in selectedDayEvents.slice(0, 3)"
          :key="event.id"
          class="px-4 py-2"
          :class="`event-${event.type}`"
        >
          <div class="text-sm font-black outfit">{{ formatEventTime(event) }}</div>
          <div class="outfit text-sm font-normal">{{ event.title }}</div>
        </UIBox>
        <div v-if="selectedDayEvents.length > 3" class="more-events text-gray-600 dark:text-gray-400">
          +{{ selectedDayEvents.length - 3 }} more events
        </div>
      </div>
    </div>

    <!-- Week navigation -->
    <div class="flex justify-between items-center text-sn outfit mb-4">
      <div>
        <UIBox @click="previousWeek" class="py-2 px-4 cursor-pointer">‹</UIBox>
      </div>
      <div>
        <UIBox class="px-4 py-2">{{ weekTitle }}</UIBox>
      </div>
      <div>
        <UIBox @click="nextWeek" class="py-2 px-4 cursor-pointer">›</UIBox>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { format, startOfWeek, addDays, addWeeks, subWeeks, isSameDay, isToday } from 'date-fns'

const props = defineProps({
  events: {
    type: Array,
    default: () => []
  }
})

// State
const currentWeekStart = ref(startOfWeek(new Date(), { weekStartsOn: 0 }))
const selectedDate = ref(new Date())

// Computed
const weekTitle = computed(() => {
  const start = currentWeekStart.value
  const end = addDays(start, 6)

  if (start.getMonth() === end.getMonth()) {
    return `${format(start, 'MMM d')} - ${format(end, 'd, yyyy')}`
  } else {
    return `${format(start, 'MMM d')} - ${format(end, 'MMM d, yyyy')}`
  }
})

const weekDays = computed(() => {
  const start = currentWeekStart.value
  return Array.from({ length: 7 }, (_, i) => {
    const date = addDays(start, i)
    const dateStr = format(date, 'yyyy-MM-dd')

    return {
      date,
      dateStr,
      dayName: format(date, 'EEE'),
      dayNumber: format(date, 'd'),
      isToday: isToday(date),
      isSelected: isSameDay(date, selectedDate.value)
    }
  })
})

const selectedDay = computed(() => {
  return weekDays.value.find(day => day.isSelected) || weekDays.value.find(day => day.isToday) || weekDays.value[0]
})

const selectedDayEvents = computed(() => {
  const selectedDateStr = format(selectedDate.value, 'yyyy-MM-dd')
  return props.events
    .filter(event => {
      // Handle both the old format (with time property) and new format (with start_date)
      if (event.start_date) {
        return event.start_date === selectedDateStr
      }
      // Fallback for old format - assume it's for today
      return format(new Date(), 'yyyy-MM-dd') === selectedDateStr
    })
    .sort((a, b) => {
      // Sort by start_time (ascending order)
      const timeA = a.start_time || '00:00'
      const timeB = b.start_time || '00:00'
      return timeA.localeCompare(timeB)
    })
})

// Methods
const selectDay = (day) => {
  selectedDate.value = day.date
}

const previousWeek = () => {
  currentWeekStart.value = subWeeks(currentWeekStart.value, 1)
  // Keep selected date within the current week or select the first day
  const firstDay = currentWeekStart.value
  const lastDay = addDays(firstDay, 6)

  if (selectedDate.value < firstDay || selectedDate.value > lastDay) {
    selectedDate.value = firstDay
  }
}

const nextWeek = () => {
  currentWeekStart.value = addWeeks(currentWeekStart.value, 1)
  // Keep selected date within the current week or select the first day
  const firstDay = currentWeekStart.value
  const lastDay = addDays(firstDay, 6)

  if (selectedDate.value < firstDay || selectedDate.value > lastDay) {
    selectedDate.value = firstDay
  }
}

const formatEventTime = (event) => {
  // Handle new calendar event format
  if (event.all_day) return 'All day'
  if (event.start_time) {
    const time = event.start_time.split(':')
    const hour = parseInt(time[0])
    const minute = time[1]
    const ampm = hour >= 12 ? 'PM' : 'AM'
    const displayHour = hour % 12 || 12
    return `${displayHour}:${minute} ${ampm}`
  }

  // Handle old format
  if (event.time) {
    const time = event.time.split(':')
    const hour = parseInt(time[0])
    const minute = time[1] || '00'
    const ampm = hour >= 12 ? 'PM' : 'AM'
    const displayHour = hour % 12 || 12
    return `${displayHour}:${minute} ${ampm}`
  }

  return 'All day'
}

// Initialize with today selected
onMounted(() => {
  const today = new Date()
  selectedDate.value = today

  // If today is not in the current week, adjust the week
  const weekStart = currentWeekStart.value
  const weekEnd = addDays(weekStart, 6)

  if (today < weekStart || today > weekEnd) {
    currentWeekStart.value = startOfWeek(today, { weekStartsOn: 0 })
  }
})
</script>

<style scoped>
.weekly-calendar-widget {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.week-navigation {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid #e5e7eb;
  background: rgba(255, 255, 255, 0.1);
}

.nav-button {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 4px;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #374151;
  font-size: 14px;
  font-weight: bold;
  transition: background-color 0.2s;
}

.nav-button:hover {
  background: rgba(255, 255, 255, 0.3);
}

.week-title {
  font-size: 12px;
  font-weight: 600;
  color: #374151;
}

.days-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  border-bottom: 1px solid #e5e7eb;
}

.day-header {
  padding: 8px 4px;
  text-align: center;
  cursor: pointer;
  transition: background-color 0.2s;
  border-right: 1px solid rgba(255, 255, 255, 0.1);
}

.day-header:last-child {
  border-right: none;
}

.day-header:hover {
  background: rgba(255, 255, 255, 0.1);
}

.day-header.today {
  background: rgba(59, 130, 246, 0.1);
}

.day-header.selected {
  background: rgba(59, 130, 246, 0.2);
}

.day-name {
  font-size: 10px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  margin-bottom: 2px;
}

.day-number {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.day-header.today .day-number {
  color: #3b82f6;
}

.events-container {
  flex: 1;
  overflow-y: auto;
}

.no-events {
  text-align: center;
  font-size: 12px;
  padding: 20px;
}

.events-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.event-item {
  padding: 6px 8px;
  border-radius: 4px;
  font-size: 11px;
  line-height: 1.2;
  border-left: 3px solid;
}

.event-meeting {
  background: rgba(59, 130, 246, 0.1);
  border-left-color: #3b82f6;
  color: #1e40af;
}

.event-training {
  background: rgba(245, 158, 11, 0.1);
  border-left-color: #f59e0b;
  color: #92400e;
}

.event-on-site-consultation {
  background: rgba(16, 185, 129, 0.1);
  border-left-color: #10b981;
  color: #065f46;
}

.event-online-consultation {
  background: rgba(99, 102, 241, 0.1);
  border-left-color: #6366f1;
  color: #3730a3;
}

.event-personal {
  background: rgba(236, 72, 153, 0.1);
  border-left-color: #ec4899;
  color: #be185d;
}

.event-holiday {
  background: rgba(245, 101, 101, 0.1);
  border-left-color: #f56565;
  color: #c53030;
}

.event-other {
  background: rgba(107, 114, 128, 0.1);
  border-left-color: #6b7280;
  color: #374151;
}

.event-time {
  font-weight: 600;
  margin-bottom: 2px;
}

.event-title {
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.more-events {
  font-size: 10px;
  text-align: center;
  margin-top: 4px;
  font-weight: 500;
}
</style>