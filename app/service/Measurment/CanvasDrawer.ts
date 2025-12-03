export function drawCircle(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  radius = 7,
  strokeColor = '#f59e0b',
) {
  ctx.beginPath()
  ctx.arc(x, y, radius, 0, 2 * Math.PI)
  ctx.fillStyle = '#ffffff'
  ctx.fill()
  ctx.lineWidth = 3
  ctx.strokeStyle = strokeColor
  ctx.stroke()
}

function roundRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  r: number,
) {
  const min = Math.min(w, h) / 2
  const radius = Math.min(r, min)
  ctx.beginPath()
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + w - radius, y)
  ctx.quadraticCurveTo(x + w, y, x + w, y + radius)
  ctx.lineTo(x + w, y + h - radius)
  ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h)
  ctx.lineTo(x + radius, y + h)
  ctx.quadraticCurveTo(x, y + h, x, y + h - radius)
  ctx.lineTo(x, y + radius)
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.closePath()
}

export function drawLabel(ctx: CanvasRenderingContext2D, text: string, x: number, y: number) {
  ctx.save()
  ctx.font = 'bold 12px sans-serif'
  const metrics = ctx.measureText(text)
  const padX = 8
  const padY = 6
  const w = Math.ceil(metrics.width + padX * 2)
  const h = 22
  ctx.fillStyle = 'rgba(0,0,0,0.85)'
  roundRect(ctx, x - padX, y - 14, w, h, 12)
  ctx.fill()
  ctx.fillStyle = '#ffffff'
  ctx.textBaseline = 'middle'
  ctx.fillText(text, x, y)
  ctx.restore()
}
