<template>
  <div v-if="hasAnyArea" class="mb-8 mt-8 px-0 mx-1 py-4 pt-6 border-t-6 border-primary">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <!-- Nyílászáró -->
      <div
        v-if="totalAreas.windowDoorArea > 0"
        class="stat flex bg-emerald-50 shadow-xl border border-emerald-200 rounded-xl p-4 gap-4"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-emerald-200/50 rounded-full">
          <DoorOpen class="w-8 h-8 text-emerald-800" />
        </div>
        <div>
          <div class="stat-title text-lg text-emerald-800 font-semibold">Nyílászárók területe</div>
          <div class="stat-value text-3xl text-emerald-900 font-extrabold">
            {{ formatArea(totalAreas.windowDoorArea) }} m²
          </div>
        </div>
      </div>

      <!-- Homlokzat bruttó -->
      <div
        v-if="totalAreas.facadeGrossArea > 0"
        class="stat flex bg-sky-50 shadow-xl border border-sky-200 rounded-xl p-4 gap-4"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-sky-200/50 rounded-full">
          <Building2 class="w-8 h-8 text-sky-800" />
        </div>
        <div>
          <div class="stat-title text-lg text-sky-800 font-semibold">Homlokzat – bruttó</div>
          <div class="stat-value text-3xl text-sky-900 font-extrabold">
            {{ formatArea(totalAreas.facadeGrossArea) }} m²
          </div>
        </div>
      </div>

      <!-- Homlokzat nettó -->
      <div
        v-if="totalAreas.facadeNetArea > 0"
        class="stat flex bg-sky-50 shadow-xl border border-sky-200 rounded-xl p-4 gap-4"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-sky-200/50 rounded-full">
          <Building class="w-8 h-8 text-sky-800" />
        </div>
        <div>
          <div class="stat-title text-lg text-sky-800 font-semibold">Homlokzat – nettó</div>
          <div class="stat-value text-3xl text-sky-900 font-extrabold">
            {{ formatArea(totalAreas.facadeNetArea) }} m²
          </div>
        </div>
      </div>

      <!-- Lábazat bruttó -->
      <div
        v-if="totalAreas.wallPlinthArea > 0"
        class="stat flex bg-yellow-50 shadow-xl border border-yellow-200 rounded-xl p-4 gap-4"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-yellow-200/50 rounded-full">
          <Layers class="w-8 h-8 text-yellow-800" />
        </div>
        <div>
          <div class="stat-title text-lg text-yellow-800 font-semibold">Lábazat – bruttó</div>
          <div class="stat-value text-3xl text-yellow-900 font-extrabold">
            {{ formatArea(totalAreas.wallPlinthArea) }} m²
          </div>
        </div>
      </div>

      <!-- Lábazat nettó -->
      <div
        v-if="totalAreas.wallPlinthNetArea > 0"
        class="stat flex bg-yellow-50 shadow-xl border border-yellow-200 rounded-xl p-4 gap-4"
      >
        <div class="flex items-center justify-center w-16 h-16 bg-yellow-200/50 rounded-full">
          <Layout class="w-8 h-8 text-yellow-800" />
        </div>
        <div>
          <div class="stat-title text-lg text-yellow-800 font-semibold">Lábazat – nettó</div>
          <div class="stat-value text-3xl text-yellow-900 font-extrabold">
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
import { DoorOpen, Building2, Building, Layers, Layout } from 'lucide-vue-next';

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
