-- ============================================================================
-- Migration: Add Display Condition to Roof Angle Question & Remove Heating Questions
-- Description:
--   1. "Tető dőlésszöge" only displays when "Tető típusa" is not "Lapostető"
--   2. Remove specific heating-related questions from Basic Data page
--   3. Move "HMV készítés módja" right after "Mivel fűt?"
--   4. Rename "Mivel fűt?" to "Meglévő fűtésrendszer hőtermelői"
--   5. Rename "Homlokzati szigetelés" Investment's "Alapadatok" page to "Homlokzati szigetelés alapadatok"
--   6. Reorder questions on "Homlokzati szigetelés" Alapadatok page - move "Munkaterület adottságai" block after "Ázás kárkép látható-e"
--   7. Remove "uniform" questions (walls_uniform_type, wall_thickness_uniform, foundation_type_uniform)
--   8. Update default_value_source_question_id for Falak page questions
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    questions_to_delete TEXT[] := ARRAY[
        'heating_device_location',
        'heating_device_other_use_gas',
        'heating_device_other_use_electric',
        'heating_system_heat_generator',
        'heating_system_heat_generator_other',
        'electric_storage_heater_warning',
        'gas_heating_methods_warning'
    ];
    question_name TEXT;
    heating_methods_sequence INTEGER;
    page_facade_basic_data_id UUID;
    source_wall_structure_id UUID;
    source_wall_thickness_avg_id UUID;
    source_foundation_type_avg_id UUID;
    page_walls_id UUID;
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
    -- STEP 1: Add display_conditions to "Tető dőlésszöge" question
    -- Only show when "Tető típusa" is NOT "Lapostető"
    -- ========================================================================

    UPDATE public.survey_questions
    SET display_conditions = jsonb_build_object(
        'field', 'roof_type_general',
        'operator', 'not_equals',
        'value', 'Lapostető'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'roof_angle';

    RAISE NOTICE 'Added display condition to "Tető dőlésszöge" question';
    RAISE NOTICE 'Question will only display when "Tető típusa" is not "Lapostető"';

    -- ========================================================================
    -- STEP 2: Remove heating-related questions from Basic Data page
    -- ========================================================================

    -- First, delete related survey answers
    DELETE FROM public.survey_answers
    WHERE survey_question_id IN (
        SELECT id FROM public.survey_questions
        WHERE survey_page_id = page_basic_data_id
          AND name = ANY(questions_to_delete)
    );

    RAISE NOTICE 'Deleted survey answers for heating-related questions';

    -- Then, delete the questions themselves
    FOREACH question_name IN ARRAY questions_to_delete
    LOOP
        DELETE FROM public.survey_questions
        WHERE survey_page_id = page_basic_data_id
          AND name = question_name;

        RAISE NOTICE 'Deleted question: %', question_name;
    END LOOP;

    RAISE NOTICE 'Successfully removed heating-related questions from Basic Data page';

    -- ========================================================================
    -- STEP 3: Move "HMV készítés módja" right after "Mivel fűt?"
    -- ========================================================================

    -- Get the sequence of "heating_methods" (Mivel fűt?)
    SELECT sequence INTO heating_methods_sequence
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id
      AND name = 'heating_methods';

    IF heating_methods_sequence IS NOT NULL THEN
        -- Shift all questions after heating_methods by 1 position
        UPDATE public.survey_questions
        SET sequence = sequence + 1
        WHERE survey_page_id = page_basic_data_id
          AND sequence > heating_methods_sequence
          AND name != 'hot_water_preparation_method';

        -- Move HMV question right after heating_methods
        UPDATE public.survey_questions
        SET sequence = heating_methods_sequence + 1
        WHERE survey_page_id = page_basic_data_id
          AND name = 'hot_water_preparation_method';

        RAISE NOTICE 'Moved "HMV készítés módja" right after "Mivel fűt?"';
    ELSE
        RAISE WARNING '"Mivel fűt?" question not found';
    END IF;

    -- ========================================================================
    -- STEP 4: Rename "Mivel fűt?" to "Meglévő fűtésrendszer hőtermelői"
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Meglévő fűtésrendszer hőtermelői (többet is kiválaszthat) *',
        'en', 'Existing heating system heat generators (you can select multiple) *'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'heating_methods';

    RAISE NOTICE 'Renamed "Mivel fűt?" to "Meglévő fűtésrendszer hőtermelői"';

    -- ========================================================================
    -- STEP 5: Rename "Homlokzati szigetelés" Investment's "Alapadatok" page
    -- ========================================================================

    UPDATE public.survey_pages
    SET name = 'Homlokzati szigetelés alapadatok',
        name_translations = jsonb_build_object(
            'hu', 'Homlokzati szigetelés alapadatok',
            'en', 'Facade Insulation Basic Data'
        )
    WHERE investment_id IN (
        SELECT id FROM public.investments WHERE persist_name = 'facadeInsulation'
    )
    AND type = 'facade_basic_data';

    RAISE NOTICE 'Renamed "Homlokzati szigetelés" Investment Alapadatok page to "Homlokzati szigetelés alapadatok"';

    -- ========================================================================
    -- STEP 6: Reorder questions on "Homlokzati szigetelés" Alapadatok page
    -- Move "Munkaterület adottságai" block after "Ázás kárkép látható-e"
    -- ========================================================================

    -- Get the facade basic data page ID
    SELECT sp.id INTO page_facade_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NOT NULL THEN
        -- Reorder all questions in the new sequence (after removing uniform questions in STEP 7)
        -- Main questions (1-13)
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_facade_basic_data_id AND name = 'facade_insulation';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_facade_basic_data_id AND name = 'wall_thickness_avg';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_type_avg';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_facade_basic_data_id AND name = 'protrusion_amount';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulated_general';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_facade_basic_data_id AND name = 'reveal_depth_avg';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_facade_basic_data_id AND name = 'coloring';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_facade_basic_data_id AND name = 'structure';
        UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_facade_basic_data_id AND name = 'defects_title';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_facade_basic_data_id AND name = 'structural_damage_visible';
        UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_facade_basic_data_id AND name = 'moisture_damage_visible';
        UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_facade_basic_data_id AND name = 'water_damage_visible';

        -- Site conditions block (14-18) - moved after water_damage_visible
        UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_facade_basic_data_id AND name = 'site_conditions_title';
        UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_facade_basic_data_id AND name = 'facades_scaffoldable';
        UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_facade_basic_data_id AND name = 'container_placement';
        UPDATE public.survey_questions SET sequence = 17 WHERE survey_page_id = page_facade_basic_data_id AND name = 'truck_accessible';
        UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_facade_basic_data_id AND name = 'material_storage_on_site';

        RAISE NOTICE 'Reordered questions on Homlokzati szigetelés Alapadatok page - moved Munkaterület adottságai block after Ázás kárkép látható-e';
    ELSE
        RAISE WARNING 'Homlokzati szigetelés Alapadatok page not found';
    END IF;

    -- ========================================================================
    -- STEP 7: Remove "uniform" questions
    -- ========================================================================

    -- Delete answers first
    DELETE FROM public.survey_answers
    WHERE survey_question_id IN (
        SELECT sq.id FROM public.survey_questions sq
        JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
        JOIN public.investments i ON i.id = sp.investment_id
        WHERE (i.persist_name = 'basicData' AND sp.type = 'basic_data' AND sq.name = 'walls_uniform_type')
           OR (i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data' AND sq.name IN ('wall_thickness_uniform', 'foundation_type_uniform'))
    );

    -- Delete questions
    DELETE FROM public.survey_questions
    WHERE id IN (
        SELECT sq.id FROM public.survey_questions sq
        JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
        JOIN public.investments i ON i.id = sp.investment_id
        WHERE (i.persist_name = 'basicData' AND sp.type = 'basic_data' AND sq.name = 'walls_uniform_type')
           OR (i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data' AND sq.name IN ('wall_thickness_uniform', 'foundation_type_uniform'))
    );

    RAISE NOTICE 'Removed uniform questions: walls_uniform_type, wall_thickness_uniform, foundation_type_uniform';

    -- ========================================================================
    -- STEP 8: Update default_value_source_question_id for Falak page questions
    -- ========================================================================

    -- Get source question IDs
    -- Source: exterior_wall_structure from Alapadatok Investment
    SELECT sq.id INTO source_wall_structure_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data' AND sq.name = 'exterior_wall_structure';

    -- Source: wall_thickness_avg from Homlokzati szigetelés Investment Homlokzati szigetelés alapadatok page
    SELECT sq.id INTO source_wall_thickness_avg_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data' AND sq.name = 'wall_thickness_avg';

    -- Source: foundation_type_avg from Homlokzati szigetelés Investment Homlokzati szigetelés alapadatok page
    SELECT sq.id INTO source_foundation_type_avg_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data' AND sq.name = 'foundation_type_avg';

    -- Get Falak page ID
    SELECT sp.id INTO page_walls_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'walls';

    IF page_walls_id IS NOT NULL THEN
        -- Update wall_structure to use exterior_wall_structure as source
        IF source_wall_structure_id IS NOT NULL THEN
            UPDATE public.survey_questions
            SET default_value_source_question_id = source_wall_structure_id
            WHERE survey_page_id = page_walls_id AND name = 'wall_structure';

            RAISE NOTICE 'Updated wall_structure default_value_source to exterior_wall_structure';
        END IF;

        -- Update wall_thickness to use wall_thickness_avg as source
        IF source_wall_thickness_avg_id IS NOT NULL THEN
            UPDATE public.survey_questions
            SET default_value_source_question_id = source_wall_thickness_avg_id
            WHERE survey_page_id = page_walls_id AND name = 'wall_thickness';

            RAISE NOTICE 'Updated wall_thickness default_value_source to wall_thickness_avg';
        END IF;

        -- Update foundation_type to use foundation_type_avg as source
        IF source_foundation_type_avg_id IS NOT NULL THEN
            UPDATE public.survey_questions
            SET default_value_source_question_id = source_foundation_type_avg_id
            WHERE survey_page_id = page_walls_id AND name = 'foundation_type';

            RAISE NOTICE 'Updated foundation_type default_value_source to foundation_type_avg';
        END IF;
    ELSE
        RAISE WARNING 'Falak page not found for Homlokzati szigetelés investment';
    END IF;

END $$;
