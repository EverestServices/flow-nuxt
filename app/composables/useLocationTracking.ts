export const useLocationTracking = () => {
  const locationTrackingEnabled = useState<boolean>('location-tracking-enabled', () => false)
  const locationLoading = useState<boolean>('location-tracking-loading', () => false)
  const userLocation = useState<[number, number] | null>('user-location', () => null)

  const toggleLocationTracking = async () => {
    if (locationLoading.value) return

    if (locationTrackingEnabled.value) {
      // Disable location tracking
      locationTrackingEnabled.value = false
      userLocation.value = null
    } else {
      // Enable location tracking
      await getUserLocation()
    }
  }

  const getUserLocation = async () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser')
      return
    }

    locationLoading.value = true

    try {
      console.log('Requesting geolocation permission...')

      const position = await new Promise<GeolocationPosition>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(
          resolve,
          reject,
          {
            enableHighAccuracy: false,
            timeout: 10000,
            maximumAge: 60000
          }
        )
      })

      console.log('User location obtained:', position.coords)

      const coords: [number, number] = [position.coords.latitude, position.coords.longitude]
      userLocation.value = coords
      locationTrackingEnabled.value = true
      locationLoading.value = false
    } catch (error: any) {
      locationLoading.value = false
      console.error('Geolocation error:', error)

      // Try IP-based geolocation as fallback
      if (error.code === 2) {
        console.log('Attempting IP-based geolocation fallback...')
        const ipLocation = await getLocationFromIP()
        if (ipLocation) {
          return
        }
      }

      let errorMessage = 'Unable to get your location.\n\n'

      if (error.code === 2) {
        errorMessage += 'macOS System Location Services Issue:\n\n'
        errorMessage += '1. Open System Settings/Preferences\n'
        errorMessage += '2. Go to Security & Privacy → Privacy → Location Services\n'
        errorMessage += '3. Make sure "Location Services" is enabled\n'
        errorMessage += '4. Scroll down and enable location for Chrome/Safari\n'
        errorMessage += '5. Refresh this page and try again'
      } else if (error.code === 1) {
        errorMessage += 'Permission was denied. Please allow location access in your browser.'
      } else if (error.code === 3) {
        errorMessage += 'Request timed out. Please try again.'
      } else {
        errorMessage += error.message || 'Unknown error occurred.'
      }

      alert(errorMessage)
    }
  }

  const getLocationFromIP = async (): Promise<boolean> => {
    try {
      const response = await fetch('https://ipapi.co/json/')
      const data = await response.json()

      if (data.latitude && data.longitude) {
        console.log('IP-based location obtained:', data.city, data.country_name)

        const coords: [number, number] = [data.latitude, data.longitude]
        userLocation.value = coords
        locationTrackingEnabled.value = true

        alert(`Using approximate location based on your IP address.\nLocation: ${data.city}, ${data.country_name}\n\nFor precise location, please enable Location Services in System Settings.`)

        return true
      }
      return false
    } catch (error) {
      console.error('IP geolocation failed:', error)
      return false
    }
  }

  return {
    locationTrackingEnabled,
    locationLoading,
    userLocation,
    toggleLocationTracking,
    getUserLocation
  }
}
