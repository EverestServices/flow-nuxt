-- ============================================================================
-- Migration: Update Attic Data Questions
-- Description: Removes "Padlástér tervezett hasznosítása" question
--              and removes "Padlap + EPS (16+5 cm)" option from
--              "Tervezett hőszigetelés típusa" question
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
    q_planned_usage_id UUID;
    q_planned_insulation_type_id UUID;
    deleted_answers_count INTEGER;
BEGIN
    -- Get Padlásfödém szigetelés investment ID
    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Padlásfödém szigetelés investment not found';
    END IF;

    -- Get Tetőtér adatai page ID
    SELECT id INTO page_attic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id AND type = 'attic_data';

    IF page_attic_data_id IS NULL THEN
        RAISE EXCEPTION 'Tetőtér adatai page not found';
    END IF;

    -- Get question IDs
    SELECT id INTO q_planned_usage_id
    FROM public.survey_questions
    WHERE survey_page_id = page_attic_data_id AND name = 'planned_usage';

    SELECT id INTO q_planned_insulation_type_id
    FROM public.survey_questions
    WHERE survey_page_id = page_attic_data_id AND name = 'planned_insulation_type';

    -- ========================================================================
    -- STEP 1: Delete "Padlástér tervezett hasznosítása" question
    -- ========================================================================

    IF q_planned_usage_id IS NOT NULL THEN
        -- Delete all survey answers for this question
        WITH deleted AS (
            DELETE FROM public.survey_answers
            WHERE survey_question_id = q_planned_usage_id
            RETURNING *
        )
        SELECT COUNT(*) INTO deleted_answers_count FROM deleted;

        RAISE NOTICE 'Deleted % survey answers for planned_usage question', deleted_answers_count;

        -- Shift sequence numbers for questions after planned_usage (sequence > 10)
        UPDATE public.survey_questions
        SET sequence = sequence - 1
        WHERE survey_page_id = page_attic_data_id
          AND sequence > 10;

        RAISE NOTICE 'Shifted sequence numbers for questions after planned_usage';

        -- Delete the question itself
        DELETE FROM public.survey_questions
        WHERE id = q_planned_usage_id;

        RAISE NOTICE 'Deleted planned_usage question';
    ELSE
        RAISE NOTICE 'planned_usage question not found, skipping deletion';
    END IF;

    -- ========================================================================
    -- STEP 2: Update "Tervezett hőszigetelés típusa" question
    -- ========================================================================

    IF q_planned_insulation_type_id IS NOT NULL THEN
        -- Remove "Padlap + EPS (16+5 cm)" option from options_translations
        -- Keep only the other options
        UPDATE public.survey_questions
        SET options_translations = jsonb_build_array(
            jsonb_build_object(
                'value', 'Könnyűbeton lapok (12 cm)',
                'label', jsonb_build_object(
                    'hu', 'Könnyűbeton lapok (12 cm)',
                    'en', 'Lightweight Concrete Slabs (12 cm)'
                )
            ),
            jsonb_build_object(
                'value', 'EPS lapok (16 cm)',
                'label', jsonb_build_object(
                    'hu', 'EPS lapok (16 cm)',
                    'en', 'EPS Slabs (16 cm)'
                )
            ),
            jsonb_build_object(
                'value', 'Kőzetgyapot (16 cm)',
                'label', jsonb_build_object(
                    'hu', 'Kőzetgyapot (16 cm)',
                    'en', 'Rock Wool (16 cm)'
                )
            ),
            jsonb_build_object(
                'value', 'Fújtgyapot (16 cm)',
                'label', jsonb_build_object(
                    'hu', 'Fújtgyapot (16 cm)',
                    'en', 'Blown Wool (16 cm)'
                )
            )
        )
        WHERE id = q_planned_insulation_type_id;

        RAISE NOTICE 'Updated planned_insulation_type question: removed "Padlap + EPS (16+5 cm)" option';
    ELSE
        RAISE NOTICE 'planned_insulation_type question not found, skipping update';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully updated Tetőtér adatai page:';
    RAISE NOTICE '   1. Deleted "Padlástér tervezett hasznosítása" question';
    RAISE NOTICE '      - Deleted % survey answers', deleted_answers_count;
    RAISE NOTICE '      - Shifted sequence numbers';
    RAISE NOTICE '   2. Updated "Tervezett hőszigetelés típusa" options:';
    RAISE NOTICE '      - Removed "Padlap + EPS (16+5 cm)" option';
    RAISE NOTICE '      - Remaining options: 4 (Könnyűbeton, EPS, Kőzetgyapot, Fújtgyapot)';

END $$;
