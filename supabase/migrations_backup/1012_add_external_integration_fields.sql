-- Migration: Add external integration fields to clients and surveys
-- Description: Adds OFP and EKR client/survey ID references for bidirectional sync
-- Date: 2025-11-06

-- ============================================================================
-- 1. MODIFY CLIENTS TABLE
-- ============================================================================

ALTER TABLE public.clients
ADD COLUMN IF NOT EXISTS ofp_client_id UUID,
ADD COLUMN IF NOT EXISTS ekr_client_id UUID;

-- ============================================================================
-- 2. MODIFY SURVEYS TABLE
-- ============================================================================

ALTER TABLE public.surveys
ADD COLUMN IF NOT EXISTS ofp_survey_id UUID,
ADD COLUMN IF NOT EXISTS ekr_survey_id UUID;

-- ============================================================================
-- 3. CREATE INDEXES
-- ============================================================================

-- Clients indexes
CREATE INDEX IF NOT EXISTS idx_clients_ofp_client_id
ON public.clients(ofp_client_id)
WHERE ofp_client_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_clients_ekr_client_id
ON public.clients(ekr_client_id)
WHERE ekr_client_id IS NOT NULL;

-- Surveys indexes
CREATE INDEX IF NOT EXISTS idx_surveys_ofp_survey_id
ON public.surveys(ofp_survey_id)
WHERE ofp_survey_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_surveys_ekr_survey_id
ON public.surveys(ekr_survey_id)
WHERE ekr_survey_id IS NOT NULL;

-- ============================================================================
-- 4. CREATE UNIQUE CONSTRAINTS
-- ============================================================================

-- Ensure one-to-one mapping: one OFP client = one Flow client
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ofp_unique
ON public.clients(ofp_client_id)
WHERE ofp_client_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ekr_unique
ON public.clients(ekr_client_id)
WHERE ekr_client_id IS NOT NULL;

-- Ensure one-to-one mapping: one OFP survey = one Flow survey
CREATE UNIQUE INDEX IF NOT EXISTS idx_surveys_ofp_unique
ON public.surveys(ofp_survey_id)
WHERE ofp_survey_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_surveys_ekr_unique
ON public.surveys(ekr_survey_id)
WHERE ekr_survey_id IS NOT NULL;

-- ============================================================================
-- 5. ADD COMMENTS
-- ============================================================================

COMMENT ON COLUMN public.clients.ofp_client_id IS 'Reference to OFP (Sherpa) Client UUID. Used for bidirectional sync.';
COMMENT ON COLUMN public.clients.ekr_client_id IS 'Reference to EKR Client UUID. Used for bidirectional sync.';
COMMENT ON COLUMN public.surveys.ofp_survey_id IS 'Reference to OFP Survey UUID (if survey originated from OFP)';
COMMENT ON COLUMN public.surveys.ekr_survey_id IS 'Reference to EKR Survey UUID (if survey originated from EKR)';
