import type { TDocumentDefinitions, Content } from 'pdfmake/interfaces'

export const useSurveyReport = () => {
  const surveyStore = useSurveyInvestmentsStore()
  const { translateField, translatePage } = useSurveyTranslations()
  const { translateOption } = useTranslatableField()
  const { locale } = useI18n()

  // Initialize pdfMake lazily (client-side only)
  const initializePdfMake = async () => {
    if (import.meta.server) {
      throw new Error('pdfMake can only be used on the client side')
    }

    const pdfMake = (await import('pdfmake/build/pdfmake')).default
    const pdfFonts = (await import('pdfmake/build/vfs_fonts')).default

    if (pdfFonts && pdfFonts.pdfMake && pdfFonts.pdfMake.vfs) {
      pdfMake.vfs = pdfFonts.pdfMake.vfs
    }

    return pdfMake
  }

  /**
   * Collect all survey data for the active investment
   */
  const collectSurveyData = () => {
    if (!surveyStore.activeInvestmentId) {
      throw new Error('No active investment')
    }

    const investmentId = surveyStore.activeInvestmentId
    const pages = surveyStore.surveyPages[investmentId] || []
    const reportData: any[] = []

    for (const page of pages) {
      const questions = surveyStore.surveyQuestions[page.id] || []
      const pageData = {
        pageName: page.name,
        pageTranslation: translatePage(page.name),
        questions: [] as any[]
      }

      for (const question of questions) {
        let response = surveyStore.getResponse(question.name)

        // Skip questions without responses
        if (response === null || response === undefined || response === '') {
          continue
        }

        // Parse JSON strings to arrays if needed
        let parsedResponse = response
        if (typeof response === 'string' && (response.startsWith('[') || response.startsWith('{'))) {
          try {
            parsedResponse = JSON.parse(response)
          } catch {
            // Keep original if parsing fails
            parsedResponse = response
          }
        }

        let displayValue = parsedResponse

        // Format the value based on question type
        if (question.type === 'dropdown' || question.type === 'icon_selector') {
          // For dropdown and icon_selector, translate the selected value
          displayValue = translateOption(question.options_translations, parsedResponse) || parsedResponse
        } else if (question.type === 'yes_no') {
          displayValue = parsedResponse === 'yes' ? 'Igen' : parsedResponse === 'no' ? 'Nem' : parsedResponse
        } else if (question.type === 'checkbox' || question.type === 'switch') {
          // For checkbox and switch, translate boolean to Igen/Nem
          displayValue = parsedResponse === true || parsedResponse === 'true' ? 'Igen' : 'Nem'
        } else if (question.type === 'multiselect' && Array.isArray(parsedResponse)) {
          // For multiselect, translate each option and join with comma
          const translatedValues = parsedResponse.map(val =>
            translateOption(question.options_translations, val) || val
          )
          displayValue = translatedValues.join(', ')
        } else if (Array.isArray(parsedResponse)) {
          // For other arrays, join with comma
          displayValue = parsedResponse.join(', ')
        } else if (typeof parsedResponse === 'object') {
          // For complex objects, convert to JSON string
          displayValue = JSON.stringify(parsedResponse, null, 2)
        }

        // Get question label from name_translations (same as SurveyQuestionRenderer)
        // Priority: name_translations > translateField > name
        const currentLocale = locale.value as 'en' | 'hu'
        let questionLabel = ''

        if (question.name_translations) {
          // Get translation based on current locale
          questionLabel = question.name_translations[currentLocale] ||
                         question.name_translations['hu'] ||
                         question.name_translations['en'] ||
                         question.name
        } else {
          // Fallback to translateField
          questionLabel = translateField(question.name)
        }

        pageData.questions.push({
          name: question.name,
          label: questionLabel,
          value: displayValue,
          type: question.type
        })
      }

      // Only add pages that have at least one answered question
      if (pageData.questions.length > 0) {
        reportData.push(pageData)
      }
    }

    return reportData
  }

  /**
   * Generate PDF document definition
   */
  const generateDocumentDefinition = (): TDocumentDefinitions => {
    const reportData = collectSurveyData()
    const content: Content[] = []

    // Add title
    content.push({
      text: 'Felmérési lap',
      style: 'header',
      margin: [0, 0, 0, 30]
    })

    // Add each page section
    for (const pageData of reportData) {
      // Page title
      content.push({
        text: pageData.pageTranslation,
        style: 'pageTitle',
        margin: [0, 10, 0, 10]
      })

      // Questions table
      const tableBody: any[] = []

      for (const question of pageData.questions) {
        tableBody.push([
          { text: question.label, style: 'questionLabel' },
          { text: String(question.value), style: 'questionValue' }
        ])
      }

      content.push({
        table: {
          widths: ['40%', '60%'],
          body: tableBody
        },
        layout: 'lightHorizontalLines',
        margin: [0, 0, 0, 20]
      })
    }

    // Document definition
    const docDefinition: TDocumentDefinitions = {
      content,
      styles: {
        header: {
          fontSize: 22,
          bold: true,
          alignment: 'center'
        },
        subheader: {
          fontSize: 12,
          alignment: 'center',
          color: '#666'
        },
        pageTitle: {
          fontSize: 16,
          bold: true,
          color: '#2c3e50'
        },
        questionLabel: {
          fontSize: 11,
          bold: true,
          color: '#34495e'
        },
        questionValue: {
          fontSize: 11,
          color: '#2c3e50'
        }
      },
      defaultStyle: {
        font: 'Roboto'
      }
    }

    return docDefinition
  }

  /**
   * Generate and download PDF
   */
  const downloadPDF = async () => {
    try {
      const pdfMake = await initializePdfMake()
      const docDefinition = generateDocumentDefinition()
      const fileName = `felmeresi_lap_${new Date().toISOString().split('T')[0]}.pdf`

      pdfMake.createPdf(docDefinition).download(fileName)
    } catch (error) {
      console.error('Error generating PDF:', error)
      throw error
    }
  }

  /**
   * Generate PDF and open in new tab
   */
  const openPDF = async () => {
    try {
      const pdfMake = await initializePdfMake()
      const docDefinition = generateDocumentDefinition()
      pdfMake.createPdf(docDefinition).open()
    } catch (error) {
      console.error('Error opening PDF:', error)
      throw error
    }
  }

  /**
   * Generate PDF as base64 string (for preview)
   */
  const generatePDFBase64 = async (): Promise<string> => {
    return new Promise(async (resolve, reject) => {
      try {
        const pdfMake = await initializePdfMake()
        const docDefinition = generateDocumentDefinition()
        pdfMake.createPdf(docDefinition).getBase64((data) => {
          resolve(data)
        })
      } catch (error) {
        reject(error)
      }
    })
  }

  /**
   * Generate PDF as blob (for preview)
   */
  const generatePDFBlob = async (): Promise<Blob> => {
    return new Promise(async (resolve, reject) => {
      try {
        const pdfMake = await initializePdfMake()
        const docDefinition = generateDocumentDefinition()
        pdfMake.createPdf(docDefinition).getBlob((blob) => {
          resolve(blob)
        })
      } catch (error) {
        reject(error)
      }
    })
  }

  return {
    collectSurveyData,
    generateDocumentDefinition,
    downloadPDF,
    openPDF,
    generatePDFBase64,
    generatePDFBlob
  }
}
