import { defineStore } from 'pinia'
import { useSupabaseClient } from '#imports'

export interface Scenario {
  id: string
  survey_id: string
  name: string
  sequence: number
  description?: string
  created_at: string
  updated_at: string
}

export interface ScenarioInvestment {
  scenario_id: string
  investment_id: string
}

export interface ScenarioMainComponent {
  id: string
  scenario_id: string
  main_component_id: string
  investment_id: string
  quantity: number
  price_snapshot: number
}

export interface MainComponent {
  id: string
  name: string
  persist_name: string
  unit: string
  price: number
  main_component_category_id: string
  manufacturer?: string
  details?: string
  power?: number
  capacity?: number
  efficiency?: number
  u_value?: number
  thickness?: number
  cop?: number
  energy_class?: string
  sequence: number
}

export interface MainComponentCategory {
  id: string
  persist_name: string
  sequence: number
}

export const useScenariosStore = defineStore('scenarios', {
  state: () => ({
    scenarios: [] as Scenario[],
    activeScenarioId: null as string | null,
    scenarioInvestments: {} as Record<string, string[]>, // scenarioId -> investmentIds
    scenarioComponents: {} as Record<string, ScenarioMainComponent[]>, // scenarioId -> components
    mainComponents: [] as MainComponent[],
    mainComponentCategories: [] as MainComponentCategory[],
    categoryInvestments: {} as Record<string, string[]>, // categoryId -> investmentIds
    loading: false
  }),

  getters: {
    activeScenario: (state) => {
      if (!state.activeScenarioId) return null
      return state.scenarios.find(s => s.id === state.activeScenarioId) || null
    },

    activeScenarioInvestments: (state) => {
      if (!state.activeScenarioId) return []
      return state.scenarioInvestments[state.activeScenarioId] || []
    },

    activeScenarioComponents: (state) => {
      if (!state.activeScenarioId) return []
      return state.scenarioComponents[state.activeScenarioId] || []
    },

    getComponentsByCategoryId: (state) => (categoryId: string) => {
      return state.mainComponents
        .filter(c => c.main_component_category_id === categoryId)
        .sort((a, b) => (a.sequence || 0) - (b.sequence || 0))
    },

    getCategoriesForInvestment: (state) => (investmentId: string) => {
      // Get category IDs that belong to this investment
      const categoryIds = Object.entries(state.categoryInvestments)
        .filter(([_, invIds]) => invIds.includes(investmentId))
        .map(([catId]) => catId)

      return state.mainComponentCategories
        .filter(cat => categoryIds.includes(cat.id))
        .sort((a, b) => (a.sequence || 0) - (b.sequence || 0))
    },

    getScenarioComponentForCategory: (state) => (categoryId: string, scenarioId?: string, investmentId?: string) => {
      const targetScenarioId = scenarioId || state.activeScenarioId
      if (!targetScenarioId) return []

      const scenarioComponents = state.scenarioComponents[targetScenarioId] || []

      return scenarioComponents.filter(sc => {
        const component = state.mainComponents.find(mc => mc.id === sc.main_component_id)
        const categoryMatch = component?.main_component_category_id === categoryId
        const investmentMatch = investmentId ? sc.investment_id === investmentId : true
        return categoryMatch && investmentMatch
      })
    }
  },

  actions: {
    async loadScenarios(surveyId: string) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        // Load scenarios
        const { data: scenarios, error: scenariosError } = await supabase
          .from('scenarios')
          .select('*')
          .eq('survey_id', surveyId)
          .order('sequence')

        if (scenariosError) throw scenariosError

        this.scenarios = scenarios || []

        // Set first scenario as active if available
        if (this.scenarios.length > 0 && !this.activeScenarioId) {
          this.activeScenarioId = this.scenarios[0].id
        }

        // Load scenario investments
        if (this.scenarios.length > 0) {
          const scenarioIds = this.scenarios.map(s => s.id)

          const { data: scenarioInvestments, error: siError } = await supabase
            .from('scenario_investments')
            .select('*')
            .in('scenario_id', scenarioIds)

          if (siError) throw siError

          // Group by scenario_id
          this.scenarioInvestments = {}
          scenarioInvestments?.forEach(si => {
            if (!this.scenarioInvestments[si.scenario_id]) {
              this.scenarioInvestments[si.scenario_id] = []
            }
            this.scenarioInvestments[si.scenario_id].push(si.investment_id)
          })

          // Load scenario main components
          const { data: scenarioComponents, error: scError } = await supabase
            .from('scenario_main_components')
            .select('*')
            .in('scenario_id', scenarioIds)

          if (scError) throw scError

          // Group by scenario_id
          this.scenarioComponents = {}
          scenarioComponents?.forEach(sc => {
            if (!this.scenarioComponents[sc.scenario_id]) {
              this.scenarioComponents[sc.scenario_id] = []
            }
            this.scenarioComponents[sc.scenario_id].push(sc)
          })
        }

        // Load all main components and categories
        await this.loadMainComponentsData()

      } catch (error) {
        console.error('Error loading scenarios:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async loadMainComponentsData() {
      const supabase = useSupabaseClient()

      // Load main component categories
      const { data: categories, error: catError } = await supabase
        .from('main_component_categories')
        .select('*')
        .order('sequence')

      if (catError) throw catError
      this.mainComponentCategories = categories || []

      // Load main components
      const { data: components, error: compError } = await supabase
        .from('main_components')
        .select('*')
        .order('sequence')

      if (compError) throw compError
      this.mainComponents = components || []

      // Load category-investment relationships
      const { data: catInvestments, error: ciError } = await supabase
        .from('main_component_category_investments')
        .select('main_component_category_id, investment_id')

      if (ciError) throw ciError

      // Group by category_id
      this.categoryInvestments = {}
      catInvestments?.forEach(ci => {
        if (!this.categoryInvestments[ci.main_component_category_id]) {
          this.categoryInvestments[ci.main_component_category_id] = []
        }
        this.categoryInvestments[ci.main_component_category_id].push(ci.investment_id)
      })
    },

    setActiveScenario(scenarioId: string) {
      this.activeScenarioId = scenarioId
    },

    async updateComponentQuantity(componentId: string, quantity: number, scenarioId?: string) {
      const targetScenarioId = scenarioId || this.activeScenarioId
      if (!targetScenarioId) return

      const supabase = useSupabaseClient()

      const { error } = await supabase
        .from('scenario_main_components')
        .update({ quantity })
        .eq('id', componentId)

      if (error) {
        console.error('Error updating component quantity:', error)
        throw error
      }

      // Update local state
      const scenarioComponents = this.scenarioComponents[targetScenarioId]
      if (scenarioComponents) {
        const component = scenarioComponents.find(c => c.id === componentId)
        if (component) {
          component.quantity = quantity
        }
      }
    },

    async updateScenarioComponent(componentId: string, mainComponentId: string, quantity?: number, scenarioId?: string) {
      const targetScenarioId = scenarioId || this.activeScenarioId
      if (!targetScenarioId) return

      const supabase = useSupabaseClient()

      // Get the new component to get its price
      const newComponent = this.mainComponents.find(c => c.id === mainComponentId)
      if (!newComponent) return

      const updateData: any = {
        main_component_id: mainComponentId,
        price_snapshot: newComponent.price
      }

      if (quantity !== undefined) {
        updateData.quantity = quantity
      }

      const { error } = await supabase
        .from('scenario_main_components')
        .update(updateData)
        .eq('id', componentId)

      if (error) {
        console.error('Error updating scenario component:', error)
        throw error
      }

      // Update local state
      const scenarioComponents = this.scenarioComponents[targetScenarioId]
      if (scenarioComponents) {
        const component = scenarioComponents.find(c => c.id === componentId)
        if (component) {
          component.main_component_id = mainComponentId
          component.price_snapshot = newComponent.price
          if (quantity !== undefined) {
            component.quantity = quantity
          }
        }
      }
    },

    async addScenarioComponent(mainComponentId: string, quantity: number, investmentId: string, scenarioId?: string) {
      const targetScenarioId = scenarioId || this.activeScenarioId
      if (!targetScenarioId) return

      const supabase = useSupabaseClient()

      // Get the component to get its price
      const component = this.mainComponents.find(c => c.id === mainComponentId)
      if (!component) return

      const { data, error } = await supabase
        .from('scenario_main_components')
        .insert({
          scenario_id: targetScenarioId,
          main_component_id: mainComponentId,
          investment_id: investmentId,
          quantity,
          price_snapshot: component.price
        })
        .select()
        .single()

      if (error) {
        console.error('Error adding scenario component:', error)
        throw error
      }

      // Update local state
      if (!this.scenarioComponents[targetScenarioId]) {
        this.scenarioComponents[targetScenarioId] = []
      }
      this.scenarioComponents[targetScenarioId].push(data)
    },

    async removeScenarioComponent(componentId: string, scenarioId?: string) {
      const targetScenarioId = scenarioId || this.activeScenarioId
      if (!targetScenarioId) return

      const supabase = useSupabaseClient()

      const { error } = await supabase
        .from('scenario_main_components')
        .delete()
        .eq('id', componentId)

      if (error) {
        console.error('Error removing scenario component:', error)
        throw error
      }

      // Update local state
      const scenarioComponents = this.scenarioComponents[targetScenarioId]
      if (scenarioComponents) {
        const index = scenarioComponents.findIndex(c => c.id === componentId)
        if (index > -1) {
          scenarioComponents.splice(index, 1)
        }
      }
    },

    getMainComponentById(componentId: string): MainComponent | undefined {
      return this.mainComponents.find(c => c.id === componentId)
    }
  }
})
