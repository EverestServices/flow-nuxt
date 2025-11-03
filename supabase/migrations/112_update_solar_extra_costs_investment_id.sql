-- Update existing extra costs to link them to Solar Panel investment
-- These are the extra costs that have a category but no investment_id yet

DO $$
DECLARE
  solar_panel_id UUID;
BEGIN
  -- Get the Solar Panel investment ID
  SELECT id INTO solar_panel_id
  FROM public.investments
  WHERE persist_name = 'solarPanel'
  LIMIT 1;

  -- Update all extra costs that have a category but no investment_id
  -- These are assumed to be solar panel related extra costs
  UPDATE public.extra_costs
  SET investment_id = solar_panel_id
  WHERE investment_id IS NULL
    AND category IS NOT NULL;

  RAISE NOTICE 'Updated solar panel extra costs with investment_id: %', solar_panel_id;
END $$;
