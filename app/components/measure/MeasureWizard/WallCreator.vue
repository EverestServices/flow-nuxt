<template>
  <div class="pt-12 pb-4 space-y-6">
    <div class="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
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
      <div class="w-full min-h-[300px]">
        <button
          @click="addWall"
          class="w-full h-full min-h-[300px] rounded-3xl border-2 border-dashed border-white/40 dark:border-black/30 hover:border-primary-500 bg-white/10 dark:bg-black/10 hover:bg-white/20 dark:hover:bg-black/20 backdrop-blur-md transition-all duration-300 flex flex-col justify-center items-center gap-4 group shadow-lg"
        >
          <div class="flex items-center justify-center w-16 h-16 rounded-full bg-primary-500/20 group-hover:bg-primary-500/30 transition-colors border border-primary-500/30">
            <Icon name="i-lucide-plus" class="w-8 h-8 text-primary-600 dark:text-primary-400 group-hover:text-primary-500" />
          </div>
          <span class="text-xl font-medium text-gray-800 dark:text-gray-200 group-hover:text-gray-900 dark:group-hover:text-white tracking-wide">
            Új falfelület
          </span>
        </button>
      </div>
    </div>

    <WallSurfaceSummaryAll />

    <div class="flex justify-center pt-6">
      <button
        @click="exportExcel"
        class="px-6 py-3 rounded-full bg-primary-500/20 hover:bg-primary-500/30 border border-primary-500/40 backdrop-blur-md transition-all duration-300 flex items-center gap-3 text-primary-700 dark:text-primary-300 font-semibold shadow-lg hover:shadow-xl hover:scale-105"
      >
        <Icon name="i-lucide-file-spreadsheet" class="h-5 w-5" />
        <span>Excel export</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Wall, WallImage, Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType, WindowSubType } from '@/model/Measure/ArucoWallSurface';
import { computed, onMounted } from 'vue';
import { useWallStore } from '@/stores/WallStore';
import WallCard from './WallCard.vue';
import WallSurfaceSummaryAll from '../Measure/WallSurfaceSummaryAll.vue';
import { processFacadeImage } from '@/service/ArucoMeasurments/AlignFacadeService';
import { useMeasure } from '@/composables/useMeasure';

const store = useWallStore();
const walls = computed(() => Object.values(store.walls));
const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const { uploadImage, fetchWallsBySurvey, createWall, insertWallImage } = useMeasure();

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

// Load walls from Supabase on mount
onMounted(async () => {
  console.log('🔄 WallCreator mounted, loading walls from Supabase...');
  const surveyId = String(route.params.surveyId);
  console.log('Survey ID:', surveyId);

  if (!surveyId) {
    console.warn('No survey ID found');
    return;
  }

  try {
    console.log('Fetching walls from Supabase...');
    const dbWalls = await fetchWallsBySurvey(surveyId);
    console.log('📦 Fetched walls from DB:', dbWalls);

    if (!dbWalls || dbWalls.length === 0) {
      console.log('No walls found in DB for this survey');
      return;
    }

    // Convert Supabase data to Wall format
    for (const dbWall of dbWalls) {
      console.log('Processing wall:', dbWall);
      console.log('Wall images:', dbWall.images);

      const wallImages: WallImage[] = (dbWall.images || []).map((img: any) => {
        console.log('Processing image:', img);
        return {
          imageId: img.id,
          file: null,
          fileName: img.original_url?.split('/').pop() || null,
          uploadStatus: 'success' as const,
          message: null,
          previewUrl: img.original_url || '',
          processedImageUrl: img.processed_url || '',
          meterPerPixel: img.meter_per_pixel,
          processedImageWidth: img.processed_image_width,
          processedImageHeight: img.processed_image_height,
          referenceStart: img.reference_start ? JSON.parse(img.reference_start) : null,
          referenceEnd: img.reference_end ? JSON.parse(img.reference_end) : null,
          referenceLengthCm: img.reference_length_cm,
        };
      });

      console.log('Converted wall images:', wallImages);

      const wallPolygons: PolygonSurface[] = (dbWall.polygons || []).map((p: any) => ({
        id: p.id,
        type: p.type,
        subType: p.sub_type,
        externalShading: p.external_shading,
        name: p.name,
        visible: p.visible,
        closed: p.closed,
        points: JSON.parse(p.points),
      }));

      const wall: Wall = {
        id: dbWall.id,
        name: dbWall.name,
        images: wallImages.length > 0 ? wallImages : [createEmptyImage()],
        polygons: wallPolygons,
      };

      console.log('✅ Setting wall in store:', wall);
      store.setWall(wall.id, wall);
    }

    console.log('✅ All walls loaded successfully! Current store:', store.walls);
  } catch (err) {
    console.error('❌ Failed to load walls from Supabase:', err);
    // Ha nem sikerül betölteni, használjuk a localStorage-ból amit már van
  }
});

