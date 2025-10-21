<template>
  <div v-if="filteredPolygons.length > 0" class="space-y-4">
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
      <AreaCard
        v-if="windowDoorArea > 0"
        :value="windowDoorArea"
        color="emerald"
        title="Nyílászáró"
      >
        <template #icon>
          <Icon name="i-lucide-door-open" class="w-7 h-7 text-emerald-700" />
        </template>
      </AreaCard>
      <AreaCard
        v-if="facadeGrossArea > 0"
        :value="facadeGrossArea"
        color="sky"
        title="Bruttó homlokzat"
      >
        <template #icon>
          <Icon name="i-lucide-building-2" class="w-7 h-7 text-sky-700" />
        </template>
      </AreaCard>
      <AreaCard v-if="facadeNetArea > 0" :value="facadeNetArea" color="sky" title="Nettó homlokzat">
        <template #icon>
          <Icon name="i-lucide-building" class="w-7 h-7 text-sky-700" />
        </template>
      </AreaCard>
      <AreaCard
        v-if="wallPlinthArea > 0"
        :value="wallPlinthArea"
        color="yellow"
        title="Lábazat bruttó"
      >
        <template #icon>
          <Icon name="i-lucide-layers" class="w-7 h-7 text-yellow-700" />
        </template>
      </AreaCard>
      <AreaCard
        v-if="wallPlinthNetArea > 0"
        :value="wallPlinthNetArea"
        color="yellow"
        title="Lábazat nettó"
      >
        <template #icon>
          <Icon name="i-lucide-layout" class="w-7 h-7 text-yellow-700" />
        </template>
      </AreaCard>
    </div>
  </div>

  <div class="space-y-2 mt-4">
    <div
      v-for="(polygon, index) in polygons"
      :key="polygon.id"
      class="flex items-center flex-wrap justify-between gap-4 bg-base-100 p-3 border rounded-xl shadow-sm cursor-pointer"
      :class="polygon.id === selectedId ? 'border-primary ring-2 ring-primary/60 bg-primary/5' : 'border-base-300'"
      @click="emit('select', polygon.id)"
    >
      <UButton
        :color="polygon.visible === false ? 'neutral' : 'primary'"
        variant="soft"
        size="sm"
        class="aspect-square p-2"
        @click.stop="toggleVisibility(index)"
        :title="polygon.visible === false ? 'Megjelenítés' : 'Elrejtés'"
      >
        <Icon v-if="polygon.visible === false" name="i-lucide-eye-off" class="w-5 h-5" />
        <Icon v-else name="i-lucide-eye" class="w-5 h-5" />
      </UButton>
      <select
        v-model="polygon.type"
        class="w-40 h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
        @click.stop
      >
        <option :value="SurfaceType.WALL_PLINTH">Lábazat</option>
        <option :value="SurfaceType.FACADE">Homlokzat bruttó</option>
        <option :value="SurfaceType.WINDOW_DOOR">Nyílászáró</option>
      </select>

      <div class="text-sm font-semibold text-right whitespace-nowrap min-w-12">
        {{ formatArea(polygon) }} m²
      </div>

      <UButton
        @click.stop="deletePolygon(polygon)"
        variant="ghost"
        color="error"
        size="sm"
        :title="`Törlés`"
      >
        <Icon name="i-lucide-trash-2" class="w-5 h-5" />
      </UButton>
    </div>
    <div class="text-end" v-if="filteredPolygons.length > 0">
      <UButton @click="confirmRemoveAll()" color="error" variant="soft" size="sm" class="tracking-wider">
        <Icon name="i-lucide-eraser" class="h-4 w-4" /> Felületek törlése
      </UButton>
    </div>
  </div>
</template>

<script lang="ts" setup>
import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import {
  subtractPolygonGroupsArea,
  unionPolygonsArea,
} from '@/service/Measurment/polygonDifference';
import { computed, watch, ref, onMounted } from 'vue';
import { clonePolygonData } from '@/stores/WallStore';
import AreaCard from './AreaCard.vue';

const surfaceTypeOptions = [
  { label: 'Lábazat', value: SurfaceType.WALL_PLINTH },
  { label: 'Homlokzat bruttó', value: SurfaceType.FACADE },
  { label: 'Nyílászáró', value: SurfaceType.WINDOW_DOOR },
];

const props = defineProps<{
  polygons: PolygonSurface[];
  meterPerPixel: number;
  imageNaturalWidth: number;
  imageNaturalHeight: number;
  wallId: string;
  selectedId?: string;
}>();
const emit = defineEmits<{
  (e: 'removePoligon', id: string): void;
  (e: 'removeAllPoligon'): void;
  (e: 'updateVisibility', index: number, value: boolean): void;
  (e: 'select', id: string): void;
}>();

const windowDoorArea = ref(0);
const facadeGrossArea = ref(0);
const facadeNetArea = ref(0);
const wallPlinthArea = ref(0);
const wallPlinthNetArea = ref(0);

const filteredPolygons = computed(() => props.polygons.filter((p) => p.closed));

