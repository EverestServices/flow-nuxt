<template>
  <UIModal
    v-model="isOpen"
    :title="title"
    size="xl"
    :scrollable="true"
  >
    <div v-if="loading" class="flex items-center justify-center py-12">
      <UIcon name="i-lucide-loader-2" class="w-8 h-8 animate-spin" />
    </div>

    <div v-else class="space-y-6">
      <!-- Chart -->
      <ClientOnly>
        <apexchart
          type="bar"
          :options="chartOptions"
          :series="chartSeries"
          height="350"
        />
      </ClientOnly>

      <!-- Monthly values table -->
      <div class="grid grid-cols-6 gap-2 text-sm">
        <div
          v-for="item in monthlyData"
          :key="item.month"
          class="text-center p-2 bg-gray-50 dark:bg-gray-800 rounded"
        >
          <div class="font-medium text-gray-600 dark:text-gray-400">
            {{ getMonthName(item.month) }}
          </div>
          <div class="font-semibold mt-1">
            {{ formatNumber(item.value) }} {{ unit }}
          </div>
        </div>
      </div>

      <!-- Annual total -->
      <div class="border-t pt-4 text-center">
        <div class="text-sm text-gray-600 dark:text-gray-400">{{ $t('survey.monthly.annualTotal') }}</div>
        <div class="text-xl font-bold mt-1">
          {{ formatNumber(annualTotal) }} {{ unit }}
        </div>
      </div>
    </div>

    <!-- Footer -->
    <template #footer>
      <UIButtonEnhanced
        variant="outline"
        @click="closeModal"
      >
        {{ $t('survey.monthly.close') }}
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { MonthlyBreakdown } from '~/composables/useEnergySavings'

interface Props {
  modelValue: boolean
  title: string
  monthlyData: MonthlyBreakdown[]
  unit: string
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const { t } = useI18n()

const isOpen = ref(false)

// Sync isOpen with modelValue
watch(() => props.modelValue, (newValue) => {
  isOpen.value = newValue
})

watch(isOpen, (newValue) => {
  emit('update:modelValue', newValue)
})

const monthNames = computed(() => [
  t('energy.monthsShort.jan'),
  t('energy.monthsShort.feb'),
  t('energy.monthsShort.mar'),
  t('energy.monthsShort.apr'),
  t('energy.monthsShort.may'),
  t('energy.monthsShort.jun'),
  t('energy.monthsShort.jul'),
  t('energy.monthsShort.aug'),
  t('energy.monthsShort.sep'),
  t('energy.monthsShort.oct'),
  t('energy.monthsShort.nov'),
  t('energy.monthsShort.dec')
])

const getMonthName = (month: number) => monthNames.value[month - 1]

const annualTotal = computed(() =>
  props.monthlyData.reduce((sum, item) => sum + item.value, 0)
)

const chartSeries = computed(() => [
  {
    name: props.title,
    data: props.monthlyData.map(item => item.value)
  }
])

const chartOptions = computed(() => ({
  chart: {
    type: 'bar',
    toolbar: {
      show: false
    }
  },
  plotOptions: {
    bar: {
      borderRadius: 4,
      dataLabels: {
        position: 'top'
      }
    }
  },
  dataLabels: {
    enabled: true,
    formatter: (val: number) => formatNumber(val),
    offsetY: -20,
    style: {
      fontSize: '12px',
      colors: ['#304758']
    }
  },
  xaxis: {
    categories: monthNames.value,
    position: 'bottom',
    labels: {
      style: {
        fontSize: '12px'
      }
    }
  },
  yaxis: {
    labels: {
      formatter: (val: number) => formatNumber(val)
    },
    title: {
      text: props.unit
    }
  },
  colors: ['#10b981'],
  grid: {
    borderColor: '#f1f1f1',
    padding: {
      top: 0,
      right: 20,
      bottom: 0,
      left: 10
    }
  },
  tooltip: {
    y: {
      formatter: (val: number) => `${formatNumber(val)} ${props.unit}`
    }
  }
}))

const formatNumber = (value: number): string => {
  return new Intl.NumberFormat('hu-HU').format(Math.round(value))
}

const closeModal = () => {
  isOpen.value = false
}
</script>