const addWall = async () => {
  const surveyId = String(route.params.surveyId);

  try {
    // Create wall in Supabase DB
    const dbWall = await createWall(surveyId, '');

    // Create wall in store with Supabase ID
    const newWall: Wall = {
      id: dbWall.id,
      name: '',
      images: [createEmptyImage()],
      polygons: [],
    };
    store.setWall(newWall.id, newWall);
  } catch (err) {
    console.error('Failed to create wall in Supabase:', err);
    // Fallback to local-only wall
    const newWall: Wall = {
      id: generateId(),
      name: '',
      images: [createEmptyImage()],
      polygons: [],
    };
    store.setWall(newWall.id, newWall);
  }
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
  if (p.type === SurfaceType.WINDOW_DOOR) {
    if (p.subType === WindowSubType.DOOR) return 'Bejárati ajtó';
    if (p.subType === WindowSubType.TERRACE_DOOR) return 'Teraszajtó';
    return 'Ablak';
  }
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
          p.type === SurfaceType.WINDOW_DOOR ? (p.subType === WindowSubType.DOOR ? 'Bejárati ajtó' : (p.subType === WindowSubType.TERRACE_DOOR ? 'Teraszajtó' : 'Ablak')) : '',
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
  image.message = 'Feldolgozás és feltöltés folyamatban...';
  image.previewUrl = URL.createObjectURL(file);
  store.setWall(wall.id, wall);

  try {
    // 1. Feldolgozzuk az API-val (ArUco marker detection)
    const res = await processFacadeImage(file);

    // 2. Feltöltjük Supabase Storage-ba és mentjük a DB-be
    let uploadedUrl: string | null = null;

    try {
      // Szerezzük meg a company_id-t
      const { data: profile, error: profileErr } = await supabase
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.value?.id)
        .single();

      if (profileErr) {
        console.error('Profile fetch error:', profileErr);
        throw profileErr;
      }

      const companyId = profile?.company_id;
      console.log('Company ID:', companyId, 'Wall ID:', wall.id, 'Survey ID:', route.params.surveyId);

      if (companyId) {
        // Feltöltjük az eredeti képet Storage-ba
        const surveyId = String(route.params.surveyId);
        console.log('Attempting upload to Supabase Storage...');
        const originalUpload = await uploadImage(file, companyId, surveyId, wall.id, 'original');
        console.log('Upload successful! URL:', originalUpload.publicUrl);
        uploadedUrl = originalUpload.publicUrl;

        // Mentjük a kép metaadatait a DB-be
        console.log('Inserting wall image metadata...');
        await insertWallImage(wall.id, {
          originalUrl: originalUpload.publicUrl,
          processedUrl: res.image_url,
          meterPerPixel: res.real_pixel_size,
          processedImageWidth: null,
          processedImageHeight: null,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        console.log('Wall image metadata saved successfully!');
      } else {
        console.warn('No company ID found, skipping upload');
      }
    } catch (uploadErr: any) {
      console.error('Supabase Storage upload failed:', uploadErr);
      console.error('Error details:', JSON.stringify(uploadErr, null, 2));
      // Nem dobunk hibát, folytatjuk blob URL-lel
    }

    // Használjuk a Supabase URL-t ha van, különben blob URL
    image.uploadStatus = 'success';
    image.message = uploadedUrl ? 'A fájl sikeresen feltöltve és feldolgozva.' : 'A fájl sikeresen feldolgozva.';
    image.processedImageUrl = res.image_url; // API által feldolgozott kép URL
    image.previewUrl = uploadedUrl || URL.createObjectURL(file); // Supabase URL vagy blob fallback
    image.meterPerPixel = res.real_pixel_size;
    store.setWall(wall.id, wall);
  } catch (err: any) {
    console.error('Feldolgozás hiba:', err);
    image.uploadStatus = 'failed';
    image.message = err?.message || 'Hiba történt a feldolgozás során. Próbáld újra.';
    store.setWall(wall.id, wall);
  }
};
</script>
