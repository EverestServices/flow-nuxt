export function applyZoomBy(params: {
  container: HTMLElement
  imageW: number
  imageH: number
  prevScale: number
  delta: number
}): { nextScale: number; scrollLeft: number; scrollTop: number } {
  const { container, imageW, imageH, prevScale, delta } = params
  const nextScale = Math.min(3, Math.max(0.2, prevScale + delta))

  const prevW = imageW * prevScale
  const prevH = imageH * prevScale

  const centerX = container.scrollLeft + container.clientWidth / 2
  const centerY = container.scrollTop + container.clientHeight / 2

  const relX = prevW > 0 ? centerX / prevW : 0.5
  const relY = prevH > 0 ? centerY / prevH : 0.5

  const newW = imageW * nextScale
  const newH = imageH * nextScale

  const newCenterX = relX * newW
  const newCenterY = relY * newH

  return {
    nextScale,
    scrollLeft: newCenterX - container.clientWidth / 2,
    scrollTop: newCenterY - container.clientHeight / 2,
  }
}

export function applyGotoZoom(params: {
  container: HTMLElement
  imageW: number
  imageH: number
  currentScale: number
  targetScale: number
}): { nextScale: number; scrollLeft: number; scrollTop: number } {
  const { container, imageW, imageH, currentScale } = params
  const nextScale = Math.min(3, Math.max(0.2, params.targetScale))

  const prevW = imageW * currentScale
  const prevH = imageH * currentScale

  const centerX = container.scrollLeft + container.clientWidth / 2
  const centerY = container.scrollTop + container.clientHeight / 2

  const relX = prevW > 0 ? centerX / prevW : 0.5
  const relY = prevH > 0 ? centerY / prevH : 0.5

  const newW = imageW * nextScale
  const newH = imageH * nextScale

  const newCenterX = relX * newW
  const newCenterY = relY * newH

  return {
    nextScale,
    scrollLeft: newCenterX - container.clientWidth / 2,
    scrollTop: newCenterY - container.clientHeight / 2,
  }
}
