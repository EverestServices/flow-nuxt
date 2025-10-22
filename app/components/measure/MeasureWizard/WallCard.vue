<template>
  <div class="card bg-base-100 w-full shadow-md border border-base-300 overflow-hidden">
    <!-- KÉP -->
    <div class="relative w-full aspect-video bg-base-200">
      <!-- Ha van kép -->
      <img
        v-if="wall.images[0]?.processedImageUrl || wall.images[0]?.previewUrl"
        :src="wall.images[0].processedImageUrl || wall.images[0].previewUrl"
        class="object-cover w-full h-full"
        alt="Falfotó"
      />

      <!-- Ha nincs kép -->
      <label
        v-else
        class="w-full h-full flex flex-col items-center justify-center text-center text-base-content/70 border-2 border-dashed border-base-content/30 cursor-pointer"
      >
        <Icon name="i-lucide-camera" class="w-10 h-10 opacity-40 mb-2" />
        <p class="text-sm">Tölts fel egy képet a falról!</p>
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
        class="absolute top-2 left-2 px-2 py-0.5 border-x-4 flex items-center gap-1 bg-white shadow"
        :class="{
          'text-error/90': wallStatus === 'error',
          'text-warning': wallStatus === 'pending',
          'text-success': wallStatus === 'ready',
          'text-base-content': wallStatus === 'unknown',
          'border-error/70': wallStatus === 'error',
          'border-warning/80': wallStatus === 'pending',
          'border-success/80': wallStatus === 'ready',
          'border-base-content/80': wallStatus === 'unknown',
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
        class="absolute bottom-2 left-2 text-sm flex items-center gap-2 bg-white/90 px-2 py-1 rounded shadow-lg"
      >
        <UBadge :color="statusColor(wall.images[0]?.uploadStatus)" size="xs" class="capitalize">
          {{ wall.images[0]?.uploadStatus }}
        </UBadge>
        <span class="opacity-70">
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
    <div class="p-3 pt-2 space-y-2">
      <!-- FEJLÉC -->
      <div class="flex justify-between items-center">
        <div class="flex items-center gap-2 font-medium text-base-content">
          <Icon name="i-lucide-brick-wall" class="w-7 h-7" />
          <span class="text-lg font-bold">#{{ index + 1 }}</span>

          <span
            v-if="!editingName"
            class="inline-flex items-center cursor-pointer font-semibold text-primary border border-primary rounded-full pl-3 pr-2 py-1 bg-white"
            @click="startEditing"
          >
            <span class="pr-2 leading-none">{{ wall.name || 'Névtelen fal' }}</span>
            <Icon name="i-lucide-pencil" class="h-4 w-4 shrink-0" />
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

        <UButton
          v-if="canRemove"
          variant="ghost"
          color="error"
          class="p-1"
          @click="$emit('remove', wall.id)"
        >
          <Icon name="i-lucide-trash-2" class="w-7" />
        </UButton>
      </div>

      <!-- ÖSSZEGZÉS -->
      <div v-if="store.hasPolygons(wall.id)">
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

const isMeasured = computed(() => store.hasPolygons(props.wall.id));
</script>
