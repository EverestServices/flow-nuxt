-- ============================================================================
-- Migration: Fix phase power question widths
-- Description: Sets 1/3 width for phase_1_power, phase_2_power, phase_3_power
--              and clears width settings from phase_1, phase_2, phase_3
-- ============================================================================

-- Clear display_settings from phase_1, phase_2, phase_3 (these were incorrectly set)
UPDATE public.survey_questions
SET display_settings = NULL
WHERE name IN ('phase_1', 'phase_2', 'phase_3');

-- Set 1/3 width for phase power questions
UPDATE public.survey_questions
SET display_settings = jsonb_build_object('width', '1/3')
WHERE name IN ('phase_1_power', 'phase_2_power', 'phase_3_power');

-- Summary
DO $$
DECLARE
    phase_cleared_count INTEGER;
    phase_power_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO phase_cleared_count FROM public.survey_questions WHERE name IN ('phase_1', 'phase_2', 'phase_3') AND display_settings IS NULL;
    SELECT COUNT(*) INTO phase_power_count FROM public.survey_questions WHERE name IN ('phase_1_power', 'phase_2_power', 'phase_3_power') AND display_settings->>'width' = '1/3';

    RAISE NOTICE '✅ Successfully fixed phase question widths:';
    RAISE NOTICE '   - % phase questions cleared (phase_1, phase_2, phase_3)', phase_cleared_count;
    RAISE NOTICE '   - % phase power questions set to 1/3 width (phase_1_power, phase_2_power, phase_3_power)', phase_power_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Phase power questions will now appear side-by-side (3 across)';
END $$;
