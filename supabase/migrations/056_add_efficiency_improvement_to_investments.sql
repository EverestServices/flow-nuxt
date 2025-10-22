-- Add energy_efficiency_improvement column to investments table
ALTER TABLE public.investments
ADD COLUMN energy_efficiency_improvement DECIMAL(5, 4) DEFAULT 0;

-- Add comment
COMMENT ON COLUMN public.investments.energy_efficiency_improvement IS 'Energy efficiency improvement percentage (0-1 scale, e.g., 0.25 = 25%)';

-- Update existing investments with energy efficiency improvement values
UPDATE public.investments SET energy_efficiency_improvement = 0.25 WHERE persist_name = 'solarPanelBattery';
UPDATE public.investments SET energy_efficiency_improvement = 0.20 WHERE persist_name = 'solarPanel';
UPDATE public.investments SET energy_efficiency_improvement = 0.15 WHERE persist_name = 'heatPump';
UPDATE public.investments SET energy_efficiency_improvement = 0.10 WHERE persist_name = 'facadeInsulation';
UPDATE public.investments SET energy_efficiency_improvement = 0.08 WHERE persist_name = 'roofInsulation';
UPDATE public.investments SET energy_efficiency_improvement = 0.05 WHERE persist_name = 'windows';
UPDATE public.investments SET energy_efficiency_improvement = 0 WHERE persist_name IN ('airConditioner', 'battery', 'carCharger');
