# Survey System Architecture Documentation

**Created:** 2025-10-17
**Last Updated:** 2025-11-05
**Version:** 2.6.0
**Migrations:**
- `004_create_survey_system.sql` - Core survey system
- `031-043_products_system.sql` - Products and components
- `070_add_investment_id_to_pivot_tables.sql` - Investment-specific tracking
- `097-101_default_value_source_and_persistence.sql` - Default values and persistence
- `102_add_hierarchical_survey_pages.sql` - Hierarchical pages
- `104_create_openings_survey_page.sql` - Openings subpage
- `105_add_planned_investment_and_site_conditions_pages.sql` - Additional pages
- `136_add_conditional_value_copy_rules.sql` - Conditional value copy rules
- `137_remove_old_default_value_source_refs.sql` - Cleanup old references
- `1006_add_multiselect_question_type.sql` - Multiselect question type (NEW)
- `1009_add_template_variables.sql` - Dynamic template variables (NEW)

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
- ✅ **Main components catalog system**
- ✅ **AI-powered scenario generation**
- ✅ **Component-based system design**
- ✅ **Investment-specific component tracking** (NEW - 2025-10-24)
- ✅ **Offer/Contract page with detailed pricing** (NEW - 2025-10-24)
- ✅ **Contract Data page with client information management** (NEW - 2025-10-24)
- ✅ **Summary page with contract preview and digital signing** (NEW - 2025-10-24)
- ✅ **Persistent survey answer storage with multi-instance support** (NEW - 2025-10-30)
- ✅ **Default value inheritance across survey questions** (NEW - 2025-10-30)
- ✅ **Dynamic readonly fields based on source data** (NEW - 2025-10-30)
- ✅ **Hierarchical survey pages with parent-child relationships** (NEW - 2025-10-30)
- ✅ **Automated wall metrics calculations for facade insulation** (NEW - 2025-10-30)
- ✅ **Conditional value copy rules with flexible condition-based copying** (NEW - 2025-11-03)
- ✅ **Multiselect question type with checkbox-based multi-option selection** (NEW - 2025-11-05)
- ✅ **Dynamic template variables for survey question text substitution** (NEW - 2025-11-05)

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
Contract data (can be linked to survey or standalone). Manages both technical contract details (name, mode, pricing) and client personal information.

| Column | Type | Description | Managed On |
|--------|------|-------------|------------|
| id | UUID | Primary key | System |
| created_at | TIMESTAMPTZ | Creation timestamp | System |
| updated_at | TIMESTAMPTZ | Last update timestamp | System |
| survey_id | UUID | FK → surveys (nullable) | System |
| **Technical Fields** | | | |
| name | VARCHAR(255) | Contract name | Offer/Contract |
| scenario_id | UUID | FK → scenarios | Offer/Contract |
| contract_mode | VARCHAR(20) | 'offer' or 'contract' | Offer/Contract |
| status | VARCHAR(20) | draft/sent/accepted/rejected | Offer/Contract |
| commission_rate | DECIMAL(5,4) | Commission rate (default 0.12) | Offer/Contract |
| vat | INTEGER | VAT percentage (default 27) | Offer/Contract |
| total_price | DECIMAL(12,2) | Total price | Offer/Contract |
| roof_configuration | JSONB | Roof configuration data | Offer/Contract |
| notes | TEXT | Additional notes | Offer/Contract |
| **Client Data** | | | |
| client_name | VARCHAR(255) | Client name | **Contract Data** |
| client_address | VARCHAR(500) | Full address | **Contract Data** |
| client_phone | VARCHAR(50) | Phone | **Contract Data** |
| client_email | VARCHAR(255) | Email | **Contract Data** |
| **Personal Details** | | | |
| birth_place | VARCHAR(255) | Birth place | **Contract Data** |
| date_of_birth | DATE | Date of birth | **Contract Data** |
| id_card_number | VARCHAR(50) | ID card number | **Contract Data** |
| tax_id | VARCHAR(50) | Tax ID | **Contract Data** |
| mother_birth_name | VARCHAR(255) | Mother's birth name | **Contract Data** |
| bank_account_number | VARCHAR(100) | Bank account | **Contract Data** |
| citizenship | VARCHAR(100) | Citizenship | **Contract Data** |
| marital_status | VARCHAR(50) | Marital status | **Contract Data** |
| residence_card_number | VARCHAR(50) | Residence card number | **Contract Data** |
| mailing_address | VARCHAR(500) | Mailing address | **Contract Data** |

**Relations:**
- 1 Survey → Many Contracts (nullable)
- Many-to-Many with Investments (via `contract_investments`)
- 1 Scenario → Many Contracts (optional)
- Links to Extra Costs (via `extra_cost_relations`)

**See Also:** [Contract Data Page Documentation](survey-contract-data-page.md)

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
Survey form pages/sections with hierarchical support.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| name | VARCHAR(255) | Page name |
| position | JSONB | Position data |
| type | VARCHAR(100) | Page type |
| **parent_page_id** | UUID | FK → survey_pages (nullable) ⭐ |
| allow_multiple | BOOLEAN | Allow multiple instances |
| allow_delete_first | BOOLEAN | Allow deleting first instance |
| item_name_template | VARCHAR(255) | Template for instance names |

⭐ **NEW - 2025-10-30:** Hierarchical page support

**Relations:**
- Many-to-Many with Surveys (via `survey_survey_pages`) with position field
- 1 Page → Many Questions
- 1 Parent Page → Many Subpages (self-referential)

**Hierarchical Structure:**
- `parent_page_id = NULL`: Root-level pages
- `parent_page_id = <uuid>`: Subpages nested under a parent
- Example: "Falak" (Walls) parent → "Nyílászárók" (Openings) subpage

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
| **default_value_source_question_id** | UUID | FK → survey_questions (nullable) ⭐ |
| **is_readonly** | BOOLEAN | Field is readonly (default false) ⭐ |
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
| **template_variables** | JSONB | Dynamic variable definitions for text substitution ⭐⭐ |
| **display_conditions** | JSONB | Conditions for conditional question visibility |
| **name_translations** | JSONB | Localized question text |
| **options_translations** | JSONB | Localized option values |

⭐ **NEW - 2025-10-30:** Default value inheritance and readonly support
⭐⭐ **NEW - 2025-11-05:** Template variables for dynamic text replacement

**Question Types:**
- `text`, `textarea`, `switch`, `dropdown`
- `title`, `phase_toggle`, `dual_toggle`
- `slider`, `range`, `number`
- `orientation_selector`, `warning`, `calculated`
- `multiselect` ⭐⭐ (NEW - 2025-11-05)

