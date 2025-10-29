-- Add persist_name column to investments table
ALTER TABLE public.investments
ADD COLUMN persist_name VARCHAR(100) UNIQUE;

-- Add comment
COMMENT ON COLUMN public.investments.persist_name IS 'Unique identifier for investment type used in code (e.g., solarPanel, heatPump)';

-- Create index for fast lookups
CREATE INDEX idx_investments_persist_name ON public.investments(persist_name);

-- Update existing investments with persist_name values
-- Note: These values must match the investment names in the database

UPDATE public.investments
SET persist_name = 'solarPanel'
WHERE name = 'Solar Panel';

UPDATE public.investments
SET persist_name = 'solarPanelBattery'
WHERE name = 'Solar Panel + Battery';

UPDATE public.investments
SET persist_name = 'heatPump'
WHERE name = 'Heat Pump';

UPDATE public.investments
SET persist_name = 'facadeInsulation'
WHERE name = 'Facade Insulation';

UPDATE public.investments
SET persist_name = 'roofInsulation'
WHERE name = 'Roof Insulation';

UPDATE public.investments
SET persist_name = 'windows'
WHERE name = 'Windows';

UPDATE public.investments
SET persist_name = 'airConditioner'
WHERE name = 'Air Conditioner';

UPDATE public.investments
SET persist_name = 'battery'
WHERE name = 'Battery';

UPDATE public.investments
SET persist_name = 'carCharger'
WHERE name = 'Car Charger';
