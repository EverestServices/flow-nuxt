<template>
  <div class="space-y-4">
    <!-- Solar Panel Fields - only if Solar Panel or Battery investment is selected -->
    <div v-if="showSolarFields" class="space-y-3">
      <!-- Roof Type -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-1">
          Tető típusa
        </label>
        <UISelect
          :model-value="localData.roofType"
          :options="roofTypeOptions"
          size="sm"
          @update:model-value="handleFieldChange('roofType', $event)"
        />
      </div>

      <!-- Orientation -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-2">
          Tájolás
        </label>
        <div class="grid grid-cols-8 gap-1">
          <button
            v-for="option in orientationOptions"
            :key="option.value"
            type="button"
            :class="[
              'flex flex-col items-center justify-center py-2 px-1 rounded border transition-colors text-xs',
              localData.orientation === option.value
                ? 'bg-primary-600 border-primary-600 text-white'
                : 'bg-white dark:bg-gray-800 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary-400'
            ]"
            @click="handleFieldChange('orientation', option.value)"
          >
            <UIcon name="i-lucide-compass" class="w-4 h-4 mb-0.5" />
            <span class="font-semibold">{{ option.label }}</span>
          </button>
        </div>
      </div>

      <!-- Tilt Angle -->
      <div>
        <div class="flex items-center justify-between mb-1">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            Dőlésszög
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ localData.tiltAngle }}°
          </span>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-sm text-gray-500 dark:text-gray-400 min-w-[30px]">0°</span>
          <input
            type="range"
            :value="localData.tiltAngle"
            min="0"
            max="50"
            step="5"
            class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            @input="handleFieldChange('tiltAngle', Number(($event.target as HTMLInputElement).value))"
          />
          <span class="text-sm text-gray-500 dark:text-gray-400 min-w-[30px]">50°</span>
        </div>
      </div>

      <!-- Consumption Unit -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-1">
          Mértékegység
        </label>
        <div class="flex border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden">
          <button
            type="button"
            :class="[
              'flex-1 py-2 px-4 text-sm font-semibold transition-colors',
              localData.consumptionUnit === 'kW'
                ? 'bg-primary-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
            ]"
            @click="handleFieldChange('consumptionUnit', 'kW')"
          >
            kW
          </button>
          <button
            type="button"
            :class="[
              'flex-1 py-2 px-4 text-sm font-semibold transition-colors border-l border-gray-300 dark:border-gray-600',
              localData.consumptionUnit === 'Ft'
                ? 'bg-primary-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
            ]"
            @click="handleFieldChange('consumptionUnit', 'Ft')"
          >
            Ft
          </button>
        </div>
      </div>

      <!-- Consumption Period -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-1">
          Időszak
        </label>
        <div class="flex border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden">
          <button
            type="button"
            :class="[
              'flex-1 py-2 px-4 text-sm font-semibold transition-colors',
              localData.consumptionPeriod === 'hónap'
                ? 'bg-primary-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
            ]"
            @click="handleFieldChange('consumptionPeriod', 'hónap')"
          >
            hónap
          </button>
          <button
            type="button"
            :class="[
              'flex-1 py-2 px-4 text-sm font-semibold transition-colors border-l border-gray-300 dark:border-gray-600',
              localData.consumptionPeriod === 'év'
                ? 'bg-primary-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
            ]"
            @click="handleFieldChange('consumptionPeriod', 'év')"
          >
            év
          </button>
        </div>
      </div>

      <!-- Consumption -->
      <div>
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-1">
          Fogyasztás
        </label>
        <UInput
          :model-value="localData.consumption"
          type="number"
          placeholder="Érték"
          size="sm"
          @update:model-value="handleFieldChange('consumption', $event)"
        />
      </div>

      <!-- Note -->
      <p class="text-xs text-gray-500 dark:text-gray-400 italic mt-2">
        {{ isModified
          ? 'Megjegyzés: Ezek az adatok módosítva lettek. Az eredeti felmérési adatok nem változnak.'
          : 'Megjegyzés: Ezek az adatok az "Ingatlan felmérése" oldalról származnak. Ha itt módosítja, az eredeti felmérési adatok nem változnak.'
        }}
      </p>

      <!-- Monthly Gas Bill Slider -->
      <div class="mt-4">
        <div class="flex items-center justify-between mb-1">
          <label class="text-sm font-medium text-gray-900 dark:text-white">
            {{ $t('household.monthlyGasBill') }}
          </label>
          <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
            {{ formatCurrency(localData.monthlyGasBill) }}
          </span>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-sm text-gray-500 dark:text-gray-400 min-w-[60px]">0 Ft</span>
          <input
            type="range"
            :value="localData.monthlyGasBill"
            min="0"
            max="500000"
            step="1000"
            class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
            @input="handleFieldChange('monthlyGasBill', Number(($event.target as HTMLInputElement).value))"
          />
          <span class="text-sm text-gray-500 dark:text-gray-400 min-w-[90px] text-right">500 000 Ft</span>
        </div>
      </div>

      <!-- Consumption Profiles -->
      <div class="mt-4">
        <label class="block text-sm font-medium text-gray-900 dark:text-white mb-2">
          {{ $t('household.consumptionProfiles') }}
        </label>
        <div class="grid grid-cols-2 gap-2">
          <button
            v-for="profile in consumptionProfiles"
            :key="profile.value"
            type="button"
            :class="[
              'flex flex-col items-center justify-center py-3 px-3 rounded-lg border-2 transition-all text-xs',
              selectedProfiles.includes(profile.value)
                ? 'bg-primary-600 border-primary-600 text-white shadow-md'
                : 'bg-white dark:bg-gray-800 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary-400 hover:bg-gray-50 dark:hover:bg-gray-700'
            ]"
            @click="toggleProfile(profile.value)"
          >
            <UIcon :name="profile.icon" class="w-5 h-5 mb-1" />
            <span class="font-medium text-center">{{ profile.label }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="text-center py-6">
      <p class="text-sm text-gray-500 dark:text-gray-400">
        Az itt megjelenő információk az "Ingatlan felmérése" oldalon megadott adatokat fogják tartalmazni.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'

interface HouseholdData {
  roofType: string
  orientation: string
  tiltAngle: number
  consumptionUnit: 'kW' | 'Ft'
  consumptionPeriod: 'hónap' | 'év'
  consumption: string
  monthlyGasBill: number
}

interface Props {
  surveyId: string
}

const props = defineProps<Props>()

const supabase = useSupabaseClient()

// Local data state
const localData = ref<HouseholdData>({
  roofType: 'Sátortető',
  orientation: 'D',
  tiltAngle: 30,
  consumptionUnit: 'kW',
  consumptionPeriod: 'év',
  consumption: '',
  monthlyGasBill: 0
})

const isModified = ref(false)
const showSolarFields = ref(false)
const selectedInvestments = ref<string[]>([])
const selectedProfiles = ref<string[]>([])

const { t } = useI18n()

// Consumption profiles options
const consumptionProfiles = computed(() => [
  { value: 'work_from_home', label: t('household.profiles.workFromHome'), icon: 'i-lucide-home' },
  { value: 'traditional_hours', label: t('household.profiles.traditionalHours'), icon: 'i-lucide-briefcase' },
  { value: 'shift_work', label: t('household.profiles.shiftWork'), icon: 'i-lucide-clock' },
  { value: 'retired_stay_at_home', label: t('household.profiles.retiredStayAtHome'), icon: 'i-lucide-armchair' },
  { value: 'young_family', label: t('household.profiles.youngFamily'), icon: 'i-lucide-baby' }
])

/**
 * Check if solar-related investment is selected
 */
const checkSolarInvestments = async () => {
  try {
    const { data: surveyInvestments, error } = await supabase
      .from('survey_investments')
      .select('investment:investments(persist_name)')
      .eq('survey_id', props.surveyId)

    if (error) throw error

    const investmentNames = surveyInvestments
      ?.map((si: any) => si.investment?.persist_name)
      .filter(Boolean) || []

    selectedInvestments.value = investmentNames

    // Show solar fields if solar panel or battery is selected
    showSolarFields.value = investmentNames.includes('solarPanel') ||
                            investmentNames.includes('solarPanelBattery')
  } catch (error) {
    console.error('Error checking investments:', error)
  }
}

// Roof type options
const roofTypeOptions = [
  { value: 'Nyeregtető', label: 'Nyeregtető' },
  { value: 'Sátortető', label: 'Sátortető' },
  { value: 'Fél nyeregtető', label: 'Fél nyeregtető' },
  { value: 'Lapostető', label: 'Lapostető' },
  { value: 'Földre telepítés', label: 'Földre telepítés' },
  { value: 'Egyéb', label: 'Egyéb' }
]

// Orientation options
const orientationOptions = [
  { value: 'É', label: 'É' },
  { value: 'ÉK', label: 'ÉK' },
  { value: 'K', label: 'K' },
  { value: 'DK', label: 'DK' },
  { value: 'D', label: 'D' },
  { value: 'DNy', label: 'DNy' },
  { value: 'Ny', label: 'Ny' },
  { value: 'ÉNy', label: 'ÉNy' }
]

/**
 * Load household data from survey
 */
const loadHouseholdData = async () => {
  try {
    const { data: survey, error } = await supabase
      .from('surveys')
      .select('household_data, consumption_profiles')
      .eq('id', props.surveyId)
      .single()

    if (error) throw error

    if (survey?.household_data) {
      // User has modified data - use it
      localData.value = { ...localData.value, ...survey.household_data }
      isModified.value = true
    } else {
      // Load from Property Assessment survey answers
      await loadFromPropertyAssessment()
      isModified.value = false
    }

    // Load consumption profiles
    if (survey?.consumption_profiles) {
      selectedProfiles.value = survey.consumption_profiles
    }
  } catch (error) {
    console.error('Error loading household data:', error)
  }
}

/**
 * Load data from Property Assessment survey answers
 */
const loadFromPropertyAssessment = async () => {
  try {
    // Get survey answers for this survey
    const { data: answers, error } = await supabase
      .from('survey_answers')
      .select(`
        answer,
        survey_question:survey_questions(name, survey_page:survey_pages(investment_id))
      `)
      .eq('survey_id', props.surveyId)

    if (error) throw error

    if (!answers || answers.length === 0) return

    // Map answers by question name for easier lookup
    const answerMap = new Map<string, string>()
    answers.forEach((a: any) => {
      if (a.survey_question?.name) {
        answerMap.set(a.survey_question.name, a.answer)
      }
    })

    // Look for solar panel/battery related questions
    // These field names should match the question names from Property Assessment
    if (answerMap.has('default_roof_type')) {
      localData.value.roofType = answerMap.get('default_roof_type') || 'Sátortető'
    }
    if (answerMap.has('orientation')) {
      localData.value.orientation = answerMap.get('orientation') || 'D'
    }
    if (answerMap.has('tilt_angle')) {
      const tilt = answerMap.get('tilt_angle')
      localData.value.tiltAngle = tilt ? Number(tilt) : 30
    }
    if (answerMap.has('consumption_unit_toggle')) {
      const unit = answerMap.get('consumption_unit_toggle')
      localData.value.consumptionUnit = (unit === 'kW' || unit === 'Ft') ? unit : 'kW'
    }
    if (answerMap.has('consumption_period_toggle')) {
      const period = answerMap.get('consumption_period_toggle')
      localData.value.consumptionPeriod = (period === 'hónap' || period === 'év') ? period : 'év'
    }
    if (answerMap.has('annual_consumption')) {
      localData.value.consumption = answerMap.get('annual_consumption') || ''
    }
  } catch (error) {
    console.error('Error loading from property assessment:', error)
  }
}

/**
 * Save household data to survey
 */
const saveHouseholdData = async () => {
  try {
    const { error } = await supabase
      .from('surveys')
      .update({
        household_data: localData.value,
        consumption_profiles: selectedProfiles.value
      })
      .eq('id', props.surveyId)

    if (error) throw error

    isModified.value = true
  } catch (error) {
    console.error('Error saving household data:', error)
  }
}

/**
 * Handle field change
 */
const handleFieldChange = (field: keyof HouseholdData, value: any) => {
  localData.value[field] = value as never
  // Debounce save
  saveHouseholdData()
}

/**
 * Toggle consumption profile selection
 */
const toggleProfile = (profileValue: string) => {
  const index = selectedProfiles.value.indexOf(profileValue)
  if (index > -1) {
    selectedProfiles.value.splice(index, 1)
  } else {
    selectedProfiles.value.push(profileValue)
  }
  // Save immediately
  saveHouseholdData()
}

/**
 * Format currency in HUF
 */
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    maximumFractionDigits: 0
  }).format(amount)
}

// Load data on mount
onMounted(async () => {
  await checkSolarInvestments()
  await loadHouseholdData()
})
</script>

<style scoped>
/* Custom slider styles */
input[type="range"]::-webkit-slider-thumb {
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgb(37, 99, 235); /* primary-600 */
  cursor: pointer;
}

input[type="range"]::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgb(37, 99, 235); /* primary-600 */
  cursor: pointer;
  border: none;
}

input[type="range"]::-webkit-slider-runnable-track {
  background: linear-gradient(to right, rgb(37, 99, 235) 0%, rgb(37, 99, 235) var(--value), rgb(229, 231, 235) var(--value), rgb(229, 231, 235) 100%);
  height: 8px;
  border-radius: 4px;
}

input[type="range"]::-moz-range-track {
  background: rgb(229, 231, 235);
  height: 8px;
  border-radius: 4px;
}

input[type="range"]::-moz-range-progress {
  background: rgb(37, 99, 235);
  height: 8px;
  border-radius: 4px;
}
</style>
