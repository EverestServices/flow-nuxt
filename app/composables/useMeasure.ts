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
    }))
    const { error: insErr } = await supabase.from('measure_polygons').insert(rows)
    if (insErr) throw insErr
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
    if (err) throw err
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
    replaceWallPolygons,
    fetchWallsBySurvey,
    deleteWall,

    // orchestration
    saveArucoResult,
  }
}
