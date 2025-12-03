-- ============================================================================
-- Migration: Update Foundation Area Calculation for Unit Conversion
-- Description: Updates calculated fields on Walls page to convert
--              foundation_height from cm to m (multiply by 0.01)
--              for accurate m² calculations
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    q_foundation_area_id UUID;
    q_total_foundation_area_id UUID;
    updated_count INTEGER := 0;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Walls page ID
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Update "Lábazat felülete (m²)" calculation (if exists)
    -- ========================================================================

    -- Try to find the foundation area calculated question
    SELECT id INTO q_foundation_area_id
    FROM public.survey_questions
    WHERE survey_page_id = page_walls_id
      AND type = 'calculated'
      AND (name = 'foundation_area' OR name LIKE '%foundation%area%');

    IF q_foundation_area_id IS NOT NULL THEN
        -- Update the calculation formula to include unit conversion
        UPDATE public.survey_questions
        SET options = jsonb_build_object(
            'operation', 'multiply',
            'fields', jsonb_build_array('wall_length', 'foundation_height'),
            'decimals', 2,
            'field_unit_conversions', jsonb_build_object(
                'foundation_height', 0.01  -- Convert cm to m
            )
        )
        WHERE id = q_foundation_area_id;

        updated_count := updated_count + 1;
        RAISE NOTICE 'Updated foundation_area calculation with unit conversion (cm → m)';
    ELSE
        RAISE NOTICE 'foundation_area question not found, skipping';
    END IF;

    -- ========================================================================
    -- STEP 2: Update any other calculations that use foundation_height
    -- ========================================================================

    -- Find all calculated questions that use foundation_height in their fields
    UPDATE public.survey_questions
    SET options = jsonb_set(
        options,
        '{field_unit_conversions}',
        jsonb_build_object('foundation_height', 0.01),
        true
    )
    WHERE survey_page_id = page_walls_id
      AND type = 'calculated'
      AND id != COALESCE(q_foundation_area_id, '00000000-0000-0000-0000-000000000000'::UUID)
      AND options->'fields' @> '"foundation_height"'::jsonb;

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    IF updated_count > 0 THEN
        RAISE NOTICE 'Updated % additional calculated questions with foundation_height unit conversion', updated_count;
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully updated foundation area calculations:';
    RAISE NOTICE '   - foundation_height now converted from cm to m (× 0.01)';
    RAISE NOTICE '   - This ensures accurate m² calculations';
    RAISE NOTICE '   - Updated questions: foundation_area and any other calculations using foundation_height';

END $$;
