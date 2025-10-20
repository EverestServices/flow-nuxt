<template>
  <div class="grid grid-cols-1 gap-4">
    <div class="max-w-md">
      <div v-if="error" class="alert alert-error">
        <span>Hiba történt!<br />{{ error }}</span>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-4 gap-4" v-if="imageSrc">
    <div class="col-span-1">
      <div class="mb-3 pb-3 border-b-1 border-secondary/30">
        <RouterLink to="/measure" class="btn btn-md btn-secondary">
          <LayoutList class="h-5 w-5" />Vissza a falfelületek listára
        </RouterLink>
      </div>
      <PolygonList
        v-if="imageRef"
        :wallId="wall.id"
        v-model:polygons="polygons"
        :meterPerPixel="meterPerPixel"
        :image-natural-height="imageRef.naturalHeight"
        :image-natural-width="imageRef.naturalWidth"
        @removePoligon="removePoligonsById"
        @removeAllPoligon="removeAllPoligon"
        @updateVisibility="(index, val) => (wall.polygons[index].visible = val)"
      />

      <ExtraItemIcoList />
    </div>
    <div class="col-span-3">
      <div class="flex flex-wrap content-between gap-8 mb-2 w-full">
        <button
          @click="togglePolygonEditing"
          class="btn"
          style="z-index: 10"
          :class="editingMode ? 'btn-warning' : 'btn-primary'"
        >
          {{ editingMode ? 'Felületek hozzáadás befejezése' : 'Felületek hozzáadása' }}
        </button>

        <div class="flex items-center gap-2 bg-secondary/20 rounded-lg">
          <button class="btn btn-secondary p-2" @click="zoomBy(-0.1)">
            <ZoomOut class="w-5.5" />
          </button>

          <span class="cursor-default"> {{ (zoomScale * 100).toFixed(0) }}% </span>

          <button class="btn btn-secondary p-2" @click="zoomBy(+0.1)">
            <ZoomIn class="w-5.5" />
          </button>
        </div>

        <button
          v-if="meterPerPixel != storedMeterPerPixel"
          class="btn btn-primary"
          @click="restoreCalibration"
        >
          Kalibráció visszaállítása
        </button>
        <button class="btn btn-secondary" @click="toggleCalibration">
          {{ calibrationMode ? 'Kalibráció befejezése' : 'Kalibráció indítása' }}
        </button>

        <div
          v-if="calibrationMode && calibrationStart && calibrationEnd"
          class="flex items-center gap-2"
        >
          <input
            type="number"
            class="input input-sm input-bordered w-24"
            v-model.number="calibrationLength"
            placeholder="hossz"
          />
          <span class="text-sm">m</span>
          <button class="btn btn-success btn-sm" type="button" @click="applyCalibration">
            Alkalmaz
          </button>
        </div>

        <div v-if="calibrationMode && !calibrationStart && !calibrationEnd">
          <span class="badge badge-info text-xs p-2"> Szakasz felvétele ... </span>
        </div>
      </div>

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
            class="absolute top-0 left-0 cursor-crosshair"
            :style="{ zIndex: 5 }"
            @click="handleCanvasClick"
            @mousedown="handleMouseDown"
            @mousemove="handleMouseMove"
            @mouseup="handleMouseUp"
            @touchstart="handleCanvasTouch"
          ></canvas>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, nextTick, onMounted, onBeforeUnmount, computed, watch } from 'vue';
import PolygonList from './PolygonList.vue';
import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface';
import ExtraItemIcoList from './ExtraItemIcoList.vue';
import { useWallStore } from '@/stores/WallStore';
import { useRoute } from 'vue-router';
import { ZoomIn, ZoomOut, LayoutList } from 'lucide-vue-next';
const store = useWallStore();
const route = useRoute();
const wallId = computed(() => String(route.params.wallId));
const wall = computed(() => store.walls[wallId.value]);
const firstImage = computed(() => wall.value?.images?.[0] ?? null);

