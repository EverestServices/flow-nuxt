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

        <!-- Readonly calculated fields -->
        <div class="mb-3 space-y-2">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Fal hossza (m)</label>
            <input
              type="text"
              :value="wall.wall_length ? wall.wall_length.toFixed(2) : '—'"
              readonly
              class="w-full h-8 rounded-md border border-base-300 bg-base-200 text-sm px-2 cursor-not-allowed"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Fal magassága (m)</label>
            <input
              type="text"
              :value="wall.wall_height ? wall.wall_height.toFixed(2) : '—'"
              readonly
              class="w-full h-8 rounded-md border border-base-300 bg-base-200 text-sm px-2 cursor-not-allowed"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Lábazat magassága (cm)</label>
            <input
              type="text"
              :value="wall.foundation_height ? wall.foundation_height.toFixed(0) : '—'"
              readonly
              class="w-full h-8 rounded-md border border-base-300 bg-base-200 text-sm px-2 cursor-not-allowed"
            />
          </div>
        </div>

        <!-- Editable wall properties -->
        <div class="mb-3">
          <label class="block text-xs text-gray-500 mb-1">Fal szerkezete</label>
          <select
            :value="wall.wall_structure || ''"
            @change="onWallStructureChange(($event.target as HTMLSelectElement).value)"
            class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
          >
            <option value="">—</option>
            <option v-for="opt in wallStructureOptions" :key="opt" :value="opt">{{ opt }}</option>
          </select>
        </div>

        <div v-if="wall.wall_structure === 'Egyéb'" class="mb-3">
          <label class="block text-xs text-gray-500 mb-1">Fal szerkezetének pontos típusa</label>
          <input
            type="text"
            :value="wallStructureOther"
            @input="onWallStructureOtherChange(($event.target as HTMLInputElement).value)"
            class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
            placeholder="Pl.: Fahéj tégla"
          />
        </div>

        <div class="mb-3">
          <label class="block text-xs text-gray-500 mb-1">Fal vastagsága (cm)</label>
          <input
            type="number"
            :value="wall.wall_thickness || ''"
            @input="onWallThicknessChange(Number(($event.target as HTMLInputElement).value))"
            class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
            placeholder="Pl.: 38"
            min="0"
            step="1"
          />
        </div>

        <div class="mb-3">
          <label class="block text-xs text-gray-500 mb-1">Lábazat típusa</label>
          <select
            :value="wall.foundation_type || ''"
            @change="onFoundationTypeChange(($event.target as HTMLSelectElement).value)"
            class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
          >
            <option value="">—</option>
            <option v-for="opt in foundationTypeOptions" :key="opt" :value="opt">{{ opt }}</option>
          </select>
        </div>

        <div class="mb-3">
          <label class="block text-xs text-gray-500 mb-1">Ki/beugrás mérete (cm)</label>
          <input
            type="number"
            :value="wall.protrusion_size || ''"
            @input="onProtrusionSizeChange(Number(($event.target as HTMLInputElement).value))"
            class="w-full h-8 rounded-md border border-base-300 bg-base-100 text-sm px-2"
            placeholder="Pl.: 10"
            step="1"
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
              crossorigin="anonymous"
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
              @click="ihHandleCanvasClick"
              @mousedown="ihHandleMouseDown"
              @mousemove="ihHandleMouseMove"
              @mouseup="ihHandleMouseUp"
              @touchstart="ihHandleCanvasTouch"
            ></canvas>
            <ManualOverlays
              :manual-active="manualActive"
              :rect-edges="selectedRectangle ? rectEdges : null"
              :all-edge-overlays="allEdgeOverlays as any"
              :rect-overlays-all="rectOverlaysAll as any"
              :selected-rect-id="selectedRectangle ? selectedRectangle.id : null"
              :selected-rect-notes="selectedRectangle ? (selectedRectangle.edgeNotesCm as any) : null"
              :manual-area-overlays="manualAreaOverlays as any"
              v-model:edgeInputA="edgeInputA"
              v-model:edgeInputB="edgeInputB"
              :on-edge-input-buffer="onEdgeInputBuffer as any"
              :save-edge-input="saveEdgeInput as any"
              :on-rect-input-buffer="onRectInputBuffer as any"
              :save-rect-input="saveRectInput as any"
              :save-edge-note="saveEdgeNote as any"
              @inputFocus="(v)=>{ isOverlayInputFocused = v }"
            />
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
import { ref, nextTick, onMounted, computed, watch } from 'vue';
import { Orientation } from '@/model/Measure/ArucoWallSurface';
import PolygonList from './PolygonList.vue';
import type { Point, PolygonSurface, Wall } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import ExtraItemIcoList from './ExtraItemIcoList.vue';
import { useWallStore, clonePolygonData } from '@/stores/WallStore';
import { useRoute, useRouter } from 'vue-router';
import { canvasOffset } from '@/service/Measurment/overlayPosition';
import { getPolygonCenter, denormalizePoint as gDenormalizePoint } from '@/service/Measurment/geometry';
import { computeAllEdgeOverlays, computeRectOverlays, computeSelectedRectEdges, updateEdgeNotesRectFor as updateEdgeNotesRectForSvc } from '@/service/Measurment/manualOverlays';
import { drawOnMainCanvas, exportPng } from '@/service/Measurment/CanvasRenderer';
import { drawDynamicOverlays } from '@/service/Measurment/dynamicOverlays';
import { recalcMeterPerPixelFromReference as recalcMppSvc, computeCalibrationMidOverlay } from '@/service/Measurment/Calibration';
import { getRectTriplet as getRectTripletSvc, lengthMetersBetween as lengthMetersBetweenSvc, applyRectInputsToPolygon } from '@/service/Measurment/rectUtils';
import { isNearPoint as isNearPointSvc, findEdgeUnderPoint as findEdgeUnderPointSvc } from '@/service/Measurment/hitTest';
import { createPanHandlers } from '@/service/Measurment/pan';
import { createInteractionHandlers, computePointByLengthStandalone } from '@/service/Measurment/interactionHandlers';
import { createReferenceControls } from '@/service/Measurment/referenceControls';
import { setupMeasureLifecycle } from '@/service/Measurment/measureLifecycle';
import { createZoomControls } from '@/service/Measurment/zoomControls';
import { createModeManager } from '@/service/Measurment/modeManager';
import { createManualInputControls } from '@/service/Measurment/manualInputControls';
import { useWallSync } from '@/composables/useWallSync';
import { createHistory } from '@/service/Measurment/history';
import { useMeasure } from '@/composables/useMeasure';
import ManualOverlays from './ManualOverlays.vue';
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

