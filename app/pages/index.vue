<template>
  <div class="flex h-24 items-center">
    <div class="text-2xl font-light">Everest<span class="font-black">Flow</span></div>
  </div>

  <button
    @click="showQuickActions = true"
    class="cursor-pointer px-4 py-3 flex justify-between items-center border border-white text-sm font-bold rounded-full fixed top-7 left-1/2 transform -translate-x-1/2 z-30 gap-x-4 hover:scale-105 transition-transform"
    style="background: linear-gradient(0deg, rgba(180, 192, 219, 0.45) 0%, rgba(180, 192, 219, 0.45) 100%), linear-gradient(90deg, rgba(249, 249, 249, 0.70) 7.65%, rgba(239, 255, 174, 0.70) 92.18%);"
  >
    <span>Quick Actions</span>
    <span><Icon name="i-lucide-chevron-down" class="w-4 h-4 mt-1" /></span>
  </button>

  <div class="flex flex-col space-y-8">
    <!-- welcome and upcoming events -->
    <div class="grid grid-cols-1 lg:grid-cols-2 min-h-96">
      <div class="basis-0 flex flex-col items-start justify-center">
        <div class="text-5xl font-thin outfit">Welcome <strong class="font-black">{{ userName }}</strong>, these things<br />are waiting for you <strong class="font-black">today</strong></div>
        <div class="text-2xl outfit font-thin">Today is {{ currentDay }}</div>
      </div>

      <div class="flex flex-col basis-0 items-start justify-center gap-2">
        <div v-if="upcomingEvents.length === 0" class="text-gray-500 text-sm">
          No events scheduled for today
        </div>
        <div v-else class="text-xs text-gray-400 mb-2">Click on events to view details</div>
        <EventCard
          v-for="(event, index) in upcomingEvents"
          :key="event.id || index"
          :title="event.title"
          :description="event.description"
          :time="event.time"
          :type="event.type"
          :attendees="event.attendees"
          :start-date="event.start_date"
          :start-time="event.start_time"
          :end-date="event.end_date"
          :end-time="event.end_time"
          :all-day="event.all_day"
          :meeting-type="event.meetingType"
          @click="openEventDetail(event)"
        />
      </div>
    </div>

    <!-- todos, calendar, and online users -->
    <div class="grid lg:grid-cols-2 gap-x-4">
      <UIBox>
        <div class="w-full text-left p-6">
          <div class="flex justify-between mb-6">
            <UIH2>ToDo ({{ todoItems.length }})</UIH2>
            <div class="flex gap-2">
              <button
                  @click="navigateTo('/ascent/todo')"
                  class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer"
              >
                <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                  View All
                </div>
              </button>
            </div>
          </div>

          <div class="flex flex-col ">
            <div v-if="todoItems.length === 0" class="text-gray-500 text-sm">
              No todos found
            </div>

            <div v-else>
              <div class="text-xs text-gray-400 mb-2">Click on Edit/Delete buttons to manage todos</div>
              <TodoItem
                  v-for="(item, index) in todoItems"
                  :key="item.id || index"
                  :todo="item"
                  @toggle="(id) => toggleTodoById(id, index)"
                  @edit="(todo) => openTodoEdit(todo)"
                  @delete="(todo) => deleteTodo(todo)" class="mb-4"
              />
            </div>
          </div>

        </div>
      </UIBox>

      <UIBox>
        <div class="w-full flex flex-col p-6">
          <div class="flex justify-between mb-6">
            <UIH2>Your Week</UIH2>
            <button
                @click="navigateTo('/ascent/calendar')"
                class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer"
            >
              <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                View All
              </div>
            </button>
          </div>

          <DashboardWeeklyCalendar :events="calendarEvents" />
        </div>
      </UIBox>

      <!-- Online Users -->
      <!--<OnlineUsersWidget />-->
    </div>

    <!-- Latest News Section -->
    <div class="">
    <UIBox>
      <div class="w-full p-6">
        <div class="flex justify-between mb-6">
          <UIH2>Latest News</UIH2>
          <button
              @click="navigateTo('/academy/news')"
              class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
              View All
            </div>
          </button>
        </div>

        <!-- Loading State -->
        <div v-if="loadingNews" class="space-y-4">
          <USkeleton v-for="i in 3" :key="i" class="h-24 w-full" />
        </div>

        <!-- Error State -->
        <div v-else-if="newsError" class="text-gray-500 text-sm">
          Error loading news: {{ newsError }}
        </div>

        <!-- No News -->
        <div v-else-if="latestNews.length === 0" class="text-gray-500 text-sm">
          No news articles found
        </div>

        <!-- News Articles -->
        <div v-else class="space-y-4 lg:space-y-0 lg:space-x-4 flex lg:flex-row flex-col">
          <UIBox
            v-for="article in latestNews"
            :key="article.id"
            @click="navigateTo(`/academy/news/${article.slug}`)"
            shadow="none"
            class="p-4"
          >
            <!-- Article Image -->
            <div v-if="article.featured_image_url" class="rounded-2xl h-48">
              <img
                :src="article.featured_image_url"
                :alt="article.featured_image_alt || article.title"
                class="w-full h-full object-cover rounded-2xl"
              />
            </div>

            <!-- Article Content -->
            <div class=" flex flex-col gap-2 mt-4">
              <div class="flex items-center gap-2 mb-1">
                <UBadge
                  v-if="article.category"
                  :style="{ backgroundColor: article.category.color }"
                  class="text-white text-xs"
                  size="xs"
                >
                  {{ article.category.name }}
                </UBadge>
                <UBadge v-if="article.is_global" color="blue" variant="soft" size="xs">
                  Global
                </UBadge>
                <UBadge v-if="article.is_featured" color="yellow" variant="soft" size="xs">
                  Featured
                </UBadge>
              </div>

              <h3 class="font-semibold text-gray-900 line-clamp-1 mb-1">
                {{ article.title }}
              </h3>

              <p class="text-sm text-gray-600 line-clamp-2 mb-2">
                {{ article.excerpt }}
              </p>

              <div class="flex items-center justify-between text-xs text-gray-500">
                <span>{{ formatDate(article.published_at || article.created_at) }}</span>
                <span class="flex items-center gap-1">
                  <Icon name="i-lucide-eye" class="w-3 h-3" />
                  {{ article.view_count || 0 }}
                </span>
              </div>
            </div>
          </UIBox>
        </div>
      </div>
    </UIBox>
  </div>
  </div>

  <!-- Todo Edit Modal -->
  <TodoEditModal
    :todo="editingTodo"
    :is-open="showTodoModal"
    @close="closeTodoModal"
    @updated="handleTodoSaved"
  />

  <!-- Event Detail Modal -->
  <EventDetail
    :event="selectedEvent"
    :is-open="showEventModal"
    @close="closeEventModal"
  />

  <!-- Quick Actions Modal -->
  <QuickActions
    :is-open="showQuickActions"
    @close="closeQuickActions"
    @create-todo="handleQuickCreateTodo"
    @create-client="handleQuickCreateClient"
    @create-ticket="handleQuickCreateTicket"
  />
