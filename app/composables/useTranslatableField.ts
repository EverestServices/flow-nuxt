/**
 * Composable for handling multilingual database fields
 * Provides utilities to translate JSONB fields based on current locale
 */
export const useTranslatableField = () => {
  const { locale } = useI18n()

  /**
   * Get translated value from a multilingual object
   * @param translations - Object with language codes as keys: { en: 'value', hu: 'érték' }
   * @param fallbackValue - Optional fallback if translations not found
   * @returns Translated string in current locale
   */
  const translate = (
    translations: { en: string; hu: string } | undefined | null,
    fallbackValue?: string
  ): string => {
    if (!translations) {
      return fallbackValue || ''
    }

    const currentLocale = locale.value as 'en' | 'hu'

    // Try current locale first
    if (translations[currentLocale]) {
      return translations[currentLocale]
    }

    // Fallback to English if current locale not found
    if (translations.en) {
      return translations.en
    }

    // Fallback to Hungarian if English not found
    if (translations.hu) {
      return translations.hu
    }

    // Last resort: return fallback value
    return fallbackValue || ''
  }

  /**
   * Get translated label from multilingual options array
   * @param options - Array of options with multilingual labels
   * @param value - The value to find
   * @returns Translated label for the given value
   */
  const translateOption = (
    options: Array<{ value: string; label: { en: string; hu: string } }> | undefined | null,
    value: string
  ): string => {
    if (!options || options.length === 0) {
      return value
    }

    const option = options.find(opt => opt.value === value)
    if (!option) {
      return value
    }

    return translate(option.label, value)
  }

  /**
   * Get all translated options for dropdown/select components
   * @param options - Array of options with multilingual labels
   * @returns Array of options with translated labels for current locale
   */
  const translateOptions = (
    options: Array<{ value: string; label: { en: string; hu: string } }> | undefined | null
  ): Array<{ value: string; label: string }> => {
    if (!options || options.length === 0) {
      return []
    }

    return options.map(option => ({
      value: option.value,
      label: translate(option.label, option.value)
    }))
  }

  return {
    translate,
    translateOption,
    translateOptions
  }
}
