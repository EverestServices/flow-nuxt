import type { Point } from '@/model/Measure/ArucoWallSurface'

export function canvasOffset(wrapper: HTMLElement, canvas: HTMLCanvasElement): { offX: number; offY: number } {
  const c = canvas.getBoundingClientRect()
  const w = wrapper.getBoundingClientRect()
  return { offX: c.left - w.left, offY: c.top - w.top }
}
