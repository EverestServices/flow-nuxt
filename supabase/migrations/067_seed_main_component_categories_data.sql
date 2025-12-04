-- Migration: Seed main_component_categories data
-- Description: Insert reference/catalog data for main_component_categories
-- Dependencies: 404_create_main_component_categories_table.sql

INSERT INTO "public"."main_component_categories" ("id", "created_at", "updated_at", "persist_name", "sequence", "name_translations", "visibility") VALUES
	('e714bb83-12a4-4fc6-a87f-217cffe19609', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'panel', 1, '{"en": "Solar Panels", "hu": "Napelem panelek"}', NULL),
	('1d1fd04b-0a81-4b7a-9109-21ea5bc884f3', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'inverter', 2, '{"en": "Inverter", "hu": "Inverter"}', NULL),
	('d34eb35d-cb23-43bb-aacf-d1d59af82b2c', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'mounting', 4, '{"en": "Mounting System", "hu": "Tartószerkezet"}', NULL),
	('518529ec-d357-4b0d-8c51-56f539c5f012', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'regulator', 5, '{"en": "Charge Regulator", "hu": "Töltésszabályozó"}', NULL),
	('e896a4cc-734a-4533-9812-c25206c984c5', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'ac_surge_protector', 6, '{"en": "AC Surge Protector", "hu": "AC túlfeszültségvédő"}', NULL),
	('9c110965-4dc8-4e5c-9035-f7bdcfe7c233', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'dc_surge_protector', 7, '{"en": "DC Surge Protector", "hu": "DC túlfeszültségvédő"}', NULL),
	('507bcf19-d4a8-4fe4-92ed-937018d4fa10', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'optimizer', 8, '{"en": "Power Optimizer", "hu": "Teljesítményoptimalizáló"}', NULL),
	('a17e0166-dce1-4176-a696-841d2a0c43b0', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'rapid_shutdown', 9, '{"en": "Rapid Shutdown", "hu": "Gyorsleállító"}', NULL),
	('dd28001f-a5d7-43a0-9950-aea17222efcd', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'battery', 3, '{"en": "Battery", "hu": "Akkumulátor"}', NULL),
	('bc996723-c4fa-400e-8590-26d80ffc817b', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'heatpump', 10, '{"en": "Heat Pump", "hu": "Hőszivattyú"}', NULL),
	('b8444279-dcbd-401a-866a-0c8a083993c1', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'accessory', 11, '{"en": "Accessories", "hu": "Kiegészítők"}', NULL),
	('a216f03a-02df-48c5-ba65-277d1f7d065b', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'window', 16, '{"en": "Windows", "hu": "Ablak"}', NULL),
	('67b98b2d-b149-40c0-8f0b-4ae00d960ff8', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'airconditioner', 17, '{"en": "Air Conditioner", "hu": "Légkondicionáló"}', NULL),
	('832c0975-38a5-4a2b-a15e-68f02bb282c1', '2025-10-21 13:55:02.616181+00', '2025-10-29 10:24:21.12251+00', 'charger', 18, '{"en": "EV Charger", "hu": "Töltőállomás"}', NULL),
	('d2dab685-30e3-4ea8-b14a-72ac3b899ca0', '2025-11-19 17:13:49.480142+00', '2025-11-19 17:13:49.480142+00', 'facade_system', NULL, '{"en": "Facade System", "hu": "Homlokzati rendszer"}', NULL),
	('820f66ab-50f2-417a-a9c4-8cc9c582ae6b', '2025-11-19 17:13:49.480142+00', '2025-11-19 17:13:49.480142+00', 'roof_system', NULL, '{"en": "Roof System", "hu": "Tetőszigetelő rendszer"}', NULL),
	('57505ddc-4260-4a29-8f88-e6ba20f00574', '2025-10-21 13:55:02.616181+00', '2025-11-20 15:47:08.250035+00', 'insulation', 12, '{"en": "Insulation", "hu": "Szigetelés"}', '{"ofp_survey": {"roofInsulation": false, "facadeInsulation": false}}'),
	('2749cf9c-6e42-448e-a940-aa44396542cb', '2025-10-21 13:55:02.616181+00', '2025-11-20 15:47:08.250035+00', 'adhesive', 13, '{"en": "Adhesive", "hu": "Ragasztó"}', '{"ofp_survey": {"facadeInsulation": false}}'),
	('cfd778eb-4d5b-4113-8217-ad20c3887d7f', '2025-10-21 13:55:02.616181+00', '2025-11-20 15:47:08.250035+00', 'plaster', 14, '{"en": "Plaster", "hu": "Vakolat"}', '{"ofp_survey": {"facadeInsulation": false}}'),
	('d9c19723-7b30-4a7c-ba3e-5a032e7ee84f', '2025-10-21 13:55:02.616181+00', '2025-11-20 15:47:08.250035+00', 'vapor_barrier', 15, '{"en": "Vapor Barrier", "hu": "Párazáró"}', '{"ofp_survey": {"roofInsulation": false}}');
