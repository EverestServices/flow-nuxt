<template>
  <!-- Backdrop -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black/20 z-40"
    @click="closeModal"
  ></div>

  <!-- Right-sliding client detail modal -->
  <Transition name="slide-client-modal">
    <div
      v-if="isOpen && client"
      class="fixed bottom-2 right-2 top-2 w-96 bg-black/30 dark:bg-black/40 backdrop-blur-2xl backdrop-saturate-180 border border-white/10 dark:border-white/5 rounded-2xl flex flex-col shadow-2xl z-50"
      style="backdrop-filter: blur(20px) saturate(180%);"
    >
      <!-- Header -->
      <div class="p-6 pb-4 border-b border-white/10 dark:border-white/5">
        <div class="flex items-center justify-between">
          <h3 class="text-white font-semibold text-lg drop-shadow-sm">Client Details</h3>
          <button
            @click="closeModal"
            class="text-white/70 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 space-y-6">
        <!-- Basic Info -->
        <div class="space-y-4">
          <div>
            <label class="text-white/60 text-sm font-medium">Company Name</label>
            <p class="text-white text-lg font-semibold">{{ client.name }}</p>
          </div>

          <div v-if="client.contact_person">
            <label class="text-white/60 text-sm font-medium">Contact Person</label>
            <p class="text-white">{{ client.contact_person }}</p>
          </div>

          <div v-if="client.email">
            <label class="text-white/60 text-sm font-medium">Email</label>
            <p class="text-white">
              <a :href="`mailto:${client.email}`" class="text-blue-300 hover:text-blue-200 transition-colors">
                {{ client.email }}
              </a>
            </p>
          </div>

          <div v-if="client.phone">
            <label class="text-white/60 text-sm font-medium">Phone</label>
            <p class="text-white">
              <a :href="`tel:${client.phone}`" class="text-blue-300 hover:text-blue-200 transition-colors">
                {{ client.phone }}
              </a>
            </p>
          </div>

          <div v-if="client.address">
            <label class="text-white/60 text-sm font-medium">Address</label>
            <p class="text-white">{{ client.address }}</p>
          </div>

          <div>
            <label class="text-white/60 text-sm font-medium">Status</label>
            <span
              class="inline-block px-3 py-1 rounded-full text-xs font-semibold"
              :class="getStatusClass(client.status)"
            >
              {{ formatStatus(client.status) }}
            </span>
          </div>
        </div>

        <!-- Notes -->
        <div v-if="client.notes" class="space-y-2">
          <label class="text-white/60 text-sm font-medium">Notes</label>
          <div class="bg-white/10 rounded-lg p-4">
            <p class="text-white/90 text-sm leading-relaxed">{{ client.notes }}</p>
          </div>
        </div>

        <!-- Client Tickets -->
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <label class="text-white/60 text-sm font-medium">Recent Tickets</label>
            <span class="text-white/40 text-xs">{{ clientTickets.length }} total</span>
          </div>

          <div v-if="clientTickets.length === 0" class="bg-white/5 rounded-lg p-4 text-center">
            <p class="text-white/60 text-sm">No tickets found for this client</p>
          </div>

          <div v-else class="space-y-2">
            <div
              v-for="ticket in clientTickets.slice(0, 5)"
              :key="ticket.id"
              class="bg-white/10 hover:bg-white/15 rounded-lg p-3 cursor-pointer transition-all duration-200"
              @click="viewTicket(ticket)"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1 min-w-0">
                  <p class="text-white font-medium text-sm truncate">{{ ticket.title }}</p>
                  <p class="text-white/60 text-xs">{{ ticket.ticket_number }}</p>
                </div>
                <div class="flex flex-col items-end space-y-1">
                  <span
                    class="px-2 py-1 rounded text-xs font-semibold"
                    :class="getTicketStatusClass(ticket.status)"
                  >
                    {{ formatTicketStatus(ticket.status) }}
                  </span>
                  <span class="text-white/40 text-xs">
                    {{ formatDate(ticket.created_at) }}
                  </span>
                </div>
              </div>
            </div>

            <div v-if="clientTickets.length > 5" class="text-center">
              <button
                @click="viewAllTickets"
                class="text-blue-300 hover:text-blue-200 text-sm transition-colors"
              >
                View all {{ clientTickets.length }} tickets →
              </button>
            </div>
          </div>
        </div>

        <!-- Meta Info -->
        <div class="space-y-2 pt-4 border-t border-white/10">
          <div class="flex justify-between text-xs">
            <span class="text-white/60">Created</span>
            <span class="text-white/80">{{ formatDate(client.created_at) }}</span>
          </div>
          <div class="flex justify-between text-xs">
            <span class="text-white/60">Last Updated</span>
            <span class="text-white/80">{{ formatDate(client.updated_at) }}</span>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="p-6 pt-4 border-t border-white/10 dark:border-white/5">
        <div class="flex gap-3">
          <button
            @click="editClient"
            class="flex-1 bg-white/15 hover:bg-white/20 text-white px-4 py-2 rounded-lg transition-colors text-sm font-medium"
          >
            Edit Client
          </button>
          <button
            @click="createTicket"
            class="flex-1 bg-blue-500/80 hover:bg-blue-500 text-white px-4 py-2 rounded-lg transition-colors text-sm font-medium"
          >
            New Ticket
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { Client } from '~/composables/useClients'
import type { Ticket } from '~/composables/useTickets'

