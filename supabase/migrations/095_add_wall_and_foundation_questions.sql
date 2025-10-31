-- ============================================================================
-- Migration: Add Wall and Foundation Questions to Basic Data
-- Description: Adds wall thickness, foundation type, protrusion size, and foundation height
--              questions to the Basic Data investment, after the exterior wall structure questions.
--              Also adds info messages to foundation type and foundation height questions.
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
BEGIN
    -- Get the Basic Data survey page ID
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Update existing question sequences (shift by 4)
    -- ========================================================================

    -- Shift questions from sequence 11 onwards by 4 positions
    UPDATE public.survey_questions
    SET sequence = sequence + 4
    WHERE survey_page_id = page_basic_data_id
      AND sequence >= 11;

    -- ========================================================================
    -- STEP 2: Add New Survey Questions
    -- ========================================================================

    -- 11. Fal vastagsága (cm) (amennyiben minden fal megegyezik)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'wall_thickness_uniform',
        jsonb_build_object(
            'hu', 'Fal vastagsága (cm) (amennyiben minden fal megegyezik)',
            'en', 'Wall Thickness (cm) (if all walls are the same)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Fal vastagsága',
        jsonb_build_object('hu', 'Fal vastagsága', 'en', 'Wall Thickness'),
        11
    );

    -- 12. Lábazat magassága (m) (amennyiben mindenhol megegyezik)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations,
        sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'foundation_height_uniform',
        jsonb_build_object(
                'hu', 'Lábazat magassága (m) (amennyiben mindenhol megegyezik)',
                'en', 'Foundation Height (m) (if the same everywhere)'
        ),
        'number',
        false,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        'Lábazat magassága',
        jsonb_build_object('hu', 'Lábazat magassága', 'en', 'Foundation Height'),
        12,
        jsonb_build_object(
                'hu', 'Csatlakozó járdától lábazat tetejéig. Lejtős terepen legkisebb-, és legnagyobb mért magasság számtani közepe.',
                'en', 'From adjacent pavement to the top of the foundation. On sloped terrain, the arithmetic mean of the smallest and largest measured heights.'
        )
     );

    -- 13. Lábazat típusa (amennyiben mindenhol megegyezik)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'foundation_type_uniform',
        jsonb_build_object(
            'hu', 'Lábazat típusa (amennyiben mindenhol megegyezik)',
            'en', 'Foundation Type (if the same everywhere)'
        ),
        'dropdown',
        false,
        jsonb_build_array('Pozitív', 'Negatív'),
        13,
        jsonb_build_object(
            'hu', 'Pozitív ha a homlokzati falsíktól kintebb áll, negatív ha mögötte van.',
            'en', 'Positive if it protrudes from the facade plane, negative if it is recessed.'
        )
    );

    -- 14. Ki/beugrás mérete (cm) (amennyiben mindenhol megegyezik)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'protrusion_size_uniform',
        jsonb_build_object(
            'hu', 'Ki/beugrás mérete (cm) (amennyiben mindenhol megegyezik)',
            'en', 'Protrusion/Recess Size (cm) (if the same everywhere)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Ki/beugrás mérete',
        jsonb_build_object('hu', 'Ki/beugrás mérete', 'en', 'Protrusion/Recess Size'),
        14
    );



    RAISE NOTICE 'Successfully added wall and foundation questions to Basic Data';

END $$;