</template>

<script setup>
import { ref, computed } from 'vue'
import EverestLogo from "~/components/EverestLogo.vue"
import TodoCreate from "~/components/modals/TodoCreate.vue"
import TodoEditModal from "~/components/modals/TodoEditModal.vue"
import EventDetail from "~/components/modals/EventDetail.vue"
import QuickActions from "~/components/modals/QuickActions.vue"

// Page metadata
useHead({
  title: 'EverestFlow Dashboard'
})

// Composables
const user = useSupabaseUser()
const client = useSupabaseClient()
const router = useRouter()
const { getArticles } = useNews()

// Reactive data
const userName = ref('John')
const isDarkMode = ref(false)
const todoItems = ref([])
const latestNews = ref([])
const loadingNews = ref(true)
const newsError = ref(null)

// Modal states
const showTodoModal = ref(false)
const editingTodo = ref(null)
const showEventModal = ref(false)
const selectedEvent = ref(null)
const showQuickActions = ref(false)

const currentDay = computed(() => {
  return new Date().toLocaleDateString('en-US', { weekday: 'long' })
})

// Upcoming events from today's calendar
const upcomingEvents = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  const todayEvents = calendarEvents.value
    .filter(event => event.start_date === today)
    .sort((a, b) => {
      // Sort by start_time (ascending order)
      const timeA = a.start_time || '00:00'
      const timeB = b.start_time || '00:00'
      return timeA.localeCompare(timeB)
    })

  return todayEvents.map((event, index) => ({
    title: event.title,
    description: event.description || 'Calendar event',
    time: event.start_time ? formatTime(event.start_time) : '09:00 AM',
    type: index === 0 ? 'primary' : 'secondary',
    attendees: event.attendees || [],
    id: event.id,
    start_date: event.start_date,
    start_time: event.start_time,
    end_date: event.end_date,
    end_time: event.end_time,
    all_day: event.all_day,
    meetingType: event.type // Add meeting type
  })).slice(0, 5) // Limit to 4 events to match original design
})

