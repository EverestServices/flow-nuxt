-- ============================================================================
-- Migration: Add birth_name and parcel_number to contracts table
-- Description: Adds fields for birth name and parcel number to support
--              Consultant Mode contract data requirements
-- ============================================================================

-- Add birth_name column (Születési név)
ALTER TABLE public.contracts
ADD COLUMN IF NOT EXISTS birth_name TEXT;

-- Add parcel_number column (Helyrajzi szám)
ALTER TABLE public.contracts
ADD COLUMN IF NOT EXISTS parcel_number TEXT;

-- Add comments for documentation
COMMENT ON COLUMN public.contracts.birth_name IS 'Birth name of the client (Születési név)';
COMMENT ON COLUMN public.contracts.parcel_number IS 'Parcel number of the property (Helyrajzi szám)';
