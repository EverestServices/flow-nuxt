-- ============================================================================
-- Migration: Update survey times with specific hours
-- Description: Adds specific times to survey dates (2 surveys per day)
-- ============================================================================

-- ============================================================================
-- 1. UPDATE SURVEY TIMES WITH DYNAMIC LOGIC
-- ============================================================================

-- This will update each survey's time based on the row number within each date
-- First survey of the day gets 09:30, second gets 14:15
WITH ranked_surveys AS (
    SELECT
        id,
        at::date as survey_date,
        ROW_NUMBER() OVER (PARTITION BY at::date ORDER BY client_id) as day_rank
    FROM public.surveys
    WHERE company_id = 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44'
)
UPDATE public.surveys
SET at = CASE
    WHEN ranked_surveys.day_rank = 1 THEN
        (ranked_surveys.survey_date + TIME '09:30:00')::timestamptz
    ELSE
        (ranked_surveys.survey_date + TIME '14:15:00')::timestamptz
END
FROM ranked_surveys
WHERE surveys.id = ranked_surveys.id;