// Format time for display (convert 24h to 12h format)
const formatTime = (timeString) => {
  if (!timeString) return '09:00 AM'

  const [hours, minutes] = timeString.split(':')
  const hour = parseInt(hours)
  const ampm = hour >= 12 ? 'PM' : 'AM'
  const hour12 = hour % 12 || 12

  return `${hour12}:${minutes} ${ampm}`
}

// Fetch todos from database
const fetchTodos = async () => {
  try {
    console.log('Dashboard: Fetching todos...')
    const { data, error } = await client
        .from('todos')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10) // Show max 10 todos on dashboard

    if (error) {
      console.error('Dashboard: Error fetching todos:', error)
      return
    }

    console.log('Dashboard: Fetched todos:', data)
    todoItems.value = data || []
    console.log('Dashboard: todoItems set to:', todoItems.value)
  } catch (err) {
    console.error('Dashboard: Error:', err)
  }
}

const weekDays = ref([
  { short: 'MON', full: 'Monday' },
  { short: 'TUE', full: 'Tuesday' },
  { short: 'WED', full: 'Wednesday' },
  { short: 'THU', full: 'Thursday' },
  { short: 'FRI', full: 'Friday' },
  { short: 'SAT', full: 'Saturday' },
  { short: 'SUN', full: 'Sunday' }
])

// Get real calendar events
const { events: calendarEvents, fetchEvents } = useCalendar()

// Get today's events formatted for the widget
const todaysCalendarEvents = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  const todayEvents = calendarEvents.value.filter(event => event.start_date === today)

  return todayEvents.map(event => ({
    title: event.title,
    time: event.start_time || '09:00',
    duration: 1
  })).slice(0, 5) // Limit to 5 events for the widget
})

// Navigation Methods
const shareLocation = () => {
  console.log('Sharing location...')
  // TODO: Implement location sharing
}

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  // TODO: Implement dark mode logic
}

const logout = async () => {
  try {
    const { error } = await client.auth.signOut()
    if (error) {
      console.error('Error logging out:', error)
    } else {
      // Redirect to login page
      await router.push('/login')
    }
  } catch (err) {
    console.error('Logout error:', err)
  }
}

// Methods

const toggleTodo = async (index) => {
  const todo = todoItems.value[index]
  if (!todo) return

  const newCompleted = !todo.completed

  try {
    // Update in Supabase
    const { error } = await client
        .from('todos')
        .update({ completed: newCompleted })
        .eq('id', todo.id)

    if (error) {
      console.error('Error updating todo:', error)
      return
    }

    // Update local state
    todoItems.value[index].completed = newCompleted
  } catch (err) {
    console.error('Error toggling todo:', err)
  }
}

const toggleTodoById = async (id, index) => {
  const todo = todoItems.value[index]
  if (!todo || todo.id !== id) return

  const newCompleted = !todo.completed

  try {
    // Update in Supabase
    const { error } = await client
        .from('todos')
        .update({ completed: newCompleted })
        .eq('id', id)

    if (error) {
      console.error('Error updating todo:', error)
      return
    }

    // Update local state
    todoItems.value[index].completed = newCompleted
    console.log('Todo toggled on dashboard:', id, newCompleted)
  } catch (err) {
    console.error('Error toggling todo:', err)
  }
}

// Fetch latest news
const fetchNews = async () => {
  try {
    loadingNews.value = true
    newsError.value = null

    const { data, error } = await getArticles({
      limit: 3,
      offset: 0
    })

    if (error) {
      console.error('Error fetching latest news:', error)
      newsError.value = error.message
      return
    }

    latestNews.value = data || []
  } catch (err) {
    console.error('Error fetching news:', err)
    newsError.value = err.message
  } finally {
    loadingNews.value = false
  }
}

