<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  title: string;
  value: number;
  color: 'emerald' | 'sky' | 'yellow';
}>();

const colorClass = computed(() => {
  const colors = {
    emerald: {
      bg: 'bg-emerald-500/10 dark:bg-emerald-500/20',
      border: 'border-emerald-500/40',
      title: 'text-emerald-700 dark:text-emerald-400',
      value: 'text-emerald-900 dark:text-emerald-300',
    },
    sky: {
      bg: 'bg-sky-500/10 dark:bg-sky-500/20',
      border: 'border-sky-500/40',
      title: 'text-sky-700 dark:text-sky-400',
      value: 'text-sky-900 dark:text-sky-300',
    },
    yellow: {
      bg: 'bg-yellow-500/10 dark:bg-yellow-500/20',
      border: 'border-yellow-500/40',
      title: 'text-yellow-700 dark:text-yellow-400',
      value: 'text-yellow-900 dark:text-yellow-300',
    },
  };
  return colors[props.color];
});
</script>

<template>
  <div
    class="rounded-2xl border backdrop-blur-sm shadow-md px-3 py-3 flex flex-col items-center text-center transition-all duration-200 hover:shadow-lg hover:scale-105"
    :class="[colorClass.bg, colorClass.border]"
  >
    <!-- Slotos ikon -->
    <slot name="icon" />

    <!-- Cím -->
    <div class="text-sm font-semibold mb-2" :class="colorClass.title">
      {{ title }}
    </div>

    <div class="flex-grow"></div>
    <div class="w-4/5 border-t mb-2 opacity-60" :class="colorClass.border" />

    <div class="text-2xl font-bold leading-none" :class="colorClass.value">
      {{ value.toFixed(2) }}
      <div class="text-sm font-bold inline-block" :class="colorClass.value">m²</div>
    </div>
  </div>
</template>
