-- Remove consultation_view_mode column from surveys table
-- This column was used to toggle between 'scenarios' and 'independent' modes,
-- but Independent Investments functionality has been removed.

ALTER TABLE public.surveys
DROP COLUMN IF EXISTS consultation_view_mode;
