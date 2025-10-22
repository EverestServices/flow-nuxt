export const useProfile = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  const profile = useState('userProfile', () => null as any)
  const loading = useState('profileLoading', () => false)
  const error = useState('profileError', () => null as string | null)

  // Fetch user profile
  const fetchProfile = async () => {
    if (!user.value) {
      error.value = 'No user logged in'
      return null
    }

    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await client
        .from('user_profiles')
        .select('*')
        .eq('user_id', user.value.id)
        .single()

      if (fetchError) {
        error.value = fetchError.message
        return null
      }

      profile.value = data
      return data
    } catch (err: any) {
      error.value = err.message
      return null
    } finally {
      loading.value = false
    }
  }

  // Update profile
  const updateProfile = async (updates: any) => {
    if (!user.value) {
      error.value = 'No user logged in'
      return { success: false, error: 'No user logged in' }
    }

    loading.value = true
    error.value = null

    try {
      const { data, error: updateError } = await client
        .from('user_profiles')
        .update({
          ...updates,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (updateError) {
        error.value = updateError.message
        return { success: false, error: updateError.message }
      }

      profile.value = data
      return { success: true, data }
    } catch (err: any) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Upload avatar
  const uploadAvatar = async (file: File) => {
    if (!user.value) {
      return { success: false, error: 'No user logged in' }
    }

    // Validate file type
    const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    if (!validTypes.includes(file.type)) {
      return { success: false, error: 'Invalid file type. Please upload JPEG, PNG, GIF, or WebP' }
    }

    // Validate file size (5MB)
    if (file.size > 5 * 1024 * 1024) {
      return { success: false, error: 'File too large. Maximum size is 5MB' }
    }

    try {
      // Create unique file name
      const fileExt = file.name.split('.').pop()
      const fileName = `${user.value.id}/${Date.now()}.${fileExt}`

      // Upload to Supabase Storage
      const { data: uploadData, error: uploadError } = await client.storage
        .from('avatars')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        return { success: false, error: uploadError.message }
      }

      // Get public URL
      const { data: { publicUrl } } = client.storage
        .from('avatars')
        .getPublicUrl(fileName)

      // Update profile with new avatar URL
      const { error: updateError } = await client
        .from('user_profiles')
        .update({ avatar_url: publicUrl })
        .eq('user_id', user.value.id)

      if (updateError) {
        return { success: false, error: updateError.message }
      }

      if (profile.value) {
        profile.value.avatar_url = publicUrl
      }

      return { success: true, url: publicUrl }
    } catch (err: any) {
      return { success: false, error: err.message }
    }
  }

  // Get display name
  const displayName = computed(() => {
    if (!profile.value) return ''

    const firstName = profile.value.first_name || ''
    const lastName = profile.value.last_name || ''

    if (firstName || lastName) {
      return `${firstName} ${lastName}`.trim()
    }

    return user.value?.email || ''
  })

  // Get avatar URL
  const avatarUrl = computed(() => {
    return profile.value?.avatar_url || 'https://github.com/benjamincanac.png'
  })

  return {
    profile,
    loading,
    error,
    fetchProfile,
    updateProfile,
    uploadAvatar,
    displayName,
    avatarUrl,
  }
}
