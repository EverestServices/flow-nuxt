-- ============================================================================
-- Migration: Swap Facade Insulation Pages Sequence
-- Description: Swaps the sequence of "walls" and "facade_basic_data" pages
--              - walls: 1 -> 0
--              - facade_basic_data: 0 -> 1
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    page_facade_basic_data_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get page IDs
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data page not found';
    END IF;

    -- ========================================================================
    -- Swap sequence values
    -- ========================================================================

    -- Temporarily set facade_basic_data to -1 to avoid unique constraint issues
    UPDATE public.survey_pages
    SET sequence = -1
    WHERE id = page_facade_basic_data_id;

    -- Set walls to 0
    UPDATE public.survey_pages
    SET sequence = 0
    WHERE id = page_walls_id;

    -- Set facade_basic_data to 1
    UPDATE public.survey_pages
    SET sequence = 1
    WHERE id = page_facade_basic_data_id;

    RAISE NOTICE '✅ Successfully swapped page sequences:';
    RAISE NOTICE '   - Walls (Falak): sequence 1 -> 0';
    RAISE NOTICE '   - Facade Basic Data (Homlokzati szigetelés alapadatok): sequence 0 -> 1';

END $$;
