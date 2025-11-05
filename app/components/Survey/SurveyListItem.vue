<template>
  <div
    class="group relative cursor-pointer transition-all duration-300 ease-out
           bg-gradient-to-br from-white via-white to-gray-50/50
           dark:from-slate-900 dark:via-slate-900 dark:to-slate-800/50
           rounded-4xl border border-gray-200/60 dark:border-slate-700/60
           overflow-hidden"
  >
    <!-- Status indicator bar (left edge) -->
    <div
      :class="[
        'absolute left-4 top-4 bottom-4 w-3 rounded-full transition-all duration-300',
        firstContractSignedDate
          ? 'bg-gradient-to-b from-emerald-500 to-green-600'
          : firstContractSentDate
          ? 'bg-gradient-to-b from-blue-500 to-indigo-600'
          : 'bg-gradient-to-b from-orange-500 to-amber-600'
      ]"
    ></div>

    <div class="relative p-5 md:p-6">
      <!-- Desktop & iPad Layout -->
      <div class="flex flex-col lg:flex-row items-start lg:items-center gap-4 lg:gap-6">
        <!-- Left: Client Info with Avatar -->
        <div class="flex items-center gap-4 flex-1 min-w-0 w-full lg:w-auto">
          <!-- Enhanced Avatar -->
          <!--
          <div class="relative flex-shrink-0">
            <div class="bg-gradient-to-br from-blue-500 via-indigo-600 to-purple-600
                        rounded-2xl p-4 shadow-lg shadow-blue-500/30
                        group-hover:shadow-xl group-hover:shadow-blue-500/40
                        group-hover:scale-110 transition-all duration-300">
              <Icon name="i-lucide-user" class="w-6 h-6 text-white" />
            </div>
            <div
              :class="[
                'absolute -top-1 -right-1 w-4 h-4 rounded-full border-2 border-white dark:border-slate-900 shadow-lg transition-all duration-300',
                firstContractSignedDate
                  ? 'bg-emerald-500'
                  : firstContractSentDate
                  ? 'bg-blue-500 animate-pulse'
                  : 'bg-orange-500'
              ]"
            ></div>
          </div>-->

          <!-- Client Details -->
          <div class="flex-1 min-w-0 space-y-2 ml-4">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white truncate
                       group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
              {{ survey.client?.name || t('survey.list.unknownClient') }}
            </h3>

            <!-- Contact Info Row -->
            <div class="flex flex-wrap gap-x-4 gap-y-1.5 text-sm text-gray-600 dark:text-gray-400">
              <span v-if="clientAddress" class="flex items-center gap-1.5 truncate max-w-xs">
                <Icon name="i-lucide-map-pin" class="w-4 h-4 flex-shrink-0 text-gray-400" />
                <span class="truncate">{{ clientAddress }}</span>
              </span>
              <span v-if="survey.client?.email" class="flex items-center gap-1.5 truncate max-w-xs">
                <Icon name="i-lucide-mail" class="w-4 h-4 flex-shrink-0 text-gray-400" />
                <span class="truncate">{{ survey.client.email }}</span>
              </span>
              <span v-if="survey.client?.phone" class="flex items-center gap-1.5 whitespace-nowrap">
                <Icon name="i-lucide-phone" class="w-4 h-4 flex-shrink-0 text-gray-400" />
                {{ survey.client.phone }}
              </span>
            </div>
          </div>
        </div>

        <!-- Center: Status Badges -->
        <div class="flex flex-wrap items-center gap-2 lg:flex-shrink-0">
          <!-- Event Date Badge -->
          <div class="inline-flex items-center gap-2 px-4 py-2.5
                      bg-gradient-to-br from-orange-100 to-amber-100
                      dark:from-orange-900/40 dark:to-amber-900/40
                      rounded-xl shadow-sm border border-orange-200/50 dark:border-orange-700/50
                      group-hover:shadow-md transition-all duration-200">
            <Icon name="i-lucide-calendar" class="w-4 h-4 text-orange-600 dark:text-orange-400" />
            <span class="text-sm font-semibold text-orange-700 dark:text-orange-400 whitespace-nowrap">
              {{ formattedDateShort }}
            </span>
          </div>

          <!-- Contract Sent Badge -->
          <div v-if="firstContractSentDate"
               class="inline-flex items-center gap-2 px-4 py-2.5
                      bg-gradient-to-br from-blue-100 to-indigo-100
                      dark:from-blue-900/40 dark:to-indigo-900/40
                      rounded-xl shadow-sm border border-blue-200/50 dark:border-blue-700/50
                      group-hover:shadow-md transition-all duration-200">
            <Icon name="i-lucide-send" class="w-4 h-4 text-blue-600 dark:text-blue-400" />
            <span class="text-sm font-semibold text-blue-700 dark:text-blue-400 whitespace-nowrap">
              {{ formattedContractSentDate }}
            </span>
          </div>

          <!-- Contract Signed Badge -->
          <div v-if="firstContractSignedDate"
               class="inline-flex items-center gap-2 px-4 py-2.5
                      bg-gradient-to-br from-emerald-100 to-green-100
                      dark:from-emerald-900/40 dark:to-green-900/40
                      rounded-xl shadow-sm border border-emerald-200/50 dark:border-emerald-700/50
                      group-hover:shadow-md transition-all duration-200">
            <Icon name="i-lucide-check-circle" class="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
            <span class="text-sm font-semibold text-emerald-700 dark:text-emerald-400 whitespace-nowrap">
              {{ formattedContractSignedDate }}
            </span>
          </div>
        </div>

        <!-- Right: Action Buttons -->
        <div class="flex items-center gap-3 lg:flex-shrink-0 w-full lg:w-auto justify-end">
          <UIButtonEnhanced
            variant="outline"
            size="md"
            class="flex-1 lg:flex-initial lg:w-12 lg:h-12 p-0
                   border-2 hover:border-blue-500 dark:hover:border-blue-500
                   transition-all duration-200 hover:scale-105"
            :to="`/client/${survey.client?.id}?from=survey`"
          >
            <Icon name="i-lucide-user" class="w-5 h-5" />
            <span class="lg:hidden ml-2">{{ t('survey.list.viewClient') }}</span>
          </UIButtonEnhanced>
          <UIButtonEnhanced
            variant="primary"
            size="md"
            class="flex-1 lg:flex-initial shadow-lg shadow-blue-500/30
                   hover:shadow-xl hover:shadow-blue-500/40
                   transition-all duration-200 hover:scale-105
                   bg-gradient-to-r from-blue-600 to-indigo-600
                   hover:from-blue-500 hover:to-indigo-500"
            :to="`/survey/${survey.id}`"
          >
            <Icon name="i-lucide-zap" class="w-4 h-4" />
            <span class="ml-2 font-semibold">{{ t('survey.list.start') }}</span>
          </UIButtonEnhanced>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Survey, Contract } from '~/types/survey-new'

