-- Seed monthly climate data for Hungary
-- Based on typical Hungarian climate statistics

INSERT INTO public.monthly_climate_data (month, region, solar_irradiance, heating_degree_days) VALUES
-- January: Low solar, high heating demand
(1, 'hungary', 36, 608),

-- February: Still winter, slightly more sun
(2, 'hungary', 60, 512),

-- March: Spring begins, heating demand decreases
(3, 'hungary', 96, 416),

-- April: More sun, less heating
(4, 'hungary', 120, 256),

-- May: Late spring, minimal heating
(5, 'hungary', 156, 96),

-- June: Peak solar season, no heating
(6, 'hungary', 168, 0),

-- July: Peak solar season, no heating
(7, 'hungary', 168, 0),

-- August: Still high solar, no heating
(8, 'hungary', 144, 0),

-- September: Autumn begins, minimal heating
(9, 'hungary', 108, 64),

-- October: Solar decreases, heating starts
(10, 'hungary', 72, 224),

-- November: Low solar, significant heating
(11, 'hungary', 36, 384),

-- December: Lowest solar, highest heating demand
(12, 'hungary', 36, 640)

ON CONFLICT (month, region) DO NOTHING;
