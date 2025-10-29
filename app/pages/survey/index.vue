<template>
  <div>
    <!-- Header -->
    <div class="flex h-24 items-center justify-between mr-16">
      <div class="text-2xl font-light"><span class="font-black">{{ $t('survey.list.title') }}</span></div>
      <UIButtonEnhanced
        icon="i-lucide-zap"
        variant="primary"
        size="md"
        to="/survey/client-data"
      >
        {{ $t('survey.list.newConsultation') }}
      </UIButtonEnhanced>
    </div>

    <div class="flex flex-col space-y-8">
      <!-- Welcome Section -->
      <!--
      <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">

        <div class="flex flex-col basis-0 items-start justify-center">
          <div class="grid grid-cols-3 gap-4 w-full">
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-blue-600 dark:text-blue-400">
                {{ surveys.length }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">{{ $t('survey.list.totalSurveys') }}</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-orange-600 dark:text-orange-400">
                {{ todayCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">{{ $t('survey.list.today') }}</div>
            </UIBox>
            <UIBox class="p-4 text-center">
              <div class="text-3xl font-bold text-green-600 dark:text-green-400">
                {{ thisWeekCount }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">{{ $t('survey.list.thisWeek') }}</div>
            </UIBox>
          </div>
        </div>
      </div>
        -->


      <!-- Filters Section -->
      <div class="flex items-start gap-3">
        <!-- Filter Buttons -->
        <!--<UIBox class="flex-1">-->
          <div class=" grow">
            <div class="flex flex-wrap gap-2">
              <button
                v-for="option in dateFilterOptions"
                :key="option.value"
                @click="selectedDateFilter = option.value"
                :class="[
                  'px-4 py-3 rounded-full text-sm font-medium transition-all duration-200 cursor-pointer',
                  selectedDateFilter === option.value
                    ? 'bg-blue-500 text-white shadow-lg shadow-blue-500/30'
                    : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-black hover:text-white dark:hover:bg-gray-700'
                ]"
              >
                {{ option.label }}
              </button>
            </div>
          </div>
        <!--</UIBox>-->

        <!-- Search Input -->
        <div class="w-64">
          <UIInput
            v-model="searchQuery"
            :placeholder="$t('survey.list.searchPlaceholder')"
            icon="i-lucide-search"
          />
        </div>
      </div>

      <!-- Loading State -->
      <UIBox v-if="loading" class="p-12">
        <div class="flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      </UIBox>

      <!-- Empty State -->
      <UIBox v-else-if="filteredSurveys.length === 0" class="p-12">
        <div class="text-center">
          <Icon name="i-lucide-clipboard-list" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">{{ $t('survey.list.noConsultationsFound') }}</h3>
          <p class="text-gray-500 dark:text-gray-400 mb-4">
            {{ selectedDateFilter !== 'all' ? $t('survey.list.noClientsForFilter') : $t('survey.list.startByCreating') }}
          </p>
          <UIButtonEnhanced to="/survey/client-data">
            <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
            {{ $t('survey.list.newConsultation') }}
          </UIButtonEnhanced>
        </div>
      </UIBox>

      <!-- Survey List -->
      <div v-else class="grid grid-cols-1 gap-2">
        <SurveyListItem
          v-for="survey in filteredSurveys"
          :key="survey.id"
          :survey="survey"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Survey, Contract } from '~/types/survey-new'

const { t } = useI18n()

interface SurveyWithContracts extends Survey {
  contracts?: Pick<Contract, 'id' | 'first_sent_at' | 'first_signed_at'>[]
}

// State
const selectedDateFilter = ref<'today' | 'yesterday' | 'thisWeek' | 'lastWeek' | 'pending' | 'all'>('all')
const searchQuery = ref('')

// Filter options
const dateFilterOptions = computed(() => [
  { label: t('survey.list.filters.allTime'), value: 'all' },
  { label: t('survey.list.filters.today'), value: 'today' },
  { label: t('survey.list.filters.yesterday'), value: 'yesterday' },
  { label: t('survey.list.filters.thisWeek'), value: 'thisWeek' },
  { label: t('survey.list.filters.lastWeek'), value: 'lastWeek' },
  { label: t('survey.list.filters.pending'), value: 'pending' }
])

// Welcome title with HTML formatting
const welcomeTitleHtml = computed(() => {
  const bold1 = t('survey.list.welcomeTitleBold1')
  const bold2 = t('survey.list.welcomeTitleBold2')
  const prefix = t('survey.list.welcomeTitle')
    .replace('@:survey.list.welcomeTitleBold1', `<strong class="font-black">${bold1}</strong>`)
    .replace('@:survey.list.welcomeTitleBold2', `<br /><strong class="font-black">${bold2}</strong>`)
  return prefix
})

// Fetch surveys with client data
const supabase = useSupabaseClient()
const loading = ref(true)
const surveys = ref<SurveyWithContracts[]>([])

// Stats computed
const todayCount = computed(() => {
  return surveys.value.filter(survey => {
    if (!survey.at) return false
    return isToday(new Date(survey.at))
  }).length
})

const thisWeekCount = computed(() => {
  return surveys.value.filter(survey => {
    if (!survey.at) return false
    return isThisWeek(new Date(survey.at))
  }).length
})

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
        ),
        contracts (
          id,
          first_sent_at,
          first_signed_at
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
      // For pending filter:
      // - Survey must have been opened at least once (first_opened_at is not null)
      // - AND either no contracts OR no contracts have been sent/signed
      result = surveys.value.filter(survey => {
        // Must have been opened at least once
        if (!survey.first_opened_at) {
          return false
        }

        // No contracts = pending
        if (!survey.contracts || survey.contracts.length === 0) {
          return true
        }

        // Check if any contract has been sent or signed
        const hasSentOrSignedContract = survey.contracts.some(contract =>
          contract.first_sent_at || contract.first_signed_at
        )

        // Pending if no contracts have been sent or signed
        return !hasSentOrSignedContract
      })
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
