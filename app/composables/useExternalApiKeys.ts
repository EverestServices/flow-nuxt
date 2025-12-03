/**
 * Composable for managing external API keys (OFP/EKR)
 *
 * Handles generation, storage, and validation of user-specific API keys
 * for external system authentication.
 */

export type ExternalSystem = 'OFP' | 'EKR'

export interface UserExternalApiKey {
  id: string
  created_at: string
  updated_at: string
  user_id: string
  external_system: ExternalSystem
  api_key_hash: string
  is_active: boolean
  last_used_at: string | null
}

export function useExternalApiKeys() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  /**
   * Get all API keys for the current user
   */
  async function getApiKeys(): Promise<Record<ExternalSystem, UserExternalApiKey | null>> {
    if (!user.value) {
      throw new Error('User not authenticated')
    }

    const { data, error } = await supabase
      .from('user_external_api_keys')
      .select('*')
      .eq('user_id', user.value.id)
      .eq('is_active', true)

    if (error) {
      console.error('Failed to fetch API keys:', error)
      return { OFP: null, EKR: null }
    }

    const keys: Record<string, UserExternalApiKey> = {}
    data?.forEach((key) => {
      keys[key.external_system] = key
    })

    return {
      OFP: keys.OFP || null,
      EKR: keys.EKR || null
    }
  }

  /**
   * Generate a new API key for an external system
   *
   * @param externalSystem - OFP or EKR
   * @returns The generated API key (plain text) - SHOW TO USER ONLY ONCE
   */
  async function generateApiKey(externalSystem: ExternalSystem): Promise<string> {
    if (!user.value) {
      throw new Error('User not authenticated')
    }

    // 1. Generate crypto-secure random API key
    const randomPart = crypto.randomUUID().replace(/-/g, '')
    const apiKey = `flow_${externalSystem.toLowerCase()}_${randomPart}`

    // 2. Hash the API key (SHA-256)
    const apiKeyHash = await hashApiKey(apiKey)

    // 3. Upsert to database (replace existing if any)
    const { error } = await supabase
      .from('user_external_api_keys')
      .upsert({
        user_id: user.value.id,
        external_system: externalSystem,
        api_key_hash: apiKeyHash,
        is_active: true
      }, {
        onConflict: 'user_id,external_system'
      })

    if (error) {
      console.error('Failed to save API key:', error)
      throw new Error('Failed to generate API key')
    }

    // 4. Return plain text key (only time user will see it)
    return apiKey
  }

  /**
   * Deactivate an API key
   */
  async function deactivateApiKey(externalSystem: ExternalSystem): Promise<void> {
    if (!user.value) {
      throw new Error('User not authenticated')
    }

    const { error } = await supabase
      .from('user_external_api_keys')
      .update({ is_active: false })
      .eq('user_id', user.value.id)
      .eq('external_system', externalSystem)

    if (error) {
      console.error('Failed to deactivate API key:', error)
      throw new Error('Failed to deactivate API key')
    }
  }

  /**
   * SHA-256 hash an API key
   */
  async function hashApiKey(apiKey: string): Promise<string> {
    const encoder = new TextEncoder()
    const data = encoder.encode(apiKey)
    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
    return hashHex
  }

  /**
   * Check if user has an active API key for a system
   */
  async function hasApiKey(externalSystem: ExternalSystem): Promise<boolean> {
    if (!user.value) return false

    const { data } = await supabase
      .from('user_external_api_keys')
      .select('id')
      .eq('user_id', user.value.id)
      .eq('external_system', externalSystem)
      .eq('is_active', true)
      .single()

    return !!data
  }

  /**
   * Get the user's OFP API key from their profile
   * This is the key they set manually from their OFP account
   */
  async function getOfpApiKey(): Promise<string | null> {
    if (!user.value) return null

    const { data, error } = await supabase
      .from('user_profiles')
      .select('ofp_api_key')
      .eq('user_id', user.value.id)
      .single()

    if (error || !data) {
      console.error('Failed to fetch OFP API key:', error)
      return null
    }

    return data.ofp_api_key || null
  }

  /**
   * Set the user's OFP API key in their profile
   */
  async function setOfpApiKey(apiKey: string): Promise<boolean> {
    if (!user.value) {
      throw new Error('User not authenticated')
    }

    const { data, error } = await supabase.rpc('update_ofp_api_key', {
      p_api_key: apiKey
    })

    if (error) {
      console.error('Failed to save OFP API key:', error)
      return false
    }

    return data?.success || false
  }

  /**
   * Check if user has OFP API key configured
   */
  async function hasOfpApiKey(): Promise<boolean> {
    const key = await getOfpApiKey()
    return !!key
  }

  /**
   * Get user email for OFP authentication
   */
  function getUserEmail(): string | null {
    return user.value?.email || null
  }

  return {
    getApiKeys,
    generateApiKey,
    deactivateApiKey,
    hasApiKey,
    getOfpApiKey,
    setOfpApiKey,
    hasOfpApiKey,
    getUserEmail
  }
}
