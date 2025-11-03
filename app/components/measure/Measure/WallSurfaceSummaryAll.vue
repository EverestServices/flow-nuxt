<template>
  <div v-if="hasAnyArea" class="mb-8 mt-8 px-0 mx-1 py-6 pt-8 border-t-2 border-primary-500/30">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Nyílászáró -->
      <div
        v-if="totalAreas.windowDoorArea > 0"
        class="stat flex bg-emerald-500/10 dark:bg-emerald-500/20 backdrop-blur-md shadow-lg border border-emerald-500/40 rounded-2xl p-5 gap-4 transition-all duration-200 hover:shadow-xl hover:scale-105"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-emerald-500/20 rounded-full border border-emerald-500/30">
          <Icon name="i-lucide-door-open" class="w-8 h-8 text-emerald-700 dark:text-emerald-400" />
        </div>
        <div>
          <div class="stat-title text-base text-emerald-700 dark:text-emerald-400 font-semibold mb-1">Nyílászárók területe</div>
          <div class="stat-value text-3xl text-emerald-900 dark:text-emerald-300 font-extrabold">
            {{ formatArea(totalAreas.windowDoorArea) }} m²
          </div>
        </div>
      </div>

      <!-- Homlokzat bruttó -->
      <div
        v-if="totalAreas.facadeGrossArea > 0"
        class="stat flex bg-sky-500/10 dark:bg-sky-500/20 backdrop-blur-md shadow-lg border border-sky-500/40 rounded-2xl p-5 gap-4 transition-all duration-200 hover:shadow-xl hover:scale-105"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-sky-500/20 rounded-full border border-sky-500/30">
          <Icon name="i-lucide-building-2" class="w-8 h-8 text-sky-700 dark:text-sky-400" />
        </div>
        <div>
          <div class="stat-title text-base text-sky-700 dark:text-sky-400 font-semibold mb-1">Homlokzat – bruttó</div>
          <div class="stat-value text-3xl text-sky-900 dark:text-sky-300 font-extrabold">
            {{ formatArea(totalAreas.facadeGrossArea) }} m²
          </div>
        </div>
      </div>

      <!-- Homlokzat nettó -->
      <div
        v-if="totalAreas.facadeNetArea > 0"
        class="stat flex bg-sky-500/10 dark:bg-sky-500/20 backdrop-blur-md shadow-lg border border-sky-500/40 rounded-2xl p-5 gap-4 transition-all duration-200 hover:shadow-xl hover:scale-105"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-sky-500/20 rounded-full border border-sky-500/30">
          <Icon name="i-lucide-building" class="w-8 h-8 text-sky-700 dark:text-sky-400" />
        </div>
        <div>
          <div class="stat-title text-base text-sky-700 dark:text-sky-400 font-semibold mb-1">Homlokzat – nettó</div>
          <div class="stat-value text-3xl text-sky-900 dark:text-sky-300 font-extrabold">
            {{ formatArea(totalAreas.facadeNetArea) }} m²
          </div>
        </div>
      </div>

      <!-- Lábazat bruttó -->
      <div
        v-if="totalAreas.wallPlinthArea > 0"
        class="stat flex bg-yellow-500/10 dark:bg-yellow-500/20 backdrop-blur-md shadow-lg border border-yellow-500/40 rounded-2xl p-5 gap-4 transition-all duration-200 hover:shadow-xl hover:scale-105"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-yellow-500/20 rounded-full border border-yellow-500/30">
          <Icon name="i-lucide-layers" class="w-8 h-8 text-yellow-700 dark:text-yellow-400" />
        </div>
        <div>
          <div class="stat-title text-base text-yellow-700 dark:text-yellow-400 font-semibold mb-1">Lábazat – bruttó</div>
          <div class="stat-value text-3xl text-yellow-900 dark:text-yellow-300 font-extrabold">
            {{ formatArea(totalAreas.wallPlinthArea) }} m²
          </div>
        </div>
      </div>

      <!-- Lábazat nettó -->
      <div
        v-if="totalAreas.wallPlinthNetArea > 0"
        class="stat flex bg-yellow-500/10 dark:bg-yellow-500/20 backdrop-blur-md shadow-lg border border-yellow-500/40 rounded-2xl p-5 gap-4 transition-all duration-200 hover:shadow-xl hover:scale-105"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-yellow-500/20 rounded-full border border-yellow-500/30">
          <Icon name="i-lucide-layout" class="w-8 h-8 text-yellow-700 dark:text-yellow-400" />
        </div>
        <div>
          <div class="stat-title text-base text-yellow-700 dark:text-yellow-400 font-semibold mb-1">Lábazat – nettó</div>
          <div class="stat-value text-3xl text-yellow-900 dark:text-yellow-300 font-extrabold">
            {{ formatArea(totalAreas.wallPlinthNetArea) }} m²
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useWallStore } from '@/stores/WallStore';

const store = useWallStore();

const totalAreas = computed(() => {
  const result = {
    facadeGrossArea: 0,
    facadeNetArea: 0,
    windowDoorArea: 0,
    wallPlinthArea: 0,
    wallPlinthNetArea: 0,
  };
  for (const wall of Object.values(store.walls)) {
    const areas = store.getWallSurfaceAreas(wall.id);
    if (areas) {
      result.facadeGrossArea += areas.facadeGrossArea;
      result.facadeNetArea += areas.facadeNetArea;
      result.windowDoorArea += areas.windowDoorArea;
      result.wallPlinthArea += areas.wallPlinthArea;
      result.wallPlinthNetArea += areas.wallPlinthNetArea;
    }
  }

  return result;
});

const hasAnyArea = computed(
  () =>
    totalAreas.value.facadeGrossArea > 0 ||
    totalAreas.value.facadeNetArea > 0 ||
    totalAreas.value.windowDoorArea > 0 ||
    totalAreas.value.wallPlinthArea > 0 ||
    totalAreas.value.wallPlinthNetArea > 0,
);

const formatArea = (value: number): string => {
  return `${value.toFixed(2)}`;
};
</script>
