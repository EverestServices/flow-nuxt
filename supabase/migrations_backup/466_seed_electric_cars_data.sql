-- Migration: Seed electric_cars data
-- Description: Production data for electric_cars table
-- Dependencies: 434_create_electric_cars_table.sql

INSERT INTO "public"."electric_cars" ("id", "created_at", "updated_at", "survey_id", "annual_mileage", "status") VALUES
	('fda63fc2-726f-4e35-a992-5799dcd6bdd8', '2025-10-22 10:26:51.579432+00', '2025-10-22 10:26:51.579432+00', 'cb5d6557-b143-496d-a732-f931f9f82f83', 20000, 'existing'),
	('589b5414-4cbb-4ea0-8c5a-4c08b001c1a2', '2025-10-22 10:26:51.579432+00', '2025-10-22 10:26:51.579432+00', 'cb5d6557-b143-496d-a732-f931f9f82f83', 10000, 'planned'),
	('09808839-b73c-486d-a1a4-e15a806e4e61', '2025-10-28 11:13:26.741669+00', '2025-10-28 11:13:26.741669+00', '2c4876d2-ad5a-4537-9266-d6d7f1179eb3', NULL, 'planned'),
	('8846e86c-e6b9-4a58-b3f0-31435404931a', '2025-11-06 08:47:22.12476+00', '2025-11-06 08:47:22.12476+00', 'df6825d7-d7d9-4d2b-af6c-d180c922a0e0', 10000, 'planned'),
	('dfbc86f2-c983-4528-b07d-ff758b04a23e', '2025-11-14 14:58:05.658776+00', '2025-11-14 14:58:05.658776+00', '39171bf8-0992-4a81-8088-f9ba8bde2353', 20000, 'planned'),
	('c8c5f9dd-7429-41b3-8eda-7366eb6ce1d8', '2025-11-14 14:58:05.658776+00', '2025-11-14 14:58:05.658776+00', '39171bf8-0992-4a81-8088-f9ba8bde2353', 10000, 'planned');