// (moved watchers below after manualActive/polygons declarations)

// Ensure a reactive wall entry exists in the store so deep mutations (polygons, images) persist to localStorage
const ensureWallInStore = () => {
  const surveyWalls = store.getWallsForSurvey(surveyId.value);
  if (!surveyWalls[wallId.value]) {
    store.setWall(surveyId.value, wallId.value, { id: wallId.value, name: '', images: [], polygons: [] } as Wall);
  }
};
ensureWallInStore();

watch(() => wallId.value, () => {
  ensureWallInStore();
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
  // Commit latest polygons/image meta to store to ensure persistence
  try {
    if (wall.value) {
      const img0 = wall.value.images?.[0];
      const nextImages = [...(wall.value.images || [])];
      if (img0) {
        img0.processedImageWidth = imageWidth.value || img0.processedImageWidth;
        img0.processedImageHeight = imageHeight.value || img0.processedImageHeight;
        if (meterPerPixel.value > 0) img0.meterPerPixel = meterPerPixel.value;
        // Mark manual flag; polygon-based geometry is persisted inside wall.polygons
        img0.manual = Boolean(manualActive.value);
        // Persist image meta to DB if imageId is available
        try {
          if ((img0 as any)?.imageId) {
            await updateWallImage((img0 as any).imageId, {
              meterPerPixel: img0.meterPerPixel ?? null,
              processedImageWidth: img0.processedImageWidth ?? null,
              processedImageHeight: img0.processedImageHeight ?? null,
              manual: img0.manual ?? null,
            } as any);
          }
        } catch (e) {
          console.warn('updateWallImage failed (non-fatal):', e);
        }
      }
      store.setWall(surveyId.value, wall.value.id, {
        ...wall.value,
        images: nextImages,
        polygons: [...(polygons.value as PolygonSurface[])],
      });
    }
    // Sync walls to survey before navigating back
    await syncWallsToSurvey(surveyId.value);
  } catch (error) {
    console.error('Error syncing walls:', error);
  }
  await router.push(`/survey/${String(route.params.surveyId)}/measure`);
};

// Reference controls initialized later (after dependent refs)

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
}

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
// Orientation select helpers (template uses these)
const orientationOptions: Orientation[] = [
  Orientation.N, Orientation.NW, Orientation.W, Orientation.SW,
  Orientation.S, Orientation.SE, Orientation.E, Orientation.NE,
];
const onOrientationChange = (val: string) => {
  const v = (val ? (val as Orientation) : null);
  if (wall.value) {
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, orientation: v ?? undefined });
  }
};
const wallOrientation = computed<Orientation | null>({
  get: () => (wall.value?.orientation ?? null) as Orientation | null,
  set: (val: Orientation | null) => {
    if (wall.value) {
      store.setWall(surveyId.value, wall.value.id, { ...wall.value, orientation: val ?? undefined });
    }
  },
});

