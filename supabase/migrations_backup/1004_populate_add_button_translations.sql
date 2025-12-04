-- Populate add_button_translations for survey_pages based on type

-- Walls (Falfelület hozzáadása / Add wall surface)
UPDATE public.survey_pages
SET add_button_translations = jsonb_build_object(
  'hu', 'Falfelület hozzáadása',
  'en', 'Add wall surface'
)
WHERE type = 'walls' AND allow_multiple = true;

-- Rooms (Helyiség hozzáadása / Add room)
UPDATE public.survey_pages
SET add_button_translations = jsonb_build_object(
  'hu', 'Helyiség hozzáadása',
  'en', 'Add room'
)
WHERE type = 'rooms' AND allow_multiple = true;

-- Windows/Openings (Nyílászáró hozzáadása / Add window or door)
UPDATE public.survey_pages
SET add_button_translations = jsonb_build_object(
  'hu', 'Nyílászáró hozzáadása',
  'en', 'Add window or door'
)
WHERE type IN ('current_windows', 'openings', 'windows') AND allow_multiple = true;

-- Radiators (Radiátor hozzáadása / Add radiator)
UPDATE public.survey_pages
SET add_button_translations = jsonb_build_object(
  'hu', 'Radiátor hozzáadása',
  'en', 'Add radiator'
)
WHERE type = 'radiators' AND allow_multiple = true;

-- Roof (Tető hozzáadása / Add roof)
UPDATE public.survey_pages
SET add_button_translations = jsonb_build_object(
  'hu', 'Tető hozzáadása',
  'en', 'Add roof'
)
WHERE type = 'roof' AND allow_multiple = true;
