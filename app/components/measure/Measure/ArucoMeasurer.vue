<template>
  <div class="grid grid-cols-1 gap-4">
    <div class="max-w-md">
      <UAlert v-if="error" color="error" variant="soft">
        <template #title>Hiba történt!</template>
        <template #description>{{ error }}</template>
      </UAlert>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-4 gap-4" v-if="imageSrc">
    <div class="col-span-1">
      <div class="mb-3 pb-3 border-b-1 border-secondary/30 flex items-center justify-between gap-3">
        <UButton :to="`/survey/${String(route.params.surveyId)}/measure`" color="neutral">
          <Icon name="i-lucide-layout-list" class="h-5 w-5" />Vissza a falfelületek listára
        </UButton>

        <div class="ml-2">
          <span
            v-if="!editingWallName"
            class="inline-flex items-center cursor-pointer font-semibold text-primary border border-primary rounded-full pl-3 pr-2 py-1 bg-white"
            @click="startEditingWallName"
          >
            <span class="pr-2 leading-none">{{ wallName || 'Névtelen fal' }}</span>
            <Icon name="i-lucide-pencil" class="h-4 w-4 shrink-0" />
          </span>
          <UInput
            v-else
            v-model="wallName"
            type="text"
            size="sm"
            class="h-7 w-[12rem]"
            @blur="stopEditingWallName"
            @keyup.enter="stopEditingWallName"
          />
        </div>
      </div>

      <!-- Orientation selector under header divider -->
      <div class="mb-3">
        <label class="block text-xs text-gray-500 mb-1">Tájolás</label>
        <select
          :value="wallOrientation || ''"
          @change="onOrientationChange(($event.target as HTMLSelectElement).value)"
          class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
        >
          <option value="">—</option>
          <option v-for="opt in orientationOptions" :key="opt" :value="opt">{{ opt }}</option>
        </select>
      </div>

      <PolygonList
        v-if="imageRef"
        :wallId="wall.id"
        v-model:polygons="polygons"
        :meterPerPixel="meterPerPixel"
        :image-natural-height="imageRef.naturalHeight"
        :image-natural-width="imageRef.naturalWidth"
        :selected-id="selectedPolygonId ?? ''"
        @removePoligon="removePoligonsById"
        @removeAllPoligon="removeAllPoligon"
        @updateVisibility="onUpdateVisibility"
        @select="onListSelect"
      />

      <ExtraItemIcoList />
    </div>
    <div class="col-span-3">
      <div class="relative">
        <div ref="zoomContainerRef" class="overflow-auto border rounded" style="height: 70vh">
          <div
            class="relative inline-block"
            ref="zoomWrapperRef"
            :style="{
              width: `${imageWidth * zoomScale}px`,
              height: `${imageHeight * zoomScale}px`,
            }"
          >
            <img
              :src="imageSrc"
              ref="imageRef"
              @load="onImageLoad"
              class="select-none pointer-events-none w-full h-full"
            />
            <canvas
              ref="canvasRef"
              :class="[
                'absolute top-0 left-0',
                (editingMode || calibrationMode) ? 'cursor-crosshair' : (editPointsMode ? 'cursor-grab' : 'cursor-default')
              ]"
              :style="{ zIndex: 5 }"
              @click="handleCanvasClick"
              @mousedown="handleMouseDown"
              @mousemove="handleMouseMove"
              @mouseup="handleMouseUp"
              @touchstart="handleCanvasTouch"
            ></canvas>
            <!-- Inline calibration input overlay near the segment midpoint -->
            <div
              v-if="calibrationMode && calibrationStart && (calibrationEnd || mousePos) && calibrationMidOverlay"
              class="absolute z-30"
              :style="{ left: `${calibrationMidOverlay.x}px`, top: `${calibrationMidOverlay.y}px`, transform: 'translate(-50%, -120%)' }"
            >
              <div class="bg-neutral-900/80 text-white rounded-full px-2 py-1 flex items-center gap-2 shadow">
                <span class="text-xs" v-if="calibrationPx">{{ `${calibrationPx.toFixed(0)} px` }}</span>
                <UInput type="number" v-model="calibrationLength" placeholder="Hossz (cm)" size="xs" class="w-24" @keyup.enter="applyCalibration" />
                <UButton color="success" size="xs" type="button" @click="applyCalibration">Alkalmaz</UButton>
              </div>
            </div>

            <!-- Single-point delete overlay near the selected vertex -->
            <div
              v-if="editPointsMode && singlePointOverlay"
              class="absolute z-30"
              :style="{ left: `${singlePointOverlay.x}px`, top: `${singlePointOverlay.y}px`, transform: 'translate(14px, -14px)' }"
            >
              <UButton size="xs" color="error" variant="solid" class="rounded-full p-1" title="Pont törlése" @click.stop="deleteSelectedPoints">
                <Icon name="i-lucide-trash-2" class="w-4 h-4" />
              </UButton>
            </div>
          </div>
        </div>
        <!-- Absolute overlays pinned to outer wrapper (not scrolling with content) -->
        <div class="pointer-events-none absolute inset-0 z-20">
          <div class="pointer-events-auto absolute right-2 top-2 flex items-center gap-2">
            <UButton size="md" color="neutral" variant="soft" class="p-2 rounded-full" @click="zoomBy(-0.1)">
              <Icon name="i-lucide-zoom-out" class="w-5 h-5" />
            </UButton>
            <UBadge color="neutral" size="sm">{{ (zoomScale * 100).toFixed(0) }}%</UBadge>
            <UButton size="md" color="neutral" variant="soft" class="px-3 py-2 rounded-full" @click="() => gotoZoom(1)">
              100%
            </UButton>
            <UButton size="md" color="neutral" variant="soft" class="p-2 rounded-full" @click="zoomBy(+0.1)">
              <Icon name="i-lucide-zoom-in" class="w-5 h-5" />
            </UButton>
            <UBadge color="neutral" size="sm">{{ pixelPerMeterLabel }}</UBadge>
            <UBadge v-if="referenceSet" color="success" size="sm" class="px-2 py-1">
              Referenciapont beállítva
            </UBadge>
            <UButton size="md" color="neutral" variant="soft" class="p-2 rounded-full" @click="handleUndo">
              <Icon name="i-lucide-undo-2" class="w-5 h-5" />
            </UButton>
            <UButton size="md" color="neutral" variant="soft" class="p-2 rounded-full" @click="handleRedo">
              <Icon name="i-lucide-redo-2" class="w-5 h-5" />
            </UButton>
            <UButton size="md" color="neutral" variant="soft" class="p-2 rounded-full" @click="resetCurrentEdit">
              <Icon name="i-lucide-rotate-ccw" class="w-5 h-5" />
            </UButton>
          </div>

          <div class="pointer-events-auto absolute left-1/2 -translate-x-1/2 bottom-2 bg-base-100/80 backdrop-blur rounded-full shadow px-2 py-1 flex items-center gap-1">
            <UButton
              size="md"
              :color="!editingMode && !calibrationMode && !editPointsMode ? 'primary' : 'neutral'"
              variant="soft"
              @click="() => setMode('view')"
            >
              View
            </UButton>
            <UButton
              size="md"
              :color="editingMode ? 'primary' : 'neutral'"
              variant="soft"
              @click="() => setMode('draw')"
            >
              Draw Surface
            </UButton>
            <UButton
              size="md"
              :color="editPointsMode ? 'primary' : 'neutral'"
              variant="soft"
              @click="() => setMode('edit')"
            >
              Edit
            </UButton>
            <UButton
              size="md"
              :color="calibrationMode ? 'warning' : 'neutral'"
              variant="soft"
              @click="() => setMode('calibrate')"
            >
              Setup Reference
            </UButton>
          </div>

          <!-- Bottom-left: Download composed image with polygons -->
          <div class="pointer-events-auto absolute left-2 bottom-2">
            <UButton size="md" color="primary" variant="solid" class="px-3 py-2 rounded-full" @click="downloadWithPolygons">
              <Icon name="i-lucide-download" class="w-5 h-5" /> Letöltés
            </UButton>
          </div>

          <!-- Top-left: Reference controls (only in calibration mode) -->
          <div
            v-if="calibrationMode"
            class="pointer-events-auto absolute left-2 top-2 flex items-center gap-1 bg-base-100/80 backdrop-blur rounded-full shadow px-2 py-1"
          >
            <UButton
              size="md"
              variant="soft"
              color="neutral"
              @click="onStartNewReference"
              title="Új referencia hozzáadása"
            >
              <Icon name="i-lucide-wand-2" class="w-4 h-4" />
              <span class="ml-1 hidden sm:inline">Új hozzáadása</span>
            </UButton>
            <UButton
              size="md"
              variant="soft"
              color="neutral"
              :disabled="!referenceSet"
              @click="onChangeReferenceLength"
              title="Referencia méret módosítása"
            >
              <Icon name="i-lucide-ruler" class="w-4 h-4" />
              <span class="ml-1 hidden sm:inline">Méret módosítása</span>
            </UButton>
            <UButton
              size="md"
              variant="soft"
              color="error"
              :disabled="!referenceSet"
              @click="onClearReference"
              title="Referencia törlése"
            >
              <Icon name="i-lucide-trash-2" class="w-4 h-4" />
              <span class="ml-1 hidden sm:inline">Törlés</span>
            </UButton>
          </div>

          <!-- Calibration helper (only message, no buttons) -->
          <div v-if="calibrationMode" class="pointer-events-none absolute inset-x-0 top-2 flex justify-center">
            <div class="pointer-events-auto bg-neutral-900/80 text-white text-sm rounded-full px-3 py-1 flex items-center gap-2 shadow">
              <UBadge color="error" size="sm" class="px-2 py-0.5">Setup Reference</UBadge>
              <span>{{ calibrationInfoText }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, nextTick, onMounted, onBeforeUnmount, computed, watch, watchEffect, unref } from 'vue';