**Relations:**
- 1 Page → Many Questions
- Many Questions → Many Answers
- 1 Question → 1 Source Question (optional, self-referential)

**Default Value Inheritance:**
- Questions can inherit default values from other questions via `default_value_source_question_id`
- When source question value changes, dependent questions auto-update (via database trigger)
- Supports both regular pages and allow_multiple pages with item_group

#### **survey_answers**
Answers to survey questions with multi-instance and hierarchical support.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| survey_id | UUID | FK → surveys |
| survey_question_id | UUID | FK → survey_questions |
| answer | TEXT | Answer value |
| **item_group** | INTEGER | Instance number for allow_multiple pages (nullable) ⭐ |
| **parent_item_group** | INTEGER | Parent instance number for hierarchical pages (nullable) ⭐ |

⭐ **NEW - 2025-10-30:** Multi-instance and hierarchical support

**Relations:**
- 1 Survey → Many Answers
- 1 Question → Many Answers (different surveys)

**Unique Constraint:**
- `UNIQUE (survey_id, survey_question_id, COALESCE(item_group, -1), COALESCE(parent_item_group, -1))`
- Ensures one answer per question per survey per instance per parent instance

**Item Group Behavior:**
- `item_group = NULL, parent_item_group = NULL`: Regular pages (single instance)
- `item_group = 0,1,2..., parent_item_group = NULL`: Root allow_multiple pages
- `item_group = 0,1,2..., parent_item_group = 0,1,2...`: Hierarchical subpage instances

**Hierarchical Example:**
```
Wall #0 (parent_item_group: null, item_group: 0)
  → Opening #0 (parent_item_group: 0, item_group: 0)
  → Opening #1 (parent_item_group: 0, item_group: 1)
Wall #1 (parent_item_group: null, item_group: 1)
  → Opening #0 (parent_item_group: 1, item_group: 0)
```

#### **survey_value_copy_rules**
Conditional rules for copying values between survey questions.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| **condition_question_id** | UUID | FK → survey_questions - Question that determines if copy should happen ⭐ |
| **condition_value** | TEXT | Value that condition must have for copy to occur ⭐ |
| **source_question_id** | UUID | FK → survey_questions - Question from which to copy ⭐ |
| **target_question_id** | UUID | FK → survey_questions - Question to which value should be copied ⭐ |

⭐ **NEW - 2025-11-03:** Conditional value copy rules

**Purpose:**
Enables conditional value copying based on switch/checkbox states. More flexible than `default_value_source_question_id`.

**Example Rules:**
1. **IF** "Falak mindenhol megegyező típusúak" (switch) = `true`
   **THEN** Copy "Fal típusa" → All "Fal szerkezete" instances

2. **IF** "Fal vastagsága mindenhol megegyezik" (switch) = `true`
   **THEN** Copy "Fal vastagsága átlag" → All "Fal vastagsága" instances

3. **IF** "Lábazat típusa mindenhol megegyezik" (switch) = `true`
   **THEN** Copy "Lábazat típusa átlag" → All "Lábazat típusa" instances

**Behavior:**
- Trigger fires on any `survey_answers` INSERT/UPDATE
- Checks if changed question is involved in any copy rule (as condition or source)
- Evaluates condition: If condition_question's answer equals condition_value
- If condition met: Copies source_question value to ALL instances of target_question
- Uses check-then-insert/update pattern (not ON CONFLICT) to avoid constraint issues

**Database Trigger:**
```sql
CREATE TRIGGER trigger_sync_conditional_value_copy
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_conditional_value_copy();
```

**Relations:**
- condition_question_id → survey_questions (the switch/condition)
- source_question_id → survey_questions (the value to copy)
- target_question_id → survey_questions (destination, usually in allow_multiple page)

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
| investment_id | UUID | FK → investments (NEW - 2025-10-24) |
| quantity | DECIMAL(10,2) | Quantity needed |
| price_snapshot | NUMERIC | Price at selection time |

**Constraints:**
- UNIQUE (scenario_id, main_component_id, investment_id) - Updated 2025-10-24

**Relations:**
- 1 Scenario → Many Components
- 1 Main Component → Many Scenario Components
- 1 Investment → Many Scenario Components (NEW)

**Migration:** See `070_add_investment_id_to_pivot_tables.sql`

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

**SurveyQuestion Interface (NEW fields):**
```typescript
interface SurveyQuestion {
  // ... existing fields
  default_value_source_question_id?: string  // UUID of source question (NEW - 2025-10-30)
  is_readonly?: boolean                       // Field is readonly (NEW - 2025-10-30)
  template_variables?: Record<string, TemplateVariable>  // Dynamic variables (NEW - 2025-11-05)
  display_conditions?: DisplayCondition       // Conditional visibility (NEW - 2025-11-05)
}
```

**TemplateVariable Interface (NEW - 2025-11-05):**
```typescript
interface TemplateVariable {
  type: 'matched_conditional_values' | 'field_value' | 'conditional_count'
  field: string  // The field name to get value from
}
```

**DisplayCondition Interface (NEW - 2025-11-05):**
```typescript
interface DisplayCondition {
  field: string  // Question name to check
  operator: 'contains_any' | 'equals' | 'not_equals'  // Comparison operator
  value: string | string[]  // Expected value(s)
}
```

**SurveyAnswer Interface (NEW field - 2025-10-30):**
```typescript
interface SurveyAnswer {
  // ... existing fields
  item_group?: number | null  // Instance number for allow_multiple pages
}
```

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

### Contract Data Page

**Location:** `/app/components/Survey/`

#### SurveyContractData.vue
Client information and personal details management for contracts.

**Features:**
- Multi-contract editing (select up to 3 contracts simultaneously)
- Smart default population from Survey Client data
- Auto-save with 1-second debounce
- Copy client data between contracts
- Copy personal details between contracts
- Responsive grid layout (1, 2, or 3 columns)
- Contract sorting by creation date (earliest first)
- Full-width input fields

**Data Sections:**
1. **Client Data**
   - Name, Address, Phone, Email
   - Auto-populated from Survey Client
2. **Personal Details**
   - Birth Place, Date of Birth, ID Card Number
   - Tax ID, Mother's Name, Bank Account Number
   - Citizenship, Marital Status, Residence Card Number
   - Mailing Address

**See Also:** [Contract Data Page Documentation](survey-contract-data-page.md)

### Summary Page

**Location:** `/app/components/Survey/`

#### SurveySummary.vue
Final survey page displaying all contracts with preview and action capabilities.

**Features:**
- View mode toggle (List / Card view)
- Contract cards showing client info and investment details
- Three action buttons per contract (Save without send, Save and Send, Sign Now)
- Smart data fallback (contract → Survey Client → empty)
- Cost summary per contract
- Footer buttons for bulk operations

