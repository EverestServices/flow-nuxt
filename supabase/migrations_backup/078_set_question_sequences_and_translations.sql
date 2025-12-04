-- Add sequence field to survey_questions table
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS sequence INTEGER DEFAULT 0;

COMMENT ON COLUMN public.survey_questions.sequence IS 'Display order of questions within a page';

-- ============================================================================
-- ÁLTALÁNOS ADATOK (general) - Napelem + Akkumulátor, Napelem, Klíma
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'default_roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Mértékegység', 'en', 'Unit') WHERE survey_page_id = page_id AND name = 'consumption_unit_toggle';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Időszak', 'en', 'Period') WHERE survey_page_id = page_id AND name = 'consumption_period_toggle';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Fogyasztás', 'en', 'Consumption') WHERE survey_page_id = page_id AND name = 'annual_consumption';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'vehicle_access';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'electrical_network_condition';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'external_insulation';
        UPDATE public.survey_questions SET sequence = 10, name_translations = jsonb_build_object('hu', 'Külső hőszigetelés vastagsága (cm)', 'en', 'External Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'insulation_thickness';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'available_power_title';
        UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_id AND name = 'phase_count';
        UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_id AND name = 'phase_1';
        UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_id AND name = 'phase_2';
        UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_id AND name = 'phase_3';
        UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_id AND name = 'fi_relay';
        UPDATE public.survey_questions SET sequence = 17, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Comment') WHERE survey_page_id = page_id AND name = 'general_comments';
        -- Egyéb kérdés
        UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_id AND name = 'difficult_access';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'default_roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Mértékegység', 'en', 'Unit') WHERE survey_page_id = page_id AND name = 'consumption_unit_toggle';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Időszak', 'en', 'Period') WHERE survey_page_id = page_id AND name = 'consumption_period_toggle';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Fogyasztás', 'en', 'Consumption') WHERE survey_page_id = page_id AND name = 'annual_consumption';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'vehicle_access';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'electrical_network_condition';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'external_insulation';
        UPDATE public.survey_questions SET sequence = 10, name_translations = jsonb_build_object('hu', 'Külső hőszigetelés vastagsága (cm)', 'en', 'External Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'insulation_thickness';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'available_power_title';
        UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_id AND name = 'phase_count';
        UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_id AND name = 'phase_1';
        UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_id AND name = 'phase_2';
        UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_id AND name = 'phase_3';
        UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_id AND name = 'fi_relay';
        UPDATE public.survey_questions SET sequence = 17, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Comment') WHERE survey_page_id = page_id AND name = 'general_comments';
        -- Egyéb kérdés
        UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_id AND name = 'difficult_access';
    END IF;
END $$;

-- Klíma (air_conditioner)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'default_roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Mértékegység', 'en', 'Unit') WHERE survey_page_id = page_id AND name = 'consumption_unit_toggle';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Időszak', 'en', 'Period') WHERE survey_page_id = page_id AND name = 'consumption_period_toggle';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Fogyasztás', 'en', 'Consumption') WHERE survey_page_id = page_id AND name = 'annual_consumption';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'vehicle_access';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'electrical_network_condition';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'external_insulation';
        UPDATE public.survey_questions SET sequence = 10, name_translations = jsonb_build_object('hu', 'Külső hőszigetelés vastagsága (cm)', 'en', 'External Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'insulation_thickness';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'available_power_title';
        UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_id AND name = 'phase_count';
        UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_id AND name = 'phase_1';
        UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_id AND name = 'phase_2';
        UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_id AND name = 'phase_3';
        UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_id AND name = 'fi_relay';
        UPDATE public.survey_questions SET sequence = 17, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Comment') WHERE survey_page_id = page_id AND name = 'general_comments';
        -- Egyéb kérdés
        UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_id AND name = 'difficult_access';
    END IF;
END $$;

-- ============================================================================
-- NAPELEM (solar_panel page)
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'installation_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'existing_solar_system';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'shading_factor';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'energy_certificate';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_id AND name = 'building_floors';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Az eresz magassága a talajhoz képest (m)', 'en', 'Eaves Height from Ground Level (m)') WHERE survey_page_id = page_id AND name = 'eaves_height';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'roof_condition';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'connection_cable_type';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'monument_protection';
        UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_id AND name = 'lightning_protection';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'roof_renovation_needed';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'installation_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'existing_solar_system';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'shading_factor';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'energy_certificate';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_id AND name = 'building_floors';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Az eresz magassága a talajhoz képest (m)', 'en', 'Eaves Height from Ground Level (m)') WHERE survey_page_id = page_id AND name = 'eaves_height';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'roof_condition';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'connection_cable_type';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'monument_protection';
        UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_id AND name = 'lightning_protection';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'roof_renovation_needed';
    END IF;
