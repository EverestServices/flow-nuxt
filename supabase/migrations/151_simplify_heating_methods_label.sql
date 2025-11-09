-- ============================================================================
-- Migration: Simplify heating methods question label
-- Description: Removes "(többet is kiválaszthat) *" from the question title
--              Old: "Meglévő fűtésrendszer hőtermelői (többet is kiválaszthat) *"
--              New: "Meglévő fűtésrendszer hőtermelői"
-- ============================================================================

-- Update the heating_methods question label
UPDATE public.survey_questions
SET name_translations = jsonb_build_object(
  'hu', 'Meglévő fűtésrendszer hőtermelői',
  'en', 'Existing heating system heat generators'
)
WHERE name = 'heating_methods';

-- Summary
DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count
    FROM public.survey_questions
    WHERE name = 'heating_methods'
      AND name_translations->>'hu' = 'Meglévő fűtésrendszer hőtermelői';

    RAISE NOTICE '✅ Successfully updated heating methods question label:';
    RAISE NOTICE '   - % question(s) updated', updated_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Old label: "Meglévő fűtésrendszer hőtermelői (többet is kiválaszthat) *"';
    RAISE NOTICE 'New label: "Meglévő fűtésrendszer hőtermelői"';
END $$;
