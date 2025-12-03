import type { Ref } from 'vue'

export function createPanHandlers(params: {
  zoomContainerRef: Ref<HTMLElement | null>
  zoomWrapperRef: Ref<HTMLElement | null>
  isViewMode: Ref<boolean>
  isSpacePressed: Ref<boolean>
  zoomScale: Ref<number>
  dragStart: Ref<{ x: number; y: number }>
  scrollStart: Ref<{ x: number; y: number }>
  isDragging: Ref<boolean>
}) {
  const {
    zoomContainerRef,
    zoomWrapperRef,
    isViewMode,
    isSpacePressed,
    zoomScale,
    dragStart,
    scrollStart,
    isDragging,
  } = params

  const handleContainerMouseDown = (event: MouseEvent) => {
    const container = zoomContainerRef.value
    if (!container) return

    const canDrag = isViewMode.value || (isSpacePressed.value && zoomScale.value > 1.0)
    if (!canDrag) return

    if (event.target !== container && !zoomWrapperRef.value?.contains(event.target as Node)) return

    isDragging.value = true
    dragStart.value = { x: event.clientX, y: event.clientY }
    scrollStart.value = { x: container.scrollLeft, y: container.scrollTop }
    event.preventDefault()
  }

  const handleContainerMouseMove = (event: MouseEvent) => {
    const container = zoomContainerRef.value
    if (!isDragging.value || !container) return
    const dx = event.clientX - dragStart.value.x
    const dy = event.clientY - dragStart.value.y
    container.scrollLeft = scrollStart.value.x - dx
    container.scrollTop = scrollStart.value.y - dy
  }

  const handleContainerMouseUp = () => { isDragging.value = false }

  return { handleContainerMouseDown, handleContainerMouseMove, handleContainerMouseUp }
}
