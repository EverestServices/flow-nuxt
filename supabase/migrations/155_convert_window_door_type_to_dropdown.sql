-- ============================================================================
-- Migration: Convert window_door_type to dropdown with 9 options
-- Description: Updates "Nyílászárók típusa" from text input to dropdown
--              with 9 predefined material and layer options
--
-- Options:
--   - Fa (Wood): 1, 2, 3 rétegű
--   - Műanyag (Plastic): 1, 2, 3 rétegű
--   - Fém (Metal): 1, 2, 3 rétegű
-- ============================================================================

-- Update window_door_type question to dropdown type with options
UPDATE public.survey_questions
SET
  type = 'dropdown',
  options_translations = jsonb_build_array(
    jsonb_build_object(
      'value', 'Fa, 1 rétegű',
      'label', jsonb_build_object('hu', 'Fa, 1 rétegű', 'en', 'Wood, 1 layer')
    ),
    jsonb_build_object(
      'value', 'Fa, 2 rétegű',
      'label', jsonb_build_object('hu', 'Fa, 2 rétegű', 'en', 'Wood, 2 layers')
    ),
    jsonb_build_object(
      'value', 'Fa, 3 rétegű',
      'label', jsonb_build_object('hu', 'Fa, 3 rétegű', 'en', 'Wood, 3 layers')
    ),
    jsonb_build_object(
      'value', 'Műanyag, 1 rétegű',
      'label', jsonb_build_object('hu', 'Műanyag, 1 rétegű', 'en', 'Plastic, 1 layer')
    ),
    jsonb_build_object(
      'value', 'Műanyag, 2 rétegű',
      'label', jsonb_build_object('hu', 'Műanyag, 2 rétegű', 'en', 'Plastic, 2 layers')
    ),
    jsonb_build_object(
      'value', 'Műanyag, 3 rétegű',
      'label', jsonb_build_object('hu', 'Műanyag, 3 rétegű', 'en', 'Plastic, 3 layers')
    ),
    jsonb_build_object(
      'value', 'Fém, 1 rétegű',
      'label', jsonb_build_object('hu', 'Fém, 1 rétegű', 'en', 'Metal, 1 layer')
    ),
    jsonb_build_object(
      'value', 'Fém, 2 rétegű',
      'label', jsonb_build_object('hu', 'Fém, 2 rétegű', 'en', 'Metal, 2 layers')
    ),
    jsonb_build_object(
      'value', 'Fém, 3 rétegű',
      'label', jsonb_build_object('hu', 'Fém, 3 rétegű', 'en', 'Metal, 3 layers')
    )
  )
WHERE name = 'window_door_type';

-- Summary
DO $$
DECLARE
    updated_count INTEGER;
    option_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count
    FROM public.survey_questions
    WHERE name = 'window_door_type'
      AND type = 'dropdown';

    SELECT jsonb_array_length(options_translations) INTO option_count
    FROM public.survey_questions
    WHERE name = 'window_door_type'
    LIMIT 1;

    RAISE NOTICE '✅ Successfully converted window_door_type to dropdown:';
    RAISE NOTICE '   - % question(s) updated', updated_count;
    RAISE NOTICE '   - % options available', option_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Available options:';
    RAISE NOTICE '   Fa: 1, 2, 3 rétegű';
    RAISE NOTICE '   Műanyag: 1, 2, 3 rétegű';
    RAISE NOTICE '   Fém: 1, 2, 3 rétegű';
END $$;
