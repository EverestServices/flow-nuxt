<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  title: string;
  value: number;
  color: 'emerald' | 'sky' | 'yellow';
}>();

const colorClass = computed(() => ({
  bg: `bg-${props.color}-50`,
  border: `border-${props.color}-200`,
  title: `text-${props.color}-800`,
  value: `text-${props.color}-900`,
}));
</script>

<template>
  <div
    class="rounded-2xl border-white dark:border-black shadow-sm px-2 py-2 flex flex-col items-center text-center"
    :class="[colorClass.bg, colorClass.border]"
  >
    <!-- Slotos ikon -->
    <slot name="icon" />

    <!-- Cím -->
    <div class="text-sm font-medium mb-1" :class="colorClass.title">
      {{ title }}
    </div>

    <div class="flex-grow"></div>
    <div class="w-4/5 border-t mb-1.5 opacity-90" :class="colorClass.border" />

    <div class="text-2xl font-bold leading-none mb-1" :class="colorClass.value">
      {{ value.toFixed(2) }}
      <div class="text-sm font-bold inline-block" :class="colorClass.value">m²</div>
    </div>
  </div>
</template>
