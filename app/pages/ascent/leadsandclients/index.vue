<template>
  <div class="flex flex-col space-y-6">
    <!-- Header Section -->
    <div class="flex justify-between py-4">
      <div class="flex items-center gap-4">
        <h1 class="text-2xl font-semibold text-gray-900 dark:text-white outfit">Leads & Clients</h1>
      </div>

      <UIBox class="flex px-4 py-2 gap-2">
        <UISelect
          v-model="currentStatusFilter"
          :options="statusSelectOptions"
          size="sm"
        />
      </UIBox>

      <div class="w-32 mr-16 flex items-center justify-end">
        <ModalsClientCreate @created="handleClientCreated" @updated="handleClientUpdated" />
      </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Total</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ clients?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-users" class="w-6 h-6 text-blue-600 dark:text-blue-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Active</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ activeClients?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-check-circle" class="w-6 h-6 text-green-600 dark:text-green-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Prospects</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ prospectClients?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-yellow-100 dark:bg-yellow-900/30 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-star" class="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
          </div>
        </div>
      </UIBox>

      <UIBox class="p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 uppercase tracking-wide">Inactive</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ inactiveClients?.length || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center">
            <Icon name="i-lucide-user-x" class="w-6 h-6 text-gray-600 dark:text-gray-400" />
          </div>
        </div>
      </UIBox>
    </div>

    <!-- Search -->
    <UIBox class="p-6">
      <UIInput
        v-model="searchQuery"
        placeholder="Search clients by name, email, or contact person..."
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
        <p class="text-gray-600 dark:text-gray-400">Loading clients...</p>
      </div>
    </UIBox>

    <!-- Error State -->
    <UIAlert v-else-if="error" variant="danger">
      <strong>Error loading clients</strong><br />
      {{ error }}
      <template #actions>
        <UIButtonEnhanced variant="danger" size="sm" @click="refreshClients" class="mt-3">
          Try Again
        </UIButtonEnhanced>
      </template>
    </UIAlert>

    <!-- Empty State -->
    <UIBox v-else-if="!filteredClients || filteredClients.length === 0" class="p-12">
      <div class="flex flex-col items-center justify-center space-y-4 text-center">
        <div class="w-24 h-24 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center">
          <Icon name="i-lucide-users" class="w-12 h-12 text-gray-400" />
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">No clients found</h3>
          <p v-if="hasActiveFilters" class="text-gray-600 dark:text-gray-400">
            Try adjusting your filters or search terms
          </p>
          <p v-else class="text-gray-600 dark:text-gray-400">
            Create your first client to get started
          </p>
        </div>
      </div>
    </UIBox>

    <!-- Clients List -->
    <UIBox v-else class="p-6">
      <div class="flex justify-between items-center mb-6">
        <UIH2>
          Clients
          <span class="text-sm font-normal text-gray-500 dark:text-gray-400 ml-2">
            (Showing {{ filteredClients.length }} of {{ clients.length }})
          </span>
        </UIH2>
      </div>

      <!-- Clients Table -->
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-gray-200 dark:border-gray-700">
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Name
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Email
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Phone
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Contact Person
              </th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">
                Status
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
              v-for="client in filteredClients"
              :key="client.id"
              @click="viewClient(client)"
              class="cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <td class="px-4 py-4">
                <div class="flex items-center">
                  <div class="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center mr-3">
                    <span class="text-sm font-semibold text-blue-600 dark:text-blue-400">
                      {{ getInitials(client.name) }}
                    </span>
                  </div>
                  <div>
                    <div class="font-semibold text-gray-900 dark:text-white">{{ client.name }}</div>
                  </div>
                </div>
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ client.email || '-' }}
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ client.phone || '-' }}
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ client.contact_person || '-' }}
              </td>
              <td class="px-4 py-4">
                <span :class="getStatusClasses(client.status)">
                  {{ formatStatus(client.status) }}
                </span>
              </td>
              <td class="px-4 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ formatDate(client.created_at) }}
              </td>
              <td class="px-4 py-4">
                <div class="flex items-center justify-end gap-2">
                  <UIButtonEnhanced
                    variant="ghost"
                    size="sm"
                    @click.stop="editClient(client)"
                  >
                    <template #icon>
                      <Icon name="i-lucide-edit" class="w-4 h-4" />
                    </template>
                  </UIButtonEnhanced>
                  <UIButtonEnhanced
                    variant="ghost"
                    size="sm"
                    @click.stop="deleteClient(client)"
                  >
                    <template #icon>
                      <Icon name="i-lucide-trash-2" class="w-4 h-4" />
                    </template>
                  </UIButtonEnhanced>
                  <UIButtonEnhanced
                    variant="primary"
                    size="sm"
                    @click.stop="createTicketForClient(client)"
                  >
                    <template #icon>
                      <Icon name="i-lucide-ticket" class="w-4 h-4" />
                    </template>
                    Ticket
                  </UIButtonEnhanced>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </UIBox>

    <!-- Edit Modal -->
    <ModalsClientCreate
      v-if="editingClient"
      :editing-client="editingClient"
      @updated="handleClientUpdated"
    />

    <!-- Client Detail Modal -->
    <ModalsClientDetail
      :client="selectedClient"
      :is-open="showClientModal"
      @close="closeClientModal"
      @edit-client="editClient"
      @create-ticket="createTicketForClient"
    />
  </div>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { Client } from '~/composables/useClients'

