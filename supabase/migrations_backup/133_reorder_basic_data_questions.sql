-- ============================================================================
-- Migration: Reorder Basic Data Questions
-- Description: Reorders questions on Alapadatok pages for Alapadatok,
--              Homlokzati szigetelés, and Padlásfödém szigetelés investments
-- ============================================================================

DO $$
DECLARE
    inv_basic_data_id UUID;
    page_basic_data_id UUID;
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Reordering Basic Data Questions';
    RAISE NOTICE '========================================';

    -- ========================================================================
    -- PART 1: Alapadatok Investment - Alapadatok Page
    -- ========================================================================

    -- Get investment ID for "Alapadatok"
    SELECT id INTO inv_basic_data_id
    FROM public.investments
    WHERE name = 'Alapadatok';

    IF inv_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Investment "Alapadatok" not found';
    END IF;

    -- Get page ID for "Alapadatok" page
    SELECT id INTO page_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_basic_data_id
      AND type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Survey page "Alapadatok" not found';
    END IF;

    RAISE NOTICE 'Found Alapadatok page: %', page_basic_data_id;

    -- Reorder questions according to new sequence
    -- Main questions (1-37)
    UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_basic_data_id AND name = 'building_type';
    UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_basic_data_id AND name = 'construction_year';
    UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_basic_data_id AND name = 'floor_levels_title';
    UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_basic_data_id AND name = 'has_basement';
    UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_basic_data_id AND name = 'has_cellar';
    UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_basic_data_id AND name = 'has_ground_floor';
    UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_basic_data_id AND name = 'has_upper_floor';
    UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_basic_data_id AND name = 'has_attic';
    UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_basic_data_id AND name = 'exterior_wall_structure';
    UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_basic_data_id AND name = 'exterior_wall_structure_other';
    UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_basic_data_id AND name = 'walls_uniform_type';
    UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_basic_data_id AND name = 'roof_type_general';
    UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_basic_data_id AND name = 'roof_angle';
    UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_basic_data_id AND name = 'building_useful_floor_area';
    UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_basic_data_id AND name = 'window_door_type';
    UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_basic_data_id AND name = 'electricity_consumption_title';
    UPDATE public.survey_questions SET sequence = 17 WHERE survey_page_id = page_basic_data_id AND name = 'electricity_period';
    UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_basic_data_id AND name = 'electricity_unit';
    UPDATE public.survey_questions SET sequence = 19 WHERE survey_page_id = page_basic_data_id AND name = 'electricity_consumption';
    UPDATE public.survey_questions SET sequence = 20 WHERE survey_page_id = page_basic_data_id AND name = 'gas_consumption_title';
    UPDATE public.survey_questions SET sequence = 21 WHERE survey_page_id = page_basic_data_id AND name = 'gas_period';
    UPDATE public.survey_questions SET sequence = 22 WHERE survey_page_id = page_basic_data_id AND name = 'gas_unit';
    UPDATE public.survey_questions SET sequence = 23 WHERE survey_page_id = page_basic_data_id AND name = 'gas_consumption';
    UPDATE public.survey_questions SET sequence = 24 WHERE survey_page_id = page_basic_data_id AND name = 'heating_system_heat_generator';
    UPDATE public.survey_questions SET sequence = 25 WHERE survey_page_id = page_basic_data_id AND name = 'heating_system_heat_generator_other';
    UPDATE public.survey_questions SET sequence = 26 WHERE survey_page_id = page_basic_data_id AND name = 'hot_water_preparation_method';
    UPDATE public.survey_questions SET sequence = 27 WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulated';
    UPDATE public.survey_questions SET sequence = 28 WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulation_material';
    UPDATE public.survey_questions SET sequence = 29 WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulation_thickness';
    UPDATE public.survey_questions SET sequence = 30 WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulated';
    UPDATE public.survey_questions SET sequence = 31 WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulation_material';
    UPDATE public.survey_questions SET sequence = 32 WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulation_thickness';
    UPDATE public.survey_questions SET sequence = 33 WHERE survey_page_id = page_basic_data_id AND name = 'available_power_title';
    UPDATE public.survey_questions SET sequence = 34 WHERE survey_page_id = page_basic_data_id AND name = 'available_phases';
    UPDATE public.survey_questions SET sequence = 35 WHERE survey_page_id = page_basic_data_id AND name = 'phase_1_power';
    UPDATE public.survey_questions SET sequence = 36 WHERE survey_page_id = page_basic_data_id AND name = 'phase_2_power';
    UPDATE public.survey_questions SET sequence = 37 WHERE survey_page_id = page_basic_data_id AND name = 'phase_3_power';

    -- Accordion questions (38-40)
    UPDATE public.survey_questions SET sequence = 38 WHERE survey_page_id = page_basic_data_id AND name = 'building_protected';
    UPDATE public.survey_questions SET sequence = 39 WHERE survey_page_id = page_basic_data_id AND name = 'building_protection_type';
    UPDATE public.survey_questions SET sequence = 40 WHERE survey_page_id = page_basic_data_id AND name = 'general_notes';

    RAISE NOTICE 'Reordered questions on Alapadatok Investment';

    -- ========================================================================
    -- PART 2: Homlokzati szigetelés Investment - Alapadatok Page
    -- ========================================================================

    -- Get investment ID for "Homlokzati szigetelés"
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Investment "Homlokzati szigetelés" not found';
    END IF;

    -- Get page ID for "Alapadatok" page of facade insulation
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id
      AND type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Survey page "Alapadatok" for Homlokzati szigetelés not found';
    END IF;

    RAISE NOTICE 'Found Homlokzati szigetelés Alapadatok page: %', page_facade_basic_data_id;

    -- Reorder questions according to new sequence
    -- Main questions (1-16)
    UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_facade_basic_data_id AND name = 'facade_insulation';
    UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulation';
    UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_facade_basic_data_id AND name = 'site_conditions_title';
    UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_facade_basic_data_id AND name = 'facades_scaffoldable';
    UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_facade_basic_data_id AND name = 'container_placement';
    UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_facade_basic_data_id AND name = 'truck_accessible';
    UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_facade_basic_data_id AND name = 'material_storage_on_site';
    UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_facade_basic_data_id AND name = 'wall_thickness_avg';
    UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_facade_basic_data_id AND name = 'wall_thickness_uniform';
    UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_type_avg';
    UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_type_uniform';
    UPDATE public.survey_questions SET sequence = 12 WHERE survey_page_id = page_facade_basic_data_id AND name = 'protrusion_amount';
    UPDATE public.survey_questions SET sequence = 13 WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulated_general';
    UPDATE public.survey_questions SET sequence = 14 WHERE survey_page_id = page_facade_basic_data_id AND name = 'reveal_depth_avg';
    UPDATE public.survey_questions SET sequence = 15 WHERE survey_page_id = page_facade_basic_data_id AND name = 'coloring';
    UPDATE public.survey_questions SET sequence = 16 WHERE survey_page_id = page_facade_basic_data_id AND name = 'structure';

    -- Accordion questions (17-20)
    UPDATE public.survey_questions SET sequence = 17 WHERE survey_page_id = page_facade_basic_data_id AND name = 'defects_title';
    UPDATE public.survey_questions SET sequence = 18 WHERE survey_page_id = page_facade_basic_data_id AND name = 'structural_damage_visible';
    UPDATE public.survey_questions SET sequence = 19 WHERE survey_page_id = page_facade_basic_data_id AND name = 'moisture_damage_visible';
    UPDATE public.survey_questions SET sequence = 20 WHERE survey_page_id = page_facade_basic_data_id AND name = 'water_damage_visible';

    RAISE NOTICE 'Reordered questions on Homlokzati szigetelés Alapadatok page';

    -- ========================================================================
    -- PART 3: Padlásfödém szigetelés Investment - Tetőtér adatai Page
    -- ========================================================================

    -- Get investment ID for "Padlásfödém szigetelés"
    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Investment "Padlásfödém szigetelés" not found';
    END IF;

    -- Get page ID for "Tetőtér adatai" page
    SELECT id INTO page_attic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'attic_data';

    IF page_attic_data_id IS NULL THEN
        RAISE EXCEPTION 'Survey page "Tetőtér adatai" for Padlásfödém szigetelés not found';
    END IF;

    RAISE NOTICE 'Found Padlásfödém szigetelés Tetőtér adatai page: %', page_attic_data_id;

    -- Reorder questions according to new sequence
    UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_attic_data_id AND name = 'attic_type';
    UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_attic_data_id AND name = 'attic_floor_structure';
    UPDATE public.survey_questions SET sequence = 3 WHERE survey_page_id = page_attic_data_id AND name = 'attic_floor_top_layer';
    UPDATE public.survey_questions SET sequence = 4 WHERE survey_page_id = page_attic_data_id AND name = 'heated_space_surface_title';
    UPDATE public.survey_questions SET sequence = 5 WHERE survey_page_id = page_attic_data_id AND name = 'width';
    UPDATE public.survey_questions SET sequence = 6 WHERE survey_page_id = page_attic_data_id AND name = 'length';
    UPDATE public.survey_questions SET sequence = 7 WHERE survey_page_id = page_attic_data_id AND name = 'calculated_surface_area';
    UPDATE public.survey_questions SET sequence = 8 WHERE survey_page_id = page_attic_data_id AND name = 'min_height';
    UPDATE public.survey_questions SET sequence = 9 WHERE survey_page_id = page_attic_data_id AND name = 'max_height';
    UPDATE public.survey_questions SET sequence = 10 WHERE survey_page_id = page_attic_data_id AND name = 'planned_usage';
    UPDATE public.survey_questions SET sequence = 11 WHERE survey_page_id = page_attic_data_id AND name = 'planned_insulation_type';

    RAISE NOTICE 'Reordered questions on Padlásfödém szigetelés Tetőtér adatai page';

    RAISE NOTICE '========================================';
    RAISE NOTICE 'All Questions Reordered Successfully!';
    RAISE NOTICE '========================================';

END $$;
