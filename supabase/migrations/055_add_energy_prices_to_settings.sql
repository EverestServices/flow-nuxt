-- Add energy prices to survey_settings
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('electricity_price', '70', 'Electricity price (HUF/kWh)'),
('gas_price', '100', 'Natural gas price (HUF/m³)')
ON CONFLICT (persist_name) DO NOTHING;
