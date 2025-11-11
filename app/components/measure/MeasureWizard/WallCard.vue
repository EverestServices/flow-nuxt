<template>
  <div class="w-full rounded-3xl bg-white/20 dark:bg-black/20 backdrop-blur-md border border-white dark:border-black/10 overflow-hidden hover:shadow-2xl transition-all duration-300 hover:bg-white/30 dark:hover:bg-black/30">
    <!-- KÉP -->
    <div class="relative w-full aspect-video ">
      <!-- Ha van kép és feldolgozva, akkor a képre kattintva is menjen mérésre -->
      <RouterLink
        v-if="(wall.images[0]?.processedImageUrl || wall.images[0]?.previewUrl) && wall.images[0]?.uploadStatus === 'success'"
        :to="`/survey/${String(route.params.surveyId)}/measure/${wall.id}`"
        class="block"
      >
        <img
          :src="wall.images[0].processedImageUrl || wall.images[0].previewUrl"
          class="object-cover w-full h-64"
          alt="Falfotó"
        />
      </RouterLink>
      <!-- Ha van kép, de még nincs kész, csak mutassuk -->
      <img
        v-else-if="wall.images[0]?.processedImageUrl || wall.images[0]?.previewUrl"
        :src="wall.images[0].processedImageUrl || wall.images[0].previewUrl"
        class="object-cover w-full h-64"
        alt="Falfotó"
      />

      <!-- Ha nincs kép -->
      <label
        v-else
        class="w-full h-full flex flex-col items-center justify-center text-center text-gray-700 dark:text-gray-300 border-2 border-dashed border-white/50 dark:border-black/30 hover:border-primary-500 dark:hover:border-primary-500 cursor-pointer hover:bg-white/20 dark:hover:bg-black/20 transition-all backdrop-blur-xs"
      >
        <Icon name="i-lucide-camera" class="w-10 h-10 mb-2" />
        <p class="text-sm font-medium">Tölts fel egy képet a falról!</p>
        <input
          type="file"
          accept="image/*"
          class="absolute inset-0 opacity-0 cursor-pointer"
          @change="$emit('image-change', wall, wall.images[0], $event)"
        />
      </label>

      <!-- STÁTUSZ -->
      <span
        role="alert"
        class="absolute top-2 left-2 px-3 py-1.5 rounded-lg flex items-center gap-2 backdrop-blur-sm font-medium text-sm shadow-lg"
        :class="{
          'bg-red-500/90 text-white': wallStatus === 'error',
          'bg-yellow-500/90 text-white': wallStatus === 'pending',
          'bg-green-500/90 text-white': wallStatus === 'ready',
          'bg-gray-700/90 text-gray-200': wallStatus === 'unknown',
        }"
      >
        <span class="flex items-center gap-1">
          <Icon v-if="wallStatus === 'error'" name="i-lucide-alert-triangle" class="w-4 h-4" />
          <Icon v-else-if="wallStatus === 'pending'" name="i-lucide-loader-2" class="w-4 h-4 animate-spin" />
          <Icon v-else-if="wallStatus === 'ready' && isMeasured" name="i-lucide-ruler" class="w-4 h-4" />
          <Icon v-else-if="wallStatus === 'ready'" name="i-lucide-check-circle" class="w-4 h-4" />
          <Icon v-else name="i-lucide-file-plus" class="w-4 h-4" />
          {{ wallStatusText }}
        </span>
      </span>

      <!-- KÉP ÁLLAPOT -->
      <div
        v-if="wall.images[0]?.uploadStatus"
        class="absolute bottom-2 left-2 text-sm flex items-center gap-2 bg-white/20 dark:bg-black/20 backdrop-blur-md px-3 py-1.5 rounded-full shadow-lg border border-white/30 dark:border-black/20"
      >
        <UBadge :color="statusColor(wall.images[0]?.uploadStatus)" size="xs" class="capitalize font-semibold">
          {{ wall.images[0]?.uploadStatus }}
        </UBadge>
        <span class="text-gray-800 dark:text-gray-300 text-xs font-medium">
          {{ wall.images[0]?.message }}
        </span>
      </div>

      <!-- MÉRÉS gomb -->
      <div v-if="wall.images[0]?.uploadStatus === 'success'" class="absolute top-2 right-2">
        <UButton
          :to="`/survey/${String(route.params.surveyId)}/measure/${wall.id}`"
          :color="isMeasured ? 'neutral' : 'warning'"
          size="sm"
          class="gap-1"
        >
          <Icon name="i-lucide-ruler" class="w-4 h-4" /> Mérés
        </UButton>
      </div>
    </div>

    <!-- TARTALOM -->
    <div class="p-5 space-y-4">
      <!-- FEJLÉC -->
      <div class="flex justify-between items-center">
        <div class="flex items-center gap-3 font-medium">
          <div class="flex items-center justify-center w-10 h-10 rounded-full bg-primary-500/20 backdrop-blur-xs border border-primary-500/30">
            <span class="text-lg font-bold text-primary-600 dark:text-primary-400">#{{ index + 1 }}</span>
          </div>

          <span
            v-if="!editingName"
            class="inline-flex items-center cursor-pointer font-semibold text-gray-800 dark:text-gray-200 border border-white/40 dark:border-black/20 rounded-full px-4 py-2 bg-white/20 dark:bg-black/20 hover:bg-white/30 dark:hover:bg-black/30 transition-all backdrop-blur-xs shadow-sm"
            @click="startEditing"
          >
            <span class="pr-2 leading-none">{{ wall.name || 'Névtelen fal' }}</span>
            <Icon name="i-lucide-pencil" class="h-4 w-4 shrink-0 opacity-60" />
          </span>

          <UInput
            v-else
            v-model="wall.name"
            type="text"
            size="sm"
            class="h-7"
            @blur="stopEditing"
            @keyup.enter="stopEditing"
          />
        </div>

        <button
          v-if="canRemove"
          @click="$emit('remove', wall.id)"
          class="p-2 rounded-full bg-red-500/20 hover:bg-red-500/30 border border-red-500/30 transition-all backdrop-blur-xs text-red-600 dark:text-red-400"
        >
          <Icon name="i-lucide-trash-2" class="w-5 h-5" />
        </button>
      </div>

      <!-- ÖSSZEGZÉS -->
      <div v-if="store.hasPolygons(String(route.params.surveyId), wall.id)">
        <WallSurfaceSummary :wallId="wall.id" />
      </div>
      <div v-if="!isMeasured">
        <div class="flex justify-center items-center text-sm h-24 text-center">
          <UAlert color="warning" variant="soft">
            <template #description>
              <div class="flex items-center gap-2"><Icon name="i-lucide-alert-triangle" class="w-4 h-4" />A fal még nem lett lemérve.</div>
            </template>
          </UAlert>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue';
