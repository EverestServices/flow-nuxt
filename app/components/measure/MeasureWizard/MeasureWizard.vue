<template>
  <div class="max-w-8xl mx-auto px-4 py-6">
    <h2 class="text-4xl text-primary font-extralight mb-4 tracking-widest text-center hidden">
      Falfelületek varázsló
    </h2>

    <WallProgressStepper class="mb-4" />

    <!-- A lépés tartalma -->
    <slot />

    <!-- Navigációs gombok -->
    <div v-if="!isInMeasure" class="mt-6 text-right">
      <UButton color="primary" class="pl-3" :disabled="!isValidToProceed" @click="goToFirstMeasure">
        <Icon name="i-lucide-drafting-compass" />
        Mérés indítása
      </UButton>
    </div>

    <div v-else class="mt-6 flex justify-between items-center">
      <UButton color="neutral" class="pl-2" @click="goToPrevWall">
        <Icon name="i-lucide-chevron-left" />
        Előző
      </UButton>
      <UButton
        color="primary"
        class="ml-auto pr-2"
        :disabled="!isValidToProceed"
        @click="goToNextWall"
      >
        Következő
        <Icon name="i-lucide-chevron-right" />
      </UButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useWallStore } from '@/stores/WallStore';
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import WallProgressStepper from './WallProgressStepper.vue';


const router = useRouter();
const route = useRoute();

const store = useWallStore();
const wallList = computed(() => Object.values(store.walls));
const MIN_WALL_COUNT = 4;

const allImagesReady = computed(() => {
  return (
    wallList.value.length >= MIN_WALL_COUNT &&
    wallList.value.every(
      (wall) =>
        Array.isArray(wall.images) &&
        wall.images.every((image) => image.uploadStatus === 'success' && image.processedImageUrl),
    )
  );
});

const isValidToProceed = computed(() => {
  return wallList.value.length >= MIN_WALL_COUNT && allImagesReady.value;
});

const isInMeasure = computed(() => Boolean(route.params.wallId));

const goToFirstMeasure = () => {
  if (wallList.value.length > 0 && wallList.value[0]) {
    void router.push({
      path: `/energy/consultation/${String(route.params.clientId)}/measure/${String(wallList.value[0].id)}`,
    });
  }
};

const getNextWallId = (): string | null => {
  const currentWallId = String(route.params.wallId);
  const wallIds = wallList.value.map((w) => w.id);
  const index = wallIds.indexOf(currentWallId);

  if (index >= 0 && index + 1 < wallIds.length && typeof wallIds[index + 1] === 'string') {
    return wallIds[index + 1];
  }
  return null;
};

const goToNextWall = () => {
  const nextWallId = getNextWallId();

  if (nextWallId) {
    void router.push({
      path: `/energy/consultation/${String(route.params.clientId)}/measure/${String(nextWallId)}`,
    });
  } else {
    alert('Összes falfelület feldolgozva. Küldés vagy mentés következhet.');
    void router.push({
      path: `/energy/consultation/${String(route.params.clientId)}/measure`,
    });
  }
};

const getPrevWallId = (): string | undefined => {
  const currentWallId = String(route.params.wallId);
  const index = wallList.value.findIndex((w) => w.id === currentWallId);
  return index > 0 ? wallList.value[index - 1].id : undefined;
};

const goToPrevWall = () => {
  const prevWallId = getPrevWallId();
  if (prevWallId) {
    void router.push({
      path: `/energy/consultation/${String(route.params.clientId)}/measure/${String(prevWallId)}`,
    });
  } else {
    void router.push({
      path: `/energy/consultation/${String(route.params.clientId)}/measure`,
    });
  }
};
</script>
