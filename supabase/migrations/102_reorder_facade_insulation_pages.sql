-- Migration: Reorder Facade Insulation survey pages
-- Date: 2025-12-12
-- Description: Swap order of "Homlokzati szigetelés adatok" and "Falak" pages
-- New order:
--   1. Homlokzati szigetelés adatok (sequence: 0)
--   2. Falak (sequence: 1)
--   3. Nyílászárók (sequence: 2)

-- Update "Homlokzati szigetelés adatok" page to sequence 0 (first)
UPDATE survey_pages
SET sequence = 0
WHERE id = '4e7fe935-db78-47ef-b724-622050cfa320'
  AND name = 'Homlokzati szigetelés adatok';

-- Update "Falak" page to sequence 1 (second)
UPDATE survey_pages
SET sequence = 1
WHERE id = 'a6d908c1-699a-4e2a-afc8-43d050b92992'
  AND name = 'Falak';

-- Update "Nyílászárók" page to sequence 2 (third) to avoid conflicts
UPDATE survey_pages
SET sequence = 2
WHERE id = '5b0e40a4-a3e5-4cea-a268-77628fa9baab'
  AND name = 'Nyílászárók';
