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
  is_default?: boolean
}

export interface SurveyPage {
  id: string
  investment_id: string
  parent_page_id?: string | null
  name: string
  name_translations?: { en: string; hu: string }
  type: string
  position: { top: number; right: number }
  sequence: number
  allow_multiple: boolean
  allow_delete_first: boolean
  item_name_template?: string
  item_name_template_translations?: { en: string; hu: string }
  add_button_translations?: { en: string; hu: string }
}

export interface SurveyQuestionOption {
  value: string
  label: { en: string; hu: string }
  icon?: string  // Optional icon for icon_selector type questions
}

export interface DisplayCondition {
  field: string
  operator: 'equals' | 'not_equals' | 'greater_than' | 'less_than' | 'greater_or_equal' | 'less_or_equal' | 'contains' | 'contains_any'
  value: string | number | boolean | string[]
}

export interface TemplateVariable {
  type: 'matched_conditional_values' | 'field_value' | 'conditional_count'
  field: string
}

export interface DisplaySettings {
  width?: 'full' | '1/2' | '1/3' | '1/4'
}

export interface SurveyQuestion {
  id: string
  survey_page_id: string
  name: string
  name_translations?: { en: string; hu: string }
  type: string
  is_required: boolean
  is_special?: boolean
  is_readonly?: boolean
  default_value?: string
  default_value_source_question_id?: string
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
  display_settings?: DisplaySettings | null
  template_variables?: Record<string, TemplateVariable>
  apply_template_to_placeholder?: boolean
  sequence?: number
  // Shared question support
  shared_question_id?: string | null
  is_shared_instance?: boolean
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
  instances: Record<string, any>[]  // For root pages (parent_page_id = null)
  subpageInstances?: Record<number, Record<string, any>[]>  // For hierarchical subpages, keyed by parent_item_group
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

