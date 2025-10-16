<template>
  <div>

    <div class="flex justify-between py-4">
      <div class=" w-48 flex">
        <UIBox class="flex text-sm items-center px-4 gap-4" width="">
          <UIBox @click="navigateCalendar('prev')" class="w-8 h-8 flex items-center justify-center">
            ←
          </UIBox>
          <UIBox @click="navigateCalendar('today')" class="px-3 h-8 flex items-center justify-center">
            Today
          </UIBox>
          <UIBox @click="navigateCalendar('next')" class="w-8 h-8 flex items-center justify-center">
            →
          </UIBox>
        </UIBox>
      </div>

      <UIBox class="flex px-4 py-2 gap-2">
        <UIBox
          v-for="view in viewOptions"
          :key="view.value"
          @click="setView(view.value)"
          :class="['view-button', { active: currentView === view.value }]"
          class="text-sm"
          background="bg-black/30"
        >
          {{ view.label }}
        </UIBox>

        <select v-model="currentTypeFilter" @change="refreshEvents" class="filter-select">
          <option value="all">All Types</option>
          <option value="meeting">Meetings</option>
          <option value="training">Training</option>
          <option value="on-site-consultation">On-site Consultation</option>
          <option value="online-consultation">Online Consultation</option>
          <option value="personal">Personal</option>
          <option value="holiday">Holiday</option>
          <option value="other">Other</option>
        </select>

        <select v-model="currentVisibilityFilter" @change="refreshEvents" class="filter-select">
          <option value="all">All Visibility</option>
          <option value="public">Public</option>
          <option value="private">Private</option>
          <option value="confidential">Confidential</option>
        </select>

      </UIBox>

      <div class="w-32 mr-16  flex items-center justify-end">
        <ModalsEventCreate
          :initial-date="selectedDate"
          :initial-hour="selectedHour"
          @created="handleEventCreated"
          @updated="handleEventUpdated"
        />
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" style="text-align: center; padding: 40px;">
      Loading events...
    </div>

    <!-- Error State -->
    <div v-else-if="error" style="color: red; padding: 20px; background: #ffebee; border-radius: 4px; margin: 20px;">
      Error: {{ error }}
      <button @click="refreshEvents" style="margin-left: 16px; padding: 8px 16px;">Try Again</button>
    </div>

    <!-- Calendar Views -->
    <UIBox v-else class="calendar-container overflow-hidden">
      <!-- Monthly View -->
      <CalendarMonthlyView
        v-if="currentView === 'monthly'"
        :current-date="currentDate"
        :events="filteredEvents"
        :selected-date="selectedDate"
        @day-click="selectDate"
        @event-click="viewEvent"
        @create-event="createEventAt"
      />

      <!-- Weekly View -->
      <CalendarWeeklyView
        v-if="currentView === 'weekly'"
        :current-date="currentDate"
        :events="filteredEvents"
        @event-click="viewEvent"
        @create-event="createEventAt"
      />

      <!-- Daily View -->
      <CalendarDailyView
        v-if="currentView === 'daily'"
        :current-date="currentDate"
        :events="filteredEvents"
        @event-click="viewEvent"
        @create-event="createEventAt"
      />

      <!-- Map View -->
      <CalendarMapView
        v-if="currentView === 'map'"
        :current-date="currentDate"
        :events="filteredEvents"
        @event-click="viewEvent"
      />
    </UIBox>

    <!-- Event Detail Modal -->
    <ModalsEventDetail
      :event="selectedEvent"
      :is-open="showEventModal"
      @close="closeEventModal"
      @edit-event="editEvent"
      @delete-event="deleteEvent"
    />

    <!-- Edit Modal -->
    <ModalsEventCreate
      v-if="editingEvent"
      :editing-event="editingEvent"
      @updated="handleEventUpdated"
    />
  </div>
</template>

