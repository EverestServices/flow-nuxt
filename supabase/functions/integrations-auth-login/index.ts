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
      .select('*')
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

    // 5. Get user details
    const { data: userData, error: userError } = await supabaseAdmin.auth.admin.getUserById(keyRecord.user_id)

    if (userError || !userData.user) {
      console.error('User not found:', userError)
      return new Response(
        JSON.stringify({ success: false, error: 'User not found' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 6. Verify email matches
    if (userData.user.email !== userEmail) {
      console.error('Email mismatch:', { expected: userData.user.email, provided: userEmail })
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid API key or email' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 7. Update last_used_at timestamp
    await supabaseAdmin
      .from('user_external_api_keys')
      .update({ last_used_at: new Date().toISOString() })
      .eq('id', keyRecord.id)

    // 8. Generate a magic link to get a token
    const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: userEmail,
    })

    if (linkError || !linkData) {
      console.error('Failed to generate magic link:', linkError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create session' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 9. Extract token from the magic link URL
    // The token is in the properties.hashed_token field
    const token = linkData.properties.hashed_token

    if (!token) {
      console.error('No token in link data:', linkData)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to generate access token' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 10. Build redirect URL
    const baseUrl = Deno.env.get('FLOW_BASE_URL') || 'http://localhost:3000'
    const redirectUrl = `${baseUrl}/auth/external-callback?token=${encodeURIComponent(token)}&redirect=${encodeURIComponent(redirectTo)}`

    // 11. Return response
    return new Response(
      JSON.stringify({
        success: true,
        sessionToken: token,
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
