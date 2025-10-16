<template>
  <div>
    <!-- Header -->
    <div class="bg-gray-50 p-8 flex items-center gap-x-4 pr-24 bg-gradient-to-r from-[#dd3e54] to-[#6be585]">
      <div class="bg-gradient-to-r from-[#a6c0fe] to-[#f68084] aspect-square p-4 rounded-md flex items-center justify-center">
        <div class="text-white h-8 w-8">🎫</div>
      </div>
      <div class="grow text-white">
        <h1>Tickets</h1>
        <p>Manage and track support tickets efficiently.</p>
      </div>

      <ModalsTicketCreate @created="handleTicketCreated" @updated="handleTicketUpdated" />
    </div>

    <!-- Statistics -->
    <div style="padding: 20px 0;">
      <p>Total: {{ tickets?.length || 0 }}</p>
      <p>Open: {{ openTickets?.length || 0 }}</p>
      <p>In Progress: {{ inProgressTickets?.length || 0 }}</p>
      <p>Resolved: {{ resolvedTickets?.length || 0 }}</p>
    </div>

    <!-- Search and Filters -->
    <div style="margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
      <h3>Search & Filters</h3>

      <!-- Search -->
      <div style="margin-bottom: 16px;">
        <label>Search:</label>
        <input
          v-model="searchQuery"
          placeholder="Search tickets by title, description, client, or ticket number..."
          style="width: 100%; padding: 8px; margin-top: 4px;"
        />
      </div>

      <!-- Filters -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;">
        <!-- Status Filter -->
        <div>
          <label>Status:</label>
          <div style="margin-top: 8px;">
            <button
              v-for="status in statusOptions"
              :key="status.value"
              @click="setStatusFilter(status.value)"
              :style="{
                backgroundColor: currentStatusFilter === status.value ? '#007bff' : '#f8f9fa',
                color: currentStatusFilter === status.value ? 'white' : 'black',
                margin: '2px',
                padding: '4px 12px',
                border: '1px solid #ccc',
                borderRadius: '4px',
                cursor: 'pointer'
              }"
            >
              {{ status.label }}
            </button>
          </div>
        </div>

        <!-- Priority Filter -->
        <div>
          <label>Priority:</label>
          <div style="margin-top: 8px;">
            <button
              v-for="priority in priorityOptions"
              :key="priority.value"
              @click="setPriorityFilter(priority.value)"
              :style="{
                backgroundColor: currentPriorityFilter === priority.value ? '#007bff' : '#f8f9fa',
                color: currentPriorityFilter === priority.value ? 'white' : 'black',
                margin: '2px',
                padding: '4px 12px',
                border: '1px solid #ccc',
                borderRadius: '4px',
                cursor: 'pointer'
              }"
            >
              {{ priority.label }}
            </button>
          </div>
        </div>

        <!-- Category Filter -->
        <div>
          <label>Category:</label>
          <select v-model="currentCategoryFilter" style="width: 100%; padding: 8px; margin-top: 4px;">
            <option value="all">All Categories</option>
            <option value="technical">Technical</option>
            <option value="contract">Contract</option>
            <option value="billing">Billing</option>
            <option value="maintenance">Maintenance</option>
          </select>
        </div>
      </div>

      <!-- Clear Filters -->
      <div style="margin-top: 16px;">
        <button @click="clearFilters" style="padding: 8px 16px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer;">
          Clear All Filters
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" style="text-align: center; padding: 40px;">
      Loading tickets...
    </div>

    <!-- Error State -->
    <div v-else-if="error" style="color: red; padding: 20px; background: #ffebee; border-radius: 4px; margin: 20px 0;">
      Error: {{ error }}
      <button @click="refreshTickets" style="margin-left: 16px; padding: 8px 16px;">Try Again</button>
    </div>

    <!-- Empty State -->
    <div v-else-if="!filteredTickets || filteredTickets.length === 0" style="text-align: center; padding: 40px; color: #666;">
      <div>📄</div>
      <p>No tickets found</p>
      <p v-if="hasActiveFilters" style="font-size: 14px;">Try adjusting your filters or search terms</p>
      <p v-else style="font-size: 14px;">Create your first ticket to get started</p>
    </div>

    <!-- Tickets List -->
    <div v-else style="margin: 20px 0;">
      <div style="margin-bottom: 16px;">
        <small>Showing {{ filteredTickets.length }} of {{ tickets.length }} tickets</small>
      </div>

      <!-- Tickets Table -->
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; border: 1px solid #ddd;">
          <thead style="background: #f8f9fa;">
            <tr>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Ticket #</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Title</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Client</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Status</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Priority</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Category</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Created</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="ticket in filteredTickets"
              :key="ticket.id"
              style="border-bottom: 1px solid #ddd;"
              @click="viewTicket(ticket)"
              class="ticket-row"
            >
              <td style="padding: 12px; border: 1px solid #ddd;">
                <strong>{{ ticket.ticket_number }}</strong>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ ticket.title }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <button
                  @click.stop="viewClient(ticket)"
                  style="background: none; border: none; color: #007bff; text-decoration: underline; cursor: pointer;"
                >
                  {{ ticket.client_name }}
                </button>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <span :style="getStatusStyle(ticket.status)">
                  {{ formatStatus(ticket.status) }}
                </span>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <span :style="getPriorityStyle(ticket.priority)">
                  {{ formatPriority(ticket.priority) }}
                </span>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ formatCategory(ticket.category) }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ formatDate(ticket.created_at) }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <button
                  @click.stop="editTicket(ticket)"
                  style="margin-right: 8px; padding: 4px 8px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;"
                >
                  Edit
                </button>
                <button
                  @click.stop="deleteTicket(ticket)"
                  style="padding: 4px 8px; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;"
                >
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Edit Modal -->
    <ModalsTicketCreate
      v-if="editingTicket"
      :editing-ticket="editingTicket"
      @updated="handleTicketUpdated"
    />

    <!-- Client Detail Modal -->
    <ModalsClientDetail
      :client="selectedClient"
      :is-open="showClientModal"
      @close="closeClientModal"
      @edit-client="editClient"
      @create-ticket="createTicketForClient"
      @view-ticket="viewTicket"
    />
  </div>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { Ticket } from '~/composables/useTickets'

