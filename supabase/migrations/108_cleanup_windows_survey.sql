-- ============================================================================
-- Migration: Cleanup Windows Survey Pages and Questions
-- Description: Removes all SurveyPages and SurveyQuestions for the
--              Nyílászárók (Windows) investment
--              to allow fresh setup from scratch
-- ============================================================================

DO $$
DECLARE
    inv_windows_id UUID;
    deleted_pages_count INTEGER;
    deleted_questions_count INTEGER;
    deleted_answers_count INTEGER;
BEGIN
    -- ========================================================================
    -- STEP 1: Find the Windows investment
    -- ========================================================================

    SELECT id INTO inv_windows_id
    FROM public.investments
    WHERE persist_name = 'windows';  -- This is the persist_name for Nyílászárók

    IF inv_windows_id IS NULL THEN
        RAISE NOTICE 'Windows investment not found (persist_name: windows)';
        RETURN;
    END IF;

    RAISE NOTICE 'Found Windows investment with ID: %', inv_windows_id;

    -- ========================================================================
    -- STEP 2: Count existing records before deletion
    -- ========================================================================

    SELECT COUNT(*) INTO deleted_pages_count
    FROM public.survey_pages
    WHERE investment_id = inv_windows_id;

    SELECT COUNT(*) INTO deleted_questions_count
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
    WHERE sp.investment_id = inv_windows_id;

    SELECT COUNT(*) INTO deleted_answers_count
    FROM public.survey_answers sa
    JOIN public.survey_questions sq ON sa.survey_question_id = sq.id
    JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
    WHERE sp.investment_id = inv_windows_id;

    RAISE NOTICE 'Found % survey pages to delete', deleted_pages_count;
    RAISE NOTICE 'Found % survey questions to delete', deleted_questions_count;
    RAISE NOTICE 'Found % survey answers to delete', deleted_answers_count;

    -- ========================================================================
    -- STEP 3: Delete survey_answers first (for safety, though CASCADE should handle it)
    -- ========================================================================

    DELETE FROM public.survey_answers sa
    USING public.survey_questions sq, public.survey_pages sp
    WHERE sa.survey_question_id = sq.id
      AND sq.survey_page_id = sp.id
      AND sp.investment_id = inv_windows_id;

    RAISE NOTICE 'Deleted survey answers';

    -- ========================================================================
    -- STEP 4: Delete survey_questions (CASCADE from pages will also delete these)
    -- ========================================================================

    DELETE FROM public.survey_questions sq
    USING public.survey_pages sp
    WHERE sq.survey_page_id = sp.id
      AND sp.investment_id = inv_windows_id;

    RAISE NOTICE 'Deleted survey questions';

    -- ========================================================================
    -- STEP 5: Delete survey_pages for this investment
    -- ========================================================================

    DELETE FROM public.survey_pages
    WHERE investment_id = inv_windows_id;

    RAISE NOTICE 'Deleted survey pages';

    -- ========================================================================
    -- STEP 6: Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully cleaned up Windows (Nyílászárók)';
    RAISE NOTICE 'Deleted: % survey pages', deleted_pages_count;
    RAISE NOTICE 'Deleted: % survey questions', deleted_questions_count;
    RAISE NOTICE 'Deleted: % survey answers', deleted_answers_count;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Investment is now ready for fresh setup';

END $$;
