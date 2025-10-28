import { defineStore } from 'pinia'
import { useSupabaseClient } from '#imports'

export interface Investment {
  id: string
  name: string
  name_translations?: { en: string; hu: string }
  persist_name: string
  icon: string
  position: { top: number; right: number }
  sequence: number
  client_type?: 'residential' | 'corporate' | 'both'
}

export interface SurveyPage {
  id: string
  investment_id: string
  name: string
  name_translations?: { en: string; hu: string }
  type: string
  position: { top: number; right: number }
  sequence: number
  allow_multiple: boolean
  allow_delete_first: boolean
  item_name_template?: string
  item_name_template_translations?: { en: string; hu: string }
}

export interface SurveyQuestionOption {
  value: string
  label: { en: string; hu: string }
}

export interface DisplayCondition {
  field: string
  operator: 'equals' | 'not_equals' | 'greater_than' | 'less_than' | 'greater_or_equal' | 'less_or_equal' | 'contains'
  value: string | number | boolean
}

export interface SurveyQuestion {
  id: string
  survey_page_id: string
  name: string
  name_translations?: { en: string; hu: string }
  type: string
  is_required: boolean
  is_special?: boolean
  default_value?: string
  placeholder_value?: string
  placeholder_translations?: { en: string; hu: string }
  options?: string[]
  options_translations?: SurveyQuestionOption[]
  min?: number
  max?: number
  step?: number
  unit?: string
  unit_translations?: { en: string; hu: string }
  info_message?: string
  info_message_translations?: { en: string; hu: string }
  display_conditions?: DisplayCondition
}

export interface DocumentCategory {
  id: string
  persist_name: string
  name: string
  name_translations?: { en: string; hu: string }
  description: string
  description_translations?: { en: string; hu: string }
  min_photos: number
  position?: { top: number; right: number }
  investmentPosition?: number // Position in the investment_document_categories junction table
}

export interface SurveyInvestmentData {
  survey_id: string
  investment_id: string
}

export interface PageInstanceData {
  instances: Record<string, any>[]
}

