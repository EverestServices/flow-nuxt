-- ============================================================================
-- Migration: Add New Heat Emitter and Energy Questions
-- Description: Adds new questions after "Fűtési hőleadók típusa" title
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
    -- Step 1: Delete old renewable and air conditioner questions
    -- ========================================================================
    DELETE FROM public.survey_questions
    WHERE survey_page_id = page_id
    AND name IN (
        'renewable_solar_panel',
        'renewable_solar_collector',
        'renewable_wind_turbine',
        'air_conditioner_split',
        'air_conditioner_multi_split',
        'air_conditioner_heat_pump'
    );

    RAISE NOTICE 'Deleted old renewable and air conditioner questions';

    -- ========================================================================
    -- Step 2: Add heat emitter questions (sequence 31-36)
    -- ========================================================================

    -- Radiátorok termosztatikus szabályozással
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'radiators_with_thermostat',
        jsonb_build_object('hu', 'Radiátorok termosztatikus szabályozással', 'en', 'Radiators with Thermostatic Control'),
        'number',
        false,
        31,
        0,
        100,
        'db'
    );

    -- Radiátorok termosztatikus szabályozás nélkül
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'radiators_without_thermostat',
        jsonb_build_object('hu', 'Radiátorok termosztatikus szabályozás nélkül', 'en', 'Radiators without Thermostatic Control'),
        'number',
        false,
        32,
        0,
        100,
        'db'
    );

    -- Padlófűtés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'underfloor_heating',
        jsonb_build_object('hu', 'Padlófűtés', 'en', 'Underfloor Heating'),
        'number',
        false,
        33,
        0,
        500,
        'm²'
    );

    -- Falfűtés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'wall_heating',
        jsonb_build_object('hu', 'Falfűtés', 'en', 'Wall Heating'),
        'number',
        false,
        34,
        0,
        500,
        'm²'
    );

    -- Mennyezetfűtés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'ceiling_heating',
        jsonb_build_object('hu', 'Mennyezetfűtés', 'en', 'Ceiling Heating'),
        'number',
        false,
        35,
        0,
        500,
        'm²'
    );

    -- Fan-coil
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'fan_coil',
        jsonb_build_object('hu', 'Fan-coil', 'en', 'Fan Coil'),
        'number',
        false,
        36,
        0,
        50,
        'db'
    );

    -- ========================================================================
    -- Step 3: Add renewable energy section (sequence 37-39)
    -- ========================================================================

    -- Megújulóenergia alapú energiatermelés (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_id,
        'renewable_energy_title',
        jsonb_build_object('hu', 'Megújulóenergia alapú energiatermelés', 'en', 'Renewable Energy Production'),
        'title',
        false,
        37
    );

    -- Napelemek éves villamos energia termelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'solar_panel_annual_production',
        jsonb_build_object('hu', 'Napelemek éves villamos energia termelése', 'en', 'Solar Panels Annual Electricity Production'),
        'number',
        false,
        38,
        0,
        50000,
        'kWh/év'
    );

    -- Tűzifa felhasználás saját vágásból
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'firewood_own_cutting',
        jsonb_build_object('hu', 'Tűzifa felhasználás saját vágásból', 'en', 'Firewood from Own Cutting'),
        'number',
        false,
        39,
        0,
        20000,
        'kg/év'
    );

    -- ========================================================================
    -- Step 4: Add air conditioning section (sequence 40-45)
    -- ========================================================================

    -- Klíma készülékek (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_id,
        'air_conditioning_title',
        jsonb_build_object('hu', 'Klíma készülékek', 'en', 'Air Conditioning Devices'),
        'title',
        false,
        40
    );

    -- Split klíma
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'split_ac',
        jsonb_build_object('hu', 'Split klíma', 'en', 'Split AC'),
        'number',
        false,
        41,
        0,
        20,
        'db'
    );

    -- Mobil klíma
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'mobile_ac',
        jsonb_build_object('hu', 'Mobil klíma', 'en', 'Mobile AC'),
        'number',
        false,
        42,
        0,
        20,
        'db'
    );

    -- Központi hűtőgépes fan-coil
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'central_cooling_fan_coil',
        jsonb_build_object('hu', 'Központi hűtőgépes fan-coil', 'en', 'Central Cooling Fan Coil'),
        'number',
        false,
        43,
        0,
        50,
        'db'
    );

    -- Hőszivattyú
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'heat_pump',
        jsonb_build_object('hu', 'Hőszivattyú', 'en', 'Heat Pump'),
        'number',
        false,
        44,
        0,
        100,
        'kW'
    );

    -- Ventilátor
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_id,
        'fan',
        jsonb_build_object('hu', 'Ventilátor', 'en', 'Fan'),
        'number',
        false,
        45,
        0,
        50,
        'db'
    );

    RAISE NOTICE 'Added 6 heat emitter questions (seq 31-36)';
    RAISE NOTICE 'Added renewable energy section (seq 37-39)';
    RAISE NOTICE 'Added air conditioning section (seq 40-45)';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
