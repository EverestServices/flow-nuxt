<template>
  <UDashboardPage>
    <UDashboardPanel grow>
      <UDashboardNavbar
        title="Clients pending survey"
      />

      <!-- Filter Bar -->
      <div class="flex items-center justify-between gap-4 px-6 py-4 border-b border-gray-200 dark:border-gray-800">
        <!-- Left: Date Filter Buttons -->
        <SurveyDateFilterButtonGroup
          v-model="selectedDateFilter"
        />

        <!-- Right: Search and New Client Button -->
        <div class="flex items-center gap-3">
          <UInput
            v-model="searchQuery"
            icon="i-heroicons-magnifying-glass-20-solid"
            placeholder="Search clients..."
            :ui="{ icon: { trailing: { pointer: '' } } }"
            class="w-64"
          />

          <UButton
            icon="i-heroicons-bolt"
            label="Energy Consultation for new Client"
            color="primary"
            size="sm"
            to="/survey/client-data"
          />
        </div>
      </div>

      <!-- Survey List -->
      <div class="divide-y divide-gray-200 dark:divide-gray-800">
        <!-- Loading State -->
        <div v-if="loading" class="flex items-center justify-center py-12">
          <UIcon name="i-heroicons-arrow-path" class="w-6 h-6 animate-spin text-primary" />
          <span class="ml-2 text-gray-500">Loading...</span>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredSurveys.length === 0" class="flex flex-col items-center justify-center py-12">
          <UIcon name="i-heroicons-users" class="w-12 h-12 text-gray-400 mb-3" />
          <p class="text-gray-500">
            {{ selectedDateFilter !== 'all' ? 'No clients found for selected filter' : 'No clients found' }}
          </p>
        </div>

        <!-- Survey Items -->
        <SurveyListItem
          v-for="survey in filteredSurveys"
          :key="survey.id"
          :survey="survey"
        />
      </div>
    </UDashboardPanel>
  </UDashboardPage>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Survey } from '~/types/survey-new'

// State
const selectedDateFilter = ref<'today' | 'yesterday' | 'thisWeek' | 'lastWeek' | 'pending' | 'all'>('today')
const searchQuery = ref('')

// Fetch surveys with client data
const supabase = useSupabaseClient()
const loading = ref(true)
const surveys = ref<Survey[]>([])

// Fetch surveys on mount
onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('surveys')
      .select(`
        *,
        client:clients (
          id,
          name,
          email,
          phone,
          postal_code,
          city,
          street,
          house_number
        )
      `)
      .order('at', { ascending: false })

    if (error) throw error
    surveys.value = data || []
  } catch (error) {
    console.error('Error fetching surveys:', error)
  } finally {
    loading.value = false
  }
})

// Date helper functions
const isToday = (date: Date): boolean => {
  const today = new Date()
  return date.toDateString() === today.toDateString()
}

const isYesterday = (date: Date): boolean => {
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  return date.toDateString() === yesterday.toDateString()
}

const isThisWeek = (date: Date): boolean => {
  const today = new Date()
  const startOfWeek = new Date(today)
  startOfWeek.setDate(today.getDate() - today.getDay() + 1) // Monday
  startOfWeek.setHours(0, 0, 0, 0)

  const endOfWeek = new Date(startOfWeek)
  endOfWeek.setDate(startOfWeek.getDate() + 6) // Sunday
  endOfWeek.setHours(23, 59, 59, 999)

  return date >= startOfWeek && date <= endOfWeek
}

const isLastWeek = (date: Date): boolean => {
  const today = new Date()
  const startOfLastWeek = new Date(today)
  startOfLastWeek.setDate(today.getDate() - today.getDay() + 1 - 7) // Monday of last week
  startOfLastWeek.setHours(0, 0, 0, 0)

  const endOfLastWeek = new Date(startOfLastWeek)
  endOfLastWeek.setDate(startOfLastWeek.getDate() + 6) // Sunday of last week
  endOfLastWeek.setHours(23, 59, 59, 999)

  return date >= startOfLastWeek && date <= endOfLastWeek
}

// Filtered surveys based on date filter and search query
const filteredSurveys = computed(() => {
  let result = surveys.value

  // Apply date filter
  if (selectedDateFilter.value !== 'all') {
    if (selectedDateFilter.value === 'pending') {
      // For pending, we'll need to check contracts later
      // For now, show all
      result = surveys.value
    } else {
      result = surveys.value.filter(survey => {
        if (!survey.at) return false
        const surveyDate = new Date(survey.at)

        switch (selectedDateFilter.value) {
          case 'today':
            return isToday(surveyDate)
          case 'yesterday':
            return isYesterday(surveyDate)
          case 'thisWeek':
            return isThisWeek(surveyDate)
          case 'lastWeek':
            return isLastWeek(surveyDate)
          default:
            return true
        }
      })
    }
  }

  // Apply search filter
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim()
    result = result.filter(survey => {
      const client = survey.client
      if (!client) return false

      // Build full address
      const address = [
        client.postal_code,
        client.city,
        client.street,
        client.house_number
      ].filter(Boolean).join(' ')

      return (
        client.name?.toLowerCase().includes(query) ||
        client.email?.toLowerCase().includes(query) ||
        client.phone?.toLowerCase().includes(query) ||
        address.toLowerCase().includes(query) ||
        survey.at?.includes(query)
      )
    })
  }

  return result
})
</script>
