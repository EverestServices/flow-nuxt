import type { Point, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { drawCircle, drawLabel } from './CanvasDrawer'
import { getPolygonCenter, calculatePolygonArea } from './geometry'

export type DrawColors = { strokeColor: string; fillColor: string; pointColor: string }

export function drawPolygonsOnCtx(params: {
  ctx: CanvasRenderingContext2D
  img: HTMLImageElement
  polygons: PolygonSurface[]
  currentPolygon?: PolygonSurface | null
  selectedPolygonId?: string | null
  pixelSize: number
  getColors: (poly: PolygonSurface) => DrawColors
  showComputedLabels?: boolean
}) {
  const { ctx, img, polygons, currentPolygon, selectedPolygonId, pixelSize, getColors, showComputedLabels = true } = params
  const rect = img.getBoundingClientRect()
  const allPolygons = [...polygons]
  if (currentPolygon) allPolygons.push(currentPolygon)
  const natW = img.naturalWidth
  const natH = img.naturalHeight

  for (const poly of allPolygons) {
    if (poly.visible === false) continue
    const denormPoints: Point[] = poly.points.map((p) => ({ x: p.x * rect.width, y: p.y * rect.height }))
    if (denormPoints.length < 1) continue
    const { strokeColor, fillColor, pointColor } = getColors(poly)

    ctx.beginPath()
    ctx.setLineDash([])
    ctx.moveTo(denormPoints[0]!.x, denormPoints[0]!.y)
    for (let i = 1; i < denormPoints.length; i++) ctx.lineTo(denormPoints[i]!.x, denormPoints[i]!.y)
    if (poly.closed) {
      ctx.closePath()
      ctx.fillStyle = fillColor
      ctx.fill()
    }
    ctx.strokeStyle = strokeColor
    ctx.lineWidth = selectedPolygonId === poly.id ? 3.5 : 2
    ctx.stroke()

    denormPoints.forEach((p) => drawCircle(ctx, p.x, p.y, 6, pointColor))

    if (showComputedLabels && poly.closed && denormPoints.length >= 3 && pixelSize > 0) {
      for (let i = 0; i < denormPoints.length; i++) {
        const j = (i + 1) % denormPoints.length

        // Metric length: use normalized points scaled by natural image size (zoom independent)
        const p1N = poly.points[i]!
        const p2N = poly.points[j]!
        const dxN = (p2N.x - p1N.x) * natW
        const dyN = (p2N.y - p1N.y) * natH
        const pxDist = Math.sqrt(dxN * dxN + dyN * dyN)
        const length = pxDist * pixelSize

        // Screen position for label: use denormalized (on-screen) points
        const p1 = denormPoints[i]!
        const p2 = denormPoints[j]!
        const midX = (p1.x + p2.x) / 2
        const midY = (p1.y + p2.y) / 2
        drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8)
      }
      const area = calculatePolygonArea(poly.points, pixelSize, img)
      const center = getPolygonCenter(denormPoints)
      drawLabel(ctx, `${area.toFixed(2)} m²`, center.x - 18, center.y - 8)
    }
  }
}

export function drawOnMainCanvas(params: {
  canvas: HTMLCanvasElement
  img: HTMLImageElement
  polygons: PolygonSurface[]
  currentPolygon?: PolygonSurface | null
  selectedPolygonId?: string | null
  pixelSize: number
  getColors: (poly: PolygonSurface) => DrawColors
  showComputedLabels?: boolean
}) {
  const { canvas, img, polygons, currentPolygon, selectedPolygonId, pixelSize, getColors, showComputedLabels = true } = params
  const rect = img.getBoundingClientRect()
  canvas.width = rect.width
  canvas.height = rect.height
  canvas.style.width = `${rect.width}px`
  canvas.style.height = `${rect.height}px`
  canvas.style.left = img.offsetLeft + 'px'
  canvas.style.top = img.offsetTop + 'px'
  const ctx = canvas.getContext('2d')!
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  drawPolygonsOnCtx({ ctx, img, polygons, currentPolygon, selectedPolygonId, pixelSize, getColors, showComputedLabels })
}

export async function exportPng(params: {
  img: HTMLImageElement
  polygons: PolygonSurface[]
  currentPolygon?: PolygonSurface | null
  pixelSize: number
  getColors: (poly: PolygonSurface) => DrawColors
  fileName: string
}) {
  const { img, polygons, currentPolygon, pixelSize, getColors, fileName } = params
  const natW = img.naturalWidth
  const natH = img.naturalHeight
  const canvas = document.createElement('canvas')
  canvas.width = natW
  canvas.height = natH
  const ctx = canvas.getContext('2d')
  if (!ctx) return
  ctx.drawImage(img, 0, 0, natW, natH)

  // draw with natural rect
  const all = [...polygons]
  if (currentPolygon) all.push(currentPolygon)
  for (const poly of all) {
    if (poly.visible === false) continue
    const denormPoints: Point[] = poly.points.map((p) => ({ x: p.x * natW, y: p.y * natH }))
    if (denormPoints.length < 1) continue
    const { strokeColor, fillColor, pointColor } = getColors(poly)

    ctx.beginPath()
    ctx.setLineDash([])
    ctx.moveTo(denormPoints[0]!.x, denormPoints[0]!.y)
    for (let i = 1; i < denormPoints.length; i++) ctx.lineTo(denormPoints[i]!.x, denormPoints[i]!.y)
    if (poly.closed) {
      ctx.closePath()
      ctx.fillStyle = fillColor
      ctx.fill()
    }
    ctx.strokeStyle = strokeColor
    ctx.lineWidth = 2
    ctx.stroke()

    denormPoints.forEach((p) => drawCircle(ctx, p.x, p.y, 6, pointColor))

    if (poly.closed && denormPoints.length >= 3 && pixelSize > 0) {
      for (let i = 0; i < denormPoints.length; i++) {
        const j = (i + 1) % denormPoints.length
        const p1 = denormPoints[i]!
        const p2 = denormPoints[j]!
        const dx = p2.x - p1.x
        const dy = p2.y - p1.y
        const pxDist = Math.sqrt(dx * dx + dy * dy)
        const length = pxDist * pixelSize
        const midX = (p1.x + p2.x) / 2
        const midY = (p1.y + p2.y) / 2
        drawLabel(ctx, `${length.toFixed(2)} m`, midX - 22, midY - 8)
      }
      const area = calculatePolygonArea(poly.points, pixelSize, img)
      const center = getPolygonCenter(denormPoints)
      drawLabel(ctx, `${area.toFixed(2)} m²`, center.x - 18, center.y - 8)
    }
  }

  return new Promise<void>((resolve) => {
    canvas.toBlob((blob) => {
      if (!blob) return resolve()
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.download = `${fileName}.png`
      a.href = url
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
      resolve()
    }, 'image/png')
  })
}
