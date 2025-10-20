<template>
  <div class="flex items-center gap-2">
    <UButton
      v-for="filter in filters"
      :key="filter.value"
      :label="filter.label"
      :color="modelValue === filter.value ? 'primary' : 'gray'"
      :variant="modelValue === filter.value ? 'solid' : 'ghost'"
      size="sm"
      @click="$emit('update:modelValue', filter.value)"
    />
  </div>
</template>

<script setup lang="ts">
type DateFilter = 'today' | 'yesterday' | 'thisWeek' | 'lastWeek' | 'pending'

defineProps<{
  modelValue: DateFilter
}>()

defineEmits<{
  'update:modelValue': [value: DateFilter]
}>()

const filters = [
  { value: 'today' as const, label: 'Today' },
  { value: 'yesterday' as const, label: 'Yesterday' },
  { value: 'thisWeek' as const, label: 'This week' },
  { value: 'lastWeek' as const, label: 'Last week' },
  { value: 'pending' as const, label: 'Pending' }
]
</script>
