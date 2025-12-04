-- ============================================================================
-- Migration: Convert available_phases to icon_selector type
-- Description: Updates available_phases questions from phase_toggle to icon_selector
--              with appropriate icons for 1 and 3 phase options
--
-- Icons used:
--   1 phase: i-lucide-minus (single horizontal line)
--   3 phase: i-lucide-menu (three horizontal lines)
-- ============================================================================

-- Update all available_phases questions to icon_selector type with icons
UPDATE public.survey_questions
SET
  type = 'icon_selector',
  options_translations = jsonb_build_array(
    jsonb_build_object(
      'value', '1',
      'label', jsonb_build_object('hu', '1 fázis', 'en', '1 phase'),
      'icon', 'i-lucide-minus'
    ),
    jsonb_build_object(
      'value', '3',
      'label', jsonb_build_object('hu', '3 fázis', 'en', '3 phase'),
      'icon', 'i-lucide-menu'
    )
  )
WHERE name = 'available_phases'
  AND type = 'phase_toggle';

-- Summary
DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count
    FROM public.survey_questions
    WHERE name = 'available_phases'
      AND type = 'icon_selector';

    RAISE NOTICE '✅ Successfully converted available_phases questions to icon_selector:';
    RAISE NOTICE '   - % question(s) updated', updated_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Icons assigned:';
    RAISE NOTICE '   - 1 phase: i-lucide-minus (single line)';
    RAISE NOTICE '   - 3 phase: i-lucide-menu (three lines)';
END $$;