const recalculate = () => {
  const getPolygonByType = (type: SurfaceType): PolygonSurface[] =>
    filteredPolygons.value.filter((p) => p.type === type);

  facadeGrossArea.value = unionPolygonsArea(
    clonePolygonData(getPolygonByType(SurfaceType.FACADE)),
    props.imageNaturalWidth,
    props.imageNaturalHeight,
    props.meterPerPixel,
  );

  windowDoorArea.value = unionPolygonsArea(
    clonePolygonData(getPolygonByType(SurfaceType.WINDOW_DOOR)),
    props.imageNaturalWidth,
    props.imageNaturalHeight,
    props.meterPerPixel,
  );

  wallPlinthArea.value = unionPolygonsArea(
    clonePolygonData(getPolygonByType(SurfaceType.WALL_PLINTH)),
    props.imageNaturalWidth,
    props.imageNaturalHeight,
    props.meterPerPixel,
  );

  facadeNetArea.value = subtractPolygonGroupsArea(
    clonePolygonData(getPolygonByType(SurfaceType.FACADE)),
    clonePolygonData(getPolygonByType(SurfaceType.WINDOW_DOOR)),
    props.imageNaturalWidth,
    props.imageNaturalHeight,
    props.meterPerPixel,
  );

  wallPlinthNetArea.value = subtractPolygonGroupsArea(
    clonePolygonData(getPolygonByType(SurfaceType.WALL_PLINTH)),
    clonePolygonData(getPolygonByType(SurfaceType.WINDOW_DOOR)),
    props.imageNaturalWidth,
    props.imageNaturalHeight,
    props.meterPerPixel,
  );
};

watch(
  () => [props.polygons, props.imageNaturalWidth, props.imageNaturalHeight, props.meterPerPixel],
  () => {
    recalculate();
  },
  { deep: true },
);

onMounted(() => {
  recalculate();
});

const calculatePolygonArea = (points: Point[]): number => {
  const denormPoints = points.map((p) => ({
    x: p.x * props.imageNaturalWidth,
    y: p.y * props.imageNaturalHeight,
  }));
  let area = 0;
  const n = denormPoints.length;
  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n;
    area += denormPoints[i].x * denormPoints[j].y - denormPoints[j].x * denormPoints[i].y;
  }
  return Math.abs(area / 2) * props.meterPerPixel * props.meterPerPixel;
};

const formatArea = (polygon: PolygonSurface): string => {
  if (!polygon.closed || polygon.points.length < 3) return '—';
  return calculatePolygonArea(polygon.points).toFixed(2);
};

const deletePolygon = (polygon: PolygonSurface) => emit('removePoligon', polygon.id);
const toggleVisibility = (index: number) => {
  const item = props.polygons[index];
  if (!item) return;
  const current = item.visible;
  const visible = current === undefined ? false : !current;
  emit('updateVisibility', index, visible);
};
// v-model on USelect directly updates polygon.type

function confirmRemoveAll() {
  if (typeof window !== 'undefined') {
    if (window.confirm('Biztosan töröljük az összes felületet?')) emit('removeAllPoligon');
  } else {
    emit('removeAllPoligon');
  }
}

function detectWindowDoorSurface(polygon: PolygonSurface): boolean {
  if (polygon.points.length < 3) return false;

  const area = calculatePolygonArea(polygon.points);
  if (area < 0.3 || area > 2.5) return false;

  const denormPoints = polygon.points.map((p) => ({
    x: p.x * props.imageNaturalWidth,
    y: p.y * props.imageNaturalHeight,
  }));

  const minX = Math.min(...denormPoints.map((p) => p.x));
  const maxX = Math.max(...denormPoints.map((p) => p.x));
  const minY = Math.min(...denormPoints.map((p) => p.y));
  const maxY = Math.max(...denormPoints.map((p) => p.y));

  const width = maxX - minX;
  const height = maxY - minY;

  const aspectRatio = width > height ? width / height : height / width;

  return aspectRatio < 5 && aspectRatio > 0.2; // Ne legyen túl lapos vagy túl vékony
}

function detectWallPlinthSurface(polygon: PolygonSurface): boolean {
  const points = polygon.points;
  if (points.length < 3) return false;

  // Denormalizált pontok (pixelben)
  const denormPoints = points.map((p) => ({
    x: p.x * props.imageNaturalWidth,
    y: p.y * props.imageNaturalHeight,
  }));

  const minY = Math.min(...denormPoints.map((p) => p.y));
  const maxY = Math.max(...denormPoints.map((p) => p.y));
  const height = maxY - minY;

  const aspectRatio =
    (Math.max(...denormPoints.map((p) => p.x)) - Math.min(...denormPoints.map((p) => p.x))) /
    height;

  const area = calculatePolygonArea(polygon.points);

  // Kritériumok:
  return (
    height < props.imageNaturalHeight * 0.15 && // kis magasság (~15% alatt)
    aspectRatio > 1.5 && // vízszintes kiterjedés
    area > 0.5 // ne legyen túl kicsi se
  );
}

function detectFacadeSurface(polygon: PolygonSurface): boolean {
  const points = polygon.points;
  if (points.length < 3) return false;

  const area = calculatePolygonArea(points);

  const imageArea =
    props.imageNaturalWidth * props.imageNaturalHeight * props.meterPerPixel * props.meterPerPixel;

  const coverageRatio = area / imageArea;

  // Kritérium: ha a kép legalább 15%-át lefedi
  return coverageRatio >= 0.15;
}

watch(
  () => props.polygons.map((p) => ({ id: p.id, type: p.type, closed: p.closed })),
  () => {
    for (const polygon of props.polygons) {
      if (!polygon.type && polygon.closed && polygon.points.length >= 3) {
        if (detectWallPlinthSurface(polygon)) {
          polygon.type = SurfaceType.WALL_PLINTH;
        } else if (detectFacadeSurface(polygon)) {
          polygon.type = SurfaceType.FACADE;
        } /* if (detectWindowDoorSurface(polygon)) */ else {
          polygon.type = SurfaceType.WINDOW_DOOR;
        }
      }
    }
  },
  { deep: true },
);
</script>

<style scoped>
.list-group-item {
  font-size: 14px;
}
</style>
