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

    // FIX: Clean up existing instances before syncing to prevent duplicates
    // Only keep instances that have a valid _markerWallId that exists in current wallsArray
    const initialWallIds = wallsArray.map(w => w.id)
    let existingInstances = pageInstancesData.instances.filter(inst => {
      // Keep the instance if it has a _markerWallId that still exists in wallsArray
      // OR if it doesn't have a _markerWallId (manual instance not from marker mode)
      return !inst._markerWallId || initialWallIds.includes(inst._markerWallId)
    })

    // Update the page instances with cleaned data
    pageInstancesData.instances = existingInstances

    // NOTE: Do not remove walls from WallStore here. Instead, create/update page instances for all walls below.
    // This ensures drawings persist when returning to the wall list even if instances were not yet created.
    const cleanedWalls = wallStore.getWallsForSurvey(surveyId)
    const cleanedWallsArray = Object.values(cleanedWalls) as Wall[]

    // STEP 1: Sync marker mode walls -> survey instances
    for (const wall of cleanedWallsArray) {
      await syncSingleWall(surveyId, wall, facadeInvestment.id, wallsPage, existingInstances)
    }

    // STEP 2: Sync survey instances -> marker mode walls (create missing walls and sync properties)
    const cleanedWallIds = cleanedWallsArray.map(w => w.id)
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
          wall_structure: instance.wall_structure || undefined,
          wall_thickness: instance.wall_thickness || undefined,
          wall_length: instance.wall_length || undefined,
          wall_height: instance.wall_height || undefined,
          foundation_height: instance.foundation_height || undefined,
          foundation_type: instance.foundation_type || undefined,
          protrusion_size: instance.protrusion_size || undefined,
          images: [],
          polygons: []
        })

        // Link the instance to the new wall
        instance._markerWallId = newWallId
        instance.wall_name = wallName
      }
      // If instance has a marker wall ID but the wall doesn't exist, remove the instance
      else if (!cleanedWallIds.includes(instance._markerWallId)) {
        instancesToRemove.push(index)
      }
      // If instance has a marker wall ID and the wall exists, sync properties from survey to marker
      else {
        syncSurveyToWall(surveyId, instance._markerWallId, instance)
      }
    }

    // Remove in reverse order to maintain indices
    for (let i = instancesToRemove.length - 1; i >= 0; i--) {
      existingInstances.splice(instancesToRemove[i], 1)
    }

    // STEP 3: Sync windows/doors (openings) for each wall
    await syncOpeningsToSurvey(surveyId, facadeInvestment.id, wallsPage, existingInstances, cleanedWallsArray)
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
      return
    }

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
        return
      }

      const wall = walls.find(w => w.id === markerWallId)
      if (!wall) {
        return
      }

      // Get all WINDOW_DOOR polygons for this wall
      const openingPolygons = wall.polygons.filter(
        p => p.type === SurfaceType.WINDOW_DOOR && p.closed
      )

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
    })
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
   * In manual mode with edgeNotesCm, uses those values directly instead of bounding box
   */
  const calculatePolygonDimensions = (
    polygon: PolygonSurface,
    wall: Wall
  ): { widthCm: number; heightCm: number } => {
    if (polygon.points.length === 0) {
      return { widthCm: 0, heightCm: 0 }
    }

    // Check if we have manual edge notes (kézi kijelölés mode)
    // For window/door polygons, use edgeNotesCm if available
    if (polygon.edgeNotesCm?.a && polygon.edgeNotesCm?.b &&
        typeof polygon.edgeNotesCm.a === 'number' && typeof polygon.edgeNotesCm.b === 'number' &&
        polygon.edgeNotesCm.a > 0 && polygon.edgeNotesCm.b > 0) {

      // Use manual edge notes directly (already in cm, no conversion needed)
      // Note: 'b' is the bottom edge (width), 'a' is the side edge (height)
      const widthCm = Math.round(polygon.edgeNotesCm.b)  // alsó él
      const heightCm = Math.round(polygon.edgeNotesCm.a) // oldalsó él

      console.log('[calculatePolygonDimensions] Using manual edge notes:', {
        polygonId: polygon.id,
        widthCm,
        heightCm
      })

      return { widthCm, heightCm }
    }

    // Fall back to bounding box calculation for non-manual mode
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

    console.log('[calculatePolygonDimensions] Using bounding box:', {
      polygonId: polygon.id,
      widthCm,
      heightCm
    })

    return { widthCm, heightCm }
  }

  /**
   * Calculates wall dimensions (length and height) from FACADE polygons
   * Uses the same logic as calculatePolygonDimensions for consistency
   * In manual mode with edgeNotesCm, uses those values directly instead of bounding box
   * If both FACADE and WALL_PLINTH are present, adds them together for total height
   */
  const calculateWallDimensions = (wall: Wall): { length: number | null; height: number | null } => {
    // Get all FACADE type polygons
    const facadePolygons = wall.polygons.filter(
      p => p.type === SurfaceType.FACADE && p.closed && p.points.length > 0
    )

    if (facadePolygons.length === 0) {
      return { length: null, height: null }
    }

    // Check if we have manual edge notes (kézi kijelölés mode)
    // Use the first facade polygon with edge notes if available
    const manualPolygon = facadePolygons.find(p =>
      p.edgeNotesCm?.a && p.edgeNotesCm?.b &&
      typeof p.edgeNotesCm.a === 'number' && typeof p.edgeNotesCm.b === 'number' &&
      p.edgeNotesCm.a > 0 && p.edgeNotesCm.b > 0
    )

    if (manualPolygon && manualPolygon.edgeNotesCm) {
      // Use manual edge notes (convert from cm to m)
      const aCm = manualPolygon.edgeNotesCm.a!
      const bCm = manualPolygon.edgeNotesCm.b!

      // Note: 'b' is the bottom edge (length), 'a' is the side edge (facade height)
      const length = bCm / 100  // alsó él
      let height = aCm / 100     // oldalsó él

      // Check if there's a plinth (lábazat) and add its height
      const plinthHeightCm = calculateFoundationHeight(wall)
      if (plinthHeightCm !== null && plinthHeightCm > 0) {
        const plinthHeightM = plinthHeightCm / 100
        height = height + plinthHeightM

        console.log('[calculateWallDimensions] Using manual edge notes + plinth:', {
          facadeHeightCm: aCm,
          plinthHeightCm,
          totalHeightM: height
        })
      } else {
        console.log('[calculateWallDimensions] Using manual edge notes (no plinth):', {
          aCm,
          bCm,
          length,
          height
        })
      }

      // Round to 2 decimal places
      return {
        length: Math.round(length * 100) / 100,
        height: Math.round(height * 100) / 100
      }
    }

    // Fall back to bounding box calculation for non-manual mode
    // Calculate bounding box of all FACADE polygons combined
    let minX = Infinity, maxX = -Infinity
    let minY = Infinity, maxY = -Infinity

    facadePolygons.forEach(polygon => {
      polygon.points.forEach(point => {
        if (point.x < minX) minX = point.x
        if (point.x > maxX) maxX = point.x
        if (point.y < minY) minY = point.y
        if (point.y > maxY) maxY = point.y
      })
    })

    const widthUnits = maxX - minX
    const heightUnits = maxY - minY

    // Convert to meters using meterPerPixel from wall image
    const meterPerPixel = wall.images[0]?.meterPerPixel || 0.01

    // DEBUG: Log calculation details
    console.log('[calculateWallDimensions] Debug info:', {
      facadePolygonCount: facadePolygons.length,
      boundingBox: { minX, maxX, minY, maxY },
      widthUnits,
      heightUnits,
      meterPerPixel,
      imageWidth: wall.images[0]?.processedImageWidth,
      imageHeight: wall.images[0]?.processedImageHeight,
      naturalWidth: wall.images[0]?.processedImageWidth,
      samplePoints: facadePolygons[0]?.points.slice(0, 3) // First 3 points as sample
    })

    const lengthMeters = widthUnits * meterPerPixel
    let heightMeters = heightUnits * meterPerPixel

    // Check if there's a plinth (lábazat) and add its height
    const plinthHeightCm = calculateFoundationHeight(wall)
    if (plinthHeightCm !== null && plinthHeightCm > 0) {
      const plinthHeightM = plinthHeightCm / 100
      heightMeters = heightMeters + plinthHeightM

      console.log('[calculateWallDimensions] Bounding box + plinth:', {
        facadeHeightM: heightUnits * meterPerPixel,
        plinthHeightCm,
        totalHeightM: heightMeters
      })
    } else {
      console.log('[calculateWallDimensions] Bounding box (no plinth):', {
        lengthMeters,
        heightMeters
      })
    }

    // Round to 2 decimal places
    const length = Math.round(lengthMeters * 100) / 100
    const height = Math.round(heightMeters * 100) / 100

    return { length, height }
  }

  /**
   * Calculates foundation height from WALL_PLINTH polygons in cm
   * In manual mode with edgeNotesCm, uses those values directly instead of bounding box
   */
  const calculateFoundationHeight = (wall: Wall): number | null => {
    // Get all WALL_PLINTH type polygons
    const plinthPolygons = wall.polygons.filter(
      p => p.type === SurfaceType.WALL_PLINTH && p.closed && p.points.length > 0
    )

    if (plinthPolygons.length === 0) {
      return null
    }

    // Check if we have manual edge notes (kézi kijelölés mode)
    // Use the first plinth polygon with edge notes if available
    const manualPolygon = plinthPolygons.find(p =>
      p.edgeNotesCm?.a &&
      typeof p.edgeNotesCm.a === 'number' &&
      p.edgeNotesCm.a > 0
    )

    if (manualPolygon && manualPolygon.edgeNotesCm?.a) {
      // Use manual edge note directly (already in cm, no conversion needed)
      // Note: 'a' is the side edge (height)
      const heightCm = manualPolygon.edgeNotesCm.a  // oldalsó él

      console.log('[calculateFoundationHeight] Using manual edge note:', {
        heightCm
      })

      // Return rounded to integer
      return Math.round(heightCm)
    }

    // Fall back to bounding box calculation for non-manual mode
    // Convert to meters using meterPerPixel from wall image
    const meterPerPixel = wall.images[0]?.meterPerPixel || 0.01

    // Calculate the average height of all plinth polygons
    let totalHeight = 0
    let count = 0

    plinthPolygons.forEach(polygon => {
      let minY = Infinity, maxY = -Infinity

      polygon.points.forEach(point => {
        if (point.y < minY) minY = point.y
        if (point.y > maxY) maxY = point.y
      })

      const heightUnits = maxY - minY

      // Convert to meters
      const heightMeters = heightUnits * meterPerPixel

      // Convert to cm
      totalHeight += heightMeters * 100
      count++
    })

    if (count === 0) {
      return null
    }

    // Return average height rounded to integer
    return Math.round(totalHeight / count)
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

    // Sync wall structure properties from marker mode
    if (wall.wall_structure) {
      instanceData.wall_structure = wall.wall_structure

      // Get wall_structure_other from survey responses if wall_structure is "Egyéb"
      if (wall.wall_structure === 'Egyéb') {
        const existingOtherValue = surveyStore.investmentResponses[investmentId]?.['wall_structure_other']
        if (existingOtherValue) {
          instanceData.wall_structure_other = existingOtherValue
        }
      }
    }

    if (wall.wall_thickness !== undefined && wall.wall_thickness !== null) {
      instanceData.wall_thickness = wall.wall_thickness
    }

    if (wall.foundation_type) {
      instanceData.foundation_type = wall.foundation_type
    }

    if (wall.protrusion_size !== undefined && wall.protrusion_size !== null) {
      instanceData.protrusion_size = wall.protrusion_size
    }

    // Calculate and sync wall dimensions from FACADE polygons
    const facadeDimensions = calculateWallDimensions(wall)
    let needsWallUpdate = false
    const wallUpdates: Partial<Wall> = {}

    if (facadeDimensions.length !== null) {
      instanceData.wall_length = facadeDimensions.length
      wallUpdates.wall_length = facadeDimensions.length
      needsWallUpdate = true
    }
    if (facadeDimensions.height !== null) {
      instanceData.wall_height = facadeDimensions.height
      wallUpdates.wall_height = facadeDimensions.height
      needsWallUpdate = true
    }

    // Calculate and sync foundation height from WALL_PLINTH polygons
    const foundationHeight = calculateFoundationHeight(wall)
    if (foundationHeight !== null) {
      instanceData.foundation_height = foundationHeight
      wallUpdates.foundation_height = foundationHeight
      needsWallUpdate = true
    }

    // Update the wall model with calculated values
    if (needsWallUpdate) {
      wallStore.setWall(surveyId, wall.id, { ...wall, ...wallUpdates })
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
   * Syncs survey instance properties back to marker mode wall
   */
  const syncSurveyToWall = (
    surveyId: string,
    wallId: string,
    instance: Record<string, any>
  ) => {
    const walls = wallStore.getWallsForSurvey(surveyId)
    const wall = walls[wallId]

    if (!wall) {
      return
    }

    // Prepare wall updates from survey instance
    const wallUpdates: Partial<Wall> = {
      ...wall
    }

    // Sync basic properties
    if (instance.wall_name && instance.wall_name !== wall.name) {
      wallUpdates.name = instance.wall_name
    }

    if (instance.wall_orientation && instance.wall_orientation !== wall.orientation) {
      wallUpdates.orientation = instance.wall_orientation
    }

    // Sync wall structure properties
    if (instance.wall_structure !== undefined && instance.wall_structure !== wall.wall_structure) {
      wallUpdates.wall_structure = instance.wall_structure || undefined
    }

    if (instance.wall_thickness !== undefined && instance.wall_thickness !== wall.wall_thickness) {
      wallUpdates.wall_thickness = instance.wall_thickness || undefined
    }

    if (instance.foundation_type !== undefined && instance.foundation_type !== wall.foundation_type) {
      wallUpdates.foundation_type = instance.foundation_type || undefined
    }

    if (instance.protrusion_size !== undefined && instance.protrusion_size !== wall.protrusion_size) {
      wallUpdates.protrusion_size = instance.protrusion_size || undefined
    }

    // Note: wall_length, wall_height, and foundation_height are calculated from polygons,
    // so we don't sync them back from survey to marker (marker mode is the source of truth for these)

    // Update the wall if there are changes
    wallStore.setWall(surveyId, wallId, wallUpdates)
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