const { t, locale } = useI18n()

const props = defineProps<{
  survey: Survey & {
    client: {
      id: string
      name: string
      email: string | null
      phone: string | null
      postal_code: string | null
      city: string | null
      street: string | null
      house_number: string | null
    } | null
    contracts?: Pick<Contract, 'id' | 'first_sent_at' | 'first_signed_at'>[]
  }
}>()

// Shorter date format for compact view
const formattedDateShort = computed(() => {
  if (!props.survey.at) return t('survey.list.noDate')

  const date = new Date(props.survey.at)
  return date.toLocaleString(locale.value, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
})

// Build full address
const clientAddress = computed(() => {
  const client = props.survey.client
  if (!client) return ''

  const parts = [
    client.postal_code,
    client.city,
    client.street,
    client.house_number
  ].filter(Boolean)

  return parts.join(' ')
})

// Get first contract sent date
const firstContractSentDate = computed(() => {
  const contracts = props.survey.contracts
  if (!contracts || contracts.length === 0) return null

  // Find the earliest first_sent_at date
  const sentDates = contracts
    .filter(c => c.first_sent_at)
    .map(c => new Date(c.first_sent_at!))
    .sort((a, b) => a.getTime() - b.getTime())

  return sentDates.length > 0 ? sentDates[0] : null
})

// Format contract sent date
const formattedContractSentDate = computed(() => {
  if (!firstContractSentDate.value) return ''

  return firstContractSentDate.value.toLocaleString(locale.value, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
})

// Get first contract signed date
const firstContractSignedDate = computed(() => {
  const contracts = props.survey.contracts
  if (!contracts || contracts.length === 0) return null

  // Find the earliest first_signed_at date
  const signedDates = contracts
    .filter(c => c.first_signed_at)
    .map(c => new Date(c.first_signed_at!))
    .sort((a, b) => a.getTime() - b.getTime())

  return signedDates.length > 0 ? signedDates[0] : null
})

// Format contract signed date
const formattedContractSignedDate = computed(() => {
  if (!firstContractSignedDate.value) return ''

  return firstContractSignedDate.value.toLocaleString(locale.value, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
})
</script>
