import type { Ref } from 'vue'
import type { PolygonSurface, Point } from '@/model/Measure/ArucoWallSurface'

export type Mode = 'view' | 'draw' | 'edit' | 'calibrate'

export function createModeManager(params: {
  manualActive: Ref<boolean>
  calibrationStart: Ref<Point | null>
  calibrationEnd: Ref<Point | null>
  allowRefOverride: Ref<boolean>
  selectedPolygonId: Ref<string | null>
  polygons: Ref<PolygonSurface[]>
  currentPolygon: Ref<PolygonSurface | null>
  editingMode: Ref<boolean>
  editPointsMode: Ref<boolean>
  calibrationMode: Ref<boolean>
  recalcMeterPerPixelFromReference: () => boolean
  calculateOptimalZoom: () => void
  drawAllPolygons: () => void
  refreshRectInputs: () => void
  clearSelection: () => void
}) {
  const {
    manualActive,
    calibrationStart,
    calibrationEnd,
    allowRefOverride,
    selectedPolygonId,
    polygons,
    currentPolygon,
    editingMode,
    editPointsMode,
    calibrationMode,
    recalcMeterPerPixelFromReference,
    calculateOptimalZoom,
    drawAllPolygons,
    refreshRectInputs,
    clearSelection,
  } = params

  const setMode = (mode: Mode) => {
    if (manualActive.value && mode === 'calibrate') return
    // Finish/cleanup current operations
    // Stop dragging current point
    // End unfinished drawing
    if (currentPolygon.value && !currentPolygon.value.closed) currentPolygon.value = null
    // Reset calibration draft line if leaving calibrate
    if (mode !== 'calibrate') {
      calibrationStart.value = null
      calibrationEnd.value = null
      allowRefOverride.value = false
    }
    if (mode !== 'edit') clearSelection()

    // Exclusive modes
    editingMode.value = mode === 'draw'
    editPointsMode.value = mode === 'edit'
    calibrationMode.value = mode === 'calibrate'

    // Apply saved reference-derived meterPerPixel if available
    recalcMeterPerPixelFromReference()

    if (mode === 'edit') {
      if (!selectedPolygonId.value) {
        const list = polygons.value as PolygonSurface[]
        for (let i = list.length - 1; i >= 0; i--) {
          const p = list[i]
          if (p && p.closed && p.points?.length >= 3) { selectedPolygonId.value = p.id; break }
        }
      }
      refreshRectInputs()
    }

    // Recalculate optimal zoom for the new mode and redraw
    calculateOptimalZoom()
    drawAllPolygons()
  }

  const toggleCalibration = () => {
    if (manualActive.value) return
    if (calibrationMode.value) setMode('view')
    else setMode('calibrate')
  }

  const togglePolygonEditing = () => {
    if (editingMode.value) setMode('view')
    else setMode('draw')
  }

  return { setMode, toggleCalibration, togglePolygonEditing }
}
