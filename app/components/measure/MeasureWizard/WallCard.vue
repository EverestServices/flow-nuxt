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
        <Camera class="w-10 h-10 opacity-40 mb-2" />
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
          <AlertTriangle v-if="wallStatus === 'error'" class="w-4 h-4" />
          <Loader2 v-else-if="wallStatus === 'pending'" class="w-4 h-4 animate-spin" />
          <RulerDimensionLine v-else-if="wallStatus === 'ready' && isMeasured" class="w-4 h-4" />
          <CheckCircle v-else-if="wallStatus === 'ready'" class="w-4 h-4" />
          <FilePlus v-else class="w-4 h-4" />
          {{ wallStatusText }}
        </span>
      </span>

      <!-- KÉP ÁLLAPOT -->
      <div
        v-if="wall.images[0]?.uploadStatus"
        class="absolute bottom-2 left-2 text-sm flex items-center gap-2 bg-white/90 px-2 py-1 rounded shadow-lg"
      >
        <span class="badge badge-xs capitalize" :class="statusColor(wall.images[0]?.uploadStatus)">
          {{ wall.images[0]?.uploadStatus }}
        </span>
        <span class="opacity-70">
          {{ wall.images[0]?.message }}
        </span>
      </div>

      <!-- MÉRÉS gomb -->
      <RouterLink
        v-if="wall.images[0]?.uploadStatus === 'success'"
        :to="{ name: 'wall-measure', params: { wallId: wall.id } }"
        class="absolute top-2 right-2 btn btn-sm btn-secondary gap-1"
        :class="{
          'btn-secondary': isMeasured,
          'btn-warning': !isMeasured,
        }"
      >
        <Ruler class="w-4 h-4" /> Mérés
      </RouterLink>
    </div>

    <!-- TARTALOM -->
    <div class="p-3 pt-2 space-y-2">
      <!-- FEJLÉC -->
      <div class="flex justify-between items-center">
        <div class="flex items-center gap-2 font-medium text-base-content">
          <BrickWall class="w-7 h-7" />
          <span class="text-lg font-bold">#{{ index + 1 }}</span>

          <span
            v-if="!editingName"
            class="inline-flex items-center cursor-pointer font-semibold text-primary border border-primary rounded-full pl-3 pr-2 py-1 bg-white"
            @click="startEditing"
          >
            <span class="pr-2 leading-none">{{ wall.name || 'Névtelen fal' }}</span>
            <Pencil class="h-4 w-4 shrink-0" />
          </span>

          <input
            v-else
            v-model="wall.name"
            type="text"
            class="input input-sm input-bordered h-7"
            @blur="stopEditing"
            @keyup.enter="stopEditing"
          />
        </div>

        <button
          v-if="canRemove"
          class="btn btn-md btn-ghost bg-base-100 p-1"
          @click="$emit('remove', wall.id)"
        >
          <Trash2 class="text-error w-7" />
        </button>
      </div>

      <!-- ÖSSZEGZÉS -->
      <div v-if="store.hasPolygons(wall.id)">
        <WallSurfaceSummary :wallId="wall.id" />
      </div>
      <div v-if="!isMeasured">
        <div class="flex justify-center items-center text-warning text-sm h-24 text-center">
          <div role="alert" class="alert alert-warning">
            <AlertTriangle class="w-4 h-4 mr-2" /> A fal még nem lett lemérve.
          </div>
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
import { RouterLink } from 'vue-router';
import {
  BrickWall,
  Trash2,
  AlertTriangle,
  Ruler,
  Camera,
  Loader2,
  CheckCircle,
  FilePlus,
  RulerDimensionLine,
  Pencil,
} from 'lucide-vue-next';

const props = defineProps<{
  wall: Wall;
  index: number;
  canRemove: boolean;
}>();

const emit = defineEmits(['remove', 'add-image', 'remove-image', 'image-change']);

const store = useWallStore();
const editingName = ref(false);

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
      return 'badge-info';
    case 'success':
      return 'badge-success';
    case 'failed':
      return 'badge-error';
    default:
      return 'badge-ghost';
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
