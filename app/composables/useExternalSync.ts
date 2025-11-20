/**
 * Composable for external system synchronization
 *
 * Handles:
 * - Survey export to OFP/EKR
 * - Sync log retrieval
 * - Retry logic
 */

export type SyncStatus = 'pending' | 'success' | 'failed' | 'partial'
export type SyncDirection = 'incoming' | 'outgoing'

export interface SyncLog {
  id: string
  created_at: string
  external_system: 'OFP' | 'EKR'
  direction: SyncDirection
  status: SyncStatus
  entity_type: string
  entity_id: string | null
  request_payload: any
  response_payload: any
  error_message: string | null
  http_status_code: number | null
  duration_ms: number | null
  user_id: string | null
}

export function useExternalSync() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  /**
   * Export survey to external system (OFP or EKR)
   */
  async function exportSurvey(surveyId: string): Promise<{
    success: boolean
    error?: string
    syncLogId?: string
  }> {
    try {
      // Call API endpoint
      const response = await $fetch('/api/integrations/survey/export', {
        method: 'POST',
        body: { surveyId }
      })

      return {
        success: true,
        syncLogId: response.syncLogId
      }
    } catch (error: any) {
      console.error('Failed to export survey:', error)
      return {
        success: false,
        error: error.message || 'Unknown error'
      }
    }
  }

  /**
   * Get last sync log for an entity
   */
  async function getLastSyncForEntity(
    entityType: string,
    entityId: string,
    externalSystem?: 'OFP' | 'EKR'
  ): Promise<SyncLog | null> {
    const { data, error } = await supabase
      .rpc('get_last_sync_for_entity', {
        p_entity_type: entityType,
        p_entity_id: entityId,
        p_external_system: externalSystem || null
      })

    if (error) {
      console.error('Failed to fetch last sync:', error)
      return null
    }

    return data?.[0] || null
  }

  /**
   * Get all sync logs for an entity
   */
  async function getSyncLogsForEntity(
    entityType: string,
    entityId: string
  ): Promise<SyncLog[]> {
    const { data, error } = await supabase
      .from('external_sync_logs')
      .select('*')
      .eq('entity_type', entityType)
      .eq('entity_id', entityId)
      .order('created_at', { ascending: false })
      .limit(50)

    if (error) {
      console.error('Failed to fetch sync logs:', error)
      return []
    }

    return data || []
  }

  /**
   * Get sync statistics
   */
  async function getSyncStatistics(
    externalSystem?: 'OFP' | 'EKR',
    hoursBack: number = 24
  ) {
    const { data, error } = await supabase
      .rpc('get_sync_statistics', {
        p_external_system: externalSystem || null,
        p_hours_back: hoursBack
      })

    if (error) {
      console.error('Failed to fetch sync statistics:', error)
      return []
    }

    return data || []
  }

  /**
   * Check if survey has pending or failed sync
   */
  async function hasPendingOrFailedSync(surveyId: string): Promise<{
    hasPending: boolean
    hasFailed: boolean
    lastFailedSync?: SyncLog
  }> {
    const logs = await getSyncLogsForEntity('survey', surveyId)

    const pending = logs.some(log => log.status === 'pending')
    const failed = logs.find(log => log.status === 'failed')

    return {
      hasPending: pending,
      hasFailed: !!failed,
      lastFailedSync: failed
    }
  }

  /**
   * Retry failed sync
   */
  async function retrySyncForSurvey(surveyId: string) {
    return await exportSurvey(surveyId)
  }

  return {
    exportSurvey,
    getLastSyncForEntity,
    getSyncLogsForEntity,
    getSyncStatistics,
    hasPendingOrFailedSync,
    retrySyncForSurvey
  }
}
