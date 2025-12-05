-- ============================================================================
-- Migration: Add Scaffold Required Question
-- Description: Adds "Homlokzati állvány szükséges" question after
--              "Munkaterület adottságai" title and makes
--              "Homlokzatok állványozhatók" conditional on it
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    q_facades_scaffoldable_id UUID;
BEGIN
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

    -- Get facades_scaffoldable question ID
    SELECT id INTO q_facades_scaffoldable_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'facades_scaffoldable';

    IF q_facades_scaffoldable_id IS NULL THEN
        RAISE EXCEPTION 'facades_scaffoldable question not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Shift all questions from sequence 2 onwards up by 1
    -- ========================================================================

    -- After migration 164, the sequences are:
    -- 1: site_conditions_title
    -- 2: facades_scaffoldable
    -- 3-22: other questions
    -- We shift 2-22 to 3-23 to make room for the new question at 2

    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_facade_basic_data_id
      AND sequence >= 2;

    RAISE NOTICE 'Shifted questions from sequence 2 onwards up by 1';

    -- ========================================================================
    -- STEP 2: Insert "Homlokzati állvány szükséges" at sequence 2
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value, info_message_translations
    ) VALUES (
        page_facade_basic_data_id,
        'scaffold_required',
        jsonb_build_object(
            'hu', 'Homlokzati állvány szükséges',
            'en', 'Facade Scaffolding Required'
        ),
        'switch',
        false,
        2,
        'false',
        jsonb_build_object(
            'hu', 'Ha az eresz magasabb mint 3,5 m a csatlakozó járdától, vagy lejtős terepen áll a ház, esetleg oromfalas az épület (a véghomlokzatok a tetőgerincig tartanak) ott homlokzati állvány szükséges.',
            'en', 'If the eaves are higher than 3.5 m from the adjacent pavement, or the house is on sloping terrain, or the building has gable walls (the end facades extend to the roof ridge), facade scaffolding is required.'
        )
    );

    RAISE NOTICE 'Inserted "Homlokzati állvány szükséges" at sequence 2';

    -- ========================================================================
    -- STEP 3: Add display condition to facades_scaffoldable
    -- ========================================================================

    -- facades_scaffoldable is now at sequence 3 (was 2, shifted up by 1)
    -- Add display condition: show only when scaffold_required = true

    UPDATE public.survey_questions
    SET display_conditions = jsonb_build_object(
        'field', 'scaffold_required',
        'operator', 'equals',
        'value', 'true'
    )
    WHERE id = q_facades_scaffoldable_id;

    RAISE NOTICE 'Added display condition to "Homlokzatok állványozhatók"';
    RAISE NOTICE '  Shows only when "Homlokzati állvány szükséges" is checked';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully added scaffold required question:';
    RAISE NOTICE '   Sequence 1: Munkaterület adottságai (title)';
    RAISE NOTICE '   Sequence 2: Homlokzati állvány szükséges (switch) - NEW';
    RAISE NOTICE '   Sequence 3: Homlokzatok állványozhatók (switch) - now conditional';
    RAISE NOTICE '   Sequences 4-6: Other site condition questions';
    RAISE NOTICE '   Sequences 7-23: Rest of the page';
    RAISE NOTICE '';
    RAISE NOTICE 'Display condition: "Homlokzatok állványozhatók" shows only when';
    RAISE NOTICE '                   "Homlokzati állvány szükséges" is checked (true)';

END $$;
