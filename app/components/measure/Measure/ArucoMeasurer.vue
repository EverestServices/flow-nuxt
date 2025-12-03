<template>
  <!-- Error Alert - Fixed Position -->
  <div v-if="error" class="fixed top-4 left-1/2 -translate-x-1/2 z-50 max-w-md">
    <UAlert color="error" variant="soft">
      <template #title>Hiba történt!</template>
      <template #description>{{ error }}</template>
    </UAlert>
  </div>
  
  <!-- Zoom Controls - Fixed to Screen Top Center -->
  <Transition
    enter-active-class="transition-all duration-500 ease-out"
    enter-from-class="opacity-0 -translate-y-4"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="transition-all duration-300 ease-in"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 -translate-y-4"
  >
    <div v-if="imageSrc" class="pointer-events-auto fixed left-1/2 -translate-x-1/2 top-3 z-40 bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-full backdrop-blur-xs flex h-12 items-center gap-1 px-3 shadow-sm">
      <button
        @click="zoomBy(-0.1)"
        class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
      >
        <Icon name="i-lucide-zoom-out" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
      <span class="px-2 py-1 text-sm font-medium text-gray-700 dark:text-gray-300">{{ (zoomScale * 100).toFixed(0) }}%</span>
      <button
        @click="() => gotoZoom(1)"
        class="px-3 py-1 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors text-sm font-medium text-gray-700 dark:text-gray-300"
      >
        100%
      </button>
      <button
        @click="zoomBy(+0.1)"
        class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
      >
        <Icon name="i-lucide-zoom-in" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
      <div class="h-6 w-px bg-gray-400/30 mx-1"></div>
      <span v-if="!manualActive" class="px-2 py-1 text-xs font-medium text-gray-600 dark:text-gray-400">{{ pixelPerMeterLabel }}</span>
      <span v-else class="px-2 py-1 rounded-full bg-amber-400/80 text-black text-xs font-semibold">Kézi kijelölés mód</span>
      <span v-if="!manualActive && referenceSet" class="px-2 py-1 rounded-full bg-green-500/20 text-green-700 dark:text-green-300 text-xs font-semibold">
        Referencia OK
      </span>
      <div class="h-6 w-px bg-gray-400/30 mx-1"></div>
      <button
        @click="handleUndo"
        class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
        title="Visszavonás"
      >
        <Icon name="i-lucide-undo-2" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
      <button
        @click="handleRedo"
        class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
        title="Mégis"
      >
        <Icon name="i-lucide-redo-2" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
      <button
        @click="resetCurrentEdit"
        class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
        title="Reset"
      >
        <Icon name="i-lucide-rotate-ccw" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
    </div>
  </Transition>

  

  <!-- Mode Selector - Fixed to Screen Bottom Center -->
  <Transition
    enter-active-class="transition-all duration-500 ease-out"
    enter-from-class="opacity-0 translate-y-8"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="transition-all duration-300 ease-in"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 translate-y-8"
  >
    <div v-if="imageSrc" class="pointer-events-auto fixed left-1/2 -translate-x-1/2 bottom-3 z-40 bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-full backdrop-blur-xs flex h-12 items-center gap-1 px-2 shadow-sm">
      <button
        @click="() => setMode('view')"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium transition-all duration-200',
          isViewMode
            ? 'bg-primary-600 text-white shadow-sm'
            : 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
        ]"
      >
        View
      </button>
      <button
        @click="() => setMode('draw')"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium transition-all duration-200',
          editingMode
            ? 'bg-primary-600 text-white shadow-sm'
            : 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
        ]"
      >
        Draw Surface
      </button>
      <button
        @click="() => setMode('edit')"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium transition-all duration-200',
          editPointsMode
            ? 'bg-primary-600 text-white shadow-sm'
            : 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
        ]"
      >
        Edit
      </button>
      <button
        v-if="!manualActive"
        @click="() => setMode('calibrate')"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium transition-all duration-200',
          calibrationMode
            ? 'bg-warning-500 text-white shadow-sm'
            : 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
        ]"
      >
        Setup Reference
      </button>
    </div>
  </Transition>

  <!-- Action Buttons - Fixed to Screen Bottom Left (Only in View Mode) -->
  <Transition
    enter-active-class="transition-all duration-500 ease-out"
    enter-from-class="opacity-0 translate-x-8"
    enter-to-class="opacity-100 translate-x-0"
    leave-active-class="transition-all duration-300 ease-in"
    leave-from-class="opacity-100 translate-x-0"
    leave-to-class="opacity-0 translate-x-8"
  >
    <div v-if="imageSrc && isViewMode" class="pointer-events-auto fixed left-3 bottom-3 z-40 bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-full backdrop-blur-xs flex h-12 items-center gap-1 px-2 shadow-sm">
      <button
        @click="navigateToPreviousWall"
        :disabled="!previousWall"
        :class="[
          'px-3 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-1',
          previousWall
            ? 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
            : 'text-gray-400 dark:text-gray-600 cursor-not-allowed opacity-50'
        ]"
        title="Előző fal"
      >
        <Icon name="i-lucide-chevron-left" class="w-4 h-4" />
        <span>Előző</span>
      </button>

      <button
        @click="downloadWithPolygons"
        class="px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-2 bg-primary-600 text-white hover:bg-primary-700 shadow-sm"
        title="Letöltés"
      >
        <Icon name="i-lucide-download" class="w-4 h-4" />
        <span>Letöltés</span>
      </button>

      <button
        @click="navigateToNextWall"
        :disabled="!nextWall"
        :class="[
          'px-3 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-1',
          nextWall
            ? 'text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'
            : 'text-gray-400 dark:text-gray-600 cursor-not-allowed opacity-50'
        ]"
        title="Következő fal"
      >
        <span>Következő</span>
        <Icon name="i-lucide-chevron-right" class="w-4 h-4" />
      </button>
    </div>
  </Transition>

  <!-- Main Layout Wrapper: Flex in View Mode, Fixed in Edit Modes -->
  <div
    v-if="imageSrc"
    :class="isViewMode ? 'flex h-screen w-full gap-6' : 'fixed inset-0'"
  >
    <!-- Sidebar Open Button - Only visible when sidebar is closed in Edit modes -->
    <div
      v-if="!isViewMode && !sidebarVisible"
      class="fixed left-2 top-1/2 -translate-y-1/2 z-50 pointer-events-auto"
    >
      <button
        @click="sidebarVisible = true"
        class="bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 backdrop-blur-xs rounded-full p-2.5 hover:bg-white/30 dark:hover:bg-black/30 transition-colors shadow-lg"
      >
        <Icon name="i-lucide-panel-left-open" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
      </button>
    </div>

    <!-- Sidebar: Normal in View Mode, Floating in Edit Modes -->
    <Transition
      enter-active-class="transition-transform duration-300 ease-out"
      enter-from-class="-translate-x-full"
      enter-to-class="translate-x-0"
      leave-active-class="transition-transform duration-300 ease-in"
      leave-from-class="translate-x-0"
      leave-to-class="-translate-x-full"
    >
      <div
        v-if="sidebarVisible"
        :class="[
          'p-4 overflow-y-auto',
          isViewMode
            ? 'flex-shrink-0 w-[400px] h-[calc(100vh-140px)] my-auto bg-white dark:bg-black/20 border border-gray-200 dark:border-gray-800 rounded-3xl'
            : 'absolute left-3 top-[68px] bottom-[68px] z-30 w-96 bg-white/20 dark:bg-black/20 backdrop-blur-md rounded-2xl shadow-2xl border border-white/20 dark:border-black/10'
        ]"
      >
        <!-- Header -->
        <div class="mb-4 flex items-center justify-between gap-3">
          <div class="flex items-center gap-2">
            <button
              @click="handleBackToMeasureList"
              class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
            >
              <Icon name="i-lucide-layout-list" class="h-5 w-5 text-gray-700 dark:text-gray-300" />
            </button>

            <!-- Close Button - Only in Edit modes -->
            <button
              v-if="!isViewMode"
              @click="sidebarVisible = false"
              class="p-2 rounded-full hover:bg-white/30 dark:hover:bg-black/30 transition-colors"
            >
              <Icon name="i-lucide-panel-left-close" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
            </button>
          </div>

          <div class="flex-1 min-w-0">
            <div
              v-if="!editingWallName"
              @click="startEditingWallName"
              class="flex items-center gap-2 px-3 py-2 rounded-full bg-white/20 dark:bg-black/20 border border-white/40 dark:border-black/10 hover:bg-white/30 dark:hover:bg-black/30 transition-all duration-200 cursor-pointer backdrop-blur-xs"
            >
              <span class="text-sm font-medium text-gray-800 dark:text-gray-200 truncate">{{ wallName || 'Névtelen fal' }}</span>
              <Icon name="i-lucide-pencil" class="h-4 w-4 shrink-0 text-gray-600 dark:text-gray-400" />
            </div>
            <input
              v-else
              v-model="wallName"
              type="text"
              class="w-full px-3 py-2 rounded-full bg-white/20 dark:bg-black/20 border border-black/40 dark:border-black/10 text-sm font-medium text-gray-800 dark:text-gray-200 backdrop-blur-xs focus:outline-none focus:ring-2 focus:ring-primary-500/50"
              @blur="stopEditingWallName"
              @keyup.enter="stopEditingWallName"
            />
          </div>
        </div>

        <!-- Divider -->
        <div class="h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-700 to-transparent mb-4"></div>

        <div v-if="manualActive" class="mb-3 flex items-center gap-2">
          <UBadge color="warning" size="xs">Kézi kijelölés</UBadge>
        </div>

        

        <div class="mb-3">
          <OrientationSelector
            v-model="wallOrientation"
            label="Tájolás"
          />
        </div>

        <PolygonList
          v-if="imageRef"
          :polygons="polygons as any"
          :meter-per-pixel="meterPerPixel || storedMeterPerPixel"
          :image-natural-width="imageWidth"
          :image-natural-height="imageHeight"
          :wall-id="wall.id"
          :selected-id="selectedPolygonId || undefined"
          :manual-active="manualActive"
          @removePoligon="removePoligonsById"
          @removeAllPoligon="removeAllPoligon"
          @updateVisibility="onUpdateVisibility"
          @select="onListSelect"
        />

        <ExtraItemIcoList />
      </div>
    </Transition>

    <!-- Image Container: Flex-1 in View Mode, Full in Edit Modes -->
    <div :class="isViewMode ? 'flex-1 min-w-0 relative' : 'w-full h-full'">
      <div class="w-full h-full">
        <div
          ref="zoomContainerRef"
          class="overflow-auto w-full h-full"
          :class="isDragging ? 'cursor-grabbing' : (isViewMode || (isSpacePressed && zoomScale > 1.0)) ? 'cursor-grab' : ''"
          style="display: grid; place-items: center;"
          @mousedown="handleContainerMouseDown"
          @mousemove="handleContainerMouseMove"
          @mouseup="handleContainerMouseUp"
          @mouseleave="handleContainerMouseUp"
        >
          <div
            class="relative"
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
              :class="[
                'select-none pointer-events-none w-full h-full',
                isViewMode ? 'rounded-3xl' : ''
              ]"
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
            <div
              v-if="manualActive && selectedRectangle && rectEdges"
              class="absolute z-30"
              :style="{ left: (rectEdges.a.x - 22) + 'px', top: (rectEdges.a.y - 8) + 'px' }"
            >
              <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
                <input
                  class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
                  type="number"
                  inputmode="numeric"
                  step="1"
                  v-model="edgeInputA"
                  placeholder="cm"
                  @keyup.enter="saveEdgeNote('a')"
                  @blur="saveEdgeNote('a')"
                />
                <span class="text-[10px] opacity-80">cm</span>
              </div>
            </div>
            <!-- Generic per-edge inputs for all non-rectangle polygons in manual mode -->
            <div
              v-for="ov in allEdgeOverlays"
              :key="ov.key"
              v-if="manualActive"
              class="absolute z-30"
              :style="{ left: (ov.x - 22) + 'px', top: (ov.y - 8) + 'px' }"
            >
              <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
                <input
                  class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
                  type="number"
                  inputmode="numeric"
                  step="1"
                  :value="ov.value"
                  placeholder="cm"
                  @input="onEdgeInputBuffer(ov.key, $event)"
                  @keyup.enter="saveEdgeInput(ov.key)"
                  @blur="saveEdgeInput(ov.key)"
                />
                <span class="text-[10px] opacity-80">cm</span>
              </div>
            </div>
            <div
              v-if="manualActive && selectedRectangle && rectEdges"
              class="absolute z-30"
              :style="{ left: (rectEdges.b.x - 22) + 'px', top: (rectEdges.b.y - 8) + 'px' }"
            >
              <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
                <input
                  class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
                  type="number"
                  inputmode="numeric"
                  step="1"
                  v-model="edgeInputB"
                  placeholder="cm"
                  @keyup.enter="saveEdgeNote('b')"
                  @blur="saveEdgeNote('b')"
                />
                <span class="text-[10px] opacity-80">cm</span>
              </div>
            </div>
            <!-- Manual area display at polygon center (manual mode, read-only) -->
            <div
              v-if="manualActive && selectedPolygonCenter && manualAreaLabel"
              class="absolute z-30"
              :style="{ left: selectedPolygonCenter.x + 'px', top: selectedPolygonCenter.y + 'px', transform: 'translate(-50%, -50%)' }"
            >
              <div class="flex items-center gap-1 bg-neutral-900/85 text-white rounded-full px-2 py-1 shadow select-none">
                <span class="text-xs font-semibold">{{ manualAreaLabel }}</span>
              </div>
            </div>
            <!-- Inline calibration input overlay near the segment midpoint -->
            <div
              v-if="!manualActive && calibrationMode && calibrationStart && (calibrationEnd || mousePos) && calibrationMidOverlay"
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


          <!-- Bottom-left: Reference controls (only in calibration mode) -->
          <div
            v-if="calibrationMode && !manualActive"
            class="pointer-events-auto absolute left-3 bottom-3 flex items-center gap-1 bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-full backdrop-blur-xs h-12 px-2 shadow-sm"
          >
            <button
              @click="onStartNewReference"
              class="px-3 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-2 text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30"
              title="Új referencia hozzáadása"
            >
              <Icon name="i-lucide-wand-2" class="w-4 h-4" />
              <span class="hidden sm:inline">Új hozzáadása</span>
            </button>
            <button
              :disabled="!referenceSet"
              @click="onChangeReferenceLength"
              class="px-3 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-gray-700 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30"
              title="Referencia méret módosítása"
            >
              <Icon name="i-lucide-ruler" class="w-4 h-4" />
              <span class="hidden sm:inline">Méret módosítása</span>
            </button>
            <button
              :disabled="!referenceSet"
              @click="onClearReference"
              class="px-3 py-2 rounded-full text-sm font-medium transition-all duration-200 flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-red-600 dark:text-red-400 hover:bg-red-500/20"
              title="Referencia törlése"
            >
              <Icon name="i-lucide-trash-2" class="w-4 h-4" />
              <span class="hidden sm:inline">Törlés</span>
            </button>
          </div>

          <!-- Calibration helper (only message, no buttons) -->
          <div v-if="calibrationMode && !manualActive" class="pointer-events-none absolute inset-x-0 top-2 flex justify-center">
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
import { ref, nextTick, onMounted, onBeforeUnmount, computed, watch, watchEffect } from 'vue';
import { Orientation } from '@/model/Measure/ArucoWallSurface';
import PolygonList from './PolygonList.vue';
import type { Point, PolygonSurface, Wall } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import ExtraItemIcoList from './ExtraItemIcoList.vue';
import OrientationSelector from '@/components/shared/OrientationSelector.vue';
import { useWallStore, clonePolygonData } from '@/stores/WallStore';
import { useRoute, useRouter } from 'vue-router';
import { useWallSync } from '@/composables/useWallSync';
import { useMeasure } from '@/composables/useMeasure';
import { deriveShape } from '@/service/Measurment/ShapeDeriveService';
const store = useWallStore();
const route = useRoute();
const router = useRouter();
const { syncWallsToSurvey } = useWallSync();
const surveyId = computed(() => String(route.params.surveyId));
const wallId = computed(() => String(route.params.wallId));
const wall = computed<Wall>(() => {
  const surveyWalls = store.getWallsForSurvey(surveyId.value);
  const w = surveyWalls[wallId.value] as Wall | undefined;
  return w ?? ({ id: wallId.value, name: '', images: [], polygons: [] } as Wall);
});

 

