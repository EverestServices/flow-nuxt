import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'
import {
  INVESTMENT_MAPPING,
  PLANNED_INVESTMENT_MAPPING,
  DEBUG_FLOOR_AREA,
  FLOOR_AREA_QUESTION_IDS,
} from './mappings.ts'

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
  prefillData?: {
    basicData?: Record<string, any>
    facadeInsulation?: Record<string, any>
    heatPump?: Record<string, any>
    [key: string]: Record<string, any> | undefined
  }
  plannedInvestments?: string[]  // OFP planned investment names
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

    // 8.5. Process prefill data if provided
    if (body.prefillData) {
      console.log('Processing prefill data for survey:', flowSurveyId)
      await processPrefillData(supabaseAdmin, flowSurveyId, body.prefillData)
    }

    // 8.6. Set planned investments if provided
    console.log('DEBUG plannedInvestments received:', body.plannedInvestments, 'type:', typeof body.plannedInvestments, 'isArray:', Array.isArray(body.plannedInvestments))

    if (body.plannedInvestments) {
      // Convert object to array if needed (PHP sends {"0":"value","3":"value"} instead of array)
      let plannedInvestmentsArray: string[]
      if (Array.isArray(body.plannedInvestments)) {
        plannedInvestmentsArray = body.plannedInvestments
      } else if (typeof body.plannedInvestments === 'object') {
        // Convert object to array of values
        plannedInvestmentsArray = Object.values(body.plannedInvestments)
      } else {
        plannedInvestmentsArray = []
      }

      if (plannedInvestmentsArray.length > 0) {
        console.log('Setting planned investments for survey:', flowSurveyId, plannedInvestmentsArray)
        await setPlannedInvestments(supabaseAdmin, flowSurveyId, plannedInvestmentsArray)
      }
    }

    // 9. Build survey URL
    const baseUrl = Deno.env.get('FLOW_FRONTEND_URL') || 'http://localhost:3000'
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

/**
 * Processes prefill data and inserts survey answers
 */
