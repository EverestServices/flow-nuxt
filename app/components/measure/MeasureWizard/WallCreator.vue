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
const route = useRoute();
const surveyId = computed(() => String(route.params.surveyId));
const walls = computed(() => Object.values(store.getWallsForSurvey(surveyId.value)));
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const { uploadImage, fetchWallsBySurvey, createWall, insertWallImage, deleteWall, getImageDataUrl, deleteWallImage, setOriginalImageBlob, setProcessedImageBlob } = useMeasure();

const generateId = (): string => crypto.randomUUID();

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
  const sid = String(route.params.surveyId);
  console.log('Survey ID:', sid);

  if (!sid) {
    console.warn('No survey ID found');
    return;
  }

  try {
    console.log('Fetching walls from Supabase...');
    const dbWalls = await fetchWallsBySurvey(sid);
    console.log('📦 Fetched walls from DB:', dbWalls);
    console.log('📦 Number of walls:', dbWalls?.length);

    if (!dbWalls || dbWalls.length === 0) {
      console.log('⚠️ No walls found in DB for this survey');
      return;
    }

    // Convert Supabase data to Wall format
    for (const dbWall of dbWalls) {
      console.log('Processing wall:', dbWall);
      console.log('Wall images:', dbWall.images);

      const wallImages: WallImage[] = (dbWall.images || []).map((img: any) => {
        console.log('📷 Processing image:', img);
        console.log('   - Original URL:', img.original_url);
        console.log('   - Processed URL:', img.processed_url);
        const hasProcessed = Boolean(img.processed_url);
        const manualFlag = (img.manual ?? null) !== null ? Boolean(img.manual) : !hasProcessed;
        return {
          imageId: img.id,
          file: null,
          fileName: (img.original_url || img.processed_url)?.split('/').pop() || null,
          uploadStatus: (hasProcessed ? 'success' : 'failed'),
          message: null,
          previewUrl: img.original_url || img.processed_url || '',
          processedImageUrl: img.processed_url || '',
          meterPerPixel: img.meter_per_pixel,
          processedImageWidth: img.processed_image_width,
          processedImageHeight: img.processed_image_height,
          referenceStart: img.reference_start ?? null,
          referenceEnd: img.reference_end ?? null,
          referenceLengthCm: img.reference_length_cm,
          manual: manualFlag,
          manualShapes: img.manual_shapes ?? [],
        };
      });

      console.log('✅ Converted wall images count:', wallImages.length);
      console.log('✅ Wall images:', wallImages);

      const wallPolygonsFromDb: PolygonSurface[] = (dbWall.polygons || []).map((p: any) => ({
        id: p.id,
        type: p.type,
        subType: p.sub_type,
        externalShading: p.external_shading,
        name: p.name,
        visible: p.visible,
        closed: p.closed,
        points: p.points,
        edgeNotesCm: p.edge_notes_cm ?? null,
        edgeNotesRect: p.edge_notes_rect ?? null,
        edgeNotesNorm: p.edge_notes_norm ?? null,
        areaOverrideM2: p.area_override_m2 ?? null,
      }));

      // Preserve existing local polygons if present (e.g., manual mode edits not yet saved to DB)
      const existing = store.getWallsForSurvey(sid)[dbWall.id] as Wall | undefined;
      const finalPolygons = (existing?.polygons && existing.polygons.length > 0) ? existing.polygons : wallPolygonsFromDb;
      const finalImages = wallImages.length > 0 ? wallImages : (existing?.images && existing.images.length > 0 ? existing.images : [createEmptyImage()]);

      const wall: Wall = {
        id: dbWall.id,
        name: dbWall.name,
        images: finalImages,
        polygons: finalPolygons,
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
      store.setWall(sid, wall.id, wall);
    }

    console.log('✅ All walls loaded successfully! Current store:', store.getWallsForSurvey(sid));
  } catch (err) {
    console.error('❌ Failed to load walls from Supabase:', err);
    // Ha nem sikerül betölteni, használjuk a localStorage-ból amit már van
  }
});