#### Modal Components

**SurveySendContractModal.vue** - Single contract email sending
- Contract preview
- Email template editor with rich text support
- Placeholder substitution

**SurveySignContractModal.vue** - Single contract digital signing
- Contract preview
- Privacy policy acceptance
- Contract terms acceptance
- Email delivery option
- Touch/mouse signature pad

**SurveySendAllContractsModal.vue** - Bulk contract sending
- Multiple contract previews with numbering
- Shared email template editor
- Batch email functionality

**SurveySignAllContractsModal.vue** - Bulk contract signing
- Multiple contract previews with numbering
- Per-contract acceptance and signature
- Global privacy policy acceptance
- Comprehensive validation (all contracts must be signed)

#### Supporting Components

**ContractPreview.vue** - Read-only contract display
- Client information with smart fallback
- Selected investments with icons
- Component breakdown with quantities and prices
- Extra costs and discounts
- Total price calculation
- Notes section

**SignaturePad.vue** - Canvas-based signature capture
- Touch event handling (touchstart, touchmove, touchend)
- Mouse event handling (mousedown, mousemove, mouseup, mouseleave)
- Coordinate transformation for proper scaling
- Clear functionality
- isEmpty() validation
- PNG data URL export

**EmailTemplateEditor.vue** - Rich text email editor
- Toolbar with formatting buttons (Bold, Italic, Underline, List, Link)
- Text insertion at cursor position
- Placeholder documentation

**See Also:** [Summary Page Documentation](survey-summary-page.md)

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
**Last Updated:** 2025-11-03

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

## Advanced Features

### Survey Answer Persistence (NEW - 2025-10-30)

**Overview:**
Survey answers are now automatically saved to the database in real-time, enabling data persistence across sessions and support for multi-instance survey pages.

**Key Components:**

#### Database Layer
- **Table:** `survey_answers`
- **New Column:** `item_group` (INTEGER, nullable)
- **Unique Index:** `idx_survey_answers_unique ON (survey_id, survey_question_id, COALESCE(item_group, -1))`

#### Store Methods

**Location:** `/app/stores/surveyInvestments.ts`

```typescript
// Save regular question answer
async saveResponse(questionName: string, value: any)

// Save answer for allow_multiple page instances
async saveInstanceResponse(pageId: string, instanceIndex: number, questionName: string, value: any)

// Load all existing answers on survey initialization
async loadExistingAnswers(surveyId: string)
```

**Behavior:**
1. **Auto-save:** All input changes trigger immediate database save
2. **Upsert Logic:** Updates existing answer or inserts new one
3. **Type Conversion:** All values converted to strings for database storage
4. **Error Handling:** Graceful error logging without UI disruption

#### Multi-Instance Support

**Use Case:** Survey pages with `allow_multiple: true` (e.g., multiple wall surfaces)

```typescript
// Example: 3 wall surfaces
survey_answers:
  - { survey_id, question_id: 'wall_type', answer: 'Brick', item_group: 0 }
  - { survey_id, question_id: 'wall_type', answer: 'Concrete', item_group: 1 }
  - { survey_id, question_id: 'wall_type', answer: 'Wood', item_group: 2 }
```

**Frontend State:**
```typescript
pageInstances[investmentId][pageId].instances = [
  { wall_type: 'Brick', wall_thickness: 30, ... },      // item_group 0
  { wall_type: 'Concrete', wall_thickness: 40, ... },   // item_group 1
  { wall_type: 'Wood', wall_thickness: 20, ... }        // item_group 2
]
```

---

### Default Value Inheritance (NEW - 2025-10-30)

**Overview:**
Questions can automatically inherit and sync values from other questions, enabling reuse of common data across survey sections.

**Use Case:**
"Basic Data" page captures "External Wall Structure" → Automatically populates "Wall Structure" field on all "Facade Insulation" wall instances.

#### Database Schema

**survey_questions Table:**
```sql
ALTER TABLE survey_questions
ADD COLUMN default_value_source_question_id UUID REFERENCES survey_questions(id) ON DELETE SET NULL;

ALTER TABLE survey_questions
ADD COLUMN is_readonly BOOLEAN DEFAULT FALSE;
```

#### Database Trigger

**Function:** `sync_dependent_question_answers()`

**Trigger:** Fires on `INSERT OR UPDATE OF answer ON survey_answers`

**Behavior:**
1. Detects when a source question's answer changes
2. Finds all dependent questions (`default_value_source_question_id` matches)
3. Updates dependent question answers in database:
   - **Regular pages:** Simple insert/update with `item_group = NULL`
   - **Allow_multiple pages:** Updates ALL existing instances

```sql
CREATE TRIGGER trigger_sync_dependent_answers
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_dependent_question_answers();
```

#### Frontend Implementation

**Location:** `/app/stores/surveyInvestments.ts`

```typescript
// Load default values when creating new instance
async loadDefaultValuesForInstance(pageId: string, instanceIndex: number)

// Sync dependent fields in frontend state when source changes
async syncDependentQuestionsInState(sourceQuestionId: string, newValue: string)

// Ensure first instance has default values
async ensurePageInstancesInitialized(pageId: string)
```

**Component Integration:**
```vue
// SurveyPropertyAssessment.vue
watch(activePageId, async (newPageId) => {
  if (!newPageId) return
  const page = activePage.value
  if (page?.allow_multiple) {
    await store.ensurePageInstancesInitialized(newPageId)
  }
})
```

**Workflow:**
1. **Initial Load:** When navigating to allow_multiple page, check for empty first instance → load defaults
2. **New Instance:** When adding new instance (`addPageInstance`), automatically load defaults
3. **Source Change:** When source question updates → sync frontend state for immediate UI update
4. **Database Sync:** Database trigger ensures backend data stays consistent

**Source Value Clearing:**
- When source becomes empty → dependent fields remain editable and keep manual values
- Frontend sync skips empty source values to preserve user input

---

### Dynamic Readonly Fields (NEW - 2025-10-30)

**Overview:**
Form fields can dynamically become readonly based on whether their source question has a value.

**Behavior:**
1. **Source Empty:** Field is editable, user can enter custom values
2. **Source Filled:** Field becomes readonly (disabled), displays inherited value
3. **Source Cleared:** Field becomes editable again, retains previous value

#### Frontend Logic

**Location:** `/app/components/Survey/SurveyQuestionRenderer.vue`

```typescript
const isEffectivelyReadonly = computed(() => {
  if (!props.question.is_readonly) return false

  // If has default_value_source, check if SOURCE field has value
  if (props.question.default_value_source_question_id) {
    // Find source question and check its value
    const sourceValue = store.getResponse(sourceQuestion.name)
    const hasSourceValue = sourceValue !== undefined &&
                          sourceValue !== null &&
                          sourceValue !== ''
    return hasSourceValue  // Only readonly if source has value
  }

  return true  // Regular is_readonly behavior
})
```

