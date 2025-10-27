<template>
  <div class="w-full overflow-x-auto p-0">
    <div class="flex items-center gap-1 min-w-max">
      <template v-for="(wall, index) in walls" :key="wall.id">
        <Icon v-if="index > 0" name="i-lucide-chevron-right" class="text-secondary/50" />
        <div class="inline-flex mx-1 sm:mx-2">
          <UButton
            :to="`/survey/${String(route.params.surveyId)}/measure/${String(wall.id)}`"
            :color="getStepClass(wall)"
            :variant="wallIsActive(wall) ? 'solid' : 'soft'"
            class="rounded-full px-3 py-1.5 min-w-[200px] sm:min-w-[240px]"
          >
            <div class="flex items-center gap-2 w-full overflow-hidden">
              <span
                class="inline-flex items-center justify-center rounded-full bg-white/20 text-white w-6 h-6 text-xs font-semibold"
              >
                {{ index + 1 }}
              </span>
              <span class="truncate max-w-[5.5rem] sm:max-w-[9rem] md:max-w-[12rem]">
                {{ wall.name || `Falfelület #${index + 1}` }}
              </span>
              <UBadge :color="getStepClass(wall)" variant="subtle" size="xs" class="!text-white shrink-0 hidden sm:inline-flex">
                {{ getStatusLabel(wall) }}
              </UBadge>
              <span class="ml-3 pl-3 border-l border-white/20 flex items-center gap-1.5 shrink-0 rounded-full bg-neutral-900/35 px-1.5 py-0.5 ring-1 ring-white/10">
                <span
                  class="rounded-full p-1.5 hover:bg-white/15"
                  title="Átnevezés"
                  @click.stop.prevent="renameWall(wall)"
                >
                  <Icon name="i-lucide-pencil" class="w-4 h-4 text-white" />
                </span>
                <span
                  class="rounded-full p-1.5 hover:bg-white/15"
                  title="Felület törlése"
                  @click.stop.prevent="deleteWall(wall)"
                >
                  <Icon name="i-lucide-trash-2" class="w-4 h-4 text-red-400 hover:text-red-300" />
                </span>
              </span>
            </div>
          </UButton>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Wall } from '@/model/Measure/ArucoWallSurface';
import { useWallStore } from '@/stores/WallStore';
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const store = useWallStore();
const route = useRoute();
const router = useRouter();

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

function renameWall(wall: Wall) {
  const current = wall.name || '';
  const next = typeof window !== 'undefined' ? window.prompt('Új falfelület név:', current) : null;
  if (next === null) return;
  const name = next.trim();
  store.setWall(wall.id, { ...wall, name });
}

function deleteWall(wall: Wall) {
  if (typeof window !== 'undefined') {
    const ok = window.confirm('Biztosan töröljük ezt a falfelületet?');
    if (!ok) return;
  }
  const activeId = activeWallId.value;
  store.removeWall(wall.id);
  // If the active wall was deleted, navigate to a sensible fallback
  if (activeId === wall.id) {
    const list = Object.values(store.walls);
    if (list.length > 0) {
      void router.push({ path: `/survey/${String(route.params.surveyId)}/measure/${String(list[0].id)}` });
    } else {
      void router.push({ path: `/survey/${String(route.params.surveyId)}/measure` });
    }
  }
}
</script>
