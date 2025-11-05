-- ============================================================================
-- Migration: Restore Sequence Column
-- Description: Re-adds the sequence column to survey_questions table
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Restoring Sequence Column';
    RAISE NOTICE '========================================';

    -- Add sequence column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'survey_questions'
          AND column_name = 'sequence'
    ) THEN
        ALTER TABLE public.survey_questions
        ADD COLUMN sequence INTEGER;

        RAISE NOTICE 'Added sequence column to survey_questions';
    ELSE
        RAISE NOTICE 'Sequence column already exists';
    END IF;

    -- Update sequence values based on created_at order for each page
    WITH numbered_questions AS (
        SELECT
            id,
            ROW_NUMBER() OVER (PARTITION BY survey_page_id ORDER BY created_at) as seq
        FROM public.survey_questions
    )
    UPDATE public.survey_questions sq
    SET sequence = nq.seq
    FROM numbered_questions nq
    WHERE sq.id = nq.id
      AND (sq.sequence IS NULL OR sq.sequence != nq.seq);

    RAISE NOTICE 'Initialized sequence values based on created_at order';

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Sequence Column Restored!';
    RAISE NOTICE '========================================';

END $$;
