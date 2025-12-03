import type { Point } from '@/model/Measure/ArucoWallSurface'

export const clamp01 = (v: number) => Math.max(0, Math.min(1, v))

export function normalizePoint(pt: Point, img: HTMLImageElement): Point {
  const rect = img.getBoundingClientRect()
  return { x: pt.x / rect.width, y: pt.y / rect.height }
}

export function denormalizePoint(norm: Point, img: HTMLImageElement): Point {
  const rect = img.getBoundingClientRect()
  return { x: norm.x * rect.width, y: norm.y * rect.height }
}

export function pointSegmentDistance(p: Point, a: Point, b: Point): { dist: number; t: number } {
  const ax = a.x, ay = a.y
  const bx = b.x, by = b.y
  const abx = bx - ax
  const aby = by - ay
  const apx = p.x - ax
  const apy = p.y - ay
  const ab2 = abx * abx + aby * aby
  const dot = ab2 === 0 ? 0 : (apx * abx + apy * aby) / ab2
  const t = Math.max(0, Math.min(1, dot))
  const projx = ax + t * abx
  const projy = ay + t * aby
  const dx = p.x - projx
  const dy = p.y - projy
  return { dist: Math.hypot(dx, dy), t }
}

export function isPointInPolygon(pt: Point, points: Point[]): boolean {
  let inside = false
  for (let i = 0, j = points.length - 1; i < points.length; j = i++) {
    const xi = points[i]!.x, yi = points[i]!.y
    const xj = points[j]!.x, yj = points[j]!.y
    const intersect = (yi > pt.y) !== (yj > pt.y) && pt.x < ((xj - xi) * (pt.y - yi)) / (yj - yi) + xi
    if (intersect) inside = !inside
  }
  return inside
}

export function getPolygonCenter(points: Point[]): Point {
  if (points.length === 0) return { x: 0, y: 0 }
  if (points.length === 1) return { x: points[0]!.x, y: points[0]!.y }
  if (points.length === 2) return { x: (points[0]!.x + points[1]!.x) / 2, y: (points[0]!.y + points[1]!.y) / 2 }
  let area = 0
  let cx = 0
  let cy = 0
  for (let i = 0, j = points.length - 1; i < points.length; j = i++) {
    const p1 = points[j]!
    const p2 = points[i]!
    const cross = p1.x * p2.y - p2.x * p1.y
    area += cross
    cx += (p1.x + p2.x) * cross
    cy += (p1.y + p2.y) * cross
  }
  area *= 0.5
  if (area === 0) return { x: points[0]!.x, y: points[0]!.y }
  cx /= 6 * area
  cy /= 6 * area
  return { x: cx, y: cy }
}

export function calculatePolygonArea(points: Point[], pixelSize: number, image: HTMLImageElement): number {
  const denormPoints = points.map((p) => ({ x: p.x * image.naturalWidth, y: p.y * image.naturalHeight }))
  let area = 0
  for (let i = 0, j = denormPoints.length - 1; i < denormPoints.length; j = i++) {
    const p1 = denormPoints[j]!
    const p2 = denormPoints[i]!
    area += p1.x * p2.y - p2.x * p1.y
  }
  return Math.abs(area / 2) * pixelSize * pixelSize
}