// Page metadata
useHead({
  title: 'Leads & Clients - EverestFlow'
})

// Composables
const {
  clients,
  loading,
  error,
  fetchClients,
  deleteClient: removeClient,
  activeClients,
  prospectClients,
  inactiveClients,
  archivedClients
} = useClients()

// State
const editingClient = ref<Client | null>(null)
const selectedClient = ref<Client | null>(null)
const showClientModal = ref(false)
const searchQuery = ref('')
const currentStatusFilter = ref('all')

// Options
const statusOptions = [
  { label: 'All', value: 'all' },
  { label: 'Active', value: 'active' },
  { label: 'Prospect', value: 'prospect' },
  { label: 'Inactive', value: 'inactive' },
  { label: 'Archived', value: 'archived' }
]

// UISelect format options
const statusSelectOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'Active', value: 'active' },
  { label: 'Prospect', value: 'prospect' },
  { label: 'Inactive', value: 'inactive' },
  { label: 'Archived', value: 'archived' }
]

// Computed
const filteredClients = computed(() => {
  let result = clients.value

  // Text search
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(client =>
      client.name.toLowerCase().includes(query) ||
      client.email?.toLowerCase().includes(query) ||
      client.contact_person?.toLowerCase().includes(query) ||
      client.phone?.toLowerCase().includes(query)
    )
  }

  // Status filter
  if (currentStatusFilter.value !== 'all') {
    result = result.filter(client => client.status === currentStatusFilter.value)
  }

  return result
})

const hasActiveFilters = computed(() => {
  return searchQuery.value.trim() !== '' ||
         currentStatusFilter.value !== 'all'
})

// Methods
const clearFilters = () => {
  searchQuery.value = ''
  currentStatusFilter.value = 'all'
}

const refreshClients = () => {
  fetchClients({
    status: currentStatusFilter.value !== 'all' ? currentStatusFilter.value : undefined,
    search: searchQuery.value.trim() || undefined
  })
}

const editClient = (client: Client) => {
  editingClient.value = client
}

const viewClient = (client: Client) => {
  selectedClient.value = client
  showClientModal.value = true
}

const deleteClient = async (client: Client) => {
  if (confirm(`Are you sure you want to delete ${client.name}?`)) {
    const success = await removeClient(client.id)
    if (success) {
      console.log('Client deleted successfully')
    }
  }
}

const closeClientModal = () => {
  showClientModal.value = false
  selectedClient.value = null
}

const createTicketForClient = (client: Client) => {
  // TODO: Implement ticket creation with pre-filled client
  console.log('Create ticket for client:', client)
  navigateTo('/ascent/tickets')
}

const handleClientCreated = () => {
  refreshClients()
}

const handleClientUpdated = () => {
  editingClient.value = null
  refreshClients()
}

// Helper functions
const getInitials = (name: string): string => {
  return name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
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

const getStatusClasses = (status: string): string => {
  const classes = {
    active: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400',
    prospect: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400',
    inactive: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-400',
    archived: 'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-400'
  }
  return classes[status] || classes.active
}

// Lifecycle
onMounted(async () => {
  await fetchClients()
})

// Watch filters and refresh
watch([searchQuery, currentStatusFilter], () => {
  refreshClients()
}, { debounce: 300 })
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
