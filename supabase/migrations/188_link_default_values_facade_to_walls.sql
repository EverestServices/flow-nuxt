-- ============================================================================
-- Migration: Link Default Values from Facade Basic Data to Walls
-- Description: Sets up default_value_source relationships:
--              1. protrusion_amount (Facade Basic Data) -> protrusion_size (Walls)
--              2. reveal_depth_avg (Facade Basic Data) -> reveal_depth (Openings)
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    page_walls_id UUID;
    page_openings_id UUID;
    q_protrusion_amount_id UUID;
    q_protrusion_size_id UUID;
    q_reveal_depth_avg_id UUID;
    q_reveal_depth_id UUID;
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

    -- Get Openings page ID (subpage of Walls)
    SELECT id INTO page_openings_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id
      AND parent_page_id = page_walls_id
      AND type = 'openings';

    IF page_openings_id IS NULL THEN
        RAISE EXCEPTION 'Openings page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Link protrusion_amount to protrusion_size
    -- ========================================================================

    -- Get source question: Ki/beugrás mértéke (cm) from Facade Basic Data
    SELECT id INTO q_protrusion_amount_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'protrusion_amount';

    -- Get target question: Ki/beugrás mérete (cm) from Walls
    SELECT id INTO q_protrusion_size_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'protrusion_size';

    IF q_protrusion_amount_id IS NULL THEN
        RAISE EXCEPTION 'protrusion_amount question not found on Facade Basic Data page';
    END IF;

    IF q_protrusion_size_id IS NULL THEN
        RAISE EXCEPTION 'protrusion_size question not found on Walls page';
    END IF;

    -- Set default_value_source for protrusion_size
    UPDATE public.survey_questions
    SET default_value_source_question_id = q_protrusion_amount_id
    WHERE id = q_protrusion_size_id;

    RAISE NOTICE 'Linked protrusion_amount -> protrusion_size';

    -- ========================================================================
    -- STEP 2: Link reveal_depth_avg to reveal_depth
    -- ========================================================================

    -- Get source question: Átlagos káva mélység (cm) from Facade Basic Data
    SELECT id INTO q_reveal_depth_avg_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'reveal_depth_avg';

    -- Get target question: Káva mélység (cm) from Openings
    SELECT id INTO q_reveal_depth_id
    FROM public.survey_questions
    WHERE survey_page_id = page_openings_id AND name = 'reveal_depth';

    IF q_reveal_depth_avg_id IS NULL THEN
        RAISE EXCEPTION 'reveal_depth_avg question not found on Facade Basic Data page';
    END IF;

    IF q_reveal_depth_id IS NULL THEN
        RAISE EXCEPTION 'reveal_depth question not found on Openings page';
    END IF;

    -- Set default_value_source for reveal_depth
    -- NOTE: We do NOT set is_readonly=true here, so the field remains editable
    -- (as per migration 163 which made it editable)
    UPDATE public.survey_questions
    SET default_value_source_question_id = q_reveal_depth_avg_id
    WHERE id = q_reveal_depth_id;

    RAISE NOTICE 'Linked reveal_depth_avg -> reveal_depth';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully linked default values from Facade Basic Data to Walls:';
    RAISE NOTICE '   1. Ki/beugrás mértéke (cm) -> Ki/beugrás mérete (cm)';
    RAISE NOTICE '      Source: protrusion_amount (Homlokzati szigetelés alapadatok)';
    RAISE NOTICE '      Target: protrusion_size (Falak)';
    RAISE NOTICE '';
    RAISE NOTICE '   2. Átlagos káva mélység (cm) -> Káva mélység (cm)';
    RAISE NOTICE '      Source: reveal_depth_avg (Homlokzati szigetelés alapadatok)';
    RAISE NOTICE '      Target: reveal_depth (Falak > Nyílászárók accordion)';
    RAISE NOTICE '';
    RAISE NOTICE 'Note: reveal_depth remains editable (is_readonly is NOT set to true)';

END $$;
