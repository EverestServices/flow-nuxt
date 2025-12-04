-- Migration: Add visibility column to main_components table
-- Description: Adds a JSONB column to control component visibility based on survey type (OFP vs non-OFP)
-- Date: 2025-11-20

-- ============================================================================
-- 1. ADD VISIBILITY COLUMN
-- ============================================================================

ALTER TABLE public.main_components
ADD COLUMN IF NOT EXISTS visibility JSONB DEFAULT NULL;

COMMENT ON COLUMN public.main_components.visibility IS 'Visibility rules for this component. Example: {"ofp_survey": false} means hidden for OFP surveys';

-- ============================================================================
-- 2. SET VISIBILITY FOR OFP-EXCLUDED COMPONENTS
-- ============================================================================

-- Facade Insulation: Hide detailed components for OFP surveys (use facade_system instead)
UPDATE public.main_components
SET visibility = '{"ofp_survey": false}'::jsonb
WHERE persist_name IN (
  'insulation-eps-80',
  'insulation-eps-100',
  'insulation-graphite-eps-80',
  'insulation-graphite-eps-100',
  'insulation-mineral-wool-80',
  'insulation-mineral-wool-100'
)
AND main_component_category_id IN (
  SELECT id FROM public.main_component_categories WHERE persist_name = 'insulation'
)
AND EXISTS (
  SELECT 1 FROM public.main_component_category_investments mcci
  JOIN public.investments i ON mcci.investment_id = i.id
  WHERE mcci.main_component_category_id = main_components.main_component_category_id
  AND i.name = 'Facade Insulation'
);

-- Adhesive components for Facade Insulation
UPDATE public.main_components
SET visibility = '{"ofp_survey": false}'::jsonb
WHERE main_component_category_id IN (
  SELECT id FROM public.main_component_categories WHERE persist_name = 'adhesive'
)
AND EXISTS (
  SELECT 1 FROM public.main_component_category_investments mcci
  JOIN public.investments i ON mcci.investment_id = i.id
  WHERE mcci.main_component_category_id = main_components.main_component_category_id
  AND i.name = 'Facade Insulation'
);

-- Plaster components for Facade Insulation
UPDATE public.main_components
SET visibility = '{"ofp_survey": false}'::jsonb
WHERE main_component_category_id IN (
  SELECT id FROM public.main_component_categories WHERE persist_name = 'plaster'
)
AND EXISTS (
  SELECT 1 FROM public.main_component_category_investments mcci
  JOIN public.investments i ON mcci.investment_id = i.id
  WHERE mcci.main_component_category_id = main_components.main_component_category_id
  AND i.name = 'Facade Insulation'
);

-- Attic/Roof Insulation: Hide insulation and vapor barrier for OFP surveys (use roof_system instead)
UPDATE public.main_components
SET visibility = '{"ofp_survey": false}'::jsonb
WHERE main_component_category_id IN (
  SELECT id FROM public.main_component_categories WHERE persist_name IN ('insulation', 'vapor_barrier')
)
AND EXISTS (
  SELECT 1 FROM public.main_component_category_investments mcci
  JOIN public.investments i ON mcci.investment_id = i.id
  WHERE mcci.main_component_category_id = main_components.main_component_category_id
  AND i.name = 'Attic Insulation'
);

-- ============================================================================
-- 3. VERIFICATION QUERY (commented out - uncomment to check results)
-- ============================================================================

-- SELECT
--   mc.name,
--   mc.persist_name,
--   mcc.persist_name as category,
--   i.name as investment,
--   mc.visibility
-- FROM public.main_components mc
-- JOIN public.main_component_categories mcc ON mc.main_component_category_id = mcc.id
-- JOIN public.main_component_category_investments mcci ON mcc.id = mcci.main_component_category_id
-- JOIN public.investments i ON mcci.investment_id = i.id
-- WHERE mc.visibility IS NOT NULL
-- ORDER BY i.name, mcc.persist_name, mc.name;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