// Wall structure and foundation options
const wallStructureOptions = [
  "Vegyes",
  "Tömör tégla (kisméretű vagy nagyméretű)",
  "Mészhomok tégla",
  "Kevéslyukú tégla",
  "Soklyukú tégla",
  "Tégla falazóblokk (1950-1980-ig)",
  "Tégla falazóblokk (1980-1990-ig)",
  "Tégla falazóblokk (1990 után)",
  "Gázszilikát (1990 előtti pórusbeton)",
  "Ytong (1990 utáni pórusbeton)",
  "Vasbeton (monolit)",
  "Vasbeton panel",
  "Szalma",
  "Vályog",
  "Könnyűszerkezetes",
  "Egyéb"
];

const foundationTypeOptions = [
  "Pozitív",
  "Negatív"
];

const wallStructureOther = ref<string>('');

// Wall property change handlers
const onWallStructureChange = (val: string) => {
  if (wall.value) {
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, wall_structure: val || undefined });
    // Trigger sync to survey
    syncWallsToSurvey(surveyId.value).catch(console.error);
  }
};

const onWallStructureOtherChange = (val: string) => {
  wallStructureOther.value = val;
  // Note: wall_structure_other is stored in survey, not in Wall model
  // We'll handle this during sync
};

const onWallThicknessChange = (val: number) => {
  if (wall.value && Number.isFinite(val) && val > 0) {
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, wall_thickness: val });
    // Trigger sync to survey
    syncWallsToSurvey(surveyId.value).catch(console.error);
  }
};

const onFoundationTypeChange = (val: string) => {
  if (wall.value) {
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, foundation_type: val || undefined });
    // Trigger sync to survey
    syncWallsToSurvey(surveyId.value).catch(console.error);
  }
};

const onProtrusionSizeChange = (val: number) => {
  if (wall.value && Number.isFinite(val)) {
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, protrusion_size: val });
    // Trigger sync to survey
    syncWallsToSurvey(surveyId.value).catch(console.error);
  }
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
const imageWidth = ref(0);
const imageHeight = ref(0);
const isOverlayInputFocused = ref(false);

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

// Rehydrate rectangle cm notes from manualGeom when present (e.g. after reload)
const rehydrateRectEdgeNotesFromManualGeom = () => {
  const list = polygons.value as PolygonSurface[];
  let changed = false;
  for (const p of list) {
    if (!p || !p.closed || p.points?.length !== 4) continue;
    const anyP = p as any;
    const mg = anyP.manualGeom;
    if (!mg || mg.type !== 'rectangle') continue;
    if (!anyP.edgeNotesCm) anyP.edgeNotesCm = {};
    const curA = anyP.edgeNotesCm.a as number | null | undefined;
    const curB = anyP.edgeNotesCm.b as number | null | undefined;
    const hasA = typeof curA === 'number' && isFinite(curA) && curA > 0;
    const hasB = typeof curB === 'number' && isFinite(curB) && curB > 0;
    let localChanged = false;
    if (!hasA && typeof mg.aCm === 'number' && isFinite(mg.aCm) && mg.aCm > 0) {
      anyP.edgeNotesCm.a = Math.round(mg.aCm);
      localChanged = true;
    }
    if (!hasB && typeof mg.bCm === 'number' && isFinite(mg.bCm) && mg.bCm > 0) {
      anyP.edgeNotesCm.b = Math.round(mg.bCm);
      localChanged = true;
    }
    if (localChanged) changed = true;
  }
  if (changed) {
    // trigger store setter so changes persist and overlays see updated values
    polygons.value = [...(polygons.value as PolygonSurface[])];
  }
};