const zoomScale = ref(1);
const imageSrc = computed(() => wall.value?.images?.[0].processedImageUrl ?? null);
const error = ref<string | null>(null);
const meterPerPixel = ref<number>(firstImage.value?.meterPerPixel || 0);
const storedMeterPerPixel = computed(() => firstImage.value?.meterPerPixel || 1);
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
const draggingPoint = ref<{
  polygonId?: string;
  index: number;
  type: 'polygon' | 'calibration';
} | null>(null);
const mousePos = ref<Point | null>(null);
const calibrationStart = ref<Point | null>(null);
const calibrationEnd = ref<Point | null>(null);
const calibrationLength = ref<number | null>(null);
const calibrationMode = ref<boolean>(false);

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
  radius = 6,
  fillColor = 'rgba(0,0,255, 0.7)',
) => {
  ctx.beginPath();
  ctx.arc(x, y, radius, 0, 3 * Math.PI);
  ctx.fillStyle = fillColor;
  ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255, 0.5)';
  ctx.stroke();
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

    ctx.beginPath();
    ctx.moveTo(denormPoints[0].x, denormPoints[0].y);
    for (let i = 1; i < denormPoints.length; i++) {
      ctx.lineTo(denormPoints[i].x, denormPoints[i].y);
    }
    if (!poly.closed && currentPolygon.value && mousePos.value) {
      const mouse = denormalizePoint(mousePos.value);
      ctx.lineTo(mouse.x, mouse.y);
    }
    if (poly.closed) {
      ctx.closePath();
      ctx.fillStyle = 'rgba(0, 0, 255, 0.2)';
      ctx.fill();
    }
    ctx.strokeStyle = 'blue';
    ctx.lineWidth = 2;
    ctx.stroke();

    denormPoints.forEach((p, idx) => {
      const isSelected =
        draggingPoint.value?.type === 'polygon' &&
        draggingPoint.value.polygonId === poly.id &&
        draggingPoint.value.index === idx;

      drawCircle(ctx, p.x, p.y, isSelected ? 8 : 6, isSelected ? 'limegreen' : undefined);
    });

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
        drawText(ctx, `${length.toFixed(2)} m`, midX + 5, midY - 5);
      }
      const area = calculatePolygonArea(poly.points, pixelSize, img);
      const center = getPolygonCenter(denormPoints);
      drawText(ctx, `${area.toFixed(2)} m²`, center.x, center.y);
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

      drawText(ctx, 'Kalibráció', midX + 5, midY - 5);
    }
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

  const naturalWidth = imageRef.value.naturalWidth;
  const naturalHeight = imageRef.value.naturalHeight;

  const dx = (calibrationEnd.value.x - calibrationStart.value.x) * naturalWidth;
  const dy = (calibrationEnd.value.y - calibrationStart.value.y) * naturalHeight;

  const pixelDist = Math.sqrt(dx * dx + dy * dy);

  if (pixelDist === 0) return;

  meterPerPixel.value = calibrationLength.value / pixelDist;
};

const toggleCalibration = () => {
  editingMode.value = false;
  calibrationMode.value = !calibrationMode.value;
  drawAllPolygons();
};

const handleCanvasClick = (event: MouseEvent) => {
  if (calibrationMode.value) {
    if (!calibrationStart.value || !calibrationEnd.value) {
      const clickPoint = normalizePoint(getCanvasCoords(event));
      if (!calibrationStart.value) {
        calibrationStart.value = clickPoint;
      } else {
        calibrationEnd.value = clickPoint;
      }
      drawAllPolygons();
    }

    return;
  }
  if (!editingMode.value) return;
  const clickPoint = normalizePoint(getCanvasCoords(event));
  if (!currentPolygon.value || currentPolygon.value.closed) {
    currentPolygon.value = {
      id: crypto.randomUUID(),
      points: [],
      closed: false,
    };
  }
  const existingPoints = currentPolygon.value.points;
  if (existingPoints.length >= 3 && isNearPoint(clickPoint, existingPoints[0])) {
    currentPolygon.value.closed = true;
    polygons.value.push(currentPolygon.value);
    currentPolygon.value = null;
  } else {
    currentPolygon.value.points.push(clickPoint);
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
const handleMouseDown = (event: MouseEvent | TouchEvent) => {
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

  for (const polygon of polygons.value) {
    for (let i = 0; i < polygon.points.length; i++) {
      if (isNearPoint(click, polygon.points[i])) {
        draggingPoint.value = { polygonId: polygon.id, index: i, type: 'polygon' };
        return;
      }
    }
  }
};

const handleMouseMove = (event: MouseEvent) => {
  mousePos.value = normalizePoint(getCanvasCoords(event));
  if (!draggingPoint.value) {
    drawAllPolygons();
    return;
  }

  if (draggingPoint.value.type === 'polygon') {
    const { polygonId, index } = draggingPoint.value;
    const polygon = polygons.value.find((p) => p.id === polygonId);
    if (polygon) polygon.points[index] = mousePos.value;
  } else if (draggingPoint.value.type === 'calibration') {
    if (draggingPoint.value.index === 0 && calibrationStart.value)
      calibrationStart.value = mousePos.value;
    else if (draggingPoint.value.index === 1 && calibrationEnd.value)
      calibrationEnd.value = mousePos.value;
  }

  drawAllPolygons();
};

const handleMouseUp = () => {
  draggingPoint.value = null;
};

const togglePolygonEditing = () => {
  calibrationMode.value = false;
  editingMode.value = !editingMode.value;
  if (!editingMode.value) {
    currentPolygon.value = null;
  }
  void nextTick(() => {
    drawAllPolygons();
  });
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
  if (wall.value && wall.value.images.length > 0) {
    const img = wall.value.images[0];
    img.processedImageWidth = imageWidth.value;
    img.processedImageHeight = imageHeight.value;

    store.setWall(wall.value.id, {
      ...wall.value,
      images: [...wall.value.images],
    });
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

onMounted(() => {
  window.addEventListener('resize', handleResize);
  const canvas = canvasRef.value;
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
  const canvas = canvasRef.value;
});

const removePoligonsById = (id: string) => {
  polygons.value = polygons.value.filter((polygon: PolygonSurface) => polygon.id != id);
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
const restoreCalibration = () => {
  meterPerPixel.value = storedMeterPerPixel.value;
};
const removeAllPoligon = () => {
  polygons.value = [];
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
  const relX = centerX / prevW;
  const relY = centerY / prevH;

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
