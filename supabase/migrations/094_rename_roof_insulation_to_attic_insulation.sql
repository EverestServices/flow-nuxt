-- ============================================================================
-- Migration: Rename Roof Insulation to Attic Insulation
-- Description: Updates the investment name and translations from
--              "Roof Insulation/Tető szigetelés" to "Attic Insulation/Padlásfödém szigetelés"
-- ============================================================================

-- Update the investment name and translations
UPDATE public.investments
SET
  name = 'Attic Insulation',
  name_translations = jsonb_build_object(
    'hu', 'Padlásfödém szigetelés',
    'en', 'Attic Insulation'
  )
WHERE persist_name = 'roofInsulation';

-- Log completion
DO $$
BEGIN
  RAISE NOTICE 'Successfully renamed Roof Insulation to Attic Insulation';
END $$;