const currentPolygon = ref<PolygonSurface | null>(null);
const editingMode = ref<boolean>(false);
const editPointsMode = ref<boolean>(false);
const selectedPolygonId = ref<string | null>(null);
// Ensure we always have a selection in manual mode (run immediately)
watch(polygons, (list) => {
  if (!manualActive.value) return;
  if (selectedPolygonId.value) return;
  const arr = list as PolygonSurface[];
  for (let i = arr.length - 1; i >= 0; i--) {
    const p = arr[i];
    if (p && p.closed && p.points?.length >= 3) { selectedPolygonId.value = p.id; break; }
  }
}, { immediate: true });

// Keep edit mode and selection consistent in manual mode (handles reloads)
watch(manualActive, (v) => {
  if (v) setMode('edit');
});

// Auto-recalculate wall dimensions when FACADE or WALL_PLINTH polygons change
let dimensionSyncTimer: NodeJS.Timeout | null = null;
let initialSyncDone = ref(false);
watch(
  () => wall.value?.polygons,
  (newPolygons, oldPolygons) => {
    // Check if there are any FACADE or WALL_PLINTH polygons
    const hasFacadeOrPlinth = newPolygons?.some(
      p => (p.type === SurfaceType.FACADE || p.type === SurfaceType.WALL_PLINTH) && p.closed
    );

    if (!hasFacadeOrPlinth && initialSyncDone.value) return;

    // On initial load, sync immediately to populate readonly fields
    if (!initialSyncDone.value && hasFacadeOrPlinth) {
      initialSyncDone.value = true;
      // Small delay to ensure image is loaded
      setTimeout(() => {
        syncWallsToSurvey(surveyId.value).catch(console.error);
      }, 100);
      return;
    }

    // Skip if no actual change (same reference) after initial sync
    if (newPolygons === oldPolygons && initialSyncDone.value) return;

    // Debounce the sync to avoid too frequent updates
    if (dimensionSyncTimer) clearTimeout(dimensionSyncTimer);
    dimensionSyncTimer = setTimeout(() => {
      syncWallsToSurvey(surveyId.value).catch(console.error);
    }, 500);
  },
  { deep: true, immediate: true }
);

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
// Ensure overlays update immediately when selection changes
watch(selectedPolygonId, async () => {
  await nextTick();
  scrollTick.value++;
});
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

const lengthMetersBetween = (a: Point, b: Point): number =>
  lengthMetersBetweenSvc(a, b, imageRef.value || null, meterPerPixel.value || storedMeterPerPixel.value || 0);

const getRectTriplet = (poly: PolygonSurface) => getRectTripletSvc(poly, rectCornerIdx.value);

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

 

// Bring Supabase update helpers into scope
const { updatePolygonEdgeNotes, updateWallImage } = useMeasure();

// Manual input controls (edge/rect inputs) moved to service
const {
  edgeInputsBuf,
  edgeEditActive,
  onEdgeInputBuffer,
  saveEdgeInput,
  startEdgeEdit,
  rectInputsBuf,
  onRectInputBuffer,
  saveRectInput,
  showEdgeInput,
  edgeInputA,
  edgeInputB,
  openEdgeInput,
  updateEdgeNotesRect,
  saveEdgeNote,
} = createManualInputControls({
  imageRef,
  zoomWrapperRef,
  canvasRef,
  polygons: polygons as any,
  selectedRectangle,
  meterPerPixel,
  storedMeterPerPixel: storedMeterPerPixel as any,
  drawAllPolygons,
  updatePolygonEdgeNotes,
});

