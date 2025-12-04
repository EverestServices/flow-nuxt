-- ============================================================================
-- Migration: Fix facade insulation display conditions
-- Description: Updates display conditions for facade insulation material and
--              thickness questions to use the new "Szigetelt" value instead of "true"
--
-- Background: When facade_insulated was converted to icon_selector type,
--             its values changed from "true"/"false" to "Szigetelt"/"Nem szigetelt"
--             but the dependent questions' display_conditions were not updated
-- ============================================================================

-- Update facade_insulation_material display condition
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
  'field', 'facade_insulated',
  'operator', 'equals',
  'value', 'Szigetelt'
)
WHERE name = 'facade_insulation_material';

-- Update facade_insulation_thickness display condition
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
  'field', 'facade_insulated',
  'operator', 'equals',
  'value', 'Szigetelt'
)
WHERE name = 'facade_insulation_thickness';

-- Summary
DO $$
DECLARE
    material_count INTEGER;
    thickness_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO material_count
    FROM public.survey_questions
    WHERE name = 'facade_insulation_material'
      AND display_conditions->>'value' = 'Szigetelt';

    SELECT COUNT(*) INTO thickness_count
    FROM public.survey_questions
    WHERE name = 'facade_insulation_thickness'
      AND display_conditions->>'value' = 'Szigetelt';

    RAISE NOTICE '✅ Successfully fixed facade insulation display conditions:';
    RAISE NOTICE '   - % facade_insulation_material question(s) updated', material_count;
    RAISE NOTICE '   - % facade_insulation_thickness question(s) updated', thickness_count;
    RAISE NOTICE '';
    RAISE NOTICE 'These questions will now appear when facade_insulated = "Szigetelt"';
    RAISE NOTICE 'Old condition: facade_insulated = "true"';
    RAISE NOTICE 'New condition: facade_insulated = "Szigetelt"';
END $$;
