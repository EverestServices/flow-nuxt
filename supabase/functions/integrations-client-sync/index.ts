import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-external-system, x-api-key',
}

interface ClientSyncRequest {
  externalClientId: string
  externalSurveyId?: string | null
  client: {
    name: string
    email: string
    phone?: string
    postal_code?: string
    city?: string
    street?: string
    house_number?: string
    contact_person?: string
    notes?: string
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Extract and validate headers
    const apiKey = req.headers.get('X-API-Key')
    const userEmail = req.headers.get('X-User-Email')
    const externalSystem = req.headers.get('X-External-System')

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
        JSON.stringify({ success: false, error: 'Invalid headers' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 2. Parse request body
    const body: ClientSyncRequest = await req.json()

    if (!body.externalClientId || !body.client) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields: externalClientId, client' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 3. Create Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // 4. Validate API key and get user
    const apiKeyHash = await hashApiKey(apiKey)
    const { data: keyRecord, error: keyError } = await supabaseAdmin
      .from('user_external_api_keys')
      .select('user_id')
      .eq('api_key_hash', apiKeyHash)
      .eq('is_active', true)
      .single()

    if (keyError || !keyRecord) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid API key' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    const userId = keyRecord.user_id

    // 5. Get user's company_id
    const { data: userProfile } = await supabaseAdmin
      .from('user_profiles')
      .select('company_id')
      .eq('user_id', userId)
      .single()

    if (!userProfile?.company_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'User has no company assigned' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    const companyId = userProfile.company_id

    // 6. Check if client already exists (by external ID)
    const externalIdField = externalSystem === 'OFP' ? 'ofp_client_id' : 'ekr_client_id'
    const { data: existingClient } = await supabaseAdmin
      .from('clients')
      .select('id')
      .eq(externalIdField, body.externalClientId)
      .single()

    let flowClientId: string

    if (existingClient) {
      // Client already synced
      flowClientId = existingClient.id
      console.log('Client already exists:', flowClientId)
    } else {
      // 7. Create new client
      const { data: newClient, error: clientError } = await supabaseAdmin
        .from('clients')
        .insert({
          company_id: companyId,
          user_id: userId,
          name: body.client.name,
          email: body.client.email,
          phone: body.client.phone || null,
          postal_code: body.client.postal_code || null,
          city: body.client.city || null,
          street: body.client.street || null,
          house_number: body.client.house_number || null,
          contact_person: body.client.contact_person || null,
          notes: body.client.notes || null,
          [externalIdField]: body.externalClientId,
          status: 'active',
        })
        .select('id')
        .single()

      if (clientError || !newClient) {
        console.error('Failed to create client:', clientError)
        return new Response(
          JSON.stringify({ success: false, error: 'Failed to create client' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
          }
        )
      }

      flowClientId = newClient.id
      console.log('Created new client:', flowClientId)
    }

    // 8. Create new survey
    const externalSurveyIdField = externalSystem === 'OFP' ? 'ofp_survey_id' : 'ekr_survey_id'
    const { data: newSurvey, error: surveyError } = await supabaseAdmin
      .from('surveys')
      .insert({
        client_id: flowClientId,
        user_id: userId,
        company_id: companyId,
        at: new Date().toISOString(),
        [externalSurveyIdField]: body.externalSurveyId || crypto.randomUUID(),
      })
      .select('id')
      .single()

    if (surveyError || !newSurvey) {
      console.error('Failed to create survey:', surveyError)
      return new Response(
        JSON.stringify({ success: false, error: 'Failed to create survey' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    const flowSurveyId = newSurvey.id
    console.log('Created new survey:', flowSurveyId)

    // 9. Build survey URL
    const baseUrl = Deno.env.get('FLOW_BASE_URL') || 'localhost:3000'
    const surveyUrl = `${baseUrl}/survey/${flowSurveyId}`

    // 10. Log sync
    await supabaseAdmin
      .from('external_sync_logs')
      .insert({
        external_system: externalSystem,
        direction: 'incoming',
        status: 'success',
        entity_type: 'client',
        entity_id: flowClientId,
        request_payload: body,
        response_payload: { flowClientId, flowSurveyId },
        http_status_code: 200,
        user_id: userId,
      })

    // 11. Return response
    return new Response(
      JSON.stringify({
        success: true,
        flowClientId,
        flowSurveyId,
        surveyUrl,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Client sync error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

async function hashApiKey(apiKey: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(apiKey)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
  return hashHex
}
