-- ============================================================================
-- Migration: Add Additional Basic Data Questions
-- Description: Adds additional questions to the Basic Data investment survey page
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
BEGIN
    -- Get the Basic Data survey page ID
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- Add New Survey Questions
    -- ========================================================================

    -- 26. Éves elektromos fogyasztás (kWh)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'annual_electricity_consumption',
        jsonb_build_object(
            'hu', 'Éves elektromos fogyasztás (kWh)',
            'en', 'Annual Electricity Consumption (kWh)'
        ),
        'number',
        false,
        'kWh',
        jsonb_build_object('hu', 'kWh', 'en', 'kWh'),
        'Éves fogyasztás',
        jsonb_build_object('hu', 'Éves fogyasztás', 'en', 'Annual Consumption'),
        26
    );

    -- 27. Éves gázfogyasztás (m³)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'annual_gas_consumption',
        jsonb_build_object(
            'hu', 'Éves gázfogyasztás (m³)',
            'en', 'Annual Gas Consumption (m³)'
        ),
        'number',
        false,
        'm³',
        jsonb_build_object('hu', 'm³', 'en', 'm³'),
        'Éves fogyasztás',
        jsonb_build_object('hu', 'Éves fogyasztás', 'en', 'Annual Consumption'),
        27
    );

    -- 28. Hány fázis áll rendelkezésre?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_basic_data_id,
        'available_phases',
        jsonb_build_object(
            'hu', 'Hány fázis áll rendelkezésre?',
            'en', 'How Many Phases Are Available?'
        ),
        'dropdown',
        false,
        jsonb_build_array('1', '3'),
        28
    );

    -- 29. Építészeti tervdokumentáció rendelkezésre áll
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'architectural_plans_available',
        jsonb_build_object(
            'hu', 'Építészeti tervdokumentáció rendelkezésre áll',
            'en', 'Architectural Plans Available'
        ),
        'switch',
        false,
        'false',
        29
    );

    -- 30. Épület hasznos alapterülete (m²)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'building_useful_floor_area',
        jsonb_build_object(
            'hu', 'Épület hasznos alapterülete (m²)',
            'en', 'Building Useful Floor Area (m²)'
        ),
        'number',
        false,
        'm²',
        jsonb_build_object('hu', 'm²', 'en', 'm²'),
        'Alapterület',
        jsonb_build_object('hu', 'Alapterület', 'en', 'Floor Area'),
        30
    );

    RAISE NOTICE 'Successfully added additional Basic Data questions';

END $$;
