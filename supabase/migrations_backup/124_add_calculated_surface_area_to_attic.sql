-- ============================================================================
-- Migration: Add Calculated Surface Area to Attic Floor Insulation
-- Description: Adds a calculated field that displays width × length
--              as a read-only card below the "Hosszúság (m)" question
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Get the Attic Floor Insulation investment and page
    -- ========================================================================

    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Attic Floor Insulation investment not found (persist_name: roofInsulation)';
    END IF;

    SELECT id INTO page_attic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'attic_data';

    IF page_attic_data_id IS NULL THEN
        RAISE EXCEPTION 'Tetőtér adatai page not found';
    END IF;

    -- ========================================================================
    -- STEP 2: Shift sequences for questions after "Hosszúság (m)" (sequence 6)
    -- ========================================================================

    -- Shift all questions with sequence >= 7 by 1 position
    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_attic_data_id
      AND sequence >= 7;

    RAISE NOTICE 'Shifted question sequences to make room for calculated field';

    -- ========================================================================
    -- STEP 3: Insert the calculated surface area question
    -- ========================================================================

    -- Insert calculated field at sequence 7 (right after "Hosszúság (m)")
    -- The options field contains the calculation formula as JSON
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        sequence,
        options
    ) VALUES (
        page_attic_data_id,
        'calculated_surface_area',
        jsonb_build_object('hu', 'Felület (m²)', 'en', 'Surface Area (m²)'),
        'calculated',
        false,
        'm²',
        jsonb_build_object('hu', 'm²', 'en', 'm²'),
        7,
        jsonb_build_object(
            'operation', 'multiply',
            'fields', jsonb_build_array('width', 'length'),
            'decimals', 2
        )
    );

    RAISE NOTICE 'Added calculated surface area field at sequence 7';

    -- ========================================================================
    -- STEP 4: Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully added calculated surface area field';
    RAISE NOTICE 'Position: After "Hosszúság (m)" question';
    RAISE NOTICE 'Formula: width × length';
    RAISE NOTICE '========================================';

END $$;