import { Orientation } from '@/model/Measure/ArucoWallSurface';
import PolygonList from './PolygonList.vue';
import type { Point, PolygonSurface, Wall } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import ExtraItemIcoList from './ExtraItemIcoList.vue';
import { useWallStore, clonePolygonData } from '@/stores/WallStore';
import { useRoute } from 'vue-router';
const store = useWallStore();
const route = useRoute();
const wallId = computed(() => String(route.params.wallId));
const wall = computed<Wall>(() => {
  const mapRaw = unref(store.walls) as Record<string, Wall> | undefined;
  const map: Record<string, Wall> = mapRaw ?? {};
  const w = map[wallId.value] as Wall | undefined;
  return w ?? ({ id: wallId.value, name: '', images: [], polygons: [] } as Wall);
});
const wallName = computed<string>({
  get: () => wall.value?.name ?? '',
  set: (val: string) => {
    if (wall.value) {
      store.setWall(wall.value.id, { ...wall.value, name: val });
    }
  },
});
const orientationOptions: Orientation[] = [
  Orientation.N, Orientation.NW, Orientation.W, Orientation.SW,
  Orientation.S, Orientation.SE, Orientation.E, Orientation.NE,
];
const wallOrientation = computed<Orientation | null>({
  get: () => (wall.value?.orientation ?? null) as Orientation | null,
  set: (val: Orientation | null) => {
    if (wall.value) {
      store.setWall(wall.value.id, { ...wall.value, orientation: val ?? undefined });
    }
  },
});
const onOrientationChange = (val: string) => {
  wallOrientation.value = (val ? (val as Orientation) : null);
};
const editingWallName = ref<boolean>(false);
const startEditingWallName = () => {
  editingWallName.value = true;
  void nextTick(() => {
    const input = document.querySelector<HTMLInputElement>('input[type="text"]:focus');
    input?.select();
  });
};
const stopEditingWallName = () => {
  editingWallName.value = false;
};
const firstImage = computed(() => wall.value?.images?.[0] ?? null);

const zoomScale = ref(1);
const imageSrc = computed(() => firstImage.value?.processedImageUrl || firstImage.value?.previewUrl || null);
const error = ref<string | null>(null);
const meterPerPixel = ref<number>(firstImage.value?.meterPerPixel || 0);
const storedMeterPerPixel = computed(() => firstImage.value?.meterPerPixel || 1);
const pixelPerMeterLabel = computed(() => {
  const mpp = meterPerPixel.value || 0;
  if (!mpp) return '— px/m';
  const val = 1 / mpp;
  return `${val.toFixed(1)} px/m`;
});
const imageRef = ref<HTMLImageElement | null>(null);
const canvasRef = ref<HTMLCanvasElement | null>(null);
const zoomContainerRef = ref<HTMLDivElement | null>(null);
const zoomWrapperRef = ref<HTMLDivElement | null>(null);
const polygons = computed({
  get: () => wall.value?.polygons ?? [],
  set: (newPolygons) => {
    if (wall.value) {
      store.setWall(wall.value.id, {
        ...wall.value,
        polygons: [...newPolygons],
      });
    }
  },
});

const currentPolygon = ref<PolygonSurface | null>(null);
const editingMode = ref<boolean>(false);
const editPointsMode = ref<boolean>(false);
const selectedPolygonId = ref<string | null>(null);
const draggingPoint = ref<{
  polygonId?: string;
  index: number;
  type: 'polygon' | 'calibration';
} | null>(null);
const selectedPoints = ref<Set<string>>(new Set());
const keyOf = (polyId: string, idx: number) => `${polyId}:${idx}`;
const clearSelection = () => {
  selectedPoints.value = new Set();
};
const isPointSelected = (polyId: string, idx: number) => selectedPoints.value.has(keyOf(polyId, idx));
const toggleSelection = (polyId: string, idx: number) => {
  const k = keyOf(polyId, idx);
  const next = new Set(selectedPoints.value);
  if (next.has(k)) next.delete(k);
  else next.add(k);
  selectedPoints.value = next;
};
const selectOnly = (polyId: string, idx: number) => {
  selectedPoints.value = new Set([keyOf(polyId, idx)]);
};
const mousePos = ref<Point | null>(null);
const calibrationStart = ref<Point | null>(null);
const calibrationEnd = ref<Point | null>(null);
const calibrationLength = ref<number | null>(null);
const calibrationMode = ref<boolean>(false);
const highlightRef = ref<boolean>(false);
const showSavedReference = ref<boolean>(false);
const allowRefOverride = ref<boolean>(false);

