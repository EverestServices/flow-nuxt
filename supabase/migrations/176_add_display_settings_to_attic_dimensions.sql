-- ============================================================================
-- Migration: Add Display Settings to Attic Floor Dimension Questions
-- Description: Sets display_settings width to "1/3" for Szélesség, Hosszúság,
--              and Felület questions to display them side by side
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
    -- Update display_settings for dimension questions
    -- ========================================================================

    -- Szélesség (m)
    UPDATE public.survey_questions
    SET display_settings = jsonb_build_object('width', '1/3')
    WHERE survey_page_id = page_attic_data_id
      AND name = 'width';

    RAISE NOTICE 'Updated display_settings for width question';

    -- Hosszúság (m)
    UPDATE public.survey_questions
    SET display_settings = jsonb_build_object('width', '1/3')
    WHERE survey_page_id = page_attic_data_id
      AND name = 'length';

    RAISE NOTICE 'Updated display_settings for length question';

    -- Felület (m²)
    UPDATE public.survey_questions
    SET display_settings = jsonb_build_object('width', '1/3')
    WHERE survey_page_id = page_attic_data_id
      AND name = 'calculated_surface_area';

    RAISE NOTICE 'Updated display_settings for calculated_surface_area question';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully added display_settings to dimension questions';
    RAISE NOTICE 'All three questions now display with width: 1/3';
    RAISE NOTICE '========================================';

END $$;
