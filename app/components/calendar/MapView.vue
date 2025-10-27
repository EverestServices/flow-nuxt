<template>
  <div class="flex h-[calc(100vh-120px)] gap-4">
    <!-- Map Container -->
    <UIBox class="flex-1">
      <div class="w-full h-full relative overflow-hidden rounded-3xl">
        <div ref="mapContainer" class="w-full h-full" />
      </div>
    </UIBox>

    <!-- Events List with Distances -->
    <UIBox class="w-[400px]">
      <div class="flex flex-col overflow-hidden h-full">
        <div class="p-5 border-b border-gray-200 dark:border-gray-700">
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white m-0 outfit">
            {{ formatDay(currentDate) }}
          </h3>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            {{ formatDaySubtitle(currentDate) }}
          </div>

          <!-- Location Tracking Toggle -->
          <div
            @click="toggleLocationTracking"
            class="mt-4 flex items-center gap-3 p-3 rounded-lg transition-all border-2"
            :class="[
              locationLoading ? 'bg-blue-50 dark:bg-blue-900/20 border-blue-500 cursor-wait' :
              locationTrackingEnabled ? 'bg-green-50 dark:bg-green-900/20 border-green-500 cursor-pointer' :
              'bg-gray-50 dark:bg-gray-800/50 border-gray-300 dark:border-gray-600 hover:border-green-400 cursor-pointer'
            ]"
          >
            <div
              class="w-10 h-10 rounded-full flex items-center justify-center text-xl"
              :class="locationLoading ? 'bg-blue-500' : locationTrackingEnabled ? 'bg-green-500' : 'bg-gray-400 dark:bg-gray-600'"
            >
              <span v-if="locationLoading" class="animate-spin">🔄</span>
              <span v-else>📍</span>
            </div>
            <div class="flex-1">
              <div class="font-semibold text-sm" :class="locationLoading ? 'text-blue-700 dark:text-blue-400' : locationTrackingEnabled ? 'text-green-700 dark:text-green-400' : 'text-gray-700 dark:text-gray-300'">
                {{ locationLoading ? 'Getting Location...' : locationTrackingEnabled ? 'Location Tracking On' : 'Access Location' }}
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400">
                {{ locationLoading ? 'Please wait...' : locationTrackingEnabled ? 'Click to disable' : 'Click to enable' }}
              </div>
            </div>
            <div
              v-if="locationTrackingEnabled"
              class="w-3 h-3 bg-green-500 rounded-full animate-pulse"
            />
          </div>
        </div>

        <div v-if="eventsWithLocations.length === 0" class="py-10 px-5 text-center text-gray-600 dark:text-gray-400">
          <p>No events with locations for this day</p>
        </div>

        <div v-else class="flex-1 overflow-y-auto p-4">
          <!-- Distance to Next Meeting -->
          <div v-if="locationTrackingEnabled && distanceToNextMeeting > 0" class="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/20 rounded-lg mb-4 border-2 border-green-500">
            <div class="text-[32px]">🎯</div>
            <div class="flex-1">
              <div class="text-xs text-green-700 dark:text-green-400 font-semibold uppercase tracking-wide">Distance to Next Meeting</div>
              <div class="text-xl font-bold text-green-900 dark:text-green-300 mt-0.5">{{ formatDistance(distanceToNextMeeting) }}</div>
              <div v-if="durationToNextMeeting" class="text-sm text-green-700 dark:text-green-400 mt-1">
                Approx. {{ durationToNextMeeting }} drive
              </div>
            </div>
          </div>

          <!-- Total Distance -->
          <div v-if="totalDistance > 0" class="flex items-center gap-3 p-4 bg-blue-50 dark:bg-blue-500/15 rounded-lg mb-4">
            <div class="text-[32px]">🚗</div>
            <div class="flex-1">
              <div class="text-xs text-gray-600 dark:text-gray-400 font-semibold uppercase tracking-wide">Total Distance</div>
              <div class="text-xl font-bold text-gray-900 dark:text-white mt-0.5">{{ formatDistance(totalDistance) }}</div>
            </div>
          </div>

          <!-- Route Info -->
          <div v-if="routeDuration" class="flex items-center gap-3 p-4 bg-blue-50 dark:bg-blue-500/15 rounded-lg mb-4">
            <div class="text-[32px]">⏱️</div>
            <div class="flex-1">
              <div class="text-xs text-gray-600 dark:text-gray-400 font-semibold uppercase tracking-wide">Estimated Travel Time</div>
              <div class="text-xl font-bold text-gray-900 dark:text-white mt-0.5">{{ routeDuration }}</div>
            </div>
          </div>

          <!-- Event Cards -->
          <div
            v-for="(event, index) in eventsWithLocations"
            :key="event.id"
            class="flex gap-3 p-4 rounded-lg mb-3 cursor-pointer transition-all duration-200 border-2 border-transparent hover:-translate-y-0.5 hover:shadow-lg"
            :class="getEventCardClasses(event.type)"
            @click="handleEventClick(event)"
            @mouseenter="highlightMarker(index)"
            @mouseleave="unhighlightMarker()"
          >
            <div class="w-8 h-8 rounded-full flex items-center justify-center font-bold text-base flex-shrink-0 text-white" :class="getEventNumberClasses(event.type)">
              {{ index + 1 }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex justify-between items-start mb-2">
                <div class="font-semibold text-base text-gray-900 dark:text-gray-900 flex-1">{{ event.title }}</div>
                <div class="text-xs text-gray-600 dark:text-gray-600 font-medium whitespace-nowrap ml-2">{{ formatEventTime(event) }}</div>
              </div>

              <div class="flex items-center gap-1.5 text-[13px] text-gray-700 dark:text-gray-600 mb-1.5">
                <span class="text-sm">📍</span>
                {{ event.location }}
              </div>

              <div v-if="event.description" class="text-[13px] text-gray-600 dark:text-gray-700 mb-2 leading-snug">
                {{ event.description }}
              </div>

              <!-- Distance from previous location -->
              <div v-if="index > 0 && distancesBetweenEvents[index - 1]" class="flex items-center gap-1.5 text-xs text-blue-600 font-semibold mt-2 pt-2 border-t border-black/5">
                <span class="text-sm">↗️</span>
                {{ formatDistance(distancesBetweenEvents[index - 1]) }} from previous
              </div>
            </div>
          </div>
        </div>
      </div>
    </UIBox>

  </div>
</template>

<script setup lang="ts">
import { format } from 'date-fns'
import type { CalendarEvent } from '~/composables/useCalendar'

interface Props {
  currentDate: Date
  events: CalendarEvent[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  eventClick: [event: CalendarEvent]
}>()

const mapContainer = ref<HTMLElement>()
const map = ref<any>(null)
const markers = ref<any[]>([])
const routeLine = ref<any>(null)
const tileLayer = ref<any>(null)
const totalDistance = ref(0)
const routeDuration = ref('')
const distancesBetweenEvents = ref<number[]>([])
const isDarkMode = ref(false)

// Location tracking - use global state
const { locationTrackingEnabled, locationLoading, userLocation, toggleLocationTracking } = useLocationTracking()

// Map-specific location state
const userLocationMarker = ref<any>(null)
const distanceToNextMeeting = ref(0)
const durationToNextMeeting = ref('')

// Get today's events with locations
const eventsWithLocations = computed(() => {
  const dateStr = format(props.currentDate, 'yyyy-MM-dd')
  return props.events
    .filter(event => event.start_date === dateStr && event.location)
    .sort((a, b) => {
      const timeA = a.start_time || '00:00'
      const timeB = b.start_time || '00:00'
      return timeA.localeCompare(timeB)
    })
})

// Initialize map (using Leaflet as a free alternative)
const initMap = async () => {
  if (!mapContainer.value) return

  // Load Leaflet dynamically
  const L = await loadLeaflet()
  if (!L) return

  // Initialize map centered on default location
  map.value = L.map(mapContainer.value).setView([51.505, -0.09], 13)

  // Check if dark mode is enabled
  isDarkMode.value = document.documentElement.classList.contains('dark')

  // Add Positron style tiles (light or dark based on theme)
  updateMapTiles(L)

  // Load and display events on map
  await loadEventsOnMap(L)

  // Watch for dark mode changes
  setupDarkModeObserver(L)
}

// Update map tiles based on dark mode
const updateMapTiles = (L: any) => {
  if (!map.value) return

  // Remove existing tile layer if it exists
  if (tileLayer.value) {
    map.value.removeLayer(tileLayer.value)
  }

  // Add new tile layer based on dark mode
  const tileUrl = isDarkMode.value
    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'

  tileLayer.value = L.tileLayer(tileUrl, {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors © <a href="https://carto.com/attributions">CARTO</a>',
    subdomains: 'abcd',
    maxZoom: 20
  }).addTo(map.value)
}

// Setup MutationObserver to watch for dark mode changes
const setupDarkModeObserver = (L: any) => {
  const observer = new MutationObserver(() => {
    const newDarkMode = document.documentElement.classList.contains('dark')
    if (newDarkMode !== isDarkMode.value) {
      isDarkMode.value = newDarkMode
      updateMapTiles(L)
    }
  })

  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['class']
  })

  // Cleanup observer on component unmount
  onUnmounted(() => {
    observer.disconnect()
  })
}

