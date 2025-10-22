import huTranslations from '~/locales/hu'

export const useI18n = () => {
  const t = (key: string, fallback?: string): string => {
    const keys = key.split('.')
    let value: any = huTranslations

    for (const k of keys) {
      if (value && typeof value === 'object' && k in value) {
        value = value[k]
      } else {
        return fallback || key
      }
    }

    return typeof value === 'string' ? value : fallback || key
  }

  /**
   * Translate a survey field name
   * Example: translateField('roof_type') -> 'Tető típusa'
   */
  const translateField = (fieldName: string): string => {
    // Try to find translation in surveyFields
    // Field names like 'roof_type' should match 'surveyFields.roof.roofType'

    // First, try direct match in general fields
    const camelCaseField = toCamelCase(fieldName)

    // Try in surveyFields.general
    let translation = t(`surveyFields.general.${camelCaseField}`)
    if (translation !== `surveyFields.general.${camelCaseField}`) {
      return translation
    }

    // Try in specific sections (roof, walls, windows, floors, etc.)
    const sections = ['roof', 'walls', 'windows', 'floors', 'general']
    for (const section of sections) {
      translation = t(`surveyFields.${section}.${camelCaseField}`)
      if (translation !== `surveyFields.${section}.${camelCaseField}`) {
        return translation
      }
    }

    // Try in heatPumpSurvey sections
    const heatPumpSections = ['general', 'rooms', 'windows', 'heatingBasics', 'radiators', 'desiredConstruction', 'otherData']
    for (const section of heatPumpSections) {
      translation = t(`heatPumpSurvey.${section}.${camelCaseField}`)
      if (translation !== `heatPumpSurvey.${section}.${camelCaseField}`) {
        return translation
      }
    }

    // If no translation found, return formatted field name
    return formatFieldName(fieldName)
  }

  /**
   * Translate a survey page name
   * Example: translatePage('general') -> 'Általános adatok'
   */
  const translatePage = (pageName: string): string => {
    const camelCasePage = toCamelCase(pageName)

    // Try to find sectionName in surveyFields
    const sections = ['general', 'roof', 'walls', 'windows', 'floors']
    for (const section of sections) {
      if (section === camelCasePage || pageName === section) {
        const translation = t(`surveyFields.${section}.sectionName`)
        if (translation !== `surveyFields.${section}.sectionName`) {
          return translation
        }
      }
    }

    // Try heatPumpSurvey sections
    const heatPumpSections = ['general', 'rooms', 'windows', 'heatingBasics', 'radiators', 'desiredConstruction', 'otherData']
    for (const section of heatPumpSections) {
      if (section === camelCasePage || pageName === section) {
        const translation = t(`heatPumpSurvey.${section}.sectionName`)
        if (translation !== `heatPumpSurvey.${section}.sectionName`) {
          return translation
        }
      }
    }

    // Fallback to formatted name
    return formatFieldName(pageName)
  }

  // Helper functions
  const toCamelCase = (str: string): string => {
    return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
  }

  const formatFieldName = (name: string): string => {
    // Convert snake_case to readable format
    return name
      .split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }

  return {
    t,
    translateField,
    translatePage
  }
}
