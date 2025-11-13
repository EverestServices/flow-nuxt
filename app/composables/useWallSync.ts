/**
 * Composable for syncing walls and openings between marker mode (WallStore) and graphic mode (Survey page instances)
 *
 * This utility ensures that:
 * 1. Walls created/edited in marker mode are reflected in the Facade Insulation -> Walls page
 * 2. Windows/Doors drawn in marker mode are reflected in the Facade Insulation -> Walls -> Nyílászárók subpage
 */

import { useWallStore } from '@/stores/WallStore'
import { useSurveyInvestmentsStore, type SurveyPage } from '@/stores/surveyInvestments'
import type { Wall, PolygonSurface } from '@/model/Measure/ArucoWallSurface'
import { SurfaceType, WindowSubType, ExternalShadingType } from '@/model/Measure/ArucoWallSurface'

export const useWallSync = () => {
  const wallStore = useWallStore()
  const surveyStore = useSurveyInvestmentsStore()

  /**
   * Syncs walls bidirectionally between WallStore and Survey page instances
   * @param surveyId The survey ID
   */
  const syncWallsToSurvey = async (surveyId: string) => {
    // Get walls from marker mode
    const walls = wallStore.getWallsForSurvey(surveyId)
    const wallsArray = Object.values(walls) as Wall[]

    // Find the Facade Insulation investment
    const facadeInvestment = surveyStore.availableInvestments.find(
      inv => inv.persist_name === 'facadeInsulation'
    )

    if (!facadeInvestment) {
      console.warn('Facade Insulation investment not found')
      return
    }

    // Make sure this investment is selected for the survey
    if (!surveyStore.selectedInvestmentIds.includes(facadeInvestment.id)) {
      console.warn('Facade Insulation is not selected for this survey')
      return
    }

    // Find the "Falak" (Walls) page
    const facadePages = surveyStore.surveyPages[facadeInvestment.id] || []
    const wallsPage = facadePages.find(
      page => page.type === 'walls' && page.name === 'Falak'
    )

    if (!wallsPage) {
      console.warn('Walls page not found in Facade Insulation')
      return
    }

    // Initialize page instances if needed
    if (!surveyStore.pageInstances[surveyId]) {
      surveyStore.pageInstances[surveyId] = {}
    }
    if (!surveyStore.pageInstances[surveyId][facadeInvestment.id]) {
      surveyStore.pageInstances[surveyId][facadeInvestment.id] = {}
    }
    if (!surveyStore.pageInstances[surveyId][facadeInvestment.id][wallsPage.id]) {
      surveyStore.pageInstances[surveyId][facadeInvestment.id][wallsPage.id] = { instances: [] }
    }

    const pageInstancesData = surveyStore.pageInstances[surveyId][facadeInvestment.id][wallsPage.id]
    const existingInstances = pageInstancesData.instances

    // STEP 1: Sync marker mode walls -> survey instances
    for (const wall of wallsArray) {
      await syncSingleWall(surveyId, wall, facadeInvestment.id, wallsPage, existingInstances)
    }

    // STEP 2: Sync survey instances -> marker mode walls (create missing walls)
    const existingWallIds = wallsArray.map(w => w.id)
    const instancesToRemove: number[] = []

    for (let index = 0; index < existingInstances.length; index++) {
      const instance = existingInstances[index]

      // If instance doesn't have a marker wall ID, create one
      if (!instance._markerWallId) {
        const newWallId = crypto.randomUUID()
        const wallName = instance.wall_name || `${index + 1}. falfelület`

        wallStore.setWall(surveyId, newWallId, {
          id: newWallId,
          name: wallName,
          orientation: instance.wall_orientation || undefined,
          images: [],
          polygons: []
        })

        // Link the instance to the new wall
        instance._markerWallId = newWallId
        instance.wall_name = wallName

        console.log(`Created marker wall for survey instance: ${wallName}`)
      }
      // If instance has a marker wall ID but the wall doesn't exist, remove the instance
      else if (!existingWallIds.includes(instance._markerWallId)) {
        instancesToRemove.push(index)
      }
    }

    // Remove in reverse order to maintain indices
    for (let i = instancesToRemove.length - 1; i >= 0; i--) {
      existingInstances.splice(instancesToRemove[i], 1)
    }

    console.log(`Bidirectional sync complete: ${wallsArray.length} marker walls, ${existingInstances.length} survey instances`)

    // STEP 3: Sync windows/doors (openings) for each wall
    await syncOpeningsToSurvey(surveyId, facadeInvestment.id, wallsPage, existingInstances, wallsArray)
  }

  /**
   * Syncs window/door polygons from marker mode to survey openings subpage instances
   */
  const syncOpeningsToSurvey = async (
    surveyId: string,
    investmentId: string,
    wallsPage: SurveyPage,
    wallInstances: Record<string, any>[],
    walls: Wall[]
  ) => {
    // Find the Nyílászárók (Openings) subpage
    const openingsPage = surveyStore.surveyPages[investmentId]?.find(
      page => page.parent_page_id === wallsPage.id && page.name === 'Nyílászárók'
    )

    if (!openingsPage) {
      console.warn('Openings subpage not found')
      return
    }

    console.log('🔄 Starting opening sync for', wallInstances.length, 'walls')

    // Initialize subpage instances if needed - use openingsPage.id, not wallsPage.id
    if (!surveyStore.pageInstances[surveyId]) {
      surveyStore.pageInstances[surveyId] = {}
    }
    if (!surveyStore.pageInstances[surveyId][investmentId]) {
      surveyStore.pageInstances[surveyId][investmentId] = {}
    }
    if (!surveyStore.pageInstances[surveyId][investmentId][openingsPage.id]) {
      surveyStore.pageInstances[surveyId][investmentId][openingsPage.id] = { instances: [], subpageInstances: {} }
    }

    const openingsPageData = surveyStore.pageInstances[surveyId][investmentId][openingsPage.id]
    if (!openingsPageData.subpageInstances) {
      openingsPageData.subpageInstances = {}
    }

    // For each wall instance, sync its openings
    wallInstances.forEach((wallInstance, parentItemGroup) => {
      const markerWallId = wallInstance._markerWallId
      if (!markerWallId) {
        console.log(`Wall instance ${parentItemGroup} has no marker wall ID, skipping`)
        return
      }

      const wall = walls.find(w => w.id === markerWallId)
      if (!wall) {
        console.log(`Marker wall ${markerWallId} not found, skipping`)
        return
      }

      // Get all WINDOW_DOOR polygons for this wall
      const openingPolygons = wall.polygons.filter(
        p => p.type === SurfaceType.WINDOW_DOOR && p.closed
      )

      console.log(`Wall "${wall.name}" (${parentItemGroup}): Found ${openingPolygons.length} opening polygons`)

      // Initialize subpage instances array for this wall if not exists
      if (!openingsPageData.subpageInstances![parentItemGroup]) {
        openingsPageData.subpageInstances![parentItemGroup] = []
      }

      const existingOpeningInstances = openingsPageData.subpageInstances![parentItemGroup]

      // Sync each opening polygon
      openingPolygons.forEach((polygon) => {
        syncSingleOpening(surveyId, wall, polygon, existingOpeningInstances)
      })

      // Remove opening instances that no longer have corresponding polygons
      const polygonIds = openingPolygons.map(p => p.id)
      const instancesToRemove: number[] = []

      existingOpeningInstances.forEach((instance, index) => {
        if (instance._markerPolygonId && !polygonIds.includes(instance._markerPolygonId)) {
          instancesToRemove.push(index)
        }
      })

      // Remove in reverse order
      for (let i = instancesToRemove.length - 1; i >= 0; i--) {
        existingOpeningInstances.splice(instancesToRemove[i], 1)
      }

      console.log(`Wall "${wall.name}" (${parentItemGroup}): Synced ${existingOpeningInstances.length} opening instances`)
    })

    console.log('✅ Synced openings for all walls')
  }

  /**
   * Syncs a single opening polygon to a survey opening instance
   */
  const syncSingleOpening = (
    surveyId: string,
    wall: Wall,
    polygon: PolygonSurface,
    existingInstances: Record<string, any>[]
  ) => {
    // Check if an instance already exists for this polygon
    const existingIndex = existingInstances.findIndex(
      instance => instance._markerPolygonId === polygon.id
    )

    // Calculate dimensions from polygon bounding box
    const dimensions = calculatePolygonDimensions(polygon, wall)

    // Map WindowSubType to opening_type
    let openingType = 'Ablak' // Default
    if (polygon.subType === WindowSubType.DOOR) {
      openingType = 'Ajtó'
    } else if (polygon.subType === WindowSubType.TERRACE_DOOR) {
      openingType = 'Erkélyajtó'
    }

    // Map ExternalShadingType to external_shading_type
    let externalShadingType = 'Nincs' // Default
    if (polygon.externalShading === ExternalShadingType.ROLLER_SHUTTER) {
      externalShadingType = 'Redőny'
    } else if (polygon.externalShading === ExternalShadingType.SHUTTERS) {
      externalShadingType = 'Zsalugáter'
    } else if (polygon.externalShading === ExternalShadingType.VENETIAN_BLINDS) {
      externalShadingType = 'Zsalúzia'
    } else if (polygon.externalShading === ExternalShadingType.TEXTILE_ROLLER) {
      externalShadingType = 'Textil roló'
    }

    // Prepare instance data
    const instanceData: Record<string, any> = {
      _markerPolygonId: polygon.id,
      opening_type: openingType,
      opening_width: dimensions.widthCm,
      opening_height: dimensions.heightCm,
      opening_quantity: 1, // Default to 1
      external_shading_type: externalShadingType,
    }

    // Update or create instance
    if (existingIndex >= 0) {
      // Update existing - preserve user edits like quantity
      existingInstances[existingIndex] = {
        ...existingInstances[existingIndex],
        ...instanceData,
        // Preserve quantity if user changed it
        opening_quantity: existingInstances[existingIndex].opening_quantity || 1,
      }
    } else {
      // Create new instance
      existingInstances.push(instanceData)
    }
  }

  /**
   * Calculates dimensions of a polygon in cm
   */
  const calculatePolygonDimensions = (
    polygon: PolygonSurface,
    wall: Wall
  ): { widthCm: number; heightCm: number } => {
    if (polygon.points.length === 0) {
      return { widthCm: 0, heightCm: 0 }
    }

    // Get bounding box
    let minX = Infinity, maxX = -Infinity
    let minY = Infinity, maxY = -Infinity

    polygon.points.forEach(point => {
      if (point.x < minX) minX = point.x
      if (point.x > maxX) maxX = point.x
      if (point.y < minY) minY = point.y
      if (point.y > maxY) maxY = point.y
    })

    const widthPixels = maxX - minX
    const heightPixels = maxY - minY

    // Convert to meters using meterPerPixel from wall image
    const meterPerPixel = wall.images[0]?.meterPerPixel || 0.01 // Default if not calibrated

    const widthMeters = widthPixels * meterPerPixel
    const heightMeters = heightPixels * meterPerPixel

    // Convert to cm and round
    const widthCm = Math.round(widthMeters * 100)
    const heightCm = Math.round(heightMeters * 100)

    return { widthCm, heightCm }
  }

  /**
   * Syncs a single wall to a survey page instance
   */
  const syncSingleWall = async (
    surveyId: string,
    wall: Wall,
    investmentId: string,
    wallsPage: SurveyPage,
    existingInstances: Record<string, any>[]
  ) => {
    // Check if an instance already exists for this wall
    const existingIndex = existingInstances.findIndex(
      instance => instance._markerWallId === wall.id
    )

    // Calculate surface areas
    const surfaceAreas = wallStore.getWallSurfaceAreas(surveyId, wall.id)

    // Prepare instance data
    const instanceData: Record<string, any> = {
      _markerWallId: wall.id, // Hidden field to track which marker wall this instance represents
      wall_name: wall.name || `${existingIndex + 1}. falfelület`,
    }

    // Sync orientation if available
    if (wall.orientation) {
      instanceData.wall_orientation = wall.orientation
    }

    // Calculate wall dimensions from surface areas if available
    if (surfaceAreas) {
      // We can derive approximate dimensions from the gross facade area
      // This is a simplified calculation - the user can refine it later
      const grossArea = surfaceAreas.facadeGrossArea

      // For now, we'll just store the areas in custom fields
      // The actual wall_length and wall_height need to be filled by user or calculated from polygons
      instanceData._facadeGrossArea = grossArea.toFixed(2)
      instanceData._facadeNetArea = surfaceAreas.facadeNetArea.toFixed(2)
      instanceData._windowDoorArea = surfaceAreas.windowDoorArea.toFixed(2)
      instanceData._wallPlinthArea = surfaceAreas.wallPlinthArea.toFixed(2)
    }

    // Update or create instance
    if (existingIndex >= 0) {
      // Update existing instance - merge with existing data to preserve manual edits
      existingInstances[existingIndex] = {
        ...existingInstances[existingIndex],
        ...instanceData,
      }
    } else {
      // Create new instance
      existingInstances.push(instanceData)
    }
  }

  /**
   * Gets the survey page instance index for a marker wall ID
   */
  const getInstanceIndexForWall = (
    surveyId: string,
    investmentId: string,
    pageId: string,
    wallId: string
  ): number => {
    const instances = surveyStore.pageInstances[surveyId]?.[investmentId]?.[pageId]?.instances || []
    return instances.findIndex(instance => instance._markerWallId === wallId)
  }

  /**
   * Gets the marker wall ID for a survey page instance
   */
  const getWallIdForInstance = (
    surveyId: string,
    investmentId: string,
    pageId: string,
    instanceIndex: number
  ): string | null => {
    const instances = surveyStore.pageInstances[surveyId]?.[investmentId]?.[pageId]?.instances || []
    const instance = instances[instanceIndex]
    return instance?._markerWallId || null
  }

  return {
    syncWallsToSurvey,
    syncSingleWall,
    getInstanceIndexForWall,
    getWallIdForInstance,
  }
}