async function processPrefillData(
  supabaseAdmin: any,
  surveyId: string,
  prefillData: Record<string, Record<string, any>>
): Promise<void> {
  try {
    const answersToInsert: any[] = []

    // Process each investment type in prefillData
    for (const [investmentKey, fieldData] of Object.entries(prefillData)) {
      if (!fieldData || typeof fieldData !== 'object') {
        continue
      }

      const persistName = INVESTMENT_MAPPING[investmentKey]
      if (!persistName) {
        console.warn(`Unknown investment key: ${investmentKey}`)
        continue
      }

      // Get investment ID and survey pages
      const { data: investment } = await supabaseAdmin
        .from('investments')
        .select('id, persist_name')
        .eq('persist_name', persistName)
        .single()

      if (!investment) {
        console.warn(`Investment not found for persist_name: ${persistName}`)
        continue
      }

      // Get all survey questions for this investment
      const { data: surveyPages } = await supabaseAdmin
        .from('survey_pages')
        .select(`
          id,
          type,
          survey_questions (
            id,
            name,
            type
          )
        `)
        .eq('investment_id', investment.id)

      if (!surveyPages || surveyPages.length === 0) {
        console.warn(`No survey pages found for investment: ${persistName}`)
        continue
      }

      // Build a map of question names to question IDs
      const questionMap = new Map<string, string>()
      for (const page of surveyPages) {
        if (page.survey_questions) {
          for (const question of page.survey_questions) {
            questionMap.set(question.name, question.id)
          }
        }
      }

      // Create survey answers for each prefilled field
      for (const [fieldName, value] of Object.entries(fieldData)) {
        const questionId = questionMap.get(fieldName)

        if (!questionId) {
          console.warn(`Question not found for field: ${fieldName} in investment: ${persistName}`)
          continue
        }

        // Debug log for floor area fields (configurable)
        if (DEBUG_FLOOR_AREA && fieldName.includes('floor_area')) {
          console.log(`DEBUG floor_area field: ${fieldName} = ${value} (type: ${typeof value})`)
        }

        // Convert value to appropriate format
        let answerValue: any = value

        // Handle boolean values
        if (typeof value === 'boolean') {
          answerValue = value.toString()
        }
        // Handle array values (multiselect)
        else if (Array.isArray(value)) {
          answerValue = JSON.stringify(value)
        }
        // Handle number values
        else if (typeof value === 'number') {
          answerValue = value.toString()
        }
        // String values stay as is

        answersToInsert.push({
          survey_id: surveyId,
          survey_question_id: questionId,
          answer: answerValue,
        })
      }
    }

    if (answersToInsert.length > 0) {
      console.log(`Inserting ${answersToInsert.length} prefilled answers`)

      // Debug: log floor_area answers before insert (configurable)
      if (DEBUG_FLOOR_AREA) {
        const floorAreaAnswers = answersToInsert.filter(a =>
          a.survey_question_id === FLOOR_AREA_QUESTION_IDS.building_useful_floor_area ||
          a.survey_question_id === FLOOR_AREA_QUESTION_IDS.heated_floor_area
        )
        console.log('DEBUG floor_area answers to insert:', JSON.stringify(floorAreaAnswers))
      }

      const { data: insertedData, error: insertError } = await supabaseAdmin
        .from('survey_answers')
        .insert(answersToInsert)
        .select('survey_question_id')

      if (insertError) {
        console.error('Failed to insert prefilled answers:', insertError)
        // Don't throw - continue with survey creation even if prefill fails
      } else {
        console.log('Successfully inserted prefilled answers')
        if (DEBUG_FLOOR_AREA) {
          console.log('DEBUG inserted count:', insertedData?.length)
        }
      }
    } else {
      console.log('No valid prefill answers to insert')
    }
  } catch (error) {
    console.error('Error processing prefill data:', error)
    // Don't throw - continue with survey creation even if prefill fails
  }
}

/**
 * Sets planned investments for a survey by inserting records into survey_investments table
 */
async function setPlannedInvestments(
  supabaseAdmin: any,
  surveyId: string,
  plannedInvestments: string[]
): Promise<void> {
  try {
    const investmentsToInsert: any[] = []

    // Map OFP investment names to Flow persist_names and get investment IDs
    for (const ofpInvestmentName of plannedInvestments) {
      const persistName = PLANNED_INVESTMENT_MAPPING[ofpInvestmentName]

      if (!persistName) {
        console.warn(`Unknown OFP investment: ${ofpInvestmentName}`)
        continue
      }

      // Get investment ID by persist_name
      const { data: investment } = await supabaseAdmin
        .from('investments')
        .select('id')
        .eq('persist_name', persistName)
        .single()

      if (!investment) {
        console.warn(`Investment not found for persist_name: ${persistName}`)
        continue
      }

      investmentsToInsert.push({
        survey_id: surveyId,
        investment_id: investment.id,
      })
    }

    // Always include basicData investment
    const { data: basicDataInvestment } = await supabaseAdmin
      .from('investments')
      .select('id')
      .eq('persist_name', 'basicData')
      .single()

    if (basicDataInvestment) {
      investmentsToInsert.push({
        survey_id: surveyId,
        investment_id: basicDataInvestment.id,
      })
    }

    if (investmentsToInsert.length > 0) {
      console.log(`Inserting ${investmentsToInsert.length} survey investments`)

      const { error: insertError } = await supabaseAdmin
        .from('survey_investments')
        .insert(investmentsToInsert)

      if (insertError) {
        console.error('Failed to insert survey investments:', insertError)
        // Don't throw - continue with survey creation even if this fails
      } else {
        console.log('Successfully set planned investments')
      }
    } else {
      console.log('No valid investments to insert')
    }
  } catch (error) {
    console.error('Error setting planned investments:', error)
    // Don't throw - continue with survey creation even if this fails
  }
}
