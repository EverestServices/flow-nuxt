-- ============================================================================
-- Migration: Create Heat Pump General Page
-- Description: Creates the "Általános adatok" page for Heat Pump investment
--              with modern structure (translations, sequence, etc.)
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

    -- ========================================================================
    -- Create "Általános adatok" (General) Page
    -- ========================================================================

    INSERT INTO public.survey_pages (
        id,
        investment_id,
        name,
        name_translations,
        type,
        position,
        sequence,
        allow_multiple,
        allow_delete_first
    ) VALUES (
        gen_random_uuid(),
        inv_heat_pump_id,
        'Általános adatok',
        jsonb_build_object(
            'hu', 'Általános adatok',
            'en', 'General Data'
        ),
        'general',
        '{"top": 200, "right": 300}'::jsonb,
        1, -- First page
        false,
        false
    )
    RETURNING id INTO page_general_id;

    RAISE NOTICE 'Heat Pump "Általános adatok" page created with ID: %', page_general_id;

    -- Note: Survey questions will be added in a subsequent migration

END $$;