// Load Leaflet library
const loadLeaflet = async () => {
  return new Promise<any>((resolve) => {
    if ((window as any).L) {
      resolve((window as any).L)
      return
    }

    // Add Leaflet CSS
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
    document.head.appendChild(link)

    // Add Leaflet JS
    const script = document.createElement('script')
    script.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'
    script.onload = () => {
      resolve((window as any).L)
    }
    script.onerror = () => {
      console.error('Failed to load Leaflet')
      resolve(null)
    }
    document.head.appendChild(script)
  })
}

// Geocode location to coordinates
const geocodeLocation = async (location: string): Promise<[number, number] | null> => {
  try {
    // Using Nominatim (OpenStreetMap) geocoding service
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}`
    )
    const data = await response.json()

    if (data && data.length > 0) {
      return [parseFloat(data[0].lat), parseFloat(data[0].lon)]
    }
    return null
  } catch (error) {
    console.error('Geocoding error:', error)
    return null
  }
}

// Get driving route between two coordinates using OSRM
const getDrivingRoute = async (
  start: [number, number],
  end: [number, number]
): Promise<{ distance: number; duration: number; geometry: [number, number][] } | null> => {
  try {
    // Using OSRM (Open Source Routing Machine) for car routing
    const response = await fetch(
      `https://router.project-osrm.org/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=full&geometries=geojson`
    )
    const data = await response.json()

    if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
      const route = data.routes[0]
      return {
        distance: route.distance / 1000, // Convert meters to km
        duration: route.duration, // Duration in seconds
        geometry: route.geometry.coordinates.map((coord: number[]) => [coord[1], coord[0]]) // Convert to [lat, lon]
      }
    }
    return null
  } catch (error) {
    console.error('Routing error:', error)
    return null
  }
}

