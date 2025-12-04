-- ============================================================================
-- Migration: Add Reveal Depth Question to Basic Data
-- Description: Adds "Káva mélység (cm)" question to Basic Data page
--              after "Ki/beugrás mérete (cm)" question
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
    -- STEP 1: Update existing question sequences (shift by 1)
    -- ========================================================================

    -- Shift questions from sequence 15 onwards by 1 position
    UPDATE public.survey_questions
    SET sequence = sequence + 1
    WHERE survey_page_id = page_basic_data_id
      AND sequence >= 15;

    -- ========================================================================
    -- STEP 2: Add New Survey Question
    -- ========================================================================

    -- 15. Káva mélység (cm) (amennyiben mindenhol megegyezik)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations,
        sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'reveal_depth_uniform',
        jsonb_build_object(
            'hu', 'Káva mélység (cm) (amennyiben mindenhol megegyezik)',
            'en', 'Reveal Depth (cm) (if the same everywhere)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        'Káva mélység',
        jsonb_build_object('hu', 'Káva mélység', 'en', 'Reveal Depth'),
        15,
        jsonb_build_object(
            'hu', 'A homlokzati sík, és a meglévő ablaktok vízszintesen mért távolsága, jellemzően 10-20 cm közötti érték. Más szóval az ablakpárkány mélysége, a falon túlnyúló cseppentő levonásával.',
            'en', 'The horizontal distance between the facade plane and existing windows, typically 10-20 cm. In other words, the depth of the window sill, minus any protruding drip edge.'
        )
    );

    RAISE NOTICE 'Successfully added reveal_depth_uniform question to Basic Data';

END $$;
