-- Mark supplementary tasks questions as special for "Egyéb kérdések" accordion
-- This applies to the "Falak" (Walls) page of "Homlokzati szigetelés" (Facade Insulation)

-- Update all questions from sequence 50 onwards (supplementary_tasks_title and all following questions)
-- on the Walls page to be marked as special questions
UPDATE survey_questions
SET is_special = true
WHERE survey_page_id = 'a6d908c1-699a-4e2a-afc8-43d050b92992' -- Falak page
  AND sequence >= 50; -- supplementary_tasks_title and all questions after it
