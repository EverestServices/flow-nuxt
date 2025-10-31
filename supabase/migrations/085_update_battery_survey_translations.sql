-- ============================================================================
-- Migration: Update Survey Translations for Battery Investment
-- Description: Apply same translations and sequences as solarPanelBattery
--              from migration 078 to standalone battery investment
-- ============================================================================

-- ============================================================================
-- AKKUMULÁTOR (Battery)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'battery' AND sp.type = 'battery';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Elhelyezésre rendelkezésre álló terület a földön (m²)', 'en', 'Available Space on Floor (m²)') WHERE survey_page_id = page_id AND name = 'available_space';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Telepítés helyszínén 0 fok felett van télen is?', 'en', 'Installation Site Above 0°C Even in Winter?') WHERE survey_page_id = page_id AND name = 'temperature_above_zero';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Inverter és akkumulátor távolsága, DC kábel hossza (m)', 'en', 'Inverter and Battery Distance, DC Cable Length (m)') WHERE survey_page_id = page_id AND name = 'inverter_battery_distance';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Tűzeseti leválasztó', 'en', 'Fire Disconnect') WHERE survey_page_id = page_id AND name = 'fire_disconnect';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Inverter és a főelosztó között megoldható az elvezetés', 'en', 'Routing Between Inverter and Main Distributor Possible') WHERE survey_page_id = page_id AND name = 'main_distributor_routing';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Smart Meter telepítéshez szükséges hely a főelosztóban', 'en', 'Space for Smart Meter Installation in Main Distributor') WHERE survey_page_id = page_id AND name = 'smart_meter_space';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Inverter és Smart Meter távolsága, RS 485 kábel hossza (m)', 'en', 'Inverter and Smart Meter Distance, RS 485 Cable Length (m)') WHERE survey_page_id = page_id AND name = 'smart_meter_distance';
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Nyomvonal (kifejtős)', 'en', 'Route (Detailed)') WHERE survey_page_id = page_id AND name = 'routing_description';
    END IF;
END $$;

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Battery investment survey translations and sequences updated successfully';
END $$;
