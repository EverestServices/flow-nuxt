/**
 * New Survey System Types
 * Generated based on the survey system database structure
 */

// ============================================================================
// ENUMS
// ============================================================================

export type ElectricCarStatus = 'existing' | 'planned'
export type HeavyConsumerStatus = 'existing' | 'planned'
export type SurveyQuestionType =
  | 'text'
  | 'textarea'
  | 'switch'
  | 'dropdown'
  | 'title'
  | 'phase_toggle'
  | 'dual_toggle'
  | 'slider'
  | 'range'
  | 'number'
  | 'orientation_selector'
  | 'warning'
  | 'calculated'

// ============================================================================
// DATABASE TYPES
// ============================================================================

export interface Client {
  id: string
  created_at: string
  updated_at: string
  company_id: string
  name: string
  email: string | null
  phone: string | null
  postal_code: string | null
  city: string | null
  street: string | null
  house_number: string | null
  contact_person: string | null
  notes: string | null
  status: 'active' | 'inactive' | 'archived'
  user_id: string | null
}

export interface Survey {
  id: string
  created_at: string
  updated_at: string
  client_id: string
  user_id: string | null
  company_id: string
  at: string | null // DATE type
  first_opened_at: string | null // TIMESTAMPTZ type
}

export interface Investment {
  id: string
  created_at: string
  updated_at: string
  name: string
  icon: string | null
  position: any // JSONB
}

export interface SurveyInvestment {
  survey_id: string
  investment_id: string
}

export interface ElectricCar {
  id: string
  created_at: string
  updated_at: string
  survey_id: string
  annual_mileage: number | null
  status: ElectricCarStatus
}

export interface HeavyConsumer {
  id: string
  created_at: string
  updated_at: string
  name: string
}

export interface SurveyHeavyConsumer {
  survey_id: string
  heavy_consumer_id: string
  status: HeavyConsumerStatus
}

export interface Scenario {
  id: string
  created_at: string
  updated_at: string
  survey_id: string
}

export interface ScenarioInvestment {
  scenario_id: string
  investment_id: string
}

export interface Contract {
  id: string
  created_at: string
  updated_at: string
  survey_id: string | null
  client_name: string | null
  client_address: string | null
  client_phone: string | null
  client_email: string | null
  birth_place: string | null
  date_of_birth: string | null // DATE type
  id_card_number: string | null
  tax_id: string | null
  mother_birth_name: string | null
  bank_account_number: string | null
  citizenship: string | null
  marital_status: string | null
  residence_card_number: string | null
  mailing_address: string | null
  first_sent_at: string | null // TIMESTAMPTZ type
  first_signed_at: string | null // TIMESTAMPTZ type
}

export interface ContractInvestment {
  contract_id: string
  investment_id: string
}

export interface ExtraCost {
  id: string
  created_at: string
  updated_at: string
  name: string
  price: number | null
}

export interface ExtraCostRelation {
  id: string
  extra_cost_id: string
  scenario_id: string | null
  contract_id: string | null
  snapshot_price: number | null
  quantity: number | null
}

export interface SurveyPage {
  id: string
  created_at: string
  updated_at: string
  name: string
  position: any // JSONB
  type: string | null
}

export interface SurveySurveyPage {
  survey_id: string
  survey_page_id: string
  position: number
}

export interface SurveyQuestion {
  id: string
  created_at: string
  updated_at: string
  survey_page_id: string
  name: string
  type: SurveyQuestionType
  default_value: string | null
  placeholder_value: string | null
  options: any // JSONB
  is_required: boolean
  is_special: boolean
  info_message: string | null
  min: number | null
  max: number | null
  step: number | null
  unit: string | null
  width: number | null
}

export interface SurveyAnswer {
  id: string
  created_at: string
  updated_at: string
  survey_id: string
  survey_question_id: string
  answer: string | null
}

export interface DocumentCategory {
  id: string
  created_at: string
  updated_at: string
  name: string
  position: any // JSONB
  description: string | null
  min_photos: number | null
}

export interface InvestmentDocumentCategory {
  investment_id: string
  document_category_id: string
  position: number
}

export interface Document {
  id: string
  created_at: string
  updated_at: string
  survey_id: string
  document_category_id: string
  name: string | null
  location: string
}

// ============================================================================
// EXTENDED TYPES WITH RELATIONS
// ============================================================================

export interface SurveyWithRelations extends Survey {
  client?: Client
  investments?: Investment[]
  electric_cars?: ElectricCar[]
  heavy_consumers?: (SurveyHeavyConsumer & { heavy_consumer?: HeavyConsumer })[]
  scenarios?: Scenario[]
  answers?: SurveyAnswer[]
  documents?: Document[]
}

export interface ScenarioWithRelations extends Scenario {
  survey?: Survey
  investments?: Investment[]
  extra_costs?: (ExtraCostRelation & { extra_cost?: ExtraCost })[]
}

export interface ContractWithRelations extends Contract {
  survey?: Survey
  investments?: Investment[]
  extra_costs?: (ExtraCostRelation & { extra_cost?: ExtraCost })[]
}

export interface SurveyPageWithQuestions extends SurveyPage {
  questions?: SurveyQuestion[]
}

export interface DocumentCategoryWithDocuments extends DocumentCategory {
  investments?: Investment[]
  documents?: Document[]
}

// ============================================================================
// INSERT/UPDATE TYPES
// ============================================================================

export type InsertSurvey = Omit<Survey, 'id' | 'created_at' | 'updated_at'>
export type UpdateSurvey = Partial<InsertSurvey>

export type InsertElectricCar = Omit<ElectricCar, 'id' | 'created_at' | 'updated_at'>
export type UpdateElectricCar = Partial<InsertElectricCar>

export type InsertScenario = Omit<Scenario, 'id' | 'created_at' | 'updated_at'>
export type UpdateScenario = Partial<InsertScenario>

export type InsertContract = Omit<Contract, 'id' | 'created_at' | 'updated_at'>
export type UpdateContract = Partial<InsertContract>

export type InsertSurveyAnswer = Omit<SurveyAnswer, 'id' | 'created_at' | 'updated_at'>
export type UpdateSurveyAnswer = Partial<InsertSurveyAnswer>

export type InsertDocument = Omit<Document, 'id' | 'created_at' | 'updated_at'>
export type UpdateDocument = Partial<InsertDocument>

// ============================================================================
// FORM/UI TYPES
// ============================================================================

export interface SurveyFormData {
  client_id: string
  at: string | null
  investments: string[] // Array of investment IDs
  electric_cars: InsertElectricCar[]
  heavy_consumers: {
    id: string
    status: HeavyConsumerStatus
  }[]
  answers: Record<string, string> // questionId -> answer
}

export interface ScenarioFormData {
  survey_id: string
  investments: string[] // Array of investment IDs
  extra_costs: {
    id: string
    quantity: number
    snapshot_price: number
  }[]
}

export interface ContractFormData extends InsertContract {
  investments: string[] // Array of investment IDs
  extra_costs: {
    id: string
    quantity: number
    snapshot_price: number
  }[]
}

// ============================================================================
// API RESPONSE TYPES
// ============================================================================

export interface SurveysResponse {
  data: SurveyWithRelations[]
  count: number
}

export interface SurveyResponse {
  data: SurveyWithRelations | null
}

export interface InvestmentsResponse {
  data: Investment[]
}

export interface SurveyPagesResponse {
  data: SurveyPageWithQuestions[]
}

export interface DocumentCategoriesResponse {
  data: DocumentCategoryWithDocuments[]
}
