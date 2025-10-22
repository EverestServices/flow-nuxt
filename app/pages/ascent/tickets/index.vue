<template>
  <div class="flex flex-col space-y-6">
    <!-- Header Section -->
    <div class="flex justify-between py-4">
      <div class="flex items-center gap-4">
        <h1 class="text-2xl font-semibold text-gray-900 dark:text-white outfit">Tickets</h1>
      </div>

      <UIBox class="flex px-4 py-2 gap-2">
        <UISelect
          v-model="currentStatusFilter"
          :options="statusSelectOptions"
          size="sm"
        />
        <UISelect
          v-model="currentPriorityFilter"
          :options="prioritySelectOptions"
          size="sm"
        />
        <UISelect
          v-model="currentCategoryFilter"
          :options="categorySelectOptions"
          size="sm"
        />
      </UIBox>

      <div class="w-32 mr-16 flex items-center justify-end">
        <ModalsTicketCreate @created="handleTicketCreated" @updated="handleTicketUpdated" />
      </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Total</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ tickets?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-ticket" class="w-6 h-6 text-blue-600 dark:text-blue-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Open</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ openTickets?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-circle-dot" class="w-6 h-6 text-blue-600 dark:text-blue-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">In Progress</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ inProgressTickets?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-yellow-100 dark:bg-yellow-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-clock" class="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Resolved</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ resolvedTickets?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-check-circle" class="w-6 h-6 text-green-600 dark:text-green-400" />
          </div>
        </div>
      </UIBox>
    </div>

    <!-- Search -->
    <UIBox class="p-6">
      <UIInput
        v-model="searchQuery"
        placeholder="Search tickets by title, description, client, or ticket number..."
        clearable
      >
        <template #prefix>
          <Icon name="i-lucide-search" class="w-5 h-5" />
        </template>
      </UIInput>
    </UIBox>

    <!-- Loading State -->
    <UIBox v-if="loading" class="p-12">
      <div class="flex flex-col items-center justify-center space-y-4">
        <div class="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
        <p class="text-gray-600 dark:text-gray-400">Loading tickets...</p>
      </div>
    </UIBox>

    <!-- Error State -->
    <UIAlert v-else-if="error" variant="danger">
      <strong>Error loading tickets</strong><br />
      {{ error }}
      <template #actions>
        <UIButtonEnhanced variant="danger" size="sm" @click="refreshTickets" class="mt-3">
          Try Again
        </UIButtonEnhanced>
      </template>
    </UIAlert>

    <!-- Empty State -->
    <UIBox v-else-if="!filteredTickets || filteredTickets.length === 0" class="p-12">
      <div class="flex flex-col items-center justify-center space-y-4 text-center">
        <div class="w-24 h-24 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center">
          <Icon name="i-lucide-ticket" class="w-12 h-12 text-gray-400" />
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">No tickets found</h3>
          <p v-if="hasActiveFilters" class="text-gray-600 dark:text-gray-400">
            Try adjusting your filters or search terms
          </p>
          <p v-else class="text-gray-600 dark:text-gray-400">
            Create your first ticket to get started
          </p>
        </div>
      </div>
    </UIBox>

    <!-- Tickets List -->
    <UIBox v-else class="p-6">
      <div class="flex justify-between items-center mb-6">
        <UIH2>
          Tickets
          <span class="text-sm font-normal text-gray-500 dark:text-gray-400 ml-2">
            (Showing {{ filteredTickets.length }} of {{ tickets.length }})
          </span>
        </UIH2>
      </div>

      <!-- Tickets Table -->
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-gray-200 dark:border-gray-700">
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Ticket #
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Title
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Client
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Status
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Priority
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Category
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Created
              </th>
              <th class="px-4 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="ticket in filteredTickets"
              :key="ticket.id"
              @click="viewTicket(ticket)"
              class="cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <td class="px-4 py-4">
                <span class="font-mono text-sm font-semibold text-blue-600 dark:text-blue-400">
                  {{ ticket.ticket_number }}
                </span>
              </td>
              <td class="px-4 py-4">
                <div class="font-semibold text-gray-900 dark:text-white">{{ ticket.title }}</div>
                <div v-if="ticket.description" class="text-sm text-gray-600 dark:text-gray-400 line-clamp-1">
                  {{ ticket.description }}
                </div>
              </td>
              <td class="px-4 py-4">
                <button
                  @click.stop="viewClient(ticket)"
                  class="text-blue-600 dark:text-blue-400 hover:underline text-sm font-medium"
                >
                  {{ ticket.client_name }}
                </button>
              </td>
              <td class="px-4 py-4">
                <span :class="getStatusClasses(ticket.status)">
                  {{ formatStatus(ticket.status) }}
                </span>
              </td>
              <td class="px-4 py-4">
                <span :class="getPriorityClasses(ticket.priority)">
                  {{ formatPriority(ticket.priority) }}
                </span>
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ formatCategory(ticket.category) }}
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ formatDate(ticket.created_at) }}
              </td>
              <td class="px-4 py-4">
                <div class="flex items-center justify-end gap-2">
                  <UIButtonEnhanced
                    variant="ghost"
                    size="sm"
                    @click.stop="editTicket(ticket)"
                  >
                    <template #icon>
                      <Icon name="i-lucide-edit" class="w-4 h-4" />
                    </template>
                  </UIButtonEnhanced>
                  <UIButtonEnhanced
                    variant="ghost"
                    size="sm"
                    @click.stop="deleteTicket(ticket.id)"
                  >
                    <template #icon>
                      <Icon name="i-lucide-trash-2" class="w-4 h-4" />
                    </template>
                  </UIButtonEnhanced>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </UIBox>

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

// Page metadata
useHead({
  title: 'Tickets - EverestFlow'
})

// Composables
const {
  tickets,
  loading,
  error,
  fetchTickets,
  deleteTicket: removeTicket,
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

// UISelect format options
const statusSelectOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'Open', value: 'open' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Closed', value: 'closed' }
]

const prioritySelectOptions = [
  { label: 'All Priorities', value: 'all' },
  { label: 'Normal', value: 'normal' },
  { label: 'High', value: 'high' },
  { label: 'Urgent', value: 'urgent' }
]

const categorySelectOptions = [
  { label: 'All Categories', value: 'all' },
  { label: 'Technical', value: 'technical' },
  { label: 'Contract', value: 'contract' },
  { label: 'Billing', value: 'billing' },
  { label: 'Maintenance', value: 'maintenance' }
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

const deleteTicket = async (ticketId: string) => {
  if (confirm('Are you sure you want to delete this ticket?')) {
    const success = await removeTicket(ticketId)
    if (success) {
      console.log('Ticket deleted successfully')
    }
  }
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
    return format(new Date(dateString), 'MMM d, yyyy')
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

const getStatusClasses = (status: string): string => {
  const classes = {
    open: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400',
    in_progress: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-400',
    resolved: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400',
    closed: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-400'
  }
  return classes[status] || classes.open
}

const getPriorityClasses = (priority: string): string => {
  const classes = {
    normal: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-400',
    high: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-orange-100 dark:bg-orange-900/30 text-orange-800 dark:text-orange-400',
    urgent: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-400'
  }
  return classes[priority] || classes.normal
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
.outfit {
  font-family: 'Outfit', sans-serif;
}

.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