// Prefill selected-rect A/B buffers only when no input is focused to avoid accidental clearing
watch(selectedRectangle, (p) => {
  if (isOverlayInputFocused.value) return;
  const a = (p as any)?.edgeNotesCm?.a as number | null | undefined;
  const b = (p as any)?.edgeNotesCm?.b as number | null | undefined;
  edgeInputA.value = (typeof a === 'number' && isFinite(a) && a > 0) ? String(Math.round(a)) : '';
  edgeInputB.value = (typeof b === 'number' && isFinite(b) && b > 0) ? String(Math.round(b)) : '';
});

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
  const _zs = zoomScale.value; // depend on zoom
  const _st = scrollTick.value; // depend on scroll
  if (!poly || !img || !wrapper || !canvasEl) return null as any;
  return computeSelectedRectEdges({
    poly,
    imageEl: img,
    wrapperEl: wrapper,
    canvasEl,
    rectCornerIdx: rectCornerIdx.value,
    swapAxes: rectSwapAxes.value,
  });
});

const applyRectInputs = () => {
  const poly = selectedRectangle.value;
  const img = imageRef.value;
  const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0;
  if (!poly || !img || !(mpp > 0) || poly.points.length !== 4) return;
  const w = Number((rectWidth.value || '').replace(',', '.'));
  const h = Number((rectHeight.value || '').replace(',', '.'));
  if (!Number.isFinite(w) || !(w > 0) || !Number.isFinite(h) || !(h > 0)) return;
  applyRectInputsToPolygon({
    poly,
    widthMeters: w,
    heightMeters: h,
    swapAxes: rectSwapAxes.value,
    img,
    meterPerPixel: mpp,
    cornerIdx: rectCornerIdx.value,
  });
  drawAllPolygons();
};

 

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

// Manual area labels for all polygons (not only selected)
const manualAreaOverlays = computed(() => {
  if (!manualActive.value) return [] as { id: string; x: number; y: number; label: string }[];
  const img = imageRef.value;
  const wrapper = zoomWrapperRef.value;
  const canvasEl = canvasRef.value;
  const _zs = zoomScale.value; // depend on zoom
  const _st = scrollTick.value; // depend on scroll
  if (!img || !wrapper || !canvasEl) return [];

  const { offX, offY } = canvasOffset(wrapper, canvasEl);

  const computeArea = (p: PolygonSurface): number => {
    const anyP = p as any;
    const ov = anyP.areaOverrideM2 as number | null | undefined;
    if (typeof ov === 'number' && isFinite(ov) && ov > 0) return ov;

    // Rectangle from A/B notes
    const a = anyP.edgeNotesCm?.a as number | null | undefined;
    const b = anyP.edgeNotesCm?.b as number | null | undefined;
    if (p.points?.length === 4 && typeof a === 'number' && typeof b === 'number' && isFinite(a) && isFinite(b) && a > 0 && b > 0) {
      return (a * b) / 10000;
    }

    // Triangle from edges/manualGeom (Heron)
    if (p.points?.length === 3) {
      const edges = (anyP.edgeNotesCm?.edges || []) as Array<number | null | undefined>;
      if (edges.length === 3 && edges.every(v => typeof v === 'number' && isFinite(v as number) && (v as number) > 0)) {
        const aM = (edges[0] as number) / 100;
        const bM = (edges[1] as number) / 100;
        const cM = (edges[2] as number) / 100;
        const valid = aM + bM > cM && aM + cM > bM && bM + cM > aM;
        if (!valid) return 0;
        const s = (aM + bM + cM) / 2;
        const tri = Math.sqrt(Math.max(0, s * (s - aM) * (s - bM) * (s - cM)));
        if (tri > 0) return tri;
      }
      const mg = anyP.manualGeom;
      if (mg && mg.type === 'triangle') {
        const aCm = Number(mg.aCm), bCm = Number(mg.bCm), cCm = Number(mg.cCm);
        if (aCm > 0 && bCm > 0 && cCm > 0) {
          const aM = aCm / 100, bM = bCm / 100, cM = cCm / 100;
          const valid = aM + bM > cM && aM + cM > bM && bM + cM > aM;
          if (!valid) return 0;
          const s = (aM + bM + cM) / 2;
          const tri = Math.sqrt(Math.max(0, s * (s - aM) * (s - bM) * (s - cM)));
          if (tri > 0) return tri;
        }
      }
    }

    return 0;
  };

  const overlays: { id: string; x: number; y: number; label: string }[] = [];
  for (const p of polygons.value as PolygonSurface[]) {
    if (!p.closed) continue;
    const area = computeArea(p);
    if (!(area > 0)) continue;
    const den = p.points.map((pt) => gDenormalizePoint(pt, img));
    if (!den.length) continue;
    const center = getPolygonCenter(den);
    overlays.push({ id: p.id, x: offX + center.x, y: offY + center.y, label: `${area.toFixed(2)} m²` });
  }
  return overlays;
});

