import type { Point } from '@/model/Measure/ArucoWallSurface'

export type ShapeKind = 'rectangle' | 'triangle' | 'pentagon'

export type DeriveOptions = {
  natW?: number
  natH?: number
  p0?: Point
  p1?: Point
  p2?: Point
  swapAxes?: boolean
  meterPerPixel?: number | null
}

export type DeriveResult = {
  imageAligned: Point[] | null
  normalized: Point[]
  estimatedMeterPerPixel: number | null
}

const clamp01 = (v: number) => Math.max(0, Math.min(1, v))

const unitRect = (w: number, h: number) => {
  const m = 0.05
  let ww = w
  let hh = h
  const s = 0.9 / Math.max(ww, hh)
  ww *= s
  hh *= s
  const x0 = m
  const yb = 1 - m
  const x1 = x0 + ww
  const yt = yb - hh
  return [
    { x: x0, y: yt },
    { x: x1, y: yt },
    { x: x1, y: yb },
    { x: x0, y: yb },
  ] as Point[]
}

const unitTriangle = (w: number, h: number) => {
  const m = 0.05
  let ww = w
  let hh = h
  const s = 0.9 / Math.max(ww, hh)
  ww *= s
  hh *= s
  const x0 = m
  const yb = 1 - m
  const x1 = x0 + ww
  const xc = x0 + ww / 2
  const yt = yb - hh
  return [
    { x: x0, y: yb },
    { x: x1, y: yb },
    { x: xc, y: yt },
  ] as Point[]
}

const unitPentagon = (w: number, h: number) => {
  const m = 0.05
  let ww = w
  let hh = h
  const s = 0.9 / Math.max(ww, hh)
  ww *= s
  hh *= s
  const x0 = m
  const yb = 1 - m
  const x1 = x0 + ww
  const xc = x0 + ww / 2
  const yt = yb - hh
  const yq = yb - hh * 0.4
  return [
    { x: x0 + ww * 0.1, y: yb },
    { x: x1 - ww * 0.1, y: yb },
    { x: x1, y: yq },
    { x: xc, y: yt },
    { x: x0, y: yq },
  ] as Point[]
}

const uvFromTriplet = (p0: Point, p1: Point, p2: Point, natW: number, natH: number) => {
  const uPx = { x: (p1.x - p0.x) * natW, y: (p1.y - p0.y) * natH }
  const vPx = { x: (p2.x - p1.x) * natW, y: (p2.y - p1.y) * natH }
  const lenU = Math.hypot(uPx.x, uPx.y)
  const lenV = Math.hypot(vPx.x, vPx.y)
  const uHat = lenU > 0 ? { x: uPx.x / lenU, y: uPx.y / lenU } : { x: 1, y: 0 }
  const vHat = lenV > 0 ? { x: vPx.x / lenV, y: vPx.y / lenV } : { x: 0, y: 1 }
  return { uPx, vPx, lenU, lenV, uHat, vHat }
}

const deriveRectImageAligned = (aCm: number | null, bCm: number | null, o: Required<Pick<DeriveOptions,'natW'|'natH'|'p0'|'p1'|'p2'>> & { swapAxes?: boolean, meterPerPixel?: number | null }) => {
  const { uPx, vPx, lenU, lenV, uHat, vHat } = uvFromTriplet(o.p0, o.p1, o.p2, o.natW, o.natH)
  let a = aCm ? aCm / 100 : null
  let b = bCm ? bCm / 100 : null
  if (o.swapAxes) { const t = a; a = b; b = t }
  let mpp = o.meterPerPixel && o.meterPerPixel > 0 ? o.meterPerPixel : null
  const mppA = a && lenU > 0 ? a / lenU : null
  const mppB = b && lenV > 0 ? b / lenV : null
  if (!mpp) {
    const cands: number[] = []
    const weights: number[] = []
    if (mppA) { cands.push(mppA); weights.push(lenU) }
    if (mppB) { cands.push(mppB); weights.push(lenV) }
    if (cands.length === 1) mpp = cands[0]!
    else if (cands.length === 2) {
      const num = cands[0]! * weights[0]! + cands[1]! * weights[1]!
      const den = weights[0]! + weights[1]!
      mpp = den > 0 ? (num / den) : (cands[0]! + cands[1]!) / 2
    }
  }
  if (mpp && mpp > 0) {
    const minMpp = 1e-4, maxMpp = 1e-1
    if (mpp < minMpp) mpp = minMpp
    if (mpp > maxMpp) mpp = maxMpp
    mpp = Math.round(mpp * 1e6) / 1e6
  }
  let targetU = lenU
  let targetV = lenV
  if (mpp && mpp > 0) {
    if (a) targetU = a / mpp
    if (b) targetV = b / mpp
  } else {
    if (a && b && a > 0) targetV = targetU * (b / a)
  }
  const du = { x: (uHat.x * targetU) / o.natW, y: (uHat.y * targetU) / o.natH }
  const dv = { x: (vHat.x * targetV) / o.natW, y: (vHat.y * targetV) / o.natH }
  const q0 = { x: clamp01(o.p0.x), y: clamp01(o.p0.y) }
  const q1 = { x: clamp01(q0.x + du.x), y: clamp01(q0.y + du.y) }
  const q2 = { x: clamp01(q1.x + dv.x), y: clamp01(q1.y + dv.y) }
  const q3 = { x: clamp01(q0.x + dv.x), y: clamp01(q0.y + dv.y) }
  return { pts: [q0, q1, q2, q3] as Point[], estimatedMpp: mpp }
}

export const deriveShape = (kind: ShapeKind, aCm: number | null, bCm: number | null, opts: DeriveOptions): DeriveResult => {
  const a = aCm ? aCm / 100 : null
  const b = bCm ? bCm / 100 : null
  let normalized: Point[]
  if (kind === 'rectangle') normalized = unitRect(a && b ? 1 : 1, a && b ? (b as number) / (a as number || 1) : 1)
  else if (kind === 'triangle') normalized = unitTriangle(a && b ? 1 : 1, a && b ? (b as number) / (a as number || 1) : 1)
  else normalized = unitPentagon(a && b ? 1 : 1, a && b ? (b as number) / (a as number || 1) : 1)
  let imageAligned: Point[] | null = null
  let estimatedMeterPerPixel: number | null = null
  if (opts.natW && opts.natH && opts.p0 && opts.p1 && opts.p2 && kind === 'rectangle') {
    const r = deriveRectImageAligned(aCm, bCm, { natW: opts.natW, natH: opts.natH, p0: opts.p0, p1: opts.p1, p2: opts.p2, swapAxes: opts.swapAxes, meterPerPixel: opts.meterPerPixel ?? null })
    imageAligned = r.pts
    estimatedMeterPerPixel = r.estimatedMpp
  }
  return { imageAligned, normalized, estimatedMeterPerPixel }
}

export const runShapeDeriveTests = () => {
  const t1 = deriveShape('rectangle', 120, 80, { natW: 1000, natH: 800, p0: { x: 0.2, y: 0.2 }, p1: { x: 0.6, y: 0.2 }, p2: { x: 0.6, y: 0.6 }, swapAxes: false, meterPerPixel: null })
  const t2 = deriveShape('triangle', 150, 100, {})
  const t3 = deriveShape('pentagon', 200, 120, {})
  return [t1.normalized.length === 4, t2.normalized.length === 3, t3.normalized.length === 5, !!t1.imageAligned]
}
