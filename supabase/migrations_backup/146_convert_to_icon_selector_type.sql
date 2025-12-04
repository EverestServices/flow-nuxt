-- ============================================================================
-- Migration: Convert insulation questions to icon_selector type
-- Description: Updates facade_insulated and slab_insulated questions to use
--              the new icon_selector type with custom icons for each option
-- ============================================================================

-- Update "Homlokzat hőszigetelt?" question to icon_selector type
UPDATE public.survey_questions
SET
  type = 'icon_selector',
  options_translations = jsonb_build_array(
    jsonb_build_object(
      'value', 'Szigetelt',
      'label', jsonb_build_object('hu', 'Szigetelt', 'en', 'Insulated'),
      'icon', 'i-lucide-shield-check'
    ),
    jsonb_build_object(
      'value', 'Nem szigetelt',
      'label', jsonb_build_object('hu', 'Nem szigetelt', 'en', 'Not Insulated'),
      'icon', 'i-lucide-shield-off'
    )
  )
WHERE name = 'facade_insulated';

-- Update "Zárófödém hőszigetelt?" question to icon_selector type
UPDATE public.survey_questions
SET
  type = 'icon_selector',
  options_translations = jsonb_build_array(
    jsonb_build_object(
      'value', 'true',
      'label', jsonb_build_object('hu', 'Szigetelt', 'en', 'Insulated'),
      'icon', 'i-lucide-shield-check'
    ),
    jsonb_build_object(
      'value', 'false',
      'label', jsonb_build_object('hu', 'Nem szigetelt', 'en', 'Not Insulated'),
      'icon', 'i-lucide-shield-off'
    )
  )
WHERE name = 'slab_insulated';

-- Summary
DO $$
DECLARE
    facade_count INTEGER;
    slab_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO facade_count FROM public.survey_questions WHERE name = 'facade_insulated' AND type = 'icon_selector';
    SELECT COUNT(*) INTO slab_count FROM public.survey_questions WHERE name = 'slab_insulated' AND type = 'icon_selector';

    RAISE NOTICE '✅ Successfully converted questions to icon_selector type:';
    RAISE NOTICE '   - % "Homlokzat hőszigetelt?" question(s) updated', facade_count;
    RAISE NOTICE '   - % "Zárófödém hőszigetelt?" question(s) updated', slab_count;
    RAISE NOTICE '';
    RAISE NOTICE 'ℹ️  Each question now displays:';
    RAISE NOTICE '   - "Szigetelt" with shield-check icon';
    RAISE NOTICE '   - "Nem szigetelt" with shield-off icon';
END $$;