**UI Implementation:**
```vue
<UIInput
  :model-value="modelValue"
  :readonly="isEffectivelyReadonly"
  :disabled="isEffectivelyReadonly"
  class="flex-1"
/>
```

**Styling:**
- Readonly fields: `opacity-60`, `cursor-not-allowed`, `disabled` state
- Applies to all input types: text, textarea, dropdown, switch, slider, toggles, orientation selector

**Example Flow:**
```
1. Basic Data → "External Wall Structure" = "" (empty)
   → Facade Insulation → "Wall Structure" = editable ✓

2. User fills Basic Data → "External Wall Structure" = "Brick"
   → Facade Insulation → "Wall Structure" = "Brick" (readonly, grayed out) ✓

3. User clears Basic Data → "External Wall Structure" = ""
   → Facade Insulation → "Wall Structure" = "Brick" (editable again) ✓
```

---

### Integration Example

**Complete Workflow: Basic Data → Facade Insulation**

```typescript
// Migration 099: Setup default_value_source
INSERT INTO survey_questions (
  survey_page_id, name, type,
  default_value_source_question_id,  // Points to Basic Data question
  is_readonly                          // Set to true
) VALUES (
  facade_wall_page_id,
  'wall_structure',
  'dropdown',
  basic_data_wall_structure_id,      // Source question ID
  true
);
```

**User Interaction:**
1. Navigate to "Facade Insulation" → "Walls" page (allow_multiple)
2. First wall instance auto-created → `ensurePageInstancesInitialized` triggered
3. Default values loaded from "Basic Data" → `loadDefaultValuesForInstance`
4. Field readonly if source has value → `isEffectivelyReadonly = true`
5. User adds 2nd wall → `addPageInstance` → defaults auto-loaded
6. User changes Basic Data → `syncDependentQuestionsInState` → all walls update instantly
7. All changes saved to database → `saveInstanceResponse` with `item_group`

**Database Result:**
```sql
SELECT * FROM survey_answers WHERE question_id = 'wall_structure';

survey_id | question_id    | answer    | item_group
----------|----------------|-----------|------------
uuid-123  | wall_structure | Brick     | 0
uuid-123  | wall_structure | Brick     | 1
uuid-123  | wall_structure | Concrete  | 2  -- User manually changed this one
```

---

### Hierarchical Survey Pages (NEW - 2025-10-30)

**Overview:**
Survey pages can now have parent-child relationships, enabling nested data entry structures where each parent instance can have multiple child instances.

**Use Case:**
"Falak" (Walls) page is the parent, "Nyílászárók" (Openings) is the subpage. Each wall can have multiple openings independently.

#### Database Schema

```sql
-- Parent page reference
ALTER TABLE survey_pages
ADD COLUMN parent_page_id UUID REFERENCES survey_pages(id) ON DELETE CASCADE;

-- Parent instance reference
ALTER TABLE survey_answers
ADD COLUMN parent_item_group INTEGER;

-- Unique constraint updated
CREATE UNIQUE INDEX idx_survey_answers_unique_with_parent
ON survey_answers (
  survey_id,
  survey_question_id,
  COALESCE(item_group, -1),
  COALESCE(parent_item_group, -1)
);
```

#### Store Structure

```typescript
pageInstances: {
  [investmentId]: {
    [pageId]: {
      instances: [...],           // Root page instances
      subpageInstances: {         // Subpage instances grouped by parent
        [parentItemGroup]: [...]  // Each parent has its own child instances
      }
    }
  }
}
```

#### Store Methods

```typescript
// Get all subpages for a parent
getSubPages(parentPageId: string): SurveyPage[]

// Get subpage instances for specific parent
getSubPageInstances(subpageId: string, parentItemGroup: number): any[]

// Add subpage instance under parent
addSubPageInstance(subpageId: string, parentItemGroup: number): void

// Save subpage answer
saveSubPageInstanceResponse(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number,
  questionName: string,
  value: any
): Promise<void>
```

#### UI Structure

Hierarchical pages render as nested accordions:

```vue
<UAccordion>  <!-- Parent: Wall #1 -->
  <div>
    <!-- Wall questions -->

    <div v-for="subpage in getSubPages(wallPageId)">
      <h5>{{ subpage.name }}</h5>  <!-- "Nyílászárók" -->

      <UAccordion>  <!-- Child: Opening #1 -->
        <!-- Opening questions -->
      </UAccordion>

      <UAccordion>  <!-- Child: Opening #2 -->
        <!-- Opening questions -->
      </UAccordion>

      <UButton @click="addSubPageInstance(subpage.id, wallIndex)">
        Add Opening
      </UButton>
    </div>
  </div>
</UAccordion>
```

#### Migration Files

- **102_add_hierarchical_survey_pages.sql** - Adds parent_page_id and parent_item_group support
- **104_create_openings_survey_page.sql** - Creates Nyílászárók subpage under Falak
- **105_add_planned_investment_and_site_conditions_pages.sql** - Additional facade insulation pages

---

### Automated Wall Metrics Calculations (NEW - 2025-10-30)

**Overview:**
Real-time calculations for facade insulation metrics, automatically updating as users input wall and opening data.

**Use Case:**
Calculate net facade area by subtracting opening areas from gross wall area, with special handling for reveal (káva) surfaces.

#### Calculation Methods

**Location:** `/app/components/Survey/SurveyPropertyAssessment.vue:463-552`

