-- Migration: Seed discounts data
-- Description: Insert reference/catalog data for discounts
-- Dependencies: 402_create_discounts_table.sql

INSERT INTO "public"."discounts" ("id", "persist_name", "name", "description", "discount_type", "value", "created_at", "updated_at") VALUES
	('3d874b4c-0d70-42a6-9f0f-5318c3de5997', 'autumn-2025', 'Őszi kedvezmény 2025', 'Elérhető minden ügyfél számára 2025 októberétől novemberéig terjedő időszakban.', 'fixed', 150000.00, '2025-10-24 10:07:12.49567+00', '2025-10-24 10:07:12.49567+00'),
	('370631d0-70c7-42b8-9c53-8a0775afac2b', 'winter-2025-2026', 'Téli kedvezmény 2025/2026', 'Elérhető minden ügyfél számára 2025 decemberétől 2026 februárjáig terjedő időszakban.', 'percentage', 3.00, '2025-10-24 10:07:12.49567+00', '2025-10-24 10:07:12.49567+00'),
	('559c386e-cc1c-4def-b785-69a9a09e761f', 'battery-free', 'Akkumulátor ingyen', 'Napelem + Akkumulátor rendszer vásárlása esetén az akkumulátor ára ingyenes. A kedvezmény automatikusan kiszámításra kerül.', 'calculated', 0.00, '2025-10-24 10:07:12.49567+00', '2025-10-24 10:07:12.49567+00'),
	('774e73ec-c389-47c3-bed7-a46e3c5f05af', 'third-panel-free', 'Harmadik panel ingyen', 'Minden harmadik napelem panel ingyenes. A kedvezmény automatikusan kiszámításra kerül a kiválasztott panelek száma alapján.', 'calculated', 0.00, '2025-10-24 10:07:12.49567+00', '2025-10-24 10:07:12.49567+00');
