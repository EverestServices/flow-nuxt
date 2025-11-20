-- ============================================================================
-- Migration: Reorder plinth questions on facade insulation page
-- Description: Moves "A lábazat hőszigetelt-e?" before "Lábazat típusa"
--
-- Original order:
--   5. Lábazat típusa (foundation_type_avg)
--   6. Ki/beugrás mértéke (protrusion_amount)
--   7. A lábazat hőszigetelt-e? (foundation_insulated_general)
--
-- New order:
--   5. A lábazat hőszigetelt-e? (foundation_insulated_general)
--   6. Lábazat típusa (foundation_type_avg)
--   7. Ki/beugrás mértéke (protrusion_amount)
-- ============================================================================

DO $$
DECLARE
    page_id UUID;
    affected_rows INTEGER := 0;
BEGIN
    -- Get the facade insulation page ID
    SELECT id INTO page_id
    FROM public.survey_pages
    WHERE name = 'Homlokzati szigetelés alapadatok'
    LIMIT 1;

    IF page_id IS NULL THEN
        RAISE EXCEPTION 'Homlokzati szigetelés alapadatok page not found';
    END IF;

    RAISE NOTICE 'Found page ID: %', page_id;

    -- Step 1: Temporarily move foundation_insulated_general to temp position
    UPDATE public.survey_questions
    SET sequence = 100
    WHERE survey_page_id = page_id
      AND name = 'foundation_insulated_general';

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 1: Temporarily moved foundation_insulated_general to position 100 (% rows)', affected_rows;

    -- Step 2: Move protrusion_amount from 6 to 7
    UPDATE public.survey_questions
    SET sequence = 7
    WHERE survey_page_id = page_id
      AND name = 'protrusion_amount';

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 2: Moved protrusion_amount to position 7 (% rows)', affected_rows;

    -- Step 3: Move foundation_type_avg from 5 to 6
    UPDATE public.survey_questions
    SET sequence = 6
    WHERE survey_page_id = page_id
      AND name = 'foundation_type_avg';

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 3: Moved foundation_type_avg to position 6 (% rows)', affected_rows;

    -- Step 4: Move foundation_insulated_general from temp to 5
    UPDATE public.survey_questions
    SET sequence = 5
    WHERE survey_page_id = page_id
      AND name = 'foundation_insulated_general';

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 4: Moved foundation_insulated_general to position 5 (% rows)', affected_rows;

    -- Verification
    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully reordered plinth questions';
    RAISE NOTICE '';
    RAISE NOTICE 'New order:';
    RAISE NOTICE '  5. A lábazat hőszigetelt-e? (foundation_insulated_general)';
    RAISE NOTICE '  6. Lábazat típusa (foundation_type_avg)';
    RAISE NOTICE '  7. Ki/beugrás mértéke (protrusion_amount)';

END $$;
