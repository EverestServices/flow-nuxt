import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { canvasOffset } from './overlayPosition'
import { denormalizePoint, clamp01 } from './geometry'
import { deriveShape } from '@/service/Measurment/ShapeDeriveService'

export type EdgeOverlay = { key: string; x: number; y: number; value: string; hasValue?: boolean }
export type RectOverlay = { key: string; polyId: string; which: 'a' | 'b'; x: number; y: number; value: string }

export function computeAllEdgeOverlays(params: {
  polygons: PolygonSurface[]
  currentPolygon?: PolygonSurface | null
  imageEl: HTMLImageElement
  wrapperEl: HTMLElement
  canvasEl: HTMLCanvasElement
  edgeInputsBuf: Record<string, string>
}): EdgeOverlay[] {
  const { polygons, currentPolygon, imageEl, wrapperEl, canvasEl, edgeInputsBuf } = params
  const { offX, offY } = canvasOffset(wrapperEl, canvasEl)
  const result: EdgeOverlay[] = []
  const all: PolygonSurface[] = [...polygons]
  if (currentPolygon) all.push(currentPolygon)
  for (const poly of all) {
    if (!poly || poly.visible === false || !poly.closed || !poly.points || poly.points.length < 2) continue
    // Skip rectangles here; handled separately by computeRectOverlays
    if (poly.points.length === 4) continue
    const den = poly.points.map((pt) => denormalizePoint(pt, imageEl))
    const notes = ((poly as any).edgeNotesCm?.edges ?? []) as (number | null | undefined)[]
    for (let i = 0; i < den.length; i++) {
      const j = (i + 1) % den.length
      const midX = (den[i]!.x + den[j]!.x) / 2
      const midY = (den[i]!.y + den[j]!.y) / 2
      const key = `${poly.id}:${i}`
      const stored = notes?.[i]
      const hasVal = typeof stored === 'number' && isFinite(stored) && stored > 0
      const val = hasVal ? String(Math.round(stored as number)) : (edgeInputsBuf[key] ?? '')
      result.push({ key, x: offX + midX, y: offY + midY, value: val, hasValue: hasVal })
    }
  }
  return result
}

export function computeSelectedRectEdges(params: {
  poly: PolygonSurface
  imageEl: HTMLImageElement
  wrapperEl: HTMLElement
  canvasEl: HTMLCanvasElement
  rectCornerIdx: number
  swapAxes: boolean
}): { a: { x: number; y: number }; b: { x: number; y: number } } | null {
  const { poly, imageEl, wrapperEl, canvasEl } = params
  if (!poly || poly.points.length !== 4) return null
  const d = (poly as any).edgeNotesRect && (poly as any).edgeNotesRect.length === 4
    ? (poly as any).edgeNotesRect.map((pt: Point) => denormalizePoint(pt, imageEl))
    : poly.points.map((pt) => denormalizePoint(pt, imageEl))
  const [d0, d1, d2, d3] = d as [Point, Point, Point, Point]
  const mids = [
    { x: (d0.x + d1.x) / 2, y: (d0.y + d1.y) / 2, i: 0, j: 1 },
    { x: (d1.x + d2.x) / 2, y: (d1.y + d2.y) / 2, i: 1, j: 2 },
    { x: (d2.x + d3.x) / 2, y: (d2.y + d3.y) / 2, i: 2, j: 3 },
    { x: (d3.x + d0.x) / 2, y: (d3.y + d0.y) / 2, i: 3, j: 0 },
  ]
  const c = ((params.rectCornerIdx % 4) + 4) % 4
  const norm = (a: number, b: number) => (a < b ? `${a}-${b}` : `${b}-${a}`)
  let aPairs = [norm(c, (c + 1) % 4), norm((c + 2) % 4, (c + 3) % 4)]
  let bPairs = [norm((c + 1) % 4, (c + 2) % 4), norm((c + 3) % 4, c)]
  if (params.swapAxes) { const t = aPairs; aPairs = bPairs; bPairs = t }
  const { offX, offY } = canvasOffset(wrapperEl, canvasEl)
  const isPair = (m: any, pair: string) => pair === norm(m.i, m.j)
  const aCandidates = mids.filter((m) => aPairs.some((p) => isPair(m, p)))
  const bCandidates = mids.filter((m) => bPairs.some((p) => isPair(m, p)))
  if (aCandidates.length === 0 || bCandidates.length === 0) return null
  const aMid = aCandidates.reduce((best, m) => (best && best.y < m.y ? best : m), aCandidates[0])
  const bMid = bCandidates.reduce((best, m) => (best && best.x > m.x ? best : m), bCandidates[0])
  return {
    a: { x: offX + (aMid?.x ?? 0), y: offY + (aMid?.y ?? 0) },
    b: { x: offX + (bMid?.x ?? 0), y: offY + (bMid?.y ?? 0) },
  }
}

export function getRectTriplet0(poly: PolygonSurface) {
  const p0 = poly.points[0]!
  const p1 = poly.points[1]!
  const p2 = poly.points[2]!
  return { p0, p1, p2 }
}