// Format date for display
const formatDate = (dateString) => {
  if (!dateString) return ''

  const date = new Date(dateString)
  const now = new Date()
  const diffTime = Math.abs(now - date)
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays === 1) {
    return 'Yesterday'
  } else if (diffDays <= 7) {
    return `${diffDays} days ago`
  } else {
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
    })
  }
}

// Todo Modal Handlers
const openTodoEdit = (todo) => {
  console.log('Opening todo edit for:', todo)
  editingTodo.value = todo
  showTodoModal.value = true
  console.log('Todo modal should open with todo:', editingTodo.value)
}

const closeTodoModal = () => {
  showTodoModal.value = false
  editingTodo.value = null
}

const handleTodoSaved = () => {
  // Refresh todos list
  fetchTodos()
  closeTodoModal()
}

const deleteTodo = async (todo) => {
  if (!confirm('Are you sure you want to delete this todo?')) return

  try {
    const { error } = await client
      .from('todos')
      .delete()
      .eq('id', todo.id)

    if (error) {
      console.error('Error deleting todo:', error)
      return
    }

    // Refresh todos list
    fetchTodos()
  } catch (err) {
    console.error('Error deleting todo:', err)
  }
}

// Event Modal Handlers
const openEventDetail = (event) => {
  console.log('Opening event detail for:', event)

  // Convert dashboard event format to full event object
  const fullEvent = {
    id: event.id || `temp-${Date.now()}`,
    title: event.title || 'Untitled Event',
    description: event.description || '',
    start_date: event.start_date,
    start_time: event.start_time || null,
    end_date: event.end_date || event.start_date,
    end_time: event.end_time || null,
    all_day: event.all_day || false,
    type: event.meetingType || 'meeting',
    attendees: event.attendees || [],
    location: null,
    visibility: 'public',
    notes: '',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    user_id: 'current-user'
  }

  selectedEvent.value = fullEvent
  showEventModal.value = true
  console.log('Event modal should be open:', showEventModal.value, selectedEvent.value)
}

const closeEventModal = () => {
  showEventModal.value = false
  selectedEvent.value = null
}

// QuickActions Modal Handlers
const closeQuickActions = () => {
  showQuickActions.value = false
}

const handleQuickCreateTodo = () => {
  // This will open the TodoCreate modal automatically via its button
  // The TodoCreate component is already in the header
}

const handleQuickCreateClient = () => {
  // Navigate to client management or trigger client create modal
  navigateTo('/ascent/clients')
}

const handleQuickCreateTicket = () => {
  // Navigate to ticket system or trigger ticket create modal
  navigateTo('/ascent/tickets')
}

// Fetch todos and calendar events when component mounts
onMounted(() => {
  fetchTodos()
  fetchEvents()
  fetchNews()
})

</script>

<style scoped>
/* Navigation Item Styles */
.nav-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  color: #374151;
  border-radius: 8px;
  transition: background-color 0.2s, color 0.2s;
  text-decoration: none;
  cursor: pointer;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
}

.nav-item:hover {
  background-color: rgba(255, 255, 255, 0.4);
}

.nav-item.active {
  background-color: rgba(59, 130, 246, 0.15);
  color: #1d4ed8;
  font-weight: 500;
}

.nav-item.active .nav-icon {
  color: #1d4ed8;
}

.nav-icon {
  width: 20px;
  height: 20px;
  margin-right: 12px;
  color: #6b7280;
}

.nav-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
  width: 100%;
}

.sub-nav-item {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  font-size: 14px;
  color: #6b7280;
  border-radius: 6px;
  transition: background-color 0.2s, color 0.2s;
  text-decoration: none;
}

.sub-nav-item:hover {
  background-color: rgba(255, 255, 255, 0.3);
}

.sub-nav-item.active {
  background-color: rgba(59, 130, 246, 0.1);
  color: #2563eb;
  font-weight: 500;
}

.sub-nav-icon {
  width: 16px;
  height: 16px;
  margin-right: 8px;
}

/* Custom fonts - you'll need to add these to your Nuxt config */
.font-lufga-light {
  font-family: 'FONTSPRING DEMO - Lufga ExtraLight', sans-serif;
}

.font-lufga-medium {
  font-family: 'FONTSPRING DEMO - Lufga Medium', sans-serif;
}

.font-lufga-semibold {
  font-family: 'FONTSPRING DEMO - Lufga SemiBold', sans-serif;
}

.font-outfit {
  font-family: 'Outfit', sans-serif;
}
</style>