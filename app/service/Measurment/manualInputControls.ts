import type { Ref, ComputedRef } from 'vue'
import { ref } from 'vue'
import type { PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { updateEdgeNotesRectFor as updateEdgeNotesRectForSvc } from '@/service/Measurment/manualOverlays'

export function createManualInputControls(params: {
  imageRef: Ref<HTMLImageElement | null>
  zoomWrapperRef: Ref<HTMLElement | null>
  canvasRef: Ref<HTMLCanvasElement | null>
  polygons: Ref<PolygonSurface[]>
  selectedRectangle: ComputedRef<PolygonSurface | null>
  meterPerPixel: Ref<number>
  storedMeterPerPixel: Ref<number> | ComputedRef<number>
  drawAllPolygons: () => void
  updatePolygonEdgeNotes: (
    id: string,
    edgeNotesCm: any,
    edgeNotesRect: any,
    edgeNotesNorm: any,
    area: number | null,
  ) => Promise<unknown> | void
}) {
  const {
    imageRef,
    zoomWrapperRef,
    canvasRef,
    polygons,
    selectedRectangle,
    meterPerPixel,
    storedMeterPerPixel,
    drawAllPolygons,
    updatePolygonEdgeNotes,
  } = params

  // Per-edge generic inputs (non-rectangle polygons)
  const edgeInputsBuf = ref<Record<string, string>>({})
  const edgeEditActive = ref<Record<string, boolean>>({})

  const onEdgeInputBuffer = (key: string, e: Event) => {
    const v = (e.target as HTMLInputElement)?.value ?? ''
    edgeInputsBuf.value[key] = v
  }

  const saveEdgeInput = (key: string) => {
    const raw = edgeInputsBuf.value[key] ?? ''
    const num = Number(String(raw).replace(',', '.'))
    const parts = key.split(':')
    if (parts.length !== 2) return
    const pid = parts[0]!
    const idx = Number(parts[1])
    const poly = (polygons.value as PolygonSurface[]).find((p) => p.id === pid)
    if (!poly || Number.isNaN(idx)) return
    if (!poly.edgeNotesCm) poly.edgeNotesCm = {} as any
    const n = poly.points.length
    let arr = ((poly.edgeNotesCm as any).edges as (number | null)[] | undefined) ?? undefined
    if (!arr || arr.length !== n) arr = Array(n).fill(null)
    if (Number.isFinite(num) && num > 0) {
      arr[idx] = Math.round(num)
    } else {
      arr[idx] = null
    }
    ;(poly.edgeNotesCm as any).edges = arr
    void (async () => {
      try {
        await updatePolygonEdgeNotes(poly.id, poly.edgeNotesCm ?? null, poly.edgeNotesRect ?? null, poly.edgeNotesNorm ?? null, (poly as any).areaOverrideM2 ?? null)
      } catch {}
    })()
    delete edgeInputsBuf.value[key]
    if (edgeEditActive.value[key]) edgeEditActive.value[key] = false
    drawAllPolygons()
  }

  const startEdgeEdit = (key: string) => {
    edgeEditActive.value[key] = true
  }

  // Rectangle overlays for all rectangles (excluding the selected one)
  const rectInputsBuf = ref<Record<string, string>>({})

  const onRectInputBuffer = (polyId: string, which: 'a' | 'b', e: Event) => {
    const v = (e.target as HTMLInputElement)?.value ?? ''
    rectInputsBuf.value[`${polyId}:${which}`] = v
  }

  const saveRectInput = (polyId: string, which: 'a' | 'b') => {
    const key = `${polyId}:${which}`
    const raw = rectInputsBuf.value[key] ?? ''
    const num = Number(String(raw).replace(',', '.'))
    const poly = (polygons.value as PolygonSurface[]).find((p) => p.id === polyId)
    if (!poly) return
    if (!(poly as any).edgeNotesCm) (poly as any).edgeNotesCm = {}
    if (Number.isFinite(num) && num > 0) (poly as any).edgeNotesCm[which] = Math.round(num)
    else (poly as any).edgeNotesCm[which] = null
    if (imageRef.value) {
      const res = updateEdgeNotesRectForSvc({
        poly,
        img: imageRef.value,
        meterPerPixel: meterPerPixel.value || 0,
        storedMeterPerPixel: (storedMeterPerPixel as any).value || 0,
        swapAxes: false,
      })
      const a = (poly as any)?.edgeNotesCm?.a as number | null | undefined
      const b = (poly as any)?.edgeNotesCm?.b as number | null | undefined
      ;(poly as any).areaOverrideM2 = (typeof a === 'number' && isFinite(a) && a > 0 && typeof b === 'number' && isFinite(b) && b > 0)
        ? ((a * b) / 10000)
        : null
      if (res.estimatedMeterPerPixel && res.estimatedMeterPerPixel > 0 && (!meterPerPixel.value || meterPerPixel.value <= 0)) {
        meterPerPixel.value = res.estimatedMeterPerPixel
      }
    }
    void (async () => {
      try {
        await updatePolygonEdgeNotes(polyId, (poly as any).edgeNotesCm ?? null, (poly as any).edgeNotesRect ?? null, (poly as any).edgeNotesNorm ?? null, (poly as any).areaOverrideM2 ?? null)
      } catch {}
    })()
    delete rectInputsBuf.value[key]
    drawAllPolygons()
  }

  // Selected rectangle A/B inline editor
  const showEdgeInput = ref<{ a: boolean; b: boolean }>({ a: false, b: false })
  const edgeInputA = ref<string>('')
  const edgeInputB = ref<string>('')

  const openEdgeInput = (which: 'a' | 'b') => {
    showEdgeInput.value = { a: false, b: false }
    if (which === 'a') {
      const v = selectedRectangle.value?.edgeNotesCm?.a ?? null
      edgeInputA.value = v !== null && v !== undefined ? String(v) : ''
      showEdgeInput.value.a = true
    } else {
      const v = selectedRectangle.value?.edgeNotesCm?.b ?? null
      edgeInputB.value = v !== null && v !== undefined ? String(v) : ''
      showEdgeInput.value.b = true
    }
  }

  const updateEdgeNotesRect = () => {
    const poly = selectedRectangle.value
    const img = imageRef.value
    if (!poly || !img) return
    const res = updateEdgeNotesRectForSvc({
      poly,
      img,
      meterPerPixel: meterPerPixel.value || 0,
      storedMeterPerPixel: (storedMeterPerPixel as any).value || 0,
      swapAxes: false,
    })
    const a = (poly as any)?.edgeNotesCm?.a as number | null | undefined
    const b = (poly as any)?.edgeNotesCm?.b as number | null | undefined
    ;(poly as any).areaOverrideM2 = (typeof a === 'number' && isFinite(a) && a > 0 && typeof b === 'number' && isFinite(b) && b > 0)
      ? ((a * b) / 10000)
      : null
    if (res.estimatedMeterPerPixel && res.estimatedMeterPerPixel > 0 && (!meterPerPixel.value || meterPerPixel.value <= 0)) {
      meterPerPixel.value = res.estimatedMeterPerPixel
    }
  }

  const saveEdgeNote = (which: 'a' | 'b') => {
    const poly = selectedRectangle.value
    if (!poly) { showEdgeInput.value = { a: false, b: false }; return }
    const raw = which === 'a' ? edgeInputA.value : edgeInputB.value
    const num = Number(String(raw || '').replace(',', '.'))
    if (!poly.edgeNotesCm) poly.edgeNotesCm = {}
    if (Number.isFinite(num)) poly.edgeNotesCm[which] = Math.round(num)
    else poly.edgeNotesCm[which] = null
    if (which === 'a') showEdgeInput.value.a = false
    else showEdgeInput.value.b = false
    updateEdgeNotesRect()
    drawAllPolygons()
    const a = poly.edgeNotesCm?.a as unknown as number | undefined
    const b = poly.edgeNotesCm?.b as unknown as number | undefined
    const areaOverride = (poly.points?.length === 4 && typeof a === 'number' && typeof b === 'number' && isFinite(a) && isFinite(b) && a > 0 && b > 0)
      ? (a * b) / 10000
      : null
    ;(poly as any).areaOverrideM2 = areaOverride
    void (async () => {
      try {
        await updatePolygonEdgeNotes(poly.id, poly.edgeNotesCm ?? null, poly.edgeNotesRect ?? null, poly.edgeNotesNorm ?? null, areaOverride)
      } catch {}
    })()
  }

  return {
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
  }
}
