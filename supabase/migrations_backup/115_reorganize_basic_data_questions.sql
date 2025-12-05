-- ============================================================================
-- Migration: Reorganize Basic Data Questions
-- Description: Reorders questions, adds new ones, and creates "Egyéb adatok" section
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    seq_counter INTEGER := 1;
BEGIN
    -- Get Basic Data page
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Add new questions
    -- ========================================================================

    -- Falak mindenhol megegyező típusúak
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'walls_uniform_type',
        jsonb_build_object(
            'hu', 'Falak mindenhol megegyező típusúak',
            'en', 'All walls are the same type'
        ),
        'switch',
        false,
        'true',
        999
    );

    -- Tető dőlésszöge
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, min, max, step, sequence
    ) VALUES (
        page_basic_data_id,
        'roof_angle',
        jsonb_build_object(
            'hu', 'Tető dőlésszöge',
            'en', 'Roof Angle'
        ),
        'range',
        false,
        '°',
        jsonb_build_object('hu', '°', 'en', '°'),
        0,
        50,
        1,
        999
    );

    -- Villanyfogyasztás (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'electricity_consumption_title',
        jsonb_build_object(
            'hu', 'Villanyfogyasztás',
            'en', 'Electricity Consumption'
        ),
        'title',
        false,
        999
    );

    -- Villany mértékegység
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'electricity_unit',
        jsonb_build_object(
            'hu', 'Mértékegység',
            'en', 'Unit'
        ),
        'dual_toggle',
        false,
        jsonb_build_array('kWh', 'Ft'),
        'kWh',
        999
    );

    -- Villany időszak
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'electricity_period',
        jsonb_build_object(
            'hu', 'Időszak',
            'en', 'Period'
        ),
        'dual_toggle',
        false,
        jsonb_build_array('hónap', 'év'),
        'év',
        999
    );

    -- Villany fogyasztás
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'electricity_consumption',
        jsonb_build_object(
            'hu', 'Fogyasztás',
            'en', 'Consumption'
        ),
        'number',
        false,
        'Fogyasztás',
        jsonb_build_object('hu', 'Fogyasztás', 'en', 'Consumption'),
        999
    );

    -- Gázfogyasztás (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'gas_consumption_title',
        jsonb_build_object(
            'hu', 'Gázfogyasztás',
            'en', 'Gas Consumption'
        ),
        'title',
        false,
        999
    );

    -- Gáz mértékegység
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'gas_unit',
        jsonb_build_object(
            'hu', 'Mértékegység',
            'en', 'Unit'
        ),
        'dual_toggle',
        false,
        jsonb_build_array('m³', 'Ft'),
        'm³',
        999
    );

    -- Gáz időszak
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, default_value, sequence
    ) VALUES (
        page_basic_data_id,
        'gas_period',
        jsonb_build_object(
            'hu', 'Időszak',
            'en', 'Period'
        ),
        'dual_toggle',
        false,
        jsonb_build_array('hónap', 'év'),
        'év',
        999
    );

    -- Gáz fogyasztás
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'gas_consumption',
        jsonb_build_object(
            'hu', 'Fogyasztás',
            'en', 'Consumption'
        ),
        'number',
        false,
        'Fogyasztás',
        jsonb_build_object('hu', 'Fogyasztás', 'en', 'Consumption'),
        999
    );

    -- Rendelkezésre álló teljesítmény (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'available_power_title',
        jsonb_build_object(
            'hu', 'Rendelkezésre álló teljesítmény',
            'en', 'Available Power'
        ),
        'title',
        false,
        999
    );

    -- Hány fázis áll rendelkezésre (update existing question to phase_toggle)
    UPDATE public.survey_questions
    SET type = 'phase_toggle',
        options = jsonb_build_array('1', '3'),
        default_value = '1',
        name_translations = jsonb_build_object(
            'hu', 'Hány fázis áll rendelkezésre',
            'en', 'Number of phases available'
        ),
        sequence = 999
    WHERE survey_page_id = page_basic_data_id
      AND name = 'available_phases';

    -- Fázis 1
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'phase_1_power',
        jsonb_build_object(
            'hu', 'Fázis 1',
            'en', 'Phase 1'
        ),
        'number',
        false,
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        999
    );

    -- Fázis 2
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence,
        display_conditions
    ) VALUES (
        page_basic_data_id,
        'phase_2_power',
        jsonb_build_object(
            'hu', 'Fázis 2',
            'en', 'Phase 2'
        ),
        'number',
        false,
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        999,
        jsonb_build_object(
            'field', 'available_phases',
            'operator', 'equals',
            'value', '3'
        )
    );

    -- Fázis 3
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, placeholder_value, placeholder_translations, sequence,
        display_conditions
    ) VALUES (
        page_basic_data_id,
        'phase_3_power',
        jsonb_build_object(
            'hu', 'Fázis 3',
            'en', 'Phase 3'
        ),
        'number',
        false,
        'A',
        jsonb_build_object('hu', 'A', 'en', 'A'),
        'Amper',
        jsonb_build_object('hu', 'Amper', 'en', 'Ampere'),
        999,
        jsonb_build_object(
            'field', 'available_phases',
            'operator', 'equals',
            'value', '3'
        )
    );

    -- Egyéb adatok title (update existing or create new)
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
            'hu', 'Egyéb adatok',
            'en', 'Other Data'
        ),
        sequence = 999
    WHERE survey_page_id = page_basic_data_id
      AND name = 'additional_data_title';

    -- If additional_data_title doesn't exist, create it
    IF NOT EXISTS (
        SELECT 1 FROM public.survey_questions
        WHERE survey_page_id = page_basic_data_id AND name = 'additional_data_title'
    ) THEN
        INSERT INTO public.survey_questions (
            survey_page_id, name, name_translations, type, is_required, sequence
        ) VALUES (
            page_basic_data_id,
            'additional_data_title',
            jsonb_build_object(
                'hu', 'Egyéb adatok',
                'en', 'Other Data'
            ),
            'title',
            false,
            999
        );
    END IF;

    -- Megjegyzés
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'general_notes',
        jsonb_build_object(
            'hu', 'Megjegyzés',
            'en', 'Notes'
        ),
        'textarea',
        false,
        'Megjegyzések...',
        jsonb_build_object('hu', 'Megjegyzések...', 'en', 'Notes...'),
        999
    );

    -- Nyílászárók típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        placeholder_value, placeholder_translations, sequence
    ) VALUES (
        page_basic_data_id,
        'window_door_type',
        jsonb_build_object(
            'hu', 'Nyílászárók típusa',
            'en', 'Window and Door Type'
        ),
        'text',
        false,
        'Nyílászárók típusa',
        jsonb_build_object('hu', 'Nyílászárók típusa', 'en', 'Window and Door Type'),
        999
    );

    -- ========================================================================
    -- STEP 2: Reorder all questions according to the specified sequence
    -- ========================================================================

    -- 1. Ingatlan típusa
    UPDATE public.survey_questions SET sequence = 1
    WHERE survey_page_id = page_basic_data_id AND name = 'building_type';

    -- 2. Ingatlan építési éve
    UPDATE public.survey_questions SET sequence = 2
    WHERE survey_page_id = page_basic_data_id AND name = 'construction_year';

    -- 3. Szintek száma (title)
    UPDATE public.survey_questions SET sequence = 3
    WHERE survey_page_id = page_basic_data_id AND name = 'floor_levels_title';

    -- 4. Pince
    UPDATE public.survey_questions SET sequence = 4
    WHERE survey_page_id = page_basic_data_id AND name = 'has_basement';

    -- 5. Alagsor
    UPDATE public.survey_questions SET sequence = 5
    WHERE survey_page_id = page_basic_data_id AND name = 'has_cellar';

    -- 6. Földszint
    UPDATE public.survey_questions SET sequence = 6
    WHERE survey_page_id = page_basic_data_id AND name = 'has_ground_floor';

    -- 7. Emelet
    UPDATE public.survey_questions SET sequence = 7
    WHERE survey_page_id = page_basic_data_id AND name = 'has_upper_floor';

    -- 8. Beépített tetőtér
    UPDATE public.survey_questions SET sequence = 8
    WHERE survey_page_id = page_basic_data_id AND name = 'has_attic';

    -- 9. Fal típusa
    UPDATE public.survey_questions SET sequence = 9
    WHERE survey_page_id = page_basic_data_id AND name = 'exterior_wall_structure';

    -- 10. Fal pontos típusa
    UPDATE public.survey_questions SET sequence = 10
    WHERE survey_page_id = page_basic_data_id AND name = 'exterior_wall_structure_other';

    -- 11. Falak mindenhol megegyező típusúak
    UPDATE public.survey_questions SET sequence = 11
    WHERE survey_page_id = page_basic_data_id AND name = 'walls_uniform_type';

    -- 12. Tető típusa
    UPDATE public.survey_questions SET sequence = 12
    WHERE survey_page_id = page_basic_data_id AND name = 'roof_type_general';

    -- 13. Magastető típusa
    UPDATE public.survey_questions SET sequence = 13
    WHERE survey_page_id = page_basic_data_id AND name = 'high_roof_type';

    -- 14. Tető dőlésszöge
    UPDATE public.survey_questions SET sequence = 14
    WHERE survey_page_id = page_basic_data_id AND name = 'roof_angle';

    -- 15. Villanyfogyasztás (title)
    UPDATE public.survey_questions SET sequence = 15
    WHERE survey_page_id = page_basic_data_id AND name = 'electricity_consumption_title';

    -- 16. Villany mértékegység
    UPDATE public.survey_questions SET sequence = 16
    WHERE survey_page_id = page_basic_data_id AND name = 'electricity_unit';

    -- 17. Villany időszak
    UPDATE public.survey_questions SET sequence = 17
    WHERE survey_page_id = page_basic_data_id AND name = 'electricity_period';

    -- 18. Villany fogyasztás
    UPDATE public.survey_questions SET sequence = 18
    WHERE survey_page_id = page_basic_data_id AND name = 'electricity_consumption';

    -- 19. Gázfogyasztás (title)
    UPDATE public.survey_questions SET sequence = 19
    WHERE survey_page_id = page_basic_data_id AND name = 'gas_consumption_title';

    -- 20. Gáz mértékegység
    UPDATE public.survey_questions SET sequence = 20
    WHERE survey_page_id = page_basic_data_id AND name = 'gas_unit';

    -- 21. Gáz időszak
    UPDATE public.survey_questions SET sequence = 21
    WHERE survey_page_id = page_basic_data_id AND name = 'gas_period';

    -- 22. Gáz fogyasztás
    UPDATE public.survey_questions SET sequence = 22
    WHERE survey_page_id = page_basic_data_id AND name = 'gas_consumption';

    -- 23. Meglévő fűtésrendszer hőtermelője
    UPDATE public.survey_questions SET sequence = 23
    WHERE survey_page_id = page_basic_data_id AND name = 'heating_system_heat_generator';

    -- 24. Meglévő fűtésrendszer hőtermelőjének típusa
    UPDATE public.survey_questions SET sequence = 24
    WHERE survey_page_id = page_basic_data_id AND name = 'heating_system_heat_generator_other';

    -- 25. HMV készítés módja
    UPDATE public.survey_questions SET sequence = 25
    WHERE survey_page_id = page_basic_data_id AND name = 'hot_water_preparation_method';

    -- 26. Homlokzat hőszigetelt?
    UPDATE public.survey_questions SET sequence = 26
    WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulated';

    -- 27. Homlokzati hőszigetelés anyaga
    UPDATE public.survey_questions SET sequence = 27
    WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulation_material';

    -- 28. Homlokzati hőszigetelés vastagsága (cm)
    UPDATE public.survey_questions SET sequence = 28
    WHERE survey_page_id = page_basic_data_id AND name = 'facade_insulation_thickness';

    -- 29. Zárófödém hőszigetelt?
    UPDATE public.survey_questions SET sequence = 29
    WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulated';

    -- 30. Zárófödém hőszigetelés anyaga
    UPDATE public.survey_questions SET sequence = 30
    WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulation_material';

    -- 31. Zárófödém hőszigetelés vastagsága (cm)
    UPDATE public.survey_questions SET sequence = 31
    WHERE survey_page_id = page_basic_data_id AND name = 'slab_insulation_thickness';

    -- 32. Rendelkezésre álló teljesítmény (title)
    UPDATE public.survey_questions SET sequence = 32
    WHERE survey_page_id = page_basic_data_id AND name = 'available_power_title';

    -- 33. Hány fázis áll rendelkezésre
    UPDATE public.survey_questions SET sequence = 33
    WHERE survey_page_id = page_basic_data_id AND name = 'available_phases';

    -- 34. Fázis 1
    UPDATE public.survey_questions SET sequence = 34
    WHERE survey_page_id = page_basic_data_id AND name = 'phase_1_power';

    -- 35. Fázis 2
    UPDATE public.survey_questions SET sequence = 35
    WHERE survey_page_id = page_basic_data_id AND name = 'phase_2_power';

    -- 36. Fázis 3
    UPDATE public.survey_questions SET sequence = 36
    WHERE survey_page_id = page_basic_data_id AND name = 'phase_3_power';

    -- 37. Egyéb adatok (title)
    UPDATE public.survey_questions SET sequence = 37
    WHERE survey_page_id = page_basic_data_id AND name = 'additional_data_title';

    -- 38. Az épület védettség alatt áll
    UPDATE public.survey_questions SET sequence = 38
    WHERE survey_page_id = page_basic_data_id AND name = 'building_protected';

    -- 39. Épület védettsége
    UPDATE public.survey_questions SET sequence = 39
    WHERE survey_page_id = page_basic_data_id AND name = 'building_protection_type';

    -- 40. Megjegyzés
    UPDATE public.survey_questions SET sequence = 40
    WHERE survey_page_id = page_basic_data_id AND name = 'general_notes';

    -- 41. Épület hasznos alapterülete (m²)
    UPDATE public.survey_questions SET sequence = 41
    WHERE survey_page_id = page_basic_data_id AND name = 'building_useful_floor_area';

    -- 42. Nyílászárók típusa
    UPDATE public.survey_questions SET sequence = 42
    WHERE survey_page_id = page_basic_data_id AND name = 'window_door_type';

    RAISE NOTICE 'Successfully reorganized Basic Data questions';

END $$;
