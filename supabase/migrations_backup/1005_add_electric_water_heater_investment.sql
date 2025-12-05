-- Add Electric Water Heater (Villanybojler) investment

INSERT INTO public.investments (
  name,
  name_translations,
  persist_name,
  icon,
  sequence,
  is_default,
  position
) VALUES (
  'Villanybojler',
  jsonb_build_object(
    'hu', 'Villanybojler',
    'en', 'Electric water heater'
  ),
  'electricWaterHeater',
  'i-lucide-droplets',
  10,
  false,
  jsonb_build_object('top', 50, 'right', 50)
);