const referenceSet = computed(() => Boolean(firstImage.value?.referenceStart && firstImage.value?.referenceEnd));

const calibrationPx = computed(() => {
  if (!imageRef.value || !calibrationStart.value) return null as number | null;
  const end = calibrationEnd.value ?? mousePos.value;
  if (!end) return null as number | null;
  const dx = (end.x - calibrationStart.value.x) * imageRef.value.naturalWidth;
  const dy = (end.y - calibrationStart.value.y) * imageRef.value.naturalHeight;
  return Math.sqrt(dx * dx + dy * dy);
});

const calibrationInfoText = computed(() => {
  const px = calibrationPx.value;
  if (!calibrationStart.value) {
    return '1/2: Érintsd meg az első pontot a képen.';
  }
  if (calibrationStart.value && !calibrationEnd.value) {
    const pxPart = px ? ` • ${px.toFixed(0)} px` : '';
    return `2/2: Érintsd meg a második pontot.${pxPart}`;
  }
  return 'Add meg a referencia hosszát centiméterben, majd kattints az Alkalmaz gombra.';
});

const calibrationMidOverlay = computed(() => {
  if (!calibrationMode.value || !calibrationStart.value || !imageRef.value) return null as { x: number; y: number } | null;
  const endNorm = calibrationEnd.value ?? mousePos.value;
  if (!endNorm) return null as { x: number; y: number } | null;
  const p1 = denormalizePoint(calibrationStart.value);
  const p2 = denormalizePoint(endNorm);
  const mid = { x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2 };
  // shift by the image's offset inside the wrapper to align with canvas positioning
  return { x: imageRef.value.offsetLeft + mid.x, y: imageRef.value.offsetTop + mid.y };
});

// Ensure saved reference always applies: compute meterPerPixel from stored reference points + length
const recalcMeterPerPixelFromReference = (): boolean => {
  const imgMeta = firstImage.value;
  const img = imageRef.value;
  const lengthCm = imgMeta?.referenceLengthCm ?? 0;
  if (!imgMeta || !img || !imgMeta.referenceStart || !imgMeta.referenceEnd || !(lengthCm > 0)) return false;
  const dx = (imgMeta.referenceEnd.x - imgMeta.referenceStart.x) * img.naturalWidth;
  const dy = (imgMeta.referenceEnd.y - imgMeta.referenceStart.y) * img.naturalHeight;
  const pixelDist = Math.sqrt(dx * dx + dy * dy);
  if (!(pixelDist > 0)) return false;
  meterPerPixel.value = (lengthCm / 100) / pixelDist;
  return true;
};

const singlePointOverlay = computed(() => {
  if (!editPointsMode.value || selectedPoints.value.size !== 1 || !imageRef.value) return null as { x: number; y: number } | null;
  const firstKey = Array.from(selectedPoints.value)[0];
  if (!firstKey) return null as { x: number; y: number } | null;
  const parts = firstKey.split(':');
  if (parts.length !== 2) return null as { x: number; y: number } | null;
  const polyId = parts[0];
  const idx = Number(parts[1]);
  const poly = polygons.value.find((p) => p.id === polyId);
  const pt = poly?.points?.[idx];
  if (!poly || !pt) return null as { x: number; y: number } | null;
  const p = denormalizePoint(pt);
  const wrapper = zoomWrapperRef.value;
  let x = imageRef.value.offsetLeft + p.x + 16; // offset right
  let y = imageRef.value.offsetTop + p.y - 16; // offset up
  if (wrapper) {
    const maxX = wrapper.clientWidth - 8;
    const maxY = wrapper.clientHeight - 8;
    x = Math.min(maxX, Math.max(8, x));
    y = Math.min(maxY, Math.max(8, y));
  }
  return { x, y };
});

type HistoryEntry = {
  polygons: PolygonSurface[];
  current: PolygonSurface | null;
};
const undoStack = ref<HistoryEntry[]>([]);
const redoStack = ref<HistoryEntry[]>([]);

const snapshot = (): HistoryEntry => {
  const polyClone = clonePolygonData(polygons.value as PolygonSurface[]);
  const currentClone = currentPolygon.value
    ? clonePolygonData([currentPolygon.value as PolygonSurface])[0]
    : null;
  return { polygons: polyClone, current: currentClone } as HistoryEntry;
};
const applySnapshot = (s: HistoryEntry) => {
  polygons.value = clonePolygonData(s.polygons);
  currentPolygon.value = s.current
    ? (clonePolygonData([s.current as PolygonSurface])[0] as PolygonSurface) ?? null
    : null;
  drawAllPolygons();
};
const pushHistory = () => {
  undoStack.value.push(snapshot());
  redoStack.value = [];
};
const undo = () => {
  if (undoStack.value.length === 0) return;
  const prev = undoStack.value.pop()!;
  const cur = snapshot();
  redoStack.value.push(cur);
  applySnapshot(prev);
};
const redo = () => {
  if (redoStack.value.length === 0) return;
  const next = redoStack.value.pop()!;
  const cur = snapshot();
  undoStack.value.push(cur);
  applySnapshot(next);
};
const handleUndo = () => undo();
const handleRedo = () => redo();

const onUpdateVisibility = (index: number, value: boolean) => {
  const list = polygons.value as PolygonSurface[];
  const item = list[index];
  if (!item) return;
  item.visible = value;
  drawAllPolygons();
};

const onListSelect = (id: string) => {
  selectedPolygonId.value = id || null;
  drawAllPolygons();
};

const isNearPoint = (p1: Point, p2: Point): boolean => {
  const dx = p1.x - p2.x;
  const dy = p1.y - p2.y;
  return Math.sqrt(dx * dx + dy * dy) < 0.02;
};

const getCanvasCoords = (event: MouseEvent): Point => {
  const rect = canvasRef.value!.getBoundingClientRect();
  return {
    x: event.clientX - rect.left,
    y: event.clientY - rect.top,
  };
};

const normalizePoint = (point: Point): Point => {
  const rect = imageRef.value!.getBoundingClientRect();
  return {
    x: point.x / rect.width,
    y: point.y / rect.height,
  };
};

const denormalizePoint = (norm: Point): Point => {
  const rect = imageRef.value!.getBoundingClientRect();
  return {
    x: norm.x * rect.width,
    y: norm.y * rect.height,
  };
};

const pointSegmentDistance = (p: Point, a: Point, b: Point): { dist: number; t: number } => {
  const ax = a.x, ay = a.y;
  const bx = b.x, by = b.y;
  const abx = bx - ax;
  const aby = by - ay;
  const apx = p.x - ax;
  const apy = p.y - ay;
  const ab2 = abx * abx + aby * aby;
  const dot = ab2 === 0 ? 0 : (apx * abx + apy * aby) / ab2;
  const t = Math.max(0, Math.min(1, dot));
  const projx = ax + t * abx;
  const projy = ay + t * aby;
  const dx = p.x - projx;
  const dy = p.y - projy;
  return { dist: Math.hypot(dx, dy), t };
};

