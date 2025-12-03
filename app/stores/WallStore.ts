import { defineStore } from 'pinia';
import { computed, reactive, ref, toRaw, watch } from 'vue';
import type { PolygonSurface, Wall } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import {
  subtractPolygonGroupsArea,
  unionPolygonsArea,
} from '../service/Measurment/polygonDifference';
export function clonePolygonData(polygons: PolygonSurface[]): PolygonSurface[] {
  return polygons.map((p) => ({
    ...toRaw(p),
    // deep copy point coordinates to avoid mutating snapshots
    points: toRaw(p.points).map((pt) => ({ x: pt.x, y: pt.y })),
  }));
}
const ssrSafeStorage = process.client
  ? localStorage
  : {
      getItem: (_key: string) => null,
      setItem: (_key: string, _value: string) => {},
      removeItem: (_key: string) => {},
    } as unknown as Storage;
export const useWallStore = defineStore(
  'wallStore',
  () => {
    // Structure: { [surveyId]: { [wallId]: Wall } }
    const wallsBySurvey = ref<Record<string, Record<string, Wall>>>(reactive({}));
    const STORAGE_KEY = 'wallStore.v2.wallsBySurvey';

    if (process.client) {
      try {
        const saved = localStorage.getItem(STORAGE_KEY);
        if (saved) {
          const parsed = JSON.parse(saved) as Record<string, Record<string, Wall>>;
          // hydrate into reactive tree so deep watch observes nested mutations
          const hydrated: Record<string, Record<string, Wall>> = reactive({});
          for (const [sid, walls] of Object.entries(parsed || {})) {
            const rec = reactive({} as Record<string, Wall>);
            for (const [wid, wall] of Object.entries(walls || {})) {
              rec[wid] = reactive(wall as Wall);
            }
            hydrated[sid] = rec;
          }
          wallsBySurvey.value = hydrated;
        }
      } catch (e) {
        // ignore hydrate errors in mock/dev
      }
      watch(
        wallsBySurvey,
        (val) => {
          try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(toRaw(val)));
          } catch (e) {
            // ignore persist errors
          }
        },
        { deep: true },
      );
    }

    // Get walls for a specific survey
    const getWallsForSurvey = (surveyId: string): Record<string, Wall> => {
      if (!wallsBySurvey.value[surveyId]) {
        wallsBySurvey.value[surveyId] = reactive({});
      }
      return wallsBySurvey.value[surveyId];
    };

    function setWall(surveyId: string, wallId: string, wall: Wall) {
      if (!wallsBySurvey.value[surveyId]) {
        wallsBySurvey.value[surveyId] = reactive({});
      }
      // ensure wall object is reactive so deep watch can persist nested edits
      const reactiveWall = (wall as any).__v_isReactive ? wall : reactive(wall);
      wallsBySurvey.value[surveyId][wallId] = reactiveWall;
    }

    function removeWall(surveyId: string, wallId: string) {
      if (wallsBySurvey.value[surveyId]) {
        delete wallsBySurvey.value[surveyId][wallId];
      }
    }

    // Legacy compatibility - returns all walls (deprecated)
    const walls = computed(() => {
      const allWalls: Record<string, Wall> = {};
      Object.values(wallsBySurvey.value).forEach(surveyWalls => {
        Object.assign(allWalls, surveyWalls);
      });
      return allWalls;
    });

    function hasPolygons(surveyId: string, wallId: string): boolean {
      const surveyWalls = getWallsForSurvey(surveyId);
      const wall = surveyWalls[wallId];
      if (!wall) return false;
      return wall.polygons.some((p) => p.closed);
    }
    function getWallSurfaceAreas(surveyId: string, wallId: string) {
      const surveyWalls = getWallsForSurvey(surveyId);
      const wall = surveyWalls[wallId];
      if (!wall) return null;

      const imgWidth = wall.images[0]?.processedImageWidth ?? 1;
      const imgHeight = wall.images[0]?.processedImageHeight ?? 1;
      const rawMpp = wall.images[0]?.meterPerPixel;
      const meterPerPixel = (typeof rawMpp === 'number' && isFinite(rawMpp) && rawMpp > 0) ? rawMpp : 1;

      const polyArea = (p: PolygonSurface): number => {
        const pts = (p.points || []) as Array<{x:number;y:number}>;
        if (pts.length < 3) return 0;
        // scale to pixels
        const den = pts.map(pt => ({ x: pt.x * imgWidth, y: pt.y * imgHeight }));
        let areaPx2 = 0;
        for (let i = 0; i < den.length; i++) {
          const j = (i + 1) % den.length;
          areaPx2 += den[i]!.x * den[j]!.y - den[j]!.x * den[i]!.y;
        }
        return Math.abs(areaPx2 / 2) * meterPerPixel * meterPerPixel;
      };
      const sumAreas = (list: PolygonSurface[]) => list.reduce((s, p) => s + polyArea(p), 0);

      const isManual = Boolean(wall.images?.[0]?.manual);
      if (isManual) {
        const manualAreaOf = (p: PolygonSurface): number => {
          const anyP = p as any;
          const ov = anyP.areaOverrideM2 as number | null | undefined;
          if (typeof ov === 'number' && isFinite(ov) && ov > 0) return ov;
          const a = anyP.edgeNotesCm?.a as number | null | undefined;
          const b = anyP.edgeNotesCm?.b as number | null | undefined;
          if (p.points?.length === 4 && typeof a === 'number' && typeof b === 'number' && isFinite(a) && isFinite(b) && a > 0 && b > 0) {
            return (a * b) / 10000;
          }
          if (p.points?.length === 3) {
            const edges = (anyP.edgeNotesCm?.edges || []) as Array<number | null | undefined>;
            if (edges.length === 3 && edges.every(v => typeof v === 'number' && isFinite(v as number) && (v as number) > 0)) {
              const aM = (edges[0] as number) / 100;
              const bM = (edges[1] as number) / 100;
              const cM = (edges[2] as number) / 100;
              const s = (aM + bM + cM) / 2;
              const tri = Math.sqrt(Math.max(0, s * (s - aM) * (s - bM) * (s - cM)));
              if (tri > 0) return tri;
            }
            const mg = anyP.manualGeom;
            if (mg && mg.type === 'triangle') {
              const aCm = Number(mg.aCm), bCm = Number(mg.bCm), cCm = Number(mg.cCm);
              if (aCm > 0 && bCm > 0 && cCm > 0) {
                const aM = aCm / 100, bM = bCm / 100, cM = cCm / 100;
                const s = (aM + bM + cM) / 2;
                const tri = Math.sqrt(Math.max(0, s * (s - aM) * (s - bM) * (s - cM)));
                if (tri > 0) return tri;
              }
            }
          }
          return 0;
        };

        let facadeGrossArea = 0;
        let windowDoorArea = 0;
        let wallPlinthArea = 0;
        for (const p of (wall.polygons || [])) {
          if (!p.closed) continue;
          const area = manualAreaOf(p);
          if (!area) continue;
          if (p.type === SurfaceType.FACADE) facadeGrossArea += area;
          else if (p.type === SurfaceType.WINDOW_DOOR) windowDoorArea += area;
          else if (p.type === SurfaceType.WALL_PLINTH) wallPlinthArea += area;
        }
        const facadeNetArea = Math.max(0, facadeGrossArea - windowDoorArea);
        const wallPlinthNetArea = wallPlinthArea;

        const manualArea = (wall.images || [])
          .flatMap((img: any) => (img?.manualShapes ?? []))
          .reduce((sum: number, s: any) => sum + (Number(s?.areaM2) || 0), 0);

        return {
          facadeGrossArea,
          facadeNetArea,
          windowDoorArea,
          wallPlinthArea,
          wallPlinthNetArea,
          manualArea,
        };
      }

      const getPolygonByType = (type: SurfaceType) => {
        return wall.polygons.filter((p) => ((p.type ?? SurfaceType.FACADE) === type) && p.closed);
      };

      const facadePolygons = getPolygonByType(SurfaceType.FACADE);
      const windowPolygons = getPolygonByType(SurfaceType.WINDOW_DOOR);
      const plinthPolygons = getPolygonByType(SurfaceType.WALL_PLINTH);

      let facadeGrossArea = unionPolygonsArea(
        clonePolygonData(facadePolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      if (!(facadeGrossArea > 0) && facadePolygons.length) {
        facadeGrossArea = sumAreas(facadePolygons);
      }
      let windowDoorArea = unionPolygonsArea(
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      if (!(windowDoorArea > 0) && windowPolygons.length) {
        windowDoorArea = sumAreas(windowPolygons);
      }
      let wallPlinthArea = unionPolygonsArea(
        clonePolygonData(plinthPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      if (!(wallPlinthArea > 0) && plinthPolygons.length) {
        wallPlinthArea = sumAreas(plinthPolygons);
      }

      let facadeNetArea = subtractPolygonGroupsArea(
        clonePolygonData(facadePolygons),
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      if (!(facadeNetArea > 0) && (facadePolygons.length || windowPolygons.length)) {
        facadeNetArea = Math.max(0, facadeGrossArea - windowDoorArea);
      }

      let wallPlinthNetArea = subtractPolygonGroupsArea(
        clonePolygonData(plinthPolygons),
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      if (!(wallPlinthNetArea > 0) && (plinthPolygons.length || windowPolygons.length)) {
        wallPlinthNetArea = Math.max(0, wallPlinthArea - windowDoorArea);
      }

      const manualArea = (wall.images || [])
        .flatMap((img: any) => (img?.manualShapes ?? []))
        .reduce((sum: number, s: any) => sum + (Number(s?.areaM2) || 0), 0);

      return {
        facadeGrossArea,
        facadeNetArea,
        windowDoorArea,
        wallPlinthArea,
        wallPlinthNetArea,
        manualArea,
      };
    }

    function getTotalAreaByType(surveyId: string, type: SurfaceType): number {
      let total = 0;
      const surveyWalls = getWallsForSurvey(surveyId);

      Object.values(surveyWalls).forEach((wall) => {
        const polygonsOfType = wall.polygons.filter((p) => p.type === type && p.closed);

        const polygonsClone = clonePolygonData(polygonsOfType);

        const rawMpp = wall.images[0]?.meterPerPixel;
        const meterPerPixel = (typeof rawMpp === 'number' && isFinite(rawMpp) && rawMpp > 0) ? rawMpp : 1;
        const imgWidth = wall.images[0]?.processedImageWidth ?? 1;
        const imgHeight = wall.images[0]?.processedImageHeight ?? 1;

        const area = unionPolygonsArea(polygonsClone, imgWidth, imgHeight, meterPerPixel);

        total += area;
      });

      return total;
    }

    return {
      walls, // deprecated - use getWallsForSurvey instead
      wallsBySurvey,
      getWallsForSurvey,
      setWall,
      removeWall,
      getTotalAreaByType,
      getWallSurfaceAreas,
      hasPolygons,
    };
  },
);
