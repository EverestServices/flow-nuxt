import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-external-system, x-redirect-to, x-api-key',
}

interface AuthLoginRequest {
  headers: {
    authorization?: string
    'x-user-email'?: string
    'x-external-system'?: string
    'x-redirect-to'?: string
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Extract headers
    const apiKey = req.headers.get('X-API-Key')
    const userEmail = req.headers.get('X-User-Email')
    const externalSystem = req.headers.get('X-External-System')
    const redirectTo = req.headers.get('X-Redirect-To') || '/dashboard'

    if (!apiKey) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing X-API-Key header' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    if (!userEmail || !externalSystem || !['OFP', 'EKR'].includes(externalSystem)) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid headers. X-User-Email and X-External-System required.' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 2. Create Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // 3. Hash the API key for comparison
    const apiKeyHash = await hashApiKey(apiKey)

    // 4. Validate API key
    const { data: keyRecord, error: keyError } = await supabaseAdmin
      .from('user_external_api_keys')
      .select(`
        *,
        user:user_id (
          id,
          email
        )
      `)
      .eq('api_key_hash', apiKeyHash)
      .eq('is_active', true)
      .single()

    if (keyError || !keyRecord) {
      console.error('API key not found:', keyError)
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid API key' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 5. Verify email matches
    if (keyRecord.user.email !== userEmail) {
      console.error('Email mismatch:', { expected: keyRecord.user.email, provided: userEmail })
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid API key or email' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 6. Update last_used_at timestamp
    await supabaseAdmin
      .from('user_external_api_keys')
      .update({ last_used_at: new Date().toISOString() })
      .eq('id', keyRecord.id)

    // 7. Generate Supabase session token
    const { data: sessionData, error: sessionError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: userEmail,
    })

    if (sessionError || !sessionData) {
      console.error('Failed to create session:', sessionError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create session' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 8. Build redirect URL
    const baseUrl = Deno.env.get('FLOW_BASE_URL') || 'localhost:3000'
    const accessToken = sessionData.properties?.access_token
    const redirectUrl = `${baseUrl}/auth/external-callback?token=${encodeURIComponent(accessToken)}&redirect=${encodeURIComponent(redirectTo)}`

    // 9. Return response
    return new Response(
      JSON.stringify({
        success: true,
        sessionToken: accessToken,
        redirectUrl,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('External auth error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

/**
 * Hash API key using SHA-256
 */
async function hashApiKey(apiKey: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(apiKey)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
  return hashHex
}
