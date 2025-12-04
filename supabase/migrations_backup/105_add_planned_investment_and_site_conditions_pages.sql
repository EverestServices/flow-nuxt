-- ============================================================================
-- Migration: Add Planned Investment and Site Conditions Pages
-- Description: Creates two new survey pages for Facade Insulation:
--              - Tervezett beruházás (Planned Investment)
--              - Munkaterület adottságai (Site Conditions)
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_planned_investment_id UUID;
    page_site_conditions_id UUID;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Create "Tervezett beruházás" Survey Page
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_facade_id,
        'Tervezett beruházás',
        jsonb_build_object('hu', 'Tervezett beruházás', 'en', 'Planned Investment'),
        'planned_investment',
        '{"top": 300, "right": 100}'::jsonb,
        false,
        false,
        3
    )
    RETURNING id INTO page_planned_investment_id;

    -- ========================================================================
    -- STEP 2: Create Survey Questions for "Tervezett beruházás" Page
    -- ========================================================================

    -- 1. Homlokzat hőszigetelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_planned_investment_id,
        'facade_insulation',
        jsonb_build_object('hu', 'Homlokzat hőszigetelése', 'en', 'Facade Insulation'),
        'switch',
        true,
        'false',
        1
    );

    -- 2. Lábazat hőszigetelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_planned_investment_id,
        'foundation_insulation',
        jsonb_build_object('hu', 'Lábazat hőszigetelése', 'en', 'Foundation Insulation'),
        'switch',
        true,
        'false',
        2
    );

    -- 3. Színezés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_planned_investment_id,
        'coloring',
        jsonb_build_object('hu', 'Színezés', 'en', 'Coloring'),
        'switch',
        true,
        'false',
        3
    );

    -- 4. Struktúra (conditional on coloring)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_planned_investment_id,
        'structure',
        jsonb_build_object('hu', 'Struktúra', 'en', 'Structure'),
        'dropdown',
        false,
        jsonb_build_array('Dörzsölt', 'Kapart'),
        4,
        jsonb_build_object(
            'field', 'coloring',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 5. Színcsoport (conditional on coloring)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_planned_investment_id,
        'color_group',
        jsonb_build_object('hu', 'Színcsoport', 'en', 'Color Group'),
        'dropdown',
        false,
        jsonb_build_array('1', '2', '3'),
        5,
        jsonb_build_object(
            'field', 'coloring',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 6. Színkód (conditional on coloring)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence, display_conditions
    ) VALUES (
        page_planned_investment_id,
        'color_code',
        jsonb_build_object('hu', 'Színkód', 'en', 'Color Code'),
        'text',
        false,
        6,
        jsonb_build_object(
            'field', 'coloring',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- ========================================================================
    -- STEP 3: Create "Munkaterület adottságai" Survey Page
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_facade_id,
        'Munkaterület adottságai',
        jsonb_build_object('hu', 'Munkaterület adottságai', 'en', 'Site Conditions'),
        'site_conditions',
        '{"top": 400, "right": 100}'::jsonb,
        false,
        false,
        4
    )
    RETURNING id INTO page_site_conditions_id;

    -- ========================================================================
    -- STEP 4: Create Survey Questions for "Munkaterület adottságai" Page
    -- ========================================================================

    -- 1. Homlokzatok állványozhatók
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_site_conditions_id,
        'facades_scaffoldable',
        jsonb_build_object('hu', 'Homlokzatok állványozhatók', 'en', 'Facades Can Be Scaffolded'),
        'switch',
        true,
        'false',
        1,
        jsonb_build_object(
            'hu', 'Van elegendő hely a homlokzat mellett ~0,9-1,0 m szabad távolság ahol a homlokzati csőállvány felállítható. Lejtős terepviszonyok nem okoznak problémát',
            'en', 'There is sufficient space next to the facade (~0.9-1.0 m clearance) where the facade pipe scaffold can be erected. Sloped terrain does not cause problems'
        )
    );

    -- 2. Konténer elhelyezése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_site_conditions_id,
        'container_placement',
        jsonb_build_object('hu', 'Konténer elhelyezése', 'en', 'Container Placement'),
        'dropdown',
        true,
        jsonb_build_array('Közterületen', 'Behajtón', 'Kerítésen belül'),
        2
    );

    -- 3. Ingatlan teherautóval megközelíthető
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_site_conditions_id,
        'truck_accessible',
        jsonb_build_object('hu', 'Ingatlan teherautóval megközelíthető', 'en', 'Property Accessible by Truck'),
        'switch',
        true,
        'false',
        3
    );

    -- 4. Építőanyag tárolás portán belül megoldható
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_site_conditions_id,
        'material_storage_on_site',
        jsonb_build_object('hu', 'Építőanyag tárolás portán belül megoldható', 'en', 'Building Material Storage Possible on Site'),
        'switch',
        true,
        'false',
        4
    );

    RAISE NOTICE 'Successfully created Planned Investment and Site Conditions survey pages and questions';

END $$;
