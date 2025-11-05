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
const { uploadImage, fetchWallsBySurvey, createWall, insertWallImage, updateWallImage, deleteWallImage, deleteWallDeep, setOriginalImageBlob, setProcessedImageBlob, getImageDataUrl } = useMeasure();

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

async function compressToJpeg(blob: Blob, maxDim = 1600, quality = 0.85): Promise<Blob> {
  const img = document.createElement('img')
  const url = URL.createObjectURL(blob)
  img.src = url
  await new Promise<void>((resolve) => {
    img.onload = () => resolve()
    img.onerror = () => resolve()
  })
  const w = img.naturalWidth || img.width
  const h = img.naturalHeight || img.height
  if (!w || !h) {
    URL.revokeObjectURL(url)
    return blob
  }
  let tw = w, th = h
  if (Math.max(w, h) > maxDim) {
    if (w >= h) {
      tw = maxDim
      th = Math.round((h / w) * maxDim)
    } else {
      th = maxDim
      tw = Math.round((w / h) * maxDim)
    }
  }
  const canvas = document.createElement('canvas')
  canvas.width = tw
  canvas.height = th
  const ctx = canvas.getContext('2d')!
  ctx.drawImage(img, 0, 0, tw, th)
  const out: Blob = await new Promise((resolve) => {
    canvas.toBlob((b) => resolve(b || blob), 'image/jpeg', quality)
  })
  URL.revokeObjectURL(url)
  return out
}

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
      const dbWall = await createWall(surveyId, '');
      const newWall: Wall = { id: dbWall.id, name: '', images: [createEmptyImage()], polygons: [] };
      store.setWall(newWall.id, newWall);
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
          fileName: (img.original_url || img.processed_url)?.split('/').pop() || null,
          uploadStatus: 'success' as const,
          message: null,
          previewUrl: img.original_url || img.processed_url || '',
          processedImageUrl: img.processed_url || '',
          meterPerPixel: img.meter_per_pixel,
          processedImageWidth: img.processed_image_width,
          processedImageHeight: img.processed_image_height,
          referenceStart: img.reference_start ?? null,
          referenceEnd: img.reference_end ?? null,
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
        points: p.points,
      }));

      const wall: Wall = {
        id: dbWall.id,
        name: dbWall.name,
        images: wallImages.length > 0 ? wallImages : [createEmptyImage()],
        polygons: wallPolygons,
      };

      // Hydrate image URLs from DB blobs (data: URLs) BEFORE first render
      for (const img of wall.images) {
        try {
          const dataUrlProcessed = await getImageDataUrl(img.imageId, 'processed');
          if (dataUrlProcessed) {
            img.processedImageUrl = dataUrlProcessed;
          } else {
            const dataUrlOriginal = await getImageDataUrl(img.imageId, 'original');
            if (dataUrlOriginal) img.previewUrl = dataUrlOriginal;
          }
        } catch (e) {
          console.warn('Hydrate DB image failed for', img.imageId, e);
        }
      }
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

const removeWall = async (wallId: string) => {
  try {
    await deleteWallDeep(wallId);
  } catch (e) {
    console.warn('deleteWallDeep failed, removing locally only:', e);
  }
  store.removeWall(wallId);
};

const addImage = (wall: Wall) => {
  wall.images.push(createEmptyImage());
  store.setWall(wall.id, wall);
};