const addWall = async () => {
  try {
    // Create wall in Supabase DB
    const dbWall = await createWall(surveyId.value, '');

    // Create wall in store with Supabase ID
    const newWall: Wall = {
      id: dbWall.id,
      name: '',
      images: [createEmptyImage()],
      polygons: [],
    };
    store.setWall(surveyId.value, newWall.id, newWall);
  } catch (err) {
    console.error('Failed to create wall in Supabase:', err);
    // Fallback to local-only wall
    const newWall: Wall = {
      id: generateId(),
      name: '',
      images: [createEmptyImage()],
      polygons: [],
    };
    store.setWall(surveyId.value, newWall.id, newWall);
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
    // Delete from Supabase database
    await deleteWall(wallId);
    // Remove from local store
    store.removeWall(surveyId.value, wallId);
  } catch (err) {
    console.error('Failed to delete wall:', err);
    // Still remove from store even if DB deletion fails
    store.removeWall(surveyId.value, wallId);
  }
};

const addImage = (wall: Wall) => {
  wall.images.push(createEmptyImage());
  store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
};

const removeImage = async (wall: Wall, imageId: string) => {
  try {
    await deleteWallImage(imageId);
  } catch (e) {
    console.warn('deleteWallImage failed or not found, proceeding to remove locally:', e);
  }
  wall.images = wall.images.filter((img) => img.imageId !== imageId);
  store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
};

