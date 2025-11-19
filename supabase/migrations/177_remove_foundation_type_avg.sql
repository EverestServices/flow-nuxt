-- ============================================================================
-- Migration: Remove foundation_type_avg Question
-- Description: Removes "Lábazat típusa" question from Facade Basic Data page
--              and cleans up all dependencies:
--              - Removes conditional copy rules that use this question
--              - Removes default_value_source references from dependent questions
--              - Removes is_readonly flag from dependent questions
--              - Deletes all survey answers for this question
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    page_walls_id UUID;
    q_foundation_type_avg_id UUID;
    q_foundation_type_walls_id UUID;
    deleted_rules_count INTEGER;
    deleted_answers_count INTEGER;
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

    -- Get question IDs
    SELECT id INTO q_foundation_type_avg_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_type_avg';

    SELECT id INTO q_foundation_type_walls_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'foundation_type';

    IF q_foundation_type_avg_id IS NULL THEN
        RAISE NOTICE 'foundation_type_avg question not found, nothing to remove';
        RETURN;
    END IF;

    RAISE NOTICE 'Found foundation_type_avg question: %', q_foundation_type_avg_id;

    -- ========================================================================
    -- STEP 1: Remove conditional copy rules that use this question
    -- ========================================================================

    WITH deleted AS (
        DELETE FROM public.survey_value_copy_rules
        WHERE source_question_id = q_foundation_type_avg_id
           OR target_question_id = q_foundation_type_avg_id
           OR condition_question_id = q_foundation_type_avg_id
        RETURNING *
    )
    SELECT COUNT(*) INTO deleted_rules_count FROM deleted;

    RAISE NOTICE 'Deleted % conditional copy rules', deleted_rules_count;

    -- ========================================================================
    -- STEP 2: Remove default_value_source and is_readonly from dependent questions
    -- ========================================================================

    IF q_foundation_type_walls_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET
            default_value_source_question_id = NULL,
            is_readonly = false
        WHERE id = q_foundation_type_walls_id
          AND default_value_source_question_id = q_foundation_type_avg_id;

        RAISE NOTICE 'Updated foundation_type question on Walls page: removed default_value_source and is_readonly';
    END IF;

    -- Also check for any other questions that might reference this as default_value_source
    UPDATE public.survey_questions
    SET
        default_value_source_question_id = NULL,
        is_readonly = false
    WHERE default_value_source_question_id = q_foundation_type_avg_id;

    -- ========================================================================
    -- STEP 3: Delete all survey answers for this question
    -- ========================================================================

    WITH deleted AS (
        DELETE FROM public.survey_answers
        WHERE survey_question_id = q_foundation_type_avg_id
        RETURNING *
    )
    SELECT COUNT(*) INTO deleted_answers_count FROM deleted;

    RAISE NOTICE 'Deleted % survey answers', deleted_answers_count;

    -- ========================================================================
    -- STEP 4: Shift sequence numbers for questions after foundation_type_avg
    -- ========================================================================

    -- foundation_type_avg is at sequence 6, so shift all questions with sequence > 6 down by 1
    UPDATE public.survey_questions
    SET sequence = sequence - 1
    WHERE survey_page_id = page_facade_basic_data_id
      AND sequence > 6;

    RAISE NOTICE 'Shifted sequence numbers for questions after foundation_type_avg';

    -- ========================================================================
    -- STEP 5: Delete the question itself
    -- ========================================================================

    DELETE FROM public.survey_questions
    WHERE id = q_foundation_type_avg_id;

    RAISE NOTICE 'Deleted foundation_type_avg question';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully removed foundation_type_avg question';
    RAISE NOTICE '   - Deleted % conditional copy rules', deleted_rules_count;
    RAISE NOTICE '   - Deleted % survey answers', deleted_answers_count;
    RAISE NOTICE '   - Updated dependent questions (removed default_value_source and is_readonly)';
    RAISE NOTICE '   - Shifted sequence numbers for subsequent questions';
    RAISE NOTICE '   - Deleted the question itself';

END $$;