// Wall navigation
const allWalls = computed(() => Object.values(store.getWallsForSurvey(surveyId.value)));
const currentWallIndex = computed(() =>
  allWalls.value.findIndex((w) => w.id === wallId.value)
);
const previousWall = computed(() => {
  const index = currentWallIndex.value;
  return index > 0 ? allWalls.value[index - 1] : null;
});
const nextWall = computed(() => {
  const index = currentWallIndex.value;
  return index >= 0 && index < allWalls.value.length - 1 ? allWalls.value[index + 1] : null;
});

const handleBackToMeasureList = async () => {
  // Sync walls to survey before navigating back
  try {
    await syncWallsToSurvey(surveyId.value);
  } catch (error) {
    console.error('Error syncing walls:', error);
  }
  await router.push(`/survey/${String(route.params.surveyId)}/measure`);
};

const toggleManualMode = () => {
  const imgMeta = firstImage.value;
  if (!imgMeta || !wall.value) return;
  imgMeta.manual = !Boolean(imgMeta.manual);
  store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] });
  if (imgMeta.manual) setMode('edit');
  drawAllPolygons();
};

const navigateToPreviousWall = () => {
  if (previousWall.value) {
    router.push(`/survey/${String(route.params.surveyId)}/measure/${previousWall.value.id}`);
  }
};

