<template>
  <div>
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-24">
      <div class="flex items-center gap-3">
        <Icon name="i-lucide-loader-2" class="w-6 h-6 animate-spin text-blue-500" />
        <span class="text-gray-500 dark:text-gray-400">Loading client data...</span>
      </div>
    </div>

    <!-- Client Not Found -->
    <UIBox v-else-if="!client" class="p-12">
      <div class="flex flex-col items-center justify-center text-center">
        <Icon name="i-lucide-user-x" class="w-16 h-16 text-gray-400 mb-4" />
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Client not found</h3>
        <p class="text-gray-500 dark:text-gray-400 mb-6">The client you're looking for doesn't exist or has been removed.</p>
        <UIButtonEnhanced variant="outline" @click="handleBack">
          <Icon name="i-lucide-arrow-left" class="w-4 h-4 mr-2" />
          Go Back
        </UIButtonEnhanced>
      </div>
    </UIBox>

    <!-- Client Profile -->
    <div v-else>
      <!-- Header -->
      <div class="flex h-24 items-center justify-between">
        <div class="flex items-center gap-4">
          <button
            @click="handleBack"
            class="flex items-center gap-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 transition-colors"
          >
            <Icon name="i-lucide-arrow-left" class="w-5 h-5" />
            <span class="text-sm font-medium">Back</span>
          </button>
          <div class="h-8 w-px bg-gray-300 dark:bg-gray-700"></div>
          <div>
            <h1 class="text-2xl font-light">
              <span class="font-black">{{ client.name }}</span>
            </h1>
            <p v-if="client.company" class="text-sm text-gray-500 dark:text-gray-400">
              {{ client.company }}
            </p>
          </div>
        </div>
        <UIButtonEnhanced variant="primary" size="md" @click="handleEdit">
          <Icon name="i-lucide-pencil" class="w-4 h-4 mr-2" />
          Edit Client
        </UIButtonEnhanced>
      </div>

      <div class="flex flex-col space-y-8">
        <!-- Tabs -->
        <div class="flex gap-2">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="[
              'px-4 py-3 rounded-full text-sm font-medium transition-all duration-200 cursor-pointer',
              activeTab === tab.key
                ? 'bg-blue-500 text-white shadow-lg shadow-blue-500/30'
                : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-black hover:text-white dark:hover:bg-gray-700'
            ]"
            @click="activeTab = tab.key"
          >
            {{ tab.label }}
          </button>
        </div>

        <!-- Tab Content -->
        <div>
          <ClientBasicInfoTab v-if="activeTab === 'basicInfo'" :client="clientData" :addresses="addresses" />
          <ClientPlaceholderTab v-else-if="activeTab === 'surveys'" tab-name="Surveys" />
          <ClientPlaceholderTab v-else-if="activeTab === 'contracts'" tab-name="Contracts" />
          <ClientPlaceholderTab v-else-if="activeTab === 'projects'" tab-name="Projects" />
          <ClientPlaceholderTab v-else-if="activeTab === 'events'" tab-name="Events" />
          <ClientPlaceholderTab v-else-if="activeTab === 'emails'" tab-name="Emails" />
          <ClientPlaceholderTab v-else-if="activeTab === 'logs'" tab-name="Logs" />
        </div>
      </div>
    </div>
  </div>
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

const tabs = [
  { key: 'basicInfo', label: 'Basic Info' },
  { key: 'surveys', label: 'Surveys' },
  { key: 'contracts', label: 'Contracts' },
  { key: 'projects', label: 'Projects' },
  { key: 'events', label: 'Events' },
  { key: 'emails', label: 'Emails' },
  { key: 'logs', label: 'Logs' }
]

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
