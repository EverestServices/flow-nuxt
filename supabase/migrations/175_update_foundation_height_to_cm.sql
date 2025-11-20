-- ============================================================================
-- Migration: Update Foundation Height to Centimeters
-- Description: Updates "Lábazat magassága" question on Walls page
--              - Change label from (m) to (cm)
--              - Change unit from "m" to "cm"
--              - Set minimum value to 0
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    q_foundation_height_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Walls page ID
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- Get foundation_height question ID
    SELECT id INTO q_foundation_height_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id AND name = 'foundation_height';

    IF q_foundation_height_id IS NULL THEN
        RAISE EXCEPTION 'foundation_height question not found';
    END IF;

    -- ========================================================================
    -- Update foundation_height question
    -- ========================================================================

    UPDATE public.survey_questions
    SET
        name_translations = jsonb_build_object(
            'hu', 'Lábazat magassága (cm)',
            'en', 'Foundation Height (cm)'
        ),
        unit = 'cm',
        unit_translations = jsonb_build_object('hu', 'cm', 'en', 'cm'),
        min = 0
    WHERE id = q_foundation_height_id;

    RAISE NOTICE '✅ Successfully updated foundation_height question:';
    RAISE NOTICE '   - Label: "Lábazat magassága (m)" -> "Lábazat magassága (cm)"';
    RAISE NOTICE '   - Unit: "m" -> "cm"';
    RAISE NOTICE '   - Min: unset -> 0';

END $$;
