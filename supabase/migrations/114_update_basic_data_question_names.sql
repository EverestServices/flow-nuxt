-- ============================================================================
-- Migration: Update Basic Data Question Names
-- Description: Updates translations for specific questions in Basic Data
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
BEGIN
    -- Get Basic Data page
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- Update Question Translations
    -- ========================================================================

    -- 1. Épület típusa -> Ingatlan típusa
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Ingatlan típusa',
        'en', 'Property Type'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'building_type';

    -- 2. Építés ideje (év) -> Ingatlan építési éve
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Ingatlan építési éve',
        'en', 'Property Construction Year'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'construction_year';

    -- 3. Külső fal szerkezete (amennyiben minden fal megegyezik) -> Fal típusa
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Fal típusa',
        'en', 'Wall Type'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'exterior_wall_structure';

    -- 4. Külső fal szerkezetének pontos típusa -> Fal pontos típusa
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Fal pontos típusa',
        'en', 'Exact Wall Type'
    )
    WHERE survey_page_id = page_basic_data_id
      AND name = 'exterior_wall_structure_other';

    RAISE NOTICE 'Successfully updated Basic Data question names';

END $$;