```typescript
// Per-wall calculations
const calculateWallMetrics = (pageId: string, parentItemGroup: number) => {
  // 1. Get wall dimensions
  const wallLength = getInstanceQuestionValue(pageId, parentItemGroup, 'wall_length')
  const wallHeight = getInstanceQuestionValue(pageId, parentItemGroup, 'wall_height')
  const foundationHeight = getInstanceQuestionValue(pageId, parentItemGroup, 'foundation_height')

  // 2. Calculate basic areas (m²)
  const bruttoHomlokzat = wallLength * wallHeight
  const bruttoLabazatNelkul = wallLength * (wallHeight - foundationHeight)
  const labazatFeluletePostpone = wallLength * foundationHeight

  // 3. Get openings for this wall
  const openings = getSubPageInstances(openingsPageId, parentItemGroup)

  let nyilaszarokFeluletePostpone = 0
  let kavaFeluletek = 0

  openings.forEach(opening => {
    const type = getSubPageInstanceQuestionValue(..., 'opening_type')
    const width = Number(...) / 100  // cm to m
    const height = Number(...) / 100
    const quantity = Number(...)
    const revealDepth = Number(...) / 100

    // Opening surface area
    nyilaszarokFeluletePostpone += width * height * quantity

    // Reveal (káva) calculation - opening type specific
    if (type === 'Ablak') {
      // Window: 4 sides (full perimeter)
      kavaFeluletek += (width * 2 + height * 2) * revealDepth * quantity
    } else if (type === 'Ajtó' || type === 'Erkélyajtó') {
      // Door: 3 sides (no bottom)
      kavaFeluletek += (width + height * 2) * revealDepth * quantity
    }
  })

  // 4. Net facade area
  const nettoHomlokzat = bruttoLabazatNelkul - nyilaszarokFeluletePostpone

  return { bruttoHomlokzat, bruttoLabazatNelkul, labazatFeluletePostpone,
          nyilaszarokFeluletePostpone, nettoHomlokzat, kavaFeluletek }
}

// Aggregate calculations for all walls
const calculateAllWallsMetrics = (pageId: string) => {
  const instances = getPageInstances(pageId)
  let totals = { /* ... */ }

  instances.forEach((instance, index) => {
    const metrics = calculateWallMetrics(pageId, index)
    // Sum up all metrics
  })

  return totals
}
```

#### Calculation Formulas

1. **Homlokzat bruttó (Gross facade):**
   ```
   wall_length × wall_height
   ```

2. **Homlokzat bruttó, lábazat nélkül (Gross without foundation):**
   ```
   wall_length × (wall_height - foundation_height)
   ```

3. **Lábazat felülete (Foundation surface):**
   ```
   wall_length × foundation_height
   ```

4. **Nyílászárók felülete (Opening surface):**
   ```
   Σ (opening_width × opening_height × opening_quantity)
   Unit: cm → m (divide by 100)
   ```

5. **Homlokzat nettó (Net facade):**
   ```
   (Gross without foundation) - (Total openings)
   ```

6. **Káva felületek (Reveal surfaces):**
   - **Windows (Ablak):** 4 sides
     ```
     Σ ((width × 2 + height × 2) × reveal_depth × quantity)
     ```
   - **Doors (Ajtó/Erkélyajtó):** 3 sides
     ```
     Σ ((width + height × 2) × reveal_depth × quantity)
     ```
   Unit: cm → m (divide by 100)

#### UI Display

**Per-Wall Metrics:**
- Displayed in accordion inside each wall instance
- Background: Blue (`bg-blue-50` / `dark:bg-blue-900/20`)
- Collapsible by default

**Total Metrics:**
- Displayed below "Add Wall" button
- Background: Green (`bg-green-50` / `dark:bg-green-900/20`)
- Only shown when walls exist
- Aggregates all wall metrics

**Real-Time Updates:**
- Calculations update instantly as user types
- Automatic recalculation when openings added/removed
- No manual refresh required

**Component Location:** `/app/components/Survey/SurveyPropertyAssessment.vue:340-382`

---

### Conditional Value Copy Rules (NEW - 2025-11-03)

**Overview:**
A flexible system for copying values between survey questions based on conditional rules. More powerful than simple `default_value_source_question_id` as it allows condition evaluation before copying.

**Key Difference:**
- **`default_value_source_question_id`**: ALWAYS copies value (no conditions)
- **`survey_value_copy_rules`**: Only copies when condition is met (e.g., switch is ON)

#### Database Schema

