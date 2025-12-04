-- ============================================================================
-- Migration: Set display_settings widths for specific questions
-- Description: Configures grid layout widths for questions that should appear side-by-side
--
-- Width mappings:
--   - "1/3" = 33% width (4 columns in a 12-column grid)
--   - "1/2" = 50% width (6 columns in a 12-column grid)
-- ============================================================================

-- Set 1/3 width for Phase questions (Fázis 1, Fázis 2, Fázis 3)
UPDATE public.survey_questions
SET display_settings = jsonb_build_object('width', '1/3')
WHERE name IN ('phase_1', 'phase_2', 'phase_3');

-- Set 1/2 width for consumption period/unit pairs
UPDATE public.survey_questions
SET display_settings = jsonb_build_object('width', '1/2')
WHERE name IN (
  'electricity_period',
  'electricity_unit',
  'gas_period',
  'gas_unit',
  'wood_fuel_consumption_period',
  'wood_fuel_consumption_unit',
  'district_heating_consumption_period',
  'district_heating_consumption_unit'
);

-- Summary
DO $$
DECLARE
    phase_count INTEGER;
    consumption_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO phase_count FROM public.survey_questions WHERE name IN ('phase_1', 'phase_2', 'phase_3');
    SELECT COUNT(*) INTO consumption_count FROM public.survey_questions WHERE name IN (
        'electricity_period', 'electricity_unit', 'gas_period', 'gas_unit',
        'wood_fuel_consumption_period', 'wood_fuel_consumption_unit',
        'district_heating_consumption_period', 'district_heating_consumption_unit'
    );

    RAISE NOTICE '✅ Successfully set display widths:';
    RAISE NOTICE '   - % phase questions set to 1/3 width', phase_count;
    RAISE NOTICE '   - % consumption period/unit questions set to 1/2 width', consumption_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Questions will now appear side-by-side in a grid layout';
END $$;
