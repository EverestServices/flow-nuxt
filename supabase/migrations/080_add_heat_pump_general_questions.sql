-- ============================================================================
-- Migration: Add Heat Pump General Questions
-- Description: Adds survey questions to Heat Pump "Általános adatok" page
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_general_id UUID;
BEGIN
    -- Get Heat Pump investment ID
    SELECT id INTO inv_heat_pump_id
    FROM public.investments
    WHERE persist_name = 'heatPump';

    IF inv_heat_pump_id IS NULL THEN
        RAISE EXCEPTION 'Heat Pump investment not found';
    END IF;

    -- Get "Általános adatok" page ID
    SELECT id INTO page_general_id
    FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id
    AND type = 'general';

    IF page_general_id IS NULL THEN
        RAISE EXCEPTION 'Heat Pump General page not found';
    END IF;

    -- ========================================================================
    -- Add Survey Questions
    -- ========================================================================

    -- 1. Ingatlan típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_general_id,
        'property_type',
        jsonb_build_object('hu', 'Ingatlan típusa', 'en', 'Property Type'),
        'dropdown',
        true,
        '["Családi ház", "Ikerház", "Sorház", "Egyéb"]'::jsonb,
        1
    );

    -- 2. A lakás/ház építési éve
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'construction_year',
        jsonb_build_object('hu', 'A lakás/ház építési éve', 'en', 'Construction Year'),
        'number',
        true,
        'Építési év',
        jsonb_build_object('hu', 'Építési év', 'en', 'Construction Year'),
        2
    );

    -- 3. Ingatlan fekvése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'property_location',
        jsonb_build_object('hu', 'Ingatlan fekvése', 'en', 'Property Location'),
        'text',
        true,
        'Település, kerület',
        jsonb_build_object('hu', 'Település, kerület', 'en', 'City, District'),
        3
    );

    -- 4. Az épület műemlékvédelem alatt áll
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_general_id,
        'monument_protection',
        jsonb_build_object('hu', 'Az épület műemlékvédelem alatt áll', 'en', 'The building is under monument protection'),
        'switch',
        true,
        'false',
        4
    );

    -- 5. Hőszivattyú típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_general_id,
        'heat_pump_type',
        jsonb_build_object('hu', 'Hőszivattyú típusa', 'en', 'Heat Pump Type'),
        'dropdown',
        true,
        '["Egyszerűsített", "FÉG"]'::jsonb,
        5
    );

    -- 6. Épület szintjeinek száma, padlástér nélkül
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_general_id,
        'building_floors',
        jsonb_build_object('hu', 'Épület szintjeinek száma, padlástér nélkül', 'en', 'Number of building floors, excluding attic'),
        'number',
        true,
        '2',
        6
    );

    -- 7. Tetőtér beépített és lakott
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_general_id,
        'attic_built_in',
        jsonb_build_object('hu', 'Tetőtér beépített és lakott', 'en', 'Attic is built in and inhabited'),
        'switch',
        true,
        'false',
        7
    );

    -- 8. A padlástér födémje felett, vagy a tetőben van-e hőszigetelés?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_general_id,
        'attic_insulation',
        jsonb_build_object('hu', 'A padlástér födémje felett, vagy a tetőben van-e hőszigetelés?', 'en', 'Is there insulation above the attic floor or in the roof?'),
        'switch',
        true,
        'false',
        8
    );

    -- 9. Épület alapterülete (m²)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'building_area',
        jsonb_build_object('hu', 'Épület alapterülete (m²)', 'en', 'Building Area (m²)'),
        'number',
        true,
        'm²',
        jsonb_build_object('hu', 'm²', 'en', 'm²'),
        9
    );

    -- 10. Belmagasság (m)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        min, max, step, unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'ceiling_height',
        jsonb_build_object('hu', 'Belmagasság (m)', 'en', 'Ceiling Height (m)'),
        'slider',
        true,
        2.0,
        5.0,
        0.1,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        10
    );

    -- 11. Fűtött alapterület (m²)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'heated_area',
        jsonb_build_object('hu', 'Fűtött alapterület (m²)', 'en', 'Heated Area (m²)'),
        'number',
        true,
        'm²',
        jsonb_build_object('hu', 'm²', 'en', 'm²'),
        11
    );

    -- 12. Vizes helyiségek száma
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence
    ) VALUES (
        page_general_id,
        'wet_rooms_count',
        jsonb_build_object('hu', 'Vizes helyiségek száma', 'en', 'Number of Wet Rooms'),
        'number',
        true,
        12
    );

    -- 13. Falazat típusa és vastagsága
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'wall_type_and_thickness',
        jsonb_build_object('hu', 'Falazat típusa és vastagsága', 'en', 'Wall Type and Thickness'),
        'text',
        true,
        'pl. Porotherm 30 cm',
        jsonb_build_object('hu', 'pl. Porotherm 30 cm', 'en', 'e.g. Porotherm 30 cm'),
        13
    );

    -- 14. Hőszigetelés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_general_id,
        'wall_insulation',
        jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Insulation'),
        'switch',
        true,
        'false',
        14
    );

    -- 15. Nyílászárók típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'window_type',
        jsonb_build_object('hu', 'Nyílászárók típusa', 'en', 'Window Type'),
        'text',
        true,
        'pl. Műanyag, 2 rétegű üvegezés',
        jsonb_build_object('hu', 'pl. Műanyag, 2 rétegű üvegezés', 'en', 'e.g. PVC, double-glazed'),
        15
    );

    -- 16. Nyílászárók árnyékolása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'window_shading',
        jsonb_build_object('hu', 'Nyílászárók árnyékolása', 'en', 'Window Shading'),
        'text',
        true,
        'pl. Redőny, napellenző',
        jsonb_build_object('hu', 'pl. Redőny, napellenző', 'en', 'e.g. Roller shutter, awning'),
        16
    );

    -- 17. Hány fázis áll rendelkezésre?
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, options, sequence
    ) VALUES (
        page_general_id,
        'phase_count',
        jsonb_build_object('hu', 'Hány fázis áll rendelkezésre?', 'en', 'How many phases are available?'),
        'phase_toggle',
        true,
        '1',
        '["1", "3"]'::jsonb,
        17
    );

    -- 18. Fázis 1
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'phase_1',
        jsonb_build_object('hu', 'Fázis 1', 'en', 'Phase 1'),
        'number',
        false,
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        18
    );

    -- 19. Fázis 2
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'phase_2',
        jsonb_build_object('hu', 'Fázis 2', 'en', 'Phase 2'),
        'number',
        false,
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        19
    );

    -- 20. Fázis 3
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, unit, unit_translations, sequence
    ) VALUES (
        page_general_id,
        'phase_3',
        jsonb_build_object('hu', 'Fázis 3', 'en', 'Phase 3'),
        'number',
        false,
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        20
    );

    -- 21. Megjegyzés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_general_id,
        'general_comments',
        jsonb_build_object('hu', 'Megjegyzés', 'en', 'Comments'),
        'textarea',
        false,
        'Itt írhat megjegyzéseket...',
        jsonb_build_object('hu', 'Itt írhat megjegyzéseket...', 'en', 'You can write comments here...'),
        21
    );

    RAISE NOTICE 'Successfully added 21 questions to Heat Pump General page';

END $$;
