<template>
  <!-- Backdrop with blur -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-white/20 backdrop-blur-sm z-40"
    @click="closeModal"
  ></div>

  <!-- Quick Actions Modal -->
  <Transition name="quick-actions-modal">
    <div
      v-if="isOpen"
      class="fixed inset-0 flex items-center justify-center z-50 p-4"
    >
      <div class="bg-white/60 backdrop-blur-xl border border-gray-200 rounded-2xl shadow-2xl max-w-2xl w-full">
        <!-- Header -->
        <div class="p-6 pb-4 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h3 class="text-black font-semibold text-xl">Quick Actions</h3>
            <button
              @click="closeModal"
              class="text-gray-400 hover:text-gray-600 transition-colors p-1"
            >
              <Icon name="uil:times" class="w-5 h-5" />
            </button>
          </div>
          <p class="text-gray-600 text-sm mt-1">Create new content quickly</p>
        </div>

        <!-- Actions Grid -->
        <div class="p-6 gap-3 grid grid-cols-2">
          <!-- Create Todo -->
          <button
            @click="handleCreateTodo"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-blue-50 to-blue-100 hover:from-blue-100 hover:to-blue-200 rounded-xl border border-blue-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-blue-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:check-circle" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Create Todo</h4>
              <p class="text-sm text-gray-600">Add a new task to your list</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>

          <!-- Create Calendar Event -->
          <button
            @click="handleCreateEvent"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-green-50 to-green-100 hover:from-green-100 hover:to-green-200 rounded-xl border border-green-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-green-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:calendar-alt" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Create Event</h4>
              <p class="text-sm text-gray-600">Schedule a new calendar event</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>

          <!-- Create News Article -->
          <button
            @click="handleCreateNews"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-purple-50 to-purple-100 hover:from-purple-100 hover:to-purple-200 rounded-xl border border-purple-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-purple-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:newspaper" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Write Article</h4>
              <p class="text-sm text-gray-600">Create a new news article</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>

          <!-- Create Client -->
          <button
            @click="handleCreateClient"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-orange-50 to-orange-100 hover:from-orange-100 hover:to-orange-200 rounded-xl border border-orange-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:user-plus" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Add Client</h4>
              <p class="text-sm text-gray-600">Register a new client</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>

          <!-- Create Ticket -->
          <button
            @click="handleCreateTicket"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-red-50 to-red-100 hover:from-red-100 hover:to-red-200 rounded-xl border border-red-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-red-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:ticket" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Create Ticket</h4>
              <p class="text-sm text-gray-600">Open a new support ticket</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>

          <!-- Browse Academy -->
          <button
            @click="handleBrowseAcademy"
            class="w-full flex items-center gap-4 p-4 text-left bg-gradient-to-r from-teal-50 to-teal-100 hover:from-teal-100 hover:to-teal-200 rounded-xl border border-teal-200 transition-all duration-200 hover:shadow-md group"
          >
            <div class="w-12 h-12 bg-teal-500 rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
              <Icon name="uil:graduation-cap" class="w-6 h-6 text-white" />
            </div>
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900">Browse Academy</h4>
              <p class="text-sm text-gray-600">Explore courses and learning</p>
            </div>
            <Icon name="uil:arrow-right" class="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors" />
          </button>
        </div>

        <!-- Footer -->
        <div class="p-6 pt-4 border-t border-gray-200 bg-gray-50/50 rounded-b-2xl">
          <p class="text-xs text-gray-500 text-center">Press <kbd class="px-1.5 py-0.5 bg-gray-200 rounded text-xs">Esc</kbd> to close</p>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

// Props
interface Props {
  isOpen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isOpen: false
})

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

// Router for navigation
const router = useRouter()

// Methods
const closeModal = () => {
  emit('close')
}

// Quick action handlers
const handleCreateTodo = () => {
  emit('createTodo')
  closeModal()
}

const handleCreateEvent = () => {
  // Navigate to calendar with create mode
  router.push('/ascent/calendar?create=event')
  closeModal()
}

const handleCreateNews = () => {
  // Navigate to news create page
  router.push('/academy/news/create')
  closeModal()
}

const handleCreateClient = () => {
  // Emit event to open client create modal
  emit('createClient')
  closeModal()
}

const handleCreateTicket = () => {
  // Emit event to open ticket create modal
  emit('createTicket')
  closeModal()
}

const handleBrowseAcademy = () => {
  // Navigate to academy
  router.push('/academy/courses')
  closeModal()
}

// Keyboard shortcut handling
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && props.isOpen) {
    closeModal()
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
/* Modal animations */
.quick-actions-modal-enter-active,
.quick-actions-modal-leave-active {
  transition: all 0.3s ease;
}

.quick-actions-modal-enter-from,
.quick-actions-modal-leave-to {
  opacity: 0;
  transform: scale(0.95) translateY(-20px);
}

/* Backdrop blur effect */
.backdrop-blur-sm {
  backdrop-filter: blur(4px);
}

.backdrop-blur-xl {
  backdrop-filter: blur(24px);
}

/* Keyboard shortcut styling */
kbd {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
}
</style>