-- Migration: Add OFP API key storage to user_profiles
-- Description: Stores the OFP API key for Sherpa integration (encrypted at rest by Supabase)
-- Date: 2025-11-19

-- ============================================================================
-- 1. ADD OFP API KEY COLUMN
-- ============================================================================

ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS ofp_api_key TEXT;

-- ============================================================================
-- 2. ADD COMMENT
-- ============================================================================

COMMENT ON COLUMN public.user_profiles.ofp_api_key IS 'OFP (Sherpa) API key for integration. User must set this manually from their OFP profile.';

-- ============================================================================
-- 3. CREATE FUNCTION TO UPDATE OFP API KEY
-- ============================================================================

CREATE OR REPLACE FUNCTION update_ofp_api_key(p_api_key TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE user_profiles
    SET
        ofp_api_key = p_api_key,
        updated_at = NOW()
    WHERE user_id = auth.uid();

    SELECT json_build_object(
        'success', true,
        'message', 'OFP API key updated successfully'
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION update_ofp_api_key TO authenticated;
