-- ============================================================================
-- Migration: Update Heat Emitter Section
-- Description: Changes heat_emitter_radiator to title type and removes
--              old heat emitter questions
-- ============================================================================

DO $$
DECLARE
    inv_id UUID;
    page_id UUID;
BEGIN
    -- Get consultant mode investment ID
    SELECT id INTO inv_id FROM public.investments WHERE persist_name = 'consultantMode';

    IF inv_id IS NULL THEN
        RAISE EXCEPTION 'Consultant mode investment not found';
    END IF;

    -- Get the energy consumption page ID
    SELECT id INTO page_id FROM public.survey_pages
    WHERE investment_id = inv_id AND name = 'Energiafelhasználási adatok';

    IF page_id IS NULL THEN
        RAISE EXCEPTION 'Energy consumption page not found';
    END IF;

    -- ========================================================================
    -- Step 1: Update heat_emitter_radiator to be a title
    -- ========================================================================
    UPDATE public.survey_questions
    SET type = 'title',
        min = NULL,
        max = NULL,
        unit = NULL,
        unit_translations = NULL
    WHERE survey_page_id = page_id
    AND name = 'heat_emitter_radiator';

    RAISE NOTICE 'Changed heat_emitter_radiator to title type';

    -- ========================================================================
    -- Step 2: Delete old heat emitter questions
    -- ========================================================================
    DELETE FROM public.survey_questions
    WHERE survey_page_id = page_id
    AND name IN (
        'heat_emitter_underfloor_heating',
        'heat_emitter_wall_heating',
        'heat_emitter_ceiling_heating',
        'heat_emitter_convector',
        'heat_emitter_fan_coil'
    );

    RAISE NOTICE 'Deleted old heat emitter questions';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
