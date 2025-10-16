<template>
  <div class="map-calendar">
    <!-- Map Container -->
    <div class="map-section">
      <div ref="mapContainer" class="map-container" />
    </div>

    <!-- Events List with Distances -->
    <UIBox>
      <div class="events-sidebar">
        <div class="sidebar-header">
          <h3 class="sidebar-title">
            {{ formatDay(currentDate) }}
          </h3>
          <div class="day-subtitle">
            {{ formatDaySubtitle(currentDate) }}
          </div>
        </div>

        <div v-if="eventsWithLocations.length === 0" class="no-events">
          <p>No events with locations for this day</p>
        </div>

        <div v-else class="events-list">
          <!-- Total Distance -->
          <div v-if="totalDistance > 0" class="total-distance">
            <div class="distance-icon">🚗</div>
            <div class="distance-info">
              <div class="distance-label">Total Distance</div>
              <div class="distance-value">{{ formatDistance(totalDistance) }}</div>
            </div>
          </div>

          <!-- Route Info -->
          <div v-if="routeDuration" class="route-duration">
            <div class="duration-icon">⏱️</div>
            <div class="duration-info">
              <div class="duration-label">Estimated Travel Time</div>
              <div class="duration-value">{{ routeDuration }}</div>
            </div>
          </div>

          <!-- Event Cards -->
          <div
            v-for="(event, index) in eventsWithLocations"
            :key="event.id"
            class="event-card"
            :class="`event-${event.type}`"
            @click="handleEventClick(event)"
            @mouseenter="highlightMarker(index)"
            @mouseleave="unhighlightMarker()"
          >
            <div class="event-number">{{ index + 1 }}</div>
            <div class="event-content">
              <div class="event-header">
                <div class="event-title">{{ event.title }}</div>
                <div class="event-time">{{ formatEventTime(event) }}</div>
              </div>

              <div class="event-location">
                <span class="location-icon">📍</span>
                {{ event.location }}
              </div>

              <div v-if="event.description" class="event-description">
                {{ event.description }}
              </div>

              <!-- Distance from previous location -->
              <div v-if="index > 0 && distancesBetweenEvents[index - 1]" class="distance-from-prev">
                <span class="distance-icon-small">↗️</span>
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
const totalDistance = ref(0)
const routeDuration = ref('')
const distancesBetweenEvents = ref<number[]>([])

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

  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(map.value)

  // Load and display events on map
  await loadEventsOnMap(L)
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

// Lifecycle
onMounted(async () => {
  await initMap()
})

// Watch for events changes
watch(eventsWithLocations, async () => {
  if (map.value) {
    const L = (window as any).L
    if (L) {
      await loadEventsOnMap(L)
    }
  }
})
</script>

<style scoped>
.map-calendar {
  display: flex;
  height: calc(100vh - 300px);
  min-height: 600px;
  gap: 0;
}

.map-section {
  flex: 1;
  position: relative;
}

.map-container {
  width: 100%;
  height: 100%;
}

.events-sidebar {
  width: 400px;
  border-left: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.sidebar-header {
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.sidebar-title {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.day-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin-top: 4px;
}

.no-events {
  padding: 40px 20px;
  text-align: center;
  color: #6b7280;
}

.events-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.total-distance,
.route-duration {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #f0f9ff;
  border-radius: 8px;
  margin-bottom: 16px;
}

.distance-icon,
.duration-icon {
  font-size: 32px;
}

.distance-info,
.duration-info {
  flex: 1;
}

.distance-label,
.duration-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.distance-value,
.duration-value {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  margin-top: 2px;
}

.event-card {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.2s;
  border: 2px solid transparent;
}

.event-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.event-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 16px;
  flex-shrink: 0;
  color: white;
}

.event-meeting {
  background: #dbeafe;
  border-left: 4px solid #3b82f6;
}

.event-meeting .event-number {
  background: #3b82f6;
}

.event-training {
  background: #fef3c7;
  border-left: 4px solid #f59e0b;
}

.event-training .event-number {
  background: #f59e0b;
}

.event-on-site-consultation {
  background: #d1fae5;
  border-left: 4px solid #10b981;
}

.event-on-site-consultation .event-number {
  background: #10b981;
}

.event-online-consultation {
  background: #e0e7ff;
  border-left: 4px solid #6366f1;
}

.event-online-consultation .event-number {
  background: #6366f1;
}

.event-personal {
  background: #fce7f3;
  border-left: 4px solid #ec4899;
}

.event-personal .event-number {
  background: #ec4899;
}

.event-holiday {
  background: #fed7d7;
  border-left: 4px solid #f56565;
}

.event-holiday .event-number {
  background: #f56565;
}

.event-other {
  background: #f3f4f6;
  border-left: 4px solid #6b7280;
}

.event-other .event-number {
  background: #6b7280;
}

.event-content {
  flex: 1;
  min-width: 0;
}

.event-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.event-title {
  font-weight: 600;
  font-size: 16px;
  color: #1f2937;
  flex: 1;
}

.event-time {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
  white-space: nowrap;
  margin-left: 8px;
}

.event-location {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #4b5563;
  margin-bottom: 6px;
}

.location-icon {
  font-size: 14px;
}

.event-description {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 8px;
  line-height: 1.4;
}

.distance-from-prev {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #3b82f6;
  font-weight: 600;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.distance-icon-small {
  font-size: 14px;
}

/* Custom marker styles */
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

@media (max-width: 1024px) {
  .map-calendar {
    flex-direction: column;
    height: auto;
  }

  .map-section {
    min-height: 400px;
  }

  .map-container {
  }

  .events-sidebar {
    width: 100%;
    max-height: 500px;
  }
}
</style>