const isPointInPolygon = (pt: Point, points: Point[]): boolean => {
  let inside = false;
  for (let i = 0, j = points.length - 1; i < points.length; j = i++) {
    const xi = points[i].x, yi = points[i].y;
    const xj = points[j].x, yj = points[j].y;
    const intersect = (yi > pt.y) !== (yj > pt.y) && pt.x < ((xj - xi) * (pt.y - yi)) / (yj - yi) + xi;
    if (intersect) inside = !inside;
  }
  return inside;
};

// Hit-test for polygon edges (topmost first). Returns the segment endpoints if within threshold.
const findEdgeUnderPoint = (
  pt: Point,
): { polyId: string; index: number; a: Point; b: Point } | null => {
  const list = polygons.value as PolygonSurface[];
  let best: { polyId: string; index: number; a: Point; b: Point; dist: number } | null = null;
  for (let pIdx = list.length - 1; pIdx >= 0; pIdx--) {
    const poly = list[pIdx];
    if (!poly || poly.visible === false || !poly.closed || poly.points.length < 2) continue;
    const n = poly.points.length;
    let localBest: { polyId: string; index: number; a: Point; b: Point; dist: number } | null = null;
    for (let i = 0; i < n; i++) {
      const j = (i + 1) % n;
      const a = poly.points[i]!;
      const b = poly.points[j]!;
      const { dist } = pointSegmentDistance(pt, a, b);
      if (!localBest || dist < localBest.dist) localBest = { polyId: poly.id, index: i, a, b, dist };
    }
    if (localBest && localBest.dist < 0.02) {
      // Topmost polygon hit found
      return { polyId: localBest.polyId, index: localBest.index, a: localBest.a, b: localBest.b };
    }
    if (!best || (localBest && localBest.dist < best.dist)) best = localBest;
  }
  if (best && best.dist < 0.02) {
    return { polyId: best.polyId, index: best.index, a: best.a, b: best.b };
  }
  return null;
};

const calculatePolygonArea = (
  points: Point[],
  pixelSize: number,
  image: HTMLImageElement,
): number => {
  const denormPoints = points.map((p) => ({
    x: p.x * image.naturalWidth,
    y: p.y * image.naturalHeight,
  }));
  let area = 0;
  const n = denormPoints.length;
  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n;
    if (typeof denormPoints === 'object')
      area += denormPoints[i].x * denormPoints[j].y - denormPoints[j].x * denormPoints[i].y;
  }
  return Math.abs(area / 2) * pixelSize * pixelSize;
};

const getPolygonCenter = (points: Point[]): Point => {
  const sum = points.reduce((acc, p) => ({ x: acc.x + p.x, y: acc.y + p.y }), { x: 0, y: 0 });
  return {
    x: sum.x / points.length,
    y: sum.y / points.length,
  };
};

const drawText = (ctx: CanvasRenderingContext2D, text: string, x: number, y: number) => {
  ctx.font = 'bold 14px sans-serif';
  ctx.strokeStyle = 'black';
  ctx.lineWidth = 4;
  ctx.strokeText(text, x, y);
  ctx.fillStyle = 'white';
  ctx.fillText(text, x, y);
};

const handleCanvasTouch = (event: TouchEvent) => {
  if (!editPointsMode.value) return; // csak szerkesztés módban kezeljük a pontmozgatást érintéssel
  const touch = event.touches[0];
  const rect = canvasRef.value!.getBoundingClientRect();
  const touchPoint: Point = normalizePoint({
    x: touch.clientX - rect.left,
    y: touch.clientY - rect.top,
  });

  // Ha már van kijelölve pont: tiltjuk a görgetést, és áthelyezzük
  if (draggingPoint.value?.type === 'polygon') {
    event.preventDefault(); // csak ilyenkor tiltjuk
    const { polygonId, index } = draggingPoint.value;
    const polygon = polygons.value.find((p) => p.id === polygonId);
    if (polygon) {
      polygon.points[index] = touchPoint;
      draggingPoint.value = null;
      drawAllPolygons();
    }
    return;
  }

  // Ha nincs kijelölve: nézzük, közel van-e pont → ha igen, kijelöljük
  for (const polygon of polygons.value) {
    for (let i = 0; i < polygon.points.length; i++) {
      if (isNearPoint(touchPoint, polygon.points[i])) {
        event.preventDefault(); // csak akkor tiltunk, ha valóban kiválasztunk
        draggingPoint.value = {
          polygonId: polygon.id,
          index: i,
          type: 'polygon',
        };
        drawAllPolygons();
        return;
      }
    }
  }

  // Egyébként: nem tiltunk semmit → mehet a scroll/pinch
};

const drawCircle = (
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  radius = 7,
  strokeColor = '#f59e0b',
) => {
  ctx.beginPath();
  ctx.arc(x, y, radius, 0, 2 * Math.PI);
  ctx.fillStyle = '#ffffff';
  ctx.fill();
  ctx.lineWidth = 3;
  ctx.strokeStyle = strokeColor;
  ctx.stroke();
};

const getPolygonColors = (poly: PolygonSurface) => {
  switch (poly.type) {
    case SurfaceType.FACADE:
      return {
        strokeColor: '#f59e0b',
        fillColor: 'rgba(245,158,11,0.15)',
        pointColor: '#f59e0b',
      };
    case SurfaceType.WINDOW_DOOR:
      return {
        strokeColor: '#10b981',
        fillColor: 'rgba(16,185,129,0.2)',
        pointColor: 'rgba(16,185,129,0.7)',
      };
    case SurfaceType.WALL_PLINTH:
      return {
        strokeColor: '#f59e0b',
        fillColor: 'rgba(245,158,11,0.2)',
        pointColor: 'rgba(245,158,11,0.7)',
      };
    default:
      return {
        strokeColor: '#4b5563',
        fillColor: 'rgba(75,85,99,0.15)',
        pointColor: 'rgba(75,85,99,0.7)',
      };
  }
};

const roundRect = (
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  r: number,
) => {
  const min = Math.min(w, h) / 2;
  const radius = Math.min(r, min);
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + w - radius, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + radius);
  ctx.lineTo(x + w, y + h - radius);
  ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h);
  ctx.lineTo(x + radius, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
};

const drawLabel = (ctx: CanvasRenderingContext2D, text: string, x: number, y: number) => {
  ctx.save();
  ctx.font = 'bold 12px sans-serif';
  const metrics = ctx.measureText(text);
  const paddingX = 8;
  const paddingY = 4;
  const width = metrics.width + paddingX * 2;
  const height = 20;
  const rectX = x;
  const rectY = y - height + 4;
  ctx.globalAlpha = 0.85;
  ctx.fillStyle = '#111827';
  roundRect(ctx, rectX, rectY, width, height, 6);
  ctx.fill();
  ctx.globalAlpha = 1;
  ctx.fillStyle = '#ffffff';
  ctx.fillText(text, rectX + paddingX, rectY + height - 6);
  ctx.restore();
};

