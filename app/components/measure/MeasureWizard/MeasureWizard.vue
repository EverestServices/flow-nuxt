<template>
  <div class="min-h-screen">
    <div class="">

      <WallProgressStepper />

      <!-- A lépés tartalma -->
      <slot />

      <!-- Navigációs gombok -->
      <div v-if="!isInMeasure" class="mt-8 flex justify-center">
        <UButton
          color="primary"
          size="lg"
          class="px-6"
          :disabled="!isValidToProceed"
          @click="goToFirstMeasure"
        >
          <Icon name="i-lucide-drafting-compass" class="w-5 h-5 mr-2" />
          Mérés indítása
        </UButton>
      </div>
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
const surveyId = computed(() => String(route.params.surveyId));
const wallList = computed(() => Object.values(store.getWallsForSurvey(surveyId.value)));
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
      path: `/survey/${String(route.params.surveyId)}/measure/${String(wallList.value[0].id)}`,
    });
  }
};

const getNextWallId = (): string | null => {
  const currentWallId = String(route.params.wallId ?? '');
  const wallIds: string[] = wallList.value.map((w) => String(w.id));
  const index = wallIds.indexOf(currentWallId);
  if (index >= 0 && index + 1 < wallIds.length) {
    return wallIds[index + 1];
  }
  return null;
};

const goToNextWall = () => {
  const nextWallId = getNextWallId();

  if (nextWallId) {
    void router.push({
      path: `/survey/${String(route.params.surveyId)}/measure/${String(nextWallId)}`,
    });
  } else {
    alert('Összes falfelület feldolgozva. Küldés vagy mentés következhet.');
    void router.push({
      path: `/survey/${String(route.params.surveyId)}/measure`,
    });
  }
};

const getPrevWallId = (): string | null => {
  const currentWallId = String(route.params.wallId ?? '');
  const wallIds: string[] = wallList.value.map((w) => String(w.id));
  const index = wallIds.indexOf(currentWallId);
  return index > 0 ? wallIds[index - 1] : null;
};

const goToPrevWall = () => {
  const prevWallId = getPrevWallId();
  if (prevWallId) {
    void router.push({
      path: `/survey/${String(route.params.surveyId)}/measure/${String(prevWallId)}`,
    });
  } else {
    void router.push({
      path: `/survey/${String(route.params.surveyId)}/measure`,
    });
  }
};
</script>
