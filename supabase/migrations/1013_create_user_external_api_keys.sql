-- Migration: Create user external API keys table
-- Description: Stores user-specific, non-expiring API keys for OFP/EKR authentication
-- Date: 2025-11-06

-- ============================================================================
-- 1. CREATE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_external_api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    external_system VARCHAR(20) NOT NULL CHECK (external_system IN ('OFP', 'EKR')),
    api_key_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    last_used_at TIMESTAMPTZ,
    CONSTRAINT unique_user_external_system UNIQUE(user_id, external_system)
);

-- ============================================================================
-- 2. CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_user_external_keys_user_id
ON public.user_external_api_keys(user_id);

CREATE INDEX IF NOT EXISTS idx_user_external_keys_system
ON public.user_external_api_keys(external_system);

CREATE INDEX IF NOT EXISTS idx_user_external_keys_hash
ON public.user_external_api_keys(api_key_hash)
WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_user_external_keys_active
ON public.user_external_api_keys(is_active)
WHERE is_active = TRUE;

-- ============================================================================
-- 3. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.user_external_api_keys ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. CREATE RLS POLICIES
-- ============================================================================

-- Users can view their own API keys
CREATE POLICY "Users can view their own API keys"
ON public.user_external_api_keys FOR SELECT
USING (user_id = auth.uid());

-- Users can insert their own API keys
CREATE POLICY "Users can insert their own API keys"
ON public.user_external_api_keys FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Users can update their own API keys
CREATE POLICY "Users can update their own API keys"
ON public.user_external_api_keys FOR UPDATE
USING (user_id = auth.uid());

-- Users can delete their own API keys
CREATE POLICY "Users can delete their own API keys"
ON public.user_external_api_keys FOR DELETE
USING (user_id = auth.uid());

-- ============================================================================
-- 5. CREATE UPDATED_AT TRIGGER
-- ============================================================================

CREATE TRIGGER update_user_external_api_keys_updated_at
    BEFORE UPDATE ON public.user_external_api_keys
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON public.user_external_api_keys TO authenticated;

-- ============================================================================
-- 7. ADD COMMENTS
-- ============================================================================

COMMENT ON TABLE public.user_external_api_keys IS 'User-specific API keys for external system authentication (OFP/EKR). Keys are stored as SHA-256 hashes.';
COMMENT ON COLUMN public.user_external_api_keys.user_id IS 'User who owns this API key';
COMMENT ON COLUMN public.user_external_api_keys.external_system IS 'External system this key is for (OFP or EKR)';
COMMENT ON COLUMN public.user_external_api_keys.api_key_hash IS 'SHA-256 hash of the API key (not the plain key)';
COMMENT ON COLUMN public.user_external_api_keys.is_active IS 'Whether this key is currently active and can be used';
COMMENT ON COLUMN public.user_external_api_keys.last_used_at IS 'Timestamp of last successful authentication with this key';
