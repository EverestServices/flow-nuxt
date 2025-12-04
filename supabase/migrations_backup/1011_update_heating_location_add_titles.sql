-- ============================================================================
-- Migration: Update Heating Device Location Options and Add Title Questions
-- Description: Updates heating_device_location options and adds two title questions
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    question_heating_device_location_id UUID;
BEGIN
    -- Get Basic Data page ID
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'basicData'
    AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data page not found';
    END IF;

    -- ========================================================================
    -- 1. Update heating_device_location options
    -- ========================================================================

    -- Get the heating_device_location question ID
    SELECT id INTO question_heating_device_location_id
    FROM public.survey_questions
    WHERE name = 'heating_device_location';

    IF question_heating_device_location_id IS NULL THEN
        RAISE EXCEPTION 'heating_device_location question not found';
    END IF;

    -- Update the options
    UPDATE public.survey_questions
    SET options = jsonb_build_array(
        'konyha, fürdőszoba, mosókonyha, egyéb fűtött tér',
        'külső kazánház, fűtetlen pince, fűtetlen padlás, egyéb fűtetlen tér'
    )
    WHERE id = question_heating_device_location_id;

    RAISE NOTICE 'Updated heating_device_location options';

    -- ========================================================================
    -- 2. Add wood fuel consumption title
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_basic_data_id,
        'wood_fuel_consumption_title',
        jsonb_build_object(
            'hu', 'Tűzifa fogyasztás',
            'en', 'Wood fuel consumption'
        ),
        'title',
        false,
        28
    );

    RAISE NOTICE 'Added wood_fuel_consumption_title question';

    -- ========================================================================
    -- 3. Add district heating consumption title
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_basic_data_id,
        'district_heating_consumption_title',
        jsonb_build_object(
            'hu', 'Származtatott hő / Távhő fogyasztás',
            'en', 'District / Derived heat consumption'
        ),
        'title',
        false,
        28
    );

    RAISE NOTICE 'Added district_heating_consumption_title question';

END $$;
