-- Migration: Seed heavy_consumers data
-- Description: Insert reference data for heavy consumer appliances
-- Dependencies: 400_create_heavy_consumers_table.sql

INSERT INTO public.heavy_consumers (id, created_at, updated_at, name, icon, sequence, name_translations) VALUES
	('a1f57d67-720c-44c4-a774-21b54e73a180', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'sauna', 'i-lucide-flame', 1, '{"en": "sauna", "hu": "sauna"}'),
	('890d10a3-a8ad-41df-abba-8d24fc4f0b7f', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'jacuzzi', 'i-lucide-droplet', 2, '{"en": "jacuzzi", "hu": "jacuzzi"}'),
	('cb954e4e-a058-4505-ac72-6c59a20ffd12', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'poolHeating', 'i-lucide-thermometer', 3, '{"en": "poolHeating", "hu": "poolHeating"}'),
	('799830e9-0249-4326-af07-ec407104b401', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'cryptoMining', 'i-lucide-cpu', 4, '{"en": "cryptoMining", "hu": "cryptoMining"}'),
	('af400250-8e68-4634-9ef8-a1ea5216af4b', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'heatPump', 'i-lucide-wind', 5, '{"en": "heatPump", "hu": "heatPump"}'),
	('136ccbff-b360-48ee-918a-f9e5f2092a35', '2025-10-17 18:45:51.661906+00', '2025-10-27 18:58:32.098101+00', 'electricHeating', 'i-lucide-zap', 6, '{"en": "electricHeating", "hu": "electricHeating"}');
