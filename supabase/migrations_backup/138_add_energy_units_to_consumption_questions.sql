-- ============================================================================
-- Migration: Add Energy Units to Consumption Questions
-- Description: Adds MJ, GJ, kWh units to gas_unit and electricity_unit questions
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Adding Energy Units to Consumption Questions';
    RAISE NOTICE '========================================';

    -- Get Basic Data page for Alapadatok investment
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.name = 'Alapadatok'
      AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    RAISE NOTICE 'Found Alapadatok page: %', page_basic_data_id;

    -- ========================================================================
    -- Update gas_unit question - Add MJ, GJ, kWh options
    -- ========================================================================

    UPDATE public.survey_questions
    SET options = jsonb_build_array('m³', 'Ft', 'MJ', 'GJ', 'kWh')
    WHERE survey_page_id = page_basic_data_id
      AND name = 'gas_unit';

    RAISE NOTICE 'Updated gas_unit options: m³, Ft, MJ, GJ, kWh';

    -- ========================================================================
    -- Update electricity_unit question - Add MJ, GJ options
    -- ========================================================================

    UPDATE public.survey_questions
    SET options = jsonb_build_array('kWh', 'Ft', 'MJ', 'GJ')
    WHERE survey_page_id = page_basic_data_id
      AND name = 'electricity_unit';

    RAISE NOTICE 'Updated electricity_unit options: kWh, Ft, MJ, GJ';

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Energy Units Added Successfully!';
    RAISE NOTICE '========================================';

END $$;