// Load events on map
const loadEventsOnMap = async (L: any) => {
  if (!map.value || eventsWithLocations.value.length === 0) return

  // Clear existing markers and routes
  markers.value.forEach(marker => marker.remove())
  markers.value = []
  if (routeLine.value) {
    routeLine.value.remove()
    routeLine.value = null
  }

  const coordinates: [number, number][] = []
  const distances: number[] = []
  const routeGeometries: [number, number][][] = []

  // Create custom numbered icons
  const createNumberedIcon = (number: number) => {
    return L.divIcon({
      className: 'custom-marker',
      html: `<div class="marker-pin" style="background-color: ${getEventColor(eventsWithLocations.value[number - 1].type)}">
               <span class="marker-number">${number}</span>
             </div>`,
      iconSize: [40, 40],
      iconAnchor: [20, 40]
    })
  }

  // Geocode all events and add markers
  for (let i = 0; i < eventsWithLocations.value.length; i++) {
    const event = eventsWithLocations.value[i]
    if (!event.location) continue

    const coords = await geocodeLocation(event.location)
    if (coords) {
      coordinates.push(coords)

      // Get driving route from previous point
      if (i > 0 && coordinates[i - 1]) {
        const route = await getDrivingRoute(coordinates[i - 1], coords)
        if (route) {
          distances.push(route.distance)
          routeGeometries.push(route.geometry)
        }
      }

      // Create marker
      const marker = L.marker(coords, {
        icon: createNumberedIcon(i + 1)
      }).addTo(map.value)

      // Add popup
      marker.bindPopup(`
        <div class="marker-popup">
          <strong>${event.title}</strong><br/>
          <span>${formatEventTime(event)}</span><br/>
          <span>${event.location}</span>
        </div>
      `)

      markers.value.push(marker)
    }
  }

  distancesBetweenEvents.value = distances

  // Draw route lines if multiple locations
  if (coordinates.length > 1 && routeGeometries.length > 0) {
    // Draw each route segment
    const allRouteCoords: [number, number][] = []
    routeGeometries.forEach(geometry => {
      allRouteCoords.push(...geometry)
    })

    if (allRouteCoords.length > 0) {
      routeLine.value = L.polyline(allRouteCoords, {
        color: '#3b82f6',
        weight: 4,
        opacity: 0.8
      }).addTo(map.value)

      // Calculate total distance
      totalDistance.value = distances.reduce((sum, dist) => sum + dist, 0)

      // Calculate total travel time from OSRM routes
      let totalDurationSeconds = 0
      for (let i = 0; i < coordinates.length - 1; i++) {
        const route = await getDrivingRoute(coordinates[i], coordinates[i + 1])
        if (route) {
          totalDurationSeconds += route.duration
        }
      }

      // Format duration
      const minutes = Math.round(totalDurationSeconds / 60)
      if (minutes < 60) {
        routeDuration.value = `${minutes} min`
      } else {
        const hrs = Math.floor(minutes / 60)
        const mins = minutes % 60
        routeDuration.value = `${hrs}h ${mins}m`
      }

      // Fit map to show all markers
      map.value.fitBounds(routeLine.value.getBounds(), { padding: [50, 50] })
    }
  } else if (coordinates.length === 1) {
    map.value.setView(coordinates[0], 15)
  }
}

