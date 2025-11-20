-- ============================================================================
-- Migration: Add "Fal típusa" question to Facade Insulation Basic Data page
-- Description: Adds a new "Fal típusa" dropdown question before "Fal vastagsága"
--              with the same options as the "Fal típusa" on Basic Data page
-- ============================================================================

DO $$
DECLARE
    page_facade_basic_data_id UUID;
    basic_data_wall_type_options JSONB;
BEGIN
    -- Get Facade Insulation Basic Data page ID
    SELECT sp.id INTO page_facade_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation Basic Data page not found';
    END IF;

    -- Get the options from the Basic Data page's "Fal típusa" question
    SELECT sq.options INTO basic_data_wall_type_options
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData'
      AND sp.type = 'basic_data'
      AND sq.name = 'exterior_wall_structure';

    IF basic_data_wall_type_options IS NULL THEN
        RAISE EXCEPTION 'exterior_wall_structure question not found on Basic Data page';
    END IF;

    RAISE NOTICE 'Found wall type options: %', basic_data_wall_type_options;

    -- ========================================================================
    -- STEP 1: Shift all questions at sequence >= 3 by +1
    -- (wall_thickness_avg is currently at sequence 3 based on migration 139)
    -- ========================================================================

    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_facade_basic_data_id
      AND sequence >= 3;

    RAISE NOTICE 'Shifted questions at sequence >= 3 by +1';

    -- ========================================================================
    -- STEP 2: Insert new "Fal típusa" question at sequence 3
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        sequence
    ) VALUES (
        page_facade_basic_data_id,
        'wall_structure',
        jsonb_build_object(
            'hu', 'Fal típusa',
            'en', 'Wall Type'
        ),
        'dropdown',
        false,
        basic_data_wall_type_options,
        3
    );

    RAISE NOTICE 'Successfully added "Fal típusa" question at sequence 3';
    RAISE NOTICE 'Question name: wall_structure';
    RAISE NOTICE '"Fal vastagsága" (wall_thickness_avg) is now at sequence 4';

END $$;
