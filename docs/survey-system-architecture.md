# Survey System Architecture Documentation

**Created:** 2025-10-17
**Last Updated:** 2025-10-21
**Version:** 2.0.0
**Migrations:** `003_create_survey_system.sql`, `031-043_products_system.sql`

---

## Table of Contents

1. [Overview](#overview)
2. [Database Schema](#database-schema)
3. [Entity Relationships](#entity-relationships)
4. [TypeScript Types](#typescript-types)
5. [Composables API](#composables-api)
6. [Usage Examples](#usage-examples)

---

## Overview

A complete survey management system for handling client property assessments, investments, documents, scenarios, and contracts.

### Key Features
- ✅ Multi-tenant support with company isolation
- ✅ Flexible investment tracking
- ✅ Photo/document management per category
- ✅ Survey answers with dynamic questions
- ✅ Scenario and contract generation
- ✅ Electric car and heavy consumer tracking
- ✅ **Main components catalog system** (NEW)
- ✅ **AI-powered scenario generation** (NEW)
- ✅ **Component-based system design** (NEW)

---

## Database Schema

### Core Tables

#### **clients**
Structured address fields for client data.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| company_id | UUID | Multi-tenant support |
| name | VARCHAR(255) | Client name |
| email | VARCHAR(255) | Email address |
| phone | VARCHAR(50) | Phone number |
| **postal_code** | VARCHAR(20) | Postal code |
| **city** | VARCHAR(100) | City |
| **street** | VARCHAR(255) | Street name |
| **house_number** | VARCHAR(50) | House number |
| contact_person | VARCHAR(255) | Contact person |
| notes | TEXT | Additional notes |
| status | VARCHAR(50) | active/inactive/archived |
| user_id | UUID | Creator user |

#### **surveys**
Main survey entity linking to clients.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| client_id | UUID | FK → clients |
| user_id | UUID | FK → auth.users |
| company_id | UUID | Multi-tenant support |
| **at** | DATE | Survey date |

**Relations:**
- 1 Client → Many Surveys
- Many-to-Many with Investments (via `survey_investments`)

#### **investments**
Available investment types.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Investment name |
| icon | VARCHAR(100) | Icon identifier |
| position | JSONB | Position data (array) |

**Examples:** Solar Panel, Heat Pump, Facade Insulation

#### **electric_cars**
Electric cars associated with surveys.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys |
| annual_mileage | INTEGER | Annual mileage |
| status | ENUM | 'existing' or 'planned' |

**Relations:**
- 1 Survey → Many Electric Cars

#### **heavy_consumers**
Predefined heavy energy consumers.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Consumer name |

**Examples:** Pool Pump, Electric Heating, Industrial Equipment

**Relations:**
- Many-to-Many with Surveys (via `survey_heavy_consumers`) with status field

#### **scenarios**
Different investment scenarios for surveys.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys |
| **name** | TEXT | Scenario name |
| **sequence** | INTEGER | Display order |
| **description** | TEXT | Scenario description |

**Relations:**
- 1 Survey → Many Scenarios
- Many-to-Many with Investments (via `scenario_investments`)
- 1 Scenario → Many Main Components (via `scenario_main_components`)
- Links to Extra Costs (via `extra_cost_relations`)

#### **contracts**
Contract data (can be linked to survey or standalone).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys (nullable) |
| client_name | VARCHAR(255) | Client name |
| client_address | VARCHAR(500) | Full address |
| client_phone | VARCHAR(50) | Phone |
| client_email | VARCHAR(255) | Email |
| birth_place | VARCHAR(255) | Birth place |
| date_of_birth | DATE | Date of birth |
| id_card_number | VARCHAR(50) | ID card number |
| tax_id | VARCHAR(50) | Tax ID |
| mother_birth_name | VARCHAR(255) | Mother's birth name |
| bank_account_number | VARCHAR(100) | Bank account |
| citizenship | VARCHAR(100) | Citizenship |
| marital_status | VARCHAR(50) | Marital status |
| residence_card_number | VARCHAR(50) | Residence card number |
| mailing_address | VARCHAR(500) | Mailing address |

**Relations:**
- 1 Survey → Many Contracts (nullable)
- Many-to-Many with Investments (via `contract_investments`)
- Links to Extra Costs (via `extra_cost_relations`)

#### **extra_costs**
Additional costs catalog.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Cost name |
| price | DECIMAL(10,2) | Base price |

**Relations:**
- Linked to Scenarios OR Contracts (via `extra_cost_relations`)

#### **survey_pages**
Survey form pages/sections.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Page name |
| position | JSONB | Position data |
| type | VARCHAR(100) | Page type |

**Relations:**
- Many-to-Many with Surveys (via `survey_survey_pages`) with position field
- 1 Page → Many Questions

#### **survey_questions**
Questions within survey pages.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_page_id | UUID | FK → survey_pages |
| name | VARCHAR(255) | Question name |
| type | ENUM | Question type (text, textarea, switch, etc.) |
| default_value | TEXT | Default value |
| placeholder_value | VARCHAR(500) | Placeholder text |
| options | JSONB | Options array (for dropdown, etc.) |
| is_required | BOOLEAN | Is required |
| is_special | BOOLEAN | Is special field |
| info_message | VARCHAR(1000) | Info message |
| min | DECIMAL(10,2) | Min value (for number/slider) |
| max | DECIMAL(10,2) | Max value (for number/slider) |
| step | DECIMAL(10,2) | Step value |
| unit | VARCHAR(50) | Unit (e.g., m², kWp) |
| width | INTEGER | UI width |

**Question Types:**
- `text`, `textarea`, `switch`, `dropdown`
- `title`, `phase_toggle`, `dual_toggle`
- `slider`, `range`, `number`
- `orientation_selector`, `warning`, `calculated`

**Relations:**
- 1 Page → Many Questions
- Many Questions → Many Answers

#### **survey_answers**
Answers to survey questions.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys |
| survey_question_id | UUID | FK → survey_questions |
| answer | TEXT | Answer value |

**Relations:**
- 1 Survey → Many Answers
- 1 Question → Many Answers (different surveys)

#### **document_categories**
Photo/document categories.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Category name |
| position | JSONB | Position data |
| description | TEXT | Description |
| min_photos | INTEGER | Minimum required photos |

**Examples:** Roof Photos, Electrical Panel, Facade

**Relations:**
- Many-to-Many with Investments (via `investment_document_categories`) with position
- 1 Category → Many Documents

#### **documents**
Uploaded documents/photos.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys |
| document_category_id | UUID | FK → document_categories |
| name | TEXT | Document name |
| location | TEXT | Storage location/URL |

**Relations:**
- 1 Survey → Many Documents
- 1 Category → Many Documents

#### **main_component_categories**
Categories for main components (e.g., Solar Panels, Inverters).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| persist_name | TEXT | Internal name (e.g., 'panel', 'inverter') |
| sequence | INTEGER | Display order |

**Examples:** panel, inverter, mounting, battery, heatpump

**Relations:**
- 1 Category → Many Main Components
- Many-to-Many with Investments (via `main_component_category_investments`)

#### **main_components**
Catalog of available components for scenarios.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | TEXT | Component name |
| persist_name | TEXT | Internal identifier |
| unit | TEXT | Unit (pcs, set, m²) |
| price | NUMERIC | Component price |
| main_component_category_id | UUID | FK → main_component_categories |
| manufacturer | TEXT | Manufacturer name |
| details | TEXT | Additional details |
| power | NUMERIC | Power rating (W/kW) |
| capacity | NUMERIC | Capacity (kWh) |
| efficiency | NUMERIC | Efficiency (%) |
| u_value | NUMERIC | U-value (W/m²K) |
| thickness | NUMERIC | Thickness (mm) |
| cop | NUMERIC | COP value |
| energy_class | TEXT | Energy class (A++, etc.) |
| sequence | INTEGER | Display/quality order |

**Relations:**
- 1 Category → Many Components
- Many Components → Many Scenarios (via `scenario_main_components`)

#### **scenario_main_components**
Components selected for each scenario with quantities.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| scenario_id | UUID | FK → scenarios |
| main_component_id | UUID | FK → main_components |
| quantity | INTEGER | Quantity needed |
| price_snapshot | NUMERIC | Price at selection time |

**Constraints:**
- UNIQUE (scenario_id, main_component_id)

**Relations:**
- 1 Scenario → Many Components
- 1 Main Component → Many Scenario Components

#### **main_component_category_investments**
Links categories to applicable investments.

| Column | Type | Description |
|--------|------|-------------|
| main_component_category_id | UUID | FK → main_component_categories |
| investment_id | UUID | FK → investments |
| sequence | INTEGER | Display order |

**Purpose:** Determines which component categories are relevant for each investment type.

---

## Entity Relationships

### ER Diagram (Text Format)

```
┌─────────────┐
│   clients   │
└──────┬──────┘
       │ 1
       │
       │ N
┌──────▼──────────┐
│    surveys      │◄────────────┐
└──────┬──────────┘             │
       │ 1                      │
       ├──────────────────┐     │
       │ N                │ N   │ 1
       │                  │     │
┌──────▼────────┐  ┌──────▼─────▼──────┐
│ electric_cars │  │  survey_answers   │
└───────────────┘  └───────────────────┘

┌──────────────────┐        ┌────────────────┐
│   investments    │◄───N───┤survey_invest-  │
└────────┬─────────┘        │    ments       │
         │                  └────────────────┘
         │ N                        ▲ N
         │                          │
┌────────▼─────────┐                │ 1
│investment_docu-  │          ┌─────┴──────┐
│ment_categories   │          │  surveys   │
└──────────────────┘          └─────┬──────┘
         │ N                        │ 1
         │                          │
┌────────▼─────────┐                │ N
│document_categories│         ┌──────▼────────┐
└────────┬─────────┘          │   scenarios   │
         │ 1                  └──────┬────────┘
         │                           │ N
         │ N                         │
┌────────▼─────────┐          ┌──────▼────────────┐
│   documents      │          │scenario_invest-   │
└──────────────────┘          │    ments          │
                              └───────────────────┘

┌──────────────────┐          ┌────────────────┐
│  heavy_consumers │◄───N─────┤survey_heavy_   │
└──────────────────┘          │  consumers     │
                              └────────────────┘
                                     ▲ N
                                     │
                                     │ 1
                              ┌──────┴──────┐
                              │  surveys    │
                              └─────────────┘

┌──────────────────┐          ┌────────────────┐
│   contracts      │◄───1─────┤   surveys      │
└────────┬─────────┘          └────────────────┘
         │ N
         │
┌────────▼─────────┐
│contract_invest-  │
│    ments         │
└──────────────────┘

┌──────────────────┐          ┌────────────────────┐
│  extra_costs     │◄───N─────┤extra_cost_relations│
└──────────────────┘          └──────┬─────┬───────┘
                                     │     │
                                     │ 1   │ 1
                              ┌──────▼─┐ ┌─▼────────┐
                              │scenarios│ │contracts │
                              └─────────┘ └──────────┘

┌──────────────────┐          ┌────────────────┐
│  survey_pages    │◄───N─────┤survey_survey_  │
└────────┬─────────┘          │    pages       │
         │ 1                  └────────────────┘
         │                           ▲ N
         │ N                         │
┌────────▼─────────┐                 │ 1
│survey_questions  │          ┌──────┴──────┐
└──────────────────┘          │  surveys    │
                              └─────────────┘
```

### Key Relationships

1. **Survey → Client**: 1:N (One client can have multiple surveys)
2. **Survey → Investments**: N:M (via `survey_investments`)
3. **Survey → Electric Cars**: 1:N
4. **Survey → Heavy Consumers**: N:M (via `survey_heavy_consumers` with status)
5. **Survey → Scenarios**: 1:N
6. **Survey → Contracts**: 1:N (nullable)
7. **Survey → Answers**: 1:N
8. **Survey → Documents**: 1:N
9. **Scenario → Investments**: N:M (via `scenario_investments`)
10. **Scenario → Extra Costs**: N:M (via `extra_cost_relations`)
11. **Contract → Investments**: N:M (via `contract_investments`)
12. **Contract → Extra Costs**: N:M (via `extra_cost_relations`)
13. **Investment → Document Categories**: N:M (via `investment_document_categories` with position)
14. **Document Category → Documents**: 1:N
15. **Survey Page → Questions**: 1:N

### Junction Tables

| Table | Purpose | Extra Fields |
|-------|---------|--------------|
| `survey_investments` | Survey ↔ Investment | - |
| `survey_heavy_consumers` | Survey ↔ Heavy Consumer | `status` (enum) |
| `scenario_investments` | Scenario ↔ Investment | - |
| `scenario_main_components` | Scenario ↔ Main Component | `quantity`, `price_snapshot` |
| `contract_investments` | Contract ↔ Investment | - |
| `extra_cost_relations` | (Scenario OR Contract) ↔ Extra Cost | `snapshot_price`, `quantity` |
| `investment_document_categories` | Investment ↔ Document Category | `position` (integer) |
| `main_component_category_investments` | Main Component Category ↔ Investment | `sequence` |
| `survey_survey_pages` | Survey ↔ Survey Page | `position` (integer) |

---

## TypeScript Types

**Location:** `/app/types/survey-new.ts`

### Enums

```typescript
export type ElectricCarStatus = 'existing' | 'planned'
export type HeavyConsumerStatus = 'existing' | 'planned'
export type SurveyQuestionType =
  | 'text' | 'textarea' | 'switch' | 'dropdown'
  | 'title' | 'phase_toggle' | 'dual_toggle'
  | 'slider' | 'range' | 'number'
  | 'orientation_selector' | 'warning' | 'calculated'
```

### Core Interfaces

All entities have:
- `id: string` (UUID)
- `created_at: string` (TIMESTAMPTZ)
- `updated_at: string` (TIMESTAMPTZ)

Plus specific fields as documented in Database Schema section.

### Extended Types with Relations

```typescript
SurveyWithRelations extends Survey {
  client?: Client
  investments?: Investment[]
  electric_cars?: ElectricCar[]
  heavy_consumers?: (SurveyHeavyConsumer & { heavy_consumer?: HeavyConsumer })[]
  scenarios?: Scenario[]
  answers?: SurveyAnswer[]
  documents?: Document[]
}

ScenarioWithRelations extends Scenario {
  survey?: Survey
  investments?: Investment[]
  extra_costs?: (ExtraCostRelation & { extra_cost?: ExtraCost })[]
}

ContractWithRelations extends Contract {
  survey?: Survey
  investments?: Investment[]
  extra_costs?: (ExtraCostRelation & { extra_cost?: ExtraCost })[]
}
```

### Form Types

```typescript
SurveyFormData {
  client_id: string
  at: string | null
  investments: string[] // Investment IDs
  electric_cars: InsertElectricCar[]
  heavy_consumers: { id: string; status: HeavyConsumerStatus }[]
  answers: Record<string, string> // questionId → answer
}

ScenarioFormData {
  survey_id: string
  investments: string[]
  extra_costs: { id: string; quantity: number; snapshot_price: number }[]
}

ContractFormData extends InsertContract {
  investments: string[]
  extra_costs: { id: string; quantity: number; snapshot_price: number }[]
}
```

---

## State Management

### Scenarios Store

**Location:** `/app/stores/scenarios.ts`

**Purpose:** Centralized state management for scenarios, main components, and system design.

```typescript
const scenariosStore = useScenariosStore()

// State
scenariosStore.scenarios                  // Scenario[]
scenariosStore.activeScenarioId           // string | null
scenariosStore.scenarioInvestments        // Record<string, string[]>
scenariosStore.scenarioComponents         // Record<string, ScenarioMainComponent[]>
scenariosStore.mainComponents             // MainComponent[]
scenariosStore.mainComponentCategories    // MainComponentCategory[]
scenariosStore.categoryInvestments        // Record<string, string[]>
scenariosStore.loading                    // boolean

// Getters
scenariosStore.activeScenario
scenariosStore.activeScenarioComponents
scenariosStore.getComponentsByCategoryId(categoryId)
scenariosStore.getCategoriesForInvestment(investmentId)
scenariosStore.getScenarioComponentForCategory(categoryId)

// Actions
await scenariosStore.loadScenarios(surveyId)
await scenariosStore.loadMainComponentsData()
scenariosStore.setActiveScenario(scenarioId)
await scenariosStore.addScenarioComponent(mainComponentId, quantity)
await scenariosStore.updateScenarioComponent(componentId, mainComponentId, quantity?)
await scenariosStore.updateComponentQuantity(componentId, quantity)
await scenariosStore.removeScenarioComponent(componentId)
```

**Key Features:**
- Reactive state for real-time UI updates
- Optimistic updates with local state sync
- Price snapshot management
- Category-based component filtering

---

## Composables API

**Location:** `/app/composables/`

### useSurveys()

**Purpose:** Main survey CRUD operations

```typescript
const {
  surveys,           // ref<SurveyWithRelations[]>
  currentSurvey,     // ref<SurveyWithRelations | null>
  loading,           // ref<boolean>
  error,             // ref<string | null>

  // Methods
  fetchSurveys,                    // () => Promise<void>
  fetchSurveysByClient,            // (clientId: string) => Promise<void>
  fetchSurveyById,                 // (surveyId: string) => Promise<SurveyWithRelations | null>
  createSurvey,                    // (data: SurveyFormData) => Promise<Survey | null>
  updateSurvey,                    // (id: string, updates: UpdateSurvey) => Promise<Survey | null>
  deleteSurvey,                    // (surveyId: string) => Promise<boolean>
  addInvestments,                  // (surveyId: string, investmentIds: string[]) => Promise<boolean>
  removeInvestments                // (surveyId: string, investmentIds: string[]) => Promise<boolean>
} = useSurveys()
```

**Key Features:**
- Auto-creates relations (investments, electric cars, heavy consumers, answers)
- Fetches with nested relations
- Company-scoped queries

### useInvestments()

**Purpose:** Investment catalog management

```typescript
const {
  investments,       // ref<Investment[]>
  loading,
  error,

  // Methods
  fetchInvestments,                       // () => Promise<Investment[]>
  fetchInvestmentById,                    // (id: string) => Promise<Investment | null>
  fetchInvestmentDocumentCategories,      // (id: string) => Promise<DocumentCategory[]>
  getInvestmentByName,                    // (name: string) => Investment | undefined
  getInvestmentsByIds                     // (ids: string[]) => Investment[]
} = useInvestments()
```

### useSurveyAnswers()

**Purpose:** Survey questions and answers management

```typescript
const {
  answers,           // ref<SurveyAnswer[]>
  questions,         // ref<SurveyQuestion[]>
  pages,             // ref<SurveyPageWithQuestions[]>
  loading,
  error,

  // Methods
  fetchSurveyPages,              // () => Promise<SurveyPageWithQuestions[]>
  fetchQuestionsByPage,          // (pageId: string) => Promise<SurveyQuestion[]>
  fetchAnswersBySurvey,          // (surveyId: string) => Promise<SurveyAnswer[]>
  saveAnswer,                    // (surveyId, questionId, value) => Promise<SurveyAnswer | null>
  saveAnswers,                   // (surveyId, answersObj) => Promise<boolean>
  deleteAnswer,                  // (answerId: string) => Promise<boolean>
  getAnswerValue,                // (questionId: string) => string | null
  getAnswersObject,              // () => Record<string, string>
  getCompletionPercentage        // (requiredQuestionIds: string[]) => number
} = useSurveyAnswers()
```

**Key Features:**
- Upsert logic (update if exists, insert if new)
- Completion tracking
- Bulk answer saving

### useDocuments()

**Purpose:** Photo/document upload and management

```typescript
const {
  documents,         // ref<Document[]>
  categories,        // ref<DocumentCategoryWithDocuments[]>
  loading,
  error,
  uploadProgress,    // ref<number>

  // Methods
  fetchDocumentCategories,                // () => Promise<DocumentCategory[]>
  fetchCategoriesByInvestment,            // (investmentId: string) => Promise<DocumentCategory[]>
  fetchDocumentsBySurvey,                 // (surveyId: string) => Promise<Document[]>
  fetchDocumentsBySurveyAndCategory,      // (surveyId, categoryId) => Promise<Document[]>
  addDocument,                            // (surveyId, categoryId, file, name?) => Promise<Document | null>
  deleteDocument,                         // (documentId: string) => Promise<boolean>
  getDocumentsCountByCategory,            // (categoryId: string) => number
  hasSufficientPhotos,                    // (categoryId, minPhotos) => boolean
  getCategoryCompletionStatus             // (requiredCategories) => CompletionStatus[]
} = useDocuments()
```

**Key Features:**
- Supabase Storage integration
- Upload progress tracking
- Minimum photo validation
- Cascade delete (Storage + DB)

### useScenarios()

**Purpose:** Scenario management (Legacy - use `useScenariosStore()` for new code)

```typescript
const {
  scenarios,         // ref<ScenarioWithRelations[]>
  currentScenario,   // ref<ScenarioWithRelations | null>
  loading,
  error,

  // Methods
  fetchScenariosBySurvey,        // (surveyId: string) => Promise<ScenarioWithRelations[]>
  fetchScenarioById,             // (scenarioId: string) => Promise<ScenarioWithRelations | null>
  createScenario,                // (data: ScenarioFormData) => Promise<Scenario | null>
  deleteScenario,                // (scenarioId: string) => Promise<boolean>
  addExtraCost,                  // (scenarioId, extraCostId, quantity, snapshotPrice) => Promise<boolean>
  removeExtraCost                // (relationId: string) => Promise<boolean>
} = useScenarios()
```

**Key Features:**
- Links investments and extra costs
- Snapshot pricing for extra costs

### useScenarioCreation()

**Purpose:** AI-powered scenario generation

**Location:** `/app/composables/useScenarioCreation.ts`

```typescript
const { createAIScenarios } = useScenarioCreation()

const result = await createAIScenarios(surveyId, selectedInvestmentIds)
// Returns: { success: boolean, scenarios?: Scenario[], error?: string }
```

**Features:**
- Automatically creates 3 scenario types (Optimum, Minimum, Premium)
- Smart component selection based on quality level
- Automatic quantity calculation with multipliers
- Preferred brand filtering for premium scenarios
- Price snapshot at creation time

**Scenario Types:**
- **Optimum:** Medium quality, 1.0x quantity multiplier
- **Minimum:** Low quality, 0.8x quantity multiplier, budget-focused
- **Premium:** High quality, 1.2x quantity multiplier, premium brands

**Component Selection Logic:**
```typescript
// High quality: First component (highest sequence = best quality)
// Medium quality: Middle component
// Low quality: Last component (lowest price)
```

### useContracts()

**Purpose:** Contract management

```typescript
const {
  contracts,         // ref<ContractWithRelations[]>
  currentContract,   // ref<ContractWithRelations | null>
  loading,
  error,

  // Methods
  fetchContractsBySurvey,        // (surveyId: string) => Promise<ContractWithRelations[]>
  fetchContractById,             // (contractId: string) => Promise<ContractWithRelations | null>
  createContract,                // (data: ContractFormData) => Promise<Contract | null>
  updateContract,                // (contractId, updates) => Promise<Contract | null>
  deleteContract,                // (contractId: string) => Promise<boolean>
  addExtraCost,                  // (contractId, extraCostId, quantity, snapshotPrice) => Promise<boolean>
  removeExtraCost                // (relationId: string) => Promise<boolean>
} = useContracts()
```

**Key Features:**
- Full client details
- Optional survey linkage
- Investment and extra cost management

---

## UI Components

### Consultation Page

**Location:** `/app/components/Survey/`

#### SurveyConsultation.vue
Main consultation page with three-column layout:
- **System Design** (left, collapsible) - Scenario components and configuration
- **System Visualization** (center) - Visual house representation
- **Consultation** (right, collapsible) - Communication panel

**Features:**
- View mode toggle (Scenarios / Independent Investments)
- AI Scenarios and New Scenario buttons
- Panel state persistence in database
- Smooth collapse/expand transitions

#### SurveyScenarioInvestments.vue
Displays investments for active scenario in accordion format.

**Features:**
- Dynamic investment accordions
- Investment-specific icons
- Categories and components per investment

#### SurveyScenarioCategories.vue
Component category management with CRUD operations.

**Features:**
- Add components (auto-selects next available)
- Edit component selection via dropdown
- Quantity management
- Delete components
- Duplicate prevention
- Loading states

#### UISelect.vue
Custom HTML select component for dropdowns.

**Features:**
- Native `<select>` and `<option>` elements
- Flexible value/label mapping
- Size variants (sm, md, lg)
- Dark mode support
- Disabled state

---

## Usage Examples

### Example 1: Create a New Survey

```typescript
const { createSurvey } = useSurveys()

const newSurvey = await createSurvey({
  client_id: 'uuid-client-123',
  at: '2025-10-17',
  investments: ['uuid-solar', 'uuid-heatpump'],
  electric_cars: [
    { annual_mileage: 15000, status: 'existing' }
  ],
  heavy_consumers: [
    { id: 'uuid-pool-pump', status: 'existing' }
  ],
  answers: {
    'uuid-question-1': 'Answer value 1',
    'uuid-question-2': 'Answer value 2'
  }
})
```

### Example 2: Fetch Survey with All Relations

```typescript
const { fetchSurveyById } = useSurveys()

const survey = await fetchSurveyById('uuid-survey-123')
// Returns:
// {
//   id, created_at, updated_at, client_id, at,
//   client: { ... },
//   investments: [ { id, name, icon } ],
//   electric_cars: [ { id, annual_mileage, status } ],
//   heavy_consumers: [ { heavy_consumer: { name }, status } ],
//   scenarios: [ ... ],
//   answers: [ { question: { ... }, answer: '...' } ],
//   documents: [ { category: { name }, location } ]
// }
```

### Example 3: Upload Document

```typescript
const { addDocument } = useDocuments()

const file = // ... File object from input
await addDocument(
  'uuid-survey-123',
  'uuid-category-roof',
  file,
  'Roof photo 1'
)
```

### Example 4: Save Multiple Answers

```typescript
const { saveAnswers } = useSurveyAnswers()

await saveAnswers('uuid-survey-123', {
  'uuid-question-roof-type': 'Pitched',
  'uuid-question-roof-area': '150',
  'uuid-question-solar-capacity': '10.5'
})
```

### Example 5: Create Scenario with Investments

```typescript
const { createScenario } = useScenarios()

await createScenario({
  survey_id: 'uuid-survey-123',
  investments: ['uuid-solar', 'uuid-battery'],
  extra_costs: [
    { id: 'uuid-cost-mounting', quantity: 1, snapshot_price: 50000 }
  ]
})
```

### Example 6: Generate Contract

```typescript
const { createContract } = useContracts()

await createContract({
  survey_id: 'uuid-survey-123',
  client_name: 'John Doe',
  client_email: 'john@example.com',
  client_phone: '+36301234567',
  client_address: '1234 Budapest, Example St. 1',
  date_of_birth: '1980-01-15',
  tax_id: '1234567890',
  // ... other fields
  investments: ['uuid-solar'],
  extra_costs: [
    { id: 'uuid-cost-installation', quantity: 1, snapshot_price: 100000 }
  ]
})
```

### Example 7: Create AI Scenarios

```typescript
const { createAIScenarios } = useScenarioCreation()

// User selects investments: Solar Panel, Heat Pump
const result = await createAIScenarios(surveyId, [
  'uuid-investment-solar',
  'uuid-investment-heatpump'
])

if (result.success) {
  // 3 scenarios created:
  // 1. "Scenario 1 - Optimum" (medium quality, 1.0x quantity)
  // 2. "Scenario 2 - Minimum" (low quality, 0.8x quantity)
  // 3. "Scenario 3 - Premium" (high quality, 1.2x quantity, premium brands)

  console.log(result.scenarios)
}
```

### Example 8: Manage Scenario Components

```typescript
const scenariosStore = useScenariosStore()

// Load scenarios for a survey
await scenariosStore.loadScenarios('uuid-survey-123')

// Set active scenario
scenariosStore.setActiveScenario('uuid-scenario-1')

// Add a component
await scenariosStore.addScenarioComponent('uuid-component-panel-500w', 12)

// Update component
await scenariosStore.updateScenarioComponent(
  'uuid-scenario-component-1',
  'uuid-component-panel-600w',
  10
)

// Update quantity only
await scenariosStore.updateComponentQuantity('uuid-scenario-component-1', 15)

// Remove component
await scenariosStore.removeScenarioComponent('uuid-scenario-component-1')

// Get components by category
const panels = scenariosStore.getComponentsByCategoryId('uuid-category-panel')

// Get categories for investment
const categories = scenariosStore.getCategoriesForInvestment('uuid-investment-solar')
```

### Example 9: Component Selection in UI

```vue
<template>
  <UISelect
    v-model="selectedComponentId"
    :options="componentOptions"
    value-attribute="value"
    label-attribute="label"
    size="sm"
    @update:model-value="handleComponentChange"
  />
</template>

<script setup>
const componentOptions = computed(() => {
  const components = scenariosStore.getComponentsByCategoryId(categoryId)
  return components.map(c => ({
    value: c.id,
    label: c.name
  }))
})

const handleComponentChange = async (componentId) => {
  await scenariosStore.updateScenarioComponent(
    scenarioComponentId,
    componentId
  )
}
</script>
```

---

## RLS Policies

All main tables have Row Level Security enabled with company-scoped policies:

```sql
-- Example for surveys table
CREATE POLICY "Users can view surveys from their company"
    ON public.surveys FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );
```

**Protected Tables:**
- surveys
- electric_cars
- scenarios
- contracts
- survey_answers
- documents

**Note:** Junction tables inherit security from parent tables.

---

## Storage Buckets

### survey-documents

**Purpose:** Store uploaded photos and documents

**Path Structure:** `{surveyId}/{categoryId}/{timestamp}.{ext}`

**Example:** `uuid-survey-123/uuid-category-roof/1729181234567.jpg`

**Access:** Public read, authenticated write (via composable)

---

## Migration Notes

### From Old System

If migrating from previous survey implementation:

1. **Data Mapping:**
   - Old `client.address` → New `postal_code + city + street + house_number`
   - Old flat survey data → New relational structure

2. **Breaking Changes:**
   - Survey structure completely redesigned
   - Investment tracking now relational (not embedded)
   - Document categories must be predefined

3. **Migration Script:** (TODO: Create if needed)

---

## Future Enhancements

### Planned Features
- [ ] Survey templates
- [ ] Bulk operations
- [ ] Export to PDF
- [ ] Email notifications
- [ ] Revision history
- [ ] Approval workflows
- [x] **AI scenario generation** ✅
- [x] **Component catalog system** ✅
- [x] **Consultation page UI** ✅
- [ ] Price calculation engine
- [ ] Scenario comparison view
- [ ] Component recommendations
- [ ] Toast notifications for operations
- [ ] Category info modals
- [ ] Bulk component operations

---

## Support & Maintenance

**Database Migrations:** `/supabase/migrations/`
**Types:** `/app/types/survey-new.ts`
**Composables:** `/app/composables/`
**Documentation:** `/docs/`

**Created by:** Claude Code
**Last Updated:** 2025-10-21

---

## State Management Patterns

### Investment-Specific Response Storage

**Context:** Questions with the same `name` can exist across multiple investments. Each investment must maintain its own set of responses.

**Store Structure:**
```typescript
// app/stores/surveyInvestments.ts
state: () => ({
  investmentResponses: {} as Record<string, Record<string, any>>,
  // Structure: investmentResponses[investmentId][questionName] = value
})
```

**Example:**
```typescript
investmentResponses: {
  'uuid-solar-panel': {
    'electrical_network_condition': 'Good',
    'roof_type': 'Pitched',
    'roof_area': '150'
  },
  'uuid-heat-pump': {
    'electrical_network_condition': 'Needs renovation',
    'heating_system': 'Gas boiler'
  },
  'uuid-battery': {
    'electrical_network_condition': '' // Not yet answered
  }
}
```

### Accessing Investment-Specific Responses

**❌ WRONG - Active Investment Only:**
```typescript
// This only checks the currently active investment
const response = store.getResponse(question.name)
```

**✅ CORRECT - Specific Investment:**
```typescript
// Directly access the specific investment's response
const response = store.investmentResponses[investment.id]?.[question.name]
```

### Critical Implementation Points

1. **Progress Calculation:**
   - Each `SurveyPage` belongs to a specific `investment_id`
   - Progress must be calculated using `page.investment_id` context
   - Function signature: `getPageCompletionPercentage(page: SurveyPage)` (not just `pageId`)

2. **Missing Items Detection:**
   - Loop through all investments
   - Check each investment's specific responses
   - Deduplicate by `investmentId:questionName` key
   - Prevents same question from appearing multiple times if answered for one investment

3. **Response Updates:**
   - Always update: `investmentResponses[investmentId][questionName] = value`
   - Never rely on "active" investment for multi-investment scenarios

### Affected Components

**Components using investment-specific responses:**
- `/app/components/Survey/SurveyHouseVisualization.vue` - Progress indicators
- `/app/components/Survey/SurveyMissingItemsModal.vue` - Missing items detection
- `/app/components/Survey/SurveyPropertyAssessment.vue` - Question rendering
- `/app/stores/surveyInvestments.ts` - Core state management

**Bug History:**
- **Issue:** Missing Items count incorrect when same question exists across investments
- **Root Cause:** Using `store.getResponse()` which only checked active investment
- **Fix Date:** 2025-10-22
- **Solution:** Direct access to `investmentResponses[investment.id][question.name]`

---

## Related Documentation

- [Consultation Page Details](survey-consultation-page.md) - Complete Consultation page documentation
- [Property Assessment Page](survey-property-assessment.md) - Property Assessment page documentation
- [Investment-Aware Response Tracking Bugfix](survey-property-assessment.md#investment-aware-question-response-tracking-bugfix) - Detailed bugfix documentation
