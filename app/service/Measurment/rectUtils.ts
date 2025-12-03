import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { clamp01 } from './geometry'

export function getRectTriplet(poly: PolygonSurface, cornerIdx: number) {
  const i = ((cornerIdx % 4) + 4) % 4
  const p0 = poly.points[i]!
  const p1 = poly.points[(i + 1) % 4]!
  const p2 = poly.points[(i + 2) % 4]!
  return { p0, p1, p2 }
}

export function lengthMetersBetween(a: Point, b: Point, img: HTMLImageElement | null, meterPerPixel: number): number {
  if (!img || !(meterPerPixel > 0)) return 0
  const dx = (b.x - a.x) * img.naturalWidth
  const dy = (b.y - a.y) * img.naturalHeight
  const px = Math.hypot(dx, dy)
  return px * meterPerPixel
}

export function applyRectInputsToPolygon(params: {
  poly: PolygonSurface
  widthMeters: number
  heightMeters: number
  swapAxes: boolean
  img: HTMLImageElement | null
  meterPerPixel: number
  cornerIdx: number
}): void {
  const { poly, widthMeters, heightMeters, swapAxes, img, meterPerPixel, cornerIdx } = params
  if (!poly || !img || !(meterPerPixel > 0) || poly.points.length !== 4) return
  if (!(widthMeters > 0) || !(heightMeters > 0)) return
  const natW = img.naturalWidth
  const natH = img.naturalHeight
  const { p0, p1, p2 } = getRectTriplet(poly, cornerIdx)
  let wIn = widthMeters, hIn = heightMeters
  if (swapAxes) [wIn, hIn] = [hIn, wIn]
  const uPx = { x: (p1.x - p0.x) * natW, y: (p1.y - p0.y) * natH }
  const vPx = { x: (p2.x - p1.x) * natW, y: (p2.y - p1.y) * natH }
  const uLen = Math.hypot(uPx.x, uPx.y) || 1
  const vLen = Math.hypot(vPx.x, vPx.y) || 1
  const ux = uPx.x / uLen
  const uy = uPx.y / uLen
  const vx = vPx.x / vLen
  const vy = vPx.y / vLen
  const wPx = wIn / meterPerPixel
  const hPx = hIn / meterPerPixel
  const du = { x: (ux * wPx) / natW, y: (uy * wPx) / natH }
  const dv = { x: (vx * hPx) / natW, y: (vy * hPx) / natH }
  const q0 = { x: p0.x, y: p0.y }
  const q1 = { x: clamp01(p0.x + du.x), y: clamp01(p0.y + du.y) }
  const q2 = { x: clamp01(q1.x + dv.x), y: clamp01(q1.y + dv.y) }
  const q3 = { x: clamp01(p0.x + dv.x), y: clamp01(p0.y + dv.y) }
  poly.points[0] = q0
  poly.points[1] = q1
  poly.points[2] = q2
  poly.points[3] = q3
}
