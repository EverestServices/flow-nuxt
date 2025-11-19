-- ============================================================================
-- Migration: Reorganize Attic Floor Insulation Pages
-- Description: Moves questions from "Munkaterület adottságai" and
--              "Hibák hozzáadása" pages to "Tetőtér adatai" page,
--              then deletes the empty pages
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
    page_site_conditions_id UUID;
    page_defects_id UUID;

    -- Question IDs from site_conditions page
    q_access_route_id UUID;
    q_access_opening_size_id UUID;
    q_attic_surface_id UUID;
    q_chimney_count_id UUID;

    -- Question IDs from defects page
    q_bird_damage_id UUID;
    q_wasp_nest_id UUID;
    q_structural_damage_id UUID;
    q_water_leak_id UUID;

    -- Question IDs that already exist (need to be moved)
    q_access_opening_width_id UUID;
    q_access_opening_height_id UUID;
BEGIN
    -- ========================================================================
    -- Find Investment and Pages
    -- ========================================================================

    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Attic Floor Insulation investment not found';
    END IF;

    SELECT id INTO page_attic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'attic_data';

    IF page_attic_data_id IS NULL THEN
        RAISE EXCEPTION 'Tetőtér adatai page not found';
    END IF;

    SELECT id INTO page_site_conditions_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'site_conditions';

    SELECT id INTO page_defects_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'defects';

    RAISE NOTICE 'Found pages - Attic Data: %, Site Conditions: %, Defects: %',
                 page_attic_data_id, page_site_conditions_id, page_defects_id;

    -- ========================================================================
    -- Get Question IDs from site_conditions page
    -- ========================================================================

    IF page_site_conditions_id IS NOT NULL THEN
        SELECT id INTO q_access_route_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'access_route';

        SELECT id INTO q_access_opening_size_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'access_opening_size';

        SELECT id INTO q_attic_surface_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'attic_surface';

        SELECT id INTO q_chimney_count_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'chimney_count';
    END IF;

    -- ========================================================================
    -- Get Question IDs from defects page
    -- ========================================================================

    IF page_defects_id IS NOT NULL THEN
        SELECT id INTO q_bird_damage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_defects_id AND name = 'bird_damage';

        SELECT id INTO q_wasp_nest_id
        FROM public.survey_questions
        WHERE survey_page_id = page_defects_id AND name = 'wasp_nest';

        SELECT id INTO q_structural_damage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_defects_id AND name = 'structural_damage';

        SELECT id INTO q_water_leak_id
        FROM public.survey_questions
        WHERE survey_page_id = page_defects_id AND name = 'water_leak';
    END IF;

    -- ========================================================================
    -- Get Question IDs that already exist (from any page)
    -- ========================================================================

    SELECT id INTO q_access_opening_width_id
    FROM public.survey_questions
    WHERE name = 'access_opening_width'
      AND survey_page_id IN (
          SELECT id FROM public.survey_pages
          WHERE investment_id = inv_attic_floor_id
      );

    SELECT id INTO q_access_opening_height_id
    FROM public.survey_questions
    WHERE name = 'access_opening_height'
      AND survey_page_id IN (
          SELECT id FROM public.survey_pages
          WHERE investment_id = inv_attic_floor_id
      );

    -- ========================================================================
    -- Create new title questions
    -- ========================================================================

    -- 12. Munkaterület adottságai (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_attic_data_id,
        'site_conditions_title',
        jsonb_build_object('hu', 'Munkaterület adottságai', 'en', 'Site Conditions'),
        'title',
        false,
        12
    );

    -- 18. Hibák hozzáadása (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_attic_data_id,
        'defects_title',
        jsonb_build_object('hu', 'Hibák hozzáadása', 'en', 'Add Defects'),
        'title',
        false,
        18
    );

    RAISE NOTICE 'Created new title questions';

    -- ========================================================================
    -- Move questions from site_conditions page to attic_data page
    -- ========================================================================

    -- 13. Feljárás
    IF q_access_route_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 13
        WHERE id = q_access_route_id;
    END IF;

    -- 16. Padlás felülete
    IF q_attic_surface_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 16
        WHERE id = q_attic_surface_id;
    END IF;

    -- 17. Kémények száma (db)
    IF q_chimney_count_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 17
        WHERE id = q_chimney_count_id;
    END IF;

    RAISE NOTICE 'Moved site_conditions questions to attic_data page';

    -- ========================================================================
    -- Move existing access_opening questions to correct positions
    -- ========================================================================

    -- 14. Feljáró tiszta nyílásméretének szélessége (cm)
    IF q_access_opening_width_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 14
        WHERE id = q_access_opening_width_id;
    END IF;

    -- 15. Feljáró tiszta nyílásméretének magassága (cm)
    IF q_access_opening_height_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 15
        WHERE id = q_access_opening_height_id;
    END IF;

    RAISE NOTICE 'Moved access opening width/height questions to correct positions';

    -- ========================================================================
    -- Move questions from defects page to attic_data page
    -- ========================================================================

    -- 19. Madarak kártétele
    IF q_bird_damage_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 19
        WHERE id = q_bird_damage_id;
    END IF;

    -- 20. Darázsfészek
    IF q_wasp_nest_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 20
        WHERE id = q_wasp_nest_id;
    END IF;

    -- 21. Statikai kár
    IF q_structural_damage_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 21
        WHERE id = q_structural_damage_id;
    END IF;

    -- 22. Beázás
    IF q_water_leak_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET survey_page_id = page_attic_data_id, sequence = 22
        WHERE id = q_water_leak_id;
    END IF;

    RAISE NOTICE 'Moved defects questions to attic_data page';

    -- ========================================================================
    -- Delete old access_opening_size question and its answers
    -- ========================================================================

    IF q_access_opening_size_id IS NOT NULL THEN
        -- Delete answers first
        DELETE FROM public.survey_answers
        WHERE survey_question_id = q_access_opening_size_id;

        -- Delete the question
        DELETE FROM public.survey_questions
        WHERE id = q_access_opening_size_id;

        RAISE NOTICE 'Deleted old access_opening_size question';
    END IF;

    -- ========================================================================
    -- Delete remaining questions on site_conditions and defects pages
    -- ========================================================================

    IF page_site_conditions_id IS NOT NULL THEN
        DELETE FROM public.survey_answers
        WHERE survey_question_id IN (
            SELECT id FROM public.survey_questions
            WHERE survey_page_id = page_site_conditions_id
        );

        DELETE FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id;

        RAISE NOTICE 'Deleted remaining questions from site_conditions page';
    END IF;

    IF page_defects_id IS NOT NULL THEN
        DELETE FROM public.survey_answers
        WHERE survey_question_id IN (
            SELECT id FROM public.survey_questions
            WHERE survey_page_id = page_defects_id
        );

        DELETE FROM public.survey_questions
        WHERE survey_page_id = page_defects_id;

        RAISE NOTICE 'Deleted remaining questions from defects page';
    END IF;

    -- ========================================================================
    -- Delete the empty pages
    -- ========================================================================

    IF page_site_conditions_id IS NOT NULL THEN
        DELETE FROM public.survey_pages WHERE id = page_site_conditions_id;
        RAISE NOTICE 'Deleted Munkaterület adottságai page';
    END IF;

    IF page_defects_id IS NOT NULL THEN
        DELETE FROM public.survey_pages WHERE id = page_defects_id;
        RAISE NOTICE 'Deleted Hibák hozzáadása page';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully reorganized Attic Floor Insulation pages';
    RAISE NOTICE 'Tetőtér adatai page now has 21 questions (sequence 1-21)';
    RAISE NOTICE 'Deleted 2 pages: Munkaterület adottságai, Hibák hozzáadása';
    RAISE NOTICE '========================================';

END $$;