// Composables
const {
  tickets,
  loading,
  error,
  fetchTickets,
  deleteTicket,
  openTickets,
  inProgressTickets,
  resolvedTickets,
  fetchClients
} = useTickets()

// State
const editingTicket = ref<Ticket | null>(null)
const selectedClient = ref<any>(null)
const showClientModal = ref(false)
const searchQuery = ref('')
const currentStatusFilter = ref('all')
const currentPriorityFilter = ref('all')
const currentCategoryFilter = ref('all')

// Options
const statusOptions = [
  { label: 'All', value: 'all' },
  { label: 'Open', value: 'open' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Closed', value: 'closed' }
]

const priorityOptions = [
  { label: 'All', value: 'all' },
  { label: 'Normal', value: 'normal' },
  { label: 'High', value: 'high' },
  { label: 'Urgent', value: 'urgent' }
]

// Computed
const filteredTickets = computed(() => {
  let result = tickets.value

  // Text search
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(ticket =>
      ticket.title.toLowerCase().includes(query) ||
      ticket.description?.toLowerCase().includes(query) ||
      ticket.client_name.toLowerCase().includes(query) ||
      ticket.ticket_number.toLowerCase().includes(query)
    )
  }

  // Status filter
  if (currentStatusFilter.value !== 'all') {
    result = result.filter(ticket => ticket.status === currentStatusFilter.value)
  }

  // Priority filter
  if (currentPriorityFilter.value !== 'all') {
    result = result.filter(ticket => ticket.priority === currentPriorityFilter.value)
  }

  // Category filter
  if (currentCategoryFilter.value !== 'all') {
    result = result.filter(ticket => ticket.category === currentCategoryFilter.value)
  }

  return result
})

