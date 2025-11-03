-- ============================================================================
-- Migration: Update Heat Pump Question Sequences and Display Conditions
-- Description: Reorders questions for Heat Pump pages and adds display conditions
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_windows_id UUID;
    page_heating_basics_id UUID;
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
    -- Nyílászárók (Windows) Page
    -- ========================================================================

    SELECT id INTO page_windows_id
    FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id AND type = 'windows';

    IF page_windows_id IS NOT NULL THEN
        -- Remove is_special flag from window_material and window_glazing
        UPDATE public.survey_questions
        SET is_special = false
        WHERE survey_page_id = page_windows_id AND name IN ('window_material', 'window_glazing');

        -- Set question sequences
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_windows_id AND name = 'window_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_windows_id AND name = 'window_material';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_windows_id AND name = 'window_glazing';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_windows_id AND name = 'window_quantity';

        RAISE NOTICE 'Updated Windows page sequences and removed special flags';
    END IF;

    -- ========================================================================
    -- Fűtés alapadatok (Heating Basics) Page
    -- ========================================================================

    SELECT id INTO page_heating_basics_id
    FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id AND type = 'heating_basics';

    IF page_heating_basics_id IS NOT NULL THEN
        -- Set question sequences
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_heating_basics_id AND name = 'current_heating_solution';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_heating_basics_id AND name = 'current_heating_solution_other';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_heating_basics_id AND name = 'current_heat_distribution';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_heating_basics_id AND name = 'current_heat_distribution_other';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_heating_basics_id AND name = 'current_hot_water';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_heating_basics_id AND name = 'current_hot_water_size';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_heating_basics_id AND name = 'solar_collector_support';

        RAISE NOTICE 'Updated Heating Basics page sequences';
    END IF;

    -- ========================================================================
    -- Igényelt konstrukció (Desired Construction) Page
    -- ========================================================================

    SELECT id INTO page_desired_construction_id
    FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id AND type = 'desired_construction';

    IF page_desired_construction_id IS NOT NULL THEN
        -- Set question sequences
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_desired_construction_id AND name = 'goal';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_desired_construction_id AND name = 'subsidy';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_desired_construction_id AND name = 'heat_pump_usage';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_desired_construction_id AND name = 'hot_water_solution';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_desired_construction_id AND name = 'external_storage';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_desired_construction_id AND name = 'heat_distribution';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_desired_construction_id AND name = 'h_tariff';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_desired_construction_id AND name = 'tank_capacity';

        -- Add display condition to external_storage (show only when hot_water_solution = "Hőszivattyúval")
        UPDATE public.survey_questions
        SET display_conditions = jsonb_build_object(
            'field', 'hot_water_solution',
            'operator', 'equals',
            'value', 'Hőszivattyúval'
        )
        WHERE survey_page_id = page_desired_construction_id AND name = 'external_storage';

        RAISE NOTICE 'Updated Desired Construction page sequences and display conditions';
    END IF;

    -- ========================================================================
    -- Egyéb kérdések (Other Data/Questions) Page
    -- ========================================================================

    SELECT id INTO page_other_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id AND type = 'other_data';

    IF page_other_data_id IS NOT NULL THEN
        -- Set question sequences
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_other_data_id AND name = 'annual_gas_consumption';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_other_data_id AND name = 'calculated_heat_demand';
        UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_other_data_id AND name = 'calculation_source';
        UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_other_data_id AND name = 'calculated_winter_heat_loss';
        UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_other_data_id AND name = 'summer_heat_load';
        UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_other_data_id AND name = 'indoor_unit_fits';
        UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_other_data_id AND name = 'indoor_outdoor_distance';
        UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_other_data_id AND name = 'outdoor_unit_installable';
        UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_other_data_id AND name = 'condensate_drainage';
        UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_other_data_id AND name = 'drainage_distance';
        UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_other_data_id AND name = 'hot_water_users_count';
        UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_other_data_id AND name = 'hot_water_users_increase';
        UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_other_data_id AND name = 'bath_or_shower';
        UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_other_data_id AND name = 'pool_heating';
        UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_other_data_id AND name = 'special_requirements';
        UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_other_data_id AND name = 'installation_comments';

        RAISE NOTICE 'Updated Other Questions page sequences';
    END IF;

    RAISE NOTICE 'Successfully updated Heat Pump question sequences and display conditions';

END $$;
