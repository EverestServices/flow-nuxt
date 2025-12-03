-- Migration: Create external sync logs table
-- Description: Audit trail for all external system synchronization attempts
-- Date: 2025-11-06

-- ============================================================================
-- 1. CREATE ENUMS
-- ============================================================================

CREATE TYPE sync_direction AS ENUM ('incoming', 'outgoing');
CREATE TYPE sync_status AS ENUM ('pending', 'success', 'failed', 'partial');

-- ============================================================================
-- 2. CREATE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.external_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    external_system VARCHAR(20) NOT NULL CHECK (external_system IN ('OFP', 'EKR')),
    direction sync_direction NOT NULL,
    status sync_status NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    request_payload JSONB,
    response_payload JSONB,
    error_message TEXT,
    http_status_code INTEGER,
    duration_ms INTEGER,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- ============================================================================
-- 3. CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_sync_logs_system
ON public.external_sync_logs(external_system);

CREATE INDEX IF NOT EXISTS idx_sync_logs_direction
ON public.external_sync_logs(direction);

CREATE INDEX IF NOT EXISTS idx_sync_logs_status
ON public.external_sync_logs(status);

CREATE INDEX IF NOT EXISTS idx_sync_logs_entity
ON public.external_sync_logs(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_sync_logs_created_at
ON public.external_sync_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sync_logs_user_id
ON public.external_sync_logs(user_id);

-- Composite index for common queries
CREATE INDEX IF NOT EXISTS idx_sync_logs_system_status_created
ON public.external_sync_logs(external_system, status, created_at DESC);

-- ============================================================================
-- 4. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.external_sync_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 5. CREATE RLS POLICIES
-- ============================================================================

-- Users can view their own sync logs
CREATE POLICY "Users can view their own sync logs"
ON public.external_sync_logs FOR SELECT
USING (user_id = auth.uid());

-- System can insert all sync logs
CREATE POLICY "System can insert sync logs"
ON public.external_sync_logs FOR INSERT
WITH CHECK (true);

-- No one can update or delete sync logs (audit trail)
-- Admin users would need to be handled separately if needed

-- ============================================================================
-- 6. GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON public.external_sync_logs TO authenticated;
GRANT INSERT ON public.external_sync_logs TO authenticated;

-- ============================================================================
-- 7. CREATE HELPER FUNCTION - Get Last Sync for Entity
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_last_sync_for_entity(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_external_system VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    created_at TIMESTAMPTZ,
    external_system VARCHAR,
    direction sync_direction,
    status sync_status,
    error_message TEXT,
    http_status_code INTEGER,
    duration_ms INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.created_at,
        l.external_system,
        l.direction,
        l.status,
        l.error_message,
        l.http_status_code,
        l.duration_ms
    FROM public.external_sync_logs l
    WHERE l.entity_type = p_entity_type
        AND l.entity_id = p_entity_id
        AND (p_external_system IS NULL OR l.external_system = p_external_system)
    ORDER BY l.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. CREATE HELPER FUNCTION - Get Sync Statistics
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_sync_statistics(
    p_external_system VARCHAR DEFAULT NULL,
    p_hours_back INTEGER DEFAULT 24
)
RETURNS TABLE (
    external_system VARCHAR,
    direction sync_direction,
    status sync_status,
    count BIGINT,
    avg_duration_ms NUMERIC,
    last_sync_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.external_system,
        l.direction,
        l.status,
        COUNT(*) as count,
        ROUND(AVG(l.duration_ms)::NUMERIC, 2) as avg_duration_ms,
        MAX(l.created_at) as last_sync_at
    FROM public.external_sync_logs l
    WHERE l.created_at >= NOW() - INTERVAL '1 hour' * p_hours_back
        AND (p_external_system IS NULL OR l.external_system = p_external_system)
    GROUP BY l.external_system, l.direction, l.status
    ORDER BY l.external_system, l.direction, l.status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 9. ADD COMMENTS
-- ============================================================================

COMMENT ON TABLE public.external_sync_logs IS 'Audit trail for all external system (OFP/EKR) synchronization attempts';
COMMENT ON COLUMN public.external_sync_logs.external_system IS 'Which external system was involved (OFP or EKR)';
COMMENT ON COLUMN public.external_sync_logs.direction IS 'Direction of sync: incoming (OFP/EKR → Flow) or outgoing (Flow → OFP/EKR)';
COMMENT ON COLUMN public.external_sync_logs.status IS 'Sync status: pending, success, failed, or partial (some data synced)';
COMMENT ON COLUMN public.external_sync_logs.entity_type IS 'Type of entity being synced (e.g., client, survey, survey_export)';
COMMENT ON COLUMN public.external_sync_logs.entity_id IS 'UUID of the entity being synced';
COMMENT ON COLUMN public.external_sync_logs.request_payload IS 'Full request body sent to external system (for outgoing) or received from external system (for incoming)';
COMMENT ON COLUMN public.external_sync_logs.response_payload IS 'Full response body received from external system';
COMMENT ON COLUMN public.external_sync_logs.error_message IS 'Human-readable error message if sync failed';
COMMENT ON COLUMN public.external_sync_logs.http_status_code IS 'HTTP status code from external system API';
COMMENT ON COLUMN public.external_sync_logs.duration_ms IS 'Duration of sync operation in milliseconds';
COMMENT ON COLUMN public.external_sync_logs.user_id IS 'User who triggered the sync (if applicable)';

COMMENT ON FUNCTION public.get_last_sync_for_entity IS 'Get the most recent sync log entry for a specific entity';
COMMENT ON FUNCTION public.get_sync_statistics IS 'Get aggregated sync statistics for a time period';
