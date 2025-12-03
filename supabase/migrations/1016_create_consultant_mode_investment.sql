-- ============================================================================
-- Migration: Create Consultant Mode (Tanácsadó mód) Investment
-- Description: Creates a new investment type for consultant mode with 3 survey pages
--              matching the OFP (Sherpa) project structure for energy consultation
-- ============================================================================

DO $$
DECLARE
    inv_consultant_id UUID;
    page_building_physics_id UUID;
    page_energy_consumption_id UUID;
    page_other_info_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Create Consultant Mode Investment
    -- ========================================================================

    INSERT INTO public.investments (
        name,
        icon,
        position,
        sequence,
        persist_name,
        energy_efficiency_improvement,
        is_default
    ) VALUES (
        'Tanácsadó mód',
        'i-lucide-clipboard-list',
        '{"top": 250, "right": 200}'::jsonb,
        11,  -- Next sequence after current max (10)
        'consultantMode',
        0,
        false
    )
    RETURNING id INTO inv_consultant_id;

    RAISE NOTICE 'Created Consultant Mode investment with ID: %', inv_consultant_id;

    -- ========================================================================
    -- STEP 2: Create Survey Pages (3 pages)
    -- ========================================================================

    -- Page 1: Épületfizikai, geometriai adatok
    INSERT INTO public.survey_pages (
        investment_id,
        name,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_consultant_id,
        'Épületfizikai, geometriai adatok',
        'building_physics',
        '{"top": 50, "right": 200}'::jsonb,
        false,
        false,
        1
    )
    RETURNING id INTO page_building_physics_id;

    -- Page 2: Energiafelhasználási adatok
    INSERT INTO public.survey_pages (
        investment_id,
        name,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_consultant_id,
        'Energiafelhasználási adatok',
        'energy_consumption',
        '{"top": 300, "right": 150}'::jsonb,
        false,
        false,
        2
    )
    RETURNING id INTO page_energy_consumption_id;

    -- Page 3: Egyéb információk, csatolandó dokumentumok
    INSERT INTO public.survey_pages (
        investment_id,
        name,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_consultant_id,
        'Egyéb információk, csatolandó dokumentumok',
        'other_info',
        '{"top": 300, "right": 250}'::jsonb,
        false,
        false,
        3
    )
    RETURNING id INTO page_other_info_id;

    RAISE NOTICE 'Created 3 survey pages for Consultant Mode';

    -- ========================================================================
    -- STEP 3: PAGE 1 - Épületfizikai, geometriai adatok
    -- ========================================================================

    -- Ingatlan típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options_translations
    ) VALUES (
        page_building_physics_id,
        'home_type',
        jsonb_build_object('hu', 'Ingatlan típusa', 'en', 'Property Type'),
        'icon_selector',
        true,
        1,
        jsonb_build_array(
          jsonb_build_object(
            'value', 'Családi ház',
            'label', jsonb_build_object('hu', 'Családi ház', 'en', 'Family House'),
            'icon', 'i-lucide-home'
          ),
          jsonb_build_object(
            'value', 'Ikerház',
            'label', jsonb_build_object('hu', 'Ikerház', 'en', 'Semi-detached House'),
            'icon', 'i-lucide-building'
          ),
          jsonb_build_object(
            'value', 'Sorház',
            'label', jsonb_build_object('hu', 'Sorház', 'en', 'Terraced House'),
            'icon', 'i-lucide-building-2'
          )
        )
    );

    -- Építési év
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max
    ) VALUES (
        page_building_physics_id, 'construction_year', jsonb_build_object('hu', 'A lakás/ház építési éve', 'en', 'Year of Construction'), 'number', true, 2, 1900, 2025
    );

    -- Belső téli hőmérséklet
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_building_physics_id, 'internal_temperature', jsonb_build_object('hu', 'Lakás téli belső hőmérséklete', 'en', 'Winter Indoor Temperature'), 'number', true, 3, 0, 30, '°C'
    );

    -- Ingatlan fő életterének tájolása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_building_physics_id, 'house_orientation', jsonb_build_object('hu', 'Az ingatlan fő életterének tájolása', 'en', 'Main Living Area Orientation'), 'orientation_selector', true, 4
    );

    -- Hány szintes az ingatlan?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options_translations
    ) VALUES (
        page_building_physics_id,
        'home_floor',
        jsonb_build_object('hu', 'Hány szintes az ingatlan?', 'en', 'Number of Floors'),
        'icon_selector',
        false,
        5,
        jsonb_build_array(
          jsonb_build_object(
            'value', '1 szintes ház',
            'label', jsonb_build_object('hu', '1 szintes ház', 'en', '1 storey house'),
            'icon', 'i-lucide-square'
          ),
          jsonb_build_object(
            'value', '2 szintes ház',
            'label', jsonb_build_object('hu', '2 szintes ház', 'en', '2 storey house'),
            'icon', 'i-lucide-layers-2'
          ),
          jsonb_build_object(
            'value', '3 szintes ház',
            'label', jsonb_build_object('hu', '3 szintes ház', 'en', '3 storey house'),
            'icon', 'i-lucide-layers-3'
          ),
          jsonb_build_object(
            'value', 'Több, mint 3 szintes',
            'label', jsonb_build_object('hu', 'Több, mint 3 szintes', 'en', 'More than 3 storeys'),
            'icon', 'i-lucide-layers'
          )
        )
    );

    -- Pincével rendelkezik?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_building_physics_id, 'has_basement', jsonb_build_object('hu', 'Pincével rendelkezik', 'en', 'Has Basement'), 'switch', false, 6
    );

    -- Beépített tetőtérrel rendelkezik?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_building_physics_id, 'has_attic', jsonb_build_object('hu', 'Beépített tetőtérrel rendelkezik', 'en', 'Has Built-in Attic'), 'switch', false, 7
    );

    -- Alapterület és magasság mezők (pince, 1-4. szint, tetőtér)
    -- Minden szintnél 4 kérdés egymás után: alapterület, fűtött alapterület, belmagasság (range), eresz magasság (range)

    -- Pince kérdések (10-13) - csak akkor jelennek meg, ha has_basement = true, 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_basement', jsonb_build_object('hu', 'Pince szintjének alapterülete', 'en', 'Basement Floor Area'), 'number', false, 10, 10, 1000, 'm²', NULL,
         jsonb_build_object('field', 'has_basement', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_basement', jsonb_build_object('hu', 'Pince fűtött alapterülete', 'en', 'Basement Heated Floor Area'), 'number', false, 11, 0, 300, 'm²', NULL,
         jsonb_build_object('field', 'has_basement', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_basement', jsonb_build_object('hu', 'Pince belmagassága', 'en', 'Basement Height'), 'range', false, 12, 2.5, 7, 'm', 0.1,
         jsonb_build_object('field', 'has_basement', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_basement', jsonb_build_object('hu', 'Pince átlagos eresz magassága', 'en', 'Basement Average Eaves Height'), 'range', false, 13, 2.5, 20, 'm', 0.1,
         jsonb_build_object('field', 'has_basement', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2'));

    -- Pincefödém hőszigetelés kérdések (14-16) - csak akkor jelennek meg, ha has_basement = true / basement_slab_thermal_insulation = true
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'basement_slab_thermal_insulation', jsonb_build_object('hu', 'Pincefödém hőszigetelés', 'en', 'Basement Ceiling Insulation'), 'switch', false, 14, NULL, NULL, NULL,
         jsonb_build_object('field', 'has_basement', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', 'full')),
        (page_building_physics_id, 'basement_slab_thickness', jsonb_build_object('hu', 'Pincefödém hőszigetelés vastagsága', 'en', 'Basement Ceiling Insulation Thickness'), 'number', false, 15, 2, 25, 'cm',
         jsonb_build_object('field', 'basement_slab_thermal_insulation', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2'));

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'basement_slab_type', jsonb_build_object('hu', 'Pincefödém hőszigetelés típusa', 'en', 'Basement Ceiling Insulation Type'), 'dropdown', false, 16,
         '["EPS", "XPS", "Ásványgyapot", "Nincs"]'::jsonb,
         jsonb_build_object('field', 'basement_slab_thermal_insulation', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2'));

    -- 1. szint kérdések (17-20) - mindig jelennek meg, 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_ground', jsonb_build_object('hu', '1. szint alapterülete', 'en', '1st Floor Area'), 'number', false, 17, 10, 300, 'm²', NULL, jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_ground', jsonb_build_object('hu', '1. szint fűtött alapterülete', 'en', '1st Floor Heated Area'), 'number', false, 18, 0, 300, 'm²', NULL, jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_ground', jsonb_build_object('hu', '1. szint belmagassága', 'en', '1st Floor Height'), 'range', false, 19, 2.5, 7, 'm', 0.1, jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_ground', jsonb_build_object('hu', '1. szint átlagos eresz magassága', 'en', '1st Floor Average Eaves Height'), 'range', false, 20, 2.5, 20, 'm', 0.1, jsonb_build_object('width', '1/2'));

    -- 2. szint kérdések (21-24) - csak akkor jelennek meg, ha home_floor = "2 szintes ház", "3 szintes ház", vagy "Több, mint 3 szintes", 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_first', jsonb_build_object('hu', '2. szint alapterülete', 'en', '2nd Floor Area'), 'number', false, 21, 10, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('2 szintes ház', '3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_first', jsonb_build_object('hu', '2. szint fűtött alapterülete', 'en', '2nd Floor Heated Area'), 'number', false, 22, 0, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('2 szintes ház', '3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_first', jsonb_build_object('hu', '2. szint belmagassága', 'en', '2nd Floor Height'), 'range', false, 23, 2.5, 7, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('2 szintes ház', '3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_first', jsonb_build_object('hu', '2. szint eresz magassága', 'en', '2nd Floor Eaves Height'), 'range', false, 24, 2.5, 20, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('2 szintes ház', '3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2'));

    -- 3. szint kérdések (25-28) - csak akkor jelennek meg, ha home_floor = "3 szintes ház" vagy "Több, mint 3 szintes", 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_second', jsonb_build_object('hu', '3. szint alapterülete', 'en', '3rd Floor Area'), 'number', false, 25, 10, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_second', jsonb_build_object('hu', '3. szint fűtött alapterülete', 'en', '3rd Floor Heated Area'), 'number', false, 26, 0, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_second', jsonb_build_object('hu', '3. szint belmagassága', 'en', '3rd Floor Height'), 'range', false, 27, 2.5, 7, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_second', jsonb_build_object('hu', '3. szint eresz magassága', 'en', '3rd Floor Eaves Height'), 'range', false, 28, 2.5, 20, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', jsonb_build_array('3 szintes ház', 'Több, mint 3 szintes'), 'operator', 'in'), jsonb_build_object('width', '1/2'));

    -- 4. szint kérdések (29-32) - csak akkor jelennek meg, ha home_floor = "Több, mint 3 szintes", 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_third', jsonb_build_object('hu', '4. szint alapterülete', 'en', '4th Floor Area'), 'number', false, 29, 10, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', 'Több, mint 3 szintes', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_third', jsonb_build_object('hu', '4. szint fűtött alapterülete', 'en', '4th Floor Heated Area'), 'number', false, 30, 0, 300, 'm²', NULL,
         jsonb_build_object('field', 'home_floor', 'value', 'Több, mint 3 szintes', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_third', jsonb_build_object('hu', '4. szint belmagassága', 'en', '4th Floor Height'), 'range', false, 31, 2.5, 7, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', 'Több, mint 3 szintes', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_third', jsonb_build_object('hu', '4. szint eresz magassága', 'en', '4th Floor Eaves Height'), 'range', false, 32, 2.5, 20, 'm', 0.1,
         jsonb_build_object('field', 'home_floor', 'value', 'Több, mint 3 szintes', 'operator', 'equals'), jsonb_build_object('width', '1/2'));

    -- Tetőtér kérdések (33-36) - csak akkor jelennek meg, ha has_attic = true, 1/2 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, step, display_conditions, display_settings
    ) VALUES
        (page_building_physics_id, 'floor_nm_attic', jsonb_build_object('hu', 'Tetőtér alapterülete', 'en', 'Attic Floor Area'), 'number', false, 33, 10, 300, 'm²', NULL,
         jsonb_build_object('field', 'has_attic', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_heated_nm_attic', jsonb_build_object('hu', 'Tetőtér fűtött alapterülete', 'en', 'Attic Heated Floor Area'), 'number', false, 34, 0, 300, 'm²', NULL,
         jsonb_build_object('field', 'has_attic', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'floor_height_attic', jsonb_build_object('hu', 'Tetőtér belmagassága', 'en', 'Attic Floor Height'), 'range', false, 35, 2.5, 7, 'm', 0.1,
         jsonb_build_object('field', 'has_attic', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')),
        (page_building_physics_id, 'average_eaves_height_attic', jsonb_build_object('hu', 'Tetőtér átlagos eresz magassága', 'en', 'Attic Average Eaves Height'), 'range', false, 36, 2.5, 20, 'm', 0.1,
         jsonb_build_object('field', 'has_attic', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2'));

    -- Külső falak típusa (37)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, step, display_settings
    ) VALUES (
        page_building_physics_id,
        'external_wall_types_count',
        jsonb_build_object('hu', 'Külső falak típusa', 'en', 'External Wall Types'),
        'range',
        false,
        37,
        1,
        5,
        1,
        jsonb_build_object('width', 'full')
    );

    -- Figyelmeztetés a falfelület arányokról (38)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES (
        page_building_physics_id,
        'wall_area_ratio_warning',
        jsonb_build_object(
            'hu', 'Figyelem! Falfelület arány megadása esetén az összegnek 100%-nak kell lenni a pontos energiamérleghez.',
            'en', 'Attention! When specifying wall area ratios, the sum must be 100% for an accurate energy balance.'
        ),
        'warning',
        false,
        38,
        jsonb_build_object('width', 'full')
    );

    -- ========================================================================
    -- 1. falfelület (40-45) - minden kérdés 1/2 szélesség
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_material_type_0', jsonb_build_object('hu', 'Fal anyaga (1. falfelület)', 'en', 'Wall Material Type 0'), 'dropdown', false, 40,
         '["Tégla 38cm", "Tégla 50cm", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb, jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_surface_thickness_0', jsonb_build_object('hu', 'Fal vastagsága (1. falfelület)', 'en', 'Wall Thickness 0'), 'number', false, 41, 15, 100, 'cm', jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_area_ratio_0', jsonb_build_object('hu', 'Fal területi aránya (1. falfelület)', 'en', 'Wall Area Ratio 0'), 'number', false, 42, 1, 100, '%', jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_0', jsonb_build_object('hu', 'Hőszigetelés (1. falfelület)', 'en', 'Thermal Insulation (1st wall surface)'), 'switch', false, 43, jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_thickness_0', jsonb_build_object('hu', 'Hőszigetelés vastagsága (1. falfelület)', 'en', 'Thermal Insulation Thickness 0'), 'number', false, 44, 2, 30, 'cm',
        jsonb_build_object('field', 'wall_thermal_insulation_0', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_type_0', jsonb_build_object('hu', 'Hőszigetelés típusa (1. falfelület)', 'en', 'Thermal Insulation Type 0'), 'dropdown', false, 45,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS"]'::jsonb,
        jsonb_build_object('field', 'wall_thermal_insulation_0', 'value', 'true', 'operator', 'equals'), jsonb_build_object('width', '1/2')
    );

    -- ========================================================================
    -- 2. falfelület (46-51) - minden kérdés 1/2 szélesség
    -- Megjelenés: external_wall_types_count >= 2
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_material_type_1', jsonb_build_object('hu', 'Fal anyaga (2. falfelület)', 'en', 'Wall Material Type 1'), 'dropdown', false, 46,
         '["Tégla 38cm", "Tégla 50cm", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_surface_thickness_1', jsonb_build_object('hu', 'Fal vastagsága (2. falfelület)', 'en', 'Wall Thickness 1'), 'number', false, 47, 15, 100, 'cm',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_area_ratio_1', jsonb_build_object('hu', 'Fal területi aránya (2. falfelület)', 'en', 'Wall Area Ratio 1'), 'number', false, 48, 1, 100, '%',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_1', jsonb_build_object('hu', 'Hőszigetelés (2. falfelület)', 'en', 'Thermal Insulation 1'), 'switch', false, 49,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_thickness_1', jsonb_build_object('hu', 'Hőszigetelés vastagsága (2. falfelület)', 'en', 'Thermal Insulation Thickness 1'), 'number', false, 50, 2, 30, 'cm',
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_1', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_type_1', jsonb_build_object('hu', 'Hőszigetelés típusa (2. falfelület)', 'en', 'Thermal Insulation Type 1'), 'dropdown', false, 51,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS"]'::jsonb,
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 2, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_1', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    -- ========================================================================
    -- 3. falfelület (52-57) - minden kérdés 1/2 szélesség
    -- Megjelenés: external_wall_types_count >= 3
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_material_type_2', jsonb_build_object('hu', 'Fal anyaga (3. falfelület)', 'en', 'Wall Material Type 2'), 'dropdown', false, 52,
         '["Tégla 38cm", "Tégla 50cm", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_surface_thickness_2', jsonb_build_object('hu', 'Fal vastagsága (3. falfelület)', 'en', 'Wall Thickness 2'), 'number', false, 53, 15, 100, 'cm',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_area_ratio_2', jsonb_build_object('hu', 'Fal területi aránya (3. falfelület)', 'en', 'Wall Area Ratio 2'), 'number', false, 54, 1, 100, '%',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_2', jsonb_build_object('hu', 'Hőszigetelés (3. falfelület)', 'en', 'Thermal Insulation 2'), 'switch', false, 55,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_thickness_2', jsonb_build_object('hu', 'Hőszigetelés vastagsága (3. falfelület)', 'en', 'Thermal Insulation Thickness 2'), 'number', false, 56, 2, 30, 'cm',
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_2', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_type_2', jsonb_build_object('hu', 'Hőszigetelés típusa (3. falfelület)', 'en', 'Thermal Insulation Type 2'), 'dropdown', false, 57,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS"]'::jsonb,
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 3, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_2', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    -- ========================================================================
    -- 4. falfelület (58-63) - minden kérdés 1/2 szélesség
    -- Megjelenés: external_wall_types_count >= 4
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_material_type_3', jsonb_build_object('hu', 'Fal anyaga (4. falfelület)', 'en', 'Wall Material Type 3'), 'dropdown', false, 58,
         '["Tégla 38cm", "Tégla 50cm", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_surface_thickness_3', jsonb_build_object('hu', 'Fal vastagsága (4. falfelület)', 'en', 'Wall Thickness 3'), 'number', false, 59, 15, 100, 'cm',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_area_ratio_3', jsonb_build_object('hu', 'Fal területi aránya (4. falfelület)', 'en', 'Wall Area Ratio 3'), 'number', false, 60, 1, 100, '%',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_3', jsonb_build_object('hu', 'Hőszigetelés (4. falfelület)', 'en', 'Thermal Insulation 3'), 'switch', false, 61,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_thickness_3', jsonb_build_object('hu', 'Hőszigetelés vastagsága (4. falfelület)', 'en', 'Thermal Insulation Thickness 3'), 'number', false, 62, 2, 30, 'cm',
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_3', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_type_3', jsonb_build_object('hu', 'Hőszigetelés típusa (4. falfelület)', 'en', 'Thermal Insulation Type 3'), 'dropdown', false, 63,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS"]'::jsonb,
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 4, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_3', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    -- ========================================================================
    -- 5. falfelület (64-69) - minden kérdés 1/2 szélesség
    -- Megjelenés: external_wall_types_count >= 5
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_material_type_4', jsonb_build_object('hu', 'Fal anyaga (5. falfelület)', 'en', 'Wall Material Type 4'), 'dropdown', false, 64,
         '["Tégla 38cm", "Tégla 50cm", "Mészhomok tégla", "B30 tégla", "Poroton", "Gázsilikát", "Vasbeton panel", "Vályog", "Könnyűszerkezetes"]'::jsonb,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_surface_thickness_4', jsonb_build_object('hu', 'Fal vastagsága (5. falfelület)', 'en', 'Wall Thickness 4'), 'number', false, 65, 15, 100, 'cm',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_area_ratio_4', jsonb_build_object('hu', 'Fal területi aránya (5. falfelület)', 'en', 'Wall Area Ratio 4'), 'number', false, 66, 1, 100, '%',
        jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_4', jsonb_build_object('hu', 'Hőszigetelés (5. falfelület)', 'en', 'Thermal Insulation 4'), 'switch', false, 67,
        jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_thickness_4', jsonb_build_object('hu', 'Hőszigetelés vastagsága (5. falfelület)', 'en', 'Thermal Insulation Thickness 4'), 'number', false, 68, 2, 30, 'cm',
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_4', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions, display_settings
    ) VALUES (
        page_building_physics_id, 'wall_thermal_insulation_type_4', jsonb_build_object('hu', 'Hőszigetelés típusa (5. falfelület)', 'en', 'Thermal Insulation Type 4'), 'dropdown', false, 69,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS"]'::jsonb,
        jsonb_build_object(
            'operator', 'and',
            'conditions', jsonb_build_array(
                jsonb_build_object('field', 'external_wall_types_count', 'value', 5, 'operator', 'greater_or_equal'),
                jsonb_build_object('field', 'wall_thermal_insulation_4', 'value', 'true', 'operator', 'equals')
            )
        ), jsonb_build_object('width', '1/2')
    );

    -- ========================================================================
    -- Nyílászárók (70) - repeatable_row type
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        sequence,
        display_settings
    ) VALUES (
        page_building_physics_id,
        'windows_doors',
        jsonb_build_object(
            'hu', 'Nyílászárók',
            'en', 'Windows and Doors'
        ),
        'repeatable_row',
        false,
        jsonb_build_object(
            'add_button_text', jsonb_build_object(
                'hu', 'Nyílászáró hozzáadása',
                'en', 'Add Window/Door'
            ),
            'fields', jsonb_build_array(
                -- Méret (Size) - dropdown - 1/2 width
                jsonb_build_object(
                    'name', 'size',
                    'label', jsonb_build_object(
                        'hu', 'Méret',
                        'en', 'Size'
                    ),
                    'type', 'dropdown',
                    'options', jsonb_build_array(
                        jsonb_build_object(
                            'value', 'Kisablak (90 cm × 90 cm-nél kisebb)',
                            'label', jsonb_build_object('hu', 'Kisablak (90 cm × 90 cm-nél kisebb)', 'en', 'Small window (smaller than 90 cm × 90 cm)')
                        ),
                        jsonb_build_object(
                            'value', 'Átlagos ablak (90-150 cm × 90-150 cm közötti)',
                            'label', jsonb_build_object('hu', 'Átlagos ablak (90-150 cm × 90-150 cm közötti)', 'en', 'Average window (90-150 cm × 90-150 cm)')
                        ),
                        jsonb_build_object(
                            'value', 'Nagyablak (150 cm × 150 cm-nél nagyobb)',
                            'label', jsonb_build_object('hu', 'Nagyablak (150 cm × 150 cm-nél nagyobb)', 'en', 'Large window (larger than 150 cm × 150 cm)')
                        ),
                        jsonb_build_object(
                            'value', 'Bejárati ajtó',
                            'label', jsonb_build_object('hu', 'Bejárati ajtó', 'en', 'Entrance door')
                        ),
                        jsonb_build_object(
                            'value', 'Terasz/erkélyajtó (üvegezett)',
                            'label', jsonb_build_object('hu', 'Terasz/erkélyajtó (üvegezett)', 'en', 'Terrace/balcony door (glazed)')
                        )
                    ),
                    'grid_width', '1/2'
                ),
                -- Típus (Type) - dropdown - 1/2 width
                jsonb_build_object(
                    'name', 'type',
                    'label', jsonb_build_object(
                        'hu', 'Típus',
                        'en', 'Type'
                    ),
                    'type', 'dropdown',
                    'options', jsonb_build_array(
                        jsonb_build_object('value', 'Fa', 'label', jsonb_build_object('hu', 'Fa', 'en', 'Wood')),
                        jsonb_build_object('value', 'Műanyag', 'label', jsonb_build_object('hu', 'Műanyag', 'en', 'Plastic')),
                        jsonb_build_object('value', 'Fém', 'label', jsonb_build_object('hu', 'Fém', 'en', 'Metal'))
                    ),
                    'grid_width', '1/2'
                ),
                -- Üvegezés (Glazing) - dropdown - 1/2 width
                -- Last 2 options become readonly when Type is Műanyag or Fém
                jsonb_build_object(
                    'name', 'glazing',
                    'label', jsonb_build_object(
                        'hu', 'Üvegezés',
                        'en', 'Glazing'
                    ),
                    'type', 'dropdown',
                    'options', jsonb_build_array(
                        jsonb_build_object(
                            'value', '1 rétegű üvegezésű',
                            'label', jsonb_build_object('hu', '1 rétegű üvegezésű', 'en', '1 layer glazing')
                        ),
                        jsonb_build_object(
                            'value', '2 rétegű üvegezésű',
                            'label', jsonb_build_object('hu', '2 rétegű üvegezésű', 'en', '2 layer glazing')
                        ),
                        jsonb_build_object(
                            'value', '3 rétegű üvegezésű',
                            'label', jsonb_build_object('hu', '3 rétegű üvegezésű', 'en', '3 layer glazing')
                        ),
                        jsonb_build_object(
                            'value', '2 rétegű csavaros teschauer',
                            'label', jsonb_build_object('hu', '2 rétegű csavaros teschauer', 'en', '2 layer screw teschauer'),
                            'readonly_when', jsonb_build_object(
                                'field', 'type',
                                'values', jsonb_build_array('Műanyag', 'Fém'),
                                'operator', 'in'
                            )
                        ),
                        jsonb_build_object(
                            'value', '2 rétegű kapcsolt gerébtokos',
                            'label', jsonb_build_object('hu', '2 rétegű kapcsolt gerébtokos', 'en', '2 layer coupled box frame'),
                            'readonly_when', jsonb_build_object(
                                'field', 'type',
                                'values', jsonb_build_array('Műanyag', 'Fém'),
                                'operator', 'in'
                            )
                        )
                    ),
                    'grid_width', '1/2'
                ),
                -- Mennyiség (Quantity) - number - calc(1/2 - 100px)
                jsonb_build_object(
                    'name', 'quantity',
                    'label', jsonb_build_object(
                        'hu', 'Mennyiség',
                        'en', 'Quantity'
                    ),
                    'type', 'number',
                    'min', 1,
                    'max', 100,
                    'unit', jsonb_build_object('hu', 'db', 'en', 'pcs'),
                    'grid_width', 'calc(1/2 - 100px)'
                )
            ),
            'button_width', '100px'
        ),
        70,
        jsonb_build_object('width', 'full')
    );

    -- ========================================================================
    -- Roof questions (80-87)
    -- ========================================================================

    -- Zárófödém típusa (icon_selector)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options_translations
    ) VALUES (
        page_building_physics_id,
        'roof_type',
        jsonb_build_object('hu', 'Zárófödém típusa', 'en', 'Roof Type'),
        'icon_selector',
        true,
        80,
        jsonb_build_array(
            jsonb_build_object(
                'value', 'Sátortető',
                'label', jsonb_build_object('hu', 'Sátortető', 'en', 'Hip Roof'),
                'icon', 'i-lucide-pyramid'
            ),
            jsonb_build_object(
                'value', 'Lapostető',
                'label', jsonb_build_object('hu', 'Lapostető', 'en', 'Flat Roof'),
                'icon', 'i-lucide-minus'
            ),
            jsonb_build_object(
                'value', 'Nyeregtető',
                'label', jsonb_build_object('hu', 'Nyeregtető', 'en', 'Gable Roof'),
                'icon', 'i-lucide-triangle'
            )
        )
    );

    -- Tető alapterülete
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_building_physics_id, 'roof_average_size', jsonb_build_object('hu', 'Tető alapterülete (m2)', 'en', 'Roof Area (m2)'), 'number', true, 81, 1, 1000, 'm²'
    );

    -- Gerincmagasság (csak "Nyeregtető" esetén jelenik meg)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions
    ) VALUES (
        page_building_physics_id, 'ridge_height', jsonb_build_object('hu', 'Gerincmagasság (cm)', 'en', 'Ridge Height (cm)'), 'number', false, 82, 1, 1000, 'cm',
        jsonb_build_object('field', 'roof_type', 'value', 'Nyeregtető', 'operator', 'equals')
    );

    -- Tető típusa (anyag)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options
    ) VALUES (
        page_building_physics_id,
        'roof_types',
        jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Material'),
        'dropdown',
        true,
        83,
        '["Cserép", "Pala", "Bitumenes lemez"]'::jsonb
    );

    -- Beépített? (csak "Sátortető" vagy "Nyeregtető" esetén jelenik meg)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_conditions
    ) VALUES (
        page_building_physics_id, 'tent_roof_built_in', jsonb_build_object('hu', 'Beépített?', 'en', 'Built-in?'), 'switch', false, 84,
        jsonb_build_object('field', 'roof_type', 'value', jsonb_build_array('Sátortető', 'Nyeregtető'), 'operator', 'in')
    );

    -- Hőszigetelés (switch)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_building_physics_id, 'roof_thermal_insulation', jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation'), 'switch', false, 85
    );

    -- Zárófödém hőszigetelés vastagsága (csak akkor jelenik meg, ha roof_thermal_insulation = true)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit, display_conditions
    ) VALUES (
        page_building_physics_id, 'roof_insulation_thickness', jsonb_build_object('hu', 'Zárófödém hőszigetelés vastagsága (cm)', 'en', 'Roof Insulation Thickness (cm)'), 'number', false, 86, 2, 30, 'cm',
        jsonb_build_object('field', 'roof_thermal_insulation', 'value', 'true', 'operator', 'equals')
    );

    -- Zárófödém hőszigetelés típusa (csak akkor jelenik meg, ha roof_thermal_insulation = true)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options, display_conditions
    ) VALUES (
        page_building_physics_id,
        'roof_insulation_type',
        jsonb_build_object('hu', 'Zárófödém hőszigetelés típusa', 'en', 'Roof Insulation Type'),
        'dropdown',
        false,
        87,
        '["EPS", "XPS", "Ásványgyapot", "Grafitos EPS", "PIR"]'::jsonb,
        jsonb_build_object('field', 'roof_thermal_insulation', 'value', 'true', 'operator', 'equals')
    );

    -- Van-e a homlokzati falon (címkérdés) (99)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES (
        page_building_physics_id,
        'facade_elements_title',
        jsonb_build_object('hu', 'Van-e a homlokzati falon:', 'en', 'Are there on the facade wall:'),
        'title',
        false,
        99,
        jsonb_build_object('width', 'full')
    );

    -- Homlokzati falon található elemek (100-103) - 1/4 szélesség
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES
        (page_building_physics_id, 'has_electric_meter', jsonb_build_object('hu', 'Villanyóra?', 'en', 'Electric Meter?'), 'switch', false, 100, jsonb_build_object('width', '1/4')),
        (page_building_physics_id, 'has_gas_meter', jsonb_build_object('hu', 'Gázóra?', 'en', 'Gas Meter?'), 'switch', false, 101, jsonb_build_object('width', '1/4')),
        (page_building_physics_id, 'has_outdoor_air_conditioner', jsonb_build_object('hu', 'Kültéri klíma?', 'en', 'Outdoor AC?'), 'switch', false, 102, jsonb_build_object('width', '1/4')),
        (page_building_physics_id, 'has_gas_pipe', jsonb_build_object('hu', 'Gázcső?', 'en', 'Gas Pipe?'), 'switch', false, 103, jsonb_build_object('width', '1/4'));

    -- Van-e olyan oldala a háznak... (104)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES (
        page_building_physics_id,
        'has_high_eaves_side',
        jsonb_build_object(
            'hu', 'Van-e olyan oldala a háznak ahol 3,5 méternél magasabban van az eresz az oldal több mint 20%-nál?',
            'en', 'Does the house have a side where the eaves are higher than 3.5 meters on more than 20% of that side?'
        ),
        'switch',
        false,
        104,
        jsonb_build_object('width', 'full')
    );

    -- Állványozás szükséges? (105)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, display_settings
    ) VALUES (
        page_building_physics_id,
        'wall_insulation_with_scaffold',
        jsonb_build_object('hu', 'Állványozás szükséges?', 'en', 'Scaffolding Required?'),
        'switch',
        false,
        105,
        jsonb_build_object('width', 'full')
    );

    -- Mivel fűt? (többet is kiválaszthat) (106)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options_translations, display_settings
    ) VALUES (
        page_building_physics_id,
        'heating_method',
        jsonb_build_object('hu', 'Mivel fűt? (többet is kiválaszthat)', 'en', 'How does it heat? (you can select multiple)'),
        'multiselect',
        false,
        106,
        jsonb_build_array(
            -- Gázfűtés kategória
            jsonb_build_object(
                'value', '__category_gas__',
                'label', jsonb_build_object('hu', 'Gázfűtés', 'en', 'Gas Heating'),
                'readonly', true
            ),
            jsonb_build_object('value', 'Állandó hőmérsékletű kazán', 'label', jsonb_build_object('hu', 'Állandó hőmérsékletű kazán', 'en', 'Constant temperature boiler')),
            jsonb_build_object('value', 'Alacsony hőmérsékletű kazán', 'label', jsonb_build_object('hu', 'Alacsony hőmérsékletű kazán', 'en', 'Low temperature boiler')),
            jsonb_build_object('value', 'Kondenzációs kazán', 'label', jsonb_build_object('hu', 'Kondenzációs kazán', 'en', 'Condensing boiler')),
            jsonb_build_object('value', 'Hagyományos gázkonvektor', 'label', jsonb_build_object('hu', 'Hagyományos gázkonvektor', 'en', 'Traditional gas convector')),
            jsonb_build_object('value', 'Nyílt égésterű gázkonvektor', 'label', jsonb_build_object('hu', 'Nyílt égésterű gázkonvektor', 'en', 'Open combustion chamber gas convector')),
            jsonb_build_object('value', 'Külső fali gázkonvektor', 'label', jsonb_build_object('hu', 'Külső fali gázkonvektor', 'en', 'Outdoor wall gas convector')),
            -- Elektromos fűtés kategória
            jsonb_build_object(
                'value', '__category_electric__',
                'label', jsonb_build_object('hu', 'Elektromos fűtés', 'en', 'Electric Heating'),
                'readonly', true
            ),
            jsonb_build_object('value', 'Elektromos radiátor', 'label', jsonb_build_object('hu', 'Elektromos radiátor', 'en', 'Electric radiator')),
            jsonb_build_object('value', 'Elektromos kazán', 'label', jsonb_build_object('hu', 'Elektromos kazán', 'en', 'Electric boiler')),
            jsonb_build_object('value', 'Vezérelt éjszakai tárolós fűtés', 'label', jsonb_build_object('hu', 'Vezérelt éjszakai tárolós fűtés', 'en', 'Controlled night storage heating')),
            jsonb_build_object('value', 'Nappali tárolós fűtés', 'label', jsonb_build_object('hu', 'Nappali tárolós fűtés', 'en', 'Day storage heating')),
            -- Biomassza alapú fűtés kategória
            jsonb_build_object(
                'value', '__category_biomass__',
                'label', jsonb_build_object('hu', 'Biomassza alapú fűtés', 'en', 'Biomass-based Heating'),
                'readonly', true
            ),
            jsonb_build_object('value', 'Cserépkályha (fa)', 'label', jsonb_build_object('hu', 'Cserépkályha (fa)', 'en', 'Tile stove (wood)')),
            jsonb_build_object('value', 'Zárt égésterű kandalló', 'label', jsonb_build_object('hu', 'Zárt égésterű kandalló', 'en', 'Closed combustion chamber fireplace')),
            jsonb_build_object('value', 'Egyedi kályházás fűtés', 'label', jsonb_build_object('hu', 'Egyedi kályházás fűtés', 'en', 'Individual stove heating')),
            jsonb_build_object('value', 'Nyílt égésterű kandalló', 'label', jsonb_build_object('hu', 'Nyílt égésterű kandalló', 'en', 'Open combustion chamber fireplace')),
            jsonb_build_object('value', 'Vegyes tüzelésű kazán', 'label', jsonb_build_object('hu', 'Vegyes tüzelésű kazán', 'en', 'Mixed fuel boiler')),
            jsonb_build_object('value', 'Hasábfás kazán', 'label', jsonb_build_object('hu', 'Hasábfás kazán', 'en', 'Log wood boiler')),
            jsonb_build_object('value', 'Pellet kazán', 'label', jsonb_build_object('hu', 'Pellet kazán', 'en', 'Pellet boiler')),
            jsonb_build_object('value', 'Faelgázosító kazán', 'label', jsonb_build_object('hu', 'Faelgázosító kazán', 'en', 'Wood gasification boiler')),
            -- Távfűtés kategória
            jsonb_build_object(
                'value', '__category_district__',
                'label', jsonb_build_object('hu', 'Távfűtés', 'en', 'District Heating'),
                'readonly', true
            ),
            jsonb_build_object('value', 'Távfűtés', 'label', jsonb_build_object('hu', 'Távfűtés', 'en', 'District heating'))
        ),
        jsonb_build_object('width', 'full')
    );

    -- HMV készítés módja
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options
    ) VALUES (
        page_building_physics_id,
        'hot_water_preparation_method',
        jsonb_build_object('hu', 'HMV készítés módja', 'en', 'Hot Water Preparation Method'),
        'dropdown',
        true,
        110,
        '["Gázkazán", "Villanybojler", "Napkollektor", "Hőszivattyú", "Egyéb"]'::jsonb
    );

    RAISE NOTICE 'Created % questions for Page 1: Épületfizikai adatok',
        (SELECT COUNT(*) FROM public.survey_questions WHERE survey_page_id = page_building_physics_id);

    -- ========================================================================
    -- STEP 4: PAGE 2 - Energiafelhasználási adatok
    -- ========================================================================

    -- Ingatlanprofil kiválasztása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options_translations
    ) VALUES (
        page_energy_consumption_id,
        'energy_consumption_profile',
        jsonb_build_object('hu', 'Ingatlanprofil kiválasztása', 'en', 'Property Profile Selection'),
        'icon_selector',
        true,
        1,
        jsonb_build_array(
            jsonb_build_object(
                'value', 'Kádár kocka - Egyedi fűtéses',
                'label', jsonb_build_object('hu', 'Kádár kocka - Egyedi fűtéses', 'en', 'Kádár cube - Individual heating'),
                'icon', 'i-lucide-home'
            ),
            jsonb_build_object(
                'value', 'Toldott Kádár kocka - Központi fűtéses',
                'label', jsonb_build_object('hu', 'Toldott Kádár kocka - Központi fűtéses', 'en', 'Extended Kádár cube - Central heating'),
                'icon', 'i-lucide-warehouse'
            ),
            jsonb_build_object(
                'value', 'Toldott Kádár kocka - Központi fűtéses + HMV',
                'label', jsonb_build_object('hu', 'Toldott Kádár kocka - Központi fűtéses + HMV', 'en', 'Extended Kádár cube - Central heating + DHW'),
                'icon', 'i-lucide-building'
            ),
            jsonb_build_object(
                'value', 'Pincés + beépített tetős - Központi fűtéses + HMV',
                'label', jsonb_build_object('hu', 'Pincés + beépített tetős - Központi fűtéses + HMV', 'en', 'With basement + built-in roof - Central heating + DHW'),
                'icon', 'i-lucide-building-2'
            )
        )
    );

    -- Energiahordozó típusok
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options
    ) VALUES (
        page_energy_consumption_id,
        'energy_consumption_select',
        jsonb_build_object('hu', 'Energiahordozó típusok', 'en', 'Energy Carrier Types'),
        'multiselect',
        true,
        2,
        '["Villamos energia", "Földgáz", "PB gáz", "Tűzifa, vegyes tüzelő", "Szén", "Napkollektorok éves hőtermelése"]'::jsonb
    );

    -- Energiafogyasztás adatok
    INSERT INTO public.survey_questions (
        survey_page_id, name, type, is_required, sequence, min, max, unit
    ) VALUES
        (page_energy_consumption_id, 'energy_consumption_electricity', 'number', false, 10, 0, 150000, 'kWh/év'),
        (page_energy_consumption_id, 'energy_consumption_natural_gas', 'number', false, 11, 0, 100000, 'm³/év'),
        (page_energy_consumption_id, 'energy_consumption_district_heating', 'number', false, 12, 10, 20000, 'MJ/év'),
        (page_energy_consumption_id, 'energy_consumption_firewood', 'number', false, 13, 10, 20000, 'kg/év'),
        (page_energy_consumption_id, 'energy_consumption_coal', 'number', false, 14, 10, 20000, 'kg/év'),
        (page_energy_consumption_id, 'energy_consumption_solar_collector', 'number', false, 15, 10, 50000, 'kWh/év'),
        (page_energy_consumption_id, 'energy_consumption_lpg', 'number', false, 16, 10, 20000, 'kg/év');

    -- Fűtőkészülék típusok
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, options
    ) VALUES (
        page_energy_consumption_id,
        'heating_type_select',
        jsonb_build_object('hu', 'Fűtő készülékek', 'en', 'Heating Devices'),
        'multiselect',
        false,
        20,
        '["Gáz", "Villany", "Tűzifa", "Szén", "Pellet", "Hőszivattyú"]'::jsonb
    );

    -- Fűtési hőleadók
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES
        (page_energy_consumption_id, 'heat_emitter_radiator', jsonb_build_object('hu', 'Fűtési hőleadók típusa', 'en', 'Heat Emitter Types'), 'number', false, 30, 1, 30, 'db'),
        (page_energy_consumption_id, 'heat_emitter_underfloor_heating', 'number', false, 31, 10, 300, 'm²'),
        (page_energy_consumption_id, 'heat_emitter_wall_heating', 'number', false, 32, 10, 300, 'm²'),
        (page_energy_consumption_id, 'heat_emitter_ceiling_heating', 'number', false, 33, 10, 300, 'm²'),
        (page_energy_consumption_id, 'heat_emitter_convector', 'number', false, 34, 1, 30, 'db'),
        (page_energy_consumption_id, 'heat_emitter_fan_coil', 'number', false, 35, 1, 30, 'db');

    -- Megújuló energia
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES
        (page_energy_consumption_id, 'renewable_solar_panel', jsonb_build_object('hu', 'Megújulóenergia alapú energiatermelés', 'en', 'Renewable Energy Production'), 'number', false, 40, 10, 20000, 'kWh/év'),
        (page_energy_consumption_id, 'renewable_solar_collector', 'number', false, 41, 10, 5000, 'm²'),
        (page_energy_consumption_id, 'renewable_wind_turbine', 'number', false, 42, 10, 5000, 'kWh/év');

    -- Klíma készülékek
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES
        (page_energy_consumption_id, 'air_conditioner_split', jsonb_build_object('hu', 'Klíma készülékek', 'en', 'Air Conditioning Devices'), 'number', false, 50, 1, 10, 'db'),
        (page_energy_consumption_id, 'air_conditioner_multi_split', 'number', false, 51, 1, 10, 'db'),
        (page_energy_consumption_id, 'air_conditioner_heat_pump', 'number', false, 52, 1, 50, 'kW');

    RAISE NOTICE 'Created % questions for Page 2: Energiafelhasználási adatok',
        (SELECT COUNT(*) FROM public.survey_questions WHERE survey_page_id = page_energy_consumption_id);

    -- ========================================================================
    -- STEP 5: PAGE 3 - Egyéb információk
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES
        (page_other_info_id, 'mothers_name', jsonb_build_object('hu', 'Anyja neve', 'en', 'Mother''s Name'), 'text', false, 1),
        (page_other_info_id, 'birth_date', jsonb_build_object('hu', 'Születési dátum', 'en', 'Birth Date'), 'text', false, 2),
        (page_other_info_id, 'birth_place', jsonb_build_object('hu', 'Születési hely', 'en', 'Birth Place'), 'text', false, 3),
        (page_other_info_id, 'birth_name', jsonb_build_object('hu', 'Születési név', 'en', 'Birth Name'), 'text', false, 4),
        (page_other_info_id, 'parcel_number', jsonb_build_object('hu', 'Helyrajzi szám', 'en', 'Parcel Number'), 'text', false, 5),
        (page_other_info_id, 'planned_investment', jsonb_build_object('hu', 'Tervezett beruházás', 'en', 'Planned Investment'), 'text', false, 6),
        (page_other_info_id, 'is_residential_building', jsonb_build_object('hu', 'Lakóépület', 'en', 'Residential Building'), 'switch', false, 7),
        (page_other_info_id, 'add_subsidy', jsonb_build_object('hu', 'Támogatás hozzáadása', 'en', 'Add Subsidy'), 'switch', false, 8);

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, unit
    ) VALUES (
        page_other_info_id, 'average_monthly_gross_income', jsonb_build_object('hu', 'Átlagos havi bruttó jövedelem', 'en', 'Average Monthly Gross Income'), 'number', false, 9, 'Ft'
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence, min, max, unit
    ) VALUES (
        page_other_info_id, 'number_residents', jsonb_build_object('hu', 'Lakók száma', 'en', 'Number of Residents'), 'number', false, 10, 1, 20, 'fő'
    );

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES
        (page_other_info_id, 'other_informations', jsonb_build_object('hu', 'Egyéb megjegyzések a használatra vonatkozóan', 'en', 'Other Notes on Usage'), 'textarea', false, 11),
        (page_other_info_id, 'any_questions', jsonb_build_object('hu', 'Kérdések, amit a tanácsadónak feltenne', 'en', 'Questions for the Consultant'), 'textarea', false, 12);

    RAISE NOTICE 'Created % questions for Page 3: Egyéb információk',
        (SELECT COUNT(*) FROM public.survey_questions WHERE survey_page_id = page_other_info_id);

    -- ========================================================================
    -- FINAL SUMMARY
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Consultant Mode Investment Created Successfully!';
    RAISE NOTICE 'Investment ID: %', inv_consultant_id;
    RAISE NOTICE 'Total Pages: 3';
    RAISE NOTICE 'Total Questions: %',
        (SELECT COUNT(*) FROM public.survey_questions sq
         JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
         WHERE sp.investment_id = inv_consultant_id);
    RAISE NOTICE '========================================';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
