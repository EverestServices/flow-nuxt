export type Point = { x: number; y: number };
export type UploadStatus = 'initial' | 'pending' | 'success' | 'failed';

export type WallImage = {
  imageId: string;
  file: File | null;
  fileName: string | null;
  uploadStatus: UploadStatus;
  message: string | null;
  processedImageUrl?: string;
  previewUrl?: string;
  meterPerPixel?: number | null;
  processedImageWidth?: number;
  processedImageHeight?: number;
  // Optional stored calibration reference (normalized to [0..1])
  referenceStart?: Point | null;
  referenceEnd?: Point | null;
  referenceLengthCm?: number | null;
};

export type Wall = {
  id: string;
  name: string;
  images: WallImage[];
  polygons: PolygonSurface[];
  clientId?: string;
};
export enum DimensionType {
  height = 'height',
  width = 'width',
}
export class DimensionPoints {
  public start: Point;
  public end: Point;

  constructor(start: Point = { x: 0, y: 0 }, end: Point = { x: 0, y: 0 }) {
    this.start = start;
    this.end = end;
  }
}
export class ArucoWallSurface {
  private readonly _uniqueId: string;
  public width?: number | null;
  public height?: number | null;
  public label?: string;
  public description?: string;
  public widthPoints?: DimensionPoints | null;
  public heightPoints?: DimensionPoints | null;
  public isNegativeType: boolean = false;

  constructor() {
    this._uniqueId = crypto.randomUUID();
  }

  get uniqueId(): string {
    return this._uniqueId;
  }
}

export enum SurfaceType {
  WALL_PLINTH = 'wallPlinth',
  FACADE = 'facade',
  WINDOW_DOOR = 'windowDoor',
}
export enum WindowSubType {
  DOOR = 'door',
  WINDOW = 'window',
  TERRACE_DOOR = 'terraceDoor',
}

export enum ExternalShadingType {
  NONE = 'none',
  ROLLER_SHUTTER = 'redony',
  SHUTTERS = 'zsalugater',
  VENETIAN_BLINDS = 'zsaluzia',
  TEXTILE_ROLLER = 'textilRolo',
}
export interface PolygonSurface {
  id: string;
  points: Point[];
  closed: boolean;
  visible?: boolean;
  type?: SurfaceType;
  // Only applicable when type === SurfaceType.WINDOW_DOOR
  subType?: WindowSubType;
  externalShading?: ExternalShadingType;
  name?: string;
}
