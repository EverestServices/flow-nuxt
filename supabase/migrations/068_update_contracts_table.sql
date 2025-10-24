-- ============================================================================
-- Migration: Update Contracts Table
-- Description: Adds columns for contract management and data storage
-- ============================================================================

-- Add new columns to contracts table
ALTER TABLE public.contracts
ADD COLUMN IF NOT EXISTS name VARCHAR(255) NOT NULL DEFAULT 'Contract 1',
ADD COLUMN IF NOT EXISTS scenario_id UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS survey_id UUID REFERENCES public.surveys(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS contract_mode VARCHAR(20) NOT NULL DEFAULT 'offer',
ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'draft',
ADD COLUMN IF NOT EXISTS commission_rate DECIMAL(5, 4) NOT NULL DEFAULT 0.12,
ADD COLUMN IF NOT EXISTS vat INTEGER NOT NULL DEFAULT 27,
ADD COLUMN IF NOT EXISTS total_price DECIMAL(12, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS roof_configuration JSONB,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add check constraints for enum-like columns
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'contracts_contract_mode_check'
  ) THEN
    ALTER TABLE public.contracts
    ADD CONSTRAINT contracts_contract_mode_check
    CHECK (contract_mode IN ('offer', 'contract'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'contracts_status_check'
  ) THEN
    ALTER TABLE public.contracts
    ADD CONSTRAINT contracts_status_check
    CHECK (status IN ('draft', 'sent', 'accepted', 'rejected'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'contracts_vat_check'
  ) THEN
    ALTER TABLE public.contracts
    ADD CONSTRAINT contracts_vat_check
    CHECK (vat IN (0, 5, 12, 15, 21, 27));
  END IF;
END $$;

-- Create indexes for foreign keys
CREATE INDEX IF NOT EXISTS idx_contracts_scenario_id ON public.contracts(scenario_id);
CREATE INDEX IF NOT EXISTS idx_contracts_survey_id ON public.contracts(survey_id);
CREATE INDEX IF NOT EXISTS idx_contracts_contract_mode ON public.contracts(contract_mode);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.contracts(status);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
