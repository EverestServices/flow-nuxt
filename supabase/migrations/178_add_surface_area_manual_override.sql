-- ============================================================================
-- Migration: Add Surface Area Manual Override Functionality
-- Description: Adds a hidden lock state question and updates the calculated
--              surface area question to support manual override with lock icon
-- ============================================================================

DO $$
DECLARE
    inv_attic_floor_id UUID;
    page_attic_data_id UUID;
    surface_area_question_id UUID;
BEGIN
    -- ========================================================================
    -- Find Investment and Page
    -- ========================================================================

    SELECT id INTO inv_attic_floor_id
    FROM public.investments
    WHERE persist_name = 'roofInsulation';

    IF inv_attic_floor_id IS NULL THEN
        RAISE EXCEPTION 'Attic Floor Insulation investment not found';
    END IF;

    SELECT id INTO page_attic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_attic_floor_id
      AND type = 'attic_data';

    IF page_attic_data_id IS NULL THEN
        RAISE EXCEPTION 'Tetőtér adatai page not found';
    END IF;

    -- ========================================================================
    -- Create hidden lock state question
    -- ========================================================================

    -- Insert hidden switch question to track lock state
    -- Sequence doesn't matter much as it will be hidden
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        default_value,
        sequence,
        display_settings
    ) VALUES (
        page_attic_data_id,
        'surface_area_lock_state',
        jsonb_build_object(
            'hu', 'Felület kézi felülírás állapota',
            'en', 'Surface area manual override state'
        ),
        'switch',
        false,
        'false',
        999, -- High sequence so it appears at the end but will be hidden anyway
        jsonb_build_object('hidden', true)
    );

    RAISE NOTICE 'Created hidden lock state question';

    -- ========================================================================
    -- Update calculated_surface_area question options
    -- ========================================================================

    -- Find the calculated_surface_area question
    SELECT id INTO surface_area_question_id
    FROM public.survey_questions
    WHERE survey_page_id = page_attic_data_id
      AND name = 'calculated_surface_area';

    IF surface_area_question_id IS NULL THEN
        RAISE EXCEPTION 'calculated_surface_area question not found';
    END IF;

    -- Update options to include manual override configuration
    UPDATE public.survey_questions
    SET options = jsonb_build_object(
        'operation', 'multiply',
        'fields', jsonb_build_array('width', 'length'),
        'decimals', 2,
        'allowManualOverride', true,
        'lockStateField', 'surface_area_lock_state',
        'affectedFields', jsonb_build_array('width', 'length')
    )
    WHERE id = surface_area_question_id;

    RAISE NOTICE 'Updated calculated_surface_area question with manual override options';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully added surface area manual override functionality';
    RAISE NOTICE 'Created hidden lock state question: surface_area_lock_state';
    RAISE NOTICE 'Updated calculated_surface_area with allowManualOverride';
    RAISE NOTICE 'Lock state controls width/length readonly state';
    RAISE NOTICE '========================================';

END $$;