const removeImage = async (wall: Wall, imageId: string) => {
  try {
    await deleteWallImage(imageId);
  } catch (e) {
    console.warn('deleteWallImage failed or not found, proceeding to remove locally:', e);
  }
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
    let res: any | null = null;
    // 1. Feltöltjük Supabase Storage-ba és mentjük a DB-be
    let uploadedUrl: string | null = null;
    let insertedImageId: string | null = null;
    let companyId: string | null = null;

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

      companyId = profile?.company_id;
      console.log('Company ID:', companyId, 'Wall ID:', wall.id, 'Survey ID:', route.params.surveyId);

      if (companyId) {
        // Feltöltjük az eredeti képet Storage-ba
        const surveyId = String(route.params.surveyId);
        console.log('Attempting upload to Supabase Storage...');
        const originalUpload = await uploadImage(file, companyId, surveyId, wall.id, 'original');
        console.log('Upload successful! URL:', originalUpload.publicUrl);
        uploadedUrl = originalUpload.publicUrl;
        console.log('Inserting wall image metadata...');
        const inserted = await insertWallImage(wall.id, {
          originalUrl: originalUpload.publicUrl,
          processedUrl: null,
          meterPerPixel: null,
          processedImageWidth: null,
          processedImageHeight: null,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        insertedImageId = inserted.id;
        image.imageId = inserted.id;
        console.log('Wall image metadata saved successfully!');

        // Save original as DB blob (compressed) and hydrate preview
        try {
          const compressed = await compressToJpeg(file)
          const dbFile = new File([compressed], file.name.replace(/\.[^.]+$/, '') + '.jpg', { type: 'image/jpeg' })
          await setOriginalImageBlob(inserted.id, dbFile);
          const dbDataUrl = await getImageDataUrl(inserted.id, 'original');
          if (dbDataUrl) image.previewUrl = dbDataUrl;
        } catch (e) {
          console.warn('Saving original image blob failed:', e);
        }
      } else {
        console.warn('No company ID found, skipping upload to Storage, but creating DB image record');
        const inserted = await insertWallImage(wall.id, {
          originalUrl: null,
          processedUrl: null,
          meterPerPixel: null,
          processedImageWidth: null,
          processedImageHeight: null,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        insertedImageId = inserted.id;
        image.imageId = inserted.id;

        // Save original as DB blob (compressed) even if no storage
        try {
          const compressed = await compressToJpeg(file)
          const dbFile = new File([compressed], file.name.replace(/\.[^.]+$/, '') + '.jpg', { type: 'image/jpeg' })
          await setOriginalImageBlob(inserted.id, dbFile);
          const dbDataUrl = await getImageDataUrl(inserted.id, 'original');
          if (dbDataUrl) image.previewUrl = dbDataUrl;
        } catch (e) {
          console.warn('Saving original image blob failed (no storage path):', e);
        }
      }
    } catch (uploadErr: any) {
      console.error('Supabase Storage upload failed:', uploadErr);
      console.error('Error details:', JSON.stringify(uploadErr, null, 2));
      // Nem dobunk hibát, folytatjuk blob URL-lel
    }

    // 2. Feldolgozzuk az API-val, majd frissítjük a DB-t
    try {
      const r = await processFacadeImage(file);
      res = r;
      // Build proxied same-origin URL for the processed image to avoid CORS when fetching blob
      let processedPath = '';
      try {
        const u = new URL(r.image_url);
        processedPath = u.pathname; // e.g. /download/...
      } catch {
        processedPath = r.image_url.startsWith('http') ? '' : r.image_url;
      }
      const proxiedUrl = processedPath ? `/measure/aruco${processedPath}` : r.image_url;

      // Load processed image to get dimensions and blob
      let processedW: number | null = null;
      let processedH: number | null = null;
      try {
        const imgEl = new Image();
        imgEl.src = proxiedUrl;
        await new Promise<void>((resolve) => {
          imgEl.onload = () => resolve();
          imgEl.onerror = () => resolve();
        });
        processedW = (imgEl as any).naturalWidth || null;
        processedH = (imgEl as any).naturalHeight || null;
      } catch {}

      // Fetch blob of processed image and upload to Supabase as 'processed'
      if (companyId) {
        try {
          const resp = await fetch(proxiedUrl);
          const blobRaw = await resp.blob();
          const blob = await compressToJpeg(blobRaw)
          const processedName = (processedPath?.split('/').pop() || file.name.replace(/\.[^.]+$/, '')) + '';
          const processedFile = new File([blob], processedName, { type: blob.type || 'image/png' });
          const surveyId = String(route.params.surveyId);
          const processedUpload = await uploadImage(processedFile as File, companyId, surveyId, wall.id, 'processed');
          if (insertedImageId) {
            await updateWallImage(insertedImageId, {
              processedUrl: processedUpload.publicUrl,
              meterPerPixel: r.real_pixel_size,
              processedImageWidth: processedW,
              processedImageHeight: processedH,
              referenceStart: null,
              referenceEnd: null,
              referenceLengthCm: null,
            });
            // reflect in UI
            try {
              await setProcessedImageBlob(insertedImageId, blob, processedName);
              const dbProcessedUrl = await getImageDataUrl(insertedImageId, 'processed');
              if (dbProcessedUrl) image.processedImageUrl = dbProcessedUrl;
            } catch (e) {
              console.warn('Saving processed image blob failed:', e);
              image.processedImageUrl = processedUpload.publicUrl;
            }
            image.processedImageWidth = processedW ?? undefined;
            image.processedImageHeight = processedH ?? undefined;
          }
        } catch (upErr) {
          console.warn('Processed image upload failed, falling back to external URL in DB:', upErr);
          if (insertedImageId) {
            await updateWallImage(insertedImageId, {
              processedUrl: r.image_url,
              meterPerPixel: r.real_pixel_size,
              processedImageWidth: processedW,
              processedImageHeight: processedH,
              referenceStart: null,
              referenceEnd: null,
              referenceLengthCm: null,
            });
            try {
              const resp2 = await fetch(proxiedUrl);
              const raw = await resp2.blob();
              const blob2 = await compressToJpeg(raw)
              await setProcessedImageBlob(insertedImageId, blob2, processedPath?.split('/').pop() || 'processed');
              const dbProcessedUrl = await getImageDataUrl(insertedImageId, 'processed');
              if (dbProcessedUrl) image.processedImageUrl = dbProcessedUrl; else image.processedImageUrl = r.image_url;
            } catch {
              image.processedImageUrl = r.image_url;
            }
            image.processedImageWidth = processedW ?? undefined;
            image.processedImageHeight = processedH ?? undefined;
          }
        }
      } else if (insertedImageId) {
        // No companyId: cannot upload to Storage; still update DB with external URL
        await updateWallImage(insertedImageId, {
          processedUrl: r.image_url,
          meterPerPixel: r.real_pixel_size,
          processedImageWidth: processedW,
          processedImageHeight: processedH,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        try {
          const resp = await fetch(proxiedUrl);
          const raw = await resp.blob();
          const blob = await compressToJpeg(raw)
          await setProcessedImageBlob(insertedImageId, blob, processedPath?.split('/').pop() || 'processed');
          const dbProcessedUrl = await getImageDataUrl(insertedImageId, 'processed');
          if (dbProcessedUrl) image.processedImageUrl = dbProcessedUrl; else image.processedImageUrl = r.image_url;
        } catch {
          image.processedImageUrl = r.image_url;
        }
        image.processedImageWidth = processedW ?? undefined;
        image.processedImageHeight = processedH ?? undefined;
      }
    } catch (procErr) {
      console.error('Feldolgozás hiba:', procErr);
    }

    if (uploadedUrl || res) {
      image.uploadStatus = 'success';
      image.message = uploadedUrl && res ? 'A fájl sikeresen feltöltve és feldolgozva.' : (uploadedUrl ? 'A fájl sikeresen feltöltve.' : 'A fájl sikeresen feldolgozva.');
      if (res) {
        // only set external URL if we didn't already set a storage URL above
        if (!image.processedImageUrl) {
          image.processedImageUrl = res.image_url;
        }
        image.meterPerPixel = res.real_pixel_size;
      }
      if (uploadedUrl) {
        image.previewUrl = uploadedUrl;
      }
      store.setWall(wall.id, wall);
    } else {
      throw new Error('Neither upload nor processing succeeded');
    }
  } catch (err: any) {
    console.error('Feldolgozás hiba:', err);
    image.uploadStatus = 'failed';
    image.message = err?.message || 'Hiba történt a feldolgozás során. Próbáld újra.';
    store.setWall(wall.id, wall);
  }
};
</script>
