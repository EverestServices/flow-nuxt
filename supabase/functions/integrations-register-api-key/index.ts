import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-external-system, x-api-key',
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Extract headers
    const apiKey = req.headers.get('X-API-Key')
    const userEmail = req.headers.get('X-User-Email')
    const externalSystem = req.headers.get('X-External-System')

    if (!apiKey) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing X-API-Key header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!userEmail || !externalSystem || !['OFP', 'EKR'].includes(externalSystem)) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid headers. X-User-Email and X-External-System (OFP|EKR) required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate API key format
    const expectedPrefix = externalSystem === 'OFP' ? 'flow_ofp_' : 'flow_ekr_'
    if (!apiKey.startsWith(expectedPrefix)) {
      return new Response(
        JSON.stringify({ success: false, error: `Invalid API key format. Expected prefix: ${expectedPrefix}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Create Supabase client (service role for admin operations)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. Find user by email
    const { data: users, error: userError } = await supabase.auth.admin.listUsers()

    if (userError) {
      console.error('Error listing users:', userError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to find user' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const user = users.users.find(u => u.email === userEmail)

    if (!user) {
      return new Response(
        JSON.stringify({ success: false, error: `User not found with email: ${userEmail}` }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. Hash the API key using SHA-256
    const encoder = new TextEncoder()
    const data = encoder.encode(apiKey)
    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const apiKeyHash = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

    // 5. Check if API key already exists for this user and system (active or inactive)
    const { data: existingKey } = await supabase
      .from('user_external_api_keys')
      .select('*')
      .eq('user_id', user.id)
      .eq('external_system', externalSystem)
      .maybeSingle()

    if (existingKey) {
      // Update existing key (reactivate if it was revoked)
      const { error: updateError } = await supabase
        .from('user_external_api_keys')
        .update({
          api_key_hash: apiKeyHash,
          is_active: true,
          updated_at: new Date().toISOString(),
        })
        .eq('id', existingKey.id)

      if (updateError) {
        console.error('Error updating API key:', updateError)
        return new Response(
          JSON.stringify({ success: false, error: 'Failed to update API key' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Also store plain text API key in user_profiles for reverse direction (Flow -> OFP)
      if (externalSystem === 'OFP') {
        await supabase
          .from('user_profiles')
          .update({ ofp_api_key: apiKey })
          .eq('user_id', user.id)
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'API key updated successfully',
          userId: user.id,
          externalSystem,
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 6. Insert new API key
    const { error: insertError } = await supabase
      .from('user_external_api_keys')
      .insert({
        user_id: user.id,
        external_system: externalSystem,
        api_key_hash: apiKeyHash,
        is_active: true,
      })

    if (insertError) {
      console.error('Error inserting API key:', insertError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to register API key' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Also store plain text API key in user_profiles for reverse direction (Flow -> OFP)
    if (externalSystem === 'OFP') {
      await supabase
        .from('user_profiles')
        .update({ ofp_api_key: apiKey })
        .eq('user_id', user.id)
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'API key registered successfully',
        userId: user.id,
        externalSystem,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in register-api-key function:', error)
    return new Response(
      JSON.stringify({ success: false, error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
