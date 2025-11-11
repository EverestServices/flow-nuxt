-- ============================================================================
-- Migration: Update Foundation Insulated to Icon Selector
-- Description: Converts "Lábazat hőszigetelt" (foundation_insulated_general)
--              from switch to icon_selector on Facade Basic Data page
--              and updates dependent questions' display conditions on Walls page
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    page_walls_id UUID;
    q_foundation_insulated_id UUID;
    q_existing_material_id UUID;
    q_existing_material_other_id UUID;
    q_existing_thickness_id UUID;
    updated_answers_count INTEGER;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Facade Basic Data page ID
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data page not found';
    END IF;

    -- Get Walls page ID (for dependent questions)
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- Get question IDs
    -- Main question is on facade_basic_data page with name foundation_insulated_general
    SELECT id INTO q_foundation_insulated_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulated_general';

    -- Dependent questions are on walls page
    SELECT id INTO q_existing_material_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'existing_insulation_material';

    SELECT id INTO q_existing_material_other_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'existing_insulation_material_other';

    SELECT id INTO q_existing_thickness_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'existing_insulation_thickness';

    IF q_foundation_insulated_id IS NULL THEN
        RAISE EXCEPTION 'foundation_insulated_general question not found on Facade Basic Data page';
    END IF;

    -- ========================================================================
    -- STEP 1: Convert existing answers from boolean to new values
    -- ========================================================================

    -- Convert "true" -> "Szigetelt"
    WITH updated AS (
        UPDATE public.survey_answers
        SET answer = 'Szigetelt'
        WHERE survey_question_id = q_foundation_insulated_id
          AND (answer = 'true' OR answer = 't')
        RETURNING *
    )
    SELECT COUNT(*) INTO updated_answers_count FROM updated;

    RAISE NOTICE 'Converted % answers from "true" to "Szigetelt"', updated_answers_count;

    -- Convert "false" -> "Nem szigetelt"
    WITH updated AS (
        UPDATE public.survey_answers
        SET answer = 'Nem szigetelt'
        WHERE survey_question_id = q_foundation_insulated_id
          AND (answer = 'false' OR answer = 'f')
        RETURNING *
    )
    SELECT COUNT(*) INTO updated_answers_count FROM updated;

    RAISE NOTICE 'Converted % answers from "false" to "Nem szigetelt"', updated_answers_count;

    -- ========================================================================
    -- STEP 2: Update foundation_insulated question to icon_selector
    -- ========================================================================

    UPDATE public.survey_questions
    SET
        type = 'icon_selector',
        name_translations = jsonb_build_object(
            'hu', 'Lábazat hőszigetelt?',
            'en', 'Is Foundation Insulated?'
        ),
        options_translations = jsonb_build_array(
            jsonb_build_object(
                'value', 'Szigetelt',
                'label', jsonb_build_object('hu', 'Szigetelt', 'en', 'Insulated'),
                'icon', 'i-lucide-shield-check'
            ),
            jsonb_build_object(
                'value', 'Nem szigetelt',
                'label', jsonb_build_object('hu', 'Nem szigetelt', 'en', 'Not Insulated'),
                'icon', 'i-lucide-shield-x'
            )
        ),
        default_value = 'Nem szigetelt'
    WHERE id = q_foundation_insulated_id;

    RAISE NOTICE 'Updated foundation_insulated to icon_selector type';

    -- ========================================================================
    -- STEP 3: Update dependent questions display conditions
    -- ========================================================================

    -- Update existing_insulation_material display condition
    IF q_existing_material_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET display_conditions = jsonb_build_object(
            'field', 'foundation_insulated_general',
            'operator', 'equals',
            'value', 'Szigetelt'
        )
        WHERE id = q_existing_material_id;

        RAISE NOTICE 'Updated existing_insulation_material display condition';
    END IF;

    -- Update existing_insulation_thickness display condition
    IF q_existing_thickness_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET display_conditions = jsonb_build_object(
            'field', 'foundation_insulated_general',
            'operator', 'equals',
            'value', 'Szigetelt'
        )
        WHERE id = q_existing_thickness_id;

        RAISE NOTICE 'Updated existing_insulation_thickness display condition';
    END IF;

    -- ========================================================================
    -- STEP 4: Update question names/labels
    -- ========================================================================

    -- Update existing_insulation_material_other label
    IF q_existing_material_other_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET name_translations = jsonb_build_object(
            'hu', 'Meglévő hőszigetelés pontos anyaga',
            'en', 'Exact Existing Insulation Material'
        )
        WHERE id = q_existing_material_other_id;

        RAISE NOTICE 'Updated existing_insulation_material_other label';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully updated foundation insulation questions:';
    RAISE NOTICE '   1. Converted foundation_insulated_general from switch to icon_selector';
    RAISE NOTICE '      - Location: Homlokzati szigetelés alapadatok page';
    RAISE NOTICE '      - Options: "Szigetelt" (i-lucide-shield-check), "Nem szigetelt" (i-lucide-shield-x)';
    RAISE NOTICE '      - Label: "Lábazat hőszigetelt?" (with question mark)';
    RAISE NOTICE '   2. Updated all existing answers';
    RAISE NOTICE '   3. Updated display conditions for dependent questions on Walls page';
    RAISE NOTICE '      - Field name in conditions: foundation_insulated_general';
    RAISE NOTICE '   4. Updated "Meglévő hőszigetelés pontos anyaga" label';

END $$;
