-- ============================================================================
-- Migration: Create Facade Insulation Basic Data Page
-- Description: Creates new "Alapadatok" page for Facade Insulation investment,
--              moves questions from other pages, adds new questions,
--              and removes obsolete pages
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_basic_data_id UUID;
    page_planned_investment_id UUID;
    page_site_conditions_id UUID;
    page_other_data_id UUID;

    -- Question IDs to move
    q_facade_insulation_id UUID;
    q_foundation_insulation_id UUID;
    q_facades_scaffoldable_id UUID;
    q_container_placement_id UUID;
    q_truck_accessible_id UUID;
    q_material_storage_id UUID;
    q_coloring_id UUID;
    q_structure_id UUID;
    q_defects_title_id UUID;
    q_structural_damage_id UUID;
    q_moisture_damage_id UUID;
    q_water_damage_id UUID;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get existing page IDs
    SELECT id INTO page_planned_investment_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'planned_investment';

    SELECT id INTO page_site_conditions_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'site_conditions';

    SELECT id INTO page_other_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'other_data';

    -- ========================================================================
    -- STEP 1: Create new "Alapadatok" Survey Page
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_facade_id,
        'Alapadatok',
        jsonb_build_object('hu', 'Alapadatok', 'en', 'Basic Data'),
        'facade_basic_data',
        '{"top": 50, "right": 100}'::jsonb,
        false,
        false,
        0
    )
    RETURNING id INTO page_basic_data_id;

    RAISE NOTICE 'Created Alapadatok page with id: %', page_basic_data_id;

    -- ========================================================================
    -- STEP 2: Move existing questions to new page
    -- ========================================================================

    -- Get question IDs from planned_investment page
    IF page_planned_investment_id IS NOT NULL THEN
        SELECT id INTO q_facade_insulation_id
        FROM public.survey_questions
        WHERE survey_page_id = page_planned_investment_id AND name = 'facade_insulation';

        SELECT id INTO q_foundation_insulation_id
        FROM public.survey_questions
        WHERE survey_page_id = page_planned_investment_id AND name = 'foundation_insulation';

        SELECT id INTO q_coloring_id
        FROM public.survey_questions
        WHERE survey_page_id = page_planned_investment_id AND name = 'coloring';

        SELECT id INTO q_structure_id
        FROM public.survey_questions
        WHERE survey_page_id = page_planned_investment_id AND name = 'structure';

        -- Move questions
        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 1
        WHERE id = q_facade_insulation_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 2
        WHERE id = q_foundation_insulation_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 14
        WHERE id = q_coloring_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 15
        WHERE id = q_structure_id;
    END IF;

    -- Get question IDs from site_conditions page
    IF page_site_conditions_id IS NOT NULL THEN
        SELECT id INTO q_facades_scaffoldable_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'facades_scaffoldable';

        SELECT id INTO q_container_placement_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'container_placement';

        SELECT id INTO q_truck_accessible_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'truck_accessible';

        SELECT id INTO q_material_storage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_site_conditions_id AND name = 'material_storage_on_site';

        -- Move questions
        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 4
        WHERE id = q_facades_scaffoldable_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 5
        WHERE id = q_container_placement_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 6
        WHERE id = q_truck_accessible_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 7
        WHERE id = q_material_storage_id;
    END IF;

    -- Get question IDs from other_data page
    IF page_other_data_id IS NOT NULL THEN
        SELECT id INTO q_defects_title_id
        FROM public.survey_questions
        WHERE survey_page_id = page_other_data_id AND name = 'defects_title';

        SELECT id INTO q_structural_damage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_other_data_id AND name = 'structural_damage_visible';

        SELECT id INTO q_moisture_damage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_other_data_id AND name = 'moisture_damage_visible';

        SELECT id INTO q_water_damage_id
        FROM public.survey_questions
        WHERE survey_page_id = page_other_data_id AND name = 'water_damage_visible';

        -- Move questions
        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 16
        WHERE id = q_defects_title_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 17
        WHERE id = q_structural_damage_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 18
        WHERE id = q_moisture_damage_id;

        UPDATE public.survey_questions
        SET survey_page_id = page_basic_data_id, sequence = 19
        WHERE id = q_water_damage_id;
    END IF;

    RAISE NOTICE 'Moved existing questions to Alapadatok page';

    -- ========================================================================
    -- STEP 3: Create new questions
    -- ========================================================================

    -- 3. Munkaterület adottságai (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'site_conditions_title',
        jsonb_build_object('hu', 'Munkaterület adottságai', 'en', 'Site Conditions'),
        'title',
        false,
        3
    );

    -- 8. Fal vastagsága
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'wall_thickness_avg',
        jsonb_build_object('hu', 'Fal vastagsága', 'en', 'Wall Thickness'),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Fal vastagsága',
        jsonb_build_object('hu', 'Fal vastagsága', 'en', 'Wall Thickness'),
        8
    );

    -- 9. Fal vastagsága mindenhol megegyezik
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'wall_thickness_uniform',
        jsonb_build_object('hu', 'Fal vastagsága mindenhol megegyezik', 'en', 'Wall thickness is uniform everywhere'),
        'switch',
        false,
        'true',
        9
    );

    -- 10. Lábazat típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'foundation_type_avg',
        jsonb_build_object('hu', 'Lábazat típusa', 'en', 'Foundation Type'),
        'dropdown',
        false,
        jsonb_build_array('Pozitív', 'Negatív'),
        10,
        jsonb_build_object(
            'hu', 'Pozitív ha a homlokzati falsíktól kintebb áll, negatív ha mögötte van.',
            'en', 'Positive if it protrudes from the facade plane, negative if it is recessed.'
        )
    );

    -- 11. Lábazat típusa mindenhol megegyezik
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'foundation_type_uniform',
        jsonb_build_object('hu', 'Lábazat típusa mindenhol megegyezik', 'en', 'Foundation type is uniform everywhere'),
        'switch',
        false,
        'true',
        11
    );

    -- 12. Ki/beugrás mértéke (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'protrusion_amount',
        jsonb_build_object('hu', 'Ki/beugrás mértéke (cm)', 'en', 'Protrusion/Recess Amount (cm)'),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Ki/beugrás mértéke',
        jsonb_build_object('hu', 'Ki/beugrás mértéke', 'en', 'Protrusion/Recess Amount'),
        12
    );

    -- 13. Átlagos káva mélység (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'reveal_depth_avg',
        jsonb_build_object('hu', 'Átlagos káva mélység (cm)', 'en', 'Average Reveal Depth (cm)'),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Káva mélység',
        jsonb_build_object('hu', 'Káva mélység', 'en', 'Reveal Depth'),
        13
    );

    RAISE NOTICE 'Created new questions';

    -- ========================================================================
    -- STEP 4: Update Walls page sequence
    -- ========================================================================

    UPDATE public.survey_pages
    SET sequence = 1
    WHERE investment_id = inv_facade_id AND type = 'walls';

    -- ========================================================================
    -- STEP 5: Delete obsolete survey pages and their answers
    -- ========================================================================

    -- Delete survey answers for questions on pages being deleted
    IF page_planned_investment_id IS NOT NULL THEN
        DELETE FROM public.survey_answers
        WHERE survey_question_id IN (
            SELECT id FROM public.survey_questions
            WHERE survey_page_id = page_planned_investment_id
        );
    END IF;

    IF page_site_conditions_id IS NOT NULL THEN
        DELETE FROM public.survey_answers
        WHERE survey_question_id IN (
            SELECT id FROM public.survey_questions
            WHERE survey_page_id = page_site_conditions_id
        );
    END IF;

    IF page_other_data_id IS NOT NULL THEN
        DELETE FROM public.survey_answers
        WHERE survey_question_id IN (
            SELECT id FROM public.survey_questions
            WHERE survey_page_id = page_other_data_id
        );
    END IF;

    -- Delete remaining questions on these pages
    DELETE FROM public.survey_questions
    WHERE survey_page_id IN (page_planned_investment_id, page_site_conditions_id, page_other_data_id);

    -- Delete the pages themselves
    DELETE FROM public.survey_pages
    WHERE id IN (page_planned_investment_id, page_site_conditions_id, page_other_data_id);

    RAISE NOTICE 'Deleted obsolete survey pages: Tervezett beruházás, Munkaterület adottságai, Egyéb adatok';

    RAISE NOTICE 'Successfully created Facade Insulation Basic Data page with all questions';

END $$;
