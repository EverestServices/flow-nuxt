import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-external-system',
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Extract headers
    const userEmail = req.headers.get('X-User-Email')
    const externalSystem = req.headers.get('X-External-System')

    if (!userEmail || !externalSystem || !['OFP', 'EKR'].includes(externalSystem)) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid headers. X-User-Email and X-External-System (OFP|EKR) required' }),
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

    // 4. Deactivate API key for this user and system
    const { error: updateError } = await supabase
      .from('user_external_api_keys')
      .update({
        is_active: false,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', user.id)
      .eq('external_system', externalSystem)
      .eq('is_active', true)

    if (updateError) {
      console.error('Error revoking API key:', updateError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to revoke API key' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'API key revoked successfully',
        userId: user.id,
        externalSystem,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in revoke-api-key function:', error)
    return new Response(
      JSON.stringify({ success: false, error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
