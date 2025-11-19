-- ============================================================================
-- Migration: Update Attic Insulation Icon
-- Description: Updates the Attic Insulation investment icon to use custom icon
-- ============================================================================

-- Update the investment icon to use custom component
UPDATE public.investments
SET icon = 'custom:attic-insulation'
WHERE persist_name = 'roofInsulation';

-- Log completion
DO $$
BEGIN
  RAISE NOTICE 'Successfully updated Attic Insulation icon to custom:attic-insulation';
END $$;
