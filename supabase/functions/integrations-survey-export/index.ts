import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-api-key',
}

interface SurveyExportRequest {
  surveyId: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  try {
    // 1. Extract and validate headers
    const apiKey = req.headers.get('X-API-Key')
    const userEmail = req.headers.get('X-User-Email')

    if (!apiKey) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing X-API-Key header' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 2. Parse request body
    const body: SurveyExportRequest = await req.json()

    if (!body.surveyId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing surveyId' }),
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

    // 4. Validate API key (optional - can also use session token)
    const apiKeyHash = await hashApiKey(apiKey)
    const { data: keyRecord } = await supabaseAdmin
      .from('user_external_api_keys')
      .select('user_id')
      .eq('api_key_hash', apiKeyHash)
      .eq('is_active', true)
      .single()

    const userId = keyRecord?.user_id

    // 5. Get survey with client info
    const { data: survey, error: surveyError } = await supabaseAdmin
      .from('surveys')
      .select(`
        *,
        client:clients(*)
      `)
      .eq('id', body.surveyId)
      .single()

    if (surveyError || !survey) {
      console.error('Survey not found:', surveyError)
      return new Response(
        JSON.stringify({ success: false, error: 'Survey not found' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 404,
        }
      )
    }

    // 6. Determine external system
    let externalSystem: 'OFP' | 'EKR' | null = null
    let externalClientId: string | null = null
    let externalSurveyId: string | null = null

    if (survey.ofp_survey_id) {
      externalSystem = 'OFP'
      externalClientId = survey.client.ofp_client_id
      externalSurveyId = survey.ofp_survey_id
    } else if (survey.ekr_survey_id) {
      externalSystem = 'EKR'
      externalClientId = survey.client.ekr_client_id
      externalSurveyId = survey.ekr_survey_id
    }

    if (!externalSystem || !externalClientId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Survey is not from an external system' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 7. Collect survey answers
    const { data: surveyAnswers } = await supabaseAdmin
      .from('survey_answers')
      .select(`
        *,
        question:survey_questions(*)
      `)
      .eq('survey_id', body.surveyId)

    const formattedAnswers = surveyAnswers?.map(answer => ({
      questionName: answer.question.name,
      questionLabel: answer.question.name, // TODO: Get from translations
      answer: answer.answer,
      type: answer.question.type,
      unit: answer.question.unit,
    })) || []

    // 8. Collect scenario main components
    const { data: scenarios } = await supabaseAdmin
      .from('scenarios')
      .select(`
        id,
        scenario_main_components(
          *,
          main_component:main_components(*)
        )
      `)
      .eq('survey_id', body.surveyId)

    const allComponents: any[] = []
    scenarios?.forEach(scenario => {
      scenario.scenario_main_components?.forEach((smc: any) => {
        allComponents.push({
          persistName: smc.main_component.persist_name,
          mainComponentName: smc.main_component.name,
          mainComponentId: smc.main_component.id,
          quantity: smc.quantity,
          priceSnapshot: smc.price_snapshot,
          unit: smc.main_component.unit,
          specifications: smc.main_component.specifications || {},
        })
      })
    })

    // 9. Calculate values
    // TODO: Implement actual calculation logic
    const calculatedValues = {
      totalInvestmentCost: allComponents.reduce((sum, c) => sum + (c.priceSnapshot * c.quantity), 0),
      estimatedAnnualSavings: 0, // TODO
      estimatedPaybackPeriod: 0, // TODO
      totalPanelPower: 0, // TODO
      estimatedAnnualProduction: 0, // TODO
      co2Reduction: 0, // TODO
    }

    // 10. Prepare export data
    const exportData = {
      surveyAnswers: formattedAnswers,
      scenarioMainComponents: allComponents,
      calculatedValues,
    }

    // 11. Send to external system
    const externalUrl = externalSystem === 'OFP'
      ? Deno.env.get('OFP_BASE_URL')
      : Deno.env.get('EKR_BASE_URL')

    const webhookUrl = `${externalUrl}/api/integrations/survey/import`

    const webhookBody = {
      [`${externalSystem.toLowerCase()}ClientId`]: externalClientId,
      [`${externalSystem.toLowerCase()}SurveyId`]: externalSurveyId,
      surveyData: exportData,
    }

    let webhookSuccess = false
    let webhookStatusCode: number | null = null
    let webhookResponse: any = null
    let errorMessage: string | null = null

    try {
      const response = await fetch(webhookUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`, // Use same API key
        },
        body: JSON.stringify(webhookBody),
      })

      webhookStatusCode = response.status
      webhookResponse = await response.json()
      webhookSuccess = response.ok
    } catch (error) {
      errorMessage = error.message
      console.error('Webhook error:', error)
    }

    const duration = Date.now() - startTime

    // 12. Log sync
    const { data: syncLog } = await supabaseAdmin
      .from('external_sync_logs')
      .insert({
        external_system: externalSystem,
        direction: 'outgoing',
        status: webhookSuccess ? 'success' : 'failed',
        entity_type: 'survey',
        entity_id: body.surveyId,
        request_payload: webhookBody,
        response_payload: webhookResponse,
        error_message: errorMessage,
        http_status_code: webhookStatusCode,
        duration_ms: duration,
        user_id: userId,
      })
      .select('id')
      .single()

    // 13. Return response
    if (webhookSuccess) {
      return new Response(
        JSON.stringify({
          success: true,
          externalSystem,
          externalClientId,
          externalSurveyId,
          data: exportData,
          syncLogId: syncLog?.id,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    } else {
      return new Response(
        JSON.stringify({
          success: false,
          error: `Failed to sync to ${externalSystem}: ${errorMessage || 'Unknown error'}`,
          syncLogId: syncLog?.id,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }
  } catch (error) {
    console.error('Survey export error:', error)

    const duration = Date.now() - startTime

    return new Response(
      JSON.stringify({ success: false, error: error.message, duration_ms: duration }),
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