<script setup lang="ts">
import { format, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns'
import type { CalendarEvent, CalendarView } from '~/composables/useCalendar'

// Page metadata
useHead({
  title: 'Calendar - EverestFlow'
})

// Composables
const {
  events,
  loading,
  error,
  currentView,
  currentDate,
  fetchEvents,
  deleteEvent: removeEvent,
  navigateCalendar,
  setView
} = useCalendar()

// State
const editingEvent = ref<CalendarEvent | null>(null)
const selectedEvent = ref<CalendarEvent | null>(null)
const selectedDate = ref<Date | undefined>()
const selectedHour = ref<number | undefined>()
const showEventModal = ref(false)
const currentTypeFilter = ref('all')
const currentVisibilityFilter = ref('all')

// View options
const viewOptions = [
  { label: 'Month', value: 'monthly' as CalendarView },
  { label: 'Week', value: 'weekly' as CalendarView },
  { label: 'Day', value: 'daily' as CalendarView },
  { label: 'Map', value: 'map' as CalendarView }
]

// Computed
const currentPeriodTitle = computed(() => {
  switch (currentView.value) {
    case 'daily':
      return format(currentDate.value, 'EEEE, MMMM d, yyyy')
    case 'weekly':
      const weekStart = startOfWeek(currentDate.value, { weekStartsOn: 0 })
      const weekEnd = endOfWeek(currentDate.value, { weekStartsOn: 0 })
      if (weekStart.getMonth() === weekEnd.getMonth()) {
        return `${format(weekStart, 'MMM d')} - ${format(weekEnd, 'd, yyyy')}`
      } else {
        return `${format(weekStart, 'MMM d')} - ${format(weekEnd, 'MMM d, yyyy')}`
      }
    case 'monthly':
    default:
      return format(currentDate.value, 'MMMM yyyy')
  }
})

const filteredEvents = computed(() => {
  let result = events.value

  // Type filter
  if (currentTypeFilter.value !== 'all') {
    result = result.filter(event => event.type === currentTypeFilter.value)
  }

  // Visibility filter
  if (currentVisibilityFilter.value !== 'all') {
    result = result.filter(event => event.visibility === currentVisibilityFilter.value)
  }

  return result
})

// Methods
const refreshEvents = () => {
  const filters: any = {}

  if (currentTypeFilter.value !== 'all') {
    filters.type = currentTypeFilter.value
  }

  if (currentVisibilityFilter.value !== 'all') {
    filters.visibility = currentVisibilityFilter.value
  }

  // Add date range based on current view
  switch (currentView.value) {
    case 'daily':
      filters.start_date = format(currentDate.value, 'yyyy-MM-dd')
      filters.end_date = format(currentDate.value, 'yyyy-MM-dd')
      break
    case 'weekly':
      const weekStart = startOfWeek(currentDate.value, { weekStartsOn: 0 })
      const weekEnd = endOfWeek(currentDate.value, { weekStartsOn: 0 })
      filters.start_date = format(weekStart, 'yyyy-MM-dd')
      filters.end_date = format(weekEnd, 'yyyy-MM-dd')
      break
    case 'monthly':
      const monthStart = startOfMonth(currentDate.value)
      const monthEnd = endOfMonth(currentDate.value)
      filters.start_date = format(monthStart, 'yyyy-MM-dd')
      filters.end_date = format(monthEnd, 'yyyy-MM-dd')
      break
  }

  fetchEvents(filters)
}

const selectDate = (date: Date) => {
  selectedDate.value = date
}

const createEventAt = (date: Date, hour?: number) => {
  selectedDate.value = date
  selectedHour.value = hour
  // The create modal will automatically open with these values
}

const viewEvent = (event: CalendarEvent) => {
  selectedEvent.value = event
  showEventModal.value = true
}

const editEvent = (event: CalendarEvent) => {
  editingEvent.value = event
  closeEventModal()
}

const deleteEvent = async (event: CalendarEvent) => {
  if (confirm(`Are you sure you want to delete "${event.title}"?`)) {
    const success = await removeEvent(event.id)
    if (success) {
      closeEventModal()
    }
  }
}

const closeEventModal = () => {
  showEventModal.value = false
  selectedEvent.value = null
}

const handleEventCreated = () => {
  selectedDate.value = undefined
  selectedHour.value = undefined
  refreshEvents()
}

const handleEventUpdated = () => {
  editingEvent.value = null
  refreshEvents()
}

// Lifecycle
onMounted(async () => {
  await refreshEvents()
})

// Watch for view changes and refresh events
watch([currentView, currentDate], () => {
  refreshEvents()
})
</script>

<style scoped>
.calendar-controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  background: white;
  border-bottom: 1px solid #e5e7eb;
  flex-wrap: wrap;
  gap: 16px;
}

.navigation-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.nav-button {
  padding: 8px 12px;
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.2s;
}

.nav-button:hover {
  background: #e5e7eb;
}

.today-button {
  padding: 8px 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.today-button:hover {
  background: #2563eb;
}

.current-period {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  margin-left: 16px;
}

.view-controls {
  display: flex;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  overflow: hidden;
}

.view-button {
  padding: 8px 16px;
  background: white;
  border: none;
  border-right: 1px solid #d1d5db;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.view-button:last-child {
  border-right: none;
}

.view-button:hover {
  background: #f9fafb;
}

.view-button.active {
  background: #3b82f6;
  color: white;
}

.filter-controls {
  display: flex;
  gap: 12px;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  font-size: 14px;
}

.filter-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.25);
}

.calendar-container {
  /*
  height: calc(100vh - 480px);
  min-height: 400px;*/
}

@media (max-width: 768px) {
  .calendar-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .navigation-controls {
    justify-content: center;
  }

  .current-period {
    margin-left: 0;
    text-align: center;
    margin-top: 8px;
  }

  .view-controls {
    width: 100%;
  }

  .view-button {
    flex: 1;
    text-align: center;
  }

  .filter-controls {
    width: 100%;
  }

  .filter-select {
    flex: 1;
  }

  .calendar-container {
  }
}
</style>