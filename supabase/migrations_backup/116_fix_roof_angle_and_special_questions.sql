-- ============================================================================
-- Migration: Fix Roof Angle Type and Move Questions to Special Accordion
-- Description: Changes roof_angle to slider type and marks certain questions
--              as special to display them in "Egyéb kérdések" accordion
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
    -- STEP 1: Change roof_angle type from range to slider
    -- ========================================================================

    UPDATE public.survey_questions
    SET type = 'slider'
    WHERE survey_page_id = page_basic_data_id
      AND name = 'roof_angle';

    RAISE NOTICE 'Changed roof_angle type to slider';

    -- ========================================================================
    -- STEP 2: Mark "Egyéb adatok" section questions as special
    -- ========================================================================

    -- Mark the following questions as special (is_special = true):
    -- - building_protected
    -- - building_protection_type
    -- - general_notes
    -- - building_useful_floor_area
    -- - window_door_type

    UPDATE public.survey_questions
    SET is_special = true
    WHERE survey_page_id = page_basic_data_id
      AND name IN (
        'building_protected',
        'building_protection_type',
        'general_notes',
        'building_useful_floor_area',
        'window_door_type'
      );

    RAISE NOTICE 'Marked "Egyéb adatok" questions as special';

    -- ========================================================================
    -- STEP 3: Remove "Egyéb adatok" title (optional - comment out if needed)
    -- ========================================================================

    -- The title "Egyéb adatok" is no longer needed since questions will
    -- appear in the "Special Questions Accordion" with the label
    -- "Egyéb kérdések" from translations

    DELETE FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id
      AND name = 'additional_data_title';

    RAISE NOTICE 'Removed "Egyéb adatok" title';

    RAISE NOTICE 'Successfully fixed roof angle and moved questions to special accordion';

END $$;
