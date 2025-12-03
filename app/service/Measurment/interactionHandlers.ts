import type { Ref } from 'vue'
import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { SurfaceType } from '@/model/Measure/ArucoWallSurface'
import { clamp01, normalizePoint as gNormalizePoint, denormalizePoint as gDenormalizePoint, isPointInPolygon } from './geometry'

export type DragSnapshot = {
  start: Point
  items: Array<{ polyId: string; index: number; start: Point }>
}

export function computePointByLengthStandalone(
  img: HTMLImageElement | null,
  meterPerPixel: number,
  storedMeterPerPixel: number,
  last: Point,
  dirToMouse: Point,
  lengthMeters: number,
): Point | null {
  const mpp = meterPerPixel || storedMeterPerPixel || 0
  if (!img || !(mpp > 0)) return null
  const natW = img.naturalWidth
  const natH = img.naturalHeight
  const dx = dirToMouse.x * natW
  const dy = dirToMouse.y * natH
  const mag = Math.hypot(dx, dy)
  if (!(mag > 0)) return null
  const scale = (lengthMeters / mpp) / mag
  const nx = clamp01(last.x + dirToMouse.x * scale)
  const ny = clamp01(last.y + dirToMouse.y * scale)
  return { x: nx, y: ny }
}

export function createInteractionHandlers(deps: {
  canvasRef: Ref<HTMLCanvasElement | null>
  imageRef: Ref<HTMLImageElement | null>
  // modes and state
  editingMode: Ref<boolean>
  editPointsMode: Ref<boolean>
  calibrationMode: Ref<boolean>
  manualActive: Ref<boolean>

  referenceSet: Ref<boolean>
  allowRefOverride: Ref<boolean>
  calibrationStart: Ref<Point | null>
  calibrationEnd: Ref<Point | null>

  polygons: Ref<PolygonSurface[]>
  currentPolygon: Ref<PolygonSurface | null>
  selectedPolygonId: Ref<string | null>
  selectedPoints: Ref<Set<string>>

  draggingPoint: Ref<{ polygonId?: string; index: number; type: 'polygon' | 'calibration' } | null>
  dragSnapshot: Ref<DragSnapshot | null>
  mousePos: Ref<Point | null>

  meterPerPixel: Ref<number>
  storedMeterPerPixel: Ref<number>

  edgeInputBuffer: Ref<string>

  // helpers
  pushHistory: () => void
  drawAllPolygons: () => void
  clearSelection: () => void
  toggleSelection: (polyId: string, idx: number) => void
  selectOnly: (polyId: string, idx: number) => void
  isNearPoint: (p1: Point, p2: Point) => boolean
  findEdgeUnderPoint: (pt: Point) => { polyId: string; index: number; a: Point; b: Point } | null
}) {
  const {
    canvasRef,
    imageRef,
    editingMode,
    editPointsMode,
    calibrationMode,
    manualActive,

    referenceSet,
    allowRefOverride,

    polygons,
    currentPolygon,
    selectedPolygonId,
    selectedPoints,

    draggingPoint,
    dragSnapshot,
    mousePos,

    meterPerPixel,
    storedMeterPerPixel,

    edgeInputBuffer,

    pushHistory,
    drawAllPolygons,
    clearSelection,
    toggleSelection,
    selectOnly,
    isNearPoint,
    findEdgeUnderPoint,
  } = deps

  const getCanvasCoords = (event: MouseEvent): Point => {
    const canvas = canvasRef.value
    const rect = canvas?.getBoundingClientRect()
    if (!rect) return { x: 0, y: 0 }
    return {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top,
    }
  }

  const getCanvasCoordsFromEvent = (event: MouseEvent | TouchEvent): Point => {
    const canvas = canvasRef.value
    const rect = canvas?.getBoundingClientRect()
    if (!rect) return { x: 0, y: 0 }
    let clientX = 0
    let clientY = 0

    if ('touches' in event) {
      if (event.touches.length > 0) {
        clientX = event.touches[0]!.clientX
        clientY = event.touches[0]!.clientY
        event.preventDefault()
      }
    } else {
      clientX = (event as MouseEvent).clientX
      clientY = (event as MouseEvent).clientY
    }

    return { x: clientX - rect.left, y: clientY - rect.top }
  }

  const norm = (point: Point): Point => {
    const img = imageRef.value
    if (!img) return { x: 0, y: 0 }
    return gNormalizePoint(point, img)
  }

  const denorm = (p: Point): Point => {
    const img = imageRef.value
    if (!img) return { x: 0, y: 0 }
    return gDenormalizePoint(p, img)
  }

  const computePointByLength = (last: Point, dirToMouse: Point, lengthMeters: number): Point | null => {
    const img = imageRef.value
    const mpp = meterPerPixel.value || storedMeterPerPixel.value || 0
    if (!img || !(mpp > 0)) return null
    const natW = img.naturalWidth
    const natH = img.naturalHeight
    const dx = dirToMouse.x * natW
    const dy = dirToMouse.y * natH
    const mag = Math.hypot(dx, dy)
    if (!(mag > 0)) return null
    const scale = (lengthMeters / mpp) / mag
    const nx = clamp01(last.x + dirToMouse.x * scale)
    const ny = clamp01(last.y + dirToMouse.y * scale)
    return { x: nx, y: ny }
  }

  const handleCanvasClick = (event: MouseEvent) => {
    let clickPoint = norm(getCanvasCoords(event))

    // 1) Calibration mode: allow cloning an existing polygon edge as reference
    if (calibrationMode.value && !manualActive.value) {
      if (referenceSet.value && !allowRefOverride.value) return
      const hit = findEdgeUnderPoint(clickPoint)
      if (hit) {
        deps.calibrationStart.value = { x: hit.a.x, y: hit.a.y }
        deps.calibrationEnd.value = { x: hit.b.x, y: hit.b.y }
        drawAllPolygons()
        return
      }
      if (!deps.calibrationStart.value) {
        deps.calibrationStart.value = clickPoint
        drawAllPolygons()
        return
      }
      if (!deps.calibrationEnd.value) {
        deps.calibrationEnd.value = clickPoint
        drawAllPolygons()
        return
      }
      return
    }

    // 2) Edit points mode: pick topmost closed polygon under cursor
    if (editPointsMode.value) {
      const list = polygons.value
      let target: PolygonSurface | null = null
      if (selectedPolygonId.value) target = list.find((p) => p.id === selectedPolygonId.value) ?? null
      if (!target) {
        for (let idx = list.length - 1; idx >= 0; idx--) {
          const p = list[idx]
          if (!p) continue
          if (p.visible === false || !p.closed || p.points.length < 3) continue
          if (isPointInPolygon(clickPoint, p.points)) { target = p; break }
        }
      }
      if (target) {
        selectedPolygonId.value = target.id
        drawAllPolygons()
      }
      return
    }

    // 3) View mode: select polygon by click (topmost)
    if (!editingMode.value) {
      for (let idx = polygons.value.length - 1; idx >= 0; idx--) {
        const p = polygons.value[idx]
        if (!p) continue
        if (p.visible === false || p.points.length < 3) continue
        if (isPointInPolygon(clickPoint, p.points)) {
          selectedPolygonId.value = p.id
          drawAllPolygons()
          return
        }
      }
      selectedPolygonId.value = null
      drawAllPolygons()
      return
    }

    // 4) Draw mode: add points / close polygon
    pushHistory()
    if (!currentPolygon.value || currentPolygon.value.closed) {
      currentPolygon.value = {
        id: crypto.randomUUID(),
        points: [],
        closed: false,
        type: SurfaceType.FACADE,
        visible: true,
      } as PolygonSurface
    }
    const existingPoints = currentPolygon.value.points
    if (existingPoints.length > 0) {
      const buf = edgeInputBuffer.value.trim()
      const num = Number((buf || '').replace(',', '.'))
      if (Number.isFinite(num) && num > 0) {
        const lastNorm = existingPoints[existingPoints.length - 1]!
        const dir = { x: clickPoint.x - lastNorm.x, y: clickPoint.y - lastNorm.y }
        const target = computePointByLength(lastNorm, dir, num)
        if (target) {
          clickPoint = target
          edgeInputBuffer.value = ''
        }
      }
    }
    if (existingPoints.length >= 3 && isNearPoint(clickPoint, existingPoints[0]!)) {
      currentPolygon.value.closed = true
      polygons.value.push(currentPolygon.value as PolygonSurface)
      currentPolygon.value = null
    } else if (existingPoints.length >= 4) {
      existingPoints.push(clickPoint)
      currentPolygon.value.closed = true
      polygons.value.push(currentPolygon.value as PolygonSurface)
      currentPolygon.value = null
    } else {
      existingPoints.push(clickPoint)
    }
    // Force setter to run (when polygons is a computed) so store persists
    try { (polygons as any).value = [...(polygons as any).value] } catch {}
    drawAllPolygons()
  }

  // We keep the logic identical to component, but set calibration points directly
  const internalSetCalibration = (a: Point, b: Point) => {
    // The caller holds refs; emulate setting via closures
    // This function will be replaced at return wiring where we have direct access
  }

  const handleMouseDown = (event: MouseEvent | TouchEvent) => {
    if (!(editPointsMode.value || calibrationMode.value)) return
    const click = norm(getCanvasCoordsFromEvent(event))

    // Calibration points drag handles
    if (calibrationMode.value) {
      if (deps.calibrationStart.value && isNearPoint(click, deps.calibrationStart.value)) {
        draggingPoint.value = { type: 'calibration', index: 0 }
        return
      }
      if (deps.calibrationEnd.value && isNearPoint(click, deps.calibrationEnd.value)) {
        draggingPoint.value = { type: 'calibration', index: 1 }
        return
      }
    }

    // Point edit selection and drag prep
    for (const polygon of polygons.value) {
      for (let i = 0; i < polygon.points.length; i++) {
        const pi = polygon.points[i]
        if (pi && isNearPoint(click, pi)) {
          if (event instanceof MouseEvent && event.shiftKey) toggleSelection(polygon.id, i)
          else selectOnly(polygon.id, i)

          pushHistory()
          draggingPoint.value = { polygonId: polygon.id, index: i, type: 'polygon' }
          const items = Array.from(selectedPoints.value)
            .map((k) => {
              const parts = k.split(':')
              if (parts.length !== 2) return null
              const polyId = parts[0] as string
              const idx = Number(parts[1])
              const p = polygons.value.find((pp) => pp.id === polyId)
              const pt = p?.points?.[idx]
              if (!p || !pt) return null
              return { polyId, index: idx, start: { x: pt.x, y: pt.y } }
            })
            .filter((x): x is { polyId: string; index: number; start: Point } => Boolean(x))
          dragSnapshot.value = { start: click, items }
          drawAllPolygons()
          return
        }
      }
    }

    if (!(event instanceof MouseEvent && event.shiftKey)) {
      clearSelection()
      drawAllPolygons()
    }
  }

  const handleMouseMove = (event: MouseEvent) => {
    mousePos.value = norm(getCanvasCoords(event))
    if (!draggingPoint.value) {
      drawAllPolygons()
      return
    }

    if (draggingPoint.value.type === 'polygon') {
      if (dragSnapshot.value && mousePos.value) {
        const dx = mousePos.value.x - dragSnapshot.value.start.x
        const dy = mousePos.value.y - dragSnapshot.value.start.y
        for (const it of dragSnapshot.value.items) {
          const poly = polygons.value.find((p) => p.id === it.polyId)
          if (!poly) continue
          const nx = clamp01(it.start.x + dx)
          const ny = clamp01(it.start.y + dy)
          poly.points[it.index] = { x: nx, y: ny }
        }
      } else {
        const { polygonId, index } = draggingPoint.value
        const polygon = polygons.value.find((p) => p.id === polygonId)
        if (polygon && mousePos.value) polygon.points[index] = mousePos.value
      }
    } else if (draggingPoint.value.type === 'calibration') {
      if (mousePos.value) {
        if (draggingPoint.value.index === 0) deps.calibrationStart.value = mousePos.value
        else if (draggingPoint.value.index === 1) deps.calibrationEnd.value = mousePos.value
      }
    }

    drawAllPolygons()
  }

  const handleMouseUp = () => {
    draggingPoint.value = null
    dragSnapshot.value = null
    // Commit polygon changes on drag end so persistence updates
    try { (polygons as any).value = [...(polygons as any).value] } catch {}
  }

  const handleCanvasTouch = (event: TouchEvent) => {
    if (!editPointsMode.value) return
    const touch = event.touches && event.touches.length > 0 ? event.touches[0] : null
    if (!touch) return
    const canvas = canvasRef.value
    const rect = canvas?.getBoundingClientRect()
    if (!rect) return
    const touchPoint: Point = norm({ x: touch.clientX - rect.left, y: touch.clientY - rect.top })

    if (draggingPoint.value?.type === 'polygon') {
      event.preventDefault()
      const { polygonId, index } = draggingPoint.value
      const polygon = polygons.value.find((p) => p.id === polygonId)
      if (polygon) {
        polygon.points[index] = touchPoint
        draggingPoint.value = null
        // Commit and redraw after touch move apply
        try { (polygons as any).value = [...(polygons as any).value] } catch {}
        drawAllPolygons()
      }
      return
    }

    for (const polygon of polygons.value) {
      for (let i = 0; i < polygon.points.length; i++) {
        const p = polygon.points[i]
        if (p && isNearPoint(touchPoint, p)) {
          event.preventDefault()
          draggingPoint.value = { polygonId: polygon.id, index: i, type: 'polygon' }
          drawAllPolygons()
          return
        }
      }
    }
  }

  // Return handlers and helpers needed by the component
  return {
    getCanvasCoords,
    getCanvasCoordsFromEvent,
    computePointByLength,
    handleCanvasClick,
    handleMouseDown,
    handleMouseMove,
    handleMouseUp,
    handleCanvasTouch,
    // expose for internal use if needed
    normalizePoint: norm,
    denormalizePoint: denorm,
  }
}
