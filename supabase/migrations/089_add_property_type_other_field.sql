-- ============================================================================
-- Migration: Add property_type_other field for Heat Pump
-- Description: Adds a conditional text field that appears when property_type is "Egyéb"
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_general_id UUID;
    property_type_other_exists BOOLEAN;
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

    -- Check if property_type_other already exists
    SELECT EXISTS (
        SELECT 1
        FROM public.survey_questions
        WHERE survey_page_id = page_general_id
        AND name = 'property_type_other'
    ) INTO property_type_other_exists;

    IF NOT property_type_other_exists THEN
        -- First, increment all sequences >= 2 to make room for the new question at position 2
        UPDATE public.survey_questions
        SET sequence = sequence + 1
        WHERE survey_page_id = page_general_id
        AND sequence >= 2;

        -- Add the new conditional field
        INSERT INTO public.survey_questions (
            survey_page_id,
            name,
            name_translations,
            type,
            is_required,
            placeholder_value,
            placeholder_translations,
            sequence,
            display_conditions
        ) VALUES (
            page_general_id,
            'property_type_other',
            jsonb_build_object('hu', 'Típus', 'en', 'Type'),
            'text',
            true,
            'Adja meg az ingatlan típusát',
            jsonb_build_object('hu', 'Adja meg az ingatlan típusát', 'en', 'Enter the property type'),
            2,
            jsonb_build_object(
                'field', 'property_type',
                'operator', 'equals',
                'value', 'Egyéb'
            )
        );

        RAISE NOTICE 'Successfully added property_type_other field to Heat Pump General page';
    ELSE
        RAISE NOTICE 'property_type_other field already exists, skipping';
    END IF;

END $$;
