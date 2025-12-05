-- ============================================================================
-- Migration: Complete Missing Survey Data
-- Description: Adds missing survey pages and questions for Solar Panel, Heat Pump, and Facade Insulation
-- ============================================================================

DO $$
DECLARE
    inv_solar_panel UUID;
    inv_heat_pump UUID;
    inv_facade_insulation UUID;
    page_id UUID;
    question_id UUID;
BEGIN
    -- Get investment IDs
    SELECT id INTO inv_solar_panel FROM public.investments WHERE name = 'Solar Panel';
    SELECT id INTO inv_heat_pump FROM public.investments WHERE name = 'Heat Pump';
    SELECT id INTO inv_facade_insulation FROM public.investments WHERE name = 'Facade Insulation';

    -- ========================================================================
    -- SOLAR PANEL - Add all categories
    -- ========================================================================

    -- Page: Általános adatok (General Data)
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

    -- Page: Napelem (Solar Panel Details)
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

    -- Page: Tető (Roof) - allowMultiple
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

    RAISE NOTICE 'Solar Panel survey categories added successfully';

    -- ========================================================================
    -- FACADE INSULATION - Add all categories
    -- ========================================================================

    -- Page: Általános adatok (General Data)
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

    -- Page: Falak (Walls) - allowMultiple
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

    -- Page: Tető (Roof)
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

    RAISE NOTICE 'Facade Insulation survey categories added successfully';

    -- ========================================================================
    -- HEAT PUMP - Add missing categories and complete general
    -- ========================================================================

    -- Update general category with missing questions
    -- First, get the existing general page_id for Heat Pump
    SELECT id INTO page_id FROM public.survey_pages
    WHERE investment_id = inv_heat_pump AND type = 'general' LIMIT 1;

    -- Add missing questions to general category if page exists
    IF page_id IS NOT NULL THEN
        INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, min, max, step, unit) VALUES
        (page_id, 'property_type_other', 'text', false, null, 'Adja meg az ingatlan típusát', null, null, null, null, null),
        (page_id, 'attic_built_in', 'switch', true, 'false', null, null, null, null, null, null),
        (page_id, 'attic_insulation', 'switch', true, 'false', null, null, null, null, null, null),
        (page_id, 'attic_insulation_size', 'text', false, null, 'pl. 100 m²', null, null, null, null, null),
        (page_id, 'ceiling_height', 'slider', true, '2.7', null, null, 2.0, 5.0, 0.1, 'm'),
        (page_id, 'wet_rooms_count', 'number', true, '2', null, null, 1, 20, null, null),
        (page_id, 'wall_type_thickness', 'text', true, null, 'pl. Porotherm 30 cm', null, null, null, null, null),
        (page_id, 'thermal_insulation', 'switch', true, 'false', null, null, null, null, null, null),
        (page_id, 'thermal_insulation_thickness', 'number', false, null, null, null, 1, 50, null, 'cm'),
        (page_id, 'ceiling_insulation', 'switch', false, 'false', null, null, null, null, null, null),
        (page_id, 'ceiling_insulation_thickness', 'number', false, null, null, null, 1, 50, null, 'cm'),
        (page_id, 'facade_insulation', 'switch', false, 'false', null, null, null, null, null, null),
        (page_id, 'facade_insulation_thickness', 'number', false, null, null, null, 1, 50, null, 'cm'),
        (page_id, 'window_door_type', 'text', true, null, 'pl. Műanyag, 2 rétegű üvegezés', null, null, null, null, null),
        (page_id, 'window_shading', 'text', false, null, 'pl. Redőny, napellenző', null, null, null, null, null);
    END IF;

    -- Page: Helyiségek (Rooms)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Helyiségek', 'rooms', '{"top": 300, "right": 200}'::jsonb, true, true, '{index}. helyiség')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, placeholder_value) VALUES
    (page_id, 'room_name', 'text', true, 'pl. Nappali, Hálószoba'),
    (page_id, 'room_size', 'text', true, 'pl. 20 m²');

    -- Page: Nyílászárók (Windows) for Heat Pump
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Nyílászárók', 'windows', '{"top": 400, "right": 300}'::jsonb, true, true, '{index}. nyílászáró')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, unit) VALUES
    (page_id, 'window_type', 'dropdown', true, 'Kisablak (90 cm × 90 cm-nél kisebb)', null, '["Kisablak (90 cm × 90 cm-nél kisebb)", "Átlagos ablak (90-150 cm × 90-150 cm közötti)", "Nagyablak (150 cm × 150 cm-nél nagyobb)", "Bejárati ajtó", "Terasz/erkélyajtó (üvegezett)"]'::jsonb, null),
    (page_id, 'window_material', 'dropdown', true, 'Műanyag', null, '["Fa", "Műanyag", "Fém"]'::jsonb, null),
    (page_id, 'window_glazing', 'dropdown', true, '2 rétegű üvegezésű', null, '["1 rétegű üvegezésű", "2 rétegű üvegezésű", "3 rétegű üvegezésű", "2 rétegű csavaros teschauer", "2 rétegű kapcsolt gerébtokos", "Nem üvegezett bejárati"]'::jsonb, null),
    (page_id, 'window_quantity', 'text', true, '1', 'db', null, 'db');

    -- Page: Fűtés alapadatok (Heating Basics)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Fűtés alapadatok', 'heating_basics', '{"top": 500, "right": 400}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, options, min, max, unit) VALUES
    (page_id, 'current_heating_solution', 'dropdown', true, 'Kondenzációs kazán', null, '["Nyílt égésterű kazán", "Kondenzációs kazán", "Konvektor", "Vegyestüzelésű kazán", "Egyéb"]'::jsonb, null, null, null),
    (page_id, 'current_heating_solution_other', 'text', false, null, 'Adja meg a fűtési megoldás típusát', null, null, null, null),
    (page_id, 'current_heat_distribution', 'dropdown', true, 'Radiátor', null, '["Radiátor", "Fancoil", "Padlófűtés", "Mennyezetfűtés", "Falfűtés", "Egyéb"]'::jsonb, null, null, null),
    (page_id, 'current_heat_distribution_other', 'text', false, null, 'Adja meg a hőleadó kör típusát', null, null, null, null),
    (page_id, 'current_hot_water', 'dropdown', true, 'Kazán, beépített HMV tároló', null, '["Átfolyó vízmelegítő", "Kazán, beépített HMV tároló", "Kazán, külső HMV tároló", "Villanybojler"]'::jsonb, null, null, null),
    (page_id, 'current_hot_water_size', 'number', false, null, null, null, 50, 1000, 'liter'),
    (page_id, 'solar_collector_support', 'switch', true, 'false', null, null, null, null, null);

    -- Page: Radiátorok (Radiators)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first, item_name_template)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Radiátorok', 'radiators', '{"top": 600, "right": 200}'::jsonb, true, true, '{index}. radiátor')
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, placeholder_value) VALUES
    (page_id, 'radiator_size', 'text', true, 'pl. 60x120 cm');

    -- Page: Igényelt konstrukció (Desired Construction)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Igényelt konstrukció', 'desired_construction', '{"top": 700, "right": 400}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, options, min, max, unit) VALUES
    (page_id, 'goal', 'dropdown', true, 'Új beruházás', '["Új beruházás", "Meglévő rendszer teljes kiváltása", "Meglévő rendszer részleges kiváltása"]'::jsonb, null, null, null),
    (page_id, 'subsidy', 'switch', true, 'false', null, null, null, null),
    (page_id, 'heat_pump_usage', 'dropdown', true, 'Fűtésre', '["Fűtésre", "Hűtésre és fűtésre"]'::jsonb, null, null, null),
    (page_id, 'hot_water_solution', 'dropdown', true, 'Hőszivattyúval', '["Hőszivattyúval", "Új bojler", "Jelenlegi marad"]'::jsonb, null, null, null),
    (page_id, 'external_storage', 'switch', false, 'false', null, null, null, null),
    (page_id, 'heat_distribution', 'dropdown', true, 'Radiátor', '["Radiátor", "Fancoil", "Padlófűtés", "Mennyezetfűtés", "Falfűtés"]'::jsonb, null, null, null),
    (page_id, 'h_tariff', 'switch', true, 'false', null, null, null, null),
    (page_id, 'tank_capacity', 'number', true, '200', null, 50, 1000, 'liter');

    -- Page: Egyéb kérdések (Other Data)
    INSERT INTO public.survey_pages (id, investment_id, name, type, position, allow_multiple, allow_delete_first)
    VALUES (gen_random_uuid(), inv_heat_pump, 'Egyéb kérdések', 'other_data', '{"top": 800, "right": 500}'::jsonb, false, false)
    RETURNING id INTO page_id;

    INSERT INTO public.survey_questions (survey_page_id, name, type, is_required, default_value, placeholder_value, min, max, step, unit) VALUES
    (page_id, 'annual_gas_consumption', 'number', true, null, null, 0, 50000, null, 'm³'),
    (page_id, 'calculated_heat_demand', 'text', false, null, 'kW', null, null, null, null),
    (page_id, 'calculation_source', 'text', false, null, 'Szakember neve, cég', null, null, null, null),
    (page_id, 'calculated_winter_heat_loss', 'text', false, null, 'kW', null, null, null, null),
    (page_id, 'summer_heat_load', 'text', false, null, 'kW', null, null, null, null),
    (page_id, 'indoor_unit_fits', 'switch', true, 'true', null, null, null, null, null),
    (page_id, 'indoor_outdoor_distance', 'slider', true, '10', null, 1, 50, 0.1, 'm'),
    (page_id, 'outdoor_unit_installable', 'switch', true, 'true', null, null, null, null, null),
    (page_id, 'condensate_drainage', 'dropdown', true, 'Csatorna/lefolyó', null, null, null, null, null),
    (page_id, 'drainage_distance', 'number', true, '5', null, 1, 100, null, 'm'),
    (page_id, 'hot_water_users_count', 'number', true, '4', null, 1, 20, null, null),
    (page_id, 'hot_water_users_increase', 'switch', true, 'false', null, null, null, null, null),
    (page_id, 'bath_or_shower', 'text', true, null, 'pl. 2 zuhanyzó, 1 kád', null, null, null, null),
    (page_id, 'pool_heating', 'switch', true, 'false', null, null, null, null, null),
    (page_id, 'special_requirements', 'text', false, null, 'pl. HMKE kiépítése, ingatlan szigetelése stb.', null, null, null, null),
    (page_id, 'installation_comments', 'textarea', false, null, 'További megjegyzések a kivitelezéshez...', null, null, null, null);

    -- Update condensate_drainage options
    UPDATE public.survey_questions
    SET options = '["Kavicságy", "Csatorna/lefolyó"]'::jsonb
    WHERE survey_page_id = page_id AND name = 'condensate_drainage';

    RAISE NOTICE 'Heat Pump missing survey categories added successfully';

END $$;
