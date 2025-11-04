<template>
  <div class="py-2 space-y-4">
    <div class="grid gap-4 grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 justify-items-center">
      <WallCard
        v-for="(wall, index) in walls"
        :key="wall.id"
        :wall="wall"
        :index="index"
        :can-remove="walls.length > 0"
        @remove="removeWall"
        @add-image="addImage"
        @remove-image="removeImage"
        @image-change="handleImageChange"
      />
      <div class="w-full">
        <UButton
          class="w-full h-full py-25 flex flex-col justify-center items-center"
          color="success"
          @click="addWall"
        >
          <span class="flex flex-row justify-center items-center">
            <Icon name="i-lucide-plus" class="w-30 h-30 mr-2" />
          </span>
          <span class="text-3xl tracking-wider"> Új falfelület </span>
        </UButton>
      </div>
    </div>

    <WallSurfaceSummaryAll />

    <div class="flex justify-center">
      <UButton color="primary" variant="soft" size="md" class="px-4" @click="exportExcel">
        <Icon name="i-lucide-file-spreadsheet" class="h-5 w-5" />
        <span class="ml-2">Excel export</span>
      </UButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Wall, WallImage, Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType, WindowSubType } from '@/model/Measure/ArucoWallSurface';
import { computed } from 'vue';
import { useWallStore } from '@/stores/WallStore';
import WallCard from './WallCard.vue';
import WallSurfaceSummaryAll from '../Measure/WallSurfaceSummaryAll.vue';
import { processFacadeImage } from '@/service/ArucoMeasurments/AlignFacadeService';
 

const store = useWallStore();
const walls = computed(() => Object.values(store.walls));

const generateId = (): string =>
  Math.random().toString(36).substring(2, 10) + Date.now().toString(36);

const createEmptyImage = (): WallImage => ({
  imageId: generateId(),
  file: null,
  fileName: null,
  uploadStatus: 'initial',
  message: null,
  previewUrl: '',
});

const addWall = () => {
  const newWall: Wall = {
    id: generateId(),
    name: '',
    images: [createEmptyImage()],
    polygons: [],
  };
  store.setWall(newWall.id, newWall);
};

function polygonAreaM2(points: Point[], imgW: number, imgH: number, mpp: number): number {
  if (points.length < 3) return 0;
  const den = points.map((p) => ({ x: p.x * imgW, y: p.y * imgH }));
  let areaPx = 0;
  for (let i = 0; i < den.length; i++) {
    const j = (i + 1) % den.length;
    areaPx += den[i]!.x * den[j]!.y - den[j]!.x * den[i]!.y;
  }
  return Math.abs(areaPx / 2) * mpp * mpp;
}

function polygonBBoxM(points: Point[], imgW: number, imgH: number, mpp: number): { w: number; h: number } {
  if (points.length < 2) return { w: 0, h: 0 };
  const den = points.map((p) => ({ x: p.x * imgW, y: p.y * imgH }));
  const minX = Math.min(...den.map((p) => p.x));
  const maxX = Math.max(...den.map((p) => p.x));
  const minY = Math.min(...den.map((p) => p.y));
  const maxY = Math.max(...den.map((p) => p.y));
  return { w: (maxX - minX) * mpp, h: (maxY - minY) * mpp };
}

function hTypeLabel(p: PolygonSurface): string {
  if (p.type === SurfaceType.WALL_PLINTH) return 'Lábazat';
  if (p.type === SurfaceType.FACADE) return 'Homlokzat';
  if (p.type === SurfaceType.WINDOW_DOOR) return p.subType === WindowSubType.DOOR ? 'Ajtó' : 'Ablak';
  return 'Ismeretlen';
}

function exportExcel() {
  const allWalls = walls.value as Wall[];
  const headers = ['Fal #', 'Fal név', 'Típus', 'Al-típus', 'Terület (m2)', 'Szélesség (m)', 'Magasság (m)'];
  const rows: (string | number)[][] = [headers];

  allWalls.forEach((w, idx) => {
    const imgW = w.images?.[0]?.processedImageWidth ?? 0;
    const imgH = w.images?.[0]?.processedImageHeight ?? 0;
    const mpp = w.images?.[0]?.meterPerPixel ?? 0;
    const wallName = w.name?.trim() ? w.name : `Falfelület ${idx + 1}`;
    (w.polygons || [])
      .filter((p) => p.closed && p.points?.length >= 3)
      .forEach((p) => {
        const area = polygonAreaM2(p.points, imgW, imgH, mpp);
        const { w: widthM, h: heightM } = p.type === SurfaceType.WINDOW_DOOR
          ? polygonBBoxM(p.points, imgW, imgH, mpp)
          : { w: 0, h: 0 };
        rows.push([
          idx + 1,
          wallName,
          p.type === SurfaceType.WINDOW_DOOR ? 'Nyílászáró' : hTypeLabel(p),
          p.type === SurfaceType.WINDOW_DOOR ? (p.subType === WindowSubType.DOOR ? 'Ajtó' : 'Ablak') : '',
          Number(area.toFixed(2)),
          widthM ? Number(widthM.toFixed(2)) : '',
          heightM ? Number(heightM.toFixed(2)) : '',
        ]);
      });
  });

  const sep = ';';
  const csv = rows
    .map((r) => r.map((c) => (typeof c === 'string' ? `"${c.replaceAll('"', '""')}"` : String(c))).join(sep))
    .join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'falak-export.csv';
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

const removeWall = (wallId: string) => {
  store.removeWall(wallId);
};

const addImage = (wall: Wall) => {
  wall.images.push(createEmptyImage());
  store.setWall(wall.id, wall);
};

const removeImage = (wall: Wall, imageId: string) => {
  wall.images = wall.images.filter((img) => img.imageId !== imageId);
  store.setWall(wall.id, wall);
};

const handleImageChange = async (wall: Wall, image: WallImage, event: Event) => {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  if (!file) return;

  image.file = file;
  image.fileName = file.name;
  image.uploadStatus = 'pending';
  image.message = 'Feldolgozás folyamatban...';
  image.previewUrl = URL.createObjectURL(file);
  store.setWall(wall.id, wall);

  try {
    const res = await processFacadeImage(file);

    image.uploadStatus = 'success';
    image.message = 'A fájl sikeresen feldolgozva.';
    image.processedImageUrl = res.image_url;
    image.meterPerPixel = res.real_pixel_size;
    store.setWall(wall.id, wall);
  } catch (err) {
    console.error('Feldolgozás hiba:', err);
    image.uploadStatus = 'failed';
    image.message = 'Hiba történt a feldolgozás során. Próbáld újra.';
    store.setWall(wall.id, wall);
  }
};
</script>
