<template>
  <!-- Backdrop -->
  <div
    v-if="modelValue"
    class="fixed inset-0 bg-black/50 z-40"
    @click="closeModal"
  ></div>

  <!-- Modal -->
  <Transition name="modal-fade">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      @click.self="closeModal"
    >
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full max-h-[90vh] flex flex-col">
        <!-- Header -->
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              Nagyfogyasztó beállítás
            </h3>
            <button
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
              @click="closeModal"
            >
              <UIcon name="i-lucide-x" class="w-5 h-5" />
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="flex-1 overflow-y-auto p-6">
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
        </div>

        <!-- Footer -->
        <div class="p-6 border-t border-gray-200 dark:border-gray-700">
          <div class="flex justify-end space-x-3">
            <button
              class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600"
              @click="closeModal"
            >
              Mégse
            </button>
            <button
              class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
              :disabled="saving"
              @click="handleSave"
            >
              <UIcon v-if="saving" name="i-lucide-loader-2" class="w-4 h-4 animate-spin" />
              <span v-else>Mentés</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
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
const loading = ref(false)
const saving = ref(false)
const heavyConsumers = ref<HeavyConsumer[]>([])
const consumerStatuses = ref<Record<string, ConsumerStatus>>({})

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
  emit('update:modelValue', false)
}

// Watch for modal opening to load data
watch(() => props.modelValue, async (isOpen) => {
  if (isOpen) {
    await loadHeavyConsumers()
  }
})
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active > div,
.modal-fade-leave-active > div {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-fade-enter-from > div,
.modal-fade-leave-to > div {
  transform: scale(0.95);
  opacity: 0;
}
</style>