const drawAllPolygons = () => {
  const pixelSize = meterPerPixel.value;
  const canvas = canvasRef.value;
  const img = imageRef.value;
  if (!canvas || !img) return;

  const ctx = canvas.getContext('2d')!;
  const rect = img.getBoundingClientRect();
  canvas.width = rect.width;
  canvas.height = rect.height;
  canvas.style.width = `${rect.width}px`;
  canvas.style.height = `${rect.height}px`;
  canvas.style.left = img.offsetLeft + 'px';
  canvas.style.top = img.offsetTop + 'px';

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  const allPolygons = [...polygons.value];
  if (currentPolygon.value) allPolygons.push(currentPolygon.value);

  for (const poly of allPolygons) {
    if (poly.visible === false) continue;
    const denormPoints = poly.points.map(denormalizePoint);
    if (denormPoints.length < 1) continue;
    const { strokeColor, fillColor, pointColor } = getPolygonColors(poly);
    const isSelectedPoly = selectedPolygonId.value === poly.id;

    // Draw solid segments for existing points
    ctx.beginPath();
    ctx.setLineDash([]);
    ctx.moveTo(denormPoints[0].x, denormPoints[0].y);
    for (let i = 1; i < denormPoints.length; i++) {
      ctx.lineTo(denormPoints[i].x, denormPoints[i].y);
    }
    // Provisional dashed segment to cursor while drawing
    if (!poly.closed && currentPolygon.value && mousePos.value && denormPoints.length > 0) {
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = 2;
      ctx.stroke();

      const lastIndex = denormPoints.length - 1;
      if (lastIndex >= 0) {
        const last: Point = denormPoints[lastIndex]!;
        const mouse = denormalizePoint(mousePos.value);
        ctx.beginPath();
        ctx.setLineDash([6, 6]);
        ctx.moveTo(last.x, last.y);
        ctx.lineTo(mouse.x, mouse.y);
        ctx.stroke();
      }
    }
    if (poly.closed) {
      ctx.closePath();
      ctx.fillStyle = fillColor;
      ctx.fill();
    }
    ctx.strokeStyle = strokeColor;
    ctx.lineWidth = isSelectedPoly ? 3.5 : 2;
    if (isSelectedPoly) {
      ctx.save();
      ctx.shadowColor = strokeColor;
      ctx.shadowBlur = 8;
      ctx.stroke();
      ctx.restore();
    } else {
      ctx.stroke();
    }

    if (editingMode.value || editPointsMode.value || isSelectedPoly) {
      denormPoints.forEach((p, idx) => {
        const isSelected =
          draggingPoint.value?.type === 'polygon' &&
          draggingPoint.value.polygonId === poly.id &&
          draggingPoint.value.index === idx;

        const preSelected = isPointSelected(poly.id, idx);
        const showSelected = isSelected || preSelected;
        drawCircle(ctx, p.x, p.y, showSelected ? 9 : 7, showSelected ? '#22c55e' : pointColor);
      });
    }

    if (poly.closed && denormPoints.length >= 3) {
      for (let i = 0; i < denormPoints.length; i++) {
        const j = (i + 1) % denormPoints.length;
        const p1 = denormPoints[i];
        const p2 = denormPoints[j];
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        const pxDist = Math.sqrt(dx * dx + dy * dy);
        const length = (pxDist / rect.width) * img.naturalWidth * pixelSize;
        const midX = (p1.x + p2.x) / 2;
        const midY = (p1.y + p2.y) / 2;
        drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8);
      }
      const area = calculatePolygonArea(poly.points, pixelSize, img);
      const center = getPolygonCenter(denormPoints);
      drawLabel(ctx, `${area.toFixed(2)} m²`, center.x - 18, center.y - 8);
    }
  }
  if (calibrationMode.value && calibrationStart.value) {
    const ctx = canvasRef.value!.getContext('2d')!;
    const p1 = denormalizePoint(calibrationStart.value);
    const p2 = calibrationEnd.value
      ? denormalizePoint(calibrationEnd.value)
      : mousePos.value
        ? denormalizePoint(mousePos.value)
        : null;

    if (p2) {
      ctx.strokeStyle = 'red';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
      ctx.stroke();

      drawCircle(ctx, p1.x, p1.y, 5);
      drawCircle(ctx, p2.x, p2.y, 5);

      const midX = (p1.x + p2.x) / 2;
      const midY = (p1.y + p2.y) / 2;

      drawLabel(ctx, 'Kalibráció', midX - 20, midY - 8);
    }
  }

  // Draw stored reference if present (always visible). Highlight may adjust style.
  if (firstImage.value?.referenceStart && firstImage.value?.referenceEnd && img) {
    const ctx = canvasRef.value!.getContext('2d')!;
    const p1 = denormalizePoint(firstImage.value.referenceStart);
    const p2 = denormalizePoint(firstImage.value.referenceEnd);
    ctx.strokeStyle = '#22c55e';
    ctx.lineWidth = highlightRef.value ? 4 : 3;
    ctx.setLineDash([10, 6]);
    ctx.beginPath();
    ctx.moveTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.stroke();
    ctx.setLineDash([]);
    drawCircle(ctx, p1.x, p1.y, 6, '#22c55e');
    drawCircle(ctx, p2.x, p2.y, 6, '#22c55e');
    const midX = (p1.x + p2.x) / 2;
    const midY = (p1.y + p2.y) / 2;
    const dx = (firstImage.value.referenceEnd.x - firstImage.value.referenceStart.x) * img.naturalWidth;
    const dy = (firstImage.value.referenceEnd.y - firstImage.value.referenceStart.y) * img.naturalHeight;
    const pixelDist = Math.sqrt(dx * dx + dy * dy);
    const mpp = meterPerPixel.value || firstImage.value?.meterPerPixel || 0; // meters per pixel
    const lengthMeters = pixelDist * mpp;
    const computedCm = lengthMeters * 100;
    const lengthCm = (firstImage.value?.referenceLengthCm ?? 0) > 0 ? (firstImage.value!.referenceLengthCm as number) : computedCm;
    drawLabel(ctx, `Mentett referencia • ${lengthCm.toFixed(0)} cm`, midX - 60, midY - 8);
  }
};

const applyCalibration = () => {
  if (
    !calibrationStart.value ||
    !calibrationEnd.value ||
    !calibrationLength.value ||
    !imageRef.value
  )
    return;

  // Do not override an existing saved reference unless explicitly starting a new one
  if (referenceSet.value && !allowRefOverride.value) {
    return;
  }

  const naturalWidth = imageRef.value.naturalWidth;
  const naturalHeight = imageRef.value.naturalHeight;

  const dx = (calibrationEnd.value.x - calibrationStart.value.x) * naturalWidth;
  const dy = (calibrationEnd.value.y - calibrationStart.value.y) * naturalHeight;

  const pixelDist = Math.sqrt(dx * dx + dy * dy);

  if (pixelDist === 0) return;

  const lengthMeters = (calibrationLength.value ?? 0) / 100; // input is in cm
  meterPerPixel.value = lengthMeters / pixelDist;

  // Persist reference points on the image metadata
  if (firstImage.value && wall.value) {
    firstImage.value.referenceStart = { ...calibrationStart.value };
    firstImage.value.referenceEnd = { ...calibrationEnd.value };
    firstImage.value.referenceLengthCm = calibrationLength.value ?? null;
    // Do not overwrite stored mpp; allow restore button to work against original server value
    // Persist mutated image meta into store
    store.setWall(wall.value.id, { ...wall.value, images: [...wall.value.images] });
  }
  allowRefOverride.value = false;
  // Exit calibration and clear draft/overlay
  calibrationStart.value = null;
  calibrationEnd.value = null;
  calibrationLength.value = null;
  setMode('view');
  // Briefly highlight the saved reference so user sees the result
  highlightStoredReference();
};

