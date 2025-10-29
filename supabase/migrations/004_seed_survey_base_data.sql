-- ============================================================================
-- Migration: Seed Survey System Base Data
-- Description: Populates the survey system with initial data from FlowFrontend
-- ============================================================================

-- ============================================================================
-- 1. INVESTMENTS
-- ============================================================================

INSERT INTO public.investments (name, icon, position) VALUES
    ('Solar Panel', 'i-lucide-sun', '{"top": 150, "right": 300}'::jsonb),
    ('Solar Panel + Battery', 'i-lucide-sun', '{"top": 150, "right": 250}'::jsonb),
    ('Heat Pump', 'i-lucide-thermometer', '{"top": 200, "right": 300}'::jsonb),
    ('Facade Insulation', 'i-lucide-home', '{"top": 250, "right": 100}'::jsonb),
    ('Roof Insulation', 'i-lucide-home', '{"top": 50, "right": 300}'::jsonb),
    ('Windows', 'i-lucide-square', '{"top": 200, "right": 100}'::jsonb),
    ('Air Conditioner', 'i-lucide-wind', '{"top": 300, "right": 200}'::jsonb),
    ('Battery', 'i-lucide-battery', '{"top": 350, "right": 300}'::jsonb),
    ('Car Charger', 'i-lucide-car', '{"top": 400, "right": 350}'::jsonb)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 2. HEAVY CONSUMERS
-- ============================================================================

INSERT INTO public.heavy_consumers (name) VALUES
    ('sauna'),
    ('jacuzzi'),
    ('poolHeating'),
    ('cryptoMining'),
    ('heatPump'),
    ('electricHeating')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 3. DOCUMENT CATEGORIES (from photoUploadConfig.ts)
-- ============================================================================

INSERT INTO public.document_categories (persist_name, name, description, min_photos) VALUES
    ('roof-condition', 'Tető állapota', 'Különböző szögekből készült képek a teljes tetőfelületről', 3),
    ('electrical-meter', 'Villanyóra és elektromos betáplálás', 'Villanyóra szekrény és mérőóra', 2),
    ('roof-structure', 'Tetőszerkezet', 'Tetőszerkezet felépítése, anyaga', 2),
    ('roof-access', 'Tetőre vezető útvonal', 'A tetőre feljutás útvonala és lehetőségei', 1),
    ('inverter-room', 'Inverteres helyiség', 'A napelem inverter elhelyezésére szolgáló helyiség', 1),
    ('battery-placement', 'Akkumulátor elhelyezésének helye', 'Az akkumulátorok elhelyezésére szolgáló helyiség vagy terület', 2),
    ('electrical-system', 'Meglévő elektromos rendszer', 'A meglévő elektromos rendszer fő elemei', 1),
    ('meter-box-interior', 'Mérőóra szekrény belső kialakítása', 'A mérőóra szekrény belső szerelvényei és kialakítása', 1),
    ('outdoor-unit', 'Kültéri egység helye', 'A hőszivattyú kültéri egységének tervezett helye', 2),
    ('indoor-unit', 'Beltéri egység helye', 'A hőszivattyú beltéri egységének tervezett helye', 1),
    ('heating-system', 'Meglévő fűtési rendszer', 'A meglévő fűtési rendszer fő elemei', 2),
    ('piping-route', 'Csővezetés útvonala', 'A hőszivattyú csővezetéseinek tervezett útvonala', 1),
    ('wall-insulation-area', 'Falak szigetelendő felülete', 'A szigetelendő falfelületek különböző nézetekből', 4),
    ('wall-condition', 'Falak állapota', 'A szigetelendő falak állapota, közeli felvételek', 2),
    ('window-condition', 'Ablakok állapota', 'A cserélendő ablakok állapota és mérete', 3),
    ('window-frame', 'Ablakkeret részletek', 'Az ablakok beépítésének részletei, keret állapota', 2),
    ('car-charger-placement', 'Autótöltő elhelyezése', 'Az autótöltő tervezett elhelyezésének helye', 2),
    ('parking-area', 'Parkolási terület', 'Az autó parkolási területe az autótöltőhöz képest', 1),
    ('ac-indoor-unit', 'Klíma beltéri egység helye', 'A klíma beltéri egységének tervezett elhelyezése', 1),
    ('ac-outdoor-unit', 'Klíma kültéri egység helye', 'A klíma kültéri egységének tervezett elhelyezése', 1),
    ('ac-piping-route', 'Klíma csővezetés útvonala', 'A klíma csővezetéseinek tervezett útvonala', 1),
    ('attic-condition', 'Padlás állapota', 'A padlás állapota és hozzáférhetősége', 2),
    ('site-survey-photos', 'Helyszíni felmérés fotói', 'Különböző szögekből készült képek a teljes tetőfelületről, a kábelezés nyomvonaláról, ha van akkumulátor, akkor annak a helyéről, illetve az inverter helyéről', 6),
    ('meter-location-photos', 'A mérőhely fotói', 'Villanyóra közelről, Villanyóra távolról', 2),
    ('connection-point', 'Csatlakozási pont', 'A főelosztóról készített képek', 2),
    ('electricity-meter-number', 'Villanyszámla fotó', '', 1)
