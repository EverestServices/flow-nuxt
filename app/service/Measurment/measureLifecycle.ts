import { onMounted, onBeforeUnmount, watch, watchEffect, nextTick, type Ref, type ComputedRef } from 'vue'
import type { PolygonSurface, Point } from '@/model/Measure/ArucoWallSurface'

export function setupMeasureLifecycle(params: {
  zoomContainerRef: Ref<HTMLElement | null>
  zoomWrapperRef: Ref<HTMLElement | null>
  imageRef: Ref<HTMLImageElement | null>
  firstImage: ComputedRef<any>
  scrollTick: Ref<number>
  handleResize: () => void
  onKeydown: (e: KeyboardEvent) => void
  onKeyup: (e: KeyboardEvent) => void
  polygons: Ref<PolygonSurface[]>
  drawAllPolygons: () => void
  editingMode: Ref<boolean>
  currentPolygon: Ref<PolygonSurface | null>
  sidebarVisible: Ref<boolean>
  meterPerPixel: Ref<number>
  zoomScale: Ref<number>
  recalcMeterPerPixelFromReference: () => boolean
}) {
  const {
    zoomContainerRef,
    zoomWrapperRef,
    imageRef,
    firstImage,
    scrollTick,
    handleResize,
    onKeydown,
    onKeyup,
    polygons,
    drawAllPolygons,
    editingMode,
    currentPolygon,
    sidebarVisible,
    meterPerPixel,
    zoomScale,
    recalcMeterPerPixelFromReference,
  } = params

  onMounted(() => {
    window.addEventListener('resize', handleResize)
    window.addEventListener('keydown', onKeydown)
    window.addEventListener('keyup', onKeyup)

    const onScroll = () => { scrollTick.value++ }
    zoomContainerRef.value?.addEventListener('scroll', onScroll, { passive: true } as any)

    let ro: ResizeObserver | null = null
    if (typeof window !== 'undefined' && 'ResizeObserver' in window) {
      ro = new ResizeObserver(() => { scrollTick.value++ })
      if (zoomWrapperRef.value) ro.observe(zoomWrapperRef.value)
    }

    onBeforeUnmount(() => {
      window.removeEventListener('resize', handleResize)
      window.removeEventListener('keydown', onKeydown)
      window.removeEventListener('keyup', onKeyup)
      zoomContainerRef.value?.removeEventListener('scroll', onScroll as any)
      if (ro) ro.disconnect()
    })
  })

  watch(
    polygons,
    () => { drawAllPolygons() },
    { deep: true },
  )

  watch(
    () => ({ mode: editingMode.value, polygon: currentPolygon.value, pointCount: currentPolygon.value?.points.length }),
    (state) => {
      if (state.mode && state.polygon && state.pointCount && state.pointCount > 0) {
        sidebarVisible.value = false
      } else if (state.mode && !state.polygon) {
        sidebarVisible.value = true
      }
    },
    { deep: true },
  )

  watch(meterPerPixel, () => { void nextTick(() => { drawAllPolygons() }) })
  watch(zoomScale, () => { void nextTick(() => { drawAllPolygons() }) })

  watchEffect(() => {
    const _img = imageRef.value
    const meta = firstImage.value
    const _rs = meta?.referenceStart?.x ?? null
    const _re = meta?.referenceEnd?.x ?? null
    const _len = meta?.referenceLengthCm ?? null
    if (!_img || !meta) return
    if (meta.referenceStart && meta.referenceEnd && (meta.referenceLengthCm ?? 0) > 0) {
      recalcMeterPerPixelFromReference()
    }
  })
}