export function updateEdgeNotesRectFor(params: {
  poly: PolygonSurface
  img: HTMLImageElement
  meterPerPixel: number
  storedMeterPerPixel: number
  swapAxes?: boolean
}): { estimatedMeterPerPixel?: number } {
  const { poly, img, meterPerPixel, storedMeterPerPixel, swapAxes = false } = params
  if (!poly || !img || poly.points.length !== 4) { (poly as any).edgeNotesRect = undefined; return {} }
  const aCm = (poly as any)?.edgeNotesCm?.a
  const bCm = (poly as any)?.edgeNotesCm?.b
  if (!Number.isFinite(aCm as number) || !Number.isFinite(bCm as number)) { (poly as any).edgeNotesRect = undefined; return {} }
  const natW = img.naturalWidth
  const natH = img.naturalHeight
  const { p0, p1, p2 } = getRectTriplet0(poly)
  const uPx = { x: (p1.x - p0.x) * natW, y: (p1.y - p0.y) * natH }
  const vPx = { x: (p2.x - p1.x) * natW, y: (p2.y - p1.y) * natH }
  const lenU = Math.hypot(uPx.x, uPx.y) || 1
  const lenV = Math.hypot(vPx.x, vPx.y) || 1
  const uHat = { x: uPx.x / lenU, y: uPx.y / lenU }
  const vHat = { x: vPx.x / lenV, y: vPx.y / lenV }
  let a_m = (aCm as number) / 100
  let b_m = (bCm as number) / 100
  if (swapAxes) { const t = a_m; a_m = b_m; b_m = t }
  const mpp = meterPerPixel || storedMeterPerPixel || 0
  let targetU_px: number
  let targetV_px: number
  if (mpp > 0) { targetU_px = a_m / mpp; targetV_px = b_m / mpp }
  else { targetU_px = lenU; const ratio = a_m > 0 ? b_m / a_m : 1; targetV_px = Math.max(1, targetU_px * ratio) }
  const du = { x: (uHat.x * targetU_px) / natW, y: (uHat.y * targetU_px) / natH }
  const dv = { x: (vHat.x * targetV_px) / natW, y: (vHat.y * targetV_px) / natH }
  const q0 = { x: clamp01(p0.x), y: clamp01(p0.y) }
  const q1 = { x: clamp01(q0.x + du.x), y: clamp01(q0.y + du.y) }
  const q2 = { x: clamp01(q1.x + dv.x), y: clamp01(q1.y + dv.y) }
  const q3 = { x: clamp01(q0.x + dv.x), y: clamp01(q0.y + dv.y) }
  ;(poly as any).edgeNotesRect = [q0, q1, q2, q3]
  const trip = getRectTriplet0(poly)
  const d = deriveShape('rectangle', Number(aCm), Number(bCm), { natW, natH, p0: trip.p0, p1: trip.p1, p2: trip.p2, swapAxes, meterPerPixel: mpp || null })
  ;(poly as any).edgeNotesNorm = d.normalized
  if (!(meterPerPixel > 0) && d.estimatedMeterPerPixel && d.estimatedMeterPerPixel > 0) {
    return { estimatedMeterPerPixel: d.estimatedMeterPerPixel }
  }
  return {}
}

export function computeRectOverlays(params: {
  polygons: PolygonSurface[]
  selectedRectId?: string | null
  imageEl: HTMLImageElement
  wrapperEl: HTMLElement
  canvasEl: HTMLCanvasElement
  rectInputsBuf: Record<string, string>
}): RectOverlay[] {
  const { polygons, selectedRectId, imageEl, wrapperEl, canvasEl, rectInputsBuf } = params
  const { offX, offY } = canvasOffset(wrapperEl, canvasEl)
  const result: RectOverlay[] = []
  for (const poly of polygons) {
    if (!poly || poly.visible === false || !poly.closed || !poly.points || poly.points.length !== 4) continue
    if (selectedRectId && poly.id === selectedRectId) continue
    const den = poly.points.map((pt) => denormalizePoint(pt, imageEl))
    const mA = { x: (den[0]!.x + den[1]!.x) / 2, y: (den[0]!.y + den[1]!.y) / 2 }
    const mB = { x: (den[1]!.x + den[2]!.x) / 2, y: (den[1]!.y + den[2]!.y) / 2 }
    const aStored = (poly as any)?.edgeNotesCm?.a as number | null | undefined
    const bStored = (poly as any)?.edgeNotesCm?.b as number | null | undefined
    const aVal = typeof aStored === 'number' && isFinite(aStored) && aStored > 0 ? String(Math.round(aStored)) : (rectInputsBuf[`${poly.id}:a`] ?? '')
    const bVal = typeof bStored === 'number' && isFinite(bStored) && bStored > 0 ? String(Math.round(bStored)) : (rectInputsBuf[`${poly.id}:b`] ?? '')
    result.push({ key: `${poly.id}:a`, polyId: poly.id, which: 'a', x: offX + mA.x, y: offY + mA.y, value: aVal })
    result.push({ key: `${poly.id}:b`, polyId: poly.id, which: 'b', x: offX + mB.x, y: offY + mB.y, value: bVal })
  }
  return result
}
