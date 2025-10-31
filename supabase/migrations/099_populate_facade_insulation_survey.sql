-- ============================================================================
-- Migration: Populate Facade Insulation Survey Pages and Questions
-- Description: Creates new survey pages and questions for Facade Insulation
--              investment with proper translations and dependencies
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    page_other_data_id UUID;

    -- Basic Data source question IDs
    source_wall_structure_id UUID;
    source_wall_structure_other_id UUID;
    source_wall_thickness_id UUID;
    source_foundation_type_id UUID;
    source_foundation_height_id UUID;
    source_protrusion_size_id UUID;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Basic Data source question IDs
    SELECT sq.id INTO source_wall_structure_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'exterior_wall_structure';

    SELECT sq.id INTO source_wall_structure_other_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'exterior_wall_structure_other';

    SELECT sq.id INTO source_wall_thickness_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'wall_thickness_uniform';

    SELECT sq.id INTO source_foundation_type_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'foundation_type_uniform';

    SELECT sq.id INTO source_foundation_height_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'foundation_height_uniform';

    SELECT sq.id INTO source_protrusion_size_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'protrusion_size_uniform';

    -- ========================================================================
    -- STEP 1: Create Survey Pages
    -- ========================================================================

    -- Page 1: Falak (Walls)
    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence,
        item_name_template,
        item_name_template_translations
    ) VALUES (
        inv_facade_id,
        'Falak',
        jsonb_build_object('hu', 'Falak', 'en', 'Walls'),
        'walls',
        '{"top": 100, "right": 100}'::jsonb,
        true,
        true,
        1,
        '{index}. falfelület',
        jsonb_build_object('hu', '{index}. falfelület', 'en', 'Wall {index}')
    )
    RETURNING id INTO page_walls_id;

    -- Page 2: Egyéb adatok (Other Data)
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
        'Egyéb adatok',
        jsonb_build_object('hu', 'Egyéb adatok', 'en', 'Other Data'),
        'other_data',
        '{"top": 200, "right": 100}'::jsonb,
        false,
        false,
        2
    )
    RETURNING id INTO page_other_data_id;

    -- ========================================================================
    -- STEP 2: Create Survey Questions for "Falak" Page
    -- ========================================================================

    -- 1. Tájolás
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_walls_id,
        'wall_orientation',
        jsonb_build_object('hu', 'Tájolás', 'en', 'Orientation'),
        'orientation_selector',
        true,
        1
    );

    -- 2. Fal szerkezete
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'wall_structure',
        jsonb_build_object('hu', 'Fal szerkezete', 'en', 'Wall Structure'),
        'dropdown',
        true,
        jsonb_build_array(
            'Vegyes',
            'Tömör tégla (kisméretű vagy nagyméretű)',
            'Mészhomok tégla',
            'Kevéslyukú tégla',
            'Soklyukú tégla',
            'Tégla falazóblokk (1950-1980-ig)',
            'Tégla falazóblokk (1980-1990-ig)',
            'Tégla falazóblokk (1990 után)',
            'Gázszilikát (1990 előtti pórusbeton)',
            'Ytong (1990 utáni pórusbeton)',
            'Vasbeton (monolit)',
            'Vasbeton panel',
            'Szalma',
            'Vályog',
            'Könnyűszerkezetes',
            'Egyéb'
        ),
        2,
        source_wall_structure_id,
        true
    );

    -- 3. Fal szerkezetének pontos típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence,
        display_conditions, default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'wall_structure_other',
        jsonb_build_object(
            'hu', 'Fal szerkezetének pontos típusa',
            'en', 'Exact Type of Wall Structure'
        ),
        'text',
        false,
        'Adja meg a fal szerkezet típusát',
        jsonb_build_object(
            'hu', 'Adja meg a fal szerkezet típusát',
            'en', 'Enter the wall structure type'
        ),
        3,
        jsonb_build_object(
            'field', 'wall_structure',
            'operator', 'equals',
            'value', 'Egyéb'
        ),
        source_wall_structure_other_id,
        true
    );

    -- 4. Fal vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'wall_thickness',
        jsonb_build_object('hu', 'Fal vastagsága (cm)', 'en', 'Wall Thickness (cm)'),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        4,
        source_wall_thickness_id,
        true
    );

    -- 5. Hossza (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_walls_id,
        'wall_length',
        jsonb_build_object('hu', 'Hossza (m)', 'en', 'Length (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        5
    );

    -- 6. Magassága (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, info_message_translations
    ) VALUES (
        page_walls_id,
        'wall_height',
        jsonb_build_object('hu', 'Magassága (m)', 'en', 'Height (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        6,
        jsonb_build_object(
            'hu', 'Csatlakozó járdától ereszaljig. Lejtős terepen legkisebb-, és legnagyobb mért magasság számtani közepe.',
            'en', 'From adjacent pavement to the eaves. On sloped terrain, the arithmetic mean of the smallest and largest measured heights.'
        )
    );

    -- 7. Lábazat magassága (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, info_message_translations,
        default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'foundation_height',
        jsonb_build_object('hu', 'Lábazat magassága (m)', 'en', 'Foundation Height (m)'),
        'number',
        true,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        7,
        jsonb_build_object(
            'hu', 'Csatlakozó járdától lábazat tetejéig. Lejtős terepen legkisebb-, és legnagyobb mért magasság számtani közepe.',
            'en', 'From adjacent pavement to the top of the foundation. On sloped terrain, the arithmetic mean of the smallest and largest measured heights.'
        ),
        source_foundation_height_id,
        true
    );

    -- 8. Lábazat típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations,
        default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'foundation_type',
        jsonb_build_object('hu', 'Lábazat típusa', 'en', 'Foundation Type'),
        'dropdown',
        true,
        jsonb_build_array('Pozitív', 'Negatív'),
        8,
        jsonb_build_object(
            'hu', 'Pozitív ha a homlokzati falsíktól kintebb áll, negatív ha mögötte van.',
            'en', 'Positive if it protrudes from the facade plane, negative if it is recessed.'
        ),
        source_foundation_type_id,
        true
    );

    -- 9. Ki/beugrás mérete (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, default_value_source_question_id, is_readonly
    ) VALUES (
        page_walls_id,
        'protrusion_size',
        jsonb_build_object(
            'hu', 'Ki/beugrás mérete (cm)',
            'en', 'Protrusion/Recess Size (cm)'
        ),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        9,
        source_protrusion_size_id,
        true
    );

    -- 10. Lábazat hőszigetelt
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_walls_id,
        'foundation_insulated',
        jsonb_build_object('hu', 'Lábazat hőszigetelt', 'en', 'Foundation Insulated'),
        'switch',
        true,
        'false',
        10
    );

    -- 11. Meglévő hőszigetelés anyaga
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_walls_id,
        'existing_insulation_material',
        jsonb_build_object(
            'hu', 'Meglévő hőszigetelés anyaga',
            'en', 'Existing Insulation Material'
        ),
        'dropdown',
        false,
        jsonb_build_array('XPS', 'Hőszigetelő vakolat', 'Ytong Multipor', 'Egyéb'),
        11,
        jsonb_build_object(
            'field', 'foundation_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 12. Meglévő hőszigetelés anyagának pontos típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence, display_conditions
    ) VALUES (
        page_walls_id,
        'existing_insulation_material_other',
        jsonb_build_object(
            'hu', 'Meglévő hőszigetelés anyagának pontos típusa',
            'en', 'Exact Type of Existing Insulation Material'
        ),
        'text',
        false,
        'Adja meg a hőszigetelés anyagát',
        jsonb_build_object(
            'hu', 'Adja meg a hőszigetelés anyagát',
            'en', 'Enter the insulation material'
        ),
        12,
        jsonb_build_object(
            'field', 'existing_insulation_material',
            'operator', 'equals',
            'value', 'Egyéb'
        )
    );

    -- 13. Meglévő hőszigetelés vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, display_conditions
    ) VALUES (
        page_walls_id,
        'existing_insulation_thickness',
        jsonb_build_object(
            'hu', 'Meglévő hőszigetelés vastagsága (cm)',
            'en', 'Existing Insulation Thickness (cm)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        13,
        jsonb_build_object(
            'field', 'foundation_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- ========================================================================
    -- STEP 3: Create Survey Questions for "Egyéb adatok" Page
    -- ========================================================================

    -- 1. Hibák hozzáadása (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_other_data_id,
        'defects_title',
        jsonb_build_object('hu', 'Hibák hozzáadása', 'en', 'Add Defects'),
        'title',
        false,
        1
    );

    -- 2. Tartószerkezeti kárkép látható-e
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_other_data_id,
        'structural_damage_visible',
        jsonb_build_object(
            'hu', 'Tartószerkezeti kárkép látható-e',
            'en', 'Is Structural Damage Visible'
        ),
        'switch',
        true,
        'false',
        2,
        jsonb_build_object(
            'hu', 'Repedések a homlokzati vagy belső tartófalakon /min. 20 cm vastag/ ezek pl.: utalhatnak egyenlőtlen süllyedésre, amit okozhat rossz alapozás, utólagos alámosódás.',
            'en', 'Cracks on the facade or internal load-bearing walls (min. 20 cm thick) may indicate uneven settlement, which can be caused by poor foundation or subsequent undermining.'
        )
    );

    -- 3. Felszívódó nedvesség okozta kárkép látható-e
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_other_data_id,
        'moisture_damage_visible',
        jsonb_build_object(
            'hu', 'Felszívódó nedvesség okozta kárkép látható-e',
            'en', 'Is Moisture Damage Visible'
        ),
        'switch',
        true,
        'false',
        3,
        jsonb_build_object(
            'hu', 'Homlokzati oldalon vakolat mállás, belső oldalon salétromosodás, sóvirágzás, festék leveles leválása a lábazati részen.',
            'en', 'Plaster deterioration on the facade side, saltpeter deposits, efflorescence, and paint peeling on the foundation section on the interior side.'
        )
    );

    -- 4. Ázás kárkép látható-e
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_other_data_id,
        'water_damage_visible',
        jsonb_build_object(
            'hu', 'Ázás kárkép látható-e',
            'en', 'Is Water Damage Visible'
        ),
        'switch',
        true,
        'false',
        4,
        jsonb_build_object(
            'hu', 'A tetőfedésből, a vízelvezetés hiányából, vagy hibájából fakadó ázás, leázott, lemállott vakolat jelzi.',
            'en', 'Water damage resulting from roofing, lack of drainage, or drainage defects, indicated by soaked and deteriorated plaster.'
        )
    );

    -- 5. Egyéb feladatok (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_other_data_id,
        'other_tasks_title',
        jsonb_build_object('hu', 'Egyéb feladatok', 'en', 'Other Tasks'),
        'title',
        false,
        5
    );

    -- 6. Állványozás szükséges
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_other_data_id,
        'scaffolding_required',
        jsonb_build_object(
            'hu', 'Állványozás szükséges',
            'en', 'Scaffolding Required'
        ),
        'switch',
        true,
        'false',
        6
    );

    RAISE NOTICE 'Successfully created Facade Insulation survey pages and questions';

END $$;
