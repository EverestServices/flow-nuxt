-- Migration: Add visibility column to main_component_categories table
-- Description: Adds a JSONB column to control category visibility based on survey type and investment
-- Date: 2025-11-20

-- ============================================================================
-- 1. ADD VISIBILITY COLUMN TO CATEGORIES
-- ============================================================================

ALTER TABLE public.main_component_categories
ADD COLUMN IF NOT EXISTS visibility JSONB DEFAULT NULL;

COMMENT ON COLUMN public.main_component_categories.visibility IS 'Visibility rules for this category. Can include survey_type and investment_id filters. Example: {"ofp_survey": {"facadeInsulation": false}}';

-- ============================================================================
-- 2. SET VISIBILITY FOR OFP-EXCLUDED CATEGORIES
-- ============================================================================

-- Hide insulation category for OFP Facade Insulation (use facade_system instead)
UPDATE public.main_component_categories
SET visibility = jsonb_build_object(
  'ofp_survey', jsonb_build_object(
    'facadeInsulation', false,
    'roofInsulation', false
  )
)
WHERE persist_name = 'insulation';

-- Hide adhesive category for OFP Facade Insulation
UPDATE public.main_component_categories
SET visibility = jsonb_build_object(
  'ofp_survey', jsonb_build_object(
    'facadeInsulation', false
  )
)
WHERE persist_name = 'adhesive';

-- Hide plaster category for OFP Facade Insulation
UPDATE public.main_component_categories
SET visibility = jsonb_build_object(
  'ofp_survey', jsonb_build_object(
    'facadeInsulation', false
  )
)
WHERE persist_name = 'plaster';

-- Hide vapor_barrier category for OFP Roof/Attic Insulation
UPDATE public.main_component_categories
SET visibility = jsonb_build_object(
  'ofp_survey', jsonb_build_object(
    'roofInsulation', false
  )
)
WHERE persist_name = 'vapor_barrier';

-- ============================================================================
-- 3. VERIFICATION QUERY (uncomment to check)
-- ============================================================================

-- SELECT
--   mcc.persist_name,
--   mcc.visibility
-- FROM public.main_component_categories mcc
-- WHERE mcc.visibility IS NOT NULL;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
