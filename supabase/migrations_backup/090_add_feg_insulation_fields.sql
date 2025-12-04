-- ============================================================================
-- Migration: Add FÉG-specific insulation fields
-- Description: Adds conditional slab and facade insulation fields for Heat Pump
--              when heat_pump_type is "FÉG"
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_general_id UUID;
    slab_insulation_exists BOOLEAN;
    facade_insulation_exists BOOLEAN;
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

    -- Check if slab_insulation already exists
    SELECT EXISTS (
        SELECT 1
        FROM public.survey_questions
        WHERE survey_page_id = page_general_id
        AND name = 'slab_insulation'
    ) INTO slab_insulation_exists;

    -- Check if facade_insulation already exists
    SELECT EXISTS (
        SELECT 1
        FROM public.survey_questions
        WHERE survey_page_id = page_general_id
        AND name = 'facade_insulation'
    ) INTO facade_insulation_exists;

    IF NOT slab_insulation_exists OR NOT facade_insulation_exists THEN
        -- Increment all sequences >= 15 to make room for the two new questions
        UPDATE public.survey_questions
        SET sequence = sequence + 2
        WHERE survey_page_id = page_general_id
        AND sequence >= 15;

        -- Add Födém szigetelés (Slab Insulation) field
        IF NOT slab_insulation_exists THEN
            INSERT INTO public.survey_questions (
                survey_page_id,
                name,
                name_translations,
                type,
                is_required,
                default_value,
                sequence,
                display_conditions
            ) VALUES (
                page_general_id,
                'slab_insulation',
                jsonb_build_object('hu', 'Födém szigetelés', 'en', 'Slab Insulation'),
                'switch',
                false,
                'false',
                15,
                jsonb_build_object(
                    'field', 'heat_pump_type',
                    'operator', 'equals',
                    'value', 'FÉG'
                )
            );
            RAISE NOTICE 'Successfully added slab_insulation field';
        END IF;

        -- Add Homlokzat szigetelés (Facade Insulation) field
        IF NOT facade_insulation_exists THEN
            INSERT INTO public.survey_questions (
                survey_page_id,
                name,
                name_translations,
                type,
                is_required,
                default_value,
                sequence,
                display_conditions
            ) VALUES (
                page_general_id,
                'facade_insulation',
                jsonb_build_object('hu', 'Homlokzat szigetelés', 'en', 'Facade Insulation'),
                'switch',
                false,
                'false',
                16,
                jsonb_build_object(
                    'field', 'heat_pump_type',
                    'operator', 'equals',
                    'value', 'FÉG'
                )
            );
            RAISE NOTICE 'Successfully added facade_insulation field';
        END IF;

        RAISE NOTICE 'Successfully added FÉG insulation fields to Heat Pump General page';
    ELSE
        RAISE NOTICE 'FÉG insulation fields already exist, skipping';
    END IF;

END $$;
