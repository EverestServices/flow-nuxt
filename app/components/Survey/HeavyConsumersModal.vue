<template>
  <UIModal
    v-model="isOpen"
    title="Nagyfogyasztó beállítás"
    size="lg"
    :scrollable="true"
  >
    <div v-if="loading" class="flex items-center justify-center py-12">
      <UIcon name="i-lucide-loader-2" class="w-8 h-8 animate-spin" />
    </div>

    <div v-else class="space-y-3">
      <div
        v-for="consumer in heavyConsumers"
        :key="consumer.id"
        class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-900 rounded-lg"
      >
        <!-- Left: Icon and Name -->
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-gray-200 dark:bg-gray-800 flex items-center justify-center">
            <UIcon :name="consumer.icon" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </div>
          <span class="font-medium text-gray-900 dark:text-white">
            {{ formatConsumerName(consumer.name) }}
          </span>
        </div>

        <!-- Right: Status Buttons -->
        <div class="flex gap-2">
          <button
            class="px-4 py-2 rounded-md text-sm font-medium transition-all"
            :class="getConsumerStatus(consumer.id) === 'none'
              ? 'bg-primary-500 text-white'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
            @click="setConsumerStatus(consumer.id, 'none')"
          >
            Nincs
          </button>
          <button
            class="px-4 py-2 rounded-md text-sm font-medium transition-all"
            :class="getConsumerStatus(consumer.id) === 'planned'
              ? 'bg-primary-500 text-white'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
            @click="setConsumerStatus(consumer.id, 'planned')"
          >
            Tervezett
          </button>
          <button
            class="px-4 py-2 rounded-md text-sm font-medium transition-all"
            :class="getConsumerStatus(consumer.id) === 'existing'
              ? 'bg-primary-500 text-white'
              : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
            @click="setConsumerStatus(consumer.id, 'existing')"
          >
            Van
          </button>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="closeModal"
      >
        Mégse
      </UIButtonEnhanced>
      <UIButtonEnhanced
        variant="primary"
        :disabled="saving"
        @click="handleSave"
      >
        <Icon v-if="saving" name="i-lucide-loader-2" class="w-4 h-4 mr-2 animate-spin" />
        Mentés
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
interface HeavyConsumer {
  id: string
  name: string
  icon: string
  sequence: number
}

type ConsumerStatus = 'none' | 'planned' | 'existing'

interface Props {
  modelValue: boolean
  surveyId: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'saved': []
}>()

const supabase = useSupabaseClient()
const isOpen = ref(false)
const loading = ref(false)
const saving = ref(false)
const heavyConsumers = ref<HeavyConsumer[]>([])
const consumerStatuses = ref<Record<string, ConsumerStatus>>({})

// Sync isOpen with modelValue
watch(() => props.modelValue, (newValue) => {
  isOpen.value = newValue
})

watch(isOpen, (newValue) => {
  emit('update:modelValue', newValue)
})

const loadHeavyConsumers = async () => {
  loading.value = true

  try {
    // Load all heavy consumers
    const { data: consumers, error: consumersError } = await supabase
      .from('heavy_consumers')
      .select('*')
      .order('sequence')

    if (consumersError) throw consumersError

    heavyConsumers.value = consumers || []

    // Load existing survey-heavy consumer relationships
    const { data: surveyConsumers, error: surveyError } = await supabase
      .from('survey_heavy_consumers')
      .select('heavy_consumer_id, status')
      .eq('survey_id', props.surveyId)

    if (surveyError) throw surveyError

    // Initialize statuses (default to 'none')
    const statuses: Record<string, ConsumerStatus> = {}
    heavyConsumers.value.forEach(consumer => {
      statuses[consumer.id] = 'none'
    })

    // Update with existing statuses
    surveyConsumers?.forEach(sc => {
      statuses[sc.heavy_consumer_id] = sc.status as ConsumerStatus
    })

    consumerStatuses.value = statuses
  } catch (error) {
    console.error('Error loading heavy consumers:', error)
  } finally {
    loading.value = false
  }
}

const getConsumerStatus = (consumerId: string): ConsumerStatus => {
  return consumerStatuses.value[consumerId] || 'none'
}

const setConsumerStatus = (consumerId: string, status: ConsumerStatus) => {
  consumerStatuses.value[consumerId] = status
}

const formatConsumerName = (name: string): string => {
  const nameMap: Record<string, string> = {
    sauna: 'Szauna',
    jacuzzi: 'Jacuzzi',
    poolHeating: 'Medence fűtés',
    cryptoMining: 'Kripto bányászat',
    heatPump: 'Hőszivattyú',
    electricHeating: 'Elektromos fűtés'
  }
  return nameMap[name] || name
}

const handleSave = async () => {
  saving.value = true

  try {
    // Delete all existing survey-heavy consumer relationships
    const { error: deleteError } = await supabase
      .from('survey_heavy_consumers')
      .delete()
      .eq('survey_id', props.surveyId)

    if (deleteError) throw deleteError

    // Insert new relationships (skip 'none' status)
    const relationshipsToInsert = Object.entries(consumerStatuses.value)
      .filter(([_, status]) => status !== 'none')
      .map(([consumerId, status]) => ({
        survey_id: props.surveyId,
        heavy_consumer_id: consumerId,
        status
      }))

    if (relationshipsToInsert.length > 0) {
      const { error: insertError } = await supabase
        .from('survey_heavy_consumers')
        .insert(relationshipsToInsert)

      if (insertError) throw insertError
    }

    // Success - emit event and close modal
    emit('saved')
    closeModal()
  } catch (error) {
    console.error('Error saving heavy consumers:', error)
    // TODO: Show error toast
    // Don't close modal on error
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  isOpen.value = false
}

// Watch for modal opening to load data
watch(isOpen, async (newValue) => {
  if (newValue) {
    await loadHeavyConsumers()
  }
})
</script>
