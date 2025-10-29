<template>
  <UIModal
    v-model="isOpen"
    title="Elektromos autó beállítás"
    size="lg"
    :scrollable="true"
  >
    <div class="space-y-6">
      <!-- Number of Cars Selection -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
          Elektromos autók száma
        </label>
        <div class="flex gap-2">
          <button
            v-for="count in [0, 1, 2, 3]"
            :key="count"
            class="flex-1 py-3 px-4 rounded-lg border-2 font-medium transition-all"
            :class="numberOfCars === count
              ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300'
              : 'border-gray-200 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700 text-gray-700 dark:text-gray-300'"
            @click="setNumberOfCars(count)"
          >
            {{ count }}
          </button>
        </div>
      </div>

      <!-- Car Details -->
      <div v-if="numberOfCars > 0" class="space-y-4">
        <h4 class="text-sm font-semibold text-gray-900 dark:text-white">
          Autók adatai
        </h4>

        <div
          v-for="index in numberOfCars"
          :key="index"
          class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg space-y-3"
        >
          <div class="font-medium text-gray-900 dark:text-white">
            {{ index }}. autó
          </div>

          <div class="grid grid-cols-2 gap-4">
            <!-- Annual Mileage -->
            <div>
              <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">
                Éves futásteljesítmény (km)
              </label>
              <input
                v-model.number="cars[index - 1].annual_mileage"
                type="number"
                placeholder="pl. 15000"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>

            <!-- Status Toggle -->
            <div>
              <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">
                Gépjármű állapota
              </label>
              <div class="flex gap-2 h-10">
                <button
                  class="flex-1 px-3 py-2 rounded-md text-xs font-medium transition-all"
                  :class="cars[index - 1].status === 'planned'
                    ? 'bg-primary-500 text-white'
                    : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
                  @click="cars[index - 1].status = 'planned'"
                >
                  Tervezett
                </button>
                <button
                  class="flex-1 px-3 py-2 rounded-md text-xs font-medium transition-all"
                  :class="cars[index - 1].status === 'existing'
                    ? 'bg-primary-500 text-white'
                    : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'"
                  @click="cars[index - 1].status = 'existing'"
                >
                  Van
                </button>
              </div>
            </div>
          </div>
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
interface ElectricCar {
  id?: string
  annual_mileage: number | null
  status: 'planned' | 'existing'
}

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
const numberOfCars = ref(0)
const cars = ref<ElectricCar[]>([])
const saving = ref(false)

// Sync isOpen with modelValue
watch(() => props.modelValue, (newValue) => {
  isOpen.value = newValue
})

watch(isOpen, (newValue) => {
  emit('update:modelValue', newValue)
})

const setNumberOfCars = (count: number) => {
  numberOfCars.value = count

  // Adjust cars array
  while (cars.value.length < count) {
    cars.value.push({
      annual_mileage: null,
      status: 'planned'
    })
  }

  if (cars.value.length > count) {
    cars.value = cars.value.slice(0, count)
  }
}

const loadExistingCars = async () => {
  const { data, error } = await supabase
    .from('electric_cars')
    .select('*')
    .eq('survey_id', props.surveyId)
    .order('created_at')

  if (error) {
    console.error('Error loading electric cars:', error)
    return
  }

  if (data && data.length > 0) {
    numberOfCars.value = data.length
    cars.value = data.map(car => ({
      id: car.id,
      annual_mileage: car.annual_mileage,
      status: car.status
    }))
  }
}

const handleSave = async () => {
  saving.value = true

  try {
    // Delete all existing cars for this survey
    const { error: deleteError } = await supabase
      .from('electric_cars')
      .delete()
      .eq('survey_id', props.surveyId)

    if (deleteError) throw deleteError

    // Insert new cars
    if (numberOfCars.value > 0) {
      const carsToInsert = cars.value.map(car => ({
        survey_id: props.surveyId,
        annual_mileage: car.annual_mileage,
        status: car.status
      }))

      const { error: insertError } = await supabase
        .from('electric_cars')
        .insert(carsToInsert)

      if (insertError) throw insertError
    }

    // Success - emit event and close modal
    emit('saved')
    closeModal()
  } catch (error) {
    console.error('Error saving electric cars:', error)
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
    await loadExistingCars()
  }
})
</script>