const gotoZoom = (targetScale: number) => {
  const container = zoomContainerRef.value;
  if (!container) return;
  const imageW = imageWidth.value;
  const imageH = imageHeight.value;
  const prevScale = zoomScale.value;
  const prevW = imageW * prevScale;
  const prevH = imageH * prevScale;
  const centerX = container.scrollLeft + container.clientWidth / 2;
  const centerY = container.scrollTop + container.clientHeight / 2;
  const relX = prevW > 0 ? centerX / prevW : 0.5;
  const relY = prevH > 0 ? centerY / prevH : 0.5;
  zoomScale.value = Math.min(3, Math.max(0.2, targetScale));
  void nextTick(() => {
    const newW = imageW * zoomScale.value;
    const newH = imageH * zoomScale.value;
    const newCenterX = relX * newW;
    const newCenterY = relY * newH;
    container.scrollLeft = newCenterX - container.clientWidth / 2;
    container.scrollTop = newCenterY - container.clientHeight / 2;
  });
};

type Mode = 'view' | 'draw' | 'edit' | 'calibrate';
const setMode = (mode: Mode) => {
  // Finish/cleanup current operations
  // Stop dragging
  draggingPoint.value = null;
  // End unfinished drawing
  if (currentPolygon.value && !currentPolygon.value.closed) {
    currentPolygon.value = null;
  }
  // Reset calibration draft line if leaving calibrate
  if (mode !== 'calibrate') {
    calibrationStart.value = null;
    calibrationEnd.value = null;
  }
  if (mode !== 'calibrate') {
    allowRefOverride.value = false;
  }
  if (mode !== 'edit') clearSelection();

  // Exclusive modes
  editingMode.value = mode === 'draw';
  editPointsMode.value = mode === 'edit';
  calibrationMode.value = mode === 'calibrate';

  // Apply saved reference-derived meterPerPixel if available
  recalcMeterPerPixelFromReference();

  void nextTick(() => {
    drawAllPolygons();
  });
};

const toggleCalibration = () => {
  if (calibrationMode.value) setMode('view');
  else setMode('calibrate');
};

const togglePolygonEditing = () => {
  if (editingMode.value) setMode('view');
  else setMode('draw');
};

const handleCanvasClick = (event: MouseEvent) => {
  const clickPoint = normalizePoint(getCanvasCoords(event));

  // 1) Calibration mode: allow cloning an existing polygon edge as reference
  if (calibrationMode.value) {
    if (referenceSet.value && !allowRefOverride.value) return;
    const hit = findEdgeUnderPoint(clickPoint);
    if (hit) {
      calibrationStart.value = { x: hit.a.x, y: hit.a.y };
      calibrationEnd.value = { x: hit.b.x, y: hit.b.y };
      drawAllPolygons();
      return;
    }
    if (!calibrationStart.value) {
      calibrationStart.value = clickPoint;
      drawAllPolygons();
      return;
    }
    if (!calibrationEnd.value) {
      calibrationEnd.value = clickPoint;
      drawAllPolygons();
      return;
    }
    return;
  }

  // 2) Edit points mode: pick topmost closed polygon under cursor
  if (editPointsMode.value) {
    const list = polygons.value as PolygonSurface[];
    let target: PolygonSurface | null = null;
    if (selectedPolygonId.value) {
      target = list.find((p) => p.id === selectedPolygonId.value) ?? null;
    }
    if (!target) {
      for (let idx = list.length - 1; idx >= 0; idx--) {
        const p = list[idx];
        if (!p) continue;
        if (p.visible === false || !p.closed || p.points.length < 3) continue;
        if (isPointInPolygon(clickPoint, p.points)) { target = p; break; }
      }
    }
    if (target) {
      selectedPolygonId.value = target.id;
      drawAllPolygons();
    }
    return;
  }

  // 3) View mode: select polygon by click (topmost)
  if (!editingMode.value) {
    for (let idx = polygons.value.length - 1; idx >= 0; idx--) {
      const p = polygons.value[idx] as PolygonSurface | undefined;
      if (!p) continue;
      if (p.visible === false || p.points.length < 3) continue;
      if (isPointInPolygon(clickPoint, p.points)) {
        selectedPolygonId.value = p.id;
        drawAllPolygons();
        return;
      }
    }
    selectedPolygonId.value = null;
    drawAllPolygons();
    return;
  }

  // 4) Draw mode: add points / close polygon
  pushHistory();
  if (!currentPolygon.value || currentPolygon.value.closed) {
    currentPolygon.value = { id: crypto.randomUUID(), points: [], closed: false } as PolygonSurface;
  }
  const existingPoints = currentPolygon.value.points;
  if (existingPoints.length >= 3 && isNearPoint(clickPoint, existingPoints[0]!)) {
    currentPolygon.value.closed = true;
    polygons.value.push(currentPolygon.value as PolygonSurface);
    currentPolygon.value = null;
  } else {
    existingPoints.push(clickPoint);
  }
  drawAllPolygons();
};

const getCanvasCoordsFromEvent = (event: MouseEvent | TouchEvent): Point => {
  const rect = canvasRef.value!.getBoundingClientRect();
  let clientX = 0;
  let clientY = 0;

  if (event instanceof MouseEvent) {
    clientX = event.clientX;
    clientY = event.clientY;
  } else if (event.touches.length > 0) {
    clientX = event.touches[0].clientX;
    clientY = event.touches[0].clientY;
    event.preventDefault();
  }

  return {
    x: clientX - rect.left,
    y: clientY - rect.top,
  };
};

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));

type DragSnapshot = {
  start: Point; // normalized
  items: Array<{ polyId: string; index: number; start: Point }>;
};
const dragSnapshot = ref<DragSnapshot | null>(null);

const handleMouseDown = (event: MouseEvent | TouchEvent) => {
  if (!(editPointsMode.value || calibrationMode.value)) return;
  const click = normalizePoint(getCanvasCoordsFromEvent(event));
  // Kalibrációs pontok kezelése
  if (calibrationMode.value) {
    if (calibrationStart.value && isNearPoint(click, calibrationStart.value)) {
      draggingPoint.value = { type: 'calibration', index: 0 };
      return;
    }
    if (calibrationEnd.value && isNearPoint(click, calibrationEnd.value)) {
      draggingPoint.value = { type: 'calibration', index: 1 };
      return;
    }
  }

  // Edit pontok: kiválasztás + húzás (multi-select támogatás)
  for (const polygon of polygons.value) {
    for (let i = 0; i < polygon.points.length; i++) {
      const pi = polygon.points[i] as Point | undefined;
      if (pi && isNearPoint(click, pi)) {
        if (event instanceof MouseEvent && event.shiftKey) toggleSelection(polygon.id, i);
        else selectOnly(polygon.id, i);

        // Drag előkészítés a kijelölt pontokra
        pushHistory();
        draggingPoint.value = { polygonId: polygon.id, index: i, type: 'polygon' };
        const items = Array.from(selectedPoints.value)
          .map((k) => {
            const parts = k.split(':');
            if (parts.length !== 2) return null;
            const polyId = parts[0] as string;
            const idx = Number(parts[1]);
            const p = polygons.value.find((pp) => pp.id === polyId);
            const pt = p?.points?.[idx];
            if (!p || !pt) return null;
            return { polyId, index: idx, start: { x: pt.x, y: pt.y } };
          })
          .filter((x): x is { polyId: string; index: number; start: { x: number; y: number } } => Boolean(x));
        dragSnapshot.value = { start: click, items };
        drawAllPolygons();
        return;
      }
    }
  }
  if (!(event instanceof MouseEvent && event.shiftKey)) {
    clearSelection();
    drawAllPolygons();
  }
};

