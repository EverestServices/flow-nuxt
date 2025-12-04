-- Migration: Seed investments data
-- Description: Insert catalog/reference data for investments
-- Dependencies: 412_create_investments_table.sql

INSERT INTO "public"."investments" ("id", "created_at", "updated_at", "name", "icon", "position", "sequence", "persist_name", "energy_efficiency_improvement", "name_translations", "is_default") VALUES
	('ac8fed60-7173-44bb-8123-2a12e6a06c7a', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Solar Panel', 'i-lucide-sun', '{"top": 150, "right": 300}', 1, 'solarPanel', 0.2000, '{"en": "Solar Panel", "hu": "Napelem"}', false),
	('50311041-20e9-4056-b205-e29aba36e9d4', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Solar Panel + Battery', 'i-lucide-battery-charging', '{"top": 150, "right": 250}', 2, 'solarPanelBattery', 0.2500, '{"en": "Solar Panel + Battery", "hu": "Napelem + Akkumulátor"}', false),
	('d72a2289-6de0-48c8-8a4e-df340968840f', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Heat Pump', 'i-lucide-thermometer', '{"top": 200, "right": 300}', 3, 'heatPump', 0.1500, '{"en": "Heat Pump", "hu": "Hőszivattyú"}', false),
	('6bf96162-cc5c-46e3-85f2-b4e3f5195344', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Facade Insulation', 'i-lucide-home', '{"top": 250, "right": 100}', 4, 'facadeInsulation', 0.1000, '{"en": "Facade Insulation", "hu": "Homlokzati szigetelés"}', false),
	('080aae38-063c-4a71-ab6f-48458650ebd1', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Air Conditioner', 'i-lucide-wind', '{"top": 300, "right": 200}', 7, 'airConditioner', 0.0000, '{"en": "Air Conditioner", "hu": "Klíma"}', false),
	('24b2591b-35a1-480c-80c1-ab4203a58019', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Battery', 'i-lucide-battery', '{"top": 350, "right": 300}', 8, 'battery', 0.0000, '{"en": "Battery", "hu": "Akkumulátor"}', false),
	('48614213-37ad-48ea-bcce-b6b2e3d6fd2b', '2025-10-17 18:45:51.661906+00', '2025-10-28 10:01:10.577797+00', 'Car Charger', 'i-lucide-car', '{"top": 400, "right": 350}', 9, 'carCharger', 0.0000, '{"en": "Car Charger", "hu": "Autótöltő"}', false),
	('2d1c6d1b-451a-4f84-b678-e28013b4b593', '2025-10-29 17:18:06.660935+00', '2025-10-29 17:18:06.660935+00', 'Alapadatok', 'i-lucide-file-text', NULL, 0, 'basicData', 0.0000, '{"en": "Basic Data", "hu": "Alapadatok"}', true),
	('3f1b2824-8781-474b-85b4-1d07e6d7a50d', '2025-10-17 18:45:51.661906+00', '2025-10-30 12:14:23.916599+00', 'Attic Insulation', 'i-lucide-home', '{"top": 50, "right": 300}', 5, 'roofInsulation', 0.0800, '{"en": "Attic Insulation", "hu": "Padlásfödém szigetelés"}', false),
	('d92985b4-41d9-46e8-adb4-712d3a8d8603', '2025-10-31 11:38:36.097415+00', '2025-10-31 11:38:36.097415+00', 'Villanybojler', 'i-lucide-droplets', '{"top": 50, "right": 50}', 10, 'electricWaterHeater', 0.0000, '{"en": "Electric water heater", "hu": "Villanybojler"}', false),
	('f83279b2-2019-4ff8-95f4-990c4d02abe9', '2025-10-17 18:45:51.661906+00', '2025-11-10 13:25:08.176911+00', 'Windows', 'custom-window', '{"top": 200, "right": 100}', 6, 'windows', 0.0500, '{"en": "Windows", "hu": "Nyílászárók"}', false);