// Get color for event type
const getEventColor = (type: string): string => {
  const colors: Record<string, string> = {
    meeting: '#3b82f6',
    training: '#f59e0b',
    'on-site-consultation': '#10b981',
    'online-consultation': '#6366f1',
    personal: '#ec4899',
    holiday: '#f56565',
    other: '#6b7280'
  }
  return colors[type] || '#6b7280'
}

// Get event card Tailwind classes
const getEventCardClasses = (type: string): string => {
  const classes: Record<string, string> = {
    meeting: 'bg-blue-100 border-l-4 border-l-blue-500',
    training: 'bg-amber-50 border-l-4 border-l-amber-500',
    'on-site-consultation': 'bg-emerald-100 border-l-4 border-l-emerald-500',
    'online-consultation': 'bg-indigo-100 border-l-4 border-l-indigo-500',
    personal: 'bg-pink-100 border-l-4 border-l-pink-500',
    holiday: 'bg-red-100 border-l-4 border-l-red-400',
    other: 'bg-gray-100 border-l-4 border-l-gray-500'
  }
  return classes[type] || classes.other
}

// Get event number background classes
const getEventNumberClasses = (type: string): string => {
  const classes: Record<string, string> = {
    meeting: 'bg-blue-500',
    training: 'bg-amber-500',
    'on-site-consultation': 'bg-emerald-500',
    'online-consultation': 'bg-indigo-500',
    personal: 'bg-pink-500',
    holiday: 'bg-red-400',
    other: 'bg-gray-500'
  }
  return classes[type] || classes.other
}

// Format distance
const formatDistance = (km: number): string => {
  if (km < 1) {
    return `${Math.round(km * 1000)} m`
  }
  return `${km.toFixed(1)} km`
}

// Format event time
const formatEventTime = (event: CalendarEvent): string => {
  if (event.all_day) return 'All day'
  if (!event.start_time) return ''

  let timeStr = formatTime(event.start_time)
  if (event.end_time && event.end_time !== event.start_time) {
    timeStr += ` - ${formatTime(event.end_time)}`
  }
  return timeStr
}

const formatTime = (time: string): string => {
  const [hours, minutes] = time.split(':').map(Number)
  const ampm = hours >= 12 ? 'PM' : 'AM'
  const displayHour = hours % 12 || 12
  return `${displayHour}:${minutes.toString().padStart(2, '0')} ${ampm}`
}

const formatDay = (date: Date): string => {
  return format(date, 'EEEE')
}

const formatDaySubtitle = (date: Date): string => {
  return format(date, 'MMMM d, yyyy')
}

// Handle event click
const handleEventClick = (event: CalendarEvent) => {
  emit('eventClick', event)
}

// Highlight marker on hover
const highlightMarker = (index: number) => {
  if (markers.value[index]) {
    markers.value[index].openPopup()
  }
}

const unhighlightMarker = () => {
  markers.value.forEach(marker => marker.closePopup())
}

// Watch for location tracking changes to update map
watch([locationTrackingEnabled, userLocation], async ([enabled, coords]) => {
  if (!enabled || !coords) {
    // Location tracking disabled - remove marker and clear distance
    distanceToNextMeeting.value = 0
    durationToNextMeeting.value = ''
    if (userLocationMarker.value) {
      userLocationMarker.value.remove()
      userLocationMarker.value = null
    }
  } else if (coords && map.value) {
    // Location tracking enabled - add marker and calculate distance
    await addUserLocationMarker(coords)
    await calculateDistanceToNextMeeting(coords)
  }
})