const handleImageChange = async (wall: Wall, image: WallImage | undefined, event: Event) => {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  if (!file) return;

  if (!wall.images) {
    wall.images = [] as WallImage[];
  }
  if (!image) {
    const placeholder = createEmptyImage();
    wall.images.push(placeholder);
    image = placeholder;
  }

  image.file = file;
  image.fileName = file.name;
  image.uploadStatus = 'pending';
  image.message = 'Feldolgozás és feltöltés folyamatban...';
  image.previewUrl = URL.createObjectURL(file);
  store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });

  try {
    // 1. Feldolgozzuk az API-val (ArUco marker detection)
    const res = await processFacadeImage(file);

    // Update status - don't show image yet, ArUco URL will be deleted after download
    image.uploadStatus = 'pending';
    image.message = 'Feldolgozva. Kép letöltése és feltöltése...';
    image.meterPerPixel = res.real_pixel_size;
    store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });

    // 2. Feltöltjük Supabase Storage-ba és mentjük a DB-be
    let uploadedUrl: string | null = null;
    let processedImageUrl: string | null = null;
    let persisted = false;

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

      const companyId = (profile?.company_id ?? null) as string | null;
      console.log('Company ID:', companyId, 'Wall ID:', wall.id, 'Survey ID:', route.params.surveyId);

      console.log('Downloading processed image from ArUco API via proxy:', res.image_url);
      const processedImageBlob: Blob = await (async () => {
        const controller = new AbortController();
        const t = setTimeout(() => controller.abort(), 20000);
        try {
          const r = await fetch('/api/proxy-image', {
            method: 'POST',
            headers: { 'content-type': 'application/json' },
            body: JSON.stringify({ imageUrl: res.image_url }),
            signal: controller.signal,
          });
          if (!r.ok) throw new Error(`proxy ${r.status}`);
          return await r.blob();
        } finally {
          clearTimeout(t);
        }
      })();
      const processedImageFile = new File([processedImageBlob], `processed_${file.name}`, { type: 'image/png' });

      if (companyId) {
        // Feltöltjük az eredeti és a feldolgozott képet a Storage-ba
        console.log('Attempting upload to Supabase Storage...');
        const originalUpload = await uploadImage(file, companyId, surveyId.value, wall.id, 'original');
        console.log('Upload successful! URL:', originalUpload.publicUrl);
        uploadedUrl = originalUpload.publicUrl;

        console.log('Uploading processed image to Supabase Storage...');
        const processedUpload = await uploadImage(processedImageFile, companyId, surveyId.value, wall.id, 'processed');
        console.log('Processed image upload successful! URL:', processedUpload.publicUrl);
        processedImageUrl = processedUpload.publicUrl; // Permanent Supabase URL

        console.log('Inserting wall image metadata...');
        const insertedImage = await insertWallImage(wall.id, {
          originalUrl: originalUpload.publicUrl,
          processedUrl: processedUpload.publicUrl,
          meterPerPixel: res.real_pixel_size,
          processedImageWidth: null,
          processedImageHeight: null,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        console.log('Wall image metadata saved successfully!', insertedImage);
        image.imageId = insertedImage.id;
        persisted = true;
      } else {
        // Fallback: DB blob mentés, ha nincs companyId
        console.warn('No company ID found, falling back to DB blob storage');
        const insertedImage = await insertWallImage(wall.id, {
          originalUrl: null,
          processedUrl: null,
          meterPerPixel: res.real_pixel_size,
          processedImageWidth: null,
          processedImageHeight: null,
          referenceStart: null,
          referenceEnd: null,
          referenceLengthCm: null,
        });
        await setOriginalImageBlob(insertedImage.id, file);
        await setProcessedImageBlob(insertedImage.id, processedImageBlob, `processed_${file.name}`);
        uploadedUrl = await getImageDataUrl(insertedImage.id, 'original');
        processedImageUrl = await getImageDataUrl(insertedImage.id, 'processed');
        image.imageId = insertedImage.id;
        persisted = true;
      }
    } catch (uploadErr: any) {
      console.error('❌ Supabase Storage upload/save failed:', uploadErr);
      console.error('Error details:', JSON.stringify(uploadErr, null, 2));
      image.uploadStatus = 'failed';
      image.message = 'A feltöltés nem sikerült. Kézi mérés elérhető.';
      image.processedImageUrl = '';
      image.manual = true;
      store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
      // Run fallback persistence in background, do not block UI
      void (async () => {
        try {
          const insertedImage = await insertWallImage(wall.id, {
            originalUrl: null,
            processedUrl: null,
            meterPerPixel: null,
            processedImageWidth: null,
            processedImageHeight: null,
            referenceStart: null,
            referenceEnd: null,
            referenceLengthCm: null,
          });
          await setOriginalImageBlob(insertedImage.id, file);
          const dataUrl = await getImageDataUrl(insertedImage.id, 'original');
          if (dataUrl) {
            image.previewUrl = dataUrl;
            image.imageId = insertedImage.id;
            store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
          }
        } catch (fallbackErr) {
          console.error('❌ DB blob fallback failed (background):', fallbackErr);
        }
      })();
      return;
    }

    // Final status: success only if DB persistence was successful AND processed image exists
    if (persisted && processedImageUrl) {
      image.uploadStatus = 'success';
      image.message = 'Sikeresen feltöltve és feldolgozva!';
      image.processedImageUrl = processedImageUrl; // Permanent Supabase URL
      if (uploadedUrl) image.previewUrl = uploadedUrl; // Original image Supabase URL
      image.manual = false;
      store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
      console.log('✅ Image successfully uploaded and saved!');
    } else {
      // Upload failed - show error but keep preview and allow manual measurement
      image.uploadStatus = 'failed';
      image.message = 'A feltöltés nem sikerült. Kézi mérés elérhető.';
      image.processedImageUrl = '';
      if (uploadedUrl) image.previewUrl = uploadedUrl;
      image.manual = true;
      store.setWall(surveyId.value, wall.id, wall);
      console.error('❌ Image upload failed - falling back to manual mode');
    }
  } catch (err: any) {
    console.error('❌ Feldolgozás hiba:', err);
    image.uploadStatus = 'failed';
    image.message = err?.message || 'Hiba történt a feldolgozás során. Kézi mérés elérhető.';
    image.processedImageUrl = '';
    image.manual = true;
    store.setWall(surveyId.value, wall.id, wall);
    // Background attempt to persist original, without blocking UI
    void (async () => {
      try {
        const { data: profile } = await supabase
          .from('user_profiles')
          .select('company_id')
          .eq('user_id', user.value?.id)
          .single();
        const companyId = (profile?.company_id ?? null) as string | null;
        if (companyId) {
          const originalUpload = await uploadImage(file, companyId, surveyId.value, wall.id, 'original');
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
          image.imageId = inserted.id;
          image.previewUrl = originalUpload.publicUrl;
          store.setWall(surveyId.value, wall.id, { ...wall, images: [...wall.images] });
        } else {
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
          await setOriginalImageBlob(inserted.id, file);
          const dataUrl = await getImageDataUrl(inserted.id, 'original');
          if (dataUrl) image.previewUrl = dataUrl;
          image.imageId = inserted.id;
          store.setWall(surveyId.value, wall.id, wall);
        }
      } catch (saveErr) {
        console.error('❌ Eredeti kép mentése sikertelen (background):', saveErr);
      }
    })();
    return;
  }
};
</script>
