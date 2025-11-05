import type { ExtraItem } from '@/model/ExtraItem';
import type { Wall } from '@/model/Measure/ArucoWallSurface';
import { api } from '@/service/ApiFactory'; // ApiService példány

const ARUCO_ORIGIN = 'https://aruco.everest.hu';
function toArucoAbsolute(u: string): string {
  if (!u) return u;
  if (/^(https?:)?\/\//i.test(u)) return u; // absolute or scheme-relative
  if (/^(blob:|data:|file:)/i.test(u)) return u; // keep special schemes
  return u.startsWith('/') ? ARUCO_ORIGIN + u : ARUCO_ORIGIN + '/' + u;
}

export interface AlignResponse {
  url: string;
  pixelSizeInMeter: number | null;
}

export interface PixeRealSizeResponse {
  pixelSizeInMeter: number;
}

export interface ProcessResponse {
  distortion_corrected: boolean;
  real_pixel_size: number | null;
  image_url: string;
}

export interface MeasurementPayload {
  walls: Wall[];
  extraItems: ExtraItem[];
}

export async function alignFacadeImage(file: File): Promise<AlignResponse> {
  const formData = new FormData();
  formData.append('file', file);

  const res = await api.post<AlignResponse, FormData>('/measure/aruco/api/facade/align', formData);
  return { ...res, url: toArucoAbsolute(res.url) };
}

export async function getImageRealSize(file: File): Promise<PixeRealSizeResponse> {
  const formData = new FormData();
  formData.append('file', file);

  return api.post<PixeRealSizeResponse, FormData>('/measure/aruco/api/image/real-size', formData);
}

export async function processFacadeImage(
  file: File,
  markerSize?: number,
): Promise<ProcessResponse> {
  const formData = new FormData();
  formData.append('file', file);
  if (markerSize !== undefined) {
    formData.append('marker_size', markerSize.toString());
  }

  const res = await api.post<ProcessResponse, FormData>('/measure/aruco/api/facade/process?marker_size=.12', formData);
  return { ...res, image_url: toArucoAbsolute(res.image_url) };
}

export async function saveMeasurement(
  clientId: string,
  payload: MeasurementPayload,
): Promise<object> {
  return api.post<object, { data: MeasurementPayload }>(`/api/facade/measure/save/${clientId}`, {
    data: payload,
  });
}

export async function loadMeasurement(clientId: string): Promise<MeasurementPayload> {
  const res = await api.get<{ data: MeasurementPayload }>(`/api/facade/measure/load/${clientId}`);
  return res.data;
}
