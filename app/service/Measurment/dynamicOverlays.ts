import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { denormalizePoint } from '@/service/Measurment/geometry'
import { drawCircle, drawLabel } from '@/service/Measurment/CanvasDrawer'
import { computePointByLengthStandalone } from '@/service/Measurment/interactionHandlers'

export type DrawDynamicOverlaysParams = {
  imageEl: HTMLImageElement | null
  currentPolygon: PolygonSurface | null
  mousePos: Point | null
  edgeInputBuffer: string
  meterPerPixel: number
  storedMeterPerPixel: number
  calibrationMode: boolean
  calibrationStart: Point | null
  calibrationEnd: Point | null
  manualActive: boolean
  firstImageMeta: any | null
  highlightRef: boolean
}

export function drawDynamicOverlays(
  ctx: CanvasRenderingContext2D,
  params: DrawDynamicOverlaysParams,
) {
  const {
    imageEl,
    currentPolygon,
    mousePos,
    edgeInputBuffer,
    meterPerPixel,
    storedMeterPerPixel,
    calibrationMode,
    calibrationStart,
    calibrationEnd,
    manualActive,
    firstImageMeta,
    highlightRef,
  } = params

  const img = imageEl
  if (!img) return

  // Manual drawing/provisional preview
  const pixelSize = meterPerPixel || storedMeterPerPixel || 0
  if (currentPolygon && !currentPolygon.closed && pixelSize > 0) {
    const natW = img.naturalWidth
    const natH = img.naturalHeight
    const ptsN = currentPolygon.points
    const n = ptsN.length
    const ptsD = ptsN.map((p) => denormalizePoint(p, img))

    // Labels for existing segments (hidden in manual mode)
    if (!manualActive) {
      for (let i = 0; i < n - 1; i++) {
        const aN = ptsN[i]!
        const bN = ptsN[i + 1]!
        const aD = ptsD[i]!
        const bD = ptsD[i + 1]!
        const dxN = (bN.x - aN.x) * natW
        const dyN = (bN.y - aN.y) * natH
        const lengthM = Math.sqrt(dxN * dxN + dyN * dyN) * pixelSize
        const midX = (aD.x + bD.x) / 2
        const midY = (aD.y + bD.y) / 2
        drawLabel(ctx, `${lengthM.toFixed(2)} m`, midX - 22, midY - 8)
      }
    }

    // Provisional segment to cursor or typed length
    if (n > 0) {
      const lastN = ptsN[n - 1]!
      let provisional = mousePos ?? null
      const buf = edgeInputBuffer.trim()
      const num = Number((buf || '').replace(',', '.'))
      if (Number.isFinite(num) && num > 0) {
        const dir = provisional
          ? { x: provisional.x - lastN.x, y: provisional.y - lastN.y }
          : { x: 0, y: 0 }
        const t = computePointByLengthStandalone(
          img,
          meterPerPixel || 0,
          storedMeterPerPixel || 0,
          lastN,
          dir,
          num,
        )
        if (t) provisional = t
      }
      if (provisional) {
        const lastD = denormalizePoint(lastN, img)
        const curD = denormalizePoint(provisional, img)
        ctx.save()
        ctx.setLineDash([6, 6])
        ctx.beginPath()
        ctx.moveTo(lastD.x, lastD.y)
        ctx.lineTo(curD.x, curD.y)
        ctx.strokeStyle = '#94a3b8'
        ctx.lineWidth = 2
        ctx.stroke()
        ctx.restore()
        if (!manualActive) {
          const dxN = (provisional.x - lastN.x) * natW
          const dyN = (provisional.y - lastN.y) * natH
          const lengthM = Math.sqrt(dxN * dxN + dyN * dyN) * pixelSize
          const midX = (lastD.x + curD.x) / 2
          const midY = (lastD.y + curD.y) / 2
          drawLabel(ctx, `${lengthM.toFixed(2)} m`, midX - 22, midY - 8)
        }
      }
    }
  }

  // Calibration preview
  if (calibrationMode && !manualActive && calibrationStart) {
    const p1 = denormalizePoint(calibrationStart, img)
    const endNorm = (calibrationEnd ?? mousePos) as Point | null
    const p2 = endNorm ? denormalizePoint(endNorm, img) : p1
    ctx.strokeStyle = 'red'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(p1.x, p1.y)
    ctx.lineTo(p2.x, p2.y)
    ctx.stroke()
    drawCircle(ctx, p1.x, p1.y, 5)
    drawCircle(ctx, p2.x, p2.y, 5)
    const midX = (p1.x + p2.x) / 2
    const midY = (p1.y + p2.y) / 2
    drawLabel(ctx, 'Kalibráció', midX - 20, midY - 8)
  }

  // Saved reference line (always visible when present)
  const ref = firstImageMeta
  if (!manualActive && ref?.referenceStart && ref?.referenceEnd) {
    const p1 = denormalizePoint(ref.referenceStart as Point, img)
    const p2 = denormalizePoint(ref.referenceEnd as Point, img)
    ctx.strokeStyle = '#22c55e'
    ctx.lineWidth = highlightRef ? 4 : 3
    ctx.setLineDash([10, 6])
    ctx.beginPath()
    ctx.moveTo(p1.x, p1.y)
    ctx.lineTo(p2.x, p2.y)
    ctx.stroke()
    ctx.setLineDash([])
    drawCircle(ctx, p1.x, p1.y, 6, '#22c55e')
    drawCircle(ctx, p2.x, p2.y, 6, '#22c55e')
    const midX = (p1.x + p2.x) / 2
    const midY = (p1.y + p2.y) / 2
    const dx = (ref.referenceEnd.x - ref.referenceStart.x) * img.naturalWidth
    const dy = (ref.referenceEnd.y - ref.referenceStart.y) * img.naturalHeight
    const pixelDist = Math.sqrt(dx * dx + dy * dy)
    const mpp = meterPerPixel || ref?.meterPerPixel || 0
    const lengthMeters = pixelDist * mpp
    const computedCm = lengthMeters * 100
    const lengthCm = (ref?.referenceLengthCm ?? 0) > 0 ? (ref!.referenceLengthCm as number) : computedCm
    drawLabel(ctx, `Mentett referencia • ${lengthCm.toFixed(0)} cm`, midX - 60, midY - 8)
  }
}
