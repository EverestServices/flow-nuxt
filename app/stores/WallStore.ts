import { defineStore } from 'pinia';
import { computed, reactive, ref, toRaw } from 'vue';
import type { PolygonSurface, Wall } from '@/model/Measure/ArucoWallSurface';
import { SurfaceType } from '@/model/Measure/ArucoWallSurface';
import {
  subtractPolygonGroupsArea,
  unionPolygonsArea,
} from '../service/Measurment/polygonDifference';
export function clonePolygonData(polygons: PolygonSurface[]): PolygonSurface[] {
  return polygons.map((p) => ({
    ...toRaw(p),
    points: toRaw(p.points),
  }));
}
export const useWallStore = defineStore(
  'wallStore',
  () => {
    const walls = ref<Record<string, Wall>>(reactive({}));

    function setWall(id: string, wall: Wall) {
      walls.value[id] = wall;
    }

    function removeWall(id: string) {
      delete walls.value[id];
    }

    function hasPolygons(wallId: string): boolean {
      const wall = walls.value[wallId];
      if (!wall) return false;
      return wall.polygons.some((p) => p.closed);
    }
    function getWallSurfaceAreas(wallId: string) {
      const wall = walls.value[wallId];
      if (!wall) return null;

      const imgWidth = wall.images[0]?.processedImageWidth ?? 1;
      const imgHeight = wall.images[0]?.processedImageHeight ?? 1;
      const meterPerPixel = wall.images[0]?.meterPerPixel ?? 1;

      const getPolygonByType = (type: SurfaceType) => {
        return wall.polygons.filter((p) => p.type === type && p.closed);
      };

      const facadePolygons = getPolygonByType(SurfaceType.FACADE);
      const windowPolygons = getPolygonByType(SurfaceType.WINDOW_DOOR);
      const plinthPolygons = getPolygonByType(SurfaceType.WALL_PLINTH);

      const facadeGrossArea = unionPolygonsArea(
        clonePolygonData(facadePolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      const windowDoorArea = unionPolygonsArea(
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );
      const wallPlinthArea = unionPolygonsArea(
        clonePolygonData(plinthPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );

      const facadeNetArea = subtractPolygonGroupsArea(
        clonePolygonData(facadePolygons),
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );

      const wallPlinthNetArea = subtractPolygonGroupsArea(
        clonePolygonData(plinthPolygons),
        clonePolygonData(windowPolygons),
        imgWidth,
        imgHeight,
        meterPerPixel,
      );

      return {
        facadeGrossArea,
        facadeNetArea,
        windowDoorArea,
        wallPlinthArea,
        wallPlinthNetArea,
      };
    }

    function getTotalAreaByType(type: SurfaceType): number {
      let total = 0;

      Object.values(walls.value).forEach((wall) => {
        const polygonsOfType = wall.polygons.filter((p) => p.type === type && p.closed);

        const polygonsClone = clonePolygonData(polygonsOfType);

        const meterPerPixel = wall.images[0]?.meterPerPixel ?? 1;
        const imgWidth = wall.images[0]?.processedImageWidth ?? 1;
        const imgHeight = wall.images[0]?.processedImageHeight ?? 1;

        const area = unionPolygonsArea(polygonsClone, imgWidth, imgHeight, meterPerPixel);

        total += area;
      });

      return total;
    }

    // konkrét API-k
    const totalFacadeArea = computed(() => getTotalAreaByType(SurfaceType.FACADE));
    const totalWindowDoorArea = computed(() => getTotalAreaByType(SurfaceType.WINDOW_DOOR));
    const totalWallPlinthArea = computed(() => getTotalAreaByType(SurfaceType.WALL_PLINTH));

    return {
      walls,
      setWall,
      removeWall,
      getTotalAreaByType,
      totalFacadeArea,
      totalWindowDoorArea,
      totalWallPlinthArea,
      getWallSurfaceAreas,
      hasPolygons,
    };
  },
  {
    persist: {
      paths: ['walls'],
      storage: localStorage,
    },
  },
);
