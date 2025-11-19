-- ============================================================================
-- Migration: Add Conditional Info Messages to Attic Defects
-- Description: Adds danger conditional info messages to 4 defect questions
--              on the "Hibák hozzáadása" page of Padlásfödém szigetelés
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_defects_id UUID;
    q_bird_damage_id UUID;
    q_wasp_nest_id UUID;
    q_structural_damage_id UUID;
    q_water_leakage_id UUID;
BEGIN
    -- Get Padlásfödém szigetelés investment ID
    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Padlásfödém szigetelés investment not found';
    END IF;

    -- Get Hibák hozzáadása page ID
    SELECT id INTO page_defects_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id AND type = 'defects';

    IF page_defects_id IS NULL THEN
        RAISE EXCEPTION 'Hibák hozzáadása page not found';
    END IF;

    -- Get question IDs
    SELECT id INTO q_bird_damage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_defects_id AND name = 'bird_damage';

    SELECT id INTO q_wasp_nest_id
    FROM public.survey_questions
    WHERE survey_page_id = page_defects_id AND name = 'wasp_nest';

    SELECT id INTO q_structural_damage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_defects_id AND name = 'structural_damage';

    SELECT id INTO q_water_leakage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_defects_id AND name = 'water_leakage';

    -- Log which questions were found
    IF q_bird_damage_id IS NULL THEN
        RAISE NOTICE 'bird_damage question not found, skipping';
    END IF;

    IF q_wasp_nest_id IS NULL THEN
        RAISE NOTICE 'wasp_nest question not found, skipping';
    END IF;

    IF q_structural_damage_id IS NULL THEN
        RAISE NOTICE 'structural_damage question not found, skipping';
    END IF;

    IF q_water_leakage_id IS NULL THEN
        RAISE NOTICE 'water_leakage question not found, skipping';
    END IF;

    -- ========================================================================
    -- Add conditional info messages to defect questions (only if they exist)
    -- ========================================================================

    -- Madarak kártétele (bird_damage)
    IF q_bird_damage_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET conditional_info_messages = jsonb_build_array(
            jsonb_build_object(
                'condition', jsonb_build_object(
                    'field', 'self',
                    'operator', 'equals',
                    'value', 'true'
                ),
                'type', 'danger',
                'message_translations', jsonb_build_object(
                    'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                    'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
                )
            )
        )
        WHERE id = q_bird_damage_id;

        RAISE NOTICE 'Added conditional info message to bird_damage (Madarak kártétele)';
    END IF;

    -- Darázsfészek (wasp_nest)
    IF q_wasp_nest_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET conditional_info_messages = jsonb_build_array(
            jsonb_build_object(
                'condition', jsonb_build_object(
                    'field', 'self',
                    'operator', 'equals',
                    'value', 'true'
                ),
                'type', 'danger',
                'message_translations', jsonb_build_object(
                    'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                    'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
                )
            )
        )
        WHERE id = q_wasp_nest_id;

        RAISE NOTICE 'Added conditional info message to wasp_nest (Darázsfészek)';
    END IF;

    -- Statikai kár (structural_damage)
    IF q_structural_damage_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET conditional_info_messages = jsonb_build_array(
            jsonb_build_object(
                'condition', jsonb_build_object(
                    'field', 'self',
                    'operator', 'equals',
                    'value', 'true'
                ),
                'type', 'danger',
                'message_translations', jsonb_build_object(
                    'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                    'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
                )
            )
        )
        WHERE id = q_structural_damage_id;

        RAISE NOTICE 'Added conditional info message to structural_damage (Statikai kár)';
    END IF;

    -- Beázás (water_leakage)
    IF q_water_leakage_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET conditional_info_messages = jsonb_build_array(
            jsonb_build_object(
                'condition', jsonb_build_object(
                    'field', 'self',
                    'operator', 'equals',
                    'value', 'true'
                ),
                'type', 'danger',
                'message_translations', jsonb_build_object(
                    'hu', 'Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását megszünették, kijavították, addig nem folytatható a projekt!',
                    'en', 'The project cannot continue until the customer reports that the source of the defect has been eliminated and repaired!'
                )
            )
        )
        WHERE id = q_water_leakage_id;

        RAISE NOTICE 'Added conditional info message to water_leakage (Beázás)';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Attempted to add conditional info messages to attic defects:';
    IF q_bird_damage_id IS NOT NULL THEN
        RAISE NOTICE '   ✓ Madarak kártétele (bird_damage)';
    ELSE
        RAISE NOTICE '   ✗ Madarak kártétele (bird_damage) - not found';
    END IF;
    IF q_wasp_nest_id IS NOT NULL THEN
        RAISE NOTICE '   ✓ Darázsfészek (wasp_nest)';
    ELSE
        RAISE NOTICE '   ✗ Darázsfészek (wasp_nest) - not found';
    END IF;
    IF q_structural_damage_id IS NOT NULL THEN
        RAISE NOTICE '   ✓ Statikai kár (structural_damage)';
    ELSE
        RAISE NOTICE '   ✗ Statikai kár (structural_damage) - not found';
    END IF;
    IF q_water_leakage_id IS NOT NULL THEN
        RAISE NOTICE '   ✓ Beázás (water_leakage)';
    ELSE
        RAISE NOTICE '   ✗ Beázás (water_leakage) - not found';
    END IF;
    RAISE NOTICE '';
    RAISE NOTICE 'When these switches are checked (true), a danger icon with tooltip will appear';
    RAISE NOTICE 'Message: "Amíg az ügyfél nem jelentkezik újra, hogy a hiba forrását';
    RAISE NOTICE '          megszünették, kijavították, addig nem folytatható a projekt!"';
    RAISE NOTICE '';
    RAISE NOTICE 'Note: Only existing questions were updated. Questions not found were skipped.';

END $$;
