-- ============================================================================
-- Migration: Update window_door_type options and add glazing_type question
-- Description:
--   1. Updates "Nyílászárók típusa" dropdown options with new list
--   2. Adds new "Üvegezés típusa" dropdown question below it
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    window_door_type_sequence INTEGER;
    new_glazing_type_id UUID;
BEGIN
    -- Get Basic Data page from Basic Data investment
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Update window_door_type dropdown options
    -- ========================================================================

    UPDATE public.survey_questions
    SET options_translations = jsonb_build_array(
        jsonb_build_object(
            'value', 'Korszerű műanyag',
            'label', jsonb_build_object('hu', 'Korszerű műanyag', 'en', 'Modern Plastic')
        ),
        jsonb_build_object(
            'value', 'Korszerű fa',
            'label', jsonb_build_object('hu', 'Korszerű fa', 'en', 'Modern Wood')
        ),
        jsonb_build_object(
            'value', 'Korszerű fém',
            'label', jsonb_build_object('hu', 'Korszerű fém', 'en', 'Modern Metal')
        ),
        jsonb_build_object(
            'value', 'Kapcsolt-gerébtokos fa',
            'label', jsonb_build_object('hu', 'Kapcsolt-gerébtokos fa', 'en', 'Connected Casement Wood')
        ),
        jsonb_build_object(
            'value', 'Gerébtokos fa',
            'label', jsonb_build_object('hu', 'Gerébtokos fa', 'en', 'Casement Wood')
        ),
        jsonb_build_object(
            'value', 'Egyesített szárnyú fa (Teschauer)',
            'label', jsonb_build_object('hu', 'Egyesített szárnyú fa (Teschauer)', 'en', 'Unified Wing Wood (Teschauer)')
        ),
        jsonb_build_object(
            'value', 'Hőhidas fém',
            'label', jsonb_build_object('hu', 'Hőhidas fém', 'en', 'Thermal Bridge Metal')
        ),
        jsonb_build_object(
            'value', 'Tetősík ablak',
            'label', jsonb_build_object('hu', 'Tetősík ablak', 'en', 'Roof Window')
        )
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'window_door_type';

    RAISE NOTICE 'Updated window_door_type options (8 options)';

    -- ========================================================================
    -- STEP 2: Get sequence number for window_door_type
    -- ========================================================================

    SELECT sequence INTO window_door_type_sequence
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id
      AND name = 'window_door_type';

    IF window_door_type_sequence IS NULL THEN
        RAISE EXCEPTION 'window_door_type question not found';
    END IF;

    RAISE NOTICE 'window_door_type is at sequence: %', window_door_type_sequence;

    -- ========================================================================
    -- STEP 3: Shift all questions after window_door_type by 1 position
    -- ========================================================================

    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_basic_data_id
      AND sequence > window_door_type_sequence;

    RAISE NOTICE 'Shifted questions after window_door_type by 1 position';

    -- ========================================================================
    -- STEP 4: Insert new "Üvegezés típusa" question
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        is_special,
        options_translations,
        sequence
    )
    VALUES (
        page_basic_data_id,
        'glazing_type',
        jsonb_build_object(
            'hu', 'Üvegezés típusa',
            'en', 'Glazing Type'
        ),
        'dropdown',
        false,
        false,
        jsonb_build_array(
            jsonb_build_object(
                'value', '1 rétegű síküvegezés',
                'label', jsonb_build_object('hu', '1 rétegű síküvegezés', 'en', '1 layer flat glazing')
            ),
            jsonb_build_object(
                'value', '2 rétegű üvegezés',
                'label', jsonb_build_object('hu', '2 rétegű üvegezés', 'en', '2 layer glazing')
            ),
            jsonb_build_object(
                'value', '2 rétegű hőszigetelő',
                'label', jsonb_build_object('hu', '2 rétegű hőszigetelő', 'en', '2 layer insulating')
            ),
            jsonb_build_object(
                'value', '3 rétegű hőszigetelő',
                'label', jsonb_build_object('hu', '3 rétegű hőszigetelő', 'en', '3 layer insulating')
            )
        ),
        window_door_type_sequence + 1
    )
    RETURNING id INTO new_glazing_type_id;

    RAISE NOTICE 'Added new glazing_type question at sequence: %', window_door_type_sequence + 1;
    RAISE NOTICE 'New question ID: %', new_glazing_type_id;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Migration completed successfully!';
    RAISE NOTICE '';
    RAISE NOTICE 'Updated "Nyílászárók típusa" (window_door_type) with 8 options:';
    RAISE NOTICE '   1. Korszerű műanyag';
    RAISE NOTICE '   2. Korszerű fa';
    RAISE NOTICE '   3. Korszerű fém';
    RAISE NOTICE '   4. Kapcsolt-gerébtokos fa';
    RAISE NOTICE '   5. Gerébtokos fa';
    RAISE NOTICE '   6. Egyesített szárnyú fa (Teschauer)';
    RAISE NOTICE '   7. Hőhidas fém';
    RAISE NOTICE '   8. Tetősík ablak';
    RAISE NOTICE '';
    RAISE NOTICE 'Added new "Üvegezés típusa" (glazing_type) with 4 options:';
    RAISE NOTICE '   1. 1 rétegű síküvegezés';
    RAISE NOTICE '   2. 2 rétegű üvegezés';
    RAISE NOTICE '   3. 2 rétegű hőszigetelő';
    RAISE NOTICE '   4. 3 rétegű hőszigetelő';

END $$;
