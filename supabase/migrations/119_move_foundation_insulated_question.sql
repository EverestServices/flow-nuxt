-- ============================================================================
-- Migration: Move Foundation Insulated Question
-- Description: Removes "Lábazat hőszigetelt" from Walls page and adds
--              "A lábazat hőszigetelt-e?" to Facade Insulation Basic Data page
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    page_basic_data_id UUID;
    q_foundation_insulated_id UUID;
    max_sequence INTEGER;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Walls page ID
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    -- Get Basic Data page ID
    SELECT id INTO page_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls survey page not found';
    END IF;

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Delete "Lábazat hőszigetelt" question from Walls page
    -- ========================================================================

    -- Get the question ID
    SELECT id INTO q_foundation_insulated_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'foundation_insulated';

    IF q_foundation_insulated_id IS NOT NULL THEN
        -- Delete related survey answers
        DELETE FROM public.survey_answers
        WHERE survey_question_id = q_foundation_insulated_id;

        -- Delete the question
        DELETE FROM public.survey_questions
        WHERE id = q_foundation_insulated_id;

        RAISE NOTICE 'Deleted "Lábazat hőszigetelt" question from Walls page';
    END IF;

    -- Also delete dependent questions (existing_insulation_material, existing_insulation_material_other, existing_insulation_thickness)
    DELETE FROM public.survey_answers
    WHERE survey_question_id IN (
        SELECT id FROM public.survey_questions
        WHERE survey_page_id = page_walls_id
          AND name IN ('existing_insulation_material', 'existing_insulation_material_other', 'existing_insulation_thickness')
    );

    DELETE FROM public.survey_questions
    WHERE survey_page_id = page_walls_id
      AND name IN ('existing_insulation_material', 'existing_insulation_material_other', 'existing_insulation_thickness');

    RAISE NOTICE 'Deleted dependent insulation questions from Walls page';

    -- ========================================================================
    -- STEP 2: Add new question to Basic Data page
    -- ========================================================================

    -- Get the maximum sequence number from Basic Data page
    SELECT COALESCE(MAX(sequence), 0) INTO max_sequence
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id;

    -- Insert the new question at the end
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'foundation_insulated_general',
        jsonb_build_object(
            'hu', 'A lábazat hőszigetelt-e?',
            'en', 'Is the foundation insulated?'
        ),
        'switch',
        false,
        'false',
        max_sequence + 1
    );

    RAISE NOTICE 'Added "A lábazat hőszigetelt-e?" question to Basic Data page at sequence %', max_sequence + 1;

    RAISE NOTICE 'Successfully moved foundation insulated question';

END $$;
