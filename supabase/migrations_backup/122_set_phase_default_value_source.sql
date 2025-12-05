-- ============================================================================
-- Migration: Set Phase Default Value Source
-- Description: Sets default_value_source_question_id for Phase 2 and Phase 3
--              to automatically copy Phase 1 value when switching to 3-phase
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    q_phase_1_id UUID;
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
    -- Set default_value_source_question_id for Phase 2 and Phase 3
    -- ========================================================================

    -- Get phase_1_power question ID
    SELECT id INTO q_phase_1_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'phase_1_power';

    IF q_phase_1_id IS NOT NULL THEN
        -- Update phase_2_power to copy from phase_1_power
        UPDATE public.survey_questions
        SET default_value_source_question_id = q_phase_1_id
        WHERE survey_page_id = page_basic_data_id AND name = 'phase_2_power';

        -- Update phase_3_power to copy from phase_1_power
        UPDATE public.survey_questions
        SET default_value_source_question_id = q_phase_1_id
        WHERE survey_page_id = page_basic_data_id AND name = 'phase_3_power';

        RAISE NOTICE 'Set default_value_source_question_id for Phase 2 and Phase 3 to copy from Phase 1';
    ELSE
        RAISE WARNING 'Phase 1 question not found, skipping default_value_source setup';
    END IF;

END $$;
