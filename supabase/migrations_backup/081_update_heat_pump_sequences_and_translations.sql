-- ============================================================================
-- Migration: Update Heat Pump Survey Pages and Questions Sequences/Translations
-- Description: Sets sequence for Heat Pump pages and adds name_translations
--              to all Heat Pump survey questions
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_rooms_id UUID;
    page_windows_id UUID;
    page_heating_basics_id UUID;
    page_radiators_id UUID;
    page_desired_construction_id UUID;
    page_other_data_id UUID;
BEGIN
    -- Get Heat Pump investment ID
    SELECT id INTO inv_heat_pump_id
    FROM public.investments
    WHERE persist_name = 'heatPump';

    IF inv_heat_pump_id IS NULL THEN
        RAISE EXCEPTION 'Heat Pump investment not found';
    END IF;

    -- ========================================================================
    -- Update Page Sequences
    -- ========================================================================

    -- Page 2: Helyiségek (Rooms)
    UPDATE public.survey_pages
    SET sequence = 2,
        name_translations = jsonb_build_object('hu', 'Helyiségek', 'en', 'Rooms')
    WHERE investment_id = inv_heat_pump_id AND type = 'rooms'
    RETURNING id INTO page_rooms_id;

    -- Page 3: Nyílászárók (Windows)
    UPDATE public.survey_pages
    SET sequence = 3,
        name_translations = jsonb_build_object('hu', 'Nyílászárók', 'en', 'Windows')
    WHERE investment_id = inv_heat_pump_id AND type = 'windows'
    RETURNING id INTO page_windows_id;

    -- Page 4: Fűtés alapadatok (Heating Basics)
    UPDATE public.survey_pages
    SET sequence = 4,
        name_translations = jsonb_build_object('hu', 'Fűtés alapadatok', 'en', 'Heating Basics')
    WHERE investment_id = inv_heat_pump_id AND type = 'heating_basics'
    RETURNING id INTO page_heating_basics_id;

    -- Page 5: Radiátorok (Radiators)
    UPDATE public.survey_pages
    SET sequence = 5,
        name_translations = jsonb_build_object('hu', 'Radiátorok', 'en', 'Radiators')
    WHERE investment_id = inv_heat_pump_id AND type = 'radiators'
    RETURNING id INTO page_radiators_id;

    -- Page 6: Igényelt konstrukció (Desired Construction)
    UPDATE public.survey_pages
    SET sequence = 6,
        name_translations = jsonb_build_object('hu', 'Igényelt konstrukció', 'en', 'Desired Construction')
    WHERE investment_id = inv_heat_pump_id AND type = 'desired_construction'
    RETURNING id INTO page_desired_construction_id;

    -- Page 7: Egyéb kérdések (Other Data)
    UPDATE public.survey_pages
    SET sequence = 7,
        name_translations = jsonb_build_object('hu', 'Egyéb kérdések', 'en', 'Other Questions')
    WHERE investment_id = inv_heat_pump_id AND type = 'other_data'
    RETURNING id INTO page_other_data_id;

    -- ========================================================================
    -- Helyiségek (Rooms) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Elnevezés', 'en', 'Naming')
    WHERE survey_page_id = page_rooms_id AND name = 'room_name';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Méret', 'en', 'Size')
    WHERE survey_page_id = page_rooms_id AND name = 'room_size';

    -- ========================================================================
    -- Nyílászárók (Windows) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Mennyiség', 'en', 'Quantity')
    WHERE survey_page_id = page_windows_id AND name = 'window_quantity';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Típus', 'en', 'Type')
    WHERE survey_page_id = page_windows_id AND name = 'window_type';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Üvegezés', 'en', 'Glazing')
    WHERE survey_page_id = page_windows_id AND name = 'window_glazing';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Anyag', 'en', 'Material')
    WHERE survey_page_id = page_windows_id AND name = 'window_material';

    -- ========================================================================
    -- Fűtés alapadatok (Heating Basics) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Jelenlegi fűtési megoldás', 'en', 'Current Heating Solution')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_heating_solution';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Jelenlegi fűtési megoldás pontos típusa', 'en', 'Exact Type of Current Heating Solution')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_heating_solution_other';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Jelenlegi hőleadó kör', 'en', 'Current Heat Distribution')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_heat_distribution';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Jelenlegi hőleadó kör pontos típusa', 'en', 'Exact Type of Current Heat Distribution')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_heat_distribution_other';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Jelenlegi HMV', 'en', 'Current Hot Water')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_hot_water';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Mérete (liter)', 'en', 'Size (liters)')
    WHERE survey_page_id = page_heating_basics_id AND name = 'current_hot_water_size';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Napkollektoros rásegítés?', 'en', 'Solar Collector Support?')
    WHERE survey_page_id = page_heating_basics_id AND name = 'solar_collector_support';

    -- ========================================================================
    -- Radiátorok (Radiators) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Méret', 'en', 'Size')
    WHERE survey_page_id = page_radiators_id AND name = 'radiator_size';

    -- ========================================================================
    -- Igényelt konstrukció (Desired Construction) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Cél', 'en', 'Goal')
    WHERE survey_page_id = page_desired_construction_id AND name = 'goal';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Pályázat?', 'en', 'Subsidy?')
    WHERE survey_page_id = page_desired_construction_id AND name = 'subsidy';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Mire szeretné használni a hőszivattyút?', 'en', 'What would you like to use the heat pump for?')
    WHERE survey_page_id = page_desired_construction_id AND name = 'heat_pump_usage';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'HMV', 'en', 'Hot Water')
    WHERE survey_page_id = page_desired_construction_id AND name = 'hot_water_solution';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Külső tároló?', 'en', 'External Storage?')
    WHERE survey_page_id = page_desired_construction_id AND name = 'external_storage';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Hőleadó', 'en', 'Heat Distribution')
    WHERE survey_page_id = page_desired_construction_id AND name = 'heat_distribution';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'H tarifát szeretne igényelni?', 'en', 'Would you like to apply for H tariff?')
    WHERE survey_page_id = page_desired_construction_id AND name = 'h_tariff';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Hány literes tartályra van szükség?', 'en', 'What capacity tank is needed?')
    WHERE survey_page_id = page_desired_construction_id AND name = 'tank_capacity';

    -- ========================================================================
    -- Egyéb kérdések (Other Questions) - Question Translations
    -- ========================================================================

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Elmúlt 1 év gázfogyasztása', 'en', 'Gas consumption in the past year')
    WHERE survey_page_id = page_other_data_id AND name = 'annual_gas_consumption';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Számított hőszükséglet', 'en', 'Calculated heat demand')
    WHERE survey_page_id = page_other_data_id AND name = 'calculated_heat_demand';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Forrása', 'en', 'Source')
    WHERE survey_page_id = page_other_data_id AND name = 'calculation_source';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Számított téli hőveszteség', 'en', 'Calculated winter heat loss')
    WHERE survey_page_id = page_other_data_id AND name = 'calculated_winter_heat_loss';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Nyári hőterhelés', 'en', 'Summer heat load')
    WHERE survey_page_id = page_other_data_id AND name = 'summer_heat_load';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Beltéri egység elfér', 'en', 'Indoor unit fits')
    WHERE survey_page_id = page_other_data_id AND name = 'indoor_unit_fits';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Beltéri és kültéri egység közötti távolság (m)', 'en', 'Distance between indoor and outdoor units (m)')
    WHERE survey_page_id = page_other_data_id AND name = 'indoor_outdoor_distance';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Kültéri egység kihelyezhető?', 'en', 'Can outdoor unit be installed?')
    WHERE survey_page_id = page_other_data_id AND name = 'outdoor_unit_installable';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Kondenzvíz elvezetés', 'en', 'Condensate drainage')
    WHERE survey_page_id = page_other_data_id AND name = 'condensate_drainage';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Távolsága', 'en', 'Distance')
    WHERE survey_page_id = page_other_data_id AND name = 'drainage_distance';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'HMV használók száma (fő)', 'en', 'Number of hot water users')
    WHERE survey_page_id = page_other_data_id AND name = 'hot_water_users_count';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Nőni fog-e várhatóan a HMV használók száma?', 'en', 'Is the number of hot water users expected to increase?')
    WHERE survey_page_id = page_other_data_id AND name = 'hot_water_users_increase';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Kád vagy zuhanyzó van az ingatlanban?', 'en', 'Is there a bathtub or shower in the property?')
    WHERE survey_page_id = page_other_data_id AND name = 'bath_or_shower';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Lesz vagy van-e a kertben medence amit fűteni kell?', 'en', 'Will there be or is there a pool in the garden that needs heating?')
    WHERE survey_page_id = page_other_data_id AND name = 'pool_heating';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Egyedi igények, jövőbeni tervek', 'en', 'Special requirements, future plans')
    WHERE survey_page_id = page_other_data_id AND name = 'special_requirements';

    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object('hu', 'Megjegyzés a kivitelezéshez', 'en', 'Comments for installation')
    WHERE survey_page_id = page_other_data_id AND name = 'installation_comments';

    RAISE NOTICE 'Successfully updated sequences and translations for Heat Pump survey pages and questions';

END $$;
