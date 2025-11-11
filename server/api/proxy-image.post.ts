/**
 * Server API endpoint to proxy image downloads from ArUco API
 * This bypasses CORS restrictions by downloading the image server-side
 */
export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const { imageUrl } = body

    if (!imageUrl || typeof imageUrl !== 'string') {
      throw createError({
        statusCode: 400,
        message: 'Image URL is required',
      })
    }

    // Validate that the URL is from the ArUco API
    if (!imageUrl.startsWith('https://aruco.everest.hu/')) {
      throw createError({
        statusCode: 400,
        message: 'Invalid image URL domain',
      })
    }

    // Download the image from the ArUco API (server-side, no CORS)
    console.log('Proxy: Downloading image from:', imageUrl)
    const response = await fetch(imageUrl)

    if (!response.ok) {
      throw createError({
        statusCode: response.status,
        message: `Failed to download image: ${response.statusText}`,
      })
    }

    // Get the image as a buffer
    const imageBuffer = await response.arrayBuffer()
    const contentType = response.headers.get('content-type') || 'image/png'

    console.log('Proxy: Downloaded image, size:', imageBuffer.byteLength, 'bytes')

    // Set the response headers
    setResponseHeaders(event, {
      'Content-Type': contentType,
      'Content-Length': imageBuffer.byteLength.toString(),
    })

    // Return the image buffer
    return Buffer.from(imageBuffer)
  } catch (error: any) {
    console.error('Proxy error:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      message: error.message || 'Failed to proxy image',
    })
  }
})