import { useWallStore } from '@/stores/WallStore';
import type { Wall } from '@/model/Measure/ArucoWallSurface';
import WallSurfaceSummary from '../Measure/WallSurfaceSummary.vue';
import { RouterLink, useRoute } from 'vue-router';

const props = defineProps<{
  wall: Wall;
  index: number;
  canRemove: boolean;
}>();

const emit = defineEmits(['remove', 'add-image', 'remove-image', 'image-change']);

const store = useWallStore();
const editingName = ref(false);
const route = useRoute();

function startEditing() {
  editingName.value = true;
  nextTick(() => {
    const input = document.querySelector<HTMLInputElement>('input[type="text"]:focus');
    input?.select();
  });
}
function stopEditing() {
  editingName.value = false;
}

const statusColor = (status: string) => {
  switch (status) {
    case 'pending':
      return 'info';
    case 'success':
      return 'success';
    case 'failed':
      return 'error';
    default:
      return 'neutral';
  }
};

const wallStatus = computed(() => {
  const statuses = props.wall.images.map((img) => img.uploadStatus);
  if (statuses.includes('failed')) return 'error';
  if (statuses.includes('pending')) return 'pending';
  if (statuses.every((s) => s === 'success')) return 'ready';
  return 'unknown';
});

const wallStatusText = computed(() => {
  if (wallStatus.value === 'error') return 'Hiba';
  if (wallStatus.value === 'pending') return 'Feldolgozás';
  if (wallStatus.value === 'ready') {
    return isMeasured.value ? 'Mérve' : 'Feldolgozva';
  }
  return 'Új';
});

const isMeasured = computed(() => store.hasPolygons(String(route.params.surveyId), props.wall.id));
</script>
