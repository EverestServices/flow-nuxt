-- Migration: Reorder "Megegyezik a hasznos alapterülettel" question in Alapadatok page
-- Date: 2025-12-12
-- Description: Move "heated_area_matches_useful_area" question to come immediately after "heated_floor_area"
--              and shift all subsequent questions by +2 instead of +1 to leave extra space
-- Old position: sequence 33
-- New position: sequence 16 (right after heated_floor_area which is at 15)

-- Step 1: Shift all questions from sequence 16-32 up by +2 to make extra room
UPDATE survey_questions
SET sequence = sequence + 2
WHERE survey_page_id = '1ebc41b2-ea7a-4b52-8578-f41a659da782'
  AND sequence >= 16
  AND sequence < 33
  AND id != '7a2488db-0164-4d7c-8a2a-b3f39f473bca'; -- Exclude heated_area_matches_useful_area itself

-- Step 2: Move "heated_area_matches_useful_area" to sequence 16 (right after heated_floor_area)
UPDATE survey_questions
SET sequence = 16
WHERE id = '7a2488db-0164-4d7c-8a2a-b3f39f473bca'
  AND name = 'heated_area_matches_useful_area';
