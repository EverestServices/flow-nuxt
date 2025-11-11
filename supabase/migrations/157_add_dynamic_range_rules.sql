-- ============================================================================
-- Migration: Add Dynamic Range Rules for Slider Questions
-- Description: Adds dynamic_range_rules field to survey_questions table
--              and configures roof_angle question to have dynamic min/max
--              based on roof_type_general value
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    q_roof_angle_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Add dynamic_range_rules column to survey_questions
    -- ========================================================================

    ALTER TABLE public.survey_questions
    ADD COLUMN IF NOT EXISTS dynamic_range_rules JSONB DEFAULT NULL;

    RAISE NOTICE 'Added dynamic_range_rules column to survey_questions table';

    -- ========================================================================
    -- STEP 2: Configure dynamic range for roof_angle question
    -- ========================================================================

    -- Get Basic Data page from Basic Data investment
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- Get roof_angle question ID
    SELECT id INTO q_roof_angle_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id
      AND name = 'roof_angle';

    IF q_roof_angle_id IS NULL THEN
        RAISE EXCEPTION 'roof_angle question not found';
    END IF;

    -- Set dynamic range rules for roof_angle
    -- Rules:
    -- - "Lapostető" -> range: 0-5
    -- - "Alacsony hajlásszögű tető" -> range: 5-25
    -- - Any other value -> range: 25-60
    UPDATE public.survey_questions
    SET dynamic_range_rules = jsonb_build_object(
        'based_on_field', 'roof_type_general',
        'rules', jsonb_build_array(
            jsonb_build_object(
                'when', 'Lapostető',
                'min', 0,
                'max', 5
            ),
            jsonb_build_object(
                'when', 'Alacsony hajlásszögű tető',
                'min', 5,
                'max', 25
            )
        ),
        'default', jsonb_build_object(
            'min', 25,
            'max', 60
        )
    )
    WHERE id = q_roof_angle_id;

    RAISE NOTICE 'Configured dynamic range rules for roof_angle question';
    RAISE NOTICE 'Rules: Lapostető (0-5), Alacsony hajlásszögű tető (5-25), Default (25-60)';

END $$;
