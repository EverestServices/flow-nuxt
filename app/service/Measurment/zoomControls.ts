import type { Ref, ComputedRef } from 'vue'
import { applyZoomBy } from '@/service/Measurment/zoom'

export function createZoomControls(params: {
  imageRef: Ref<HTMLImageElement | null>
  zoomContainerRef: Ref<HTMLDivElement | null>
  zoomWrapperRef: Ref<HTMLDivElement | null>
  imageWidth: Ref<number>
  imageHeight: Ref<number>
  isViewMode: ComputedRef<boolean>
  zoomScale: Ref<number>
}) {
  const { imageRef, zoomContainerRef, zoomWrapperRef, imageWidth, imageHeight, isViewMode, zoomScale } = params

  const calculateOptimalZoom = () => {
    if (!imageRef.value || !zoomContainerRef.value) return
    const container = zoomContainerRef.value
    const availableW = container.clientWidth
    const availableH = container.clientHeight
    const scaleX = availableW / imageWidth.value
    const scaleY = availableH / imageHeight.value
    if (isViewMode.value) {
      zoomScale.value = Math.min(scaleX, scaleY)
    } else {
      zoomScale.value = Math.max(scaleX, scaleY)
    }
  }

  const gotoZoom = (targetScale: number) => {
    const container = zoomContainerRef.value
    if (!container) return
    const imageW = imageWidth.value
    const imageH = imageHeight.value
    const prevScale = zoomScale.value
    const prevW = imageW * prevScale
    const prevH = imageH * prevScale
    const centerX = container.scrollLeft + container.clientWidth / 2
    const centerY = container.scrollTop + container.clientHeight / 2
    const relX = prevW > 0 ? centerX / prevW : 0.5
    const relY = prevH > 0 ? centerY / prevH : 0.5
    zoomScale.value = Math.min(3, Math.max(0.2, targetScale))
    const newW = imageW * zoomScale.value
    const newH = imageH * zoomScale.value
    const newCenterX = relX * newW
    const newCenterY = relY * newH
    container.scrollLeft = newCenterX - container.clientWidth / 2
    container.scrollTop = newCenterY - container.clientHeight / 2
  }

  const zoomBy = (delta: number) => {
    const container = zoomContainerRef.value
    const wrapper = zoomWrapperRef.value
    if (!container || !wrapper) return
    const r = applyZoomBy({
      container,
      imageW: imageWidth.value,
      imageH: imageHeight.value,
      prevScale: zoomScale.value,
      delta,
    })
    zoomScale.value = r.nextScale
    container.scrollLeft = r.scrollLeft
    container.scrollTop = r.scrollTop
  }

  return { calculateOptimalZoom, gotoZoom, zoomBy }
}