const navigateToNextWall = () => {
  if (nextWall.value) {
    router.push(`/survey/${String(route.params.surveyId)}/measure/${nextWall.value.id}`);
  }
};
const wallName = computed<string>({
  get: () => wall.value?.name ?? '',
  set: (val: string) => {
    if (wall.value) {
      store.setWall(surveyId.value, wall.value.id, { ...wall.value, name: val });
    }
  },
});
const wallOrientation = computed<Orientation | null>({
  get: () => (wall.value?.orientation ?? null) as Orientation | null,
  set: (val: Orientation | null) => {
    if (wall.value) {
      store.setWall(surveyId.value, wall.value.id, { ...wall.value, orientation: val ?? undefined });
    }
  },
});
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
const manualActive = computed(() => {
  const q = String((route.query as any)?.manual ?? '');
  const fromQuery = q && ['1','true','yes'].includes(q.toLowerCase());
  const meta = firstImage.value;
  return Boolean(fromQuery || meta?.manual || !meta?.processedImageUrl);
});
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

// Drag to pan in view mode or draw mode with spacebar
const isDragging = ref(false);
const dragStart = ref({ x: 0, y: 0 });
const scrollStart = ref({ x: 0, y: 0 });
const isSpacePressed = ref(false);
const polygons = computed({
  get: () => wall.value?.polygons ?? [],
  set: (newPolygons) => {
    if (wall.value) {
      store.setWall(surveyId.value, wall.value.id, {
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
const manualInitDone = ref<boolean>(false);
const edgeInputBuffer = ref<string>('');

const selectedRectangle = computed(() => {
  if (!selectedPolygonId.value) return null as null | PolygonSurface;
  const p = polygons.value.find((x) => x.id === selectedPolygonId.value) || null;
  if (!p || !p.closed || p.points.length !== 4) return null as null | PolygonSurface;
  return p as PolygonSurface;
});
const rectWidth = ref<string>('');
const rectHeight = ref<string>('');
const rectCornerIdx = ref<number>(0);
const rectSwapAxes = ref<boolean>(false);

const lengthMetersBetween = (a: Point, b: Point): number => {
  const img = imageRef.value;
  const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0;
  if (!img || !(mpp > 0)) return 0;
  const dx = (b.x - a.x) * img.naturalWidth;
  const dy = (b.y - a.y) * img.naturalHeight;
  const px = Math.hypot(dx, dy);
  return px * mpp;
};

const getRectTriplet = (poly: PolygonSurface) => {
  const i = ((rectCornerIdx.value % 4) + 4) % 4;
  const p0 = poly.points[i]!;
  const p1 = poly.points[(i + 1) % 4]!;
  const p2 = poly.points[(i + 2) % 4]!;
  return { p0, p1, p2 };
};

const refreshRectInputs = () => {
  const poly = selectedRectangle.value;
  if (!poly) return;
  const { p0, p1, p2 } = getRectTriplet(poly);
  let a = lengthMetersBetween(p0, p1);
  let b = lengthMetersBetween(p1, p2);
  if (rectSwapAxes.value) [a, b] = [b, a];
  rectWidth.value = a > 0 ? a.toFixed(2) : '';
  rectHeight.value = b > 0 ? b.toFixed(2) : '';
};

 

const rotateRectCorner = () => { rectCornerIdx.value = (rectCornerIdx.value + 1) % 4; refreshRectInputs(); updateEdgeNotesRect(); };
const swapRectAxes = () => { rectSwapAxes.value = !rectSwapAxes.value; refreshRectInputs(); updateEdgeNotesRect(); };

let rectApplyTimer: number | null = null;
const onRectInputChange = () => {
  if (rectApplyTimer) window.clearTimeout(rectApplyTimer);
  rectApplyTimer = window.setTimeout(() => applyRectInputs(), 250) as unknown as number;
};

const rectEdges = computed(() => {
  const poly = selectedRectangle.value;
  const img = imageRef.value;
  const wrapper = zoomWrapperRef.value;
  const canvasEl = canvasRef.value;
  const _zs = zoomScale.value;
  if (!poly || !img || !wrapper || !canvasEl) return null as null | { a: { x: number; y: number }; b: { x: number; y: number } };
  const points = poly.points;
  if (points.length !== 4) return null as any;
  const d = points.map((pt) => denormalizePoint(pt));
  // Edge midpoints
  const mids = [
    { x: (d[0].x + d[1].x) / 2, y: (d[0].y + d[1].y) / 2, i: 0, j: 1 },
    { x: (d[1].x + d[2].x) / 2, y: (d[1].y + d[2].y) / 2, i: 1, j: 2 },
    { x: (d[2].x + d[3].x) / 2, y: (d[2].y + d[3].y) / 2, i: 2, j: 3 },
    { x: (d[3].x + d[0].x) / 2, y: (d[3].y + d[0].y) / 2, i: 3, j: 0 },
  ];
  // Determine A/B edge pairs based on rectCornerIdx and swap
  const c = ((rectCornerIdx.value % 4) + 4) % 4;
  const norm = (a: number, b: number) => (a < b ? `${a}-${b}` : `${b}-${a}`);
  let aPairs = [norm(c, (c + 1) % 4), norm((c + 2) % 4, (c + 3) % 4)];
  let bPairs = [norm((c + 1) % 4, (c + 2) % 4), norm((c + 3) % 4, c)];
  if (rectSwapAxes.value) {
    const t = aPairs; aPairs = bPairs; bPairs = t;
  }
  // Read canvas CSS offsets directly (set in drawAllPolygons)
  const offX = Number((canvasEl.style.left || '0').replace('px','')) || 0;
  const offY = Number((canvasEl.style.top || '0').replace('px','')) || 0;
  // Pick topmost from A, leftmost from B
  const isPair = (m: any, pair: string) => pair === norm(m.i, m.j);
  const aCandidates = mids.filter((m) => aPairs.some((p) => isPair(m, p)));
  const bCandidates = mids.filter((m) => bPairs.some((p) => isPair(m, p)));
  const aMid = aCandidates.reduce((best, m) => (best && best.y < m.y ? best : m), aCandidates[0]);
  const bMid = bCandidates.reduce((best, m) => (best && best.x > m.x ? best : m), bCandidates[0]);
  return {
    a: { x: offX + (aMid?.x ?? 0), y: offY + (aMid?.y ?? 0) },
    b: { x: offX + (bMid?.x ?? 0), y: offY + (bMid?.y ?? 0) },
  };
});

const applyRectInputs = () => {
  const poly = selectedRectangle.value;
  const img = imageRef.value;
  const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0;
  if (!poly || !img || !(mpp > 0) || poly.points.length !== 4) return;
  const w = Number((rectWidth.value || '').replace(',', '.'));
  const h = Number((rectHeight.value || '').replace(',', '.'));
  if (!Number.isFinite(w) || !(w > 0) || !Number.isFinite(h) || !(h > 0)) return;
  const natW = img.naturalWidth;
  const natH = img.naturalHeight;
  const { p0, p1, p2 } = getRectTriplet(poly);
  let wIn = w, hIn = h;
  if (rectSwapAxes.value) [wIn, hIn] = [hIn, wIn];
  const uPx = { x: (p1.x - p0.x) * natW, y: (p1.y - p0.y) * natH };
  const vPx = { x: (p2.x - p1.x) * natW, y: (p2.y - p1.y) * natH };
  const uLen = Math.hypot(uPx.x, uPx.y) || 1;
  const vLen = Math.hypot(vPx.x, vPx.y) || 1;
  const ux = uPx.x / uLen;
  const uy = uPx.y / uLen;
  const vx = vPx.x / vLen;
  const vy = vPx.y / vLen;
  const wPx = wIn / mpp;
  const hPx = hIn / mpp;
  const du = { x: (ux * wPx) / natW, y: (uy * wPx) / natH };
  const dv = { x: (vx * hPx) / natW, y: (vy * hPx) / natH };
  const q0 = { x: p0.x, y: p0.y };
  const q1 = { x: clamp01(p0.x + du.x), y: clamp01(p0.y + du.y) };
  const q2 = { x: clamp01(q1.x + dv.x), y: clamp01(q1.y + dv.y) };
  const q3 = { x: clamp01(p0.x + dv.x), y: clamp01(p0.y + dv.y) };
  poly.points[0] = q0;
  poly.points[1] = q1;
  poly.points[2] = q2;
  poly.points[3] = q3;
  drawAllPolygons();
};

const showEdgeInput = ref<{ a: boolean; b: boolean }>({ a: false, b: false });
const edgeInputA = ref<string>('');
const edgeInputB = ref<string>('');
const { updatePolygonEdgeNotes } = useMeasure();

const hasRectNoteA = computed(() => {
  const v = selectedRectangle.value?.edgeNotesCm?.a as unknown as number | null | undefined;
  return typeof v === 'number' && Number.isFinite(v) && v > 0;
});
const hasRectNoteB = computed(() => {
  const v = selectedRectangle.value?.edgeNotesCm?.b as unknown as number | null | undefined;
  return typeof v === 'number' && Number.isFinite(v) && v > 0;
});

const selectedPolygonObj = computed<PolygonSurface | null>(() => {
  const list = polygons.value as PolygonSurface[];
  return list.find((p) => p.id === (selectedPolygonId.value || '')) ?? null;
});

const manualAreaLabel = computed(() => {
  if (!manualActive.value) return '';
  const p = selectedPolygonObj.value as any;
  if (!p) return '';
  let area: number | null | undefined = p.areaOverrideM2;
  if (!(typeof area === 'number' && isFinite(area) && area > 0)) {
    const a = p?.edgeNotesCm?.a as number | null | undefined;
    const b = p?.edgeNotesCm?.b as number | null | undefined;
    if (p?.points?.length === 4 && typeof a === 'number' && typeof b === 'number' && isFinite(a) && isFinite(b) && a > 0 && b > 0) {
      area = (a * b) / 10000;
    }
  }
  return typeof area === 'number' && isFinite(area) && area > 0 ? `${area.toFixed(2)} m²` : '';
});

const selectedPolygonCenter = computed(() => {
  if (!manualActive.value) return null as null | { x: number; y: number };
  const poly = selectedPolygonObj.value;
  const wrapper = zoomWrapperRef.value;
  const canvasEl = canvasRef.value;
  const _zs = zoomScale.value;
  if (!poly || !wrapper || !canvasEl) return null as null | { x: number; y: number };
  const den = poly.points.map((pt) => denormalizePoint(pt));
  if (!den.length) return null as null | { x: number; y: number };
  const center = getPolygonCenter(den);
  const canvasRect = canvasEl.getBoundingClientRect();
  const wrapperRect = wrapper.getBoundingClientRect();
  const offX = canvasRect.left - wrapperRect.left;
  const offY = canvasRect.top - wrapperRect.top;
  return { x: offX + center.x, y: offY + center.y };
});

// Manual per-edge input overlays for all non-rectangle polygons
const edgeInputsBuf = ref<Record<string, string>>({});
const edgeEditActive = ref<Record<string, boolean>>({});
type EdgeOverlay = { key: string; x: number; y: number; value: string; hasValue: boolean };
const allEdgeOverlays = computed<EdgeOverlay[]>(() => {
  if (!manualActive.value) return [];
  const canvasEl = canvasRef.value;
  const wrapper = zoomWrapperRef.value;
  if (!canvasEl || !wrapper) return [];
  const _zs = zoomScale.value;
  const offX = Number((canvasEl.style.left || '0').replace('px', '')) || 0;
  const offY = Number((canvasEl.style.top || '0').replace('px', '')) || 0;
  const result: EdgeOverlay[] = [];
  const all: PolygonSurface[] = [...(polygons.value as PolygonSurface[])];
  if (currentPolygon.value) all.push(currentPolygon.value as PolygonSurface);
  for (const poly of all) {
    if (!poly || poly.visible === false || !poly.closed || !poly.points || poly.points.length < 2) continue;
    // Skip rectangles (handled by dedicated A/B inputs)
    if (poly.points.length === 4) continue;
    const den = poly.points.map((pt) => denormalizePoint(pt));
    const notes = ((poly as any).edgeNotesCm?.edges ?? []) as (number | null | undefined)[];
    for (let i = 0; i < den.length; i++) {
      const j = (i + 1) % den.length;
      const midX = (den[i]!.x + den[j]!.x) / 2;
      const midY = (den[i]!.y + den[j]!.y) / 2;
      const key = `${poly.id}:${i}`;
      const stored = notes?.[i];
      const hasVal = (typeof stored === 'number' && isFinite(stored) && stored > 0);
      const val = hasVal
        ? String(Math.round(stored as number))
        : (edgeInputsBuf.value[key] ?? '');
      result.push({ key, x: offX + midX, y: offY + midY, value: val, hasValue: hasVal });
    }
  }
  return result;
});

const onEdgeInputBuffer = (key: string, e: Event) => {
  const v = (e.target as HTMLInputElement)?.value ?? '';
  edgeInputsBuf.value[key] = v;
};
const saveEdgeInput = (key: string) => {
  const raw = edgeInputsBuf.value[key] ?? '';
  const num = Number(String(raw).replace(',', '.'));
  const parts = key.split(':');
  if (parts.length !== 2) return;
  const pid = parts[0]!;
  const idx = Number(parts[1]);
  const poly = (polygons.value as PolygonSurface[]).find((p) => p.id === pid);
  if (!poly || Number.isNaN(idx)) return;
  if (!poly.edgeNotesCm) poly.edgeNotesCm = {} as any;
  const n = poly.points.length;
  let arr = ((poly.edgeNotesCm as any).edges as (number | null)[] | undefined) ?? undefined;
  if (!arr || arr.length !== n) arr = Array(n).fill(null);
  if (Number.isFinite(num) && num > 0) arr[idx] = Math.round(num); else arr[idx] = null;
  (poly.edgeNotesCm as any).edges = arr;
  // Persist
  void (async () => {
    try {
      await updatePolygonEdgeNotes(poly.id, poly.edgeNotesCm ?? null, poly.edgeNotesRect ?? null, poly.edgeNotesNorm ?? null, (poly as any).areaOverrideM2 ?? null);
    } catch {}
  })();
  delete edgeInputsBuf.value[key];
  if (edgeEditActive.value[key]) edgeEditActive.value[key] = false;
  drawAllPolygons();
};

const startEdgeEdit = (key: string) => {
  edgeEditActive.value[key] = true;
};

const manualAreaInput = ref<string>('');
watch(selectedPolygonObj, (p) => {
  const v = (p as any)?.areaOverrideM2 as number | null | undefined;
  manualAreaInput.value = typeof v === 'number' && isFinite(v) && v > 0 ? v.toFixed(2) : '';
});

const onRemovePoligon = (id: string) => {
  const list = polygons.value as PolygonSurface[];
  polygons.value = list.filter((p) => p.id !== id) as any;
  if (selectedPolygonId.value === id) selectedPolygonId.value = null;
  drawAllPolygons();
};
const onRemoveAllPoligon = () => {
  polygons.value = [] as any;
  selectedPolygonId.value = null;
  drawAllPolygons();
};
 

const saveManualArea = () => {
  const poly = selectedPolygonObj.value as any;
  if (!poly) return;
  const v = Number(String(manualAreaInput.value || '').replace(',', '.'));
  const area = Number.isFinite(v) && v > 0 ? v : null;
  poly.areaOverrideM2 = area;
  void (async () => {
    try {
      await updatePolygonEdgeNotes(poly.id, poly.edgeNotesCm ?? null, poly.edgeNotesRect ?? null, poly.edgeNotesNorm ?? null, area);
    } catch {}
  })();
  drawAllPolygons();
};

onMounted(() => {
  refreshRectInputs();
  showEdgeInput.value = { a: false, b: false };
  nextTick(() => { updateEdgeNotesRect(); });
  // If manual mode requested via query, enter Edit mode directly
  const manual = String((route.query as any)?.manual ?? '');
  if (manual && ['1','true','yes'].includes(manual.toLowerCase())) {
    setMode('edit');
  }
});

watch(() => selectedRectangle.value?.id, () => {
  rectCornerIdx.value = 0;
  rectSwapAxes.value = false;
  refreshRectInputs();
  showEdgeInput.value = { a: false, b: false };
  nextTick(() => { updateEdgeNotesRect(); });
  // Prefill visible overlay inputs from existing notes
  const poly = selectedRectangle.value;
  if (poly) {
    const a = poly.edgeNotesCm?.a as unknown as number | null | undefined;
    const b = poly.edgeNotesCm?.b as unknown as number | null | undefined;
    edgeInputA.value = (typeof a === 'number' && isFinite(a) && a > 0) ? String(a) : '';
    edgeInputB.value = (typeof b === 'number' && isFinite(b) && b > 0) ? String(b) : '';
  } else {
    edgeInputA.value = '';
    edgeInputB.value = '';
  }
});

const openEdgeInput = (which: 'a' | 'b') => {
  showEdgeInput.value = { a: false, b: false };
  if (which === 'a') {
    const v = selectedRectangle.value?.edgeNotesCm?.a ?? null;
    edgeInputA.value = v !== null && v !== undefined ? String(v) : '';
    showEdgeInput.value.a = true;
  } else {
    const v = selectedRectangle.value?.edgeNotesCm?.b ?? null;
    edgeInputB.value = v !== null && v !== undefined ? String(v) : '';
    showEdgeInput.value.b = true;
  }
};

const saveEdgeNote = (which: 'a' | 'b') => {
  const poly = selectedRectangle.value;
  if (!poly) { showEdgeInput.value = { a: false, b: false }; return; }
  const raw = which === 'a' ? edgeInputA.value : edgeInputB.value;
  const num = Number(String(raw || '').replace(',', '.'));
  if (!poly.edgeNotesCm) poly.edgeNotesCm = {};
  if (Number.isFinite(num)) {
    poly.edgeNotesCm[which] = Math.round(num);
  } else {
    poly.edgeNotesCm[which] = null;
  }
  if (which === 'a') showEdgeInput.value.a = false; else showEdgeInput.value.b = false;
  updateEdgeNotesRect();
  drawAllPolygons();
  const a = poly.edgeNotesCm?.a as unknown as number | undefined;
  const b = poly.edgeNotesCm?.b as unknown as number | undefined;
  const areaOverride = (poly.points?.length === 4 && typeof a === 'number' && typeof b === 'number' && isFinite(a) && isFinite(b) && a > 0 && b > 0)
    ? (a * b) / 10000
    : null;
  (poly as any).areaOverrideM2 = areaOverride;
  void (async () => {
    try {
      await updatePolygonEdgeNotes(poly.id, poly.edgeNotesCm ?? null, poly.edgeNotesRect ?? null, poly.edgeNotesNorm ?? null, areaOverride);
    } catch {}
  })();
};

const updateEdgeNotesRect = () => {
  const poly = selectedRectangle.value;
  const img = imageRef.value;
  if (!poly || !img || poly.points.length !== 4) { if (poly) poly.edgeNotesRect = undefined; return; }
  const aCm = poly.edgeNotesCm?.a;
  const bCm = poly.edgeNotesCm?.b;
  if (!Number.isFinite(aCm as number) || !Number.isFinite(bCm as number)) { poly.edgeNotesRect = undefined; return; }

  const natW = img.naturalWidth;
  const natH = img.naturalHeight;
  const { p0, p1, p2 } = getRectTriplet(poly);
  const uPx = { x: (p1.x - p0.x) * natW, y: (p1.y - p0.y) * natH };
  const vPx = { x: (p2.x - p1.x) * natW, y: (p2.y - p1.y) * natH };
  const lenU = Math.hypot(uPx.x, uPx.y) || 1;
  const lenV = Math.hypot(vPx.x, vPx.y) || 1;
  const uHat = { x: uPx.x / lenU, y: uPx.y / lenU };
  const vHat = { x: vPx.x / lenV, y: vPx.y / lenV };

  let a_m = (aCm as number) / 100;
  let b_m = (bCm as number) / 100;
  if (rectSwapAxes.value) { const t = a_m; a_m = b_m; b_m = t; }
  const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0;

  let targetU_px: number;
  let targetV_px: number;
  if (mpp > 0) {
    targetU_px = a_m / mpp;
    targetV_px = b_m / mpp;
  } else {
    targetU_px = lenU;
    const ratio = a_m > 0 ? b_m / a_m : 1;
    targetV_px = Math.max(1, targetU_px * ratio);
  }

  const du = { x: (uHat.x * targetU_px) / natW, y: (uHat.y * targetU_px) / natH };
  const dv = { x: (vHat.x * targetV_px) / natW, y: (vHat.y * targetV_px) / natH };
  const q0 = { x: clamp01(p0.x), y: clamp01(p0.y) };
  const q1 = { x: clamp01(q0.x + du.x), y: clamp01(q0.y + du.y) };
  const q2 = { x: clamp01(q1.x + dv.x), y: clamp01(q1.y + dv.y) };
  const q3 = { x: clamp01(q0.x + dv.x), y: clamp01(q0.y + dv.y) };
  poly.edgeNotesRect = [q0, q1, q2, q3];
  const trip = getRectTriplet(poly);
  const d = deriveShape('rectangle', Number(aCm), Number(bCm), { natW, natH, p0: trip.p0, p1: trip.p1, p2: trip.p2, swapAxes: rectSwapAxes.value, meterPerPixel: meterPerPixel.value || storedMeterPerPixel.value || null });
  poly.edgeNotesNorm = d.normalized;
  if ((!meterPerPixel.value || meterPerPixel.value <= 0) && d.estimatedMeterPerPixel && d.estimatedMeterPerPixel > 0) {
    meterPerPixel.value = d.estimatedMeterPerPixel;
  }
};

// Computed property to check if we're in view mode (not editing)
const isViewMode = computed(() => !editingMode.value && !editPointsMode.value && !calibrationMode.value);

// Sidebar visibility toggle
const sidebarVisible = ref(true);

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
  if (!calibrationMode.value || !calibrationStart.value || !imageRef.value || !canvasRef.value) return null as { x: number; y: number } | null;
  const endNorm = calibrationEnd.value ?? mousePos.value;
  if (!endNorm) return null as { x: number; y: number } | null;
  const p1 = denormalizePoint(calibrationStart.value);
  const p2 = denormalizePoint(endNorm);
  const mid = { x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2 };
  // Use canvas position which is always aligned with the image
  const canvasRect = canvasRef.value.getBoundingClientRect();
  const wrapperRect = zoomWrapperRef.value?.getBoundingClientRect();
  if (!wrapperRect) return { x: mid.x, y: mid.y };
  return { x: canvasRect.left - wrapperRect.left + mid.x, y: canvasRect.top - wrapperRect.top + mid.y };
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
  if (!editPointsMode.value || selectedPoints.value.size !== 1 || !imageRef.value || !canvasRef.value) return null as { x: number; y: number } | null;
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
  const canvasRect = canvasRef.value.getBoundingClientRect();
  const wrapperRect = wrapper?.getBoundingClientRect();
  if (!wrapperRect) return { x: p.x + 16, y: p.y - 16 };
  const offsetX = canvasRect.left - wrapperRect.left;
  const offsetY = canvasRect.top - wrapperRect.top;
  let x = offsetX + p.x + 16; // offset right
  let y = offsetY + p.y - 16; // offset up
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
  if (points.length === 0) return { x: 0, y: 0 };
  if (points.length === 1) return { x: points[0].x, y: points[0].y };
  if (points.length === 2) return { x: (points[0].x + points[1].x) / 2, y: (points[0].y + points[1].y) / 2 };
  let twiceArea = 0;
  let cx = 0;
  let cy = 0;
  for (let i = 0; i < points.length; i++) {
    const j = (i + 1) % points.length;
    const cross = points[i].x * points[j].y - points[j].x * points[i].y;
    twiceArea += cross;
    cx += (points[i].x + points[j].x) * cross;
    cy += (points[i].y + points[j].y) * cross;
  }
  if (Math.abs(twiceArea) < 1e-8) {
    const sx = points.reduce((acc, p) => acc + p.x, 0);
    const sy = points.reduce((acc, p) => acc + p.y, 0);
    return { x: sx / points.length, y: sy / points.length };
  }
  const area = twiceArea / 2;
  return { x: cx / (6 * area), y: cy / (6 * area) };
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
    if (!poly.closed && currentPolygon.value && mousePos.value && denormPoints.length > 0) {
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = 2;
      ctx.stroke();

      const lastIndex = denormPoints.length - 1;
      if (lastIndex >= 0) {
        const last: Point = denormPoints[lastIndex]!;
        let provisionalNorm = mousePos.value;
        const lastNorm = currentPolygon.value.points[lastIndex]!;
        const buf = edgeInputBuffer.value.trim();
        const num = Number((buf || '').replace(',', '.'));
        if (Number.isFinite(num) && num > 0) {
          const dir = { x: provisionalNorm.x - lastNorm.x, y: provisionalNorm.y - lastNorm.y };
          const target = computePointByLength(lastNorm, dir, num);
          if (target) provisionalNorm = target;
        }
        const mouse = denormalizePoint(provisionalNorm);
        ctx.beginPath();
        ctx.setLineDash([6, 6]);
        ctx.moveTo(last.x, last.y);
        ctx.lineTo(mouse.x, mouse.y);
        ctx.stroke();

        if (!manualActive.value) {
          const dx = mouse.x - last.x;
          const dy = mouse.y - last.y;
          const pxDistDom = Math.sqrt(dx * dx + dy * dy);
          const pxDistImg = (pxDistDom / rect.width) * img.naturalWidth;
          const length = pxDistImg * pixelSize;
          const midX = (last.x + mouse.x) / 2;
          const midY = (last.y + mouse.y) / 2;
          drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8);
        }
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
      let aSet: Set<string> | null = null;
      let bSet: Set<string> | null = null;
      const overlayActive = isSelectedPoly && manualActive.value && editPointsMode.value && poly.points.length === 4;
      if (isSelectedPoly && poly.points.length === 4) {
        const c = rectCornerIdx.value % 4;
        const i0 = c;
        const i1 = (c + 1) % 4;
        const i2 = (c + 2) % 4;
        const i3 = (c + 3) % 4;
        const norm = (a: number, b: number) => (a < b ? `${a}-${b}` : `${b}-${a}`);
        const aPairs = [norm(i0, i1), norm(i2, i3)];
        const bPairs = [norm(i1, i2), norm(i3, i0)];
        if (rectSwapAxes.value) {
          aSet = new Set(bPairs);
          bSet = new Set(aPairs);
        } else {
          aSet = new Set(aPairs);
          bSet = new Set(bPairs);
        }
      }

      for (let i = 0; i < denormPoints.length; i++) {
        const j = (i + 1) % denormPoints.length;
        const p1 = denormPoints[i];
        const p2 = denormPoints[j];
        const midX = (p1.x + p2.x) / 2;
        const midY = (p1.y + p2.y) / 2;

        const key = `${Math.min(i, j)}-${Math.max(i, j)}`;
        // In manual mode, we do not draw computed edge lengths at all
        if (manualActive.value) continue;
        // Otherwise, draw computed length
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        const pxDist = Math.sqrt(dx * dx + dy * dy);
        const length = (pxDist / rect.width) * img.naturalWidth * pixelSize;
        drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8);
      }

      

      let areaText: string | null = null;
      if (manualActive.value) {
        const ov = (poly as any).areaOverrideM2 as number | null | undefined;
        if (typeof ov === 'number' && isFinite(ov) && ov > 0) {
          areaText = `${ov.toFixed(2)} m²`;
        } else if (poly.points.length === 4 && Number.isFinite(poly.edgeNotesCm?.a as number) && Number.isFinite(poly.edgeNotesCm?.b as number)) {
          const aCm = Number(poly.edgeNotesCm!.a);
          const bCm = Number(poly.edgeNotesCm!.b);
          const areaM2 = (aCm * bCm) / 10000;
          areaText = `${areaM2.toFixed(2)} m²`;
        } else {
          areaText = null;
        }
      } else {
        const area = calculatePolygonArea(poly.points, pixelSize, img);
        areaText = `${area.toFixed(2)} m²`;
      }
      if (areaText) {
        const skipCanvasArea = manualActive.value && editPointsMode.value && isSelectedPoly && Boolean(manualAreaLabel.value);
        if (!skipCanvasArea) {
          const center = poly.edgeNotesRect && poly.edgeNotesRect.length === 4
            ? getPolygonCenter(poly.edgeNotesRect.map(denormalizePoint))
            : getPolygonCenter(denormPoints);
          drawLabel(ctx, areaText, center.x - 18, center.y - 8);
        }
      }
    }
  }
  if (calibrationMode.value && !manualActive.value && calibrationStart.value) {
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
  if (!manualActive.value && firstImage.value?.referenceStart && firstImage.value?.referenceEnd && img) {
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
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] });
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
  if (manualActive.value && mode === 'calibrate') return;
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

  if (mode === 'edit') {
    if (!selectedPolygonId.value) {
      const list = polygons.value as PolygonSurface[];
      for (let i = list.length - 1; i >= 0; i--) {
        const p = list[i];
        if (p && p.closed && p.points?.length >= 3) { selectedPolygonId.value = p.id; break; }
      }
    }
    refreshRectInputs();
  }

  void nextTick(() => {
    // Recalculate optimal zoom for the new mode
    calculateOptimalZoom();
    drawAllPolygons();
  });
};

const toggleCalibration = () => {
  if (manualActive.value) return;
  if (calibrationMode.value) setMode('view');
  else setMode('calibrate');
};

const togglePolygonEditing = () => {
  if (editingMode.value) setMode('view');
  else setMode('draw');
};

const handleCanvasClick = (event: MouseEvent) => {
  let clickPoint = normalizePoint(getCanvasCoords(event));

  // 1) Calibration mode: allow cloning an existing polygon edge as reference
  if (calibrationMode.value && !manualActive.value) {
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
  if (existingPoints.length > 0) {
    const buf = edgeInputBuffer.value.trim();
    const num = Number((buf || '').replace(',', '.'));
    if (Number.isFinite(num) && num > 0) {
      const lastNorm = existingPoints[existingPoints.length - 1]!;
      const dir = { x: clickPoint.x - lastNorm.x, y: clickPoint.y - lastNorm.y };
      const target = computePointByLength(lastNorm, dir, num);
      if (target) {
        clickPoint = target;
        edgeInputBuffer.value = '';
      }
    }
  }
  if (existingPoints.length >= 3 && isNearPoint(clickPoint, existingPoints[0]!)) {
    currentPolygon.value.closed = true;
    polygons.value.push(currentPolygon.value as PolygonSurface);
    currentPolygon.value = null;
  } else if (existingPoints.length >= 4) {
    existingPoints.push(clickPoint);
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

const computePointByLength = (last: Point, dirToMouse: Point, lengthMeters: number): Point | null => {
  const img = imageRef.value;
  const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0;
  if (!img || !(mpp > 0)) return null;
  const natW = img.naturalWidth;
  const natH = img.naturalHeight;
  const dx = dirToMouse.x * natW;
  const dy = dirToMouse.y * natH;
  const mag = Math.hypot(dx, dy);
  if (!(mag > 0)) return null;
  const scale = (lengthMeters / mpp) / mag;
  const nx = clamp01(last.x + dirToMouse.x * scale);
  const ny = clamp01(last.y + dirToMouse.y * scale);
  return { x: nx, y: ny };
};

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
  isDragging.value = false;
};

// Pan/drag handlers for view mode or draw mode with spacebar
const handleContainerMouseDown = (event: MouseEvent) => {
  if (!zoomContainerRef.value) return;

  // Allow drag in view mode OR in draw mode with spacebar pressed and zoomed in
  const canDrag = isViewMode.value || (isSpacePressed.value && zoomScale.value > 1.0);
  if (!canDrag) return;

  // Only start drag if clicking on the container itself (not on buttons or other elements)
  if (event.target !== zoomContainerRef.value && !zoomWrapperRef.value?.contains(event.target as Node)) return;

  isDragging.value = true;
  dragStart.value = { x: event.clientX, y: event.clientY };
  scrollStart.value = {
    x: zoomContainerRef.value.scrollLeft,
    y: zoomContainerRef.value.scrollTop,
  };
  event.preventDefault();
};

const handleContainerMouseMove = (event: MouseEvent) => {
  if (!isDragging.value || !zoomContainerRef.value) return;

  const dx = event.clientX - dragStart.value.x;
  const dy = event.clientY - dragStart.value.y;

  zoomContainerRef.value.scrollLeft = scrollStart.value.x - dx;
  zoomContainerRef.value.scrollTop = scrollStart.value.y - dy;
};

const handleContainerMouseUp = () => {
  isDragging.value = false;
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
  store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] });
  highlightStoredReference();
};

const onClearReference = () => {
  const imgMeta = firstImage.value;
  if (!imgMeta) return;
  imgMeta.referenceStart = null;
  imgMeta.referenceEnd = null;
  imgMeta.referenceLengthCm = null;
  showSavedReference.value = false;
  store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] });
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