// Props
interface Props {
  client?: Client | null
  isOpen?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  client: null,
  isOpen: false
})

// Emits
const emit = defineEmits<{
  close: []
  editClient: [client: Client]
  createTicket: [client: Client]
  viewTicket: [ticket: Ticket]
}>()

// Composables
const { tickets, fetchTickets } = useTickets()

// Computed
const clientTickets = computed(() => {
  if (!props.client) return []

  // Filter tickets by client_id - handle both string and UUID comparisons
  return tickets.value.filter(ticket => {
    const ticketClientId = ticket.client_id?.toString()
    const clientId = props.client?.id?.toString()
    return ticketClientId === clientId
  })
})

// Watch for client changes and fetch tickets
watch(() => props.client, async (newClient) => {
  if (newClient && props.isOpen) {
    // Fetch all tickets to ensure we have the latest data
    await fetchTickets()
  }
}, { immediate: true })

// Also watch for modal opening
watch(() => props.isOpen, async (isOpen) => {
  if (isOpen && props.client) {
    // Fetch tickets when modal opens
    await fetchTickets()
  }
})

// Methods
const closeModal = () => {
  emit('close')
}

const editClient = () => {
  if (props.client) {
    emit('editClient', props.client)
  }
}

const createTicket = () => {
  if (props.client) {
    emit('createTicket', props.client)
  }
}

const viewTicket = (ticket: Ticket) => {
  emit('viewTicket', ticket)
}

const viewAllTickets = () => {
  // Navigate to tickets page with client filter
  navigateTo(`/ascent/tickets?client=${props.client?.id}`)
}

const formatDate = (dateString: string) => {
  try {
    return format(new Date(dateString), 'MMM d, yyyy')
  } catch (e) {
    return dateString
  }
}

const formatStatus = (status: string) => {
  return status.charAt(0).toUpperCase() + status.slice(1)
}

const formatTicketStatus = (status: string) => {
  return status.replace('_', ' ').split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

const getStatusClass = (status: string) => {
  const classes = {
    active: 'bg-green-500/80 text-white',
    prospect: 'bg-blue-500/80 text-white',
    inactive: 'bg-yellow-500/80 text-white',
    archived: 'bg-gray-500/80 text-white'
  }
  return classes[status] || 'bg-gray-500/80 text-white'
}

const getTicketStatusClass = (status: string) => {
  const classes = {
    open: 'bg-blue-500/80 text-white',
    in_progress: 'bg-orange-500/80 text-white',
    resolved: 'bg-green-500/80 text-white',
    closed: 'bg-gray-500/80 text-white'
  }
  return classes[status] || 'bg-gray-500/80 text-white'
}
</script>

<style scoped>
/* Right-sliding modal animation */
.slide-client-modal-enter-active,
.slide-client-modal-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-client-modal-enter-from,
.slide-client-modal-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.slide-client-modal-enter-to,
.slide-client-modal-leave-from {
  transform: translateX(0);
  opacity: 1;
}
</style>