import { describe, it, expect } from 'vitest';
import { subtractPolygonGroupsArea } from '@/service/Measurment/polygonDifference';
import type { PolygonSurface } from '@/model/Measure/ArucoWallSurface';

let idCounter = 0;
const mockSurface = (points: { x: number; y: number }[]): PolygonSurface => ({
  id: `mock-${++idCounter}`,
  points,
  closed: true,
});

describe('subtractPolygonGroupsArea', () => {
  it('should return 0 when no base polygons', () => {
    const result = subtractPolygonGroupsArea([], [], 1000, 1000, 0.01);
    expect(result).toBe(0);
  });

  it('should calculate area of a 200 x 200 px square in 0.1 m/px scale (→ 4 m²)', () => {
    const base: PolygonSurface[] = [
      mockSurface([
        { x: 0.1, y: 0.1 },
        { x: 0.3, y: 0.1 },
        { x: 0.3, y: 0.3 },
        { x: 0.1, y: 0.3 },
      ]),
    ];

    const result = subtractPolygonGroupsArea(base, [], 1000, 1000, 0.01);
    expect(result).toBeCloseTo(4.0, 2); // 200x200 px = 40000 px² = 4 m²
  });

  it('should subtract 100x100 px square from 400x400 px square (→ 15 m²)', () => {
    const base: PolygonSurface[] = [
      mockSurface([
        { x: 0.1, y: 0.1 },
        { x: 0.5, y: 0.1 },
        { x: 0.5, y: 0.5 },
        { x: 0.1, y: 0.5 },
      ]),
    ];

    const subtract: PolygonSurface[] = [
      mockSurface([
        { x: 0.3, y: 0.3 },
        { x: 0.4, y: 0.3 },
        { x: 0.4, y: 0.4 },
        { x: 0.3, y: 0.4 },
      ]),
    ];

    const result = subtractPolygonGroupsArea(base, subtract, 1000, 1000, 0.01);
    expect(result).toBeCloseTo(15.0, 2); // (400x400 - 100x100) px = 150000 px² = 15 m²
  });
});
