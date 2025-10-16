<template>
  <div>
    <button @click="isOpen = true">
      Create Ticket
    </button>

    <div v-if="isOpen" class="modal">
      <div class="modal-content">
        <h3>{{ editingTicket ? 'Edit Ticket' : 'Create New Ticket' }}</h3>

        <form @submit.prevent="handleSubmit">
          <div>
            <label>Title*</label>
            <input
              v-model="formState.title"
              placeholder="Enter ticket title"
              required
            />
          </div>

          <div>
            <label>Client*</label>
            <div class="autocomplete-container">
              <input
                v-model="clientSearch"
                @input="searchForClients"
                @focus="showClientDropdown = true"
                @blur="hideClientDropdown"
                placeholder="Search for client..."
                required
              />
              <div v-if="showClientDropdown && filteredClients.length > 0" class="autocomplete-dropdown">
                <div
                  v-for="client in filteredClients"
                  :key="client.id"
                  @mousedown="selectClient(client)"
                  class="autocomplete-item"
                >
                  <div>
                    <strong>{{ client.name }}</strong>
                    <div class="client-contact">{{ client.contact_person }} - {{ client.email }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div>
            <label>Category</label>
            <select v-model="formState.category">
              <option value="technical">Technical</option>
              <option value="contract">Contract</option>
              <option value="billing">Billing</option>
              <option value="maintenance">Maintenance</option>
            </select>
          </div>

          <div>
            <label>Priority</label>
            <select v-model="formState.priority">
              <option value="normal">Normal</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>

          <div>
            <label>Description</label>
            <textarea
              v-model="formState.description"
              placeholder="Describe the ticket details..."
              rows="4"
            ></textarea>
          </div>

          <div>
            <button type="button" @click="closeModal">Cancel</button>
            <button type="submit" :disabled="!formState.title?.trim() || !formState.client_name?.trim()">
              {{ editingTicket ? 'Update' : 'Create' }} Ticket
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { CreateTicket, Ticket, Client } from '~/composables/useTickets'

// Props
interface Props {
  editingTicket?: Ticket | null
}

const props = withDefaults(defineProps<Props>(), {
  editingTicket: null
})

// Emits
const emit = defineEmits<{
  created: [ticket: Ticket]
  updated: [ticket: Ticket]
}>()

// Composables
const { createTicket, updateTicket, searchClients } = useTickets()

// State
const isOpen = ref(false)
const submitting = ref(false)
const clientSearch = ref('')
const filteredClients = ref<Client[]>([])
const showClientDropdown = ref(false)

// Form state
const defaultFormState: CreateTicket = {
  title: '',
  description: null,
  client_id: null,
  client_name: '',
  category: 'technical',
  priority: 'normal',
  status: 'open',
  assigned_to: null,
  resolution: null,
  resolved_at: null,
  tags: []
}

const formState = ref<CreateTicket>({ ...defaultFormState })

// Methods
const searchForClients = async () => {
  console.log('searchForClients called with:', clientSearch.value)

  if (clientSearch.value.length < 2) {
    filteredClients.value = []
    return
  }

  try {
    console.log('Calling searchClients with:', clientSearch.value)
    const clients = await searchClients(clientSearch.value)
    console.log('searchClients returned:', clients)
    filteredClients.value = clients
  } catch (error) {
    console.error('Error searching clients:', error)
    filteredClients.value = []
  }
}

const selectClient = (client: Client) => {
  formState.value.client_id = client.id
  formState.value.client_name = client.name
  clientSearch.value = client.name
  showClientDropdown.value = false
}

const hideClientDropdown = () => {
  // Delay hiding to allow click on dropdown items
  setTimeout(() => {
    showClientDropdown.value = false
  }, 200)
}

const resetForm = () => {
  formState.value = { ...defaultFormState }
  clientSearch.value = ''
  filteredClients.value = []
}

const closeModal = () => {
  isOpen.value = false
  resetForm()
}

const handleSubmit = async () => {
  try {
    submitting.value = true

    if (props.editingTicket) {
      // Update existing ticket
      const updated = await updateTicket({
        id: props.editingTicket.id,
        ...formState.value
      })

      if (updated) {
        emit('updated', updated)
        closeModal()
      }
    } else {
      // Create new ticket
      const created = await createTicket(formState.value)

      if (created) {
        emit('created', created)
        closeModal()
      }
    }
  } catch (error) {
    console.error('Error submitting ticket:', error)
  } finally {
    submitting.value = false
  }
}

// Watch for editing ticket changes
watch(
  () => props.editingTicket,
  (ticket) => {
    if (ticket) {
      // Populate form with existing ticket data
      formState.value = {
        title: ticket.title,
        description: ticket.description,
        client_id: ticket.client_id,
        client_name: ticket.client_name,
        category: ticket.category,
        priority: ticket.priority,
        status: ticket.status,
        assigned_to: ticket.assigned_to,
        resolution: ticket.resolution,
        resolved_at: ticket.resolved_at,
        tags: [...(ticket.tags || [])]
      }
      clientSearch.value = ticket.client_name
      isOpen.value = true
    }
  },
  { immediate: true }
)
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 24px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-content h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 600;
}

.modal-content form > div {
  margin-bottom: 16px;
}

.modal-content label {
  display: block;
  margin-bottom: 4px;
  font-weight: 500;
}

.modal-content input,
.modal-content select,
.modal-content textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 14px;
}

.modal-content button {
  padding: 8px 16px;
  margin-right: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
}

.modal-content button[type="submit"] {
  background: #007bff;
  color: white;
  border-color: #007bff;
}

.modal-content button[type="submit"]:disabled {
  background: #ccc;
  border-color: #ccc;
  cursor: not-allowed;
}

.autocomplete-container {
  position: relative;
}

.autocomplete-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #ccc;
  border-top: none;
  border-radius: 0 0 4px 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1001;
}

.autocomplete-item {
  padding: 8px 12px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}

.autocomplete-item:hover {
  background: #f5f5f5;
}

.autocomplete-item:last-child {
  border-bottom: none;
}

.client-contact {
  font-size: 12px;
  color: #666;
  margin-top: 2px;
}
</style>