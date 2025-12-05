-- Migration: Add heated floor area, matching switch, and average ceiling height questions to Basic Data
-- Description: Adds three new questions after "Épület hasznos alapterülete (m²)":
-- 1. Ebből fűtött alapterület (m²) - number type
-- 2. Megegyezik a hasznos alapterülettel - switch type (controls readonly state and value copy)
-- 3. Épület átlagos belmagassága (m) - range type

DO $$
DECLARE
    page_basic_data_id UUID;
    q_useful_floor_area_id UUID;
    q_heated_floor_area_id UUID;
    q_matches_useful_area_id UUID;
    q_avg_ceiling_height_id UUID;
BEGIN
    -- Get the Basic Data survey page ID
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'basicData'
      AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data survey page not found';
    END IF;

    -- Get the "Épület hasznos alapterülete (m²)" question ID
    SELECT id INTO q_useful_floor_area_id
    FROM public.survey_questions
    WHERE survey_page_id = page_basic_data_id
      AND name = 'building_useful_floor_area';

    IF q_useful_floor_area_id IS NULL THEN
        RAISE EXCEPTION 'Question "building_useful_floor_area" not found';
    END IF;

    -- 31. Ebből fűtött alapterület (m²)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        placeholder_value,
        placeholder_translations,
        sequence,
        is_readonly
    ) VALUES (
        page_basic_data_id,
        'heated_floor_area',
        jsonb_build_object(
            'hu', 'Ebből fűtött alapterület (m²)',
            'en', 'Heated Floor Area (m²)'
        ),
        'number',
        false,
        'm²',
        jsonb_build_object('hu', 'm²', 'en', 'm²'),
        'Fűtött alapterület',
        jsonb_build_object('hu', 'Fűtött alapterület', 'en', 'Heated Floor Area'),
        31,
        false  -- Will be controlled by switch, not permanently readonly
    )
    RETURNING id INTO q_heated_floor_area_id;

    -- 32. Megegyezik a hasznos alapterülettel (switch)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_basic_data_id,
        'heated_area_matches_useful_area',
        jsonb_build_object(
            'hu', 'Megegyezik a hasznos alapterülettel',
            'en', 'Matches Useful Floor Area'
        ),
        'switch',
        false,
        32
    )
    RETURNING id INTO q_matches_useful_area_id;

    -- 33. Épület átlagos belmagassága (m)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        placeholder_value,
        placeholder_translations,
        min,
        max,
        step,
        sequence
    ) VALUES (
        page_basic_data_id,
        'avg_ceiling_height',
        jsonb_build_object(
            'hu', 'Épület átlagos belmagassága (m)',
            'en', 'Average Ceiling Height (m)'
        ),
        'range',
        false,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        'Belmagasság',
        jsonb_build_object('hu', 'Belmagasság', 'en', 'Ceiling Height'),
        2.0,
        5.0,
        0.1,
        33
    )
    RETURNING id INTO q_avg_ceiling_height_id;

    -- Create value copy rule:
    -- When "Megegyezik a hasznos alapterülettel" switch is TRUE,
    -- copy value from "building_useful_floor_area" to "heated_floor_area"
    INSERT INTO public.survey_value_copy_rules (
        condition_question_id,
        condition_value,
        source_question_id,
        target_question_id
    ) VALUES (
        q_matches_useful_area_id,
        'true',
        q_useful_floor_area_id,
        q_heated_floor_area_id
    );

    RAISE NOTICE 'Successfully added heated floor area, matching switch, and ceiling height questions';
    RAISE NOTICE 'Question IDs: heated_floor_area=%, matches_switch=%, avg_ceiling_height=%',
        q_heated_floor_area_id, q_matches_useful_area_id, q_avg_ceiling_height_id;

END $$;