END $$;

-- Klíma
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'installation_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'existing_solar_system';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'shading_factor';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'energy_certificate';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_id AND name = 'building_floors';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Az eresz magassága a talajhoz képest (m)', 'en', 'Eaves Height from Ground Level (m)') WHERE survey_page_id = page_id AND name = 'eaves_height';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_id AND name = 'roof_condition';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_id AND name = 'connection_cable_type';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_id AND name = 'monument_protection';
        UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_id AND name = 'lightning_protection';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_id AND name = 'roof_renovation_needed';
    END IF;
END $$;

-- ============================================================================
-- INVERTER
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'inverter';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Inverter beépítési helye, leírása', 'en', 'Inverter Installation Location, Description') WHERE survey_page_id = page_id AND name = 'inverter_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'signal_availability';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'internet_access';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'monitoring_system';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'inverter';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Inverter beépítési helye, leírása', 'en', 'Inverter Installation Location, Description') WHERE survey_page_id = page_id AND name = 'inverter_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'signal_availability';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'internet_access';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'monitoring_system';
    END IF;
END $$;

-- Klíma
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'inverter';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Inverter beépítési helye, leírása', 'en', 'Inverter Installation Location, Description') WHERE survey_page_id = page_id AND name = 'inverter_location';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'signal_availability';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'internet_access';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_id AND name = 'monitoring_system';
    END IF;
END $$;

-- ============================================================================
-- AKKUMULÁTOR (csak Napelem + Akkumulátor)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'battery';

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
-- TETŐ (roof)
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Szélessége (m)', 'en', 'Width (m)') WHERE survey_page_id = page_id AND name = 'roof_width';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hosszúsága (m)', 'en', 'Length (m)') WHERE survey_page_id = page_id AND name = 'roof_length';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_id AND name = 'roof_structure_material';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Tetőhéjazat típusa', 'en', 'Roof Covering Type') WHERE survey_page_id = page_id AND name = 'roof_covering_type';
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Agyagcserép esetén annak típusa', 'en', 'Clay Tile Type if Applicable') WHERE survey_page_id = page_id AND name = 'clay_tile_type';
        UPDATE public.survey_questions SET sequence = 9, name_translations = jsonb_build_object('hu', 'Szarufák közötti távolság (cm)', 'en', 'Rafter Spacing (cm)') WHERE survey_page_id = page_id AND name = 'rafter_spacing';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Szélessége (m)', 'en', 'Width (m)') WHERE survey_page_id = page_id AND name = 'roof_width';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hosszúsága (m)', 'en', 'Length (m)') WHERE survey_page_id = page_id AND name = 'roof_length';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_id AND name = 'roof_structure_material';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Tetőhéjazat típusa', 'en', 'Roof Covering Type') WHERE survey_page_id = page_id AND name = 'roof_covering_type';
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Agyagcserép esetén annak típusa', 'en', 'Clay Tile Type if Applicable') WHERE survey_page_id = page_id AND name = 'clay_tile_type';
        UPDATE public.survey_questions SET sequence = 9, name_translations = jsonb_build_object('hu', 'Szarufák közötti távolság (cm)', 'en', 'Rafter Spacing (cm)') WHERE survey_page_id = page_id AND name = 'rafter_spacing';
    END IF;
END $$;

-- Klíma
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'orientation';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_id AND name = 'tilt_angle';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Szélessége (m)', 'en', 'Width (m)') WHERE survey_page_id = page_id AND name = 'roof_width';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hosszúsága (m)', 'en', 'Length (m)') WHERE survey_page_id = page_id AND name = 'roof_length';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_id AND name = 'roof_structure_material';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Tetőhéjazat típusa', 'en', 'Roof Covering Type') WHERE survey_page_id = page_id AND name = 'roof_covering_type';
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Agyagcserép esetén annak típusa', 'en', 'Clay Tile Type if Applicable') WHERE survey_page_id = page_id AND name = 'clay_tile_type';
        UPDATE public.survey_questions SET sequence = 9, name_translations = jsonb_build_object('hu', 'Szarufák közötti távolság (cm)', 'en', 'Rafter Spacing (cm)') WHERE survey_page_id = page_id AND name = 'rafter_spacing';
    END IF;
END $$;
