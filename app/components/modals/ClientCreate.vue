<template>
  <div>
    <UIBox @click="isOpen = true" class="px-4 py-4 cursor-pointer text-sm text-white" background="bg-green-500">
      Create Client
    </UIBox>

    <div v-if="isOpen" class="modal">
      <div class="modal-content">
        <h3>{{ editingClient ? 'Edit Client' : 'Create New Client' }}</h3>

        <form @submit.prevent="handleSubmit">
          <div>
            <label>Name*</label>
            <input
              v-model="formState.name"
              placeholder="Enter client name"
              required
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <div>
            <label>Email</label>
            <input
              v-model="formState.email"
              type="email"
              placeholder="Enter email address"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <div>
            <label>Phone</label>
            <input
              v-model="formState.phone"
              type="tel"
              placeholder="Enter phone number"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <div>
            <label>Contact Person</label>
            <input
              v-model="formState.contact_person"
              placeholder="Enter primary contact person"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            />
          </div>

          <div>
            <label>Address</label>
            <textarea
              v-model="formState.address"
              placeholder="Enter full address"
              rows="3"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px; resize: vertical;"
            ></textarea>
          </div>

          <div>
            <label>Status</label>
            <select
              v-model="formState.status"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px;"
            >
              <option value="active">Active</option>
              <option value="prospect">Prospect</option>
              <option value="inactive">Inactive</option>
              <option value="archived">Archived</option>
            </select>
          </div>

          <div>
            <label>Notes</label>
            <textarea
              v-model="formState.notes"
              placeholder="Enter any additional notes"
              rows="4"
              style="width: 100%; padding: 8px; margin-top: 4px; margin-bottom: 16px; resize: vertical;"
            ></textarea>
          </div>

          <div class="form-actions">
            <button
              type="button"
              @click="closeModal"
              style="padding: 8px 16px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 8px;"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="loading"
              style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;"
            >
              {{ loading ? 'Saving...' : (editingClient ? 'Update Client' : 'Create Client') }}
            </button>
          </div>
        </form>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Client, CreateClientData, UpdateClientData } from '~/composables/useClients'

// Props
interface Props {
  editingClient?: Client | null
}

const props = defineProps<Props>()

// Emits
const emit = defineEmits<{
  created: []
  updated: []
}>()

// Composables
const { createClient, updateClient } = useClients()

// State
const isOpen = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)

// Form state
const initialFormState = (): CreateClientData => ({
  name: '',
  email: '',
  phone: '',
  contact_person: '',
  address: '',
  notes: '',
  status: 'active'
})

const formState = ref<CreateClientData>(initialFormState())

// Watch for editing client changes
watch(() => props.editingClient, (newClient) => {
  if (newClient) {
    isOpen.value = true
    formState.value = {
      name: newClient.name,
      email: newClient.email || '',
      phone: newClient.phone || '',
      contact_person: newClient.contact_person || '',
      address: newClient.address || '',
      notes: newClient.notes || '',
      status: newClient.status
    }
  }
}, { immediate: true })

// Methods
const closeModal = () => {
  isOpen.value = false
  error.value = null
  formState.value = initialFormState()
}

const handleSubmit = async () => {
  loading.value = true
  error.value = null

  try {
    if (props.editingClient) {
      // Update existing client
      const updateData: UpdateClientData = {
        id: props.editingClient.id,
        ...formState.value
      }

      const result = await updateClient(updateData)

      if (result) {
        emit('updated')
        closeModal()
      } else {
        error.value = 'Failed to update client. Please try again.'
      }
    } else {
      // Create new client
      const result = await createClient(formState.value)

      if (result) {
        emit('created')
        closeModal()
      } else {
        error.value = 'Failed to create client. Please try again.'
      }
    }
  } catch (err) {
    console.error('Error submitting client form:', err)
    error.value = 'An unexpected error occurred. Please try again.'
  } finally {
    loading.value = false
  }
}

// Close modal when editing client becomes null
watch(() => props.editingClient, (newClient) => {
  if (newClient === null && isOpen.value) {
    closeModal()
  }
})
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
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.dark .modal-content {
  background: rgb(17, 24, 39);
}

.modal-content h3 {
  margin: 0 0 20px 0;
  color: #333;
}

.dark .modal-content h3 {
  color: white;
}

.modal-content label {
  display: block;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.dark .modal-content label {
  color: rgb(209, 213, 219);
}

.modal-content input,
.modal-content select,
.modal-content textarea {
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background: white;
  color: #333;
}

.dark .modal-content input,
.dark .modal-content select,
.dark .modal-content textarea {
  background: rgb(31, 41, 55);
  color: white;
  border-color: rgb(75, 85, 99);
}

.modal-content input:focus,
.modal-content select:focus,
.modal-content textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.dark .modal-content input:focus,
.dark .modal-content select:focus,
.dark .modal-content textarea:focus {
  border-color: rgb(96, 165, 250);
  box-shadow: 0 0 0 2px rgba(96, 165, 250, 0.25);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.form-actions button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  color: #dc3545;
  margin-top: 16px;
  padding: 8px;
  background: #ffebee;
  border-radius: 4px;
}

.dark .error-message {
  color: rgb(248, 113, 113);
  background: rgba(248, 113, 113, 0.1);
}
</style>