const handleMouseMove = (event: MouseEvent) => {
  mousePos.value = normalizePoint(getCanvasCoords(event));
  if (!draggingPoint.value) {
    drawAllPolygons();
    return;
  }

  if (draggingPoint.value.type === 'polygon') {
    if (dragSnapshot.value && mousePos.value) {
      const dx = mousePos.value.x - dragSnapshot.value.start.x;
      const dy = mousePos.value.y - dragSnapshot.value.start.y;
      for (const it of dragSnapshot.value.items) {
        const poly = polygons.value.find((p) => p.id === it.polyId);
        if (!poly) continue;
        const nx = clamp01(it.start.x + dx);
        const ny = clamp01(it.start.y + dy);
        poly.points[it.index] = { x: nx, y: ny };
      }
    } else {
      const { polygonId, index } = draggingPoint.value;
      const polygon = polygons.value.find((p) => p.id === polygonId);
      if (polygon) polygon.points[index] = mousePos.value;
    }
  } else if (draggingPoint.value.type === 'calibration') {
    if (mousePos.value) {
      if (draggingPoint.value.index === 0 && calibrationStart.value)
        calibrationStart.value = mousePos.value;
      else if (draggingPoint.value.index === 1 && calibrationEnd.value)
        calibrationEnd.value = mousePos.value;
    }
  }

  drawAllPolygons();
};

const handleMouseUp = () => {
  draggingPoint.value = null;
  dragSnapshot.value = null;
};

const highlightStoredReference = () => {
  const imgMeta = firstImage.value;
  const container = zoomContainerRef.value;
  if (!imgMeta || !imgMeta.referenceStart || !imgMeta.referenceEnd || !container) return;
  // Center scroll to midpoint of stored reference
  const scaledW = imageWidth.value * zoomScale.value;
  const scaledH = imageHeight.value * zoomScale.value;
  const midX = ((imgMeta.referenceStart.x + imgMeta.referenceEnd.x) / 2) * scaledW;
  const midY = ((imgMeta.referenceStart.y + imgMeta.referenceEnd.y) / 2) * scaledH;
  container.scrollLeft = Math.max(0, midX - container.clientWidth / 2);
  container.scrollTop = Math.max(0, midY - container.clientHeight / 2);
  highlightRef.value = true;
  drawAllPolygons();
  window.setTimeout(() => {
    highlightRef.value = false;
    drawAllPolygons();
  }, 1200);
};

const toggleSavedReference = () => {
  const imgMeta = firstImage.value;
  const container = zoomContainerRef.value;
  if (!imgMeta || !imgMeta.referenceStart || !imgMeta.referenceEnd || !container) return;
  showSavedReference.value = !showSavedReference.value;
  if (showSavedReference.value) {
    // Center to saved reference
    const scaledW = imageWidth.value * zoomScale.value;
    const scaledH = imageHeight.value * zoomScale.value;
    const midX = ((imgMeta.referenceStart.x + imgMeta.referenceEnd.x) / 2) * scaledW;
    const midY = ((imgMeta.referenceStart.y + imgMeta.referenceEnd.y) / 2) * scaledH;
    container.scrollLeft = Math.max(0, midX - container.clientWidth / 2);
    container.scrollTop = Math.max(0, midY - container.clientHeight / 2);
  }
  drawAllPolygons();
};

// Calibration controls (top-left)
const onStartNewReference = () => {
  if (!calibrationMode.value) setMode('calibrate');
  calibrationStart.value = null;
  calibrationEnd.value = null;
  calibrationLength.value = null;
  showSavedReference.value = false;
  allowRefOverride.value = true;
  drawAllPolygons();
};

const onChangeReferenceLength = () => {
  const imgMeta = firstImage.value;
  const img = imageRef.value;
  if (!imgMeta || !img || !imgMeta.referenceStart || !imgMeta.referenceEnd) return;
  const current = imgMeta.referenceLengthCm ?? null;
  const input = typeof window !== 'undefined' ? window.prompt('Referencia hossza (cm)', current ? String(current) : '') : null;
  if (input === null) return;
  const lengthCm = Number(input);
  if (!Number.isFinite(lengthCm) || lengthCm <= 0) return;
  const dx = (imgMeta.referenceEnd.x - imgMeta.referenceStart.x) * img.naturalWidth;
  const dy = (imgMeta.referenceEnd.y - imgMeta.referenceStart.y) * img.naturalHeight;
  const pixelDist = Math.sqrt(dx * dx + dy * dy);
  if (pixelDist <= 0) return;
  meterPerPixel.value = (lengthCm / 100) / pixelDist;
  imgMeta.referenceLengthCm = lengthCm;
  store.setWall(wall.value.id, { ...wall.value, images: [...wall.value.images] });
  highlightStoredReference();
};

const onClearReference = () => {
  const imgMeta = firstImage.value;
  if (!imgMeta) return;
  imgMeta.referenceStart = null;
  imgMeta.referenceEnd = null;
  imgMeta.referenceLengthCm = null;
  showSavedReference.value = false;
  store.setWall(wall.value.id, { ...wall.value, images: [...wall.value.images] });
  drawAllPolygons();
};

const undoLastPoint = () => {
  undo();
};
const resetCurrentEdit = () => {
  if (currentPolygon.value && !currentPolygon.value.closed) {
    pushHistory();
    currentPolygon.value = null;
    drawAllPolygons();
  }
};

const deleteSelectedPoints = () => {
  if (selectedPoints.value.size === 0) return;
  pushHistory();
  // Group deletions by polygon
  const map = new Map<string, number[]>();
  for (const key of selectedPoints.value) {
    const parts = key.split(':');
    if (parts.length !== 2) continue;
    const pid: string = String(parts[0] ?? '');
    const idxRaw = parts[1];
    const idx = Number(idxRaw);
    if (!pid || Number.isNaN(idx)) continue;
    if (!map.has(pid)) map.set(pid, []);
    map.get(pid)!.push(idx);
  }
  // Apply deletions (descending index order)
  for (const [pid, idxs] of map) {
    const poly = polygons.value.find((p) => p.id === pid);
    if (!poly) continue;
    idxs.sort((a, b) => b - a).forEach((i) => {
      if (i >= 0 && i < poly.points.length) poly.points.splice(i, 1);
    });
    if (poly.closed && poly.points.length < 3) poly.closed = false;
    if (poly.points.length === 0) {
      polygons.value = polygons.value.filter((p) => p.id !== pid);
    }
  }
  clearSelection();
  drawAllPolygons();
};