export const useSurveyInvestmentsStore = defineStore('surveyInvestments', {
  state: () => ({
    // Available investments from database
    availableInvestments: [] as Investment[],

    // Selected investments for current survey
    selectedInvestmentIds: [] as string[],

    // Responses data for each investment (stored separately from junction table)
    investmentResponses: {} as Record<string, Record<string, any>>,

    // Page instances for allow_multiple pages
    // Structure: { [investmentId]: { [pageId]: { instances: [{questionName: value}, ...] } } }
    pageInstances: {} as Record<string, Record<string, PageInstanceData>>,

    // Active instance index for each page (for allow_multiple pages)
    activeInstanceIndex: {} as Record<string, number>, // key: pageId, value: index

    // Survey pages for each investment
    surveyPages: {} as Record<string, SurveyPage[]>,

    // Survey questions for each page
    surveyQuestions: {} as Record<string, SurveyQuestion[]>,

    // Document categories for each investment
    documentCategories: {} as Record<string, DocumentCategory[]>,

    // Current active investment and page
    activeInvestmentId: null as string | null,
    activePageId: null as string | null,

    // Client type filter
    clientType: 'residential' as 'residential' | 'corporate',

    // Current survey ID
    currentSurveyId: null as string | null,

    // Loading states
    isLoading: false,
    isLoadingInvestmentData: false,
  }),

  getters: {
    // Get filtered investments by client type
    filteredInvestments(state): Investment[] {
      return state.availableInvestments.filter(inv => {
        if (!inv.client_type || inv.client_type === 'both') return true
        return inv.client_type === state.clientType
      })
    },

    // Get selected investments
    selectedInvestments(state): Investment[] {
      return state.availableInvestments.filter(inv =>
        state.selectedInvestmentIds.includes(inv.id)
      )
    },

    // Get active investment
    activeInvestment(state): Investment | null {
      if (!state.activeInvestmentId) return null
      return state.availableInvestments.find(inv => inv.id === state.activeInvestmentId) || null
    },

    // Get pages for active investment
    activeSurveyPages(state): SurveyPage[] {
      if (!state.activeInvestmentId) return []
      return state.surveyPages[state.activeInvestmentId] || []
    },

    // Get active page
    activePage(state): SurveyPage | null {
      if (!state.activePageId || !state.activeInvestmentId) return null
      const pages = state.surveyPages[state.activeInvestmentId] || []
      return pages.find(page => page.id === state.activePageId) || null
    },

    // Get questions for active page
    activePageQuestions(state): SurveyQuestion[] {
      if (!state.activePageId) return []
      return state.surveyQuestions[state.activePageId] || []
    },

    // Get document categories for active investment
    activeDocumentCategories(state): DocumentCategory[] {
      if (!state.activeInvestmentId) return []
      return state.documentCategories[state.activeInvestmentId] || []
    },

    // Check if any investment is selected
    hasSelectedInvestments(state): boolean {
      return state.selectedInvestmentIds.length > 0
    },
  },

  actions: {
    // Initialize store for a survey
    async initializeForSurvey(surveyId: string) {
      this.currentSurveyId = surveyId
      this.isLoading = true

      try {
        const supabase = useSupabaseClient()

        // Load all available investments
        const { data: investments, error: invError } = await supabase
          .from('investments')
          .select('*')
          .order('sequence')

        if (invError) throw invError
        this.availableInvestments = investments || []

        // Load survey investments (already selected for this survey)
        const { data: surveyInvestments, error: siError } = await supabase
          .from('survey_investments')
          .select('*')
          .eq('survey_id', surveyId)

        if (siError) throw siError

        // Set selected investment IDs (remove duplicates using Set)
        const investmentIds = surveyInvestments?.map(si => si.investment_id) || []
        this.selectedInvestmentIds = [...new Set(investmentIds)]

        // If we have selected investments, load their pages
        if (this.selectedInvestmentIds.length > 0) {
          await this.loadInvestmentData(this.selectedInvestmentIds)

          // Set first investment and page as active
          if (!this.activeInvestmentId) {
            this.activeInvestmentId = this.selectedInvestmentIds[0]
            const pages = this.surveyPages[this.activeInvestmentId]
            if (pages && pages.length > 0) {
              this.activePageId = pages[0].id
            }
          }
        }

      } catch (error) {
        console.error('Error initializing survey investments:', error)
      } finally {
        this.isLoading = false
      }
    },

    // Load survey pages and questions for investments
    async loadInvestmentData(investmentIds: string[], forceReload: boolean = false) {
      // Check if already loading - prevent concurrent calls
      if (this.isLoadingInvestmentData) {
        // Wait for the current loading to finish
        while (this.isLoadingInvestmentData) {
          await new Promise(resolve => setTimeout(resolve, 50))
        }
        return
      }

      // Check if data is already loaded for ALL requested investments
      const alreadyLoaded = !forceReload && investmentIds.every(invId =>
        this.surveyPages[invId] && this.surveyPages[invId].length > 0
      )

      if (alreadyLoaded) {
        return
      }

      const supabase = useSupabaseClient()

      try {
        this.isLoadingInvestmentData = true

        // Initialize/reset data structures for these investments
        investmentIds.forEach(invId => {
          this.surveyPages[invId] = []
          this.documentCategories[invId] = []
        })

        // Load survey pages for these investments
        const { data: pages, error: pagesError } = await supabase
          .from('survey_pages')
          .select('*')
          .in('investment_id', investmentIds)
          .order('sequence')

        if (pagesError) throw pagesError

        // Group pages by investment_id and ensure no duplicates
        const pagesByInvestment = new Map<string, Set<string>>()

        pages?.forEach((page) => {
          // Track which page IDs we've already added for this investment
          if (!pagesByInvestment.has(page.investment_id)) {
            pagesByInvestment.set(page.investment_id, new Set())
          }

          const pageIds = pagesByInvestment.get(page.investment_id)!

          // Only add if we haven't seen this page ID before
          if (!pageIds.has(page.id)) {
            pageIds.add(page.id)
            this.surveyPages[page.investment_id].push(page)
          }
        })

        // Load questions for all pages
        const pageIds = pages?.map(p => p.id) || []
        if (pageIds.length > 0) {
          // Initialize/reset questions for these pages
          pageIds.forEach(pageId => {
            this.surveyQuestions[pageId] = []
          })

          const { data: questions, error: questionsError } = await supabase
            .from('survey_questions')
            .select('*')
            .in('survey_page_id', pageIds)
            .order('created_at')

          if (questionsError) throw questionsError

          // Group questions by page_id
          questions?.forEach(question => {
            this.surveyQuestions[question.survey_page_id].push(question)
          })
        }

        // Load document categories for these investments
        const { data: docCats, error: docCatsError } = await supabase
          .from('investment_document_categories')
          .select(`
            position,
            investment_id,
            document_category:document_categories (
              id,
              persist_name,
              name,
              description,
              min_photos,
              position
            )
          `)
          .in('investment_id', investmentIds)
          .order('position')

        if (docCatsError) throw docCatsError

        // Group document categories by investment_id
        docCats?.forEach((idc: any) => {
          const investmentId = idc.investment_id
          const categoryWithPosition = {
            ...idc.document_category,
            investmentPosition: idc.position
          }
          this.documentCategories[investmentId].push(categoryWithPosition)
        })

      } catch (error) {
        console.error('Error loading investment data:', error)
      } finally {
        this.isLoadingInvestmentData = false
      }
    },

    // Select an investment
    async selectInvestment(investmentId: string) {
      if (this.selectedInvestmentIds.includes(investmentId)) {
        return // Already selected
      }

      const supabase = useSupabaseClient()

      try {
        // Add to survey_investments table
        const { error } = await supabase
          .from('survey_investments')
          .insert({
            survey_id: this.currentSurveyId,
            investment_id: investmentId
          })

        if (error) throw error

        // Add to selected list
        this.selectedInvestmentIds.push(investmentId)

        // Initialize empty responses for this investment
        this.investmentResponses[investmentId] = {}

        // Load data for this investment
        await this.loadInvestmentData([investmentId])

        // If this is the first investment, set it as active
        if (this.selectedInvestmentIds.length === 1) {
          this.activeInvestmentId = investmentId
          const pages = this.surveyPages[investmentId]
          if (pages && pages.length > 0) {
            this.activePageId = pages[0].id
          }
        }

      } catch (error) {
        console.error('Error selecting investment:', error)
        throw error
      }
    },

    // Deselect an investment
    async deselectInvestment(investmentId: string) {
      const supabase = useSupabaseClient()

      try {
        // Remove from survey_investments table
        const { error } = await supabase
          .from('survey_investments')
          .delete()
          .eq('survey_id', this.currentSurveyId)
          .eq('investment_id', investmentId)

        if (error) throw error

        // Remove from selected list
        this.selectedInvestmentIds = this.selectedInvestmentIds.filter(id => id !== investmentId)
        delete this.investmentResponses[investmentId]

        // Clean up survey pages data
        const pageIds = this.surveyPages[investmentId]?.map(p => p.id) || []
        delete this.surveyPages[investmentId]

        // Clean up survey questions for these pages
        pageIds.forEach(pageId => {
          delete this.surveyQuestions[pageId]
        })

        // Clean up document categories
        delete this.documentCategories[investmentId]

        // If this was the active investment, switch to another
        if (this.activeInvestmentId === investmentId) {
          if (this.selectedInvestmentIds.length > 0) {
            this.activeInvestmentId = this.selectedInvestmentIds[0]
            const pages = this.surveyPages[this.activeInvestmentId]
            if (pages && pages.length > 0) {
              this.activePageId = pages[0].id
            }
          } else {
            this.activeInvestmentId = null
            this.activePageId = null
          }
        }

      } catch (error) {
        console.error('Error deselecting investment:', error)
        throw error
      }
    },

    // Set active investment and page
    setActiveInvestment(investmentId: string, pageId?: string) {
      this.activeInvestmentId = investmentId

      if (pageId) {
        this.activePageId = pageId
      } else {
        // Set first page as active
        const pages = this.surveyPages[investmentId]
        if (pages && pages.length > 0) {
          this.activePageId = pages[0].id
        }
      }
    },

    // Set active page
    setActivePage(pageId: string) {
      this.activePageId = pageId

      // Find which investment this page belongs to
      for (const investmentId in this.surveyPages) {
        const pages = this.surveyPages[investmentId]
        const page = pages.find(p => p.id === pageId)
        if (page) {
          // If the page belongs to a different investment, switch to it
          if (this.activeInvestmentId !== investmentId) {
            this.activeInvestmentId = investmentId
          }
          break
        }
      }
    },

    // Set client type
    setClientType(clientType: 'residential' | 'corporate') {
      this.clientType = clientType
    },

    // Save response for a question
    async saveResponse(questionName: string, value: any) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        // Update local state (responses are stored in memory for now)
        // TODO: Save to a separate survey_responses table if needed
        if (!this.investmentResponses[this.activeInvestmentId]) {
          this.investmentResponses[this.activeInvestmentId] = {}
        }
        this.investmentResponses[this.activeInvestmentId][questionName] = value

      } catch (error) {
        console.error('Error saving response:', error)
      }
    },

    // Get response for a question
    getResponse(questionName: string): any {
      if (!this.activeInvestmentId) return null
      return this.investmentResponses[this.activeInvestmentId]?.[questionName]
    },

    // ========================================================================
    // Page Instances Management (for allow_multiple pages)
    // ========================================================================

    // Get instances for a page
    getPageInstances(pageId: string): Record<string, any>[] {
      if (!this.activeInvestmentId) return []

      // Initialize if doesn't exist
      if (!this.pageInstances[this.activeInvestmentId]) {
        this.pageInstances[this.activeInvestmentId] = {}
      }

      // If page data doesn't exist at all, create it with one instance
      // But if it exists (even with empty array), keep it as is
      if (!this.pageInstances[this.activeInvestmentId][pageId]) {
        this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
      }

      // Return instances (can be empty array if all were deleted with allow_delete_first=true)
      return this.pageInstances[this.activeInvestmentId][pageId].instances
    },

    // Add a new instance for a page
    addPageInstance(pageId: string) {
      if (!this.activeInvestmentId) return

      // Initialize if doesn't exist
      if (!this.pageInstances[this.activeInvestmentId]) {
        this.pageInstances[this.activeInvestmentId] = {}
      }
      if (!this.pageInstances[this.activeInvestmentId][pageId]) {
        this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
      }

      // Add new instance
      this.pageInstances[this.activeInvestmentId][pageId].instances.push({})

      // Set as active
      const newIndex = this.pageInstances[this.activeInvestmentId][pageId].instances.length - 1
      this.activeInstanceIndex[pageId] = newIndex
    },

    // Remove an instance from a page
    removePageInstance(pageId: string, index: number, allowDeleteLast: boolean = false) {
      if (!this.activeInvestmentId) return

      const instances = this.pageInstances[this.activeInvestmentId]?.[pageId]?.instances
      if (!instances || instances.length === 0) return

      // Remove the instance
      instances.splice(index, 1)

      // Ensure at least one instance exists (unless allowDeleteLast is true)
      if (instances.length === 0 && !allowDeleteLast) {
        instances.push({})
      }

      // Adjust active index if needed
      const currentActive = this.activeInstanceIndex[pageId] || 0
      if (instances.length > 0 && currentActive >= instances.length) {
        this.activeInstanceIndex[pageId] = instances.length - 1
      } else if (instances.length === 0) {
        this.activeInstanceIndex[pageId] = 0
      }
    },

    // Set active instance for a page
    setActiveInstance(pageId: string, index: number) {
      this.activeInstanceIndex[pageId] = index
    },

    // Get active instance index for a page
    getActiveInstanceIndex(pageId: string): number {
      return this.activeInstanceIndex[pageId] || 0
    },

    // Save response for a question in a specific instance
    async saveInstanceResponse(pageId: string, instanceIndex: number, questionName: string, value: any) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        // Initialize if doesn't exist
        if (!this.pageInstances[this.activeInvestmentId]) {
          this.pageInstances[this.activeInvestmentId] = {}
        }
        if (!this.pageInstances[this.activeInvestmentId][pageId]) {
          this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
        }

        const instances = this.pageInstances[this.activeInvestmentId][pageId].instances

        // Ensure instance exists
        while (instances.length <= instanceIndex) {
          instances.push({})
        }

        // Save the value
        instances[instanceIndex][questionName] = value

      } catch (error) {
        console.error('Error saving instance response:', error)
      }
    },

    // Get response for a question in a specific instance
    getInstanceResponse(pageId: string, instanceIndex: number, questionName: string): any {
      if (!this.activeInvestmentId) return null

      const instances = this.pageInstances[this.activeInvestmentId]?.[pageId]?.instances
      if (!instances || instanceIndex >= instances.length) return null

      return instances[instanceIndex]?.[questionName]
    },
  }
})
