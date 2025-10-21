<template>
  <div class="h-full w-full flex flex-col">
    <!-- Map Header -->
    <div class="bg-gradient-to-r from-blue-600 to-blue-500 px-6 py-4 flex items-center gap-3">
      <div class="bg-white/20 rounded-full p-2">
        <UIcon name="i-heroicons-map" class="w-6 h-6 text-white" />
      </div>
      <h3 class="text-lg font-semibold text-white">Location on Map</h3>
    </div>

    <!-- Map Container -->
    <div ref="mapContainer" class="flex-1 w-full" />
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
    mapTypeId: 'satellite',
    mapTypeControl: true,
    mapTypeControlOptions: {
      style: googleMaps.MapTypeControlStyle.HORIZONTAL_BAR,
      position: googleMaps.ControlPosition.TOP_RIGHT,
      mapTypeIds: ['roadmap', 'satellite']
    }
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

    // Update map view with animation
    map.value.panTo(latLng)

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
