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
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col">
        <!-- Header -->
        <div class="p-6 border-b border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              {{ title }}
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
              <div class="text-sm text-gray-600 dark:text-gray-400">Annual Total</div>
              <div class="text-xl font-bold mt-1">
                {{ formatNumber(annualTotal) }} {{ unit }}
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="p-6 border-t border-gray-200 dark:border-gray-700">
          <div class="flex justify-end">
            <button
              class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-600"
              @click="closeModal"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
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

const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
]

const getMonthName = (month: number) => monthNames[month - 1]

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
    categories: monthNames,
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
  emit('update:modelValue', false)
}
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
