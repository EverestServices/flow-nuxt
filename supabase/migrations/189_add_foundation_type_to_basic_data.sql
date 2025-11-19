-- ============================================================================
-- Migration: Add Foundation Type to Facade Basic Data
-- Description: Adds "Lábazat típusa" question to Facade Basic Data page
--              at sequence 6 and links it to the Walls page foundation_type
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    page_walls_id UUID;
    q_foundation_type_basic_id UUID;
    q_foundation_type_walls_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get page IDs
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data page not found';
    END IF;

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Shift existing questions to make room at sequence 6
    -- ========================================================================

    -- Move questions with sequence >= 6 up by 1
    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_facade_basic_data_id
      AND sequence >= 6;

    RAISE NOTICE 'Shifted questions with sequence >= 6 up by 1';

    -- ========================================================================
    -- STEP 2: Insert new foundation_type question at sequence 6
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options_translations, sequence, info_message_translations
    ) VALUES (
        page_facade_basic_data_id,
        'foundation_type',
        jsonb_build_object('hu', 'Lábazat típusa', 'en', 'Foundation Type'),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object(
                'value', 'Pozitív',
                'label', jsonb_build_object('hu', 'Pozitív', 'en', 'Positive')
            ),
            jsonb_build_object(
                'value', 'Negatív',
                'label', jsonb_build_object('hu', 'Negatív', 'en', 'Negative')
            )
        ),
        6,
        jsonb_build_object(
            'hu', 'Pozitív ha a homlokzati falsíktól kintebb áll, negatív ha mögötte van.',
            'en', 'Positive if it protrudes from the facade plane, negative if it is recessed.'
        )
    )
    RETURNING id INTO q_foundation_type_basic_id;

    RAISE NOTICE 'Created foundation_type question at sequence 6 with id: %', q_foundation_type_basic_id;

    -- ========================================================================
    -- STEP 3: Link Walls page foundation_type to inherit value
    -- ========================================================================

    -- Get the foundation_type question on Walls page
    SELECT id INTO q_foundation_type_walls_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'foundation_type';

    IF q_foundation_type_walls_id IS NOT NULL THEN
        -- Set default_value_source to the new basic data question
        UPDATE public.survey_questions
        SET default_value_source_question_id = q_foundation_type_basic_id
        WHERE id = q_foundation_type_walls_id;

        RAISE NOTICE 'Linked Walls page foundation_type to inherit from Basic Data question';
    ELSE
        RAISE NOTICE 'foundation_type question not found on Walls page, skipping link';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully added foundation_type to Facade Basic Data:';
    RAISE NOTICE '   - Shifted existing questions (sequence >= 6) up by 1';
    RAISE NOTICE '   - Created foundation_type at sequence 6';
    RAISE NOTICE '   - Options: Pozitív, Negatív';
    RAISE NOTICE '   - Info message: "Pozitív ha a homlokzati falsíktól kintebb áll..."';
    IF q_foundation_type_walls_id IS NOT NULL THEN
        RAISE NOTICE '   - Linked to Walls page foundation_type (inherits value)';
    END IF;

END $$;
