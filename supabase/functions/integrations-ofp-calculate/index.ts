import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-user-email, x-api-key',
}

interface OfpCalculateRequest {
  scenarioId: string
}

interface InvestmentData {
  type: string
  quantity?: number
  with_scaffold?: boolean
  capacity_kw?: number
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
    const body: OfpCalculateRequest = await req.json()

    if (!body.scenarioId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing scenarioId' }),
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

    // 4. Validate API key
    const apiKeyHash = await hashApiKey(apiKey)
    const { data: keyRecord } = await supabaseAdmin
      .from('user_external_api_keys')
      .select('user_id')
      .eq('api_key_hash', apiKeyHash)
      .eq('is_active', true)
      .single()

    if (!keyRecord) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid API key' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 5. Get scenario with survey and client data
    const { data: scenario, error: scenarioError } = await supabaseAdmin
      .from('scenarios')
      .select(`
        *,
        survey:surveys(
          *,
          client:clients(*)
        )
      `)
      .eq('id', body.scenarioId)
      .single()

    if (scenarioError || !scenario) {
      console.error('Scenario not found:', scenarioError)
      return new Response(
        JSON.stringify({ success: false, error: 'Scenario not found' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 404,
        }
      )
    }

    // 6. Get scenario investments
    const { data: scenarioInvestments } = await supabaseAdmin
      .from('scenario_investments')
      .select(`
        investment:investments(*)
      `)
      .eq('scenario_id', body.scenarioId)

    // 7. Get scenario main components with quantities
    const { data: scenarioComponents } = await supabaseAdmin
      .from('scenario_main_components')
      .select(`
        *,
        main_component:main_components(
          *,
          category:main_component_categories(*)
        )
      `)
      .eq('scenario_id', body.scenarioId)

    // 8. Get scenario extra costs (OFP-specific only)
    const { data: scenarioExtraCosts } = await supabaseAdmin
      .from('scenario_extra_costs')
      .select(`
        *,
        extra_cost:extra_costs(
          *
        )
      `)
      .eq('scenario_id', body.scenarioId)

    // 8. Build investments payload for Sherpa
    const investments: Record<string, any> = {}

    // Map investment names to API types
    const investmentTypeMap: Record<string, string> = {
      'Facade Insulation': 'wall_insulation',
      'Attic Insulation': 'roof_insulation',
      'Windows': 'window_replacement',
      'Heat Pump': 'heat_pump',
    }

    // Process each investment
    for (const si of scenarioInvestments || []) {
      const investment = si.investment
      const apiType = investmentTypeMap[investment.name]

      if (!apiType) continue

      // Find main component for this investment
      const component = scenarioComponents?.find(sc => {
        // Match by investment_id if available, otherwise by category
        return sc.main_component?.main_component_category_id
      })

      if (apiType === 'wall_insulation') {
        // Find wall insulation component and its quantity
        const wallComponent = scenarioComponents?.find(sc =>
          sc.main_component?.category?.persist_name === 'facade_system' ||
          sc.main_component?.category?.persist_name === 'insulation'
        )

        investments.wall_insulation = {
          quantity: wallComponent?.quantity || 0,
          with_scaffold: false, // TODO: Get from survey answers
        }
      }

      if (apiType === 'roof_insulation') {
        const roofComponent = scenarioComponents?.find(sc =>
          sc.main_component?.category?.persist_name === 'roof_system'
        )

        investments.roof_insulation = {
          quantity: roofComponent?.quantity || 0,
        }
      }

      if (apiType === 'window_replacement') {
        const windowComponent = scenarioComponents?.find(sc =>
          sc.main_component?.category?.persist_name === 'window'
        )

        investments.window_replacement = {
          quantity: windowComponent?.quantity || 0,
        }
      }

      if (apiType === 'heat_pump') {
        const heatPumpComponent = scenarioComponents?.find(sc =>
          sc.main_component?.category?.persist_name === 'heatpump'
        )

        // Get OFP-specific extra costs for heat pump
        const ofpExtraCosts: Record<string, boolean> = {}

        if (scenarioExtraCosts) {
          for (const sec of scenarioExtraCosts) {
            const extraCost = sec.extra_cost

            // Check if this is an OFP-specific extra cost
            if (extraCost?.metadata?.is_ofp_specific === true) {
              // Use the ofp_api_key from metadata to send to Sherpa API
              const apiKey = extraCost.metadata.ofp_api_key
              if (apiKey) {
                ofpExtraCosts[apiKey] = true
              }
            }
          }
        }

        investments.heat_pump = {
          capacity_kw: heatPumpComponent?.main_component?.power
            ? Math.round(heatPumpComponent.main_component.power / 1000)
            : 12, // Default to 12 kW
          extra_costs: ofpExtraCosts, // e.g., { "HMW 200L": true, "Hibrid bekötés": true }
        }
      }
    }

    // 9. Build request payload
    const sherpaPayload = {
      investments,
      building_data: {
        zip_code: scenario.survey?.client?.postal_code || null,
        construction_year: null, // TODO: Get from survey answers
      },
      ofp_client_id: scenario.survey?.client?.ofp_client_id || null,
    }

    // 10. Call Sherpa OFP calculate endpoint
    const ofpBaseUrl = Deno.env.get('OFP_BASE_URL')
    if (!ofpBaseUrl) {
      return new Response(
        JSON.stringify({ success: false, error: 'OFP_BASE_URL not configured' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    const sherpaResponse = await fetch(`${ofpBaseUrl}/api/integrations/ofp-calculate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'X-API-Key': apiKey,
        'X-User-Email': userEmail || '',
      },
      body: JSON.stringify(sherpaPayload),
    })

    const sherpaResult = await sherpaResponse.json()

    if (!sherpaResponse.ok || !sherpaResult.success) {
      console.error('Sherpa OFP calculation failed:', sherpaResult)
      return new Response(
        JSON.stringify({
          success: false,
          error: sherpaResult.error || 'OFP calculation failed',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 11. Store result in scenario
    const ofpCalculation = {
      calculated_at: new Date().toISOString(),
      calculations: sherpaResult.calculations,
      totals: sherpaResult.totals,
      percentage: sherpaResult.percentage,
    }

    const { error: updateError } = await supabaseAdmin
      .from('scenarios')
      .update({ ofp_calculation: ofpCalculation })
      .eq('id', body.scenarioId)

    if (updateError) {
      console.error('Failed to store OFP calculation:', updateError)
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to store calculation result',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500,
        }
      )
    }

    // 12. Return result
    return new Response(
      JSON.stringify({
        success: true,
        scenarioId: body.scenarioId,
        ofpCalculation,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('OFP calculation error:', error)

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
