<template>
  <div>
    <!-- Header -->
    <div class="bg-gray-50 p-8 flex items-center gap-x-4 pr-24 bg-gradient-to-r from-[#667eea] to-[#764ba2]">
      <div class="bg-gradient-to-r from-[#a6c0fe] to-[#f68084] aspect-square p-4 rounded-md flex items-center justify-center">
        <div class="text-white h-8 w-8">👥</div>
      </div>
      <div class="grow text-white">
        <h1>Clients</h1>
        <p>Manage your client relationships and information.</p>
      </div>

      <ModalsClientCreate @created="handleClientCreated" @updated="handleClientUpdated" />
    </div>

    <!-- Statistics -->
    <div style="padding: 20px 0;">
      <p>Total: {{ clients?.length || 0 }}</p>
      <p>Active: {{ activeClients?.length || 0 }}</p>
      <p>Prospects: {{ prospectClients?.length || 0 }}</p>
      <p>Inactive: {{ inactiveClients?.length || 0 }}</p>
    </div>

    <!-- Search and Filters -->
    <div style="margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
      <h3>Search & Filters</h3>

      <!-- Search -->
      <div style="margin-bottom: 16px;">
        <label>Search:</label>
        <input
          v-model="searchQuery"
          placeholder="Search clients by name, email, or contact person..."
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
      Loading clients...
    </div>

    <!-- Error State -->
    <div v-else-if="error" style="color: red; padding: 20px; background: #ffebee; border-radius: 4px; margin: 20px 0;">
      Error: {{ error }}
      <button @click="refreshClients" style="margin-left: 16px; padding: 8px 16px;">Try Again</button>
    </div>

    <!-- Empty State -->
    <div v-else-if="!filteredClients || filteredClients.length === 0" style="text-align: center; padding: 40px; color: #666;">
      <div>👥</div>
      <p>No clients found</p>
      <p v-if="hasActiveFilters" style="font-size: 14px;">Try adjusting your filters or search terms</p>
      <p v-else style="font-size: 14px;">Create your first client to get started</p>
    </div>

    <!-- Clients List -->
    <div v-else style="margin: 20px 0;">
      <div style="margin-bottom: 16px;">
        <small>Showing {{ filteredClients.length }} of {{ clients.length }} clients</small>
      </div>

      <!-- Clients Table -->
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; border: 1px solid #ddd;">
          <thead style="background: #f8f9fa;">
            <tr>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Name</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Email</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Phone</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Contact Person</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Status</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Created</th>
              <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="client in filteredClients"
              :key="client.id"
              style="border-bottom: 1px solid #ddd;"
              @click="viewClient(client)"
              class="client-row"
            >
              <td style="padding: 12px; border: 1px solid #ddd;">
                <strong>{{ client.name }}</strong>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ client.email || '-' }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ client.phone || '-' }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ client.contact_person || '-' }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <span :style="getStatusStyle(client.status)">
                  {{ formatStatus(client.status) }}
                </span>
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                {{ formatDate(client.created_at) }}
              </td>
              <td style="padding: 12px; border: 1px solid #ddd;">
                <button
                  @click.stop="editClient(client)"
                  style="margin-right: 8px; padding: 4px 8px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;"
                >
                  Edit
                </button>
                <button
                  @click.stop="deleteClient(client)"
                  style="margin-right: 8px; padding: 4px 8px; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;"
                >
                  Delete
                </button>
                <button
                  @click.stop="createTicketForClient(client)"
                  style="padding: 4px 8px; background: #17a2b8; color: white; border: none; border-radius: 4px; cursor: pointer;"
                >
                  New Ticket
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

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
  title: 'Clients - EverestFlow'
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
const setStatusFilter = (status: string) => {
  currentStatusFilter.value = status
}

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

// Formatting functions
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

const getStatusStyle = (status: string) => {
  const styles = {
    active: { background: '#e8f5e8', color: '#388e3c', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    prospect: { background: '#e3f2fd', color: '#1976d2', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    inactive: { background: '#fff3e0', color: '#f57c00', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' },
    archived: { background: '#f3e5f5', color: '#7b1fa2', padding: '4px 8px', borderRadius: '12px', fontSize: '12px' }
  }
  return styles[status] || {}
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
.client-row {
  cursor: pointer;
  transition: background-color 0.2s;
}

.client-row:hover {
  background-color: #f8f9fa;
}
</style>