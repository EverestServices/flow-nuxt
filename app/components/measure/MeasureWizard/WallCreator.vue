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
  </div>
</template>

<script setup lang="ts">
import type { Wall, WallImage } from '@/model/Measure/ArucoWallSurface';
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
