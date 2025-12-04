-- ============================================================================
-- Migration: Add Basic Data Investment System
-- Description: Adds info_message_translations column, is_default column,
--              and creates Basic Data investment with survey questions
-- ============================================================================

-- ============================================================================
-- STEP 1: Add new columns
-- ============================================================================

-- Add info_message_translations to survey_questions
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS info_message_translations JSONB DEFAULT NULL;

COMMENT ON COLUMN public.survey_questions.info_message_translations IS 'Tooltip information messages in multiple languages';

-- Add is_default to investments
ALTER TABLE public.investments
ADD COLUMN IF NOT EXISTS is_default BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN public.investments.is_default IS 'If true, this investment is automatically selected for all surveys and hidden from the selection modal';

-- ============================================================================
-- STEP 2: Create Basic Data Investment
-- ============================================================================

DO $$
DECLARE
    inv_basic_data_id UUID;
    page_basic_data_id UUID;
BEGIN
    -- Insert Basic Data investment (with sequence 0 to appear first)
    INSERT INTO public.investments (
        persist_name,
        name,
        name_translations,
        icon,
        is_default,
        sequence
    ) VALUES (
        'basicData',
        'Alapadatok',
        jsonb_build_object('hu', 'Alapadatok', 'en', 'Basic Data'),
        'i-lucide-file-text',
        true,
        0
    )
    RETURNING id INTO inv_basic_data_id;

    -- Insert Basic Data survey page
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
        inv_basic_data_id,
        'Alapadatok',
        jsonb_build_object('hu', 'Alapadatok', 'en', 'Basic Data'),
        'basic_data',
        '{"top": 100, "right": 200}'::jsonb,
        false,
        false,
        1
    )
    RETURNING id INTO page_basic_data_id;

    -- ========================================================================
    -- STEP 3: Add Survey Questions
    -- ========================================================================

    -- 1. Épület típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'building_type',
        jsonb_build_object(
            'hu', 'Épület típusa',
            'en', 'Building Type'
        ),
        'dropdown',
        true,
        jsonb_build_array(
            'Szabadon álló családiház',
            'Oldalhatáron álló családiház',
            'Zártsorú családiház',
            'Ikerház',
            'Sorház'
        ),
        1,
        jsonb_build_object(
            'hu', 'Szabadon álló családiház: saját telken belül körül járható, oldalkert jellemzően min. 3,0 m\nOldalhatáron álló családiház: egyik telekhatárra épült (vagy attól legfeljebb 1,0 m-re), egy homlokzata csak a szomszéd telkéről elérhető\nZártsorú családiház: a ház a teljes telekszélességet elfoglalja, a szomszéd épületek tűzfalasan kapcsolódnak – belvárosban járatos beépítési forma\nIkerház: egyik telekhatáron tűzfalasan összeérő lakóépületek egyike\nSorház: telek legalább egy, legfeljebb 2 oldalhatárán egymáshoz határfalakkal csatlakozott épületsor egy lakása',
            'en', 'Detached family house: accessible within own plot, side yard typically min. 3.0 m\nSide boundary family house: built on one plot boundary (or max 1.0 m from it), one facade only accessible from neighbor''s plot\nRow family house: house occupies full plot width, neighboring buildings connected with fire walls – common urban form\nSemi-detached house: one of two residential buildings connected by fire wall on one plot boundary\nTownhouse: one dwelling in a row of buildings connected by party walls on at least one, maximum 2 plot boundaries'
        )
    );

    -- 2. Építés ideje (év)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'construction_year',
        jsonb_build_object(
            'hu', 'Építés ideje (év)',
            'en', 'Construction Year'
        ),
        'number',
        true,
        'Építési év',
        jsonb_build_object('hu', 'Építési év', 'en', 'Construction Year'),
        2
    );

    -- 3. Szintek száma (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'floor_levels_title',
        jsonb_build_object(
            'hu', 'Szintek száma',
            'en', 'Number of Floors'
        ),
        'title',
        false,
        3
    );

    -- 4. Pince
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'has_basement',
        jsonb_build_object(
            'hu', 'Pince',
            'en', 'Basement'
        ),
        'switch',
        true,
        'false',
        4,
        jsonb_build_object(
            'hu', 'Olyan építményszint, amelynek padlószintje több mint 20%-ában kerül 0,70 méternél mélyebbre a csatlakozó rendezett terepszint alá',
            'en', 'A building level whose floor level is more than 20% below 0.70 meters from the adjacent finished grade'
        )
    );

    -- 5. Alagsor
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'has_cellar',
        jsonb_build_object(
            'hu', 'Alagsor',
            'en', 'Cellar'
        ),
        'switch',
        true,
        'false',
        5,
        jsonb_build_object(
            'hu', 'Olyan építményszint, amelynek padlószintje legfeljebb 20 százalékában kerül 0,70 méternél mélyebbre a csatlakozó rendezett terepszint alá',
            'en', 'A building level whose floor level is at most 20% below 0.70 meters from the adjacent finished grade'
        )
    );

    -- 6. Földszint
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'has_ground_floor',
        jsonb_build_object(
            'hu', 'Földszint',
            'en', 'Ground Floor'
        ),
        'switch',
        true,
        'true',
        6
    );

    -- 7. Emelet
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'has_upper_floor',
        jsonb_build_object(
            'hu', 'Emelet',
            'en', 'Upper Floor'
        ),
        'switch',
        true,
        'false',
        7
    );

    -- 8. Beépített tetőtér
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'has_attic',
        jsonb_build_object(
            'hu', 'Beépített tetőtér',
            'en', 'Built-in Attic'
        ),
        'switch',
        true,
        'false',
        8
    );

    -- 9. Külső fal szerkezete
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_basic_data_id,
        'exterior_wall_structure',
        jsonb_build_object(
            'hu', 'Külső fal szerkezete (amennyiben minden fal megegyezik)',
            'en', 'Exterior Wall Structure (if all walls are the same)'
        ),
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
        9
    );

    -- 10. Külső fal szerkezetének pontos típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'exterior_wall_structure_other',
        jsonb_build_object(
            'hu', 'Külső fal szerkezetének pontos típusa',
            'en', 'Exact Type of Exterior Wall Structure'
        ),
        'text',
        false,
        'Adja meg a fal szerkezet típusát',
        jsonb_build_object(
            'hu', 'Adja meg a fal szerkezet típusát',
            'en', 'Enter the wall structure type'
        ),
        10,
        jsonb_build_object(
            'field', 'exterior_wall_structure',
            'operator', 'equals',
            'value', 'Egyéb'
        )
    );

    -- 11. Tető típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'roof_type_general',
        jsonb_build_object(
            'hu', 'Tető típusa',
            'en', 'Roof Type'
        ),
        'dropdown',
        true,
        jsonb_build_array(
            'Lapostető',
            'Alacsony hajlásszögű tető',
            'Magastető'
        ),
        11,
        jsonb_build_object(
            'hu', 'Lapostető: 5° alatt\nAlacsony hajlásszögű tető: 5° és 25° között\nMagastető: 25° felett',
            'en', 'Flat roof: below 5°\nLow-pitched roof: between 5° and 25°\nHigh roof: above 25°'
        )
    );

    -- 12. Magastető típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'high_roof_type',
        jsonb_build_object(
            'hu', 'Magastető típusa',
            'en', 'High Roof Type'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            'Sátortető',
            'Nyeregtető',
            'Kontyolt nyeregtető',
            'Félnyeregtető'
        ),
        12,
        jsonb_build_object(
            'field', 'roof_type_general',
            'operator', 'equals',
            'value', 'Magastető'
        )
    );

    -- 13. Megjegyzés a tetőhöz
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'roof_comments',
        jsonb_build_object(
            'hu', 'Megjegyzés a tetőhöz',
            'en', 'Comments on Roof'
        ),
        'textarea',
        false,
        'Megjegyzések...',
        jsonb_build_object(
            'hu', 'Megjegyzések...',
            'en', 'Comments...'
        ),
        13
    );

    -- 14. Kiegészítő adatok (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'additional_data_title',
        jsonb_build_object(
            'hu', 'Kiegészítő adatok',
            'en', 'Additional Data'
        ),
        'title',
        false,
        14
    );

    -- 15. Az épület védettség alatt áll
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'building_protected',
        jsonb_build_object(
            'hu', 'Az épület védettség alatt áll',
            'en', 'Building is Under Protection'
        ),
        'switch',
        true,
        'false',
        15
    );

    -- 16. Épület védettsége
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'building_protection_type',
        jsonb_build_object(
            'hu', 'Épület védettsége',
            'en', 'Building Protection Type'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            'Műemlék',
            'Műemlék jellegű',
            'Helyi védett'
        ),
        16,
        jsonb_build_object(
            'field', 'building_protected',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 17. Homlokzat hőszigetelt?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'facade_insulated',
        jsonb_build_object(
            'hu', 'Homlokzat hőszigetelt?',
            'en', 'Is Facade Insulated?'
        ),
        'switch',
        true,
        'false',
        17
    );

    -- 18. Homlokzati hőszigetelés anyaga
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'facade_insulation_material',
        jsonb_build_object(
            'hu', 'Homlokzati hőszigetelés anyaga',
            'en', 'Facade Insulation Material'
        ),
        'dropdown',
        false,
        jsonb_build_array('EPS', 'Ásványi szálas', 'PIR'),
        18,
        jsonb_build_object(
            'field', 'facade_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 19. Homlokzati hőszigetelés vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'facade_insulation_thickness',
        jsonb_build_object(
            'hu', 'Homlokzati hőszigetelés vastagsága (cm)',
            'en', 'Facade Insulation Thickness (cm)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        19,
        jsonb_build_object(
            'field', 'facade_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 20. Zárófödém hőszigetelt?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'slab_insulated',
        jsonb_build_object(
            'hu', 'Zárófödém hőszigetelt?',
            'en', 'Is Ceiling Slab Insulated?'
        ),
        'switch',
        true,
        'false',
        20
    );

    -- 21. Zárófödém hőszigetelés anyaga
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'slab_insulation_material',
        jsonb_build_object(
            'hu', 'Zárófödém hőszigetelés anyaga',
            'en', 'Ceiling Slab Insulation Material'
        ),
        'dropdown',
        false,
        jsonb_build_array('EPS', 'Ásványi szálas', 'PIR'),
        21,
        jsonb_build_object(
            'field', 'slab_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 22. Zárófödém hőszigetelés vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'slab_insulation_thickness',
        jsonb_build_object(
            'hu', 'Zárófödém hőszigetelés vastagsága (cm)',
            'en', 'Ceiling Slab Insulation Thickness (cm)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        22,
        jsonb_build_object(
            'field', 'slab_insulated',
            'operator', 'equals',
            'value', 'true'
        )
    );

    -- 23. Meglévő fűtésrendszer hőtermelője
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'heating_system_heat_generator',
        jsonb_build_object(
            'hu', 'Meglévő fűtésrendszer hőtermelője',
            'en', 'Existing Heating System Heat Generator'
        ),
        'dropdown',
        true,
        jsonb_build_array(
            'Nyílt égésterű gázkazán',
            'Zárt égésterű állandó hőmérsékletű gázkazán',
            'Kondenzációs gázkazán',
            'Vegyestüzelésű kazán',
            'Cserépkályha, kandalló',
            'Elektromos kazán',
            'Gázkonvektor',
            'Klíma',
            'Hőszivattyú',
            'Elektromos fűtőpanel',
            'Egyéb'
        ),
        23,
        jsonb_build_object(
            'hu', 'Zárt égésterű állandó hőmérsékletű gázkazán: az égéshez szükséges levegőt nem a szobából veszi, de még nem kondenzációs üzemű',
            'en', 'Sealed combustion chamber constant temperature gas boiler: does not take combustion air from the room, but is not yet condensing'
        )
    );

    -- 24. Meglévő fűtésrendszer hőtermelőjének típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'heating_system_heat_generator_other',
        jsonb_build_object(
            'hu', 'Meglévő fűtésrendszer hőtermelőjének típusa',
            'en', 'Type of Existing Heating System Heat Generator'
        ),
        'text',
        false,
        'Adja meg a hőtermelő típusát',
        jsonb_build_object(
            'hu', 'Adja meg a hőtermelő típusát',
            'en', 'Enter the heat generator type'
        ),
        24,
        jsonb_build_object(
            'field', 'heating_system_heat_generator',
            'operator', 'equals',
            'value', 'Egyéb'
        )
    );

    -- 25. HMV készítés módja
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_basic_data_id,
        'hot_water_preparation_method',
        jsonb_build_object(
            'hu', 'HMV készítés módja',
            'en', 'Hot Water Preparation Method'
        ),
        'dropdown',
        true,
        jsonb_build_array(
            'Villanybojler',
            'Gázbojler',
            'Kombi gázkazán (átfolyós)',
            'Indirekt tároló',
            'Elektromos átfolyós vízmelegítő'
        ),
        25,
        jsonb_build_object(
            'hu', 'Indirekt tároló: fűtési rendszer hőtermelője fűti, ami lehet kazán, kályha, hőszivattyú',
            'en', 'Indirect storage: heated by heating system heat generator, which can be boiler, stove, heat pump'
        )
    );

    RAISE NOTICE 'Successfully created Basic Data investment with survey page and questions';

END $$;
