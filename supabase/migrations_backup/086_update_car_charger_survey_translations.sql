-- ============================================================================
-- Migration: Update Survey Translations for Car Charger Investment
-- Description: Update translations and sequences for Autótöltő investment
-- ============================================================================

-- ============================================================================
-- ELEKTROMOS AUTÓ ADATOK (ev_data)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'carCharger' AND sp.type = 'ev_data';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'ev_brand_select';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Márka', 'en', 'Brand') WHERE survey_page_id = page_id AND name = 'ev_brand_other';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Elektromos autó típusa', 'en', 'Electric Vehicle Type') WHERE survey_page_id = page_id AND name = 'ev_model';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Töltő csatlakozó típusa (Type1/Type2?)', 'en', 'Charger Connector Type (Type1/Type2?)') WHERE survey_page_id = page_id AND name = 'ev_connector_type';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Elektromos autó akkumulátor kapacitása (kWh)', 'en', 'Electric Vehicle Battery Capacity (kWh)') WHERE survey_page_id = page_id AND name = 'ev_battery_capacity';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Elektromos autó fedélzeti töltőjének teljesítménye', 'en', 'Electric Vehicle Onboard Charger Power') WHERE survey_page_id = page_id AND name = 'onboard_charger_title';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Teljesítmény', 'en', 'Power') WHERE survey_page_id = page_id AND name = 'onboard_charger_power';
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Fázis', 'en', 'Phase') WHERE survey_page_id = page_id AND name = 'onboard_charger_phase';
        UPDATE public.survey_questions SET sequence = 9, name_translations = jsonb_build_object('hu', 'Amper', 'en', 'Ampere') WHERE survey_page_id = page_id AND name = 'onboard_charger_ampere';
    END IF;
END $$;

-- ============================================================================
-- HELYSZÍN ADATOK (location)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'carCharger' AND sp.type = 'location';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Telepítés helye', 'en', 'Installation Location') WHERE survey_page_id = page_id AND name = 'installation_site_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Tulajdoni viszony', 'en', 'Ownership Status') WHERE survey_page_id = page_id AND name = 'ownership';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Telepítési helyszín hozzáférhetősége', 'en', 'Installation Site Accessibility') WHERE survey_page_id = page_id AND name = 'site_access';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Telepítési helyszín jellege', 'en', 'Installation Site Nature') WHERE survey_page_id = page_id AND name = 'site_nature';
    END IF;
END $$;

-- ============================================================================
-- TELJESÍTMÉNYBŐVÍTÉS (power_upgrade)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'carCharger' AND sp.type = 'power_upgrade';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Ügyfél tervez teljesítménybővítést a belső hálózatán?', 'en', 'Does the client plan a power upgrade for the internal network?') WHERE survey_page_id = page_id AND name = 'plans_internal_upgrade';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Ingatlanról és telepítési helyszínről kapcsolási rajz, villamossági terv rendelkezésre áll?', 'en', 'Is wiring diagram and electrical plan available for property and installation site?') WHERE survey_page_id = page_id AND name = 'has_wiring_plan';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Tervezett töltőhely villamosenergia ellátása megfelelő?', 'en', 'Is the electrical supply for the planned charging location adequate?') WHERE survey_page_id = page_id AND name = 'power_supply_ok';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Tervezett töltőhely kialakítása megfelelő, a szükséges rögzítési felület és kábelezés rendelkezésre áll?', 'en', 'Is the planned charging location properly configured, with necessary mounting surface and wiring available?') WHERE survey_page_id = page_id AND name = 'site_prepared_ok';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Felszerelési hely kiépítésének jellege – ha szükséges:', 'en', 'Installation site construction nature – if necessary:') WHERE survey_page_id = page_id AND name = 'mounting_surface_type';
    END IF;
END $$;

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Car Charger investment survey translations and sequences updated successfully';
END $$;