ON CONFLICT (persist_name) DO NOTHING;

-- Link document categories to investments
-- Solar Panel
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.id) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Solar Panel'
AND dc.persist_name IN ('roof-condition', 'electrical-meter', 'roof-structure', 'roof-access', 'inverter-room')
ON CONFLICT DO NOTHING;

-- Solar Panel + Battery
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Solar Panel + Battery'
AND dc.persist_name IN ('site-survey-photos', 'meter-location-photos', 'connection-point', 'electricity-meter-number')
ON CONFLICT DO NOTHING;

-- Heat Pump
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Heat Pump'
AND dc.persist_name IN ('outdoor-unit', 'indoor-unit', 'heating-system', 'electrical-meter', 'piping-route')
ON CONFLICT DO NOTHING;

-- Facade Insulation
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Facade Insulation'
AND dc.persist_name IN ('wall-insulation-area', 'wall-condition')
ON CONFLICT DO NOTHING;

-- Roof Insulation
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Roof Insulation'
AND dc.persist_name IN ('roof-condition', 'roof-structure', 'attic-condition')
ON CONFLICT DO NOTHING;

-- Windows
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Windows'
AND dc.persist_name IN ('window-condition', 'window-frame')
ON CONFLICT DO NOTHING;

-- Battery
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Battery'
AND dc.persist_name IN ('electrical-meter', 'battery-placement', 'electrical-system', 'meter-box-interior')
ON CONFLICT DO NOTHING;

-- Car Charger
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Car Charger'
AND dc.persist_name IN ('electrical-meter', 'car-charger-placement', 'parking-area')
ON CONFLICT DO NOTHING;

-- Air Conditioner
INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
SELECT
    i.id,
    dc.id,
    ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY dc.persist_name) as position
FROM public.investments i
CROSS JOIN public.document_categories dc
WHERE i.name = 'Air Conditioner'
AND dc.persist_name IN ('ac-indoor-unit', 'ac-outdoor-unit', 'ac-piping-route', 'electrical-meter')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. EXTRA COSTS (from ExtraCostsPanel.tsx)
-- ============================================================================

INSERT INTO public.extra_costs (persist_name, name, price) VALUES
    ('gutter-reinstallation', 'Eresz visszahelyezése', 25000),
    ('downspout-removal', 'Függőleges lefolyó eltávolítása', 15000),
    ('downspout-reinstallation', 'Függőleges lefolyó visszahelyezése', 20000),
    ('railing-reinstallation', 'Korlát visszahelyezése', 30000),
    ('fence-gate-installation', 'Kerítés/kapu felszerelése', 45000),
    ('canopy-reinstallation', 'Előtető visszahelyezése', 35000),
    ('window-grille-reinstallation', 'Ablakrács visszahelyezése', 18000),
    ('shutter-reinstallation', 'Redőny visszahelyezése', 25000),
    ('alarm-camera-removal', 'Riasztó/kamera leszerelése', 20000),
    ('alarm-camera-installation', 'Riasztó/kamera felszerelése', 25000),
    ('masonry-work', 'Kőműves munka', 40000),
    ('damage-crack-repair', 'Sérülés/ repedés javítása', 30000),
    ('surface-unevenness-repair', 'Felületi egyenetlenség javítása', 35000),
    ('sheet-metal-work', 'Bádogos munka', 50000),
    ('gas-installation-work', 'Gázszerelési munka', 60000),
    ('gas-pipe-elevation', 'Gázcső kiemelése a síkból', 25000),
    ('gas-electric-meter-work', 'Gáz/villanyóra le-, és felszerelése', 40000),
    ('other-work', 'Egyéb munka', 0)
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 5. SURVEY PAGES & QUESTIONS (from FlowFrontend fixtures)
-- ============================================================================

-- First, let's create a temporary table to store investment IDs for reference
DO $$
DECLARE
    inv_solar_panel UUID;
    inv_solar_panel_battery UUID;
    inv_heat_pump UUID;
    inv_facade_insulation UUID;
    inv_roof_insulation UUID;
    inv_windows UUID;
    inv_air_conditioner UUID;
    inv_battery UUID;
    inv_car_charger UUID;

    page_id UUID;
    question_id UUID;
