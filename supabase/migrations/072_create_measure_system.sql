-- ============================================================================
-- Migration: Measure (Aruco) System
-- Description: Creates tables and policies to persist Aruco results, images and
--              wall surfaces per survey. Adds a storage bucket for images.
-- ============================================================================

-- 1) ENUMS
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'measure_surface_type') THEN
    CREATE TYPE measure_surface_type AS ENUM ('wallPlinth','facade','windowDoor');
  END IF;
END $$;

-- 2) TABLES
CREATE TABLE IF NOT EXISTS public.measure_walls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
  name TEXT
);

CREATE TABLE IF NOT EXISTS public.measure_wall_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  wall_id UUID NOT NULL REFERENCES public.measure_walls(id) ON DELETE CASCADE,
  original_url TEXT,               -- storage path or public URL
  processed_url TEXT,              -- processed image URL/path
  meter_per_pixel NUMERIC,         -- m/px
  processed_image_width INTEGER,
  processed_image_height INTEGER,
  reference_start JSONB,           -- { x, y } normalized
  reference_end JSONB,             -- { x, y } normalized
  reference_length_cm NUMERIC
);

CREATE TABLE IF NOT EXISTS public.measure_polygons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  wall_id UUID NOT NULL REFERENCES public.measure_walls(id) ON DELETE CASCADE,
  type measure_surface_type,
  name TEXT,
  visible BOOLEAN DEFAULT TRUE,
  closed BOOLEAN DEFAULT TRUE,
  points JSONB NOT NULL            -- [{ x, y }, ...] normalized
);

-- 3) TRIGGERS
CREATE TRIGGER update_measure_walls_updated_at
  BEFORE UPDATE ON public.measure_walls
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measure_wall_images_updated_at
  BEFORE UPDATE ON public.measure_wall_images
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measure_polygons_updated_at
  BEFORE UPDATE ON public.measure_polygons
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4) INDEXES
CREATE INDEX IF NOT EXISTS idx_measure_walls_survey_id ON public.measure_walls(survey_id);
CREATE INDEX IF NOT EXISTS idx_measure_images_wall_id ON public.measure_wall_images(wall_id);
CREATE INDEX IF NOT EXISTS idx_measure_polygons_wall_id ON public.measure_polygons(wall_id);

-- 5) RLS
ALTER TABLE public.measure_walls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measure_wall_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measure_polygons ENABLE ROW LEVEL SECURITY;

-- measure_walls policies (by company via surveys)
CREATE POLICY IF NOT EXISTS "Measure: select walls by company"
  ON public.measure_walls FOR SELECT
  USING (
    survey_id IN (
      SELECT id FROM public.surveys
      WHERE company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );
CREATE POLICY IF NOT EXISTS "Measure: manage walls by company"
  ON public.measure_walls FOR ALL
  USING (
    survey_id IN (
      SELECT id FROM public.surveys
      WHERE company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  ) WITH CHECK (
    survey_id IN (
      SELECT id FROM public.surveys
      WHERE company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );

-- measure_wall_images policies (inherit via wall -> survey)
CREATE POLICY IF NOT EXISTS "Measure: select images by company"
  ON public.measure_wall_images FOR SELECT
  USING (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );
CREATE POLICY IF NOT EXISTS "Measure: manage images by company"
  ON public.measure_wall_images FOR ALL
  USING (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  ) WITH CHECK (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );

-- measure_polygons policies (inherit via wall -> survey)
CREATE POLICY IF NOT EXISTS "Measure: select polygons by company"
  ON public.measure_polygons FOR SELECT
  USING (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );
CREATE POLICY IF NOT EXISTS "Measure: manage polygons by company"
  ON public.measure_polygons FOR ALL
  USING (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  ) WITH CHECK (
    wall_id IN (
      SELECT mw.id FROM public.measure_walls mw
      JOIN public.surveys s ON s.id = mw.survey_id
      WHERE s.company_id IN (SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid())
    )
  );

-- 6) GRANTS
GRANT ALL ON public.measure_walls TO authenticated;
GRANT ALL ON public.measure_wall_images TO authenticated;
GRANT ALL ON public.measure_polygons TO authenticated;

-- 7) STORAGE BUCKET for measure images
-- Drop policies & bucket if previously existed (idempotent)
DROP POLICY IF EXISTS "Measure: authenticated upload" ON storage.objects;
DROP POLICY IF EXISTS "Measure: public read" ON storage.objects;
DROP POLICY IF EXISTS "Measure: manage company images" ON storage.objects;
DELETE FROM storage.buckets WHERE id = 'measure-images';

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'measure-images',
  'measure-images',
  true,
  52428800, -- 50MB
  ARRAY['image/jpeg','image/png','image/webp']::text[]
);

-- Upload policy: users upload under /<companyId>/<surveyId>/**
CREATE POLICY "Measure: authenticated upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'measure-images'
  AND auth.uid() IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.user_id = auth.uid()
      AND (storage.foldername(name))[1] = up.company_id::text
  )
);

-- Read policy: public read
CREATE POLICY "Measure: public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'measure-images');

-- Manage policy: users can manage their company folder
CREATE POLICY "Measure: manage company images"
ON storage.objects FOR ALL
USING (
  bucket_id = 'measure-images'
  AND EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.user_id = auth.uid()
      AND (storage.foldername(name))[1] = up.company_id::text
  )
);
