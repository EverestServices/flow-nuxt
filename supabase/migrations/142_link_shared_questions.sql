-- ============================================================================
-- Migration: Link Shared Questions between Basic Data and Facade Insulation
-- Description: Links the following question pairs using the Shared Questions feature:
--   1. "Fal típusa" (Alapadatok) ← → "Fal típusa" (Homlokzati szigetelés)
--   2. "Homlokzat hőszigetelt?" (Alapadatok) ← → "Homlokzat hőszigetelése" (Homlokzati szigetelés)
--
-- Strategy:
--   - Alapadatok questions are the MASTER (answers stored here)
--   - Homlokzati szigetelés questions are INSTANCES (reference master)
--   - Rename instance questions to match master names (required for shared questions)
-- ============================================================================

DO $$
DECLARE
    -- Master question IDs (Alapadatok page)
    master_wall_type_id UUID;
    master_facade_insulated_id UUID;

    -- Instance question IDs (Homlokzati szigetelés alapadatok page)
    instance_wall_type_id UUID;
    instance_facade_insulation_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Get Master Question IDs from Alapadatok page
    -- ========================================================================

    -- Get "Fal típusa" (exterior_wall_structure) from Alapadatok
    SELECT sq.id INTO master_wall_type_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData'
      AND sp.type = 'basic_data'
      AND sq.name = 'exterior_wall_structure';

    IF master_wall_type_id IS NULL THEN
        RAISE EXCEPTION 'Master question exterior_wall_structure not found';
    END IF;

    -- Get "Homlokzat hőszigetelt?" (facade_insulated) from Alapadatok
    SELECT sq.id INTO master_facade_insulated_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData'
      AND sp.type = 'basic_data'
      AND sq.name = 'facade_insulated';

    IF master_facade_insulated_id IS NULL THEN
        RAISE EXCEPTION 'Master question facade_insulated not found';
    END IF;

    RAISE NOTICE 'Found master questions:';
    RAISE NOTICE '  - exterior_wall_structure: %', master_wall_type_id;
    RAISE NOTICE '  - facade_insulated: %', master_facade_insulated_id;

    -- ========================================================================
    -- STEP 2: Get Instance Question IDs from Homlokzati szigetelés page
    -- ========================================================================

    -- Get "Fal típusa" (wall_structure) from Homlokzati szigetelés
    SELECT sq.id INTO instance_wall_type_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation'
      AND sp.type = 'facade_basic_data'
      AND sq.name = 'wall_structure';

    IF instance_wall_type_id IS NULL THEN
        RAISE EXCEPTION 'Instance question wall_structure not found';
    END IF;

    -- Get "Homlokzat hőszigetelése" (facade_insulation) from Homlokzati szigetelés
    SELECT sq.id INTO instance_facade_insulation_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'facadeInsulation'
      AND sp.type = 'facade_basic_data'
      AND sq.name = 'facade_insulation';

    IF instance_facade_insulation_id IS NULL THEN
        RAISE EXCEPTION 'Instance question facade_insulation not found';
    END IF;

    RAISE NOTICE 'Found instance questions:';
    RAISE NOTICE '  - wall_structure: %', instance_wall_type_id;
    RAISE NOTICE '  - facade_insulation: %', instance_facade_insulation_id;

    -- ========================================================================
    -- STEP 3: Rename instance questions to match master names
    -- (Required for Shared Questions to work - same name needed)
    -- ========================================================================

    -- Rename wall_structure → exterior_wall_structure
    UPDATE public.survey_questions
    SET name = 'exterior_wall_structure'
    WHERE id = instance_wall_type_id;

    RAISE NOTICE 'Renamed wall_structure → exterior_wall_structure';

    -- Rename facade_insulation → facade_insulated
    UPDATE public.survey_questions
    SET name = 'facade_insulated'
    WHERE id = instance_facade_insulation_id;

    RAISE NOTICE 'Renamed facade_insulation → facade_insulated';

    -- ========================================================================
    -- STEP 4: Set instance questions as shared instances
    -- ========================================================================

    -- Set wall_structure as instance of exterior_wall_structure
    UPDATE public.survey_questions
    SET is_shared_instance = true,
        shared_question_id = master_wall_type_id
    WHERE id = instance_wall_type_id;

    RAISE NOTICE 'Linked "Fal típusa" questions as shared';
    RAISE NOTICE '  Master (Alapadatok): exterior_wall_structure';
    RAISE NOTICE '  Instance (Homlokzati szigetelés): exterior_wall_structure';

    -- Set facade_insulation as instance of facade_insulated
    UPDATE public.survey_questions
    SET is_shared_instance = true,
        shared_question_id = master_facade_insulated_id
    WHERE id = instance_facade_insulation_id;

    RAISE NOTICE 'Linked "Homlokzat hőszigetelése" questions as shared';
    RAISE NOTICE '  Master (Alapadatok): facade_insulated';
    RAISE NOTICE '  Instance (Homlokzati szigetelés): facade_insulated';

    -- ========================================================================
    -- STEP 5: Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully linked shared questions:';
    RAISE NOTICE '';
    RAISE NOTICE '1. "Fal típusa" (Wall Type)';
    RAISE NOTICE '   - Answers stored in: Alapadatok page';
    RAISE NOTICE '   - Also appears on: Homlokzati szigetelés alapadatok page';
    RAISE NOTICE '   - Question name: exterior_wall_structure';
    RAISE NOTICE '';
    RAISE NOTICE '2. "Homlokzat hőszigetelése" (Facade Insulation)';
    RAISE NOTICE '   - Answers stored in: Alapadatok page';
    RAISE NOTICE '   - Also appears on: Homlokzati szigetelés alapadatok page';
    RAISE NOTICE '   - Question name: facade_insulated';
    RAISE NOTICE '';
    RAISE NOTICE 'ℹ️  When users answer these questions on either page, the same answer will appear on both pages.';

END $$;
