import type { PolygonSurface, Point, Wall } from '@/model/Measure/ArucoWallSurface'

/**
 * useMeasure (Aruco) Composable
 * - Persists Aruco results (images + polygons) per Survey to Supabase
 * - Uploads images to the `measure-images` bucket under /<companyId>/<surveyId>/<wallId>/...
 * - Follows RLS pattern used elsewhere (company via surveys)
 */
export const useMeasure = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const loading = ref(false)
  const error = ref<string | null>(null)

  const getCompanyId = async (): Promise<string | null> => {
    if (!user.value) return null
    const { data } = await supabase
      .from('user_profiles')
      .select('company_id')
      .eq('user_id', user.value.id)
      .single()
    return (data as any)?.company_id || null
  }

  // --- Storage helpers
  const bucket = 'measure-images'
  const buildPath = (companyId: string, surveyId: string, wallId: string, kind: 'original' | 'processed', fileName: string) => {
    const safe = fileName.replace(/[^a-zA-Z0-9._-]/g, '_')
    return `${companyId}/${surveyId}/${wallId}/${kind}/${Date.now()}_${safe}`
  }

  const uploadImage = async (file: File, companyId: string, surveyId: string, wallId: string, kind: 'original' | 'processed') => {
    const path = buildPath(companyId, surveyId, wallId, kind, file.name)
    const { error: upErr } = await supabase.storage.from(bucket).upload(path, file, { upsert: true, contentType: file.type })
    if (upErr) throw upErr
    const { data: pub } = supabase.storage.from(bucket).getPublicUrl(path)
    return { path, publicUrl: pub.publicUrl as string }
  }

  // --- DB blob helpers
  const fileToBase64 = (file: Blob): Promise<string> =>
    new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => {
        const res = reader.result as string
        const base64 = res.startsWith('data:') ? (res.split(',')[1] || '') : (res || '')
        resolve(base64)
      }
      reader.onerror = () => reject(reader.error)
      reader.readAsDataURL(file)
    })

  const blobToBase64 = (blob: Blob): Promise<string> => fileToBase64(blob)

  const setOriginalImageBlob = async (imageId: string, file: File) => {
    const base64 = await fileToBase64(file)
    const { error } = await supabase.rpc('measure_set_original_image', {
      p_image_id: imageId,
      p_base64: base64,
      p_mime: file.type || 'application/octet-stream',
      p_name: file.name || 'original'
    })
    if (error) throw error
    return true
  }

  const setProcessedImageBlob = async (imageId: string, blob: Blob, name: string) => {
    const base64 = await blobToBase64(blob)
    const { error } = await supabase.rpc('measure_set_processed_image', {
      p_image_id: imageId,
      p_base64: base64,
      p_mime: (blob as any).type || 'image/png',
      p_name: name || 'processed'
    })
    if (error) throw error
    return true
  }

  const getImageDataUrl = async (imageId: string, kind: 'original' | 'processed'): Promise<string | null> => {
    const { data, error } = await supabase.rpc('measure_get_image', {
      p_image_id: imageId,
      p_kind: kind
    })
    if (error) throw error
    const row = Array.isArray(data) ? data[0] : data
    if (!row || !row.content_base64 || !row.mime) return null
    return `data:${row.mime};base64,${row.content_base64}`
  }

  // --- DB helpers
  const createWall = async (surveyId: string, name: string) => {
    const { data, error: err } = await supabase
      .from('measure_walls')
      .insert({ survey_id: surveyId, name })
      .select()
      .single()
    if (err) throw err
    return data as { id: string, survey_id: string, name: string }
  }

  const insertWallImage = async (wallId: string, payload: {
    originalUrl?: string | null,
    processedUrl?: string | null,
    meterPerPixel?: number | null,
    processedImageWidth?: number | null,
    processedImageHeight?: number | null,
    referenceStart?: Point | null,
    referenceEnd?: Point | null,
    referenceLengthCm?: number | null,
  }) => {
    const { data, error: err } = await supabase
      .from('measure_wall_images')
      .insert({
        wall_id: wallId,
        original_url: payload.originalUrl ?? null,
        processed_url: payload.processedUrl ?? null,
        meter_per_pixel: payload.meterPerPixel ?? null,
        processed_image_width: payload.processedImageWidth ?? null,
        processed_image_height: payload.processedImageHeight ?? null,
        reference_start: payload.referenceStart ?? null,
        reference_end: payload.referenceEnd ?? null,
        reference_length_cm: payload.referenceLengthCm ?? null,
      })
      .select()
      .single()
    if (err) throw err
    return data as { id: string }
  }

  const updateWallImage = async (imageId: string, payload: {
    processedUrl?: string | null,
    meterPerPixel?: number | null,
    processedImageWidth?: number | null,
    processedImageHeight?: number | null,
    referenceStart?: Point | null,
    referenceEnd?: Point | null,
    referenceLengthCm?: number | null,
    manual?: boolean | null,
    manualShapes?: any[] | null,
  }) => {
    const updates: Record<string, any> = {}
    if ('processedUrl' in payload) updates.processed_url = payload.processedUrl
    if ('meterPerPixel' in payload) updates.meter_per_pixel = payload.meterPerPixel
    if ('processedImageWidth' in payload) updates.processed_image_width = payload.processedImageWidth
    if ('processedImageHeight' in payload) updates.processed_image_height = payload.processedImageHeight
    if ('referenceStart' in payload) updates.reference_start = payload.referenceStart
    if ('referenceEnd' in payload) updates.reference_end = payload.referenceEnd
    if ('referenceLengthCm' in payload) updates.reference_length_cm = payload.referenceLengthCm
    if ('manual' in payload) updates.manual = payload.manual
    if ('manualShapes' in payload) updates.manual_shapes = payload.manualShapes

    const { error } = await supabase
      .from('measure_wall_images')
      .update(updates)
      .eq('id', imageId)
    if (error) throw error
    return true
  }

  const getManualShapes = async (imageId: string): Promise<any[]> => {
    const { data, error } = await supabase
      .from('measure_wall_images')
      .select('manual_shapes')
      .eq('id', imageId)
      .single()
    if (error) throw error
    return ((data as any)?.manual_shapes ?? []) as any[]
  }

  const setManualShapes = async (imageId: string, shapes: any[]) => {
    await updateWallImage(imageId, { manualShapes: shapes })
    return true
  }

  const appendManualShape = async (imageId: string, shape: any) => {
    const current = await getManualShapes(imageId)
    const next = [...current, shape]
    await updateWallImage(imageId, { manualShapes: next })
    return true
  }

  const pathFromPublicUrl = (url?: string | null): string | null => {
    if (!url) return null
    try {
      const marker = '/storage/v1/object/public/' + bucket + '/'
      const idx = url.indexOf(marker)
      if (idx >= 0) return url.substring(idx + marker.length)
      const marker2 = '/object/public/' + bucket + '/'
      const idx2 = url.indexOf(marker2)
      if (idx2 >= 0) return url.substring(idx2 + marker2.length)
      return null
    } catch {
      return null
    }
  }

  const deleteWallImage = async (imageId: string) => {
    const { data, error: selErr } = await supabase
      .from('measure_wall_images')
      .select('original_url, processed_url')
      .eq('id', imageId)
      .single()
    if (selErr) throw selErr
    const paths: string[] = []
    const o = pathFromPublicUrl((data as any)?.original_url)
    const p = pathFromPublicUrl((data as any)?.processed_url)
    if (o) paths.push(o)
    if (p) paths.push(p)
    if (paths.length) {
      await supabase.storage.from(bucket).remove(paths)
    }
    const { error: delErr } = await supabase.from('measure_wall_images').delete().eq('id', imageId)
    if (delErr) throw delErr
    return true
  }

  const listWallImagesByWallId = async (wallId: string) => {
    const { data, error } = await supabase
      .from('measure_wall_images')
      .select('id, original_url, processed_url')
      .eq('wall_id', wallId)
    if (error) throw error
    return (data ?? []) as Array<{ id: string, original_url: string | null, processed_url: string | null }>
  }

  const deleteWallDeep = async (wallId: string) => {
    const images = await listWallImagesByWallId(wallId)
    const paths: string[] = []
    for (const img of images) {
      const o = pathFromPublicUrl(img.original_url)
      const p = pathFromPublicUrl(img.processed_url)
      if (o) paths.push(o)
      if (p) paths.push(p)
    }
    if (paths.length) {
      await supabase.storage.from(bucket).remove(paths)
    }
    const { error } = await supabase.from('measure_walls').delete().eq('id', wallId)
    if (error) throw error
    return true
  }

  const replaceWallPolygons = async (wallId: string, polygons: PolygonSurface[]) => {
    // Delete existing then bulk insert
    const { error: delErr } = await supabase.from('measure_polygons').delete().eq('wall_id', wallId)
    if (delErr) throw delErr
    if (!polygons || polygons.length === 0) return true
    const rows = polygons.map(p => ({
      wall_id: wallId,
      type: p.type ?? null,
      sub_type: p.subType ?? null,
      external_shading: p.externalShading ?? null,
      name: p.name ?? null,
      visible: p.visible !== false,
      closed: p.closed === true,
      points: p.points,
      edge_notes_cm: (p as any).edgeNotesCm ?? null,
      edge_notes_rect: (p as any).edgeNotesRect ?? null,
      edge_notes_norm: (p as any).edgeNotesNorm ?? null,
      area_override_m2: (p as any).areaOverrideM2 ?? null,
    }))
    const { error: insErr } = await supabase.from('measure_polygons').insert(rows)
    if (insErr) throw insErr
    return true
  }

  const updatePolygonEdgeNotes = async (
    polygonId: string,
    notesCm: { a?: number | null; b?: number | null } | null,
    rect: Point[] | null,
    norm?: Point[] | null,
    areaOverrideM2?: number | null,
  ) => {
    const updates: Record<string, any> = {}
    updates.edge_notes_cm = notesCm ?? null
    updates.edge_notes_rect = rect ?? null
    if (typeof norm !== 'undefined') updates.edge_notes_norm = norm
    if (typeof areaOverrideM2 !== 'undefined') updates.area_override_m2 = areaOverrideM2
    const { error } = await supabase
      .from('measure_polygons')
      .update(updates)
      .eq('id', polygonId)
    if (error) throw error
    return true
  }

  const fetchWallsBySurvey = async (surveyId: string) => {
    const { data, error: err } = await supabase
      .from('measure_walls')
      .select(`
        *,
        images:measure_wall_images(*),
        polygons:measure_polygons(*)
      `)
      .eq('survey_id', surveyId)
      .order('created_at', { ascending: true })
    if (err) {
      console.error('❌ Error fetching walls:', err)
      throw err
    }
    console.log('✅ Successfully fetched walls, count:', data?.length)
    return (data ?? []) as Array<any>
  }

  const deleteWall = async (wallId: string) => {
    const { error: err } = await supabase.from('measure_walls').delete().eq('id', wallId)
    if (err) throw err
    return true
  }

  // --- Orchestrator: save everything from one pass
  /**
   * Saves an Aruco measurement result once for a survey
   * - Creates a wall
   * - Uploads images (original/processed) if provided
   * - Inserts image metadata
   * - Replaces polygons
   */
  const saveArucoResult = async (opts: {
    surveyId: string,
    wallName: string,
    originalFile?: File | null,
    processedFile?: File | null,
    imageMeta?: {
      meterPerPixel?: number | null,
      processedImageWidth?: number | null,
      processedImageHeight?: number | null,
      referenceStart?: Point | null,
      referenceEnd?: Point | null,
      referenceLengthCm?: number | null,
    },
    polygons?: PolygonSurface[]
  }) => {
    loading.value = true
    error.value = null
    try {
      const companyId = await getCompanyId()
      if (!companyId) throw new Error('Company ID not found')

      const wall = await createWall(opts.surveyId, opts.wallName)

      let originalUrl: string | undefined
      let processedUrl: string | undefined

      if (opts.originalFile) {
        const up = await uploadImage(opts.originalFile, companyId, opts.surveyId, wall.id, 'original')
        originalUrl = up.publicUrl
      }
      if (opts.processedFile) {
        const up = await uploadImage(opts.processedFile, companyId, opts.surveyId, wall.id, 'processed')
        processedUrl = up.publicUrl
      }

      await insertWallImage(wall.id, {
        originalUrl,
        processedUrl,
        meterPerPixel: opts.imageMeta?.meterPerPixel ?? null,
        processedImageWidth: opts.imageMeta?.processedImageWidth ?? null,
        processedImageHeight: opts.imageMeta?.processedImageHeight ?? null,
        referenceStart: opts.imageMeta?.referenceStart ?? null,
        referenceEnd: opts.imageMeta?.referenceEnd ?? null,
        referenceLengthCm: opts.imageMeta?.referenceLengthCm ?? null,
      })

      if (opts.polygons) {
        await replaceWallPolygons(wall.id, opts.polygons)
      }

      return wall
    } catch (e: any) {
      error.value = e.message || String(e)
      console.error('[useMeasure] saveArucoResult error:', e)
      return null
    } finally {
      loading.value = false
    }
  }

  return {
    // state
    loading: readonly(loading),
    error: readonly(error),

    // storage
    uploadImage,

    // walls/images/polygons
    createWall,
    insertWallImage,
    updateWallImage,
    getManualShapes,
    setManualShapes,
    appendManualShape,
    deleteWallImage,
    setOriginalImageBlob,
    setProcessedImageBlob,
    getImageDataUrl,
    listWallImagesByWallId,
    deleteWallDeep,
    replaceWallPolygons,
    updatePolygonEdgeNotes,
    fetchWallsBySurvey,
    deleteWall,

    // orchestration
    saveArucoResult,
  }
}
