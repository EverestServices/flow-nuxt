import { polygon, featureCollection, difference, union } from '@turf/turf';
import type { Feature, Polygon, MultiPolygon } from 'geojson';
import type { PolygonSurface } from '@/model/Measure/ArucoWallSurface';

/**
 * Converts an array of points into closed coordinate pairs.
 */
function toClosedCoords(points: Array<{ x: number; y: number }>): Array<[number, number]> {
  if (!points || points.length === 0) {
    return [];
  }

  const coords = points.map((p) => [p.x, p.y] as [number, number]);
  const first = coords[0]!;
  const last = coords[coords.length - 1]!;

  if (first[0] !== last[0] || first[1] !== last[1]) {
    coords.push(first);
  }

  return coords;
}

function toTurfPolygon(surface: PolygonSurface): Feature<Polygon> {
  const coords = toClosedCoords(surface.points);
  return polygon([coords]);
}

function calculatePolygonArea(
  points: { x: number; y: number }[],
  imageWidth: number,
  imageHeight: number,
  meterPerPixel: number,
): number {
  const denormPoints = points.map((p) => ({
    x: p.x * imageWidth,
    y: p.y * imageHeight,
  }));
  let area = 0;
  const n = denormPoints.length;
  if (typeof denormPoints === 'undefined') return 0;
  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n;
    area += denormPoints[i].x * denormPoints[j].y - denormPoints[j].x * denormPoints[i].y;
  }
  return Math.abs(area / 2) * meterPerPixel * meterPerPixel;
}

function calculateAreaFromFeature(
  feature: Feature<Polygon | MultiPolygon>,
  imageWidth: number,
  imageHeight: number,
  meterPerPixel: number,
): number {
  const coords =
    feature.geometry.type === 'Polygon'
      ? [feature.geometry.coordinates]
      : feature.geometry.coordinates;

  let total = 0;

  for (let i = 0; i < coords.length; i++) {
    const polygon = coords[i];

    const outerRing = polygon[0];
    const outerPoints = outerRing.map(([x, y]) => ({ x, y }));
    let ringArea = calculatePolygonArea(outerPoints, imageWidth, imageHeight, meterPerPixel);

    for (let j = 1; j < polygon.length; j++) {
      const innerRing = polygon[j];
      const innerPoints = innerRing.map(([x, y]) => ({ x, y }));
      ringArea -= calculatePolygonArea(innerPoints, imageWidth, imageHeight, meterPerPixel);
    }

    total += ringArea;
  }

  return total;
}

export function subtractPolygonGroupsArea(
  bases: PolygonSurface[],
  subtracts: PolygonSurface[],
  imageWidth: number,
  imageHeight: number,
  meterPerPixel: number,
): number {
  const basePolygons = bases.filter((p) => p.points.length >= 3).map(toTurfPolygon);

  const subtractPolygons = subtracts.filter((p) => p.points.length >= 3).map(toTurfPolygon);

  if (basePolygons.length === 0) return 0;

  let baseUnion: Feature<Polygon | MultiPolygon>;
  if (basePolygons.length === 1) {
    baseUnion = basePolygons[0];
  } else {
    baseUnion = union(featureCollection(basePolygons)) as Feature<Polygon | MultiPolygon>;
  }

  let subtractUnion: Feature<Polygon | MultiPolygon> | null = null;
  if (subtractPolygons.length === 1) {
    subtractUnion = subtractPolygons[0];
  } else if (subtractPolygons.length >= 2) {
    subtractUnion = union(featureCollection(subtractPolygons)) as Feature<Polygon | MultiPolygon>;
  }

  try {
    const result = subtractUnion
      ? difference(featureCollection([baseUnion, subtractUnion]))
      : baseUnion;

    if (!result) return 0;

    return calculateAreaFromFeature(result, imageWidth, imageHeight, meterPerPixel);
  } catch (e) {
    console.warn('Error calculating union/difference area:', e);
    return 0;
  }
}

export function unionPolygonsArea(
  bases: PolygonSurface[],
  imageWidth: number,
  imageHeight: number,
  meterPerPixel: number,
): number {
  const basePolygons = bases.filter((p) => p.points.length >= 3).map(toTurfPolygon);

  if (basePolygons.length === 0) return 0;

  let unioned: Feature<Polygon | MultiPolygon>;

  if (basePolygons.length === 1) {
    unioned = basePolygons[0];
  } else if (basePolygons.length >= 2) {
    unioned = union(featureCollection(basePolygons)) as Feature<Polygon | MultiPolygon>;
  } else {
    return 0;
  }

  return calculateAreaFromFeature(unioned, imageWidth, imageHeight, meterPerPixel);
}