// Calculate optimal zoom scale based on current mode
const calculateOptimalZoom = () => {
  if (!imageRef.value || !zoomContainerRef.value) return;

  const container = zoomContainerRef.value;
  const availableW = container.clientWidth;
  const availableH = container.clientHeight;

  const scaleX = availableW / imageWidth.value;
  const scaleY = availableH / imageHeight.value;

  // In View mode: fit image inside container (contain)
  // In Edit modes: fill container with image (cover)
  if (isViewMode.value) {
    zoomScale.value = Math.min(scaleX, scaleY);
  } else {
    zoomScale.value = Math.max(scaleX, scaleY);
  }
};

const onImageLoad = () => {
  if (!imageRef.value || !zoomContainerRef.value) return;

  imageWidth.value = imageRef.value.naturalWidth;
  imageHeight.value = imageRef.value.naturalHeight;

  // Set initial zoom
  calculateOptimalZoom();

  // ⬇️ Itt update-eljük a store-ban az image-et is
  if (wall.value && wall.value.images && wall.value.images.length > 0) {
    const imgMeta = wall.value.images?.[0];
    if (imgMeta) {
      imgMeta.processedImageWidth = imageWidth.value;
      imgMeta.processedImageHeight = imageHeight.value;
      store.setWall(surveyId.value, wall.value.id, {
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
  const target = e.target as HTMLElement | null;
  const tn = target?.tagName?.toLowerCase() || '';
  const isTyping = tn === 'input' || tn === 'textarea' || (target as any)?.isContentEditable;

  // Handle spacebar for drag mode
  if (e.code === 'Space' && !isTyping && !isViewMode.value && zoomScale.value > 1.0) {
    e.preventDefault();
    isSpacePressed.value = true;
    return;
  }

  if (editingMode.value && !isTyping) {
    if ((e.key >= '0' && e.key <= '9') || e.key === '.' || e.key === ',') {
      edgeInputBuffer.value += e.key;
      drawAllPolygons();
      e.preventDefault();
      return;
    }
    if (e.key === 'Backspace') {
      edgeInputBuffer.value = edgeInputBuffer.value.slice(0, -1);
      drawAllPolygons();
      e.preventDefault();
      return;
    }
    if (e.key === 'Escape') {
      edgeInputBuffer.value = '';
      drawAllPolygons();
      e.preventDefault();
      return;
    }
    if (e.key === 'Enter') {
      const buf = edgeInputBuffer.value.trim();
      const len = Number((buf || '').replace(',', '.'));
      const cp = currentPolygon.value;
      if (Number.isFinite(len) && len > 0 && cp) {
        const lastIdx = cp.points.length - 1;
        if (lastIdx >= 0 && mousePos.value) {
          pushHistory();
          const last = cp.points[lastIdx]!;
          const dir = { x: mousePos.value.x - last.x, y: mousePos.value.y - last.y };
          const target = computePointByLength(last, dir, len);
          if (target) {
            const pts = cp.points;
            if (pts.length >= 4) {
              pts.push(target);
              cp.closed = true;
              polygons.value.push(cp as PolygonSurface);
              currentPolygon.value = null;
            } else {
              pts.push(target);
            }
            edgeInputBuffer.value = '';
            drawAllPolygons();
            e.preventDefault();
            return;
          }
        }
      }
    }
  }

  if (!editPointsMode.value) return;
  if (isTyping) return;
  if (e.key === 'Delete' || e.key === 'Backspace') {
    if (selectedPoints.value.size > 0) {
      e.preventDefault();
      deleteSelectedPoints();
    }
  }
};

const onKeyup = (e: KeyboardEvent) => {
  if (e.code === 'Space') {
    isSpacePressed.value = false;
    if (isDragging.value && !isViewMode.value) {
      isDragging.value = false;
    }
  }
};

onMounted(() => {
  const manual = String((route.query as any)?.manual ?? '');
  if (manual && ['1','true','yes'].includes(manual.toLowerCase())) {
    setMode('calibrate');
  }
  window.addEventListener('resize', handleResize);
  window.addEventListener('keydown', onKeydown);
  window.addEventListener('keyup', onKeyup);
  const canvas = canvasRef.value;
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
  window.removeEventListener('keydown', onKeydown);
  window.removeEventListener('keyup', onKeyup);
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

// Auto-hide sidebar when drawing, show when polygon closed
watch(
  () => ({ mode: editingMode.value, polygon: currentPolygon.value, pointCount: currentPolygon.value?.points.length }),
  (state) => {
    if (state.mode && state.polygon && state.pointCount && state.pointCount > 0) {
      // Drawing in progress - hide sidebar
      sidebarVisible.value = false;
    } else if (state.mode && !state.polygon) {
      // Polygon closed or cancelled - show sidebar
      sidebarVisible.value = true;
    }
  },
  { deep: true }
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
