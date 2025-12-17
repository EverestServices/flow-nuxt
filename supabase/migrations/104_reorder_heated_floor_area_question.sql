-- Migration: Reorder "Ebből fűtött alapterület" question in Alapadatok page
-- Date: 2025-12-12
-- Description: Move "heated_floor_area" question to come immediately after "building_useful_floor_area"
-- Old position: sequence 32
-- New position: sequence 15 (right after building_useful_floor_area which is at 14)

-- Step 1: Shift all questions between sequence 15-31 down by 1 to make room
UPDATE survey_questions
SET sequence = sequence + 1
WHERE survey_page_id = '1ebc41b2-ea7a-4b52-8578-f41a659da782'
  AND sequence >= 15
  AND sequence < 32
  AND id != 'f923a636-7c4d-4769-b744-cd4623bf97f2'; -- Exclude heated_floor_area itself

-- Step 2: Move "heated_floor_area" to sequence 15 (right after building_useful_floor_area)
UPDATE survey_questions
SET sequence = 15
WHERE id = 'f923a636-7c4d-4769-b744-cd4623bf97f2'
  AND name = 'heated_floor_area';
