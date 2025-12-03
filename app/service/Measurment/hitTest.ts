import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { pointSegmentDistance } from './geometry'

export function isNearPoint(p1: Point, p2: Point, thresh = 0.02): boolean {
  const dx = p1.x - p2.x
  const dy = p1.y - p2.y
  return Math.sqrt(dx * dx + dy * dy) < thresh
}

export function findEdgeUnderPoint(
  pt: Point,
  polygons: PolygonSurface[],
): { polyId: string; index: number; a: Point; b: Point } | null {
  let best: { polyId: string; index: number; a: Point; b: Point; dist: number } | null = null
  for (let pIdx = polygons.length - 1; pIdx >= 0; pIdx--) {
    const poly = polygons[pIdx]
    if (!poly || poly.visible === false || !poly.closed || poly.points.length < 2) continue
    const n = poly.points.length
    let localBest: { polyId: string; index: number; a: Point; b: Point; dist: number } | null = null
    for (let i = 0; i < n; i++) {
      const j = (i + 1) % n
      const a = poly.points[i]!
      const b = poly.points[j]!
      const { dist } = pointSegmentDistance(pt, a, b)
      if (!localBest || dist < localBest.dist) localBest = { polyId: poly.id, index: i, a, b, dist }
    }
    if (localBest && localBest.dist < 0.02) {
      return { polyId: localBest.polyId, index: localBest.index, a: localBest.a, b: localBest.b }
    }
    if (!best || (localBest && localBest.dist < best.dist)) best = localBest
  }
  if (best && best.dist < 0.02) {
    return { polyId: best.polyId, index: best.index, a: best.a, b: best.b }
  }
  return null
}
