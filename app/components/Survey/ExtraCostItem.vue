<template>
  <div class="space-y-2 p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
    <!-- Header with toggle and price -->
    <div class="flex items-start justify-between gap-4">
      <div class="flex-1">
        <div class="flex items-center gap-3">
          <USwitch
            :model-value="selected"
            @update:model-value="$emit('toggle')"
          />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              {{ cost.name }}
            </p>
            <p v-if="cost.description" class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              {{ cost.description }}
            </p>
          </div>
        </div>
      </div>
      <div class="text-right">
        <p class="text-sm font-semibold text-gray-900 dark:text-white">
          {{ formatPrice(cost.price) }} Ft
        </p>
        <p v-if="cost.is_quantity_based" class="text-xs text-gray-500 dark:text-gray-400">
          / db
        </p>
      </div>
    </div>

    <!-- Quantity input (only for quantity-based costs) -->
    <div v-if="selected && cost.is_quantity_based" class="ml-11">
      <UInput
        type="number"
        :model-value="quantity"
        @update:model-value="$emit('update:quantity', Number($event))"
        placeholder="Mennyiség"
        min="1"
        size="sm"
        class="max-w-32"
      />
    </div>

    <!-- Notes textarea (when selected) -->
    <div v-if="selected" class="ml-11">
      <UTextarea
        :model-value="notes"
        @update:model-value="$emit('update:notes', $event)"
        placeholder="Megjegyzések..."
        :rows="2"
        size="sm"
      />
    </div>

    <!-- Subtotal (when selected) -->
    <div v-if="selected" class="ml-11 flex justify-end">
      <p class="text-sm font-medium text-primary-600 dark:text-primary-400">
        Részösszeg: {{ formatPrice(subtotal) }} Ft
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  cost: {
    id: string
    persist_name: string
    name: string
    description: string
    price: number
    is_quantity_based: boolean
    category: string
  }
  selected: boolean
  quantity: number
  notes: string
}

const props = defineProps<Props>()

defineEmits<{
  'toggle': []
  'update:quantity': [value: number]
  'update:notes': [value: string]
}>()

// Calculate subtotal
const subtotal = computed(() => {
  if (!props.selected) return 0
  return props.cost.price * (props.cost.is_quantity_based ? props.quantity : 1)
})

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('hu-HU').format(price)
}
</script>
