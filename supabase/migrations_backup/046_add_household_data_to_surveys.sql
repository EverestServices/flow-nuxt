-- Add household_data JSONB column to surveys table
ALTER TABLE public.surveys
ADD COLUMN household_data JSONB;

-- Add comment
COMMENT ON COLUMN public.surveys.household_data IS 'Household data including solar panel configuration and consumption profiles (modified by user in Consultation page)';