// Manual per-edge input overlays for all non-rectangle polygons (buffers provided by service)
const allEdgeOverlays = computed(() => {
  if (!manualActive.value) return [] as any[];
  const img = imageRef.value;
  const wrapper = zoomWrapperRef.value;
  const canvas = canvasRef.value;
  const _zs = zoomScale.value; // depend on zoom
  const _st = scrollTick.value; // depend on scroll
  if (!img || !wrapper || !canvas) return [] as any[];
  const base = computeAllEdgeOverlays({
    polygons: polygons.value as PolygonSurface[],
    currentPolygon: currentPolygon.value as PolygonSurface | null,
    imageEl: img,
    wrapperEl: wrapper,
    canvasEl: canvas,
    edgeInputsBuf: edgeInputsBuf.value,
  });
  // show overlays for all polygons, do not filter by selection
  return base as any[];
});

// onEdgeInputBuffer/saveEdgeInput provided by service

// Rectangle overlays for all rectangles (excluding the selected one)
const rectOverlaysAll = computed(() => {
  if (!manualActive.value) return [] as any[];
  const img = imageRef.value;
  const wrapper = zoomWrapperRef.value;
  const canvas = canvasRef.value;
  const _zs = zoomScale.value; // depend on zoom
  const _st = scrollTick.value; // depend on scroll
  if (!img || !wrapper || !canvas) return [] as any[];
  return computeRectOverlays({
    polygons: polygons.value as PolygonSurface[],
    selectedRectId: selectedRectangle.value?.id ?? null,
    imageEl: img,
    wrapperEl: wrapper,
    canvasEl: canvas,
    rectInputsBuf: rectInputsBuf.value,
  }) as any[];
});

// rect input handlers and startEdgeEdit provided by service

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
  // Ensure rectangle cm notes exist after reload (from manualGeom / persisted edgeNotesCm)
  rehydrateRectEdgeNotesFromManualGeom();
  refreshRectInputs();
  showEdgeInput.value = { a: false, b: false };
  nextTick(() => { updateEdgeNotesRect(); });
  const manual = String((route.query as any)?.manual ?? '');
  if (manual && ['1','true','yes'].includes(manual.toLowerCase())) setMode('edit');
  // If image meta already marks manual, ensure we enter edit mode and have a selection
  if (manualActive.value) setMode('edit');
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

// openEdgeInput/saveEdgeNote provided by service

// updateEdgeNotesRect provided by service

// Computed property to check if we're in view mode (not editing)
const isViewMode = computed(() => !editingMode.value && !editPointsMode.value && !calibrationMode.value);

// Initialize pan handlers after isViewMode is defined
const { handleContainerMouseDown, handleContainerMouseMove, handleContainerMouseUp } = createPanHandlers({
  zoomContainerRef,
  zoomWrapperRef,
  isViewMode,
  isSpacePressed,
  zoomScale,
  dragStart,
  scrollStart,
  isDragging,
});

// Zoom controls from service (needs imageWidth/Height and isViewMode)
const { calculateOptimalZoom, gotoZoom, zoomBy } = createZoomControls({
  imageRef,
  zoomContainerRef,
  zoomWrapperRef,
  imageWidth,
  imageHeight,
  isViewMode,
  zoomScale,
});

// Sidebar visibility toggle
const sidebarVisible = ref(true);
// Tick to recompute overlay positions on scroll/pan/zoom
const scrollTick = ref(0);
// When overlay inputs lose focus, force a recompute to ensure positions refresh
watch(isOverlayInputFocused, (v) => { if (!v) scrollTick.value++; });
// Always nudge overlays when polygon geometry changes (drag/move), even if input is focused
watch(polygons, async () => { await nextTick(); scrollTick.value++; }, { deep: true });

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
  if (!calibrationMode.value) return null as { x: number; y: number } | null;
  const endNorm = calibrationEnd.value ?? mousePos.value ?? null;
  return computeCalibrationMidOverlay(
    calibrationStart.value,
    endNorm,
    imageRef.value,
    canvasRef.value,
    zoomWrapperRef.value,
  );
});

