-- ============================================================================
-- Migration: Add first_signed_at to Contracts Table
-- Description: Adds a timestamp column to track when a contract was first signed
-- ============================================================================

-- Add first_signed_at column to contracts table
ALTER TABLE public.contracts
ADD COLUMN IF NOT EXISTS first_signed_at TIMESTAMPTZ;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_contracts_first_signed_at ON public.contracts(first_signed_at);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