**survey_value_copy_rules Table:**
```sql
CREATE TABLE IF NOT EXISTS public.survey_value_copy_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    condition_question_id UUID NOT NULL,  -- The switch/checkbox
    condition_value TEXT NOT NULL,        -- Expected value (e.g., "true")
    source_question_id UUID NOT NULL,     -- Where to copy FROM
    target_question_id UUID NOT NULL,     // Where to copy TO
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Indexes:**
- `idx_copy_rules_condition` ON `condition_question_id`
- `idx_copy_rules_source` ON `source_question_id`
- `idx_copy_rules_target` ON `target_question_id`

#### Database Trigger

**Function:** `sync_conditional_value_copy()`

**Trigger:** Fires on `INSERT OR UPDATE OF answer ON survey_answers`

**Behavior:**
1. Detects if changed question is involved in any copy rule (as condition OR source)
2. For each matching rule:
   - Get current value of condition_question
   - Check if value equals condition_value
   - If YES: Copy source_question value to ALL instances of target_question
   - If NO: Do nothing
3. Uses **check-then-insert/update pattern** (NOT `ON CONFLICT`) to avoid unique constraint issues

```sql
CREATE TRIGGER trigger_sync_conditional_value_copy
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_conditional_value_copy();
```

**Important:** Uses explicit SELECT → IF EXISTS → UPDATE ELSE INSERT instead of ON CONFLICT to avoid "42P10" errors.

#### Implemented Rules

**Migration 136** creates three copy rules for facade insulation:

1. **Wall Structure Rule**
   - **Condition:** "Falak mindenhol megegyező típusúak" (walls_uniform_type) = `true`
   - **Source:** Alapadatok → "Fal típusa" (exterior_wall_structure)
   - **Target:** Homlokzati szigetelés - Falak → "Fal szerkezete" (wall_structure)
   - **Effect:** When switch is ON, all wall instances get the same structure type

2. **Wall Thickness Rule**
   - **Condition:** "Fal vastagsága mindenhol megegyezik" (wall_thickness_uniform) = `true`
   - **Source:** Homlokzati szigetelés - Alapadatok → "Fal vastagsága átlag" (wall_thickness_avg)
   - **Target:** Homlokzati szigetelés - Falak → "Fal vastagsága" (wall_thickness)
   - **Effect:** When switch is ON, all wall instances get the same thickness

3. **Foundation Type Rule**
   - **Condition:** "Lábazat típusa mindenhol megegyezik" (foundation_type_uniform) = `true`
   - **Source:** Homlokzati szigetelés - Alapadatok → "Lábazat típusa átlag" (foundation_type_avg)
   - **Target:** Homlokzati szigetelés - Falak → "Lábazat típusa" (foundation_type)
   - **Effect:** When switch is ON, all wall instances get the same foundation type

#### Frontend Implementation

**Location:** `/app/stores/surveyInvestments.ts`

```typescript
// Called after saveResponse() to refresh frontend state
async refreshCopiedValuesFromRules(changedQuestionId: string) {
  if (!this.currentSurveyId) return

  try {
    const supabase = useSupabaseClient()

    // 1. Query copy rules involving this question
    const { data: rules } = await supabase
      .from('survey_value_copy_rules')
      .select('*')
      .or(`condition_question_id.eq.${changedQuestionId},source_question_id.eq.${changedQuestionId}`)

    if (!rules || rules.length === 0) return

    // 2. For each rule, check if condition is met
    for (const rule of rules) {
      const { data: conditionAnswer } = await supabase
        .from('survey_answers')
        .select('answer')
        .eq('survey_id', this.currentSurveyId)
        .eq('survey_question_id', rule.condition_question_id)
        .is('item_group', null)
        .maybeSingle()

      // 3. Only proceed if condition matches
      const conditionMet = conditionAnswer?.answer === rule.condition_value
      if (!conditionMet) continue

      // 4. Find target question info (page, investment)
      const targetQuestionInfo = this.findQuestionById(rule.target_question_id)
      if (!targetQuestionInfo) continue

      // 5. Reload all target instance values from database
      const { data: answers } = await supabase
        .from('survey_answers')
        .select('item_group, answer')
        .eq('survey_id', this.currentSurveyId)
        .eq('survey_question_id', rule.target_question_id)
        .not('item_group', 'is', null)

      // 6. Update frontend state with fresh values
      if (answers && answers.length > 0) {
        const instances = this.pageInstances[investmentId][pageId].instances
        for (const answer of answers) {
          instances[answer.item_group][targetQuestion.name] = answer.answer
        }
      }
    }
  } catch (error) {
    console.error('Error refreshing copied values from rules:', error)
  }
}
```

**Integration Point:**
```typescript
async saveResponse(questionName: string, value: any) {
  // ... save to database ...

  // Sync dependent questions (old system)
  await this.syncDependentQuestionsInState(questionId, String(value))

  // Refresh conditional copies (new system)
  await this.refreshCopiedValuesFromRules(questionId)
}
```

#### User Workflow Example

**Scenario:** User sets "Fal típusa" = "Brick" with uniform wall types

1. **User clicks switch:** "Falak mindenhol megegyező típusúak" → ON
   - `saveResponse('walls_uniform_type', 'true')` called
   - Database trigger evaluates condition → copies nothing yet (no source value)

2. **User sets wall type:** "Fal típusa" → "Brick"
   - `saveResponse('exterior_wall_structure', 'Brick')` called
   - Database trigger evaluates condition → switch is ON
   - Database trigger copies "Brick" to ALL wall instances
   - `refreshCopiedValuesFromRules()` called
   - Frontend state refreshed → UI shows "Brick" in all wall structure fields

3. **User toggles switch OFF:** "Falak mindenhol megegyező típusúak" → OFF
   - Database trigger stops copying
   - Existing values remain (no automatic deletion)
   - User can now manually edit each wall's structure independently

4. **User toggles switch ON again:** "Falak mindenhol megegyező típusúak" → ON
   - Database trigger resumes copying
   - ALL wall instances get current "Fal típusa" value (overwrites manual changes)

#### Migration Notes

**Migration 136:** Creates table, trigger, and 3 copy rules

**Migration 137:** Cleans up old `default_value_source_question_id` references
- Removes `default_value_source_question_id` from target questions now using copy rules
- Prevents both systems from running simultaneously
- Ensures only conditional logic applies

**Why separate migrations?**
- Migration 136 ran first (creates new system)
- Migration 137 removes old references (prevents conflicts)
- Questions transitioned from unconditional to conditional copying

#### Advantages Over default_value_source

1. **Conditional Logic:** Copy only when needed (switch ON)
2. **Bulk Operations:** Update ALL instances in one trigger execution
3. **Flexible Conditions:** Any question + any value can be a condition
4. **Multi-Rule Support:** Multiple rules can target same question
5. **Frontend Sync:** Automatic refresh keeps UI consistent with database

#### Limitations

- **Trigger Overhead:** Evaluates rules on every answer INSERT/UPDATE
- **No Partial Matching:** Condition must exactly match (no ranges, no patterns)
- **Overwrite Behavior:** Always overwrites target values when condition is met
- **No History:** Previous values are lost when rule applies

---

### Template Variables System (NEW - 2025-11-05)

**Overview:**
A dynamic text substitution system that allows survey question labels to display runtime-calculated values based on user responses. Variables are defined in the database as JSON configurations and processed at render time on the frontend.

**Key Use Case:**
Warning messages that dynamically show which specific options were selected by the user, rather than displaying static text that may become outdated when options change.

#### Database Schema

**survey_questions.template_variables Column:**
```sql
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS template_variables JSONB;

COMMENT ON COLUMN public.survey_questions.template_variables IS
  'Template variable definitions for dynamic text replacement.
   Example: {"selectedHeatingMethods": {"type": "matched_conditional_values", "field": "heating_methods"}}.
   Supported types:
   - matched_conditional_values: values that match display_conditions
   - field_value: direct field value
   - conditional_count: count of matched conditions';