// Ensure saved reference always applies: compute meterPerPixel from stored reference points + length
const recalcMeterPerPixelFromReference = (): boolean => {
  const mpp = recalcMppSvc(firstImage.value, imageRef.value);
  if (mpp && mpp > 0) {
    meterPerPixel.value = mpp;
    return true;
  }
  return false;
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
  const p = denormalizePoint(pt as Point);
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

const { pushHistory, undo, redo } = createHistory({
  getPolygons: () => polygons.value as PolygonSurface[],
  setPolygons: (p) => { polygons.value = p; },
  getCurrent: () => currentPolygon.value as PolygonSurface | null,
  setCurrent: (c) => { currentPolygon.value = c; },
  drawAllPolygons,
  clonePolygonData,
});
const handleUndo = () => undo();
const handleRedo = () => redo();

// Initialize extracted canvas interaction handlers (after pushHistory is available)
const ihDragSnapshot = ref<{
  start: Point;
  items: Array<{ polyId: string; index: number; start: Point }>;
} | null>(null);
const {
  handleCanvasClick: ihHandleCanvasClick,
  handleMouseDown: ihHandleMouseDown,
  handleMouseMove: ihHandleMouseMove,
  handleMouseUp: ihHandleMouseUp,
  handleCanvasTouch: ihHandleCanvasTouch,
} = createInteractionHandlers({
  canvasRef,
  imageRef,
  editingMode,
  editPointsMode,
  calibrationMode,
  manualActive,
  referenceSet,
  allowRefOverride,
  calibrationStart,
  calibrationEnd,
  polygons: polygons as unknown as any,
  currentPolygon,
  selectedPolygonId,
  selectedPoints,
  draggingPoint,
  dragSnapshot: ihDragSnapshot as any,
  mousePos,
  meterPerPixel,
  storedMeterPerPixel: storedMeterPerPixel as unknown as any,
  edgeInputBuffer,
  pushHistory,
  drawAllPolygons,
  clearSelection,
  toggleSelection,
  selectOnly,
  isNearPoint: (p1: Point, p2: Point) => isNearPointSvc(p1, p2),
  findEdgeUnderPoint: (pt: Point) => findEdgeUnderPointSvc(pt, polygons.value as PolygonSurface[]),
});

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

const isNearPoint = (p1: Point, p2: Point): boolean => isNearPointSvc(p1, p2);

const denormalizePoint = (norm: Point): Point => gDenormalizePoint(norm, imageRef.value!);

// Touch handled by interactionHandlers

const getPolygonColors = (poly: PolygonSurface) => {
  const isSelected = poly.id === selectedPolygonId.value;
  switch (poly.type) {
    case SurfaceType.FACADE:
      return {
        strokeColor: '#f59e0b',
        fillColor: isSelected ? 'rgba(245,158,11,0.45)' : 'rgba(245,158,11,0.15)',
        pointColor: '#f59e0b',
      };
    case SurfaceType.WINDOW_DOOR:
      return {
        strokeColor: '#10b981',
        fillColor: isSelected ? 'rgba(16,185,129,0.5)' : 'rgba(16,185,129,0.2)',
        pointColor: 'rgba(16,185,129,0.7)',
      };
    case SurfaceType.WALL_PLINTH:
      return {
        strokeColor: '#f59e0b',
        fillColor: isSelected ? 'rgba(245,158,11,0.45)' : 'rgba(245,158,11,0.2)',
        pointColor: 'rgba(245,158,11,0.7)',
      };
    default:
      return {
        strokeColor: '#4b5563',
        fillColor: isSelected ? 'rgba(75,85,99,0.4)' : 'rgba(75,85,99,0.15)',
        pointColor: 'rgba(75,85,99,0.7)',
      };
  }
};

// drawLabel imported from CanvasDrawer

function drawAllPolygons() {
  const canvas = canvasRef.value;
  const img = imageRef.value;
  if (!canvas || !img) return;
  drawOnMainCanvas({
    canvas,
    img,
    polygons: polygons.value as PolygonSurface[],
    currentPolygon: currentPolygon.value as PolygonSurface | null,
    selectedPolygonId: selectedPolygonId.value,
    pixelSize: meterPerPixel.value || storedMeterPerPixel.value || 0,
    getColors: getPolygonColors,
    showComputedLabels: !manualActive.value,
  });
  // Acquire context once for overlays drawn after base pass
  const ctx = canvas.getContext('2d');
  if (!ctx) return;
  drawDynamicOverlays(ctx, {
    imageEl: imageRef.value,
    currentPolygon: currentPolygon.value as PolygonSurface | null,
    mousePos: mousePos.value,
    edgeInputBuffer: edgeInputBuffer.value,
    meterPerPixel: meterPerPixel.value || 0,
    storedMeterPerPixel: storedMeterPerPixel.value || 0,
    calibrationMode: calibrationMode.value,
    calibrationStart: calibrationStart.value,
    calibrationEnd: calibrationEnd.value,
    manualActive: manualActive.value,
    firstImageMeta: firstImage.value,
    highlightRef: highlightRef.value,
  });
  // Nudge overlay recomputations (HTML overlays depend on scrollTick)
  if (!isOverlayInputFocused.value) scrollTick.value++;
}


const { setMode, toggleCalibration, togglePolygonEditing } = createModeManager({
  manualActive,
  calibrationStart,
  calibrationEnd,
  allowRefOverride,
  selectedPolygonId,
  polygons: polygons as any,
  currentPolygon,
  editingMode,
  editPointsMode,
  calibrationMode,
  recalcMeterPerPixelFromReference,
  calculateOptimalZoom,
  drawAllPolygons,
  refreshRectInputs,
  clearSelection,
});


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

const downloadWithPolygons = async () => {
  const img = imageRef.value;
  if (!img) return;
  const baseName = (wallName.value || wallId.value || 'measure').replace(/\s+/g, '-');
  await exportPng({
    img,
    polygons: polygons.value as PolygonSurface[],
    currentPolygon: currentPolygon.value as PolygonSurface | null,
    pixelSize: meterPerPixel.value || storedMeterPerPixel.value || 0,
    getColors: getPolygonColors,
    fileName: baseName,
  });
};
 

// Reference controls (apply/toggle/highlight/etc.) moved to service; init here after dependent refs
const {
  applyCalibration,
  highlightStoredReference,
  toggleSavedReference,
  onStartNewReference,
  onChangeReferenceLength,
  onClearReference,
} = createReferenceControls({
  firstImage,
  imageRef,
  wall,
  surveyId,
  store,
  imageWidth,
  imageHeight,
  zoomScale,
  zoomContainerRef,
  highlightRef,
  drawAllPolygons,
  setMode,
  meterPerPixel,
  allowRefOverride,
  showSavedReference,
  calibrationStart,
  calibrationEnd,
  calibrationLength,
});

// calculateOptimalZoom provided by zoomControls

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
          const target = computePointByLengthStandalone(imageRef.value!, meterPerPixel.value || 0, storedMeterPerPixel.value || 0, last, dir, len);
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
            // Commit polygons so setter persists to store/localStorage
            polygons.value = [...(polygons.value as PolygonSurface[])];
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

// Lifecycle & watchers moved to service
setupMeasureLifecycle({
  zoomContainerRef,
  zoomWrapperRef,
  imageRef,
  firstImage,
  scrollTick,
  handleResize,
  onKeydown,
  onKeyup,
  polygons: polygons as any,
  drawAllPolygons,
  editingMode,
  currentPolygon,
  sidebarVisible,
  meterPerPixel,
  zoomScale,
  recalcMeterPerPixelFromReference,
});

const removePoligonsById = (id: string) => {
  pushHistory();
  polygons.value = polygons.value.filter((polygon: PolygonSurface) => polygon.id !== id);
  if (selectedPolygonId.value === id) selectedPolygonId.value = null;
  drawAllPolygons();
};
// watchers handled by setupMeasureLifecycle
const restoreCalibration = () => {
  meterPerPixel.value = storedMeterPerPixel.value;
};
const removeAllPoligon = () => {
  pushHistory();
  polygons.value = [];
  selectedPolygonId.value = null;
  drawAllPolygons();
};
// zoomBy provided by zoomControls
</script>

<style scoped>
canvas {
  pointer-events: auto;
}
</style>
