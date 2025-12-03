import type { PolygonSurface } from '@/model/Measure/ArucoWallSurface'

export type HistoryEntry = {
  polygons: PolygonSurface[]
  current: PolygonSurface | null
}

export function createHistory(deps: {
  getPolygons: () => PolygonSurface[]
  setPolygons: (p: PolygonSurface[]) => void
  getCurrent: () => PolygonSurface | null
  setCurrent: (c: PolygonSurface | null) => void
  drawAllPolygons: () => void
  clonePolygonData: (list: PolygonSurface[]) => PolygonSurface[]
}) {
  const undoStack: HistoryEntry[] = []
  const redoStack: HistoryEntry[] = []

  const snapshot = (): HistoryEntry => {
    const polyClone = deps.clonePolygonData(deps.getPolygons())
    const cur = deps.getCurrent()
    const currentClone = cur ? ((deps.clonePolygonData([cur])[0] as PolygonSurface | undefined) ?? null) : null
    return { polygons: polyClone, current: currentClone }
  }

  const applySnapshot = (s: HistoryEntry) => {
    deps.setPolygons(deps.clonePolygonData(s.polygons))
    const nextCur = s.current ? ((deps.clonePolygonData([s.current])[0] as PolygonSurface | undefined) ?? null) : null
    deps.setCurrent(nextCur)
    deps.drawAllPolygons()
  }

  const pushHistory = () => {
    undoStack.push(snapshot())
    redoStack.length = 0
  }

  const undo = () => {
    if (undoStack.length === 0) return
    const prev = undoStack.pop()!
    const cur = snapshot()
    redoStack.push(cur)
    applySnapshot(prev)
  }

  const redo = () => {
    if (redoStack.length === 0) return
    const next = redoStack.pop()!
    const cur = snapshot()
    undoStack.push(cur)
    applySnapshot(next)
  }

  const clear = () => { undoStack.length = 0; redoStack.length = 0 }

  return { pushHistory, undo, redo, clear }
}