const addUserLocationMarker = async (coords: [number, number]) => {
  if (!map.value) return

  const L = (window as any).L
  if (!L) return

  // Remove existing user marker
  if (userLocationMarker.value) {
    userLocationMarker.value.remove()
  }

  // Create custom user location icon
  const userIcon = L.divIcon({
    className: 'user-location-marker',
    html: `<div class="user-marker-pin">
             <span class="user-marker-icon">📍</span>
           </div>
           <div class="user-marker-pulse"></div>`,
    iconSize: [30, 30],
    iconAnchor: [15, 15]
  })

  // Add marker
  userLocationMarker.value = L.marker(coords, {
    icon: userIcon,
    zIndexOffset: 1000 // Ensure it's on top
  }).addTo(map.value)

  // Add popup
  userLocationMarker.value.bindPopup(`
    <div class="marker-popup">
      <strong>Your Location</strong><br/>
      <span>Current position</span>
    </div>
  `)

  // Pan to user location
  map.value.setView(coords, map.value.getZoom())
}

const calculateDistanceToNextMeeting = async (userCoords: [number, number]) => {
  if (eventsWithLocations.value.length === 0) {
    distanceToNextMeeting.value = 0
    durationToNextMeeting.value = ''
    return
  }

  // Get the next upcoming event (first event in the sorted list)
  const nextEvent = eventsWithLocations.value[0]
  if (!nextEvent.location) {
    distanceToNextMeeting.value = 0
    durationToNextMeeting.value = ''
    return
  }

  // Geocode the next event location
  const eventCoords = await geocodeLocation(nextEvent.location)
  if (!eventCoords) {
    distanceToNextMeeting.value = 0
    durationToNextMeeting.value = ''
    return
  }

  // Get driving route from user location to next meeting
  const route = await getDrivingRoute(userCoords, eventCoords)
  if (route) {
    distanceToNextMeeting.value = route.distance

    // Format duration
    const minutes = Math.round(route.duration / 60)
    if (minutes < 60) {
      durationToNextMeeting.value = `${minutes} min`
    } else {
      const hrs = Math.floor(minutes / 60)
      const mins = minutes % 60
      durationToNextMeeting.value = `${hrs}h ${mins}m`
    }
  }
}

// Lifecycle
onMounted(async () => {
  await initMap()

  // If location tracking is already enabled, show user location on map
  if (locationTrackingEnabled.value && userLocation.value) {
    await addUserLocationMarker(userLocation.value)
    await calculateDistanceToNextMeeting(userLocation.value)
  }
})

// Watch for events changes
watch(eventsWithLocations, async () => {
  if (map.value) {
    const L = (window as any).L
    if (L) {
      await loadEventsOnMap(L)
    }
  }

  // Recalculate distance when events change
  if (locationTrackingEnabled.value && userLocation.value) {
    await calculateDistanceToNextMeeting(userLocation.value)
  }
})
</script>

<style scoped>
/* Outfit font */
.outfit {
  font-family: 'Outfit', sans-serif;
}

/* Custom Leaflet marker styles - can't be done with Tailwind */
:deep(.custom-marker) {
  background: transparent;
  border: none;
}

:deep(.marker-pin) {
  width: 40px;
  height: 40px;
  border-radius: 50% 50% 50% 0;
  position: relative;
  transform: rotate(-45deg);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

:deep(.marker-number) {
  transform: rotate(45deg);
  color: white;
  font-weight: 700;
  font-size: 16px;
}

:deep(.marker-popup) {
  font-family: inherit;
}

:deep(.marker-popup strong) {
  display: block;
  margin-bottom: 4px;
  color: #1f2937;
}

:deep(.marker-popup span) {
  display: block;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 2px;
}

/* User location marker styles */
:deep(.user-location-marker) {
  background: transparent;
  border: none;
}

:deep(.user-marker-pin) {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #10b981;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.5);
  position: relative;
  z-index: 2;
}

:deep(.user-marker-icon) {
  font-size: 18px;
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.3));
}

:deep(.user-marker-pulse) {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: rgba(16, 185, 129, 0.4);
  position: absolute;
  top: 0;
  left: 0;
  animation: pulse 2s ease-out infinite;
  z-index: 1;
}

@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  100% {
    transform: scale(2.5);
    opacity: 0;
  }
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .flex.h-\[calc\(100vh-100px\)\].gap-4 {
    flex-direction: column;
    height: auto;
  }

  .flex.h-\[calc\(100vh-100px\)\].gap-4 > :first-child {
    min-height: 400px;
  }

  .flex.h-\[calc\(100vh-100px\)\].gap-4 > .w-\[400px\] {
    width: 100%;
    max-height: 500px;
  }
}
</style>