const downloadWithPolygons = () => {
  const img = imageRef.value;
  if (!img) return;
  const natW = img.naturalWidth;
  const natH = img.naturalHeight;
  const canvas = document.createElement('canvas');
  canvas.width = natW;
  canvas.height = natH;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;
  // Draw base image
  ctx.drawImage(img, 0, 0, natW, natH);

  const pixelSize = meterPerPixel.value || storedMeterPerPixel.value || 0; // meters per pixel
  const allPolys: PolygonSurface[] = [...(polygons.value as PolygonSurface[])];
  if (currentPolygon.value) allPolys.push(currentPolygon.value);

  for (const poly of allPolys) {
    if (poly.visible === false) continue;
    const denormPoints = poly.points.map((p) => ({ x: p.x * natW, y: p.y * natH }));
    if (denormPoints.length < 1) continue;
    const { strokeColor, fillColor, pointColor } = getPolygonColors(poly);

    ctx.beginPath();
    ctx.setLineDash([]);
    ctx.moveTo(denormPoints[0].x, denormPoints[0].y);
    for (let i = 1; i < denormPoints.length; i++) ctx.lineTo(denormPoints[i].x, denormPoints[i].y);
    if (poly.closed) {
      ctx.closePath();
      ctx.fillStyle = fillColor;
      ctx.fill();
    }
    ctx.strokeStyle = strokeColor;
    ctx.lineWidth = 2;
    ctx.stroke();

    // Draw points for clarity
    denormPoints.forEach((p) => drawCircle(ctx, p.x, p.y, 6, pointColor));

    // Labels (length per edge and area)
    if (poly.closed && denormPoints.length >= 3 && pixelSize > 0) {
      for (let i = 0; i < denormPoints.length; i++) {
        const j = (i + 1) % denormPoints.length;
        const p1 = denormPoints[i];
        const p2 = denormPoints[j];
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        const pxDist = Math.sqrt(dx * dx + dy * dy);
        const length = pxDist * pixelSize;
        const midX = (p1.x + p2.x) / 2;
        const midY = (p1.y + p2.y) / 2;
        drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8);
      }
      const area = calculatePolygonArea(poly.points, pixelSize, img);
      const center = getPolygonCenter(denormPoints);
      drawLabel(ctx, `${area.toFixed(2)} m²`, center.x - 18, center.y - 8);
    }
  }

  canvas.toBlob((blob) => {
    if (!blob) return;
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    const baseName = (wallName.value || wallId.value || 'measure').replace(/\s+/g, '-');
    a.download = `${baseName}.png`;
    a.href = url;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  }, 'image/png');
};
const imageWidth = ref(0);
const imageHeight = ref(0);
const onImageLoad = () => {
  if (!imageRef.value || !zoomContainerRef.value) return;

  imageWidth.value = imageRef.value.naturalWidth;
  imageHeight.value = imageRef.value.naturalHeight;

  const container = zoomContainerRef.value;
  const availableW = container.clientWidth;
  const availableH = container.clientHeight;

  const scaleX = availableW / imageWidth.value;
  const scaleY = availableH / imageHeight.value;

  // Azt a scale-t válasszuk, amelyik **teljesen belefér** (kisebb arány)
  zoomScale.value = Math.min(scaleX, scaleY);

  // ⬇️ Itt update-eljük a store-ban az image-et is
  if (wall.value && wall.value.images && wall.value.images.length > 0) {
    const imgMeta = wall.value.images?.[0];
    if (imgMeta) {
      imgMeta.processedImageWidth = imageWidth.value;
      imgMeta.processedImageHeight = imageHeight.value;
      store.setWall(wall.value.id, {
        ...wall.value,
        images: [...wall.value.images],
      });
    }
  }

  void nextTick(() => {
    drawAllPolygons();
  });
};

const handleResize = () => {
  void nextTick(() => {
    drawAllPolygons();
  });
};

const onKeydown = (e: KeyboardEvent) => {
  if (!editPointsMode.value) return;
  const target = e.target as HTMLElement | null;
  const tn = target?.tagName?.toLowerCase() || '';
  const isTyping = tn === 'input' || tn === 'textarea' || (target as any)?.isContentEditable;
  if (isTyping) return;
  if (e.key === 'Delete' || e.key === 'Backspace') {
    if (selectedPoints.value.size > 0) {
      e.preventDefault();
      deleteSelectedPoints();
    }
  }
};

onMounted(() => {
  window.addEventListener('resize', handleResize);
  window.addEventListener('keydown', onKeydown);
  const canvas = canvasRef.value;
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
  window.removeEventListener('keydown', onKeydown);
  const canvas = canvasRef.value;
});

const removePoligonsById = (id: string) => {
  pushHistory();
  polygons.value = polygons.value.filter((polygon: PolygonSurface) => polygon.id !== id);
  if (selectedPolygonId.value === id) selectedPolygonId.value = null;
  drawAllPolygons();
};
watch(
  polygons,
  () => {
    drawAllPolygons();
  },
  { deep: true },
);
watch(meterPerPixel, () => {
  void nextTick(() => {
    drawAllPolygons();
  });
});
watch(zoomScale, () => {
  void nextTick(() => {
    drawAllPolygons();
  });
});
// Keep meterPerPixel in sync with saved reference whenever image/meta becomes available
watchEffect(() => {
  // Reading these makes them reactive dependencies
  const _img = imageRef.value;
  const meta = firstImage.value;
  const _rs = meta?.referenceStart?.x ?? null;
  const _re = meta?.referenceEnd?.x ?? null;
  const _len = meta?.referenceLengthCm ?? null;
  if (!_img || !meta) return;
  if (meta.referenceStart && meta.referenceEnd && (meta.referenceLengthCm ?? 0) > 0) {
    recalcMeterPerPixelFromReference();
  }
});
const restoreCalibration = () => {
  meterPerPixel.value = storedMeterPerPixel.value;
};
const removeAllPoligon = () => {
  pushHistory();
  polygons.value = [];
  selectedPolygonId.value = null;
  drawAllPolygons();
};
const zoomBy = (delta: number) => {
  const container = zoomContainerRef.value;
  const wrapper = zoomWrapperRef.value;
  if (!container || !wrapper) return;

  const prevScale = zoomScale.value;
  const nextScale = Math.min(3, Math.max(0.2, prevScale + delta));

  const imageW = imageWidth.value;
  const imageH = imageHeight.value;

  // Jelenlegi wrapper méretek
  const prevW = imageW * prevScale;
  const prevH = imageH * prevScale;

  // Container középpont koordinátája scroll + offset alapján (abszolút pozíció a wrapperen belül)
  const centerX = container.scrollLeft + container.clientWidth / 2;
  const centerY = container.scrollTop + container.clientHeight / 2;

  // A wrapperen belül, relatív hely arány a képhez képest
  const relX = prevW > 0 ? centerX / prevW : 0.5;
  const relY = prevH > 0 ? centerY / prevH : 0.5;

  // Új scale beállítás
  zoomScale.value = nextScale;

  void nextTick(() => {
    const newW = imageW * nextScale;
    const newH = imageH * nextScale;

    const newCenterX = relX * newW;
    const newCenterY = relY * newH;

    container.scrollLeft = newCenterX - container.clientWidth / 2;
    container.scrollTop = newCenterY - container.clientHeight / 2;
  });
};
</script>

<style scoped>
canvas {
  pointer-events: auto;
}
</style>
