-- ============================================================================
-- Migration: Add Missing Translations
-- Description: Adds name_translations for fields that were missing them
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
    -- Update heat emitter fields
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Padlófűtés',
        'en', 'Underfloor Heating'
    )
    WHERE survey_page_id = page_id AND name = 'heat_emitter_underfloor_heating';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Falfűtés',
        'en', 'Wall Heating'
    )
    WHERE survey_page_id = page_id AND name = 'heat_emitter_wall_heating';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Mennyezetfűtés',
        'en', 'Ceiling Heating'
    )
    WHERE survey_page_id = page_id AND name = 'heat_emitter_ceiling_heating';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Konvektor',
        'en', 'Convector'
    )
    WHERE survey_page_id = page_id AND name = 'heat_emitter_convector';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Fan coil',
        'en', 'Fan Coil'
    )
    WHERE survey_page_id = page_id AND name = 'heat_emitter_fan_coil';

    -- ========================================================================
    -- Update renewable energy fields
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Napkollektor',
        'en', 'Solar Collector'
    )
    WHERE survey_page_id = page_id AND name = 'renewable_solar_collector';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Szélkerék',
        'en', 'Wind Turbine'
    )
    WHERE survey_page_id = page_id AND name = 'renewable_wind_turbine';

    -- ========================================================================
    -- Update air conditioner fields
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Multi split klíma',
        'en', 'Multi Split AC'
    )
    WHERE survey_page_id = page_id AND name = 'air_conditioner_multi_split';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Hőszivattyús klíma',
        'en', 'Heat Pump AC'
    )
    WHERE survey_page_id = page_id AND name = 'air_conditioner_heat_pump';

    RAISE NOTICE 'Added translations for heat emitter fields';
    RAISE NOTICE 'Added translations for renewable energy fields';
    RAISE NOTICE 'Added translations for air conditioner fields';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
