-- ============================================================================
-- Migration: Add options to wall_orientation question
-- Description: Updates the wall_orientation question in Facade Insulation
--              to include the 8 compass direction options needed for
--              the orientation_selector component
-- ============================================================================

DO $$
DECLARE
    question_id UUID;
BEGIN
    -- Find the wall_orientation question in Facade Insulation -> Falak page
    SELECT sq.id INTO question_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation'
      AND sp.name = 'Falak'
      AND sq.name = 'wall_orientation';

    IF question_id IS NULL THEN
        RAISE EXCEPTION 'wall_orientation question not found in Facade Insulation -> Falak page';
    END IF;

    -- Update the question with options array
    UPDATE public.survey_questions
    SET options = jsonb_build_array('É', 'ÉK', 'K', 'DK', 'D', 'DNy', 'Ny', 'ÉNy')
    WHERE id = question_id;

    RAISE NOTICE 'Successfully added options to wall_orientation question';

END $$;
