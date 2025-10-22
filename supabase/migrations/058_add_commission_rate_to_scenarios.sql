-- Add commission_rate column to scenarios table
-- Stores the commission percentage as decimal (0.12 = 12%)
-- Default is 0.12 (12% - red/piros)

ALTER TABLE public.scenarios
ADD COLUMN commission_rate DECIMAL(5, 4) DEFAULT 0.12;

COMMENT ON COLUMN public.scenarios.commission_rate IS 'Commission rate for pricing calculations (0-1). Default 0.12 = 12% (red)';
