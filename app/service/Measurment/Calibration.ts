import type { Point } from '@/model/Measure/ArucoWallSurface'

export function recalcMeterPerPixelFromReference(meta: {
  referenceStart?: Point | null
  referenceEnd?: Point | null
  referenceLengthCm?: number | null
} | null | undefined, img: HTMLImageElement | null): number | null {
  const lengthCm = meta?.referenceLengthCm ?? 0
  if (!meta || !img || !meta.referenceStart || !meta.referenceEnd || !(lengthCm > 0)) return null
  const dx = (meta.referenceEnd.x - meta.referenceStart.x) * img.naturalWidth
  const dy = (meta.referenceEnd.y - meta.referenceStart.y) * img.naturalHeight
  const pixelDist = Math.sqrt(dx * dx + dy * dy)
  if (!(pixelDist > 0)) return null
  return (lengthCm / 100) / pixelDist
}

export function computeCalibrationMidOverlay(
  calibrationStart: Point | null,
  endNorm: Point | null,
  img: HTMLImageElement | null,
  canvas: HTMLCanvasElement | null,
  wrapper: HTMLElement | null,
): { x: number; y: number } | null {
  if (!calibrationStart || !endNorm || !img || !canvas) return null
  const p1 = { x: calibrationStart.x * img.getBoundingClientRect().width, y: calibrationStart.y * img.getBoundingClientRect().height }
  const p2 = { x: endNorm.x * img.getBoundingClientRect().width, y: endNorm.y * img.getBoundingClientRect().height }
  const mid = { x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2 }
  const canvasRect = canvas.getBoundingClientRect()
  const wrapperRect = wrapper?.getBoundingClientRect()
  if (!wrapperRect) return { x: mid.x, y: mid.y }
  return { x: canvasRect.left - wrapperRect.left + mid.x, y: canvasRect.top - wrapperRect.top + mid.y }
}
