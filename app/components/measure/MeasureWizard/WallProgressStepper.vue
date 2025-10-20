<template>
  <div class="w-full overflow-x-auto px-5 py-4">
    <ul class="steps steps-horizontal w-full">
      <li
        v-for="(wall, index) in walls"
        :key="wall.id"
        class="step"
        :data-content="index + 1"
        :class="getStepClass(wall)"
      >
        <!-- Lefelé mutató háromszög, ha aktív -->
        <div
          v-if="wallIsActive(wall)"
          class="absolute transform -translate-y-10 w-0 h-0 border-l-8 border-r-8 border-t-[8px] border-r-transparent border-l-transparent border-t-secondary/85"
        ></div>
        <RouterLink
          :to="`/energy/consultation/${String(route.params.clientId)}/measure/${String(wall.id)}`"
          class="block text-center mt-2"
          :class="{
            'text-md': wallIsActive(wall),
            'font-bold': wallIsActive(wall),
            'text-sm': !wallIsActive(wall),
          }"
        >
          {{ wall.name || `Falfelület #${index + 1}` }}
        </RouterLink>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import type { Wall } from '@/model/Measure/ArucoWallSurface';
import { useWallStore } from '@/stores/WallStore';
import { computed } from 'vue';
import { useRoute } from 'vue-router';

const store = useWallStore();
const route = useRoute();

const walls = computed(() => Object.values(store.walls));

const activeWallId = computed(() => {
  if (route.name === 'wall-measure' && route.params.wallId) {
    return String(route.params.wallId);
  }
  return null;
});

const getStepClass = (wall: Wall) => {
  const isActive = wall.id === activeWallId.value;

  if (store.hasPolygons(wall.id)) {
    return isActive ? 'step-success text-secondary' : 'step-success';
  } else if (wall.images.some((img) => img.uploadStatus === 'success')) {
    return isActive ? 'step-primary text-secondary' : 'step-primary';
  } else {
    return isActive ? 'step-neutral text-secondary' : 'step-neutral';
  }
};

const wallIsActive = (wall: Wall): boolean => wall.id === activeWallId.value;
</script>
