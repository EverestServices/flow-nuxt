-- ============================================================================
-- Migration: Add Non-Insulated Area Question
-- Description: Adds "Nem szigetelendő felületek összege (m2)" question
--              after "Hosszúság (m)" in Tetőtér adatai page
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
BEGIN
    -- ========================================================================
    -- Find Investment and Page
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

    -- ========================================================================
    -- Shift sequences for questions at position 7 and above
    -- ========================================================================

    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_attic_data_id
      AND sequence >= 7;

    RAISE NOTICE 'Shifted sequences for questions at position 7 and above';

    -- ========================================================================
    -- Insert new question at sequence 7
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        sequence
    ) VALUES (
        page_attic_data_id,
        'non_insulated_area',
        jsonb_build_object(
            'hu', 'Nem szigetelendő felületek összege (m2)',
            'en', 'Total non-insulated surfaces (m2)'
        ),
        'number',
        false,
        'm2',
        jsonb_build_object('hu', 'm2', 'en', 'm2'),
        7
    );

    RAISE NOTICE 'Added non_insulated_area question at sequence 7';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully added non-insulated area question';
    RAISE NOTICE 'New question inserted at sequence 7';
    RAISE NOTICE 'All subsequent questions shifted by 1';
    RAISE NOTICE '========================================';

END $$;
