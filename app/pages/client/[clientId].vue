<template>
  <UDashboardPage>
    <UDashboardPanel grow>
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-12">
        <UIcon name="i-heroicons-arrow-path" class="w-6 h-6 animate-spin text-primary" />
        <span class="ml-2 text-gray-500">Loading...</span>
      </div>

      <!-- Client Not Found -->
      <div v-else-if="!client" class="flex flex-col items-center justify-center py-12">
        <UIcon name="i-heroicons-user-circle" class="w-12 h-12 text-gray-400 mb-3" />
        <p class="text-gray-500">Client not found</p>
      </div>

      <!-- Client Profile -->
      <div v-else class="flex flex-col h-full">
        <ClientHeader
          :client-name="client.name"
          :company-name="client.company"
          @back="handleBack"
          @edit="handleEdit"
        />

        <ClientTabs
          v-model="activeTab"
        />

        <div class="flex-1 overflow-auto p-6">
          <ClientBasicInfoTab v-if="activeTab === 'basicInfo'" :client="clientData" :addresses="addresses" />
          <ClientPlaceholderTab v-else-if="activeTab === 'surveys'" tab-name="Surveys" />
          <ClientPlaceholderTab v-else-if="activeTab === 'contracts'" tab-name="Contracts" />
          <ClientPlaceholderTab v-else-if="activeTab === 'projects'" tab-name="Projects" />
          <ClientPlaceholderTab v-else-if="activeTab === 'events'" tab-name="Events" />
          <ClientPlaceholderTab v-else-if="activeTab === 'emails'" tab-name="Emails" />
          <ClientPlaceholderTab v-else-if="activeTab === 'logs'" tab-name="Logs" />
        </div>
      </div>
    </UDashboardPanel>
  </UDashboardPage>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const supabase = useSupabaseClient()

const clientId = computed(() => route.params.clientId as string)
const from = computed(() => route.query.from as string || 'survey')

const loading = ref(true)
const client = ref<any>(null)
const activeTab = ref('basicInfo')

onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('clients')
      .select('*')
      .eq('id', clientId.value)
      .single()

    if (error) throw error
    client.value = data
  } catch (error) {
    console.error('Error fetching client:', error)
  } finally {
    loading.value = false
  }
})

// Computed client data for BasicInfoTab
const clientData = computed(() => {
  if (!client.value) return null

  return {
    name: client.value.name,
    email: client.value.email || '',
    phone: client.value.phone || '',
    company: client.value.company || '',
    joinDate: new Date(client.value.created_at).toLocaleDateString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }),
    status: client.value.status === 'active' ? 'Active' : 'Inactive',
    statusChangeDate: new Date(client.value.updated_at).toLocaleDateString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }),
    lastContact: new Date(client.value.updated_at).toLocaleDateString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }),
    nextAction: 'Follow up',
    daysInStatus: Math.floor((Date.now() - new Date(client.value.updated_at).getTime()) / (1000 * 60 * 60 * 24)),
    priority: 'High' as const,
    notes: client.value.notes || 'No notes available'
  }
})

// Computed addresses for BasicInfoTab
const addresses = computed(() => {
  if (!client.value) return []

  const parts = [
    client.value.postal_code,
    client.value.city,
    client.value.street,
    client.value.house_number
  ].filter(Boolean)

  if (parts.length === 0) return []

  return [{
    type: 'Primary Address',
    street: parts.join(', '),
    city: '',
    country: ''
  }]
})

const handleBack = () => {
  if (from.value === 'survey') {
    router.push('/survey')
  } else {
    router.back()
  }
}

const handleEdit = () => {
  // TODO: Implement edit functionality
  console.log('Edit client pressed')
}
</script>
