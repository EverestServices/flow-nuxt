-- ============================================================================
-- Migration: Add Conditional Info Messages Feature
-- Description: Adds conditional_info_messages column to survey_questions table
--              and configures danger messages for defect-related questions
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    q_structural_damage_id UUID;
    q_moisture_damage_id UUID;
    q_water_damage_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Add conditional_info_messages column to survey_questions
    -- ========================================================================

    ALTER TABLE public.survey_questions
    ADD COLUMN IF NOT EXISTS conditional_info_messages JSONB DEFAULT NULL;

    RAISE NOTICE 'Added conditional_info_messages column to survey_questions table';

    -- ========================================================================
    -- STEP 2: Get Facade Insulation page and question IDs
    -- ========================================================================

    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get facade_basic_data page ID
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data page not found';
    END IF;

    -- Get question IDs
    SELECT id INTO q_structural_damage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'structural_damage_visible';

    SELECT id INTO q_moisture_damage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'moisture_damage_visible';

    SELECT id INTO q_water_damage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'water_damage_visible';

    IF q_structural_damage_id IS NULL THEN
        RAISE EXCEPTION 'structural_damage_visible question not found';
    END IF;

    IF q_moisture_damage_id IS NULL THEN
        RAISE EXCEPTION 'moisture_damage_visible question not found';
    END IF;

    IF q_water_damage_id IS NULL THEN
        RAISE EXCEPTION 'water_damage_visible question not found';
    END IF;

    -- ========================================================================
    -- STEP 3: Add conditional info messages to defect questions
    -- ========================================================================

    -- structural_damage_visible (Tartószerkezeti kárkép látható-e)
    UPDATE public.survey_questions
    SET conditional_info_messages = jsonb_build_array(
        jsonb_build_object(
            'condition', jsonb_build_object(
                'field', 'self',
                'operator', 'equals',
                'value', 'true'
            ),
            'type', 'danger',
            'message_translations', jsonb_build_object(
                'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
            )
        )
    )
    WHERE id = q_structural_damage_id;

    RAISE NOTICE 'Added conditional info message to structural_damage_visible';

    -- moisture_damage_visible (Felszívódó nedvesség okozta kárkép látható-e)
    UPDATE public.survey_questions
    SET conditional_info_messages = jsonb_build_array(
        jsonb_build_object(
            'condition', jsonb_build_object(
                'field', 'self',
                'operator', 'equals',
                'value', 'true'
            ),
            'type', 'danger',
            'message_translations', jsonb_build_object(
                'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
            )
        )
    )
    WHERE id = q_moisture_damage_id;

    RAISE NOTICE 'Added conditional info message to moisture_damage_visible';

    -- water_damage_visible (Ázás kárkép látható-e)
    UPDATE public.survey_questions
    SET conditional_info_messages = jsonb_build_array(
        jsonb_build_object(
            'condition', jsonb_build_object(
                'field', 'self',
                'operator', 'equals',
                'value', 'true'
            ),
            'type', 'danger',
            'message_translations', jsonb_build_object(
                'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
            )
        )
    )
    WHERE id = q_water_damage_id;

    RAISE NOTICE 'Added conditional info message to water_damage_visible';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully added conditional info messages feature:';
    RAISE NOTICE '   - Added conditional_info_messages JSONB column to survey_questions';
    RAISE NOTICE '   - Configured danger messages for 3 defect questions:';
    RAISE NOTICE '     • Tartószerkezeti kárkép látható-e';
    RAISE NOTICE '     • Felszívódó nedvesség okozta kárkép látható-e';
    RAISE NOTICE '     • Ázás kárkép látható-e';
    RAISE NOTICE '';
    RAISE NOTICE 'When these switches are checked (true), a danger icon with tooltip will appear';
    RAISE NOTICE 'Message: "Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását';
    RAISE NOTICE '          megszünették, kijavították, addig nem folytatható a projekt!"';

END $$;
