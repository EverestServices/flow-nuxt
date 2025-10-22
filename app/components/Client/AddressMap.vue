<template>
  <div class="h-full w-full flex flex-col">
    <!-- Map Container -->
    <div ref="mapContainer" class="flex-1 w-full rounded-4xl overflow-hidden" />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'

interface Props {
  address: string
}

const props = defineProps<Props>()

const config = useRuntimeConfig()
const mapContainer = ref<HTMLElement>()
const map = ref<any>(null)
const marker = ref<any>(null)
const geocoder = ref<any>(null)

// Initialize map
const initMap = () => {
  if (!mapContainer.value || !window.google) return

  const googleMaps = window.google.maps

  // Initialize map centered on Budapest
  map.value = new googleMaps.Map(mapContainer.value, {
    center: { lat: 47.497912, lng: 19.040235 },
    zoom: 13,
    mapTypeId: 'roadmap',
    mapTypeControl: false
  })

  // Add initial marker
  marker.value = new googleMaps.Marker({
    position: { lat: 47.497912, lng: 19.040235 },
    map: map.value,
    draggable: true
  })

  // Initialize geocoder
  geocoder.value = new googleMaps.Geocoder()

  // Add marker drag listener
  marker.value.addListener('dragend', () => {
    const position = marker.value.getPosition()
    reverseGeocode(position)
  })

  // Add map click listener
  map.value.addListener('click', (event: any) => {
    marker.value.setPosition(event.latLng)
    reverseGeocode(event.latLng)
  })
}

// Load Google Maps script
const loadGoogleMaps = (): Promise<void> => {
  return new Promise((resolve, reject) => {
    if (window.google?.maps) {
      resolve()
      return
    }

    const script = document.createElement('script')
    const apiKey = config.public.googleMapsApiKey
    if (!apiKey) {
      console.error('Google Maps API key not found')
      reject(new Error('Google Maps API key not found'))
      return
    }
    script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`
    script.async = true
    script.defer = true
    script.onload = () => resolve()
    script.onerror = () => {
      console.error('Failed to load Google Maps')
      reject(new Error('Failed to load Google Maps'))
    }
    document.head.appendChild(script)
  })
}

// Geocode location to coordinates
const geocodeAddress = async (address: string): Promise<{ lat: number; lng: number } | null> => {
  if (!address.trim() || !geocoder.value) return null

  return new Promise((resolve) => {
    geocoder.value.geocode({ address }, (results: any[], status: string) => {
      if (status === 'OK' && results && results.length > 0) {
        const location = results[0].geometry.location
        resolve({
          lat: location.lat(),
          lng: location.lng()
        })
      } else {
        resolve(null)
      }
    })
  })
}

// Reverse geocode coordinates to address
const reverseGeocode = (location: any) => {
  if (!geocoder.value) return

  geocoder.value.geocode({ location }, (results: any[], status: string) => {
    if (status === 'OK' && results && results.length > 0) {
      console.log('Reverse geocoded address:', results[0].formatted_address)
    }
  })
}

// Update map location based on address
const updateMapLocation = async () => {
  if (!map.value || !props.address.trim()) return

  const coords = await geocodeAddress(props.address)
  if (coords) {
    const latLng = new window.google.maps.LatLng(coords.lat, coords.lng)

    // Update marker position
    if (marker.value) {
      marker.value.setPosition(latLng)
    }

    // Adjust zoom based on address specificity
    if (props.address.match(/\d+$/)) {
      // Has house number - zoom closer
      map.value.setZoom(18)
    } else if (props.address.includes(',')) {
      // Has street - medium zoom
      map.value.setZoom(16)
    } else {
      // Only postal code/city - wider zoom
      map.value.setZoom(14)
    }

    // Offset the center to the right so marker is visible on right side
    // Calculate offset in pixels (form takes up left 50%, so shift center to right)
    const bounds = map.value.getBounds()
    if (bounds) {
      const projection = map.value.getProjection()
      if (projection) {
        // Pan to marker first
        map.value.panTo(latLng)

        // Then shift the view to show marker on the right side
        // This moves the center point left so the marker appears on the right
        const scale = Math.pow(2, map.value.getZoom())
        const worldCoordinate = projection.fromLatLngToPoint(latLng)
        const pixelOffset = new window.google.maps.Point(
          (worldCoordinate.x - 0.15) * scale, // Shift left by 15% of map width
          worldCoordinate.y * scale
        )
        const newCenter = projection.fromPointToLatLng(
          new window.google.maps.Point(
            pixelOffset.x / scale,
            pixelOffset.y / scale
          )
        )
        map.value.panTo(newCenter)
      }
    }

    // Add popup with address
    const infoWindow = new window.google.maps.InfoWindow({
      content: props.address
    })
    infoWindow.open(map.value, marker.value)
  }
}

// Watch address changes
watch(() => props.address, async () => {
  await updateMapLocation()
}, { immediate: false })

// Lifecycle
onMounted(async () => {
  try {
    await loadGoogleMaps()
    initMap()
    if (props.address) {
      await updateMapLocation()
    }
  } catch (error) {
    console.error('Error initializing Google Maps:', error)
  }
})

// TypeScript declarations
declare global {
  interface Window {
    google: any
  }
}
</script>

<style scoped>
/* Google Maps container should fill the available space */
:deep(.gm-style) {
  font-family: inherit;
}
</style>