```

**Structure:**
```json
{
  "variableName": {
    "type": "matched_conditional_values" | "field_value" | "conditional_count",
    "field": "question_name_to_reference"
  }
}
```

#### Variable Types

**1. matched_conditional_values**
Returns the intersection of selected values and the question's display_conditions.

**Purpose:** Show which selected options triggered a conditional question to appear.

**Example:**
```json
{
  "selectedHeatingMethods": {
    "type": "matched_conditional_values",
    "field": "heating_methods"
  }
}
```

**Behavior:**
- Gets current value of `heating_methods` field
- Parses as array (handles JSON, comma-separated, or array format)
- Gets `display_conditions.value` from current question
- Returns intersection of both arrays
- Joins matched values with `, ` separator

**Output:** `"Gázkazán, Elektromos fűtés, Olajkályha"`

**2. field_value**
Returns the direct value of a specified field.

**Purpose:** Display current answer to another question.

**Example:**
```json
{
  "roofArea": {
    "type": "field_value",
    "field": "roof_area_m2"
  }
}
```

**Behavior:**
- Gets current value of `roof_area_m2` field
- Converts to string
- Returns raw value

**Output:** `"150"` (if roof_area_m2 = 150)

**3. conditional_count**
Returns the count of selected values that match display_conditions.

**Purpose:** Show number of matching items (e.g., "3 heating methods selected").

**Example:**
```json
{
  "matchedCount": {
    "type": "conditional_count",
    "field": "heating_methods"
  }
}
```

**Behavior:**
- Gets current value of `heating_methods` field
- Parses as array
- Counts intersection with `display_conditions.value`
- Returns count as string

**Output:** `"3"` (if 3 heating methods match)

#### Frontend Implementation

**Location:** `/app/components/Survey/SurveyQuestionRenderer.vue`

**Processing Function:**
```typescript
const processTemplateVariables = (text: string): string => {
  if (!text || !props.question.template_variables) {
    return text
  }

  let processedText = text
  const templateVarRegex = /\{([^}]+)\}/g  // Matches {variableName}
  const matches = text.match(templateVarRegex)

  if (!matches) {
    return text
  }

  for (const match of matches) {
    const varName = match.slice(1, -1)  // Remove { and }
    const varDef = props.question.template_variables[varName]

    if (!varDef) {
      continue  // Unknown variable, skip
    }

    let replacement = ''

    switch (varDef.type) {
      case 'matched_conditional_values': {
        // Get field value
        const fieldValue = store.getResponse(varDef.field)

        // Parse to array
        let fieldArray: string[] = []
        if (Array.isArray(fieldValue)) {
          fieldArray = fieldValue
        } else if (typeof fieldValue === 'string') {
          try {
            const parsed = JSON.parse(fieldValue)
            fieldArray = Array.isArray(parsed) ? parsed : [fieldValue]
          } catch {
            fieldArray = fieldValue.split(',').map(v => v.trim())
          }
        }

        // Get conditional values
        const conditionalValues = Array.isArray(props.question.display_conditions.value)
          ? props.question.display_conditions.value
          : [props.question.display_conditions.value]

        // Find intersection
        const matchedValues = fieldArray.filter(fv =>
          conditionalValues.some(cv => fv === cv)
        )

        replacement = matchedValues.join(', ')
        break
      }

      case 'field_value': {
        const fieldValue = store.getResponse(varDef.field)
        replacement = fieldValue ? String(fieldValue) : ''
        break
      }

      case 'conditional_count': {
        const fieldValue = store.getResponse(varDef.field)
        // ... parse to array (same as above) ...
        const matchedCount = fieldArray.filter(fv =>
          conditionalValues.some(cv => fv === cv)
        ).length
        replacement = String(matchedCount)
        break
      }
    }

    processedText = processedText.replace(match, replacement)
  }

  return processedText
}
```

**Integration with Computed Property:**
```typescript
const questionLabel = computed(() => {
  const rawLabel = translate(
    props.question.name_translations,
    translateField(props.question.name)
  )
  return processTemplateVariables(rawLabel)
})
```

**Reactivity:**
- Computed property automatically re-runs when:
  - Store responses change
  - Question template_variables change
  - Question name_translations change
- Real-time updates as user selects options

#### Variable Syntax

**In Database (name_translations):**
```json
{
  "hu": "💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: {selectedHeatingMethods}",
  "en": "💡 The following questions appear due to the selected heating methods: {selectedHeatingMethods}"
}
```

**Pattern:** `{variableName}`
- Must match exactly with key in `template_variables` object
- Case-sensitive
- No spaces inside braces
- Can appear anywhere in text (beginning, middle, end)
- Multiple variables per text supported

**Invalid Examples:**
- `{ selectedHeatingMethods }` (spaces)
- `{{selectedHeatingMethods}}` (double braces)
- `$selectedHeatingMethods` (wrong syntax)

#### Real-World Examples

**Example 1: Electric Storage Heater Warning**

**Database Setup:**
```sql
UPDATE survey_questions
SET
  name_translations = jsonb_build_object(
    'hu', '💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: {selectedHeatingMethods}',
    'en', '💡 The following questions appear due to the selected heating methods: {selectedHeatingMethods}'
  ),
  template_variables = jsonb_build_object(
    'selectedHeatingMethods', jsonb_build_object(
      'type', 'matched_conditional_values',
      'field', 'heating_methods'
    )
  ),
  display_conditions = jsonb_build_object(
    'field', 'heating_methods',
    'operator', 'contains_any',
    'value', jsonb_build_array(
      'Elektromos tárolós fűtés / Éjszakai fűtés',
      'Elektromos áramlásos fűtés / Elektromos radiátor',
      'Elektromos padlófűtés',
      'Elektromos infra fűtés'
    )
  )
WHERE name = 'electric_storage_heater_warning';
```

**User Selects:**
- "Elektromos tárolós fűtés / Éjszakai fűtés"
- "Gázkazán" (not in display_conditions)
- "Elektromos padlófűtés"

**Rendered Output (Hungarian):**
> 💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: Elektromos tárolós fűtés / Éjszakai fűtés, Elektromos padlófűtés

**Example 2: Gas Heating Methods Warning**

**Database Setup:**
```sql
INSERT INTO survey_questions (
  survey_page_id,
  name,
  name_translations,
  type,
  sequence,
  display_conditions,
  template_variables
) VALUES (
  page_id,
  'gas_heating_methods_warning',
  jsonb_build_object(
    'hu', '💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: {selectedGasHeatingMethods}',
    'en', '💡 The following questions appear due to the selected heating methods: {selectedGasHeatingMethods}'
  ),
  'warning',
  17,
  jsonb_build_object(
    'field', 'heating_methods',
    'operator', 'contains_any',
    'value', jsonb_build_array(
      'Állandó hőmérsékletű kazán (hagyományos gázkazán radiátoros fűtéshez, általában pincében vagy fürdőszobában elhelyezve)',
      'Alacsony hőmérsékletű kazán (modern gázkazán padlófűtéshez optimalizálva, alacsonyabb hőmérsékleten üzemel)',
      'Kondenzációs kazán (legkorszerűbb, energiatakarékos gázkazán kondenzációs technológiával)',
      'Hagyományos gázkonvektor (falra szerelt, egyedi szobafűtés gázzal működtetve)',
      'Nyílt égésterű gravitációs gázkonvektor (régebbi típusú fali gázfűtés, kéménybe kötött, természetes légáramlással)',
      'Külsőfali gázkonvektor (falra szerelt, külső falon át levegőt vevő egyedi fűtés)'
    )
  ),
  jsonb_build_object(
    'selectedGasHeatingMethods', jsonb_build_object(
      'type', 'matched_conditional_values',
      'field', 'heating_methods'
    )
  )
);
```

**User Selects:**
- "Kondenzációs kazán (legkorszerűbb, energiatakarékos gázkazán kondenzációs technológiával)"
- "Napelemes rendszer" (not in display_conditions)

**Rendered Output (Hungarian):**
> 💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: Kondenzációs kazán (legkorszerűbb, energiatakarékos gázkazán kondenzációs technológiával)

**Display Behavior:**
- Warning only appears when at least one gas heating method is selected
- Dynamic text updates in real-time as user changes selections
- If user deselects all gas methods → warning disappears entirely

#### Workflow

**1. Page Load:**
```
User navigates to survey page
  ↓
SurveyQuestionRenderer receives question
  ↓
Checks if template_variables exists
  ↓
If YES: processTemplateVariables() called
  ↓
Rendered with substituted values
```

**2. User Interaction:**
```
User selects/deselects heating method
  ↓
