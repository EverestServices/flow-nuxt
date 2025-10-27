<template>
  <UIBox class="cursor-pointer hover:shadow-xl transition-all duration-200">
    <div class="p-4">
      <!-- Single Row Layout -->
      <div class="flex items-center justify-between gap-4">
        <!-- Left: Client Info -->
        <div class="flex items-center gap-3 flex-1 min-w-0">
          <!-- Client Avatar/Icon -->
          <div class="bg-blue-100 dark:bg-blue-900/30 rounded-full p-2 flex-shrink-0">
            <Icon name="i-lucide-user" class="w-5 h-5 text-blue-600 dark:text-blue-400" />
          </div>

          <div class="min-w-0 flex-1">
            <h3 class="text-base font-semibold text-gray-900 dark:text-white truncate">
              {{ survey.client?.name || 'Unknown Client' }}
            </h3>
            <div class="flex items-center gap-3 text-xs text-gray-500 dark:text-gray-400">
              <span v-if="clientAddress" class="flex items-center gap-1 truncate">
                <Icon name="i-lucide-map-pin" class="w-3 h-3 flex-shrink-0" />
                {{ clientAddress }}
              </span>
              <span v-if="survey.client?.email" class="flex items-center gap-1 truncate">
                <Icon name="i-lucide-mail" class="w-3 h-3 flex-shrink-0" />
                {{ survey.client.email }}
              </span>
              <span v-if="survey.client?.phone" class="flex items-center gap-1">
                <Icon name="i-lucide-phone" class="w-3 h-3 flex-shrink-0" />
                {{ survey.client.phone }}
              </span>
            </div>
          </div>
        </div>

        <!-- Center: Date Badge -->
        <div class="flex-shrink-0">
          <div class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-orange-100 dark:bg-orange-900/30 rounded-full">
            <Icon name="i-lucide-calendar" class="w-3.5 h-3.5 text-orange-600 dark:text-orange-400" />
            <span class="text-xs font-medium text-orange-600 dark:text-orange-400">{{ formattedDateShort }}</span>
          </div>
        </div>

        <!-- Right: Action Buttons -->
        <div class="flex items-center gap-2 flex-shrink-0">
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            :to="`/client/${survey.client?.id}?from=survey`"
          >
            <Icon name="i-lucide-user" class="w-3.5 h-3.5" />
          </UIButtonEnhanced>
          <UIButtonEnhanced
            variant="primary"
            size="sm"
            :to="`/survey/${survey.id}`"
          >
            <Icon name="i-lucide-zap" class="w-3.5 h-3.5 mr-1.5" />
            Start
          </UIButtonEnhanced>
        </div>
      </div>
    </div>
  </UIBox>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Survey } from '~/types/survey-new'

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
  }
}>()

// Format survey date with time
const formattedDate = computed(() => {
  if (!props.survey.at) return 'No date'

  const date = new Date(props.survey.at)
  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
})

// Shorter date format for compact view
const formattedDateShort = computed(() => {
  if (!props.survey.at) return 'No date'

  const date = new Date(props.survey.at)
  return date.toLocaleString('en-US', {
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
</script>
