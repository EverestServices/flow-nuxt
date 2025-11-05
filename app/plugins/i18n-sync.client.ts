// Import locale files statically
import enMessages from '../../i18n/locales/en.json'
import huMessages from '../../i18n/locales/hu.json'

// Create a locale map for easy access
const localeFiles: Record<string, any> = {
  en: enMessages,
  hu: huMessages
}

export default defineNuxtPlugin(async (nuxtApp) => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Access i18n instance from nuxtApp
  const i18n = nuxtApp.$i18n

  // Function to load user language preference
  const loadLanguagePreference = async (userId: string) => {
    try {
      const { data, error } = await client
        .from('user_profiles')
        .select('language')
        .eq('user_id', userId)
        .maybeSingle()

      if (!error && data?.language) {
        // Check if the locale messages are already loaded
        const currentMessages = i18n.getLocaleMessage(data.language)
        if (!currentMessages || Object.keys(currentMessages).length === 0) {
          try {
            // Load from statically imported locale files
            const messages = localeFiles[data.language]
            if (messages) {
              i18n.setLocaleMessage(data.language, messages)
            }
          } catch (err) {
            console.error(`Failed to load locale ${data.language}:`, err)
          }
        }

        i18n.locale.value = data.language
      }
    } catch (error) {
      console.error('Error loading language preference:', error)
    }
  }

  // Load language on mount if user is already logged in
  if (user.value) {
    await loadLanguagePreference(user.value.id)
  }

  // Watch for user changes and load their language preference
  watch(user, async (newUser) => {
    if (newUser) {
      await loadLanguagePreference(newUser.id)
    }
  })
})
