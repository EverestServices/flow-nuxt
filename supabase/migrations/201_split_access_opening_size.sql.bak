-- ============================================================================
-- Migration: Split Access Opening Size Question
-- Description: Replaces "Feljáró tiszta nyílásmérete (cm×cm)" with two
--              separate questions for width and height, displayed side-by-side
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_site_conditions_id UUID;
    q_access_opening_size_id UUID;
    original_sequence INTEGER;
    deleted_answers_count INTEGER;
BEGIN
    -- Get Padlásfödém szigetelés investment ID
    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Padlásfödém szigetelés investment not found';
    END IF;

    -- Get Munkaterület adottságai page ID
    SELECT id INTO page_site_conditions_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id AND type = 'site_conditions';

    IF page_site_conditions_id IS NULL THEN
        RAISE EXCEPTION 'Munkaterület adottságai page not found';
    END IF;

    -- Get the original question ID and sequence
    SELECT id, sequence INTO q_access_opening_size_id, original_sequence
    FROM public.survey_questions
    WHERE survey_page_id = page_site_conditions_id AND name = 'access_opening_size';

    IF q_access_opening_size_id IS NULL THEN
        RAISE EXCEPTION 'access_opening_size question not found';
    END IF;

    RAISE NOTICE 'Found access_opening_size question at sequence %', original_sequence;

    -- ========================================================================
    -- STEP 1: Shift questions after the original question up by 1
    -- ========================================================================

    -- Since we're replacing 1 question with 2 questions, we need to make room
    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_site_conditions_id
      AND sequence > original_sequence;

    RAISE NOTICE 'Shifted sequence numbers for questions after position %', original_sequence;

    -- ========================================================================
    -- STEP 2: Delete the original question and its answers
    -- ========================================================================

    -- Delete all survey answers for this question
    WITH deleted AS (
        DELETE FROM public.survey_answers
        WHERE survey_question_id = q_access_opening_size_id
        RETURNING *
    )
    SELECT COUNT(*) INTO deleted_answers_count FROM deleted;

    RAISE NOTICE 'Deleted % survey answers for access_opening_size question', deleted_answers_count;

    -- Delete the question itself
    DELETE FROM public.survey_questions
    WHERE id = q_access_opening_size_id;

    RAISE NOTICE 'Deleted access_opening_size question';

    -- ========================================================================
    -- STEP 3: Create two new questions at the original position
    -- ========================================================================

    -- Create width question at original_sequence
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        unit, unit_translations, placeholder_value, placeholder_translations,
        display_settings
    ) VALUES (
        page_site_conditions_id,
        'access_opening_width',
        jsonb_build_object(
            'hu', 'Feljáró tiszta nyílásméretének szélessége (cm)',
            'en', 'Access Opening Clear Width (cm)'
        ),
        'number',
        false,
        original_sequence,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Szélesség',
        jsonb_build_object('hu', 'Szélesség', 'en', 'Width'),
        jsonb_build_object('width', '1/2')
    );

    RAISE NOTICE 'Created access_opening_width question at sequence %', original_sequence;

    -- Create height question at original_sequence + 1
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        unit, unit_translations, placeholder_value, placeholder_translations,
        display_settings
    ) VALUES (
        page_site_conditions_id,
        'access_opening_height',
        jsonb_build_object(
            'hu', 'Feljáró tiszta nyílásméretének magassága (cm)',
            'en', 'Access Opening Clear Height (cm)'
        ),
        'number',
        false,
        original_sequence + 1,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Magasság',
        jsonb_build_object('hu', 'Magasság', 'en', 'Height'),
        jsonb_build_object('width', '1/2')
    );

    RAISE NOTICE 'Created access_opening_height question at sequence %', original_sequence + 1;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully split access opening size question:';
    RAISE NOTICE '   Deleted: "Feljáró tiszta nyílásmérete (cm×cm)"';
    RAISE NOTICE '   Created:';
    RAISE NOTICE '     - Sequence %: Feljáró tiszta nyílásméretének szélessége (width: 1/2)', original_sequence;
    RAISE NOTICE '     - Sequence %: Feljáró tiszta nyílásméretének magassága (width: 1/2)', original_sequence + 1;
    RAISE NOTICE '   Deleted % survey answers', deleted_answers_count;
    RAISE NOTICE '   Both questions will appear side-by-side with 50%% width each';

END $$;