Store updates response
  ↓
Computed property (questionLabel) re-runs
  ↓
processTemplateVariables() called again
  ↓
UI updates with new values
```

**3. Conditional Display:**
```
User selects option that matches display_conditions
  ↓
Question becomes visible (conditional rendering)
  ↓
Template variables processed
  ↓
Shows matched selections in text
```

#### Type Safety

**TypeScript Interfaces:**
```typescript
// /app/stores/surveyInvestments.ts

export interface TemplateVariable {
  type: 'matched_conditional_values' | 'field_value' | 'conditional_count'
  field: string
}

export interface SurveyQuestion {
  id: string
  name: string
  type: SurveyQuestionType
  name_translations?: Record<string, string>
  template_variables?: Record<string, TemplateVariable>
  display_conditions?: {
    field: string
    operator: 'contains_any' | 'equals' | 'not_equals'
    value: string | string[]
  }
  // ... other fields
}
```

**Benefits:**
- TypeScript ensures correct variable structure
- Autocomplete for variable types
- Compile-time error detection
- Clear interface documentation

#### Performance Considerations

**Regex Execution:**
- Simple pattern: `/\{([^}]+)\}/g`
- Runs on every computed property evaluation
- Negligible performance impact for typical text lengths

**Store Access:**
- `store.getResponse()` is O(1) lookup
- No database queries (frontend-only processing)
- Reactive updates handled by Vue's computed properties

**Array Operations:**
- Parsing and filtering scale with array size
- Typical arrays: 1-20 items
- No noticeable performance impact

**Optimization:**
- Early return if no template_variables
- Early return if no matches in text
- Skip unknown variable names

#### Limitations

**Current Limitations:**
1. **Single Field Reference:** Each variable can only reference one field
2. **No Nested Variables:** Cannot use `{var1{var2}}` syntax
3. **No Expressions:** Cannot compute `{field1 + field2}` or `{field * 2}`
4. **String Output Only:** All replacements become strings
5. **No Formatting:** No date formatting, number formatting, etc.
6. **Frontend Only:** No server-side rendering of variables

**Workarounds:**
- For complex logic: Create separate computed properties in component
- For formatting: Use frontend filters/pipes after substitution
- For multiple fields: Create multiple variables

#### Future Enhancements

**Potential Improvements:**
- [ ] Custom formatting functions (date, number, currency)
- [ ] Multiple field references per variable
- [ ] Conditional expressions within variables
- [ ] Server-side variable resolution for PDF exports
- [ ] Variable preview in admin interface
- [ ] Variable validation at migration time
- [ ] Support for nested variables
- [ ] Arithmetic expressions

#### Migration Files

**1009_add_template_variables.sql** - Creates template variable system
- Adds `template_variables` column
- Adds column comment with documentation
- Updates `electric_storage_heater_warning` question with example usage
- Demonstrates complete setup pattern

**1010_add_gas_heating_warning.sql** - Additional usage example
- Creates `gas_heating_methods_warning` question
- Uses `matched_conditional_values` type
- Shows conditional display + template variables together

#### Advantages

**1. Database-Driven:**
- Variable logic stored in database, not hardcoded
- Can add/modify variables without code deployment
- Migration-based versioning

**2. Flexible:**
- Three variable types cover common use cases
- Extensible architecture for new types
- Works with any question type

**3. Reactive:**
- Real-time updates as user interacts
- No manual refresh needed
- Leverages Vue's computed properties

**4. Localized:**
- Variables work with translated text
- Same variable in multiple languages
- Consistent behavior across locales

**5. Maintainable:**
- Clear separation: database config + frontend processing
- TypeScript interfaces ensure correctness
- Self-documenting code with strong types

**6. Performant:**
- Frontend-only processing (no API calls)
- Computed properties cache results
- Minimal overhead

#### Common Patterns

**Pattern 1: Warning with Matched Values**
```sql
-- Question that appears conditionally and shows what matched
template_variables = {
  "matchedItems": {
    "type": "matched_conditional_values",
    "field": "option_field"
  }
}
display_conditions = {
  "field": "option_field",
  "operator": "contains_any",
  "value": ["Option A", "Option B", "Option C"]
}
name_translations = {
  "en": "⚠️ You selected: {matchedItems}"
}
```

**Pattern 2: Dynamic Field Display**
```sql
-- Show value from another question
template_variables = {
  "clientName": {
    "type": "field_value",
    "field": "client_name"
  }
}
name_translations = {
  "en": "Hello {clientName}, please confirm your details"
}
```

**Pattern 3: Count Display**
```sql
-- Show count of matched items
template_variables = {
  "selectedCount": {
    "type": "conditional_count",
    "field": "features"
  }
}
name_translations = {
  "en": "You have selected {selectedCount} features"
}
```

#### Testing Template Variables

**Manual Testing Steps:**
1. Navigate to survey page with template variable question
2. Ensure question has display_conditions and is initially hidden
3. Select options that match display_conditions
4. Verify question appears
5. Verify variable substitution shows correct values
6. Select/deselect options
7. Verify text updates in real-time
8. Check multiple language variants
9. Verify text formatting (spaces, punctuation)

**Example Test Case:**
```
Given: heating_methods question with multiselect
And: electric_storage_heater_warning with {selectedHeatingMethods} variable
When: User selects "Elektromos tárolós fűtés / Éjszakai fűtés"
Then: Warning appears with text containing selected method name
When: User adds "Elektromos padlófűtés" selection
Then: Text updates to show both methods separated by ", "
When: User deselects all electric methods
Then: Warning disappears
```

#### Related Features

**Works Together With:**
- **Display Conditions:** Controls when questions appear
- **Multiselect Questions:** Common source for template variables
- **Localization:** Template variables respect i18n
- **Question Types:** Works with all question types, especially `warning` and `title`

**Comparison with Other Systems:**
- **vs default_value_source_question_id:** Template vars are for display text, not for copying answer values
- **vs Conditional Value Copy Rules:** Template vars show text, copy rules modify data
- **vs Computed Questions:** Template vars are text-only, computed questions calculate numeric values

---

## Related Documentation

- [Survey Page Feature Documentation](features/SURVEY_PAGE.md) - Complete survey page feature documentation
- [Consultation Page Details](survey-consultation-page.md) - Complete Consultation page documentation
- [Property Assessment Page](survey-property-assessment.md) - Property Assessment page documentation
- [Contract Data Page](survey-contract-data-page.md) - Contract Data page documentation
- [Summary Page](survey-summary-page.md) - Summary page with contract preview and signing functionality
- [Investment-Aware Response Tracking Bugfix](survey-property-assessment.md#investment-aware-question-response-tracking-bugfix) - Detailed bugfix documentation
