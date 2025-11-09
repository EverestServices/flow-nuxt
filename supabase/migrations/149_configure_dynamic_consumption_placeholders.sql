-- ============================================================================
-- Migration: Configure dynamic consumption placeholders
-- Description: Sets up template-based placeholders for consumption questions
--              that dynamically update based on period and unit selections
-- ============================================================================

-- Configure electricity_consumption
UPDATE public.survey_questions
SET
  apply_template_to_placeholder = true,
  template_variables = jsonb_build_object(
    'unit', jsonb_build_object('type', 'field_value', 'field', 'electricity_unit'),
    'period', jsonb_build_object('type', 'field_value', 'field', 'electricity_period')
  ),
  placeholder_translations = jsonb_build_object(
    'hu', 'Fogyasztás ({unit}/{period})',
    'en', 'Consumption ({unit}/{period})'
  )
WHERE name = 'electricity_consumption';

-- Configure gas_consumption
UPDATE public.survey_questions
SET
  apply_template_to_placeholder = true,
  template_variables = jsonb_build_object(
    'unit', jsonb_build_object('type', 'field_value', 'field', 'gas_unit'),
    'period', jsonb_build_object('type', 'field_value', 'field', 'gas_period')
  ),
  placeholder_translations = jsonb_build_object(
    'hu', 'Fogyasztás ({unit}/{period})',
    'en', 'Consumption ({unit}/{period})'
  )
WHERE name = 'gas_consumption';

-- Configure district_heating_consumption_amount
UPDATE public.survey_questions
SET
  apply_template_to_placeholder = true,
  template_variables = jsonb_build_object(
    'unit', jsonb_build_object('type', 'field_value', 'field', 'district_heating_consumption_unit'),
    'period', jsonb_build_object('type', 'field_value', 'field', 'district_heating_consumption_period')
  ),
  placeholder_translations = jsonb_build_object(
    'hu', 'Fogyasztás ({unit}/{period})',
    'en', 'Consumption ({unit}/{period})'
  )
WHERE name = 'district_heating_consumption_amount';

-- Configure wood_fuel_consumption_amount
UPDATE public.survey_questions
SET
  apply_template_to_placeholder = true,
  template_variables = jsonb_build_object(
    'unit', jsonb_build_object('type', 'field_value', 'field', 'wood_fuel_consumption_unit'),
    'period', jsonb_build_object('type', 'field_value', 'field', 'wood_fuel_consumption_period')
  ),
  placeholder_translations = jsonb_build_object(
    'hu', 'Fogyasztás ({unit}/{period})',
    'en', 'Consumption ({unit}/{period})'
  )
WHERE name = 'wood_fuel_consumption_amount';

-- Summary
DO $$
DECLARE
    electricity_count INTEGER;
    gas_count INTEGER;
    district_heating_count INTEGER;
    wood_fuel_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO electricity_count FROM public.survey_questions WHERE name = 'electricity_consumption' AND apply_template_to_placeholder = true;
    SELECT COUNT(*) INTO gas_count FROM public.survey_questions WHERE name = 'gas_consumption' AND apply_template_to_placeholder = true;
    SELECT COUNT(*) INTO district_heating_count FROM public.survey_questions WHERE name = 'district_heating_consumption_amount' AND apply_template_to_placeholder = true;
    SELECT COUNT(*) INTO wood_fuel_count FROM public.survey_questions WHERE name = 'wood_fuel_consumption_amount' AND apply_template_to_placeholder = true;

    RAISE NOTICE '✅ Successfully configured dynamic placeholders:';
    RAISE NOTICE '   - % electricity_consumption question(s)', electricity_count;
    RAISE NOTICE '   - % gas_consumption question(s)', gas_count;
    RAISE NOTICE '   - % district_heating_consumption_amount question(s)', district_heating_count;
    RAISE NOTICE '   - % wood_fuel_consumption_amount question(s)', wood_fuel_count;
    RAISE NOTICE '';
    RAISE NOTICE 'ℹ️  Placeholders will now dynamically show: "Fogyasztás ({unit}/{period})"';
    RAISE NOTICE '   Example: If unit=kWh and period=év, placeholder will be "Fogyasztás (kWh/év)"';
END $$;
