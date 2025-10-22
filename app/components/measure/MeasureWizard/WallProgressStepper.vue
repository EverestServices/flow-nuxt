<template>
  <div class="w-full overflow-x-auto px-5 py-4">
    <div class="flex items-center gap-3 min-w-max">
      <template v-for="(wall, index) in walls" :key="wall.id">
        <Icon v-if="index > 0" name="i-lucide-chevron-right" class="text-secondary/50" />
        <UButton
          :to="`/survey/${String(route.params.surveyId)}/measure/${String(wall.id)}`"
          :color="getStepClass(wall)"
          :variant="wallIsActive(wall) ? 'solid' : 'soft'"
          class="rounded-full"
        >
          <span
            class="mr-2 inline-flex items-center justify-center rounded-full bg-white/20 text-white w-6 h-6 text-xs font-semibold"
          >
            {{ index + 1 }}
          </span>
          <span class="truncate max-w-[12rem]">
            {{ wall.name || `Falfelület #${index + 1}` }}
          </span>
          <UBadge :color="getStepClass(wall)" variant="subtle" size="xs" class="ml-2 !text-white">
            {{ getStatusLabel(wall) }}
          </UBadge>
        </UButton>
      </template>
    </div>
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

const activeWallId = computed(() => (route.params.wallId ? String(route.params.wallId) : null));

const getStepClass = (wall: Wall) => {
  if (store.hasPolygons(wall.id)) {
    return 'success';
  } else if (wall.images.some((img) => img.uploadStatus === 'success')) {
    return 'primary';
  } else {
    return 'neutral';
  }
};

const wallIsActive = (wall: Wall): boolean => wall.id === activeWallId.value;

const getStatusLabel = (wall: Wall): string => {
  if (store.hasPolygons(wall.id)) return 'Kész';
  if (wall.images.some((img) => img.uploadStatus === 'success')) return 'Kép kész';
  return 'Nincs kép';
};
</script>
