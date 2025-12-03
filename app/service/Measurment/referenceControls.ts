import type { Ref, ComputedRef } from 'vue'
import type { Point, Wall } from '@/model/Measure/ArucoWallSurface'

export function createReferenceControls(params: {
  firstImage: ComputedRef<any>
  imageRef: Ref<HTMLImageElement | null>
  wall: ComputedRef<Wall>
  surveyId: ComputedRef<string>
  store: any
  imageWidth: Ref<number>
  imageHeight: Ref<number>
  zoomScale: Ref<number>
  zoomContainerRef: Ref<HTMLElement | null>
  highlightRef: Ref<boolean>
  drawAllPolygons: () => void
  setMode: (m: 'view' | 'draw' | 'edit' | 'calibrate') => void
  meterPerPixel: Ref<number>
  allowRefOverride: Ref<boolean>
  showSavedReference: Ref<boolean>
  calibrationStart: Ref<Point | null>
  calibrationEnd: Ref<Point | null>
  calibrationLength: Ref<number | null>
}) {
  const {
    firstImage,
    imageRef,
    wall,
    surveyId,
    store,
    imageWidth,
    imageHeight,
    zoomScale,
    zoomContainerRef,
    highlightRef,
    drawAllPolygons,
    setMode,
    meterPerPixel,
    allowRefOverride,
    showSavedReference,
    calibrationStart,
    calibrationEnd,
    calibrationLength,
  } = params

  const applyCalibration = () => {
    // Do not override an existing saved reference unless explicitly started a new one
    const hasSavedRef = Boolean(firstImage.value?.referenceStart && firstImage.value?.referenceEnd)
    if (hasSavedRef && !allowRefOverride.value) return
    if (!calibrationStart.value || !calibrationEnd.value || !calibrationLength.value || !imageRef.value) return

    const naturalWidth = imageRef.value.naturalWidth
    const naturalHeight = imageRef.value.naturalHeight

    const dx = (calibrationEnd.value.x - calibrationStart.value.x) * naturalWidth
    const dy = (calibrationEnd.value.y - calibrationStart.value.y) * naturalHeight

    const pixelDist = Math.sqrt(dx * dx + dy * dy)
    if (pixelDist === 0) return

    const lengthMeters = (calibrationLength.value ?? 0) / 100
    meterPerPixel.value = lengthMeters / pixelDist

    if (firstImage.value && wall.value) {
      firstImage.value.meterPerPixel = meterPerPixel.value
      firstImage.value.referenceStart = { ...calibrationStart.value }
      firstImage.value.referenceEnd = { ...calibrationEnd.value }
      firstImage.value.referenceLengthCm = calibrationLength.value ?? null
      store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] })
    }
    allowRefOverride.value = false
    calibrationStart.value = null
    calibrationEnd.value = null
    calibrationLength.value = null
    setMode('view')
    highlightStoredReference()
  }

  const highlightStoredReference = () => {
    const imgMeta = firstImage.value
    const container = zoomContainerRef.value
    if (!imgMeta || !imgMeta.referenceStart || !imgMeta.referenceEnd || !container) return
    const scaledW = imageWidth.value * zoomScale.value
    const scaledH = imageHeight.value * zoomScale.value
    const midX = ((imgMeta.referenceStart.x + imgMeta.referenceEnd.x) / 2) * scaledW
    const midY = ((imgMeta.referenceStart.y + imgMeta.referenceEnd.y) / 2) * scaledH
    container.scrollLeft = Math.max(0, midX - container.clientWidth / 2)
    container.scrollTop = Math.max(0, midY - container.clientHeight / 2)
    highlightRef.value = true
    drawAllPolygons()
    window.setTimeout(() => {
      highlightRef.value = false
      drawAllPolygons()
    }, 1200)
  }

  const toggleSavedReference = () => {
    const imgMeta = firstImage.value
    const container = zoomContainerRef.value
    if (!imgMeta || !imgMeta.referenceStart || !imgMeta.referenceEnd || !container) return
    showSavedReference.value = !showSavedReference.value
    if (showSavedReference.value) {
      const scaledW = imageWidth.value * zoomScale.value
      const scaledH = imageHeight.value * zoomScale.value
      const midX = ((imgMeta.referenceStart.x + imgMeta.referenceEnd.x) / 2) * scaledW
      const midY = ((imgMeta.referenceStart.y + imgMeta.referenceEnd.y) / 2) * scaledH
      container.scrollLeft = Math.max(0, midX - container.clientWidth / 2)
      container.scrollTop = Math.max(0, midY - container.clientHeight / 2)
    }
    drawAllPolygons()
  }

  const onStartNewReference = () => {
    if (typeof setMode === 'function') setMode('calibrate')
    calibrationStart.value = null
    calibrationEnd.value = null
    calibrationLength.value = null
    showSavedReference.value = false
    allowRefOverride.value = true
    drawAllPolygons()
  }

  const onChangeReferenceLength = () => {
    const imgMeta = firstImage.value
    const img = imageRef.value
    if (!imgMeta || !img || !imgMeta.referenceStart || !imgMeta.referenceEnd) return
    const current = imgMeta.referenceLengthCm ?? null
    const input = typeof window !== 'undefined' ? window.prompt('Referencia hossza (cm)', current ? String(current) : '') : null
    if (input === null) return
    const lengthCm = Number(input)
    if (!Number.isFinite(lengthCm) || lengthCm <= 0) return
    const dx = (imgMeta.referenceEnd.x - imgMeta.referenceStart.x) * img.naturalWidth
    const dy = (imgMeta.referenceEnd.y - imgMeta.referenceStart.y) * img.naturalHeight
    const pixelDist = Math.sqrt(dx * dx + dy * dy)
    if (pixelDist <= 0) return
    meterPerPixel.value = (lengthCm / 100) / pixelDist
    imgMeta.referenceLengthCm = lengthCm
    imgMeta.meterPerPixel = meterPerPixel.value
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] })
    highlightStoredReference()
  }

  const onClearReference = () => {
    const imgMeta = firstImage.value
    if (!imgMeta) return
    imgMeta.referenceStart = null
    imgMeta.referenceEnd = null
    imgMeta.referenceLengthCm = null
    showSavedReference.value = false
    store.setWall(surveyId.value, wall.value.id, { ...wall.value, images: [...wall.value.images] })
    drawAllPolygons()
  }

  return {
    applyCalibration,
    highlightStoredReference,
    toggleSavedReference,
    onStartNewReference,
    onChangeReferenceLength,
    onClearReference,
  }
}
