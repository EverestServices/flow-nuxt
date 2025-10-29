-- Add icon and sequence columns to heavy_consumers table
ALTER TABLE public.heavy_consumers
ADD COLUMN icon VARCHAR(50),
ADD COLUMN sequence INTEGER;

-- Create index for sequence ordering
CREATE INDEX idx_heavy_consumers_sequence ON public.heavy_consumers(sequence);

-- Add comments
COMMENT ON COLUMN public.heavy_consumers.icon IS 'Lucide icon name for the heavy consumer';
COMMENT ON COLUMN public.heavy_consumers.sequence IS 'Display order sequence';

-- Update existing records with icon and sequence values
UPDATE public.heavy_consumers SET icon = 'i-lucide-flame', sequence = 1 WHERE name = 'sauna';
UPDATE public.heavy_consumers SET icon = 'i-lucide-droplet', sequence = 2 WHERE name = 'jacuzzi';
UPDATE public.heavy_consumers SET icon = 'i-lucide-thermometer', sequence = 3 WHERE name = 'poolHeating';
UPDATE public.heavy_consumers SET icon = 'i-lucide-cpu', sequence = 4 WHERE name = 'cryptoMining';
UPDATE public.heavy_consumers SET icon = 'i-lucide-wind', sequence = 5 WHERE name = 'heatPump';
UPDATE public.heavy_consumers SET icon = 'i-lucide-zap', sequence = 6 WHERE name = 'electricHeating';
