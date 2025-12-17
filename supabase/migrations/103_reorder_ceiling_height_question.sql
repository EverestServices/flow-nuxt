-- Migration: Reorder "Épület átlagos belmagassága" question in Alapadatok page
-- Date: 2025-12-12
-- Description: Move "avg_ceiling_height" question to come immediately after "building_useful_floor_area"
-- Old position: sequence 33
-- New position: sequence 15 (right after building_useful_floor_area which is at 14)

-- Step 1: Shift all questions between sequence 15-32 down by 1 to make room
UPDATE survey_questions
SET sequence = sequence + 1
WHERE survey_page_id = '1ebc41b2-ea7a-4b52-8578-f41a659da782'
  AND sequence >= 15
  AND sequence < 33
  AND id != 'c3c6dbf4-aee2-4cbb-a98d-866ec4746280'; -- Exclude avg_ceiling_height itself

-- Step 2: Move "avg_ceiling_height" to sequence 15 (right after building_useful_floor_area)
UPDATE survey_questions
SET sequence = 15
WHERE id = 'c3c6dbf4-aee2-4cbb-a98d-866ec4746280'
  AND name = 'avg_ceiling_height';
