-- ============================================================================
-- Migration: Cleanup Facade Insulation Survey Pages and Questions
-- Description: Removes all existing survey pages and questions for the
--              Facade Insulation investment to prepare for restructuring
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    deleted_pages_count INTEGER;
    deleted_questions_count INTEGER;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Count existing questions before deletion
    SELECT COUNT(*) INTO deleted_questions_count
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    WHERE sp.investment_id = inv_facade_id;

    -- Count existing pages before deletion
    SELECT COUNT(*) INTO deleted_pages_count
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id;

    -- ========================================================================
    -- STEP 1: Delete all survey questions for Facade Insulation
    -- ========================================================================

    DELETE FROM public.survey_questions
    WHERE survey_page_id IN (
        SELECT id FROM public.survey_pages
        WHERE investment_id = inv_facade_id
    );

    -- ========================================================================
    -- STEP 2: Delete all survey pages for Facade Insulation
    -- ========================================================================

    DELETE FROM public.survey_pages
    WHERE investment_id = inv_facade_id;

    -- Log completion
    RAISE NOTICE 'Successfully deleted % survey questions and % survey pages for Facade Insulation',
        deleted_questions_count, deleted_pages_count;

END $$;
