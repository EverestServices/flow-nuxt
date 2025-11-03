-- ============================================================================
-- Migration: Update Roof Type Options
-- Description: Updates "Tető típusa" options and removes "Magastető típusa"
--              from Basic Data Investment's Alapadatok page
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    page_facade_basic_data_id UUID;
    page_walls_id UUID;
    q_high_roof_type_id UUID;
    q_foundation_insulated_id UUID;
    foundation_type_uniform_sequence INTEGER;
    inv_facade_insulation_id UUID;
BEGIN
    -- Get Basic Data page from Basic Data investment
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- Get Facade Insulation pages
    SELECT sp.id INTO page_facade_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'facade_basic_data';

    SELECT sp.id INTO page_walls_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'walls';

    -- ========================================================================
    -- STEP 1: Update "Tető típusa" options
    -- ========================================================================

    UPDATE public.survey_questions
    SET options = jsonb_build_array(
        'Lapostető',
        'Alacsony hajlásszögű tető',
        'Magastető (sátor)',
        'Magastető (nyereg)',
        'Magastető (félnyereg)',
        'Magastető (kontyolt nyereg)'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'roof_type_general';

    RAISE NOTICE 'Updated "Tető típusa" options';

    -- ========================================================================
    -- STEP 2: Delete "Magastető típusa" question
    -- ========================================================================

    -- Get the question ID
    SELECT id INTO q_high_roof_type_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id AND name = 'high_roof_type';

    IF q_high_roof_type_id IS NOT NULL THEN
        -- Delete related survey answers
        DELETE FROM public.survey_answers
        WHERE survey_question_id = q_high_roof_type_id;

        -- Delete the question
        DELETE FROM public.survey_questions
        WHERE id = q_high_roof_type_id;

        RAISE NOTICE 'Deleted "Magastető típusa" question';
    ELSE
        RAISE NOTICE '"Magastető típusa" question not found, skipping deletion';
    END IF;

    -- ========================================================================
    -- STEP 3: Move questions out of "Egyéb kérdések" accordion
    -- ========================================================================

    -- Set is_special = false for these questions to move them out of accordion
    UPDATE public.survey_questions
    SET is_special = false
    WHERE survey_page_id = page_basic_data_id
      AND name IN ('building_useful_floor_area', 'window_door_type');

    RAISE NOTICE 'Moved questions out of "Egyéb kérdések" accordion';

    -- ========================================================================
    -- STEP 4: Reorder sequences - place after "Tető dőlésszöge"
    -- ========================================================================

    -- First, shift existing questions to make room
    -- roof_angle is at sequence 14, so we need to shift 15+ by 2 positions
    UPDATE public.survey_questions
    SET sequence = sequence + 2
    WHERE survey_page_id = page_basic_data_id
      AND sequence >= 15
      AND name NOT IN ('building_useful_floor_area', 'window_door_type');

    -- Now set the correct sequences for our two questions
    -- 15. Épület hasznos alapterülete (m²)
    UPDATE public.survey_questions
    SET sequence = 15
    WHERE survey_page_id = page_basic_data_id
      AND name = 'building_useful_floor_area';

    -- 16. Nyílászárók típusa
    UPDATE public.survey_questions
    SET sequence = 16
    WHERE survey_page_id = page_basic_data_id
      AND name = 'window_door_type';

    RAISE NOTICE 'Reordered sequences - placed questions after "Tető dőlésszöge"';

    -- ========================================================================
    -- STEP 5: Set "Földszint" default value to true
    -- ========================================================================

    UPDATE public.survey_questions
    SET default_value = 'true'
    WHERE survey_page_id = page_basic_data_id
      AND name = 'has_ground_floor';

    RAISE NOTICE 'Set "Földszint" default value to true';

    -- ========================================================================
    -- STEP 6: Move "Lábazat hőszigetelt" from Walls to Facade Basic Data
    -- ========================================================================

    IF page_walls_id IS NOT NULL AND page_facade_basic_data_id IS NOT NULL THEN
        -- Get the question ID from Walls page
        SELECT id INTO q_foundation_insulated_id
        FROM public.survey_questions
        WHERE survey_page_id = page_walls_id AND name = 'foundation_insulated';

        IF q_foundation_insulated_id IS NOT NULL THEN
            -- Get the sequence of "Lábazat típusa mindenhol megegyezik"
            SELECT sequence INTO foundation_type_uniform_sequence
            FROM public.survey_questions
            WHERE survey_page_id = page_facade_basic_data_id
              AND name = 'foundation_type_uniform';

            IF foundation_type_uniform_sequence IS NOT NULL THEN
                -- Shift questions after "Lábazat típusa mindenhol megegyezik" by 1
                UPDATE public.survey_questions
                SET sequence = sequence + 1
                WHERE survey_page_id = page_facade_basic_data_id
                  AND sequence > foundation_type_uniform_sequence;

                -- Move the question and set its sequence
                UPDATE public.survey_questions
                SET survey_page_id = page_facade_basic_data_id,
                    sequence = foundation_type_uniform_sequence + 1
                WHERE id = q_foundation_insulated_id;

                RAISE NOTICE 'Moved "Lábazat hőszigetelt" from Walls to Facade Basic Data';

                -- Delete dependent questions from Walls page
                DELETE FROM public.survey_answers
                WHERE survey_question_id IN (
                    SELECT id FROM public.survey_questions
                    WHERE survey_page_id = page_walls_id
                      AND name IN ('existing_insulation_material', 'existing_insulation_material_other', 'existing_insulation_thickness')
                );

                DELETE FROM public.survey_questions
                WHERE survey_page_id = page_walls_id
                  AND name IN ('existing_insulation_material', 'existing_insulation_material_other', 'existing_insulation_thickness');

                RAISE NOTICE 'Deleted dependent insulation questions from Walls page';
            ELSE
                RAISE WARNING '"Lábazat típusa mindenhol megegyezik" not found in Facade Basic Data';
            END IF;
        ELSE
            RAISE WARNING '"Lábazat hőszigetelt" question not found on Walls page';
        END IF;
    ELSE
        RAISE WARNING 'Facade Insulation pages not found, skipping step 6';
    END IF;

    RAISE NOTICE 'Successfully updated roof type options and facade insulation questions';

    -- ========================================================================
    -- STEP 7: Update extra cost names to add "(nem vállaljuk)" suffix
    -- ========================================================================

    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_insulation_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_insulation_id IS NOT NULL THEN
        -- Update security_work
        UPDATE public.extra_costs
        SET name = 'Kamera/riasztó végpontok le-, és felszerelése (nem vállaljuk)',
            name_translations = jsonb_build_object('hu', 'Kamera/riasztó végpontok le-, és felszerelése (nem vállaljuk)', 'en', 'Camera/alarm endpoint work (not undertaken)')
        WHERE investment_id = inv_facade_insulation_id AND persist_name = 'security_work';

        -- Update ac_unit_work
        UPDATE public.extra_costs
        SET name = 'Klíma/hőszivattyú kültéri le-, és felszerelése (nem vállaljuk)',
            name_translations = jsonb_build_object('hu', 'Klíma/hőszivattyú kültéri le-, és felszerelése (nem vállaljuk)', 'en', 'AC/heat pump outdoor unit work (not undertaken)')
        WHERE investment_id = inv_facade_insulation_id AND persist_name = 'ac_unit_work';

        -- Update gas_pipe_lifting
        UPDATE public.extra_costs
        SET name = 'Gázcső kiemelése (nem vállaljuk)',
            name_translations = jsonb_build_object('hu', 'Gázcső kiemelése (nem vállaljuk)', 'en', 'Gas pipe lifting (not undertaken)')
        WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gas_pipe_lifting';

        -- Update gas_meter_work
        UPDATE public.extra_costs
        SET name = 'Gázóra le-, és felszerelése (nem vállaljuk)',
            name_translations = jsonb_build_object('hu', 'Gázóra le-, és felszerelése (nem vállaljuk)', 'en', 'Gas meter work (not undertaken)')
        WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gas_meter_work';

        -- Update electric_meter_work
        UPDATE public.extra_costs
        SET name = 'Villanyóra le-, és felszerelése (nem vállaljuk)',
            name_translations = jsonb_build_object('hu', 'Villanyóra le-, és felszerelése (nem vállaljuk)', 'en', 'Electric meter work (not undertaken)')
        WHERE investment_id = inv_facade_insulation_id AND persist_name = 'electric_meter_work';

        RAISE NOTICE 'Updated extra cost names with "(nem vállaljuk)" suffix';
    ELSE
        RAISE WARNING 'Facade Insulation investment not found, skipping extra cost updates';
    END IF;

    -- ========================================================================
    -- STEP 8: Set all survey questions to is_required = false
    -- ========================================================================

    UPDATE public.survey_questions
    SET is_required = false;

    RAISE NOTICE 'Set all survey questions to is_required = false';

    -- ========================================================================
    -- STEP 9: Add info message to "Épület hasznos alapterülete (m²)"
    -- ========================================================================

    UPDATE public.survey_questions
    SET info_message_translations = jsonb_build_object(
        'hu', '190 cm fölötti területek, a teraszok nem.',
        'en', 'Areas above 190 cm height, excluding terraces.'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'building_useful_floor_area';

    RAISE NOTICE 'Added info message to "Épület hasznos alapterülete (m²)" question';

END $$;
