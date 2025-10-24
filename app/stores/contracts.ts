import { defineStore } from 'pinia'
import { useSupabaseClient } from '#imports'

export interface Contract {
  id: string
  name: string
  scenario_id?: string | null
  survey_id?: string | null
  contract_mode: 'offer' | 'contract'
  status: 'draft' | 'sent' | 'accepted' | 'rejected'
  commission_rate: number
  vat: number
  total_price: number
  roof_configuration?: any
  notes?: string
  created_at: string
  updated_at: string
}

export interface ContractMainComponent {
  id: string
  contract_id: string
  main_component_id: string
  investment_id: string
  quantity: number
  price_snapshot: number
}

export interface ContractInvestment {
  contract_id: string
  investment_id: string
}

export interface ContractExtraCost {
  id: string
  contract_id: string
  extra_cost_id: string
  snapshot_price: number
  quantity?: number
  comment?: string
}

export interface ContractDiscount {
  id: string
  contract_id: string
  discount_id: string
  discount_snapshot: number
}

export const useContractsStore = defineStore('contracts', {
  state: () => ({
    contracts: [] as Contract[],
    activeContractId: null as string | null,
    contractMainComponents: {} as Record<string, ContractMainComponent[]>,
    contractInvestments: {} as Record<string, string[]>,
    contractExtraCosts: {} as Record<string, ContractExtraCost[]>,
    contractDiscounts: {} as Record<string, ContractDiscount[]>,
    loading: false
  }),

  getters: {
    activeContract: (state) => {
      if (!state.activeContractId) return null
      return state.contracts.find(c => c.id === state.activeContractId) || null
    },

    activeContractComponents: (state) => {
      if (!state.activeContractId) return []
      return state.contractMainComponents[state.activeContractId] || []
    },

    activeContractInvestments: (state) => {
      if (!state.activeContractId) return []
      return state.contractInvestments[state.activeContractId] || []
    },

    activeContractExtraCosts: (state) => {
      if (!state.activeContractId) return []
      return state.contractExtraCosts[state.activeContractId] || []
    },

    activeContractDiscounts: (state) => {
      if (!state.activeContractId) return []
      return state.contractDiscounts[state.activeContractId] || []
    }
  },

  actions: {
    async loadContracts(surveyId: string) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        // Load contracts
        const { data: contracts, error: contractsError } = await supabase
          .from('contracts')
          .select('*')
          .eq('survey_id', surveyId)
          .order('created_at', { ascending: false })

        if (contractsError) throw contractsError

        this.contracts = contracts || []

        // Load related data for all contracts
        if (this.contracts.length > 0) {
          const contractIds = this.contracts.map(c => c.id)

          // Load contract investments
          const { data: contractInvestments, error: ciError } = await supabase
            .from('contract_investments')
            .select('*')
            .in('contract_id', contractIds)

          if (ciError) throw ciError

          // Group by contract_id
          this.contractInvestments = {}
          contractInvestments?.forEach(ci => {
            if (!this.contractInvestments[ci.contract_id]) {
              this.contractInvestments[ci.contract_id] = []
            }
            this.contractInvestments[ci.contract_id].push(ci.investment_id)
          })

          // Load contract main components
          const { data: contractComponents, error: ccError } = await supabase
            .from('contract_main_components')
            .select('*')
            .in('contract_id', contractIds)

          if (ccError) throw ccError

          // Group by contract_id
          this.contractMainComponents = {}
          contractComponents?.forEach(cc => {
            if (!this.contractMainComponents[cc.contract_id]) {
              this.contractMainComponents[cc.contract_id] = []
            }
            this.contractMainComponents[cc.contract_id].push(cc)
          })

          // Load contract extra costs
          const { data: contractExtraCosts, error: ecError } = await supabase
            .from('contract_extra_costs')
            .select('*')
            .in('contract_id', contractIds)

          if (ecError) throw ecError

          // Group by contract_id
          this.contractExtraCosts = {}
          contractExtraCosts?.forEach(ec => {
            if (!this.contractExtraCosts[ec.contract_id]) {
              this.contractExtraCosts[ec.contract_id] = []
            }
            this.contractExtraCosts[ec.contract_id].push(ec)
          })

          // Load contract discounts
          const { data: contractDiscounts, error: cdError } = await supabase
            .from('contract_discounts')
            .select('*')
            .in('contract_id', contractIds)

          if (cdError) throw cdError

          // Group by contract_id
          this.contractDiscounts = {}
          contractDiscounts?.forEach(cd => {
            if (!this.contractDiscounts[cd.contract_id]) {
              this.contractDiscounts[cd.contract_id] = []
            }
            this.contractDiscounts[cd.contract_id].push(cd)
          })
        }
      } catch (error) {
        console.error('Error loading contracts:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async createContract(data: {
      name: string
      scenario_id?: string | null
      survey_id?: string | null
      contract_mode: 'offer' | 'contract'
      commission_rate: number
      vat: number
      total_price: number
      roof_configuration?: any
      notes?: string
      main_components: Array<{ main_component_id: string; investment_id: string; quantity: number; price_snapshot: number }>
      investments: string[]
      solar_extra_costs: Array<{ extra_cost_id: string; snapshot_price: number; quantity?: number; comment?: string }>
      general_extra_costs: Array<{ extra_cost_id: string; snapshot_price: number; quantity?: number; comment?: string }>
      discounts: Array<{ discount_id: string; discount_snapshot: number }>
    }) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        // 1. Create contract
        const { data: contract, error: contractError } = await supabase
          .from('contracts')
          .insert({
            name: data.name,
            scenario_id: data.scenario_id,
            survey_id: data.survey_id,
            contract_mode: data.contract_mode,
            commission_rate: data.commission_rate,
            vat: data.vat,
            total_price: data.total_price,
            roof_configuration: data.roof_configuration,
            notes: data.notes
          })
          .select()
          .single()

        if (contractError) throw contractError

        const contractId = contract.id

        // 2. Insert main components
        if (data.main_components.length > 0) {
          const { error: componentsError } = await supabase
            .from('contract_main_components')
            .insert(
              data.main_components.map(mc => ({
                contract_id: contractId,
                main_component_id: mc.main_component_id,
                investment_id: mc.investment_id,
                quantity: mc.quantity,
                price_snapshot: mc.price_snapshot
              }))
            )

          if (componentsError) throw componentsError
        }

        // 3. Insert investments
        if (data.investments.length > 0) {
          const { error: investmentsError } = await supabase
            .from('contract_investments')
            .insert(
              data.investments.map(inv_id => ({
                contract_id: contractId,
                investment_id: inv_id
              }))
            )

          if (investmentsError) throw investmentsError
        }

        // 4. Insert extra costs (solar + general)
        const allExtraCosts = [...data.solar_extra_costs, ...data.general_extra_costs]
        if (allExtraCosts.length > 0) {
          const { error: extraCostsError } = await supabase
            .from('contract_extra_costs')
            .insert(
              allExtraCosts.map(ec => ({
                contract_id: contractId,
                extra_cost_id: ec.extra_cost_id,
                snapshot_price: ec.snapshot_price,
                quantity: ec.quantity,
                comment: ec.comment
              }))
            )

          if (extraCostsError) throw extraCostsError
        }

        // 5. Insert discounts
        if (data.discounts.length > 0) {
          const { error: discountsError } = await supabase
            .from('contract_discounts')
            .insert(
              data.discounts.map(d => ({
                contract_id: contractId,
                discount_id: d.discount_id,
                discount_snapshot: d.discount_snapshot
              }))
            )

          if (discountsError) throw discountsError
        }

        // Reload contracts
        if (data.survey_id) {
          await this.loadContracts(data.survey_id)
        }

        // Set as active
        this.activeContractId = contractId

        return contract
      } catch (error) {
        console.error('Error creating contract:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateContract(contractId: string, data: {
      name?: string
      contract_mode?: 'offer' | 'contract'
      commission_rate?: number
      vat?: number
      total_price?: number
      roof_configuration?: any
      notes?: string
      main_components?: Array<{ main_component_id: string; investment_id: string; quantity: number; price_snapshot: number }>
      investments?: string[]
      solar_extra_costs?: Array<{ extra_cost_id: string; snapshot_price: number; quantity?: number; comment?: string }>
      general_extra_costs?: Array<{ extra_cost_id: string; snapshot_price: number; quantity?: number; comment?: string }>
      discounts?: Array<{ discount_id: string; discount_snapshot: number }>
    }) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        // Find contract to get survey_id
        const contract = this.contracts.find(c => c.id === contractId)
        if (!contract) throw new Error('Contract not found')

        // 1. Update contract basic fields
        const updateData: any = {}
        if (data.name !== undefined) updateData.name = data.name
        if (data.contract_mode !== undefined) updateData.contract_mode = data.contract_mode
        if (data.commission_rate !== undefined) updateData.commission_rate = data.commission_rate
        if (data.vat !== undefined) updateData.vat = data.vat
        if (data.total_price !== undefined) updateData.total_price = data.total_price
        if (data.roof_configuration !== undefined) updateData.roof_configuration = data.roof_configuration
        if (data.notes !== undefined) updateData.notes = data.notes

        if (Object.keys(updateData).length > 0) {
          const { error: contractError } = await supabase
            .from('contracts')
            .update(updateData)
            .eq('id', contractId)

          if (contractError) throw contractError
        }

        // 2. Update main components (delete all and re-insert)
        if (data.main_components !== undefined) {
          await supabase
            .from('contract_main_components')
            .delete()
            .eq('contract_id', contractId)

          if (data.main_components.length > 0) {
            const { error: componentsError } = await supabase
              .from('contract_main_components')
              .insert(
                data.main_components.map(mc => ({
                  contract_id: contractId,
                  main_component_id: mc.main_component_id,
                  investment_id: mc.investment_id,
                  quantity: mc.quantity,
                  price_snapshot: mc.price_snapshot
                }))
              )

            if (componentsError) throw componentsError
          }
        }

        // 3. Update investments
        if (data.investments !== undefined) {
          await supabase
            .from('contract_investments')
            .delete()
            .eq('contract_id', contractId)

          if (data.investments.length > 0) {
            const { error: investmentsError } = await supabase
              .from('contract_investments')
              .insert(
                data.investments.map(inv_id => ({
                  contract_id: contractId,
                  investment_id: inv_id
                }))
              )

            if (investmentsError) throw investmentsError
          }
        }

        // 4. Update extra costs
        if (data.solar_extra_costs !== undefined || data.general_extra_costs !== undefined) {
          await supabase
            .from('contract_extra_costs')
            .delete()
            .eq('contract_id', contractId)

          const allExtraCosts = [
            ...(data.solar_extra_costs || []),
            ...(data.general_extra_costs || [])
          ]

          if (allExtraCosts.length > 0) {
            const { error: extraCostsError } = await supabase
              .from('contract_extra_costs')
              .insert(
                allExtraCosts.map(ec => ({
                  contract_id: contractId,
                  extra_cost_id: ec.extra_cost_id,
                  snapshot_price: ec.snapshot_price,
                  quantity: ec.quantity,
                  comment: ec.comment
                }))
              )

            if (extraCostsError) throw extraCostsError
          }
        }

        // 5. Update discounts
        if (data.discounts !== undefined) {
          await supabase
            .from('contract_discounts')
            .delete()
            .eq('contract_id', contractId)

          if (data.discounts.length > 0) {
            const { error: discountsError } = await supabase
              .from('contract_discounts')
              .insert(
                data.discounts.map(d => ({
                  contract_id: contractId,
                  discount_id: d.discount_id,
                  discount_snapshot: d.discount_snapshot
                }))
              )

            if (discountsError) throw discountsError
          }
        }

        // Reload contracts
        if (contract.survey_id) {
          await this.loadContracts(contract.survey_id)
        }
      } catch (error) {
        console.error('Error updating contract:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteContract(contractId: string) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        // Find contract to get survey_id
        const contract = this.contracts.find(c => c.id === contractId)
        if (!contract) throw new Error('Contract not found')

        const { error } = await supabase
          .from('contracts')
          .delete()
          .eq('id', contractId)

        if (error) throw error

        // Clear active contract if it was deleted
        if (this.activeContractId === contractId) {
          this.activeContractId = null
        }

        // Reload contracts
        if (contract.survey_id) {
          await this.loadContracts(contract.survey_id)
        }
      } catch (error) {
        console.error('Error deleting contract:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async duplicateContract(contractId: string) {
      this.loading = true

      try {
        const contract = this.contracts.find(c => c.id === contractId)
        if (!contract) throw new Error('Contract not found')

        // Get all related data
        const components = this.contractMainComponents[contractId] || []
        const investments = this.contractInvestments[contractId] || []
        const extraCosts = this.contractExtraCosts[contractId] || []
        const discounts = this.contractDiscounts[contractId] || []

        // Generate new name
        const baseName = contract.name.replace(/ \d+$/, '') // Remove trailing number
        const existingNumbers = this.contracts
          .filter(c => c.name.startsWith(baseName))
          .map(c => {
            const match = c.name.match(/(\d+)$/)
            return match ? parseInt(match[1]) : 0
          })
        const nextNumber = Math.max(...existingNumbers, 0) + 1
        const newName = `${baseName} ${nextNumber}`

        // Create new contract with same data
        await this.createContract({
          name: newName,
          scenario_id: contract.scenario_id,
          survey_id: contract.survey_id,
          contract_mode: contract.contract_mode,
          commission_rate: contract.commission_rate,
          vat: contract.vat,
          total_price: contract.total_price,
          roof_configuration: contract.roof_configuration,
          notes: contract.notes,
          main_components: components.map(c => ({
            main_component_id: c.main_component_id,
            investment_id: c.investment_id,
            quantity: c.quantity,
            price_snapshot: c.price_snapshot
          })),
          investments,
          solar_extra_costs: extraCosts
            .filter(ec => ec.extra_cost_id.includes('solar'))
            .map(ec => ({
              extra_cost_id: ec.extra_cost_id,
              snapshot_price: ec.snapshot_price,
              quantity: ec.quantity,
              comment: ec.comment
            })),
          general_extra_costs: extraCosts
            .filter(ec => !ec.extra_cost_id.includes('solar'))
            .map(ec => ({
              extra_cost_id: ec.extra_cost_id,
              snapshot_price: ec.snapshot_price,
              quantity: ec.quantity,
              comment: ec.comment
            })),
          discounts: discounts.map(d => ({
            discount_id: d.discount_id,
            discount_snapshot: d.discount_snapshot
          }))
        })
      } catch (error) {
        console.error('Error duplicating contract:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async renameContract(contractId: string, newName: string) {
      this.loading = true

      try {
        const supabase = useSupabaseClient()

        const { error } = await supabase
          .from('contracts')
          .update({ name: newName })
          .eq('id', contractId)

        if (error) throw error

        // Update local state
        const contract = this.contracts.find(c => c.id === contractId)
        if (contract) {
          contract.name = newName
        }
      } catch (error) {
        console.error('Error renaming contract:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    setActiveContract(contractId: string | null) {
      this.activeContractId = contractId
    },

    // Helper to generate next contract name
    getNextContractName(): string {
      const existingNumbers = this.contracts
        .filter(c => c.name.match(/^Contract \d+$/))
        .map(c => {
          const match = c.name.match(/(\d+)$/)
          return match ? parseInt(match[1]) : 0
        })
      const nextNumber = existingNumbers.length > 0 ? Math.max(...existingNumbers) + 1 : 1
      return `Contract ${nextNumber}`
    }
  }
})
