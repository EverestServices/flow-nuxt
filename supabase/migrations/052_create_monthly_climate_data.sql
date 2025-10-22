-- Create monthly_climate_data table for storing regional climate statistics
CREATE TABLE public.monthly_climate_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    region VARCHAR(100) DEFAULT 'hungary',
    solar_irradiance DECIMAL(10, 2) NOT NULL, -- kWh/m²/month
    heating_degree_days DECIMAL(10, 2) NOT NULL, -- heating degree days per month
    UNIQUE(month, region)
);

-- Add comments
COMMENT ON TABLE public.monthly_climate_data IS 'Monthly climate statistics for energy calculations (solar irradiance, heating degree days)';
COMMENT ON COLUMN public.monthly_climate_data.month IS 'Month number (1-12)';
COMMENT ON COLUMN public.monthly_climate_data.region IS 'Geographic region identifier (default: hungary)';
COMMENT ON COLUMN public.monthly_climate_data.solar_irradiance IS 'Average solar irradiance for the month (kWh/m²/month)';
COMMENT ON COLUMN public.monthly_climate_data.heating_degree_days IS 'Heating degree days for the month';

-- Create index for fast lookups
CREATE INDEX idx_monthly_climate_data_region_month ON public.monthly_climate_data(region, month);

-- Enable RLS
ALTER TABLE public.monthly_climate_data ENABLE ROW LEVEL SECURITY;

-- Create policy to allow read access to all authenticated users
CREATE POLICY "Allow read access to all authenticated users"
    ON public.monthly_climate_data
    FOR SELECT
    TO authenticated
    USING (true);

-- Add trigger to update updated_at
CREATE TRIGGER update_monthly_climate_data_updated_at
    BEFORE UPDATE ON public.monthly_climate_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
