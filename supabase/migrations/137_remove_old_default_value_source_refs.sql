-- ============================================================================
-- Migration: Remove Old Default Value Source References
-- Description: Removes default_value_source_question_id from questions that
--              now use conditional copy rules instead
-- ============================================================================

DO $$
DECLARE
    -- Homlokzati szigetelés Investment
    inv_facade_id UUID;
    page_facade_walls_id UUID;

    q_wall_thickness_instance_id UUID;
    q_foundation_type_instance_id UUID;
    q_wall_structure_instance_id UUID;
BEGIN
    RAISE NOTICE '========================================'  ;
    RAISE NOTICE 'Removing Old Default Value Source References';
    RAISE NOTICE '========================================';

    -- Get Homlokzati szigetelés investment
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Homlokzati szigetelés investment not found';
    END IF;

    -- Get Homlokzati szigetelés - Falak page
    SELECT id INTO page_facade_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_facade_walls_id IS NULL THEN
        RAISE EXCEPTION 'Homlokzati szigetelés - Falak page not found';
    END IF;

    -- Get the target question IDs
    SELECT id INTO q_wall_structure_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'wall_structure';

    SELECT id INTO q_wall_thickness_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'wall_thickness';

    SELECT id INTO q_foundation_type_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'foundation_type';

    -- Remove default_value_source_question_id from these questions
    -- They now use conditional copy rules instead

    IF q_wall_structure_instance_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET default_value_source_question_id = NULL
        WHERE id = q_wall_structure_instance_id
          AND default_value_source_question_id IS NOT NULL;

        IF FOUND THEN
            RAISE NOTICE 'Cleared default_value_source from wall_structure';
        ELSE
            RAISE NOTICE 'wall_structure had no default_value_source (already clean)';
        END IF;
    END IF;

    IF q_wall_thickness_instance_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET default_value_source_question_id = NULL
        WHERE id = q_wall_thickness_instance_id
          AND default_value_source_question_id IS NOT NULL;

        IF FOUND THEN
            RAISE NOTICE 'Cleared default_value_source from wall_thickness';
        ELSE
            RAISE NOTICE 'wall_thickness had no default_value_source (already clean)';
        END IF;
    END IF;

    IF q_foundation_type_instance_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET default_value_source_question_id = NULL
        WHERE id = q_foundation_type_instance_id
          AND default_value_source_question_id IS NOT NULL;

        IF FOUND THEN
            RAISE NOTICE 'Cleared default_value_source from foundation_type';
        ELSE
            RAISE NOTICE 'foundation_type had no default_value_source (already clean)';
        END IF;
    END IF;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Old Default Value Source References Removed!';
    RAISE NOTICE '========================================';
END $$;