    // Uploaded photos count for each category
    // Structure: { [categoryId]: count }
    categoryPhotoCounts: {} as Record<string, number>,

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
    // Get filtered investments by client type (excluding default investments)
    filteredInvestments(state): Investment[] {
      return state.availableInvestments.filter(inv => {
        // Hide default investments from selection modal
        if (inv.is_default) return false

        // Filter by client type
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

    // Get pages for active investment (only root pages, not subpages)
    activeSurveyPages(state): SurveyPage[] {
      if (!state.activeInvestmentId) return []
      const allPages = state.surveyPages[state.activeInvestmentId] || []
      return allPages.filter(page => !page.parent_page_id)
    },

    // Get subpages for a specific page
    getSubPages: (state) => (parentPageId: string): SurveyPage[] => {
      if (!state.activeInvestmentId) return []
      const allPages = state.surveyPages[state.activeInvestmentId] || []
      return allPages.filter(page => page.parent_page_id === parentPageId)
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

        // Auto-select default investments if not already selected
        const defaultInvestments = this.availableInvestments.filter(inv => inv.is_default)
        for (const defaultInv of defaultInvestments) {
          if (!this.selectedInvestmentIds.includes(defaultInv.id)) {
            // Add to database
            try {
              await supabase
                .from('survey_investments')
                .insert({
                  survey_id: surveyId,
                  investment_id: defaultInv.id
                })

              // Add to selected list
              this.selectedInvestmentIds.push(defaultInv.id)
            } catch (error) {
              console.error('Error auto-selecting default investment:', error)
            }
          }
        }

        // If we have selected investments, load their pages
        if (this.selectedInvestmentIds.length > 0) {
          await this.loadInvestmentData(this.selectedInvestmentIds)

          // Load existing answers from database
          await this.loadExistingAnswers(surveyId)

          // Load photo counts from database
          await this.loadCategoryPhotoCounts(surveyId)

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
            .order('sequence', { ascending: true, nullsFirst: false })
            .order('created_at', { ascending: true })

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

    // Load existing answers from database
    async loadExistingAnswers(surveyId: string) {
      const supabase = useSupabaseClient()

      try {
        // Load all survey answers for this survey
        const { data: answers, error } = await supabase
          .from('survey_answers')
          .select('survey_question_id, answer, item_group, parent_item_group')
          .eq('survey_id', surveyId)

        if (error) throw error
        if (!answers || answers.length === 0) return

        // Create a map of question_id -> question for faster lookup
        const questionMap = new Map<string, { question: SurveyQuestion, page: SurveyPage, investmentId: string }>()

        for (const investmentId in this.surveyPages) {
          const pages = this.surveyPages[investmentId]
          for (const page of pages) {
            const questions = this.surveyQuestions[page.id] || []
            for (const question of questions) {
              questionMap.set(question.id, {
                question,
                page,
                investmentId: investmentId
              })
            }
          }
        }

        // Process each answer
        for (const answer of answers) {
          const questionData = questionMap.get(answer.survey_question_id)
          if (!questionData) {
            console.warn(`Question not found for answer: ${answer.survey_question_id}`)
            continue
          }

          const { question, page, investmentId } = questionData

          if (answer.item_group === null && answer.parent_item_group === null) {
            // Regular answer (no item_group, no parent_item_group) - store in investmentResponses
            if (!this.investmentResponses[investmentId]) {
              this.investmentResponses[investmentId] = {}
            }
            this.investmentResponses[investmentId][question.name] = answer.answer
          } else if (answer.parent_item_group === null) {
            // Answer with item_group but no parent (root-level multi-instance page)
            if (!this.pageInstances[investmentId]) {
              this.pageInstances[investmentId] = {}
            }
            if (!this.pageInstances[investmentId][page.id]) {
              this.pageInstances[investmentId][page.id] = { instances: [] }
            }

            const instances = this.pageInstances[investmentId][page.id].instances
            const itemGroup = answer.item_group

            // Ensure we have enough instances
            while (instances.length <= itemGroup) {
              instances.push({})
            }

            // Store the answer
            instances[itemGroup][question.name] = answer.answer
          } else {
            // Answer with both item_group and parent_item_group (hierarchical subpage)
            if (!this.pageInstances[investmentId]) {
              this.pageInstances[investmentId] = {}
            }
            if (!this.pageInstances[investmentId][page.id]) {
              this.pageInstances[investmentId][page.id] = { instances: [], subpageInstances: {} }
            }

            const pageData = this.pageInstances[investmentId][page.id]
            if (!pageData.subpageInstances) {
              pageData.subpageInstances = {}
            }

            const parentItemGroup = answer.parent_item_group
            if (!pageData.subpageInstances[parentItemGroup]) {
              pageData.subpageInstances[parentItemGroup] = []
            }

            const instances = pageData.subpageInstances[parentItemGroup]
            const itemGroup = answer.item_group

            // Ensure we have enough instances
            while (instances.length <= itemGroup) {
              instances.push({})
            }

            // Store the answer
            instances[itemGroup][question.name] = answer.answer
          }
        }

      } catch (error) {
        console.error('Error loading existing answers:', error)
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
      // Prevent deselecting default investments
      const investment = this.availableInvestments.find(inv => inv.id === investmentId)
      if (investment?.is_default) {
        console.warn('Cannot deselect default investment')
        return
      }

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

    // ========================================================================
    // Shared Question Support
    // ========================================================================

    // Resolve question to master question ID if it's a shared instance
    // Returns: { questionId, actualQuestionId, question }
    // - questionId: The ID of the question we're working with (instance or master)
    // - actualQuestionId: The ID to use for database operations (always the master)
    // - question: The question object
    findQuestionAndResolveShared(questionName: string): {
      questionId: string
      actualQuestionId: string
      question: SurveyQuestion
    } | null {
      if (!this.activeInvestmentId) return null

      const pages = this.surveyPages[this.activeInvestmentId] || []

      for (const page of pages) {
        const questions = this.surveyQuestions[page.id] || []
        const question = questions.find(q => q.name === questionName)
        if (question) {
          // If this is a shared instance, resolve to master question ID
          const actualQuestionId = question.is_shared_instance && question.shared_question_id
            ? question.shared_question_id
            : question.id

          return {
            questionId: question.id,
            actualQuestionId,
            question
          }
        }
      }

      return null
    },

    // Save response for a question
    async saveResponse(questionName: string, value: any) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        const supabase = useSupabaseClient()

        // Find the question and resolve if it's a shared instance
        const questionInfo = this.findQuestionAndResolveShared(questionName)

        if (!questionInfo) {
          console.warn(`Question not found for name: ${questionName}`)
          return
        }

        const { actualQuestionId, question } = questionInfo

        // Update local state - if shared instance, update the master investment's state
        if (question.is_shared_instance && question.shared_question_id) {
          // Find the master question and its investment
          let masterInvestmentId: string | null = null
          let masterQuestionName: string | null = null

          for (const investmentId in this.surveyPages) {
            const pages = this.surveyPages[investmentId]
            for (const page of pages) {
              const questions = this.surveyQuestions[page.id] || []
              const masterQuestion = questions.find(q => q.id === actualQuestionId && !q.is_shared_instance)
              if (masterQuestion) {
                masterInvestmentId = investmentId
                masterQuestionName = masterQuestion.name
                break
              }
            }
            if (masterInvestmentId) break
          }

          if (masterInvestmentId && masterQuestionName) {
            // Update the master investment's state
            if (!this.investmentResponses[masterInvestmentId]) {
              this.investmentResponses[masterInvestmentId] = {}
            }
            this.investmentResponses[masterInvestmentId][masterQuestionName] = value
          }
        } else {
          // Not a shared instance, update current investment's state normally
          if (!this.investmentResponses[this.activeInvestmentId]) {
            this.investmentResponses[this.activeInvestmentId] = {}
          }
          this.investmentResponses[this.activeInvestmentId][questionName] = value
        }

        // Save to database using the actual question ID (master if shared, otherwise same as questionId)
        const { data: existing, error: checkError } = await supabase
          .from('survey_answers')
          .select('id')
          .eq('survey_id', this.currentSurveyId)
          .eq('survey_question_id', actualQuestionId)
          .is('item_group', null)
          .maybeSingle()

        if (checkError) throw checkError

        if (existing) {
          const { error: updateError } = await supabase
            .from('survey_answers')
            .update({ answer: String(value) })
            .eq('id', existing.id)
          if (updateError) throw updateError
        } else {
          const { error: insertError } = await supabase
            .from('survey_answers')
            .insert({
              survey_id: this.currentSurveyId,
              survey_question_id: actualQuestionId,
              answer: String(value),
              item_group: null
            })
          if (insertError) throw insertError
        }

        // Update dependent questions in frontend state (questions that use this as default_value_source)
        // Use the actual question ID for dependency sync
        await this.syncDependentQuestionsInState(actualQuestionId, String(value))

        // Refresh values that were copied by conditional copy rules
        await this.refreshCopiedValuesFromRules(actualQuestionId)

      } catch (error) {
        console.error('Error saving response:', error)
      }
    },

    // Get response for a question
    getResponse(questionName: string): any {
      if (!this.activeInvestmentId) return null

      // Find the question and resolve if it's a shared instance
      const questionInfo = this.findQuestionAndResolveShared(questionName)

      if (!questionInfo) {
        // Question not found, try direct lookup as fallback
        return this.investmentResponses[this.activeInvestmentId]?.[questionName]
      }

      const { question, actualQuestionId } = questionInfo

      // If this is a shared instance, we need to find the master question's investment
      if (question.is_shared_instance && question.shared_question_id) {
        // Find which investment contains the master question
        for (const investmentId in this.surveyPages) {
          const pages = this.surveyPages[investmentId]
          for (const page of pages) {
            const questions = this.surveyQuestions[page.id] || []
            const masterQuestion = questions.find(q => q.id === actualQuestionId && !q.is_shared_instance)
            if (masterQuestion) {
              // Found the master question - get the response from that investment
              return this.investmentResponses[investmentId]?.[masterQuestion.name]
            }
          }
        }
      }

      // Not a shared instance, or couldn't find master - use normal lookup
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

    // Ensure page instances are initialized with default values (call this when displaying allow_multiple pages)
    async ensurePageInstancesInitialized(pageId: string) {
      if (!this.activeInvestmentId) return

      // Get instances (this will create the first empty instance if needed)
      const instances = this.getPageInstances(pageId)

      // If we have exactly one instance and it's empty (no keys), it might need default values loaded
      if (instances.length === 1 && Object.keys(instances[0]).length === 0) {
        await this.loadDefaultValuesForInstance(pageId, 0)
      }
    },

    // Add a new instance for a page
    async addPageInstance(pageId: string) {
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

      // Load default values from source questions
      await this.loadDefaultValuesForInstance(pageId, newIndex)
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
        const supabase = useSupabaseClient()

        // Update local state
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

        // Save the value locally
        instances[instanceIndex][questionName] = value

        // Find the question and resolve if it's a shared instance
        const questions = this.surveyQuestions[pageId] || []
        const question = questions.find(q => q.name === questionName)

        if (!question) {
          console.warn(`Question not found for name: ${questionName}`)
          return
        }

        // Resolve to master question ID if this is a shared instance
        const actualQuestionId = question.is_shared_instance && question.shared_question_id
          ? question.shared_question_id
          : question.id

        // Save to database with item_group using the actual question ID (master if shared)
        const { data: existing, error: checkError } = await supabase
          .from('survey_answers')
          .select('id')
          .eq('survey_id', this.currentSurveyId)
          .eq('survey_question_id', actualQuestionId)
          .eq('item_group', instanceIndex)
          .maybeSingle()

        if (checkError) throw checkError

        if (existing) {
          // Update existing answer
          const { error: updateError } = await supabase
            .from('survey_answers')
            .update({ answer: String(value) })
            .eq('id', existing.id)

          if (updateError) throw updateError
        } else {
          // Insert new answer
          const { error: insertError } = await supabase
            .from('survey_answers')
            .insert({
              survey_id: this.currentSurveyId,
              survey_question_id: actualQuestionId,
              answer: String(value),
              item_group: instanceIndex
            })

          if (insertError) throw insertError
        }

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

    // Sync dependent questions in frontend state when a source question changes
    async syncDependentQuestionsInState(sourceQuestionId: string, newValue: string) {
      if (!this.currentSurveyId) return

      try {
        // Only sync if the source value is not empty
        // When source is empty, we want to keep the manually entered values in dependent fields
        const hasSourceValue = newValue !== undefined && newValue !== null && newValue !== ''

        if (!hasSourceValue) {
          // Source is empty, don't update dependent fields (they keep their manual values)
          return
        }

        // Find all questions that have this question as their default_value_source
        const dependentQuestions: Array<{
          question: SurveyQuestion
          pageId: string
          investmentId: string
        }> = []

        for (const investmentId in this.surveyPages) {
          const pages = this.surveyPages[investmentId]
          for (const page of pages) {
            const questions = this.surveyQuestions[page.id] || []
            for (const question of questions) {
              if (question.default_value_source_question_id === sourceQuestionId) {
                dependentQuestions.push({
                  question,
                  pageId: page.id,
                  investmentId
                })
              }
            }
          }
        }

        // Update each dependent question in the frontend state
        for (const dep of dependentQuestions) {
          const page = this.surveyPages[dep.investmentId]?.find(p => p.id === dep.pageId)

          if (!page) continue

          if (page.allow_multiple) {
            // For allow_multiple pages, update all existing instances
            const instances = this.pageInstances[dep.investmentId]?.[dep.pageId]?.instances || []

            for (let i = 0; i < instances.length; i++) {
              instances[i][dep.question.name] = newValue
            }
          } else {
            // For regular pages, update investmentResponses
            if (!this.investmentResponses[dep.investmentId]) {
              this.investmentResponses[dep.investmentId] = {}
            }
            this.investmentResponses[dep.investmentId][dep.question.name] = newValue
          }
        }

      } catch (error) {
        console.error('Error syncing dependent questions:', error)
      }
    },

    // Refresh values that were copied by conditional copy rules
    async refreshCopiedValuesFromRules(changedQuestionId: string) {
      if (!this.currentSurveyId) return

      try {
        const supabase = useSupabaseClient()

        // Query copy rules involving this question (as condition or source)
        const { data: rules, error: rulesError } = await supabase
          .from('survey_value_copy_rules')
          .select('*')
          .or(`condition_question_id.eq.${changedQuestionId},source_question_id.eq.${changedQuestionId}`)

        if (rulesError) throw rulesError
        if (!rules || rules.length === 0) return

        // Process each rule
        for (const rule of rules) {
          // Get the condition value to check if the rule should be applied
          const { data: conditionAnswers, error: conditionError } = await supabase
            .from('survey_answers')
            .select('answer')
            .eq('survey_id', this.currentSurveyId)
            .eq('survey_question_id', rule.condition_question_id)
            .is('item_group', null)
            .maybeSingle()

          if (conditionError) throw conditionError

          // Check if condition is met
          const conditionMet = conditionAnswers?.answer === rule.condition_value

          if (!conditionMet) {
            // Condition not met, skip this rule
            continue
          }

          // Find the target question to determine its page and investment
          let targetQuestionInfo: {
            question: SurveyQuestion
            page: SurveyPage
            investmentId: string
          } | null = null

          for (const investmentId in this.surveyPages) {
            const pages = this.surveyPages[investmentId]
            for (const page of pages) {
              const questions = this.surveyQuestions[page.id] || []
              const targetQuestion = questions.find(q => q.id === rule.target_question_id)
              if (targetQuestion) {
                targetQuestionInfo = {
                  question: targetQuestion,
                  page,
                  investmentId
                }
                break
              }
            }
            if (targetQuestionInfo) break
          }

          if (!targetQuestionInfo) {
            console.warn(`Target question not found: ${rule.target_question_id}`)
            continue
          }

          const { question: targetQuestion, page: targetPage, investmentId } = targetQuestionInfo

          // Only process if the target page allows multiple instances
          if (!targetPage.allow_multiple) {
            continue
          }

          // Reload all target instance values from database
          const { data: answers, error: answersError } = await supabase
            .from('survey_answers')
            .select('item_group, answer')
            .eq('survey_id', this.currentSurveyId)
            .eq('survey_question_id', rule.target_question_id)
            .not('item_group', 'is', null)

          if (answersError) throw answersError

          // Update frontend state with fresh values
          if (answers && answers.length > 0) {
            // Ensure the page instances structure exists
            if (!this.pageInstances[investmentId]) {
              this.pageInstances[investmentId] = {}
            }
            if (!this.pageInstances[investmentId][targetPage.id]) {
              this.pageInstances[investmentId][targetPage.id] = { instances: [] }
            }

            const instances = this.pageInstances[investmentId][targetPage.id].instances

            // Update each instance with the fresh value from database
            for (const answer of answers) {
              const itemGroup = answer.item_group

              // Ensure we have enough instances
              while (instances.length <= itemGroup) {
                instances.push({})
              }

              // Update the value in the frontend state
              instances[itemGroup][targetQuestion.name] = answer.answer
            }
          }
        }

      } catch (error) {
        console.error('Error refreshing copied values from rules:', error)
      }
    },

    // Load default values from source questions for an instance
    async loadDefaultValuesForInstance(pageId: string, instanceIndex: number) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        const supabase = useSupabaseClient()

        // Get all questions for this page
        const questions = this.surveyQuestions[pageId] || []

        // Find questions with default_value_source_question_id
        const questionsWithSource = questions.filter(q => q.default_value_source_question_id)

        if (questionsWithSource.length === 0) return

        // Get source question IDs
        const sourceQuestionIds = questionsWithSource
          .map(q => q.default_value_source_question_id)
          .filter((id): id is string => id !== undefined && id !== null)

        // Load source answers from database
        const { data: sourceAnswers, error } = await supabase
          .from('survey_answers')
          .select('survey_question_id, answer')
          .eq('survey_id', this.currentSurveyId)
          .in('survey_question_id', sourceQuestionIds)
          .is('item_group', null)

        if (error) throw error
        if (!sourceAnswers || sourceAnswers.length === 0) return

        // Create a map: sourceQuestionId -> answer
        const sourceAnswerMap = new Map<string, string>()
        sourceAnswers.forEach(sa => {
          sourceAnswerMap.set(sa.survey_question_id, sa.answer)
        })

        // Set default values and save to database
        for (const question of questionsWithSource) {
          if (!question.default_value_source_question_id) continue

          const sourceAnswer = sourceAnswerMap.get(question.default_value_source_question_id)
          if (sourceAnswer !== undefined) {
            // Save to local state and database
            await this.saveInstanceResponse(pageId, instanceIndex, question.name, sourceAnswer)
          }
        }

      } catch (error) {
        console.error('Error loading default values for instance:', error)
      }
    },

    // ========================================================================
    // Hierarchical Subpage Instances Management
    // ========================================================================

    // Get instances for a hierarchical subpage under a specific parent instance
    getSubPageInstances(subpageId: string, parentItemGroup: number): Record<string, any>[] {
      if (!this.activeInvestmentId) return []

      // Initialize if doesn't exist
      if (!this.pageInstances[this.activeInvestmentId]) {
        this.pageInstances[this.activeInvestmentId] = {}
      }
      if (!this.pageInstances[this.activeInvestmentId][subpageId]) {
        this.pageInstances[this.activeInvestmentId][subpageId] = { instances: [], subpageInstances: {} }
      }

      const pageData = this.pageInstances[this.activeInvestmentId][subpageId]
      if (!pageData.subpageInstances) {
        pageData.subpageInstances = {}
      }

      if (!pageData.subpageInstances[parentItemGroup]) {
        pageData.subpageInstances[parentItemGroup] = [{}] // Initialize with one empty instance
      }

      return pageData.subpageInstances[parentItemGroup]
    },

    // Add a new instance for a hierarchical subpage
    async addSubPageInstance(subpageId: string, parentItemGroup: number) {
      if (!this.activeInvestmentId) return

      // Initialize if doesn't exist
      if (!this.pageInstances[this.activeInvestmentId]) {
        this.pageInstances[this.activeInvestmentId] = {}
      }
      if (!this.pageInstances[this.activeInvestmentId][subpageId]) {
        this.pageInstances[this.activeInvestmentId][subpageId] = { instances: [], subpageInstances: {} }
      }

      const pageData = this.pageInstances[this.activeInvestmentId][subpageId]
      if (!pageData.subpageInstances) {
        pageData.subpageInstances = {}
      }

      if (!pageData.subpageInstances[parentItemGroup]) {
        pageData.subpageInstances[parentItemGroup] = []
      }

      // Add new instance
      pageData.subpageInstances[parentItemGroup].push({})

      // Load default values for the new instance
      const newIndex = pageData.subpageInstances[parentItemGroup].length - 1
      await this.loadDefaultValuesForSubPageInstance(subpageId, parentItemGroup, newIndex)
    },

    // Remove an instance from a hierarchical subpage
    removeSubPageInstance(subpageId: string, parentItemGroup: number, index: number, allowDeleteLast: boolean = false) {
      if (!this.activeInvestmentId) return

      const instances = this.pageInstances[this.activeInvestmentId]?.[subpageId]?.subpageInstances?.[parentItemGroup]
      if (!instances || instances.length === 0) return

      // Remove the instance
      instances.splice(index, 1)

      // Ensure at least one instance exists (unless allowDeleteLast is true)
      if (instances.length === 0 && !allowDeleteLast) {
        instances.push({})
      }
    },

    // Save response for a question in a hierarchical subpage instance
    async saveSubPageInstanceResponse(
      subpageId: string,
      parentItemGroup: number,
      instanceIndex: number,
      questionName: string,
      value: any
    ) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        const supabase = useSupabaseClient()

        // Update local state
        if (!this.pageInstances[this.activeInvestmentId]) {
          this.pageInstances[this.activeInvestmentId] = {}
        }
        if (!this.pageInstances[this.activeInvestmentId][subpageId]) {
          this.pageInstances[this.activeInvestmentId][subpageId] = { instances: [], subpageInstances: {} }
        }

        const pageData = this.pageInstances[this.activeInvestmentId][subpageId]
        if (!pageData.subpageInstances) {
          pageData.subpageInstances = {}
        }

        if (!pageData.subpageInstances[parentItemGroup]) {
          pageData.subpageInstances[parentItemGroup] = []
        }

        const instances = pageData.subpageInstances[parentItemGroup]

        // Ensure instance exists
        while (instances.length <= instanceIndex) {
          instances.push({})
        }

        // Save the value locally
        instances[instanceIndex][questionName] = value

        // Find the question and resolve if it's a shared instance
        const questions = this.surveyQuestions[subpageId] || []
        const question = questions.find(q => q.name === questionName)

        if (!question) {
          console.warn(`Question not found for name: ${questionName}`)
          return
        }

        // Resolve to master question ID if this is a shared instance
        const actualQuestionId = question.is_shared_instance && question.shared_question_id
          ? question.shared_question_id
          : question.id

        // Save to database with both item_group and parent_item_group using the actual question ID (master if shared)
        const { data: existing, error: checkError } = await supabase
          .from('survey_answers')
          .select('id')
          .eq('survey_id', this.currentSurveyId)
          .eq('survey_question_id', actualQuestionId)
          .eq('item_group', instanceIndex)
          .eq('parent_item_group', parentItemGroup)
          .maybeSingle()

        if (checkError) throw checkError

        if (existing) {
          // Update existing answer
          const { error: updateError } = await supabase
            .from('survey_answers')
            .update({ answer: String(value) })
            .eq('id', existing.id)

          if (updateError) throw updateError
        } else {
          // Insert new answer
          const { error: insertError } = await supabase
            .from('survey_answers')
            .insert({
              survey_id: this.currentSurveyId,
              survey_question_id: actualQuestionId,
              answer: String(value),
              item_group: instanceIndex,
              parent_item_group: parentItemGroup
            })

          if (insertError) throw insertError
        }

      } catch (error) {
        console.error('Error saving subpage instance response:', error)
      }
    },

    // Get response for a question in a hierarchical subpage instance
    getSubPageInstanceResponse(
      subpageId: string,
      parentItemGroup: number,
      instanceIndex: number,
      questionName: string
    ): any {
      if (!this.activeInvestmentId) return null

      const instances = this.pageInstances[this.activeInvestmentId]?.[subpageId]?.subpageInstances?.[parentItemGroup]
      if (!instances || instanceIndex >= instances.length) return null

      return instances[instanceIndex]?.[questionName]
    },

    // Load default values from source questions for a subpage instance
    async loadDefaultValuesForSubPageInstance(subpageId: string, parentItemGroup: number, instanceIndex: number) {
      if (!this.activeInvestmentId || !this.currentSurveyId) return

      try {
        const supabase = useSupabaseClient()

        // Get all questions for this subpage
        const questions = this.surveyQuestions[subpageId] || []

        // Find questions with default_value_source_question_id
        const questionsWithSource = questions.filter(q => q.default_value_source_question_id)

        if (questionsWithSource.length === 0) return

        // Get source question IDs
        const sourceQuestionIds = questionsWithSource
          .map(q => q.default_value_source_question_id)
          .filter((id): id is string => id !== undefined && id !== null)

        // Load source answers from database
        const { data: sourceAnswers, error } = await supabase
          .from('survey_answers')
          .select('survey_question_id, answer')
          .eq('survey_id', this.currentSurveyId)
          .in('survey_question_id', sourceQuestionIds)
          .is('item_group', null)

        if (error) throw error
        if (!sourceAnswers || sourceAnswers.length === 0) return

        // Create a map: sourceQuestionId -> answer
        const sourceAnswerMap = new Map<string, string>()
        sourceAnswers.forEach(sa => {
          sourceAnswerMap.set(sa.survey_question_id, sa.answer)
        })

        // Set default values and save to database
        for (const question of questionsWithSource) {
          if (!question.default_value_source_question_id) continue

          const sourceAnswer = sourceAnswerMap.get(question.default_value_source_question_id)
          if (sourceAnswer !== undefined) {
            // Save to local state and database
            await this.saveSubPageInstanceResponse(subpageId, parentItemGroup, instanceIndex, question.name, sourceAnswer)
          }
        }

      } catch (error) {
        console.error('Error loading default values for subpage instance:', error)
      }
    },

    // Update photo count for a category
    updateCategoryPhotoCount(categoryId: string, count: number) {
      this.categoryPhotoCounts[categoryId] = count
    },

    // Get photo count for a category
    getCategoryPhotoCount(categoryId: string): number {
      return this.categoryPhotoCounts[categoryId] || 0
    },

    // Load all photo counts from database
    async loadCategoryPhotoCounts(surveyId: string) {
      try {
        console.log('📊 Loading photo counts for survey:', surveyId)
        const supabase = useSupabaseClient()

        // Get all documents for this survey grouped by category
        const { data, error } = await supabase
          .from('documents')
          .select('document_category_id')
          .eq('survey_id', surveyId)

        if (error) throw error

        console.log('📊 Documents from database:', data)

        // Count documents per category
        const counts: Record<string, number> = {}
        data?.forEach(doc => {
          const categoryId = doc.document_category_id
          counts[categoryId] = (counts[categoryId] || 0) + 1
        })

        // Update store
        this.categoryPhotoCounts = counts
        console.log('✅ Photo counts loaded:', counts)
      } catch (error) {
        console.error('❌ Error loading category photo counts:', error)
      }
    },
  }
})
