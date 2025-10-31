-- Add add_button_translations column to survey_pages table
-- This allows custom translations for "Add" buttons on allow_multiple pages

ALTER TABLE public.survey_pages
ADD COLUMN add_button_translations JSONB DEFAULT NULL;

COMMENT ON COLUMN public.survey_pages.add_button_translations IS 'Custom translations for Add button label on allow_multiple pages. Format: {"en": "Add window", "hu": "Ablak hozzáadása"}. Falls back to default "{name} hozzáadása" pattern when null.';
