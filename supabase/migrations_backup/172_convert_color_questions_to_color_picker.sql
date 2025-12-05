-- ============================================================================
-- Migration: Convert Color Questions to Color Picker Type
-- Description: Part 2 - Converts color_code and foundation_plaster_color_code
--              questions to use the color_picker type with color palette
-- ============================================================================

DO $$
DECLARE
    page_facade_basic_data_id UUID;
    question_color_code_id UUID;
    question_foundation_plaster_color_id UUID;
    color_options JSONB;
BEGIN
    -- ========================================================================
    -- Prepare color options JSONB
    -- ========================================================================

    color_options := jsonb_build_object(
        '80008', 'rgb(169, 185, 197)',
        '80020', 'rgb(129, 180, 216)',
        '80031', 'rgb(162, 176, 203)',
        '80265', 'rgb(220, 178, 162)',
        '80301', 'rgb(223, 184, 156)',
        '80307', 'rgb(239, 199, 180)',
        '80331', 'rgb(241, 220, 210)',
        '80350', 'rgb(226, 185, 167)',
        '80379', 'rgb(196, 187, 180)',
        '80386', 'rgb(197, 188, 178)',
        '80391', 'rgb(219, 211, 204)',
        '80409', 'rgb(223, 202, 186)',
        '80417', 'rgb(201, 167, 134)',
        '80422', 'rgb(230, 191, 153)',
        '80427', 'rgb(227, 205, 183)',
        '80445', 'rgb(240, 198, 168)',
        '80457', 'rgb(244, 207, 169)',
        '80463', 'rgb(241, 210, 168)',
        '80499', 'rgb(221, 212, 198)',
        '80511', 'rgb(219, 211, 201)',
        '80538', 'rgb(176, 160, 138)',
        '80548', 'rgb(225, 208, 181)',
        '80562', 'rgb(199, 173, 130)',
        '80563', 'rgb(176, 162, 136)',
        '80697', 'rgb(222, 219, 201)',
        '80698', 'rgb(225, 210, 178)',
        '80706', 'rgb(197, 192, 175)',
        '80710', 'rgb(223, 215, 194)',
        '80716', 'rgb(204, 202, 196)',
        '80734', 'rgb(216, 217, 208)',
        '80739', 'rgb(231, 234, 218)',
        '80746', 'rgb(219, 220, 198)',
        '80757', 'rgb(237, 233, 213)',
        '80759', 'rgb(224, 216, 181)',
        '80867', 'rgb(190, 193, 179)',
        'fehér', 'rgb(255, 255, 255)'
    );

    -- ========================================================================
    -- Find facade_basic_data page
    -- ========================================================================

    SELECT sp.id INTO page_facade_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'facadeInsulation'
      AND sp.type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'facade_basic_data page not found for Facade Insulation investment';
    END IF;

    -- ========================================================================
    -- Update color_code question to color_picker type
    -- ========================================================================

    SELECT id INTO question_color_code_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'color_code';

    IF question_color_code_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET
            type = 'color_picker',
            options = color_options
        WHERE id = question_color_code_id;

        RAISE NOTICE 'Updated color_code question to color_picker type with color palette';
    ELSE
        RAISE NOTICE 'color_code question not found, skipping update';
    END IF;

    -- ========================================================================
    -- Update foundation_plaster_color_code question to color_picker type
    -- ========================================================================

    SELECT id INTO question_foundation_plaster_color_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'foundation_plaster_color_code';

    IF question_foundation_plaster_color_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET
            type = 'color_picker',
            options = color_options
        WHERE id = question_foundation_plaster_color_id;

        RAISE NOTICE 'Updated foundation_plaster_color_code question to color_picker type with color palette';
    ELSE
        RAISE NOTICE 'foundation_plaster_color_code question not found, skipping update';
    END IF;

    RAISE NOTICE 'Successfully converted color questions to color_picker type';

END $$;
