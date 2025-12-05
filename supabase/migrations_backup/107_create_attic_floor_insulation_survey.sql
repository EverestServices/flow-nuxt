-- ============================================================================
-- Migration: Create Attic Floor Insulation Survey Pages and Questions
-- Description: Creates survey pages and questions for Padlásfödém szigetelés
--              (Attic Floor Insulation) investment
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
    page_site_conditions_id UUID;
    page_defects_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Get the Attic Floor Insulation investment ID
    -- ========================================================================

    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Attic Floor Insulation investment not found (persist_name: roofInsulation)';
    END IF;

    RAISE NOTICE 'Found Attic Floor Insulation investment with ID: %', inv_attic_floor_id;

    -- ========================================================================
    -- STEP 2: Create Survey Page 1 - Tetőtér adatai (Attic Data)
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
        inv_attic_floor_id,
        'Tetőtér adatai',
        jsonb_build_object('hu', 'Tetőtér adatai', 'en', 'Attic Data'),
        'attic_data',
        '{"top": 100, "right": 100}'::jsonb,
        false,
        false,
        1
    )
    RETURNING id INTO page_attic_data_id;

    RAISE NOTICE 'Created survey page: Tetőtér adatai (ID: %)', page_attic_data_id;

    -- ========================================================================
    -- STEP 3: Create Questions for Tetőtér adatai
    -- ========================================================================

    -- 1. Tetőtér típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_attic_data_id,
        'attic_type',
        jsonb_build_object('hu', 'Tetőtér típusa', 'en', 'Attic Type'),
        'dropdown',
        true,
        jsonb_build_array('Beépítetlen', 'Beépített'),
        1
    );

    -- 2. Padlásfödém szerkezete
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_attic_data_id,
        'attic_floor_structure',
        jsonb_build_object('hu', 'Padlásfödém szerkezete', 'en', 'Attic Floor Structure'),
        'dropdown',
        true,
        jsonb_build_array('Nem járható álmennyezet', 'Fafödém', 'Szilárd födém'),
        2,
        jsonb_build_object(
            'hu', 'Nem járható álmennyezet: legfelső vízszintes határoló szerkezet, a fedélszékről függesztett gipszkarton, vagy OSB álmennyezet\nFafödém: borított gerendás (fagerendák ~90 cm-es osztással, felső- vagy kétoldali deszkaterítéssel) vagy csapos gerendafödém (egymás mellé sorolt fagerendák)\nSzilárd födém: ide tartozik minden vasbeton vagy acélgerendás és béléselemes födém, vasbeton pallós, vagy monolit vasbeton födém',
            'en', 'Non-walkable suspended ceiling: uppermost horizontal boundary structure, gypsum board or OSB suspended ceiling from the roof structure\nWooden floor: covered beam (wooden beams with ~90 cm spacing, with upper or double-sided boarding) or pegged beam floor (wooden beams placed next to each other)\nSolid floor: includes all reinforced concrete or steel beam and panel floors, reinforced concrete slab or monolithic reinforced concrete floors'
        )
    );

    -- 3. Padlásfödém legfelső rétege
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_attic_data_id,
        'attic_floor_top_layer',
        jsonb_build_object('hu', 'Padlásfödém legfelső rétege', 'en', 'Attic Floor Top Layer'),
        'dropdown',
        true,
        jsonb_build_array('Agyag/sár tapasztás', 'Salak feltöltés', 'Deszkázat/OSB', 'Beton/burkolat'),
        3
    );

    -- 4. Padlásfödém fűtött tér feletti felülete (Title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence
    ) VALUES (
        page_attic_data_id,
        'heated_space_surface_title',
        jsonb_build_object('hu', 'Padlásfödém fűtött tér feletti felülete', 'en', 'Attic Floor Surface Above Heated Space'),
        'title',
        false,
        4
    );

    -- 5. Szélesség (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_attic_data_id,
        'width',
        jsonb_build_object('hu', 'Szélesség (m)', 'en', 'Width (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        5
    );

    -- 6. Hosszúság (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_attic_data_id,
        'length',
        jsonb_build_object('hu', 'Hosszúság (m)', 'en', 'Length (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        6
    );

    -- 7. Legkisebb belmagasság (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, info_message_translations
    ) VALUES (
        page_attic_data_id,
        'min_height',
        jsonb_build_object('hu', 'Legkisebb belmagasság (m)', 'en', 'Minimum Interior Height (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        7,
        jsonb_build_object(
            'hu', 'Lehet 0 m is, amennyiben a tetőszerkezet a zárófödémen áll',
            'en', 'Can be 0 m if the roof structure stands on the closing ceiling'
        )
    );

    -- 8. Legnagyobb belmagasság (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, info_message_translations
    ) VALUES (
        page_attic_data_id,
        'max_height',
        jsonb_build_object('hu', 'Legnagyobb belmagasság (m)', 'en', 'Maximum Interior Height (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        8,
        jsonb_build_object(
            'hu', 'Általában gerincszelemen alatt mérhető',
            'en', 'Usually measured under the ridge beam'
        )
    );

    -- 9. Padlástér tervezett hasznosítása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_attic_data_id,
        'planned_usage',
        jsonb_build_object('hu', 'Padlástér tervezett hasznosítása', 'en', 'Planned Attic Usage'),
        'dropdown',
        true,
        jsonb_build_array('Üres, nem járható', 'Tárolásra használt, járható'),
        9
    );

    -- 10. Tervezett hőszigetelés típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_attic_data_id,
        'planned_insulation_type',
        jsonb_build_object('hu', 'Tervezett hőszigetelés típusa', 'en', 'Planned Insulation Type'),
        'dropdown',
        true,
        jsonb_build_array('Kőzetgyapot (10+15 cm)', 'Üveggyapot (10+15 cm)', 'Padlap + EPS (16+5 cm)'),
        10
    );

    -- ========================================================================
    -- STEP 4: Create Survey Page 2 - Munkaterület adottságai (Site Conditions)
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
        inv_attic_floor_id,
        'Munkaterület adottságai',
        jsonb_build_object('hu', 'Munkaterület adottságai', 'en', 'Site Conditions'),
        'site_conditions',
        '{"top": 200, "right": 100}'::jsonb,
        false,
        false,
        2
    )
    RETURNING id INTO page_site_conditions_id;

    RAISE NOTICE 'Created survey page: Munkaterület adottságai (ID: %)', page_site_conditions_id;

    -- ========================================================================
    -- STEP 5: Create Questions for Munkaterület adottságai
    -- ========================================================================

    -- 1. Feljárás
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_site_conditions_id,
        'access_route',
        jsonb_build_object('hu', 'Feljárás', 'en', 'Access Route'),
        'dropdown',
        true,
        jsonb_build_array('Épületen belül', 'Épületen kívül'),
        1
    );

    -- 2. Feljáró tiszta nyílásmérete (cm×cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence
    ) VALUES (
        page_site_conditions_id,
        'access_opening_size',
        jsonb_build_object('hu', 'Feljáró tiszta nyílásmérete (cm×cm)', 'en', 'Access Opening Clear Size (cm×cm)'),
        'text',
        true,
        2
    );

    -- 3. Padlás felülete
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_site_conditions_id,
        'attic_surface',
        jsonb_build_object('hu', 'Padlás felülete', 'en', 'Attic Surface'),
        'dropdown',
        true,
        jsonb_build_array('Sík', 'Tagolt'),
        3
    );

    -- 4. Kémények száma (db)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_site_conditions_id,
        'chimney_count',
        jsonb_build_object('hu', 'Kémények száma (db)', 'en', 'Number of Chimneys (pcs)'),
        'number',
        true,
        'db',
        jsonb_build_object('hu', 'db', 'en', 'pcs'),
        4
    );

    -- ========================================================================
    -- STEP 6: Create Survey Page 3 - Hibák hozzáadása (Add Defects)
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
        inv_attic_floor_id,
        'Hibák hozzáadása',
        jsonb_build_object('hu', 'Hibák hozzáadása', 'en', 'Add Defects'),
        'defects',
        '{"top": 300, "right": 100}'::jsonb,
        false,
        false,
        3
    )
    RETURNING id INTO page_defects_id;

    RAISE NOTICE 'Created survey page: Hibák hozzáadása (ID: %)', page_defects_id;

    -- ========================================================================
    -- STEP 7: Create Questions for Hibák hozzáadása
    -- ========================================================================

    -- 1. Madarak kártétele
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_defects_id,
        'bird_damage',
        jsonb_build_object('hu', 'Madarak kártétele', 'en', 'Bird Damage'),
        'switch',
        true,
        'false',
        1
    );

    -- 2. Darázsfészek
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_defects_id,
        'wasp_nest',
        jsonb_build_object('hu', 'Darázsfészek', 'en', 'Wasp Nest'),
        'switch',
        true,
        'false',
        2
    );

    -- 3. Statikai kár
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_defects_id,
        'structural_damage',
        jsonb_build_object('hu', 'Statikai kár', 'en', 'Structural Damage'),
        'switch',
        true,
        'false',
        3
    );

    -- 4. Beázás
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_defects_id,
        'water_leak',
        jsonb_build_object('hu', 'Beázás', 'en', 'Water Leak'),
        'switch',
        true,
        'false',
        4
    );

    -- ========================================================================
    -- STEP 8: Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully created Attic Floor Insulation survey structure';
    RAISE NOTICE 'Created 3 survey pages:';
    RAISE NOTICE '  1. Tetőtér adatai (10 questions)';
    RAISE NOTICE '  2. Munkaterület adottságai (4 questions)';
    RAISE NOTICE '  3. Hibák hozzáadása (4 questions)';
    RAISE NOTICE 'Total: 18 questions';
    RAISE NOTICE '========================================';

END $$;