const hasActiveFilters = computed(() => {
  return searchQuery.value.trim() !== '' ||
         currentStatusFilter.value !== 'all' ||
         currentPriorityFilter.value !== 'all' ||
         currentCategoryFilter.value !== 'all'
})

// Methods
const setStatusFilter = (status: string) => {
  currentStatusFilter.value = status
}

const setPriorityFilter = (priority: string) => {
  currentPriorityFilter.value = priority
}

const clearFilters = () => {
  searchQuery.value = ''
  currentStatusFilter.value = 'all'
  currentPriorityFilter.value = 'all'
  currentCategoryFilter.value = 'all'
}

const refreshTickets = () => {
  fetchTickets({
    status: currentStatusFilter.value !== 'all' ? currentStatusFilter.value : undefined,
    priority: currentPriorityFilter.value !== 'all' ? currentPriorityFilter.value : undefined,
    category: currentCategoryFilter.value !== 'all' ? currentCategoryFilter.value : undefined,
    search: searchQuery.value.trim() || undefined
  })
}

const editTicket = (ticket: Ticket) => {
  editingTicket.value = ticket
}

const viewTicket = (ticket: Ticket) => {
  console.log('View ticket:', ticket)
  // TODO: Implement ticket detail modal
}

const viewClient = async (ticket: Ticket) => {
  try {
    // Fetch the client details
    const clients = await fetchClients()
    const client = clients.find(c => c.id?.toString() === ticket.client_id?.toString())

    if (client) {
      selectedClient.value = client
      showClientModal.value = true
    } else {
      // If client not found, create a basic client object from ticket data
      selectedClient.value = {
        id: ticket.client_id,
        name: ticket.client_name,
        email: null,
        phone: null,
        address: null,
        contact_person: null,
        notes: null,
        status: 'active',
        created_at: ticket.created_at,
        updated_at: ticket.updated_at
      }
      showClientModal.value = true
    }
  } catch (error) {
    console.error('Error fetching client details:', error)
  }
}

const closeClientModal = () => {
  showClientModal.value = false
  selectedClient.value = null
}

const editClient = (client: any) => {
  console.log('Edit client:', client)
  // TODO: Implement client editing
  closeClientModal()
}

const createTicketForClient = (client: any) => {
  console.log('Create ticket for client:', client)
  // TODO: Pre-populate ticket creation modal with client
  closeClientModal()
}

const handleTicketCreated = () => {
  refreshTickets()
}

const handleTicketUpdated = () => {
  editingTicket.value = null
  refreshTickets()
}

// Formatting functions
const formatDate = (dateString: string) => {
  try {
    return format(new Date(dateString), 'MMM d, yyyy HH:mm')
  } catch (e) {
    return dateString
  }
}

const formatStatus = (status: string) => {
  return status.replace('_', ' ').split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

const formatPriority = (priority: string) => {
  return priority.charAt(0).toUpperCase() + priority.slice(1)
}

const formatCategory = (category: string) => {
  return category.charAt(0).toUpperCase() + category.slice(1)
}

const getStatusStyle = (status: string) => {
  const styles = {
    open: { background: '#e3f2fd', color: '#1976d2', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    in_progress: { background: '#fff3e0', color: '#f57c00', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    resolved: { background: '#e8f5e8', color: '#388e3c', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    closed: { background: '#f3e5f5', color: '#7b1fa2', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' }
  }
  return styles[status] || {}
}

const getPriorityStyle = (priority: string) => {
  const styles = {
    normal: { background: '#f5f5f5', color: '#666', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    high: { background: '#fff3e0', color: '#f57c00', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    urgent: { background: '#ffebee', color: '#d32f2f', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' }
  }
  return styles[priority] || {}
}

// Lifecycle
onMounted(async () => {
  await fetchTickets()
})

// Watch filters and refresh
watch([searchQuery, currentStatusFilter, currentPriorityFilter, currentCategoryFilter], () => {
  refreshTickets()
}, { debounce: 300 })
</script>

<style scoped>
.ticket-row {
  cursor: pointer;
  transition: background-color 0.2s;
}

.ticket-row:hover {
  background-color: #f8f9fa;
}
</style>