// Minimal in-memory store for measurement load/save mocks
const __mockMemory: Record<string, any> = {}

export async function mockRequest<T = any>(
  method: string,
  url: string,
  data?: any,
  _config?: any,
): Promise<T> {
  // Process facade image → return processed image URL and pixel size
  if (method === 'POST' && url.includes('/measure/aruco/api/facade/process')) {
    let imageUrl = ''
    if (typeof window !== 'undefined' && data instanceof FormData) {
      const file = data.get('file') as File | null
      if (file) imageUrl = URL.createObjectURL(file)
    }
    const res = {
      distortion_corrected: true,
      real_pixel_size: 0.0025,
      image_url: imageUrl,
    } as any
    return res as T
  }

  // Align facade image → return URL + pixel size
  if (method === 'POST' && url.includes('/measure/aruco/api/facade/align')) {
    let imageUrl = ''
    if (typeof window !== 'undefined' && data instanceof FormData) {
      const file = data.get('file') as File | null
      if (file) imageUrl = URL.createObjectURL(file)
    }
    return ({ url: imageUrl, pixelSizeInMeter: 0.0025 } as any) as T
  }

  // Image real size → fixed mock value
  if (method === 'POST' && url.includes('/measure/aruco/api/image/real-size')) {
    return ({ pixelSizeInMeter: 0.0025 } as any) as T
  }

  // Save measurement → store by clientId in-memory
  if (method === 'POST' && url.includes('/api/facade/measure/save/')) {
    const clientId = url.split('/').pop() || 'unknown'
    __mockMemory[clientId] = data?.data ?? data
    return ({ ok: true } as any) as T
  }

  // Load measurement → return previously saved or empty
  if (method === 'GET' && url.includes('/api/facade/measure/load/')) {
    const clientId = url.split('/').pop() || 'unknown'
    const payload = __mockMemory[clientId] ?? { walls: [], extraItems: [] }
    return ({ data: payload } as any) as T
  }

  // Default behavior: echo POST/PUT data, empty for others
  if (method === 'POST' || method === 'PUT') {
    return (data as T) ?? ({} as T)
  }
  return ({} as unknown) as T
}
