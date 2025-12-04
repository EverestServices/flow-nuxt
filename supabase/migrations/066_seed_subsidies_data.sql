-- Migration: Seed subsidies data
-- Description: Insert reference/catalog data for subsidies
-- Dependencies: 403_create_subsidies_table.sql

INSERT INTO "public"."subsidies" ("id", "created_at", "updated_at", "name", "description", "target_group", "discount_type", "discount_value", "sequence") VALUES
	('6cde5b10-4447-45c7-92a9-ca41271de1ad', '2025-10-21 16:28:38.792947+00', '2025-10-21 16:28:38.792947+00', 'Otthonfelújítási Támogatás', 'Az otthon energetikai korszerűsítésére igénybe vehető támogatás. A támogatás keretében napelem rendszer telepítése, szigetelés, nyílászáró csere és egyéb energetikai fejlesztések is támogathatók.', 'Gyermeket nevelő családok', 'percentage', 50, 1),
	('0fdb5b4f-0eae-4592-9bd7-c8d1a8171efa', '2025-10-21 16:28:38.792947+00', '2025-10-21 16:28:38.792947+00', 'Napelem Pályázat', 'Lakossági napelem és akkumulátor telepítésének támogatása. A támogatás fix összegű, amely csökkentheti a napelemes rendszer telepítésének költségeit.', 'Magyar háztartások', 'fixed', 2800000, 2),
	('b2296aec-98dd-4751-a6f1-53be0ac34a3a', '2025-10-21 16:28:38.792947+00', '2025-10-21 16:28:38.792947+00', 'Energetikai Korszerűsítési Program', 'Komplex energetikai korszerűsítési támogatás régi építésű lakóingatlanok tulajdonosai számára. A támogatás felhasználható szigetelésre, fűtéskorszerűsítésre, nyílászáró cserére és megújuló energia rendszerek telepítésére.', 'Régi építésű ingatlanok tulajdonosai', 'percentage', 35, 3);
