export interface Subsidy {
  id: string
  created_at: string
  updated_at: string
  name: string
  description: string | null
  target_group: string
  discount_type: 'percentage' | 'fixed'
  discount_value: number
  sequence: number
}

export interface SurveySubsidy {
  survey_id: string
  subsidy_id: string
  is_enabled: boolean
  created_at: string
  updated_at: string
}

export interface SubsidyWithEnabled extends Subsidy {
  is_enabled: boolean
}

export interface EligibilityConditions {
  builtBefore2010: boolean
  energyClassE: boolean
  familyHouse: boolean
  energyImprovement30Percent: boolean
  hasEnergyAudit: boolean
  builtBefore2007: boolean
  notSmallSettlement: boolean
  smallSettlement: boolean
  ownershipMinimum50Percent: boolean
  hungarianCitizen: boolean
  minSelfFunding: boolean
}
