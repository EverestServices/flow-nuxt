-- Add consumption_profiles column to surveys table
ALTER TABLE public.surveys
ADD COLUMN IF NOT EXISTS consumption_profiles TEXT[];

COMMENT ON COLUMN public.surveys.consumption_profiles IS 'Array of selected consumption profiles (work_from_home, traditional_hours, shift_work, retired_stay_at_home, young_family)';
