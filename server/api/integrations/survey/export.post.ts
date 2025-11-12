export default defineEventHandler(async (event) => {
  const supabase = await serverSupabaseClient(event)
  const body = await readBody(event)

  // Get authenticated user
  const { data: { user }, error: userError } = await supabase.auth.getUser()

  if (userError || !user) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized'
    })
  }

  // Validate request body
  if (!body.surveyId) {
    throw createError({
      statusCode: 400,
      message: 'Missing surveyId'
    })
  }

  // Call Supabase Edge Function directly
  // Note: Edge Function will handle user validation internally
  const config = useRuntimeConfig()
  const supabaseUrl = config.public.supabase?.url || process.env.SUPABASE_URL

  // Get user's session token to pass to Edge Function
  const {
    data: { session },
  } = await supabase.auth.getSession()

  if (!session) {
    throw createError({
      statusCode: 401,
      message: 'No active session'
    })
  }

  try {
    const response = await $fetch(`${supabaseUrl}/functions/v1/integrations-survey-export`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json'
      },
      body: {
        surveyId: body.surveyId
      }
    })

    return response
  } catch (error: any) {
    console.error('Edge Function call failed:', error)

    // Return more detailed error
    const errorMessage = error.data?.error || error.message || 'Failed to export survey'
    const statusCode = error.statusCode || error.status || 500

    throw createError({
      statusCode,
      message: errorMessage
    })
  }
})
