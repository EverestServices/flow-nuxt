-- ============================================================================
-- Migration: Add first_sent_at to Contracts Table
-- Description: Adds a timestamp column to track when a contract was first sent
-- ============================================================================

-- Add first_sent_at column to contracts table
ALTER TABLE public.contracts
ADD COLUMN IF NOT EXISTS first_sent_at TIMESTAMPTZ;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_contracts_first_sent_at ON public.contracts(first_sent_at);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
