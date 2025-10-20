<template>
  <div class="px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
    <!-- Row 1: Client Name & Survey Date -->
    <div class="flex items-center justify-between mb-2">
      <h3 class="text-base font-semibold text-gray-900 dark:text-white">
        {{ survey.client?.name || 'Unknown Client' }}
      </h3>
      <div class="text-sm text-gray-500 dark:text-gray-400">
        <span class="font-medium">Survey date:</span>
        {{ formattedDate }}
      </div>
    </div>

    <!-- Row 2: Contact Info -->
    <div class="flex items-center gap-4 mb-3 text-sm text-gray-600 dark:text-gray-300">
      <span v-if="clientAddress" class="truncate">{{ clientAddress }}</span>
      <span v-if="survey.client?.email" class="truncate">{{ survey.client.email }}</span>
      <span v-if="survey.client?.phone">{{ survey.client.phone }}</span>
    </div>

    <!-- Row 3: Action Buttons -->
    <div class="flex items-center justify-end gap-3">
      <UButton
        label="Client profile"
        color="gray"
        variant="outline"
        size="sm"
        :to="`/client/${survey.client?.id}?from=survey`"
      />
      <UButton
        icon="i-heroicons-bolt"
        label="Start Energy Consultation"
        color="primary"
        size="sm"
        :to="`/survey/${survey.id}`"
      />
    </div>
  </div>
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
