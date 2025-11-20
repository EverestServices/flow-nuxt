-- ============================================================================
-- Migration: Make reveal_depth editable in Openings page
-- Description: Removes default_value_source and is_readonly from reveal_depth
--              question to make it editable by users
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    page_openings_id UUID;
    q_reveal_depth_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
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

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- Get Openings page ID (subpage of Walls)
    SELECT id INTO page_openings_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id
      AND parent_page_id = page_walls_id
      AND type = 'openings';

    IF page_openings_id IS NULL THEN
        RAISE EXCEPTION 'Openings page not found';
    END IF;

    -- Get reveal_depth question ID
    SELECT id INTO q_reveal_depth_id
    FROM public.survey_questions
    WHERE survey_page_id = page_openings_id AND name = 'reveal_depth';

    IF q_reveal_depth_id IS NULL THEN
        RAISE EXCEPTION 'reveal_depth question not found on Openings page';
    END IF;

    -- ========================================================================
    -- Update reveal_depth question to be editable
    -- ========================================================================

    UPDATE public.survey_questions
    SET
        default_value_source_question_id = NULL,
        is_readonly = false
    WHERE id = q_reveal_depth_id;

    RAISE NOTICE '✅ Successfully made reveal_depth question editable';
    RAISE NOTICE '   - Removed default_value_source_question_id';
    RAISE NOTICE '   - Set is_readonly to false';
    RAISE NOTICE '';
    RAISE NOTICE 'The "Káva mélység (cm)" question in Nyílászárók accordion is now editable!';

END $$;
