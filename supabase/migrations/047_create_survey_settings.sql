-- Create survey_settings table for storing system-wide configuration values
CREATE TABLE public.survey_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    persist_name VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT
);

-- Add comment
COMMENT ON TABLE public.survey_settings IS 'System-wide configuration values for energy calculations and survey defaults';

-- Create index on persist_name for fast lookups
CREATE INDEX idx_survey_settings_persist_name ON public.survey_settings(persist_name);

-- Enable RLS
ALTER TABLE public.survey_settings ENABLE ROW LEVEL SECURITY;

-- Create policy to allow read access to all authenticated users
CREATE POLICY "Allow read access to all authenticated users"
    ON public.survey_settings
    FOR SELECT
    TO authenticated
    USING (true);

-- Create policy to allow admin users to modify settings
CREATE POLICY "Allow admin users to modify settings"
    ON public.survey_settings
    FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin')
    WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Add trigger to update updated_at
CREATE TRIGGER update_survey_settings_updated_at
    BEFORE UPDATE ON public.survey_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
