<template>
  <!-- Dynamic Island style container -->
  <div class="fixed top-6 left-1/2 transform -translate-x-1/2 z-20 bg-white dark:bg-black rounded-full border border-white/50 dark:border-black/50">
    <!-- Single morphing element -->
    <div
      class="flex items-center rounded-full overflow-hidden shadow-2xl transition-all duration-500 ease-in-out"
      :class="isOpen ? 'border-gray-700' : 'border-white'"
    >
      <!-- Collapsed State: Quick Actions Button -->
      <button
        v-if="!isOpen"
        @click="openActions"
        class="cursor-pointer px-4 py-3 flex justify-between items-center text-sm font-bold gap-x-4 hover:scale-105 transition-transform text-black dark:text-white backdrop-blur-sm whitespace-nowrap"
        style="background: linear-gradient(0deg, rgba(180, 192, 219, 0.45) 0%, rgba(180, 192, 219, 0.45) 100%), linear-gradient(90deg, rgba(249, 249, 249, 0.70) 7.65%, rgba(239, 255, 174, 0.70) 92.18%);"
      >
        <span>Quick Actions</span>
        <Icon name="i-lucide-chevron-down" class="w-4 h-4 mt-1" />
      </button>

      <!-- Expanded State: Actions Panel -->
      <template v-else>
        <!-- Close Button (left side) -->
        <button
          @click="closeActions"
          class="px-4 py-3 text-black dark:text-white font-bold text-sm hover:from-gray-800 hover:to-gray-700 transition-all flex items-center gap-2 border-r border-gray-700 whitespace-nowrap flex-shrink-0"
        >
          <span>Quick Actions</span>
          <Icon name="i-lucide-x" class="w-4 h-4" />
        </button>

        <!-- Action Icons (right side) -->
        <div class="flex items-center gap-1 bg-white/50 dark:bg-black/50 backdrop-blur-xl px-3 py-2">
          <!-- Create Todo -->
          <button
            @click="handleCreateTodo"
            class="w-12 h-12 rounded-full bg-blue-500/20 hover:bg-blue-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Create Todo"
          >
            <Icon name="i-lucide-check-circle" class="w-5 h-5 text-blue-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              Todo
            </div>
          </button>

          <!-- Create Event -->
          <button
            @click="handleCreateEvent"
            class="w-12 h-12 rounded-full bg-green-500/20 hover:bg-green-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Create Event"
          >
            <Icon name="i-lucide-calendar" class="w-5 h-5 text-green-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              Event
            </div>
          </button>

          <!-- Create News -->
          <button
            @click="handleCreateNews"
            class="w-12 h-12 rounded-full bg-purple-500/20 hover:bg-purple-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Write Article"
          >
            <Icon name="i-lucide-newspaper" class="w-5 h-5 text-purple-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              News
            </div>
          </button>

          <!-- Create Client -->
          <button
            @click="handleCreateClient"
            class="w-12 h-12 rounded-full bg-orange-500/20 hover:bg-orange-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Add Client"
          >
            <Icon name="i-lucide-user-plus" class="w-5 h-5 text-orange-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              Client
            </div>
          </button>

          <!-- Create Ticket -->
          <button
            @click="handleCreateTicket"
            class="w-12 h-12 rounded-full bg-red-500/20 hover:bg-red-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Create Ticket"
          >
            <Icon name="i-lucide-ticket" class="w-5 h-5 text-red-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              Ticket
            </div>
          </button>

          <!-- Browse Academy -->
          <button
            @click="handleBrowseAcademy"
            class="w-12 h-12 rounded-full bg-teal-500/20 hover:bg-teal-500 flex items-center justify-center transition-all duration-200 group relative flex-shrink-0"
            title="Browse Academy"
          >
            <Icon name="i-lucide-graduation-cap" class="w-5 h-5 text-teal-400 group-hover:text-white transition-colors" />
            <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 bg-black/90 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              Academy
            </div>
          </button>
        </div>
      </template>
    </div>
  </div>

  <!-- Backdrop -->
  <Transition name="fade">
    <div
      v-if="isOpen"
      class="fixed inset-0 bg-white/30 dark:bg-black/20 backdrop-blur-sm z-10"
      @click="closeActions"
    ></div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

// Emits
const emit = defineEmits<{
  close: []
  createTodo: []
  createEvent: []
  createNews: []
  createClient: []
  createTicket: []
  browseAcademy: []
}>()

// Local state - simplified to only use internal state
const isOpen = ref(false)

// Router for navigation
const router = useRouter()

// Methods
const openActions = () => {
  isOpen.value = true
}

const closeActions = () => {
  isOpen.value = false
  emit('close')
}

// Quick action handlers
const handleCreateTodo = () => {
  emit('createTodo')
  closeActions()
}

const handleCreateEvent = () => {
  router.push('/ascent/calendar?create=event')
  closeActions()
}

const handleCreateNews = () => {
  router.push('/academy/news/create')
  closeActions()
}

const handleCreateClient = () => {
  emit('createClient')
  closeActions()
}

const handleCreateTicket = () => {
  emit('createTicket')
  closeActions()
}

const handleBrowseAcademy = () => {
  router.push('/academy/courses')
  closeActions()
}

// Keyboard shortcut handling
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeActions()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
/* Backdrop fade */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
