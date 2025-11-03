-- ============================================================================
-- Migration: Remove Basic Data Questions
-- Description: Removes specified questions from Basic Data survey page
--              and cleans up dependent references
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    page_walls_id UUID;
    page_openings_id UUID;

    -- Question IDs to remove
    q_annual_electricity_id UUID;
    q_annual_gas_id UUID;
    q_wall_thickness_id UUID;
    q_foundation_height_id UUID;
    q_foundation_type_id UUID;
    q_protrusion_size_id UUID;
    q_reveal_depth_id UUID;
    q_roof_comments_id UUID;
    q_architectural_plans_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Get page IDs
    -- ========================================================================

    -- Get Basic Data page
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- Get Facade Insulation Walls page
    SELECT sp.id INTO page_walls_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'walls';

    -- Get Openings page
    SELECT sp.id INTO page_openings_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'openings';

    -- ========================================================================
    -- STEP 2: Get question IDs to remove
    -- ========================================================================

    SELECT id INTO q_annual_electricity_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'annual_electricity_consumption';

    SELECT id INTO q_annual_gas_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'annual_gas_consumption';

    SELECT id INTO q_wall_thickness_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'wall_thickness_uniform';

    SELECT id INTO q_foundation_height_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'foundation_height_uniform';

    SELECT id INTO q_foundation_type_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'foundation_type_uniform';

    SELECT id INTO q_protrusion_size_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'protrusion_size_uniform';

    SELECT id INTO q_reveal_depth_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'reveal_depth_uniform';

    SELECT id INTO q_roof_comments_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'roof_comments';

    SELECT id INTO q_architectural_plans_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'architectural_plans_available';

    -- ========================================================================
    -- STEP 3: Remove default_value_source_question_id references
    -- ========================================================================

    -- Update facade insulation wall questions
    IF page_walls_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET default_value_source_question_id = NULL,
            is_readonly = false
        WHERE survey_page_id = page_walls_id
          AND default_value_source_question_id IN (
              q_wall_thickness_id,
              q_foundation_height_id,
              q_foundation_type_id,
              q_protrusion_size_id
          );

        RAISE NOTICE 'Cleared default_value_source_question_id for facade insulation wall questions';
    END IF;

    -- Update openings questions
    IF page_openings_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET default_value_source_question_id = NULL,
            is_readonly = false
        WHERE survey_page_id = page_openings_id
          AND default_value_source_question_id = q_reveal_depth_id;

        RAISE NOTICE 'Cleared default_value_source_question_id for openings questions';
    END IF;

    -- ========================================================================
    -- STEP 4: Delete survey answers for these questions
    -- ========================================================================

    DELETE FROM public.survey_answers
    WHERE survey_question_id IN (
        q_annual_electricity_id,
        q_annual_gas_id,
        q_wall_thickness_id,
        q_foundation_height_id,
        q_foundation_type_id,
        q_protrusion_size_id,
        q_reveal_depth_id,
        q_roof_comments_id,
        q_architectural_plans_id
    );

    RAISE NOTICE 'Deleted survey answers for removed questions';

    -- ========================================================================
    -- STEP 5: Delete the questions
    -- ========================================================================

    DELETE FROM public.survey_questions
    WHERE id IN (
        q_annual_electricity_id,
        q_annual_gas_id,
        q_wall_thickness_id,
        q_foundation_height_id,
        q_foundation_type_id,
        q_protrusion_size_id,
        q_reveal_depth_id,
        q_roof_comments_id,
        q_architectural_plans_id
    );

    RAISE NOTICE 'Deleted questions from Basic Data page';

    -- ========================================================================
    -- STEP 6: Resequence remaining questions
    -- ========================================================================

    -- This will ensure there are no gaps in the sequence
    WITH numbered_questions AS (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY sequence) as new_sequence
        FROM public.survey_questions
        WHERE survey_page_id = page_basic_data_id
        ORDER BY sequence
    )
    UPDATE public.survey_questions sq
    SET sequence = nq.new_sequence
    FROM numbered_questions nq
    WHERE sq.id = nq.id;

    RAISE NOTICE 'Resequenced remaining questions in Basic Data page';

    RAISE NOTICE 'Successfully removed specified questions from Basic Data';

END $$;