BEGIN
    -- Get investment IDs
    SELECT id INTO inv_solar_panel FROM public.investments WHERE name = 'Solar Panel';
    SELECT id INTO inv_solar_panel_battery FROM public.investments WHERE name = 'Solar Panel + Battery';
    SELECT id INTO inv_heat_pump FROM public.investments WHERE name = 'Heat Pump';
    SELECT id INTO inv_facade_insulation FROM public.investments WHERE name = 'Facade Insulation';
    SELECT id INTO inv_roof_insulation FROM public.investments WHERE name = 'Roof Insulation';
    SELECT id INTO inv_windows FROM public.investments WHERE name = 'Windows';
    SELECT id INTO inv_air_conditioner FROM public.investments WHERE name = 'Air Conditioner';
    SELECT id INTO inv_battery FROM public.investments WHERE name = 'Battery';
    SELECT id INTO inv_car_charger FROM public.investments WHERE name = 'Car Charger';

    -- ========================================================================
    -- SOLAR PANEL (4 categories)
    -- ========================================================================

    -- Page: Általános adatok
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'default_roof_type', 'dropdown', true, 'Sátortető', 'Tető típusa', '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb),
    (page_id, 'orientation', 'orientation_selector', true, 'D', 'Tájolás', '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb),
    (page_id, 'tilt_angle', 'slider', true, '30', null, null),
    (page_id, 'consumption_unit_toggle', 'dual_toggle', true, 'kW', 'Mértékegység', '["kW", "Ft"]'::jsonb),
    (page_id, 'consumption_period_toggle', 'dual_toggle', true, 'év', 'Időszak', '["hónap", "év"]'::jsonb),
    (page_id, 'annual_consumption', 'text', true, null, 'Érték', null),
    (page_id, 'vehicle_access', 'switch', true, 'true', 'Gépjárművel megközelíthető az épület?', null),
    (page_id, 'difficult_access', 'switch', true, 'false', 'Gépjárművel nehezen megközelíthető az épület?', null),
    (page_id, 'electrical_network_condition', 'dropdown', true, 'Átlagos', 'Az épület belső villamoshálózatának állapota', '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb),
    (page_id, 'external_insulation', 'switch', true, 'false', 'Rendelkezik külső hőszigeteléssel az épület', null),
    (page_id, 'insulation_thickness', 'text', false, null, 'Vastagság cm-ben', null),
    (page_id, 'available_power_title', 'title', false, null, 'Rendelkezésre álló teljesítmény (A)', null),
    (page_id, 'phase_count', 'phase_toggle', true, '1', 'Hány fázis áll rendelkezésre?', '["1", "3"]'::jsonb),
    (page_id, 'phase_1', 'text', false, null, 'Amper', null),
    (page_id, 'phase_2', 'text', false, null, 'Amper', null),
    (page_id, 'phase_3', 'text', false, null, 'Amper', null),
    (page_id, 'fi_relay', 'dropdown', true, 'Nincs', 'Rendelkezik az ügyfél Fi relével', '["Igen, az elosztó szekrényben", "Igen, a mérőóránál", "Nincs"]'::jsonb),
    (page_id, 'general_comments', 'textarea', false, '', 'Itt írhat megjegyzéseket az általános adatokhoz...', null);

    UPDATE public.survey_questions SET min = 0, max = 50, step = 5, unit = '°' WHERE survey_page_id = page_id AND name = 'tilt_angle';

    -- Page: Napelem
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel, 'Napelem', 'solar_panel', '{"top": 120, "right": 200}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'installation_location', 'dropdown', true, 'Családi ház', 'Telepítés helye', '["Földfelszín", "Családi ház", "Tömbház", "Üzemcsarnok", "Egyéb"]'::jsonb),
    (page_id, 'existing_solar_system', 'switch', true, 'false', 'Rendelkezik már napelem rendszerrel?', null),
    (page_id, 'shading_factor', 'text', false, null, 'Árnyékolás leírása', null),
    (page_id, 'energy_certificate', 'switch', true, 'false', 'Energia tanúsítvánnyal rendelkezik az épület?', null),
    (page_id, 'building_floors', 'dropdown', true, '1', 'Épület szintjeinek száma padlástér nélkül', '["1", "2", "3", "4"]'::jsonb),
    (page_id, 'eaves_height', 'text', true, '4', 'méter', null),
    (page_id, 'roof_condition', 'dropdown', true, 'Átlagos', 'Tetőszerkezet műszaki állapota', '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb),
    (page_id, 'connection_cable_type', 'dropdown', true, 'Légvezeték', 'Meglévő csatlakozó vezeték típusa', '["Földkábel", "Légvezeték"]'::jsonb),
    (page_id, 'monument_protection', 'switch', true, 'false', 'Épület műemlékvédelem alatt áll', null),
    (page_id, 'lightning_protection', 'switch', true, 'false', 'Villámhárító van az épületen', null),
    (page_id, 'roof_renovation_needed', 'switch', true, 'false', 'Tetőfelújítás szükséges', null);

    -- Page: Inverter
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel, 'Inverter', 'inverter', '{"top": 280, "right": 380}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'inverter_location', 'textarea', true, null, 'Inverter elhelyezésének részletes leírása...', null),
    (page_id, 'signal_availability', 'switch', true, 'true', 'Van-e megfelelő jel az inverter tervezett helyén', null),
    (page_id, 'internet_access', 'switch', true, 'true', 'Internet eléréssel rendelkezik?', null),
    (page_id, 'monitoring_system', 'dropdown', true, 'Wifi', 'Monitoring rendszert igényel?', '["Wifi", "UTP", "Nincs"]'::jsonb);

    -- Page: Tető (allowMultiple)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_solar_panel, 'Tető', 'roof', '{"top": 100, "right": 350}'::jsonb, true, false, '{index}. tető')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, min, max, step, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', null, '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null, null, null, null),
    (page_id, 'tilt_angle', 'slider', true, '30', null, null, 0, 50, 5, '°'),
    (page_id, 'roof_width', 'text', true, null, 'méter', null, null, null, null, 'm'),
    (page_id, 'roof_length', 'text', true, null, 'méter', null, null, null, null, 'm'),
    (page_id, 'roof_structure_material', 'dropdown', true, 'Fa', null, '["Fa", "Fém", "Beton"]'::jsonb, null, null, null, null),
    (page_id, 'roof_covering_type', 'dropdown', true, 'Agyagcserép', null, '["Agyagcserép", "Betoncserép", "Cserepes lemez", "Trapéz lemez", "Zsindely", "Lemezpala", "Hullámpala", "Szalma nád", "Szendvicspanel", "Hódfarkú cserép", "Dupla hódfarkú cserép", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'clay_tile_type', 'dropdown', false, null, null, '["Íves", "Bramac", "Egyenes", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'sheet_thickness', 'text', false, null, 'mm', null, null, null, null, null),
    (page_id, 'rafter_spacing', 'text', true, '90', 'cm', null, null, null, null, 'cm');

    -- ========================================================================
    -- AIR CONDITIONER (4 categories) - ugyanazok a page-ek mint Solar Panel
    -- ========================================================================

    -- Az Air Conditioner survey ugyanazokat a category-kat használja mint a Solar Panel
    -- Ezért csak a page-eket hozzuk létre újra az inv_air_conditioner investment_id-val

    -- Page: Általános adatok
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_air_conditioner, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'default_roof_type', 'dropdown', true, 'Sátortető', null, '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb),
    (page_id, 'orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb),
    (page_id, 'tilt_angle', 'slider', true, '30', null, null),
    (page_id, 'consumption_unit_toggle', 'dual_toggle', true, 'kW', null, '["kW", "Ft"]'::jsonb),
    (page_id, 'consumption_period_toggle', 'dual_toggle', true, 'év', null, '["hónap", "év"]'::jsonb),
    (page_id, 'annual_consumption', 'text', true, null, 'Érték', null),
    (page_id, 'vehicle_access', 'switch', true, 'true', null, null),
    (page_id, 'difficult_access', 'switch', true, 'false', null, null),
    (page_id, 'electrical_network_condition', 'dropdown', true, 'Átlagos', null, '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb),
    (page_id, 'external_insulation', 'switch', true, 'false', null, null),
    (page_id, 'insulation_thickness', 'text', false, null, 'Vastagság cm-ben', null),
    (page_id, 'available_power_title', 'title', false, null, null, null),
    (page_id, 'phase_count', 'phase_toggle', true, '1', null, '["1", "3"]'::jsonb),
    (page_id, 'phase_1', 'text', false, null, 'Amper', null),
    (page_id, 'phase_2', 'text', false, null, 'Amper', null),
    (page_id, 'phase_3', 'text', false, null, 'Amper', null),
    (page_id, 'fi_relay', 'dropdown', true, 'Nincs', null, '["Igen, az elosztó szekrényben", "Igen, a mérőóránál", "Nincs"]'::jsonb),
    (page_id, 'other_comments', 'textarea', false, null, 'További megjegyzések...', null);

    UPDATE public.survey_questions SET min = 0, max = 50, step = 5, unit = '°' WHERE survey_page_id = page_id AND name = 'tilt_angle';

    -- Ugyanezek a többi 3 page (solar_panel, inverter, roof) az air conditioner-hez

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_air_conditioner, 'Napelem', 'solar_panel', '{"top": 220, "right": 200}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'installation_location', 'dropdown', true, 'Családi ház', null, '["Földfelszín", "Családi ház", "Tömbház", "Üzemcsarnok", "Egyéb"]'::jsonb),
    (page_id, 'existing_solar_system', 'switch', true, 'false', null, null),
    (page_id, 'shading_factor', 'text', false, null, 'Árnyékolás leírása', null),
    (page_id, 'energy_certificate', 'switch', true, 'false', null, null),
    (page_id, 'building_floors', 'dropdown', true, '1', null, '["1", "2", "3", "4"]'::jsonb),
    (page_id, 'eaves_height', 'text', true, '4', 'méter', null),
    (page_id, 'roof_condition', 'dropdown', true, 'Átlagos', null, '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb),
    (page_id, 'connection_cable_type', 'dropdown', true, 'Légvezeték', null, '["Földkábel", "Légvezeték"]'::jsonb),
    (page_id, 'monument_protection', 'switch', true, 'false', null, null),
    (page_id, 'lightning_protection', 'switch', true, 'false', null, null),
    (page_id, 'roof_renovation_needed', 'switch', true, 'false', null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_air_conditioner, 'Inverter', 'inverter', '{"top": 260, "right": 380}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value) VALUES
    (page_id, 'inverter_location', 'textarea', true, null, 'Inverter elhelyezésének részletes leírása...'),
    (page_id, 'signal_availability', 'switch', true, 'true', null),
    (page_id, 'internet_access', 'switch', true, 'true', null),
    (page_id, 'monitoring_system', 'dropdown', true, 'Wifi', null);

    UPDATE public.survey_questions SET options = '["Wifi", "UTP", "Nincs"]'::jsonb WHERE survey_page_id = page_id AND name = 'monitoring_system';

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_air_conditioner, 'Tető', 'roof', '{"top": 300, "right": 350}'::jsonb, true, false, '{index}. tető')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, step, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'orientation', 'orientation_selector', true, 'D', '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null, null, null, null),
    (page_id, 'tilt_angle', 'slider', true, '30', null, 0, 50, 5, '°'),
    (page_id, 'roof_width', 'text', true, null, null, null, null, null, 'm'),
    (page_id, 'roof_length', 'text', true, null, null, null, null, null, 'm'),
    (page_id, 'roof_structure_material', 'dropdown', true, 'Fa', '["Fa", "Fém", "Beton"]'::jsonb, null, null, null, null),
    (page_id, 'roof_covering_type', 'dropdown', true, 'Agyagcserép', '["Agyagcserép", "Betoncserép", "Cserepes lemez", "Trapéz lemez", "Zsindely", "Lemezpala", "Hullámpala", "Szalma nád", "Szendvicspanel", "Hódfarkú cserép", "Dupla hódfarkú cserép", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'clay_tile_type', 'dropdown', false, null, '["Íves", "Bramac", "Egyenes", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'sheet_thickness', 'text', false, null, null, null, null, null, 'mm'),
    (page_id, 'rafter_spacing', 'text', true, '90', null, null, null, null, 'cm');

    -- ========================================================================
    -- BATTERY (1 category)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_battery, 'Akkumulátor', 'battery', '{"top": 380, "right": 450}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, unit) VALUES
    (page_id, 'available_space', 'text', true, '2', 'm²', 'm²'),
    (page_id, 'temperature_above_zero', 'switch', true, 'true', null, null),
    (page_id, 'inverter_battery_distance', 'text', true, '2', 'méter', 'm'),
    (page_id, 'fire_disconnect', 'switch', true, 'true', null, null),
    (page_id, 'main_distributor_routing', 'switch', true, 'true', null, null),
    (page_id, 'smart_meter_space', 'switch', true, 'false', null, null),
    (page_id, 'smart_meter_distance', 'text', false, null, 'méter', 'm'),
    (page_id, 'routing_description', 'textarea', false, null, 'Részletes nyomvonal leírása...', null);

    -- ========================================================================
    -- CAR CHARGER (3 categories)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_car_charger, 'Elektromos autó adatok', 'ev_data', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'ev_brand_select', 'dropdown', true, 'Tesla', null, '["Audi", "BMW", "Hyundai", "Kia", "Mercedes-Benz", "Nissan", "Renault", "Skoda", "Tesla", "Volkswagen", "Egyéb"]'::jsonb, null),
    (page_id, 'ev_brand_other', 'text', false, null, 'Adja meg a márkát', null, null),
    (page_id, 'ev_model', 'text', true, null, 'pl. Model 3, Ioniq 5, ID.4', null, null),
    (page_id, 'ev_connector_type', 'dropdown', true, 'Type2', null, '["Type2", "Type1"]'::jsonb, null),
    (page_id, 'ev_battery_capacity', 'text', false, null, 'pl. 60', null, 'kWh'),
    (page_id, 'onboard_charger_title', 'title', false, null, null, null, null),
    (page_id, 'onboard_charger_power', 'text', false, null, 'pl. 11', null, 'kW'),
    (page_id, 'onboard_charger_phase', 'dropdown', false, '1', null, '["1", "2", "3"]'::jsonb, null),
    (page_id, 'onboard_charger_ampere', 'text', false, null, 'pl. 16', null, 'A');

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_car_charger, 'Helyszín adatok', 'location', '{"top": 320, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options) VALUES
    (page_id, 'installation_site_type', 'dropdown', true, 'Családi ház', '["Családi ház", "Ikerház", "Sorház", "Társasház"]'::jsonb),
    (page_id, 'ownership', 'dropdown', true, 'Ügyfél saját tulajdona', '["Ügyfél saját tulajdona", "Több tulajdonos", "Bérelt"]'::jsonb),
    (page_id, 'site_access', 'dropdown', true, 'Privát, zárt', '["Privát, zárt", "Zárt, de osztott használatú", "Utcai beálló"]'::jsonb),
    (page_id, 'site_nature', 'dropdown', true, 'Garázs', '["Garázs", "Mélygarázs", "Fedett kerti kocsibeálló", "Nem fedett kerti kocsibeálló"]'::jsonb);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_car_charger, 'Teljesítménybővítés', 'power_upgrade', '{"top": 440, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options) VALUES
    (page_id, 'plans_internal_upgrade', 'switch', true, 'false', null),
    (page_id, 'has_wiring_plan', 'switch', true, 'false', null),
    (page_id, 'power_supply_ok', 'switch', true, 'false', null),
    (page_id, 'site_prepared_ok', 'switch', true, 'false', null),
    (page_id, 'mounting_surface_type', 'dropdown', false, null, '["Falfelület", "Beton alapzat"]'::jsonb);

    RAISE NOTICE 'Survey pages and questions seeded successfully for Solar Panel, Air Conditioner, Battery, and Car Charger';

    -- ========================================================================
    -- SOLAR PANEL + BATTERY (5 categories: general, solar_panel, inverter, battery, roof)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel_battery, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, min, max, step, unit) VALUES
    (page_id, 'default_roof_type', 'dropdown', true, 'Sátortető', null, '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null, null, null, null),
    (page_id, 'tilt_angle', 'slider', true, '30', null, null, 0, 50, 5, '°'),
    (page_id, 'consumption_unit_toggle', 'dual_toggle', true, 'kW', null, '["kW", "Ft"]'::jsonb, null, null, null, null),
    (page_id, 'consumption_period_toggle', 'dual_toggle', true, 'év', null, '["hónap", "év"]'::jsonb, null, null, null, null),
    (page_id, 'annual_consumption', 'text', true, null, 'Érték', null, null, null, null, null),
    (page_id, 'vehicle_access', 'switch', true, 'true', null, null, null, null, null, null),
    (page_id, 'difficult_access', 'switch', true, 'false', null, null, null, null, null, null),
    (page_id, 'electrical_network_condition', 'dropdown', true, 'Átlagos', null, '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb, null, null, null, null),
    (page_id, 'external_insulation', 'switch', true, 'false', null, null, null, null, null, null),
    (page_id, 'insulation_thickness', 'text', false, null, 'Vastagság cm-ben', null, null, null, null, 'cm'),
    (page_id, 'available_power_title', 'title', false, null, null, null, null, null, null, null),
    (page_id, 'phase_count', 'phase_toggle', true, '1', null, '["1", "3"]'::jsonb, null, null, null, null),
    (page_id, 'phase_1', 'text', false, null, 'Amper', null, null, null, null, 'A'),
    (page_id, 'phase_2', 'text', false, null, 'Amper', null, null, null, null, 'A'),
    (page_id, 'phase_3', 'text', false, null, 'Amper', null, null, null, null, 'A'),
    (page_id, 'fi_relay', 'dropdown', true, 'Nincs', null, '["Igen, az elosztó szekrényben", "Igen, a mérőóránál", "Nincs"]'::jsonb, null, null, null, null),
    (page_id, 'general_comments', 'textarea', false, '', 'Itt írhat megjegyzéseket az általános adatokhoz...', null, null, null, null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel_battery, 'Napelem', 'solar_panel', '{"top": 120, "right": 200}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'installation_location', 'dropdown', true, 'Családi ház', null, '["Földfelszín", "Családi ház", "Tömbház", "Üzemcsarnok", "Egyéb"]'::jsonb),
    (page_id, 'existing_solar_system', 'switch', true, 'false', null, null),
    (page_id, 'shading_factor', 'text', false, null, 'Árnyékolás leírása', null),
    (page_id, 'energy_certificate', 'switch', true, 'false', null, null),
    (page_id, 'building_floors', 'dropdown', true, '1', null, '["1", "2", "3", "4"]'::jsonb),
    (page_id, 'eaves_height', 'text', true, '4', 'méter', null),
    (page_id, 'roof_condition', 'dropdown', true, 'Átlagos', null, '["Új", "Jó", "Átlagos", "Felújításra szorul", "Rossz"]'::jsonb),
    (page_id, 'connection_cable_type', 'dropdown', true, 'Légvezeték', null, '["Földkábel", "Légvezeték"]'::jsonb),
    (page_id, 'monument_protection', 'switch', true, 'false', null, null),
    (page_id, 'lightning_protection', 'switch', true, 'false', null, null),
    (page_id, 'roof_renovation_needed', 'switch', true, 'false', null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel_battery, 'Inverter', 'inverter', '{"top": 280, "right": 380}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options) VALUES
    (page_id, 'inverter_location', 'textarea', true, null, 'Inverter elhelyezésének részletes leírása...', null),
    (page_id, 'signal_availability', 'switch', true, 'true', null, null),
    (page_id, 'internet_access', 'switch', true, 'true', null, null),
    (page_id, 'monitoring_system', 'dropdown', true, 'Wifi', null, '["Wifi", "UTP", "Nincs"]'::jsonb);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_solar_panel_battery, 'Akkumulátor', 'battery', '{"top": 380, "right": 450}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, unit) VALUES
    (page_id, 'available_space', 'text', true, '2', 'm²', 'm²'),
    (page_id, 'temperature_above_zero', 'switch', true, 'true', null, null),
    (page_id, 'inverter_battery_distance', 'text', true, '2', 'méter', 'm'),
    (page_id, 'fire_disconnect', 'switch', true, 'true', null, null),
    (page_id, 'main_distributor_routing', 'switch', true, 'true', null, null),
    (page_id, 'smart_meter_space', 'switch', true, 'false', null, null),
    (page_id, 'smart_meter_distance', 'text', false, null, 'méter', 'm'),
    (page_id, 'routing_description', 'textarea', false, null, 'Részletes nyomvonal leírása...', null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_solar_panel_battery, 'Tető', 'roof', '{"top": 100, "right": 350}'::jsonb, true, false, '{index}. tető')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, step, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', '["Nyeregtető", "Sátortető", "Fél nyeregtető", "Lapostető", "Földre telepítés", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'orientation', 'orientation_selector', true, 'D', '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null, null, null, null),
    (page_id, 'tilt_angle', 'slider', true, '30', null, 0, 50, 5, '°'),
    (page_id, 'roof_width', 'text', true, null, null, null, null, null, 'm'),
    (page_id, 'roof_length', 'text', true, null, null, null, null, null, 'm'),
    (page_id, 'roof_structure_material', 'dropdown', true, 'Fa', '["Fa", "Fém", "Beton"]'::jsonb, null, null, null, null),
    (page_id, 'roof_covering_type', 'dropdown', true, 'Agyagcserép', '["Agyagcserép", "Betoncserép", "Cserepes lemez", "Trapéz lemez", "Zsindely", "Lemezpala", "Hullámpala", "Szalma nád", "Szendvicspanel", "Hódfarkú cserép", "Dupla hódfarkú cserép", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'clay_tile_type', 'dropdown', false, null, '["Íves", "Bramac", "Egyenes", "Egyéb"]'::jsonb, null, null, null, null),
    (page_id, 'sheet_thickness', 'text', false, null, null, null, null, null, 'mm'),
    (page_id, 'rafter_spacing', 'text', true, '90', null, null, null, null, 'cm');

    RAISE NOTICE 'Survey pages and questions seeded successfully for Solar Panel + Battery';

    -- ========================================================================
    -- FACADE INSULATION (3 categories)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_facade_insulation, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'property_type', 'dropdown', true, 'Családi ház', null, '["Családi ház", "Ikerház", "Sorház"]'::jsonb, null),
    (page_id, 'construction_year', 'text', true, null, 'Építési év', null, null),
    (page_id, 'winter_temperature', 'text', true, '21', null, null, '°C'),
    (page_id, 'main_orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null),
    (page_id, 'has_basement', 'switch', true, 'false', null, null, null),
    (page_id, 'has_attic', 'switch', true, 'false', null, null, null),
    (page_id, 'general_comments', 'textarea', false, '', 'Itt írhat megjegyzéseket az általános adatokhoz...', null, null),
    (page_id, 'moisture_damage', 'switch', true, 'false', null, null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_facade_insulation, 'Falak', 'walls', '{"top": 400, "right": 300}'::jsonb, true, true, '{index}. falfelület')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, step, unit) VALUES
    (page_id, 'wall_type', 'dropdown', true, 'Kérjük, válasszon', '["Kérjük, válasszon", "Kis méretű tömör tégla", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Bautherm", "Porotherm N+F", "Ytong", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb, null, null, null, null),
    (page_id, 'wall_thickness', 'number', true, '30', null, 1, 100, null, 'cm'),
    (page_id, 'wall_width', 'number', true, '10', null, 0.1, 100, 0.1, 'm'),
    (page_id, 'wall_height', 'number', true, '3', null, 0.1, 20, 0.1, 'm'),
    (page_id, 'foundation_height', 'number', true, '0.5', null, 0, 5, 0.1, 'm'),
    (page_id, 'wall_insulation', 'switch', true, 'false', null, null, null, null, null),
    (page_id, 'wall_insulation_thickness', 'number', false, '10', null, 1, 50, null, 'cm');

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_facade_insulation, 'Tető', 'roof', '{"top": 500, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', '["Sátortető", "Lapostető"]'::jsonb, null, null, null),
    (page_id, 'roof_area', 'text', true, '100', null, null, null, 'm²'),
    (page_id, 'roof_material', 'dropdown', true, 'Cserép', '["Cserép", "Pala", "Lemezelt"]'::jsonb, null, null, null),
    (page_id, 'roof_built_in', 'switch', true, 'false', null, null, null, null),
    (page_id, 'roof_insulation', 'switch', true, 'false', null, null, null, null),
    (page_id, 'roof_insulation_thickness', 'number', false, '10', null, 1, 50, 'cm');

    -- ========================================================================
    -- ROOF INSULATION (4 categories)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_roof_insulation, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'property_type', 'dropdown', true, 'Családi ház', null, '["Családi ház", "Ikerház", "Sorház"]'::jsonb, null),
    (page_id, 'construction_year', 'text', true, null, 'Építési év', null, null),
    (page_id, 'winter_temperature', 'text', true, '21', null, null, '°C'),
    (page_id, 'main_orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null),
    (page_id, 'has_basement', 'switch', true, 'false', null, null, null),
    (page_id, 'has_attic', 'switch', true, 'false', null, null, null),
    (page_id, 'general_comments', 'textarea', false, '', 'Itt írhat megjegyzéseket az általános adatokhoz...', null, null),
    (page_id, 'moisture_damage', 'switch', true, 'false', null, null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_roof_insulation, 'Falak', 'walls', '{"top": 400, "right": 300}'::jsonb, true, true, '{index}. falfelület')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, step, unit) VALUES
    (page_id, 'wall_type', 'dropdown', true, 'Kérjük, válasszon', '["Kérjük, válasszon", "Kis méretű tömör tégla", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Bautherm", "Porotherm N+F", "Ytong", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb, null, null, null, null),
    (page_id, 'wall_thickness', 'number', true, '30', null, 1, 100, null, 'cm'),
    (page_id, 'wall_width', 'number', true, '10', null, 0.1, 100, 0.1, 'm'),
    (page_id, 'wall_height', 'number', true, '3', null, 0.1, 20, 0.1, 'm');

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_roof_insulation, 'Tető', 'roof', '{"top": 500, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', '["Sátortető", "Lapostető"]'::jsonb, null, null, null),
    (page_id, 'roof_area', 'text', true, '100', null, null, null, 'm²'),
    (page_id, 'roof_material', 'dropdown', true, 'Cserép', '["Cserép", "Pala", "Lemezelt"]'::jsonb, null, null, null),
    (page_id, 'roof_built_in', 'switch', true, 'false', null, null, null, null),
    (page_id, 'roof_insulation', 'switch', true, 'false', null, null, null, null),
    (page_id, 'roof_insulation_thickness', 'number', false, '10', null, 1, 50, 'cm');

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_roof_insulation, 'Nyílászárók', 'windows', '{"top": 600, "right": 300}'::jsonb, true, true, '{index}. nyílászáró')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'window_type', 'dropdown', true, 'Ablak', null, '["Ablak", "Bejárati ajtó", "Terasz/erkélyajtó (üvegezett)"]'::jsonb, null),
    (page_id, 'window_width', 'text', true, null, 'cm', null, 'cm'),
    (page_id, 'window_height', 'text', true, null, 'cm', null, 'cm'),
    (page_id, 'window_material', 'dropdown', true, 'Műanyag', null, '["Fa", "Műanyag", "Fém"]'::jsonb, null),
    (page_id, 'window_glazing', 'dropdown', true, '2 rétegű üvegezésű', null, '["1 rétegű üvegezésű", "2 rétegű üvegezésű", "3 rétegű üvegezésű", "2 rétegű csavaros teschauer", "2 rétegű kapcsolt gerébtokos", "Nem üvegezett bejárati"]'::jsonb, null),
    (page_id, 'window_quantity', 'text', true, '1', 'db', null, 'db');

    -- ========================================================================
    -- WINDOWS (4 categories)
    -- ========================================================================

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_windows, 'Általános adatok', 'general', '{"top": 200, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'property_type', 'dropdown', true, 'Családi ház', null, '["Családi ház", "Ikerház", "Sorház"]'::jsonb, null),
    (page_id, 'construction_year', 'text', true, null, 'Építési év', null, null),
    (page_id, 'winter_temperature', 'text', true, '21', null, null, '°C'),
    (page_id, 'main_orientation', 'orientation_selector', true, 'D', null, '["É", "ÉK", "K", "DK", "D", "DNy", "Ny", "ÉNy"]'::jsonb, null),
    (page_id, 'has_basement', 'switch', true, 'false', null, null, null),
    (page_id, 'has_attic', 'switch', true, 'false', null, null, null),
    (page_id, 'general_comments', 'textarea', false, '', 'Itt írhat megjegyzéseket az általános adatokhoz...', null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_windows, 'Falak', 'walls', '{"top": 400, "right": 300}'::jsonb, true, true, '{index}. falfelület')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, step, unit) VALUES
    (page_id, 'wall_type', 'dropdown', true, 'Kérjük, válasszon', '["Kérjük, válasszon", "Kis méretű tömör tégla", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Bautherm", "Porotherm N+F", "Ytong", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb, null, null, null, null),
    (page_id, 'wall_thickness', 'number', true, '30', null, 1, 100, null, 'cm'),
    (page_id, 'wall_width', 'number', true, '10', null, 0.1, 100, 0.1, 'm'),
    (page_id, 'wall_height', 'number', true, '3', null, 0.1, 20, 0.1, 'm'),
    (page_id, 'wall_insulation', 'switch', true, 'false', null, null, null, null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_windows, 'Tető', 'roof', '{"top": 500, "right": 300}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, unit) VALUES
    (page_id, 'roof_type', 'dropdown', true, 'Sátortető', '["Sátortető", "Lapostető"]'::jsonb, null, null, null),
    (page_id, 'roof_area', 'text', true, '100', null, null, null, 'm²'),
    (page_id, 'roof_material', 'dropdown', true, 'Cserép', '["Cserép", "Pala", "Lemezelt"]'::jsonb, null, null, null),
    (page_id, 'roof_built_in', 'switch', true, 'false', null, null, null, null),
    (page_id, 'roof_insulation', 'switch', true, 'false', null, null, null, null);

    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_windows, 'Nyílászárók', 'windows', '{"top": 600, "right": 300}'::jsonb, true, true, '{index}. nyílászáró')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'window_type', 'dropdown', true, 'Ablak', null, '["Ablak", "Bejárati ajtó", "Terasz/erkélyajtó (üvegezett)"]'::jsonb, null),
    (page_id, 'window_width', 'text', true, null, 'cm', null, 'cm'),
    (page_id, 'window_height', 'text', true, null, 'cm', null, 'cm'),
    (page_id, 'window_material', 'dropdown', true, 'Műanyag', null, '["Fa", "Műanyag", "Fém"]'::jsonb, null),
    (page_id, 'window_glazing', 'dropdown', true, '2 rétegű üvegezésű', null, '["1 rétegű üvegezésű", "2 rétegű üvegezésű", "3 rétegű üvegezésű", "2 rétegű csavaros teschauer", "2 rétegű kapcsolt gerébtokos", "Nem üvegezett bejárati"]'::jsonb, null),
    (page_id, 'window_quantity', 'text', true, '1', 'db', null, 'db');

    RAISE NOTICE 'All survey pages and questions seeded successfully for all 9 investment types';

END $$;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
