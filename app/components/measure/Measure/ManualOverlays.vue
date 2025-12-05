<template>
  <template v-if="manualActive">
    <!-- Selected rectangle edge inputs (A/B) -->
    <div
      v-if="rectEdges"
      class="absolute z-30"
      :style="{ left: rectEdges.a.x + 'px', top: rectEdges.a.y + 'px', transform: 'translate(-50%, -50%)' }"
    >
      <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
        <input
          class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
          type="text"
          inputmode="numeric"
          step="1"
          :value="edgeInputA || selectedRectNotes?.a || ''"
          placeholder="cm"
          @input="(e) => { $emit('update:edgeInputA', (e.target as HTMLInputElement).value); if (selectedRectId) onRectInputBuffer?.(selectedRectId, 'a', e) }"
          @keyup.enter="(e) => { (e.target as HTMLInputElement)?.blur?.() }"
          @focus="$emit('inputFocus', true)"
          @blur="() => { if (selectedRectId) saveRectInput?.(selectedRectId, 'a'); $emit('inputFocus', false) }"
        />
        <span class="text-[10px] opacity-80">cm</span>
      </div>
    </div>
    <div
      v-if="rectEdges"
      class="absolute z-30"
      :style="{ left: rectEdges.b.x + 'px', top: rectEdges.b.y + 'px', transform: 'translate(-50%, -50%)' }"
    >
      <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
        <input
          class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
          type="text"
          inputmode="numeric"
          step="1"
          :value="edgeInputB || selectedRectNotes?.b || ''"
          placeholder="cm"
          @input="(e) => { $emit('update:edgeInputB', (e.target as HTMLInputElement).value); if (selectedRectId) onRectInputBuffer?.(selectedRectId, 'b', e) }"
          @keyup.enter="(e) => { (e.target as HTMLInputElement)?.blur?.() }"
          @focus="$emit('inputFocus', true)"
          @blur="() => { if (selectedRectId) saveRectInput?.(selectedRectId, 'b'); $emit('inputFocus', false) }"
        />
        <span class="text-[10px] opacity-80">cm</span>
      </div>
    </div>

    <!-- Generic per-edge inputs for non-rect polygons -->
    <div
      v-for="ov in allEdgeOverlays"
      :key="ov.key"
      class="absolute z-30"
      :style="{ left: ov.x + 'px', top: ov.y + 'px', transform: 'translate(-50%, -50%)' }"
    >
      <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
        <input
          class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
          type="text"
          inputmode="numeric"
          step="1"
          :value="ov.value"
          placeholder="cm"
          @input="(e) => onEdgeInputBuffer?.(ov.key, e)"
          @keyup.enter="() => saveEdgeInput?.(ov.key)"
          @focus="$emit('inputFocus', true)"
          @blur="() => { saveEdgeInput?.(ov.key); $emit('inputFocus', false) }"
        />
        <span class="text-[10px] opacity-80">cm</span>
      </div>
    </div>

    <!-- Rectangle overlays for all rectangles (excluding selected) -->
    <div
      v-for="rov in rectOverlaysAll"
      :key="rov.key"
      class="absolute z-30"
      :style="{ left: rov.x + 'px', top: rov.y + 'px', transform: 'translate(-50%, -50%)' }"
    >
      <div class="flex items-center gap-1 bg-black/70 text-white rounded-full px-2 py-1 shadow backdrop-blur-sm border border-white/10">
        <input
          class="w-16 h-6 bg-transparent text-xs px-1 outline-none border-0"
          type="text"
          inputmode="numeric"
          step="1"
          :value="rov.value"
          placeholder="cm"
          @input="(e) => onRectInputBuffer?.(rov.polyId, rov.which, e)"
          @keyup.enter="() => saveRectInput?.(rov.polyId, rov.which)"
          @focus="$emit('inputFocus', true)"
          @blur="() => { saveRectInput?.(rov.polyId, rov.which); $emit('inputFocus', false) }"
        />
        <span class="text-[10px] opacity-80">cm</span>
      </div>
    </div>

    <!-- Manual area labels at polygon centers for all polygons -->
    <div
      v-for="al in manualAreaOverlays"
      :key="al.id"
      class="absolute z-30"
      :style="{ left: al.x + 'px', top: al.y + 'px', transform: 'translate(-50%, -50%)' }"
    >
      <div class="flex items-center gap-1 bg-neutral-900/85 text-white rounded-full px-2 py-1 shadow select-none">
        <span class="text-xs font-semibold">{{ al.label }}</span>
      </div>
    </div>
  </template>
</template>

<script setup lang="ts">
import type { EdgeOverlay, RectOverlay } from '@/service/Measurment/manualOverlays'

const props = defineProps<{
  manualActive: boolean
  rectEdges: { a: { x: number; y: number }; b: { x: number; y: number } } | null
  allEdgeOverlays: EdgeOverlay[]
  rectOverlaysAll: RectOverlay[]
  selectedRectId?: string | null
  selectedRectNotes?: { a?: number | string | null; b?: number | string | null } | null
  edgeInputA: string
  edgeInputB: string
  manualAreaOverlays: { id: string; x: number; y: number; label: string }[]
  onEdgeInputBuffer?: (key: string, e: Event) => void
  saveEdgeInput?: (key: string) => void
  onRectInputBuffer?: (polyId: string, which: 'a'|'b', e: Event) => void
  saveRectInput?: (polyId: string, which: 'a'|'b') => void
  saveEdgeNote?: (which: 'a'|'b') => void
}>()

defineEmits<{
  (e:'update:edgeInputA', v: string): void
  (e:'update:edgeInputB', v: string): void
  (e:'inputFocus', v: boolean): void
}>()
</script>
