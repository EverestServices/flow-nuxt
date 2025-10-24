# Offer/Contract Page Documentation

**Created:** 2025-10-24
**Last Updated:** 2025-10-24
**Version:** 1.0.0
**Related Migrations:** `070_add_investment_id_to_pivot_tables.sql`, `031_create_products_system.sql`

---

## Table of Contents

1. [Overview](#overview)
2. [Recent Updates](#recent-updates)
3. [Architecture](#architecture)
4. [Component Hierarchy](#component-hierarchy)
5. [Database Schema](#database-schema)
6. [State Management](#state-management)
7. [Cost Calculations](#cost-calculations)
8. [User Flows](#user-flows)
9. [Investment-Specific Component Tracking](#investment-specific-component-tracking)
10. [Technical Implementation](#technical-implementation)
11. [Testing Checklist](#testing-checklist)
12. [Troubleshooting](#troubleshooting)

---

## Overview

Az Offer/Contract oldal a survey folyamat harmadik fázisa, ahol az előzőleg megtervezett scenario alapján ajánlat (offer) vagy szerződés (contract) generálható. Az oldal két fő részből áll: bal oldalon a technikai részletek és konfiguráció, jobb oldalon pedig a szerződés adatok és árak.

### Key Features

- ✅ Scenario-based contract generation
- ✅ Investment-specific technical details management
- ✅ Component categorization with Hungarian translations
- ✅ Roof configuration for solar installations
- ✅ Compatibility check (panels & inverters)
- ✅ Solar-specific extra costs management
- ✅ General extra costs management
- ✅ Discount management
- ✅ VAT and commission rate handling
- ✅ Real-time price calculations
- ✅ Investment-aware component tracking (NEW - 2025-10-24)

---

## Recent Updates

### 2025-10-24: Investment-Specific Component Tracking

**Major Features Added:**

1. **Investment ID on Pivot Tables**
   - Added `investment_id` column to `scenario_main_components` table
   - Added `investment_id` column to `contract_main_components` table
   - Updated unique constraints to `(scenario_id, main_component_id, investment_id)`
   - Updated unique constraints to `(contract_id, main_component_id, investment_id)`

2. **Investment-Aware Component Filtering**
   - Store getter updated to filter components by investment
   - Each investment displays only its own components
   - Prevents component duplication across investments
   - Maintains data integrity with proper relationships

3. **Duplicate Component Support**
   - Same component can be used in multiple investments
   - Each investment-component pair stored as separate row
   - Proper quantity tracking per investment
   - Prevents unique constraint violations

**Database Changes:**
- Migration 070: `investment_id` column added to pivot tables
- Unique constraints updated to include `investment_id`
- Indexes created for performance optimization

**Files Modified:**
- `supabase/migrations/070_add_investment_id_to_pivot_tables.sql` (NEW)
- `app/stores/scenarios.ts` - Getter updated with investment filtering
- `app/stores/contracts.ts` - Interface and methods updated
- `app/composables/useScenarioCreation.ts` - Component insertion updated
- `app/components/Survey/SurveyScenarioCategories.vue` - Investment ID passed
- `app/components/Survey/SurveyOfferContractCategories.vue` - Investment ID passed
- `app/components/Survey/SurveyOfferContract.vue` - Contract data collection updated

**Bug Fix:**
- **Issue:** Same component appeared in multiple investment sections
- **Root Cause:** Components filtered only by category, not by investment
- **Solution:** Added `investmentId` parameter to store getter for proper filtering

---

## Architecture

### Main Components

#### 1. `SurveyOfferContract.vue`

**Location:** `app/components/Survey/SurveyOfferContract.vue`

**Purpose:** Főkomponens az Offer/Contract oldalon, két oszlopra osztva.

**Props:**
- `surveyId: string` - Survey azonosító
- `contractMode: 'offer' | 'contract' | null` - Contract típus

**Layout:**
- **Left Column (w-1/2):**
  - Scenario Selector
  - Technical Details (accordions per investment)
  - Roof Configuration (csak Solar Panel scenariokhoz)
  - Compatibility Check (csak Solar Panel scenariokhoz)
  - Solar Extra Costs (csak Solar Panel scenariokhoz)
  - General Extra Costs
  - Discounts (csak Solar Panel scenariokhoz)

- **Right Column (w-1/2):**
  - Contract Details
  - Prices (collapse/expand)

**Features:**
- Scenario selection buttons with investment icons
- Investment-based accordion visibility
- Reactive price calculations
- Commission rate management
- VAT handling
- Data collection for contract creation/modification

---

#### 2. `SurveyOfferContractTechnicalDetails.vue`

**Location:** `app/components/Survey/SurveyOfferContractTechnicalDetails.vue`

**Purpose:** Investment accordionok megjelenítése technikai adatokkal.

**Props:**
- `surveyId: string` - Survey azonosító
- `scenarioId: string` - Scenario azonosító

**Features:**
- Dynamic investment accordions
- Investment-specific icons and names
- Nested `SurveyOfferContractCategories` component per investment
- Empty state handling

**Data Flow:**
```typescript
scenariosStore.scenarioInvestments[scenarioId]
  → investment IDs
  → investmentsStore.availableInvestments
  → full investment details with icons
  → accordions with categories
```

---

#### 3. `SurveyOfferContractCategories.vue`

**Location:** `app/components/Survey/SurveyOfferContractCategories.vue`

**Purpose:** Main component kategóriák és komponensek kezelése egy adott befektetéshez.

**Props:**
- `scenarioId: string` - Scenario azonosító
- `investmentId: string` - Investment azonosító (CRITICAL for filtering)

**Features:**
- **Add Component:** Új komponens hozzáadása kategóriához
  - Automatically selects next available component
  - Prevents duplicates within same investment
  - Loading state management
- **Component Selection:** Dropdown for component switching
- **Quantity Management:** Quantity editing
- **Delete:** Component removal

**Investment-Aware Filtering:**
```typescript
// Get components for category filtered by investment
const getCategoryComponents = (categoryId: string) => {
  return scenariosStore.getScenarioComponentForCategory(
    categoryId,
    props.scenarioId,
    props.investmentId  // Critical parameter!
  )
}
```

---

#### 4. `SurveyOfferContractRoofConfiguration.vue`

**Location:** `app/components/Survey/SurveyOfferContractRoofConfiguration.vue`

**Purpose:** Tető konfiguráció megadása napelem rendszerekhez.

**Features:**
- Roof type selection (dropdown)
- Azimuth angle input (0-360°)
- Tilt angle input (0-90°)
- Roof area calculation
- Data persistence with `provide/inject` pattern

---

#### 5. `SurveyOfferContractCompatibilityCheck.vue`

**Location:** `app/components/Survey/SurveyOfferContractCompatibilityCheck.vue`

**Purpose:** Inverter-napelem kompatibilitás ellenőrzése.

**Features:**
- Panel and inverter selection from scenario components
- Power calculation (panels × panel_power)
- Inverter capacity check
- Compatibility status display (compatible/incompatible/warning)
- Visual feedback with color coding

**Compatibility Logic:**
```typescript
const totalPanelPower = panelQuantity × panelPower
const inverterCapacity = inverterPower

if (totalPanelPower > inverterCapacity × 1.2) {
  status = 'incompatible'  // Red
} else if (totalPanelPower > inverterCapacity × 1.1) {
  status = 'warning'  // Yellow
} else {
  status = 'compatible'  // Green
}
```

---

#### 6. `SurveyOfferContractExtraCosts.vue`

**Location:** `app/components/Survey/SurveyOfferContractExtraCosts.vue`

**Purpose:** Napelem-specifikus járulékos költségek kezelése.

**Features:**
- Solar-specific extra costs catalog loading
- Checkbox-based selection
- Quantity input per cost item
- Snapshot price display
- Comment field for custom notes
- Data export via `provide/inject`

**Data Structure:**
```typescript
{
  extra_cost_id: string,
  snapshot_price: number,
  quantity: number,
  comment: string,
  is_selected: boolean
}
```

---

#### 7. `SurveyOfferContractGeneralExtraCosts.vue`

**Location:** `app/components/Survey/SurveyOfferContractGeneralExtraCosts.vue`

**Purpose:** Általános (nem solar-specifikus) extra költségek kezelése.

**Features:**
- General extra costs catalog loading
- Similar UI to solar extra costs
- Independent selection and management
- Data export via `provide/inject`

---

#### 8. `SurveyOfferContractDiscounts.vue`

**Location:** `app/components/Survey/SurveyOfferContractDiscounts.vue`

**Purpose:** Kedvezmények kezelése.

**Features:**
- Discount catalog loading (subsidies)
- Checkbox-based enable/disable
- Percentage vs Fixed type handling
- Calculated value display
- Real-time total discount calculation
- Data export via `provide/inject`

**Discount Calculation:**
```typescript
if (discount.discount_type === 'percentage') {
  calculatedValue = totalPrice × (discount.discount_value / 100)
} else if (discount.discount_type === 'fixed') {
  calculatedValue = discount.discount_value
}
```

---

#### 9. `SurveyOfferContractDetails.vue`

**Location:** `app/components/Survey/SurveyOfferContractDetails.vue`

**Purpose:** Szerződés alapvető adatainak megjelenítése és szerkesztése.

**Props:**
- `surveyId: string`
- `scenarioId: string`
- `commissionRate: number` (0-1 scale, e.g., 0.12 = 12%)

**Features:**
- Client information display
- Survey date display
- Commission rate display (percentage format)
- Investment icons and names
- Read-only data presentation

---

#### 10. `SurveyOfferContractPrices.vue`

**Location:** `app/components/Survey/SurveyOfferContractPrices.vue`

**Purpose:** Részletes árkalkuláció megjelenítése.

**Props:**
- `surveyId: string`
- `scenarioId: string`
- `totalPriceAfterSubsidy: number`
- `totalDiscounts: number`
- `commissionRate: number`

**Features:**
- Main components total (by category)
- Solar extra costs total
- General extra costs total
- Implementation fee calculation
- Subsidies/Discounts display
- VAT calculation and display
- Final total price
- Formatted number display (Hungarian locale)

**Cost Breakdown Display:**
```
Main Components Total:      2,450,000 Ft
Solar Extra Costs:            112,000 Ft
General Extra Costs:           50,000 Ft
─────────────────────────────────────
Implementation Fee:         2,612,000 Ft

Subsidies:                   -768,600 Ft
─────────────────────────────────────
Subtotal:                   1,843,400 Ft

VAT (27%):                    497,718 Ft
─────────────────────────────────────
TOTAL:                      2,341,118 Ft
```

---

## Component Hierarchy

```
SurveyOfferContract.vue
├── Left Column
│   ├── Scenario Selector (buttons)
│   ├── Technical Details Accordion
│   │   └── SurveyOfferContractTechnicalDetails.vue
│   │       └── UAccordion (per investment)
│   │           └── SurveyOfferContractCategories.vue
│   │               ├── Category Headers
│   │               ├── Component Rows (UISelect + UInput + UButton)
│   │               └── Add Component Button
│   ├── Roof Configuration Accordion
│   │   └── SurveyOfferContractRoofConfiguration.vue
│   ├── Compatibility Check Accordion
│   │   └── SurveyOfferContractCompatibilityCheck.vue
│   ├── Solar Extra Costs Accordion
│   │   └── SurveyOfferContractExtraCosts.vue
│   ├── General Extra Costs Accordion
│   │   └── SurveyOfferContractGeneralExtraCosts.vue
│   └── Discounts Accordion
│       └── SurveyOfferContractDiscounts.vue
└── Right Column
    ├── Contract Details Accordion
    │   └── SurveyOfferContractDetails.vue
    └── Prices Accordion
        └── SurveyOfferContractPrices.vue
```

---

## Database Schema

### Updated Tables (Migration 070)

#### **scenario_main_components**
```sql
CREATE TABLE public.scenario_main_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    scenario_id UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
    main_component_id UUID NOT NULL REFERENCES public.main_components(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,  -- NEW!

    -- Quantity and pricing
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 1,
    price_snapshot DECIMAL(10, 2) NOT NULL,

    -- Updated unique constraint
    CONSTRAINT scenario_main_components_unique_key
        UNIQUE(scenario_id, main_component_id, investment_id)
);

-- Performance index
CREATE INDEX idx_scenario_main_components_investment_id
    ON public.scenario_main_components(investment_id);
```

**Key Changes:**
- ✅ `investment_id` column added
- ✅ Unique constraint now includes `investment_id`
- ✅ Same component can exist for different investments in same scenario
- ✅ Index created for efficient queries

#### **contract_main_components**
```sql
CREATE TABLE public.contract_main_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    main_component_id UUID NOT NULL REFERENCES public.main_components(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,  -- NEW!

    -- Quantity and pricing
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 1,
    price_snapshot DECIMAL(10, 2) NOT NULL,

    -- Updated unique constraint
    CONSTRAINT contract_main_components_unique_key
        UNIQUE(contract_id, main_component_id, investment_id)
);

-- Performance index
CREATE INDEX idx_contract_main_components_investment_id
    ON public.contract_main_components(investment_id);
```

**Key Changes:**
- ✅ `investment_id` column added
- ✅ Unique constraint now includes `investment_id`
- ✅ Same component can exist for different investments in same contract
- ✅ Index created for efficient queries

### Example Data Structure

**Before Migration 070:**
```sql
-- ❌ PROBLEM: Duplicate key error when adding same component for multiple investments
INSERT INTO scenario_main_components (scenario_id, main_component_id, quantity, price_snapshot)
VALUES
  ('scenario-1', 'panel-500w', 10, 50000),  -- Solar Panel investment
  ('scenario-1', 'panel-500w', 8, 50000);   -- ❌ ERROR! Duplicate constraint violation
```

**After Migration 070:**
```sql
-- ✅ SOLUTION: investment_id allows same component for different investments
INSERT INTO scenario_main_components (scenario_id, main_component_id, investment_id, quantity, price_snapshot)
VALUES
  ('scenario-1', 'panel-500w', 'investment-solar', 10, 50000),        -- Solar Panel
  ('scenario-1', 'panel-500w', 'investment-solar-battery', 8, 50000); -- ✅ OK! Different investment
```

---

## State Management

### Scenarios Store Updates

**Location:** `app/stores/scenarios.ts`

#### Updated Interface

```typescript
export interface ScenarioMainComponent {
  id: string
  scenario_id: string
  main_component_id: string
  investment_id: string  // NEW!
  quantity: number
  price_snapshot: number
}
```

#### Updated Getter

```typescript
getScenarioComponentForCategory: (state) => (
  categoryId: string,
  scenarioId?: string,
  investmentId?: string  // NEW! Optional investment filter
) => {
  const targetScenarioId = scenarioId || state.activeScenarioId
  if (!targetScenarioId) return []

  const scenarioComponents = state.scenarioComponents[targetScenarioId] || []

  return scenarioComponents.filter(sc => {
    const component = state.mainComponents.find(mc => mc.id === sc.main_component_id)
    const categoryMatch = component?.main_component_category_id === categoryId
    const investmentMatch = investmentId ? sc.investment_id === investmentId : true  // NEW!
    return categoryMatch && investmentMatch
  })
}
```

**Usage:**
```typescript
// Get all components for category (all investments)
const allComponents = store.getScenarioComponentForCategory(categoryId)

// Get components for category filtered by investment
const investmentComponents = store.getScenarioComponentForCategory(
  categoryId,
  scenarioId,
  investmentId  // Only returns components for this investment
)
```

#### Updated Actions

**`addScenarioComponent`:**
```typescript
async addScenarioComponent(
  mainComponentId: string,
  quantity: number,
  investmentId: string,  // NEW! Required parameter
  scenarioId?: string
) {
  const targetScenarioId = scenarioId || this.activeScenarioId
  if (!targetScenarioId) return

  const supabase = useSupabaseClient()
  const component = this.mainComponents.find(c => c.id === mainComponentId)
  if (!component) return

  const { data, error } = await supabase
    .from('scenario_main_components')
    .insert({
      scenario_id: targetScenarioId,
      main_component_id: mainComponentId,
      investment_id: investmentId,  // NEW!
      quantity,
      price_snapshot: component.price
    })
    .select()
    .single()

  if (error) throw error

  // Update local state
  if (!this.scenarioComponents[targetScenarioId]) {
    this.scenarioComponents[targetScenarioId] = []
  }
  this.scenarioComponents[targetScenarioId].push(data)
}
```

### Contracts Store Updates

**Location:** `app/stores/contracts.ts`

#### Updated Interface

```typescript
export interface ContractMainComponent {
  id: string
  contract_id: string
  main_component_id: string
  investment_id: string  // NEW!
  quantity: number
  price_snapshot: number
}
```

#### Updated Methods

**`createContract`:**
```typescript
async createContract(data: {
  // ... other fields
  main_components: Array<{
    main_component_id: string
    investment_id: string  // NEW!
    quantity: number
    price_snapshot: number
  }>
  // ...
})
```

**`updateContract`:**
```typescript
async updateContract(contractId: string, data: {
  // ... other fields
  main_components?: Array<{
    main_component_id: string
    investment_id: string  // NEW!
    quantity: number
    price_snapshot: number
  }>
  // ...
})
```

---

## Cost Calculations

### Price Calculation Flow

```typescript
// 1. Main Components Cost (per investment)
const mainComponentsCost = scenarioComponents
  .filter(sc => sc.investment_id === investmentId)
  .reduce((sum, sc) => {
    return sum + (sc.quantity × sc.price_snapshot × (1 + commissionRate))
  }, 0)

// 2. Total Main Components (all investments)
const totalMainComponents = allInvestments
  .reduce((sum, inv) => sum + getMainComponentsCost(inv.id), 0)

// 3. Solar Extra Costs
const solarExtraCosts = solarCosts
  .reduce((sum, cost) => {
    return sum + (cost.quantity × cost.snapshot_price × (1 + commissionRate))
  }, 0)

// 4. General Extra Costs
const generalExtraCosts = generalCosts
  .reduce((sum, cost) => {
    return sum + (cost.quantity × cost.snapshot_price × (1 + commissionRate))
  }, 0)

// 5. Implementation Fee (before subsidies)
const implementationFee = totalMainComponents + solarExtraCosts + generalExtraCosts

// 6. Subsidies/Discounts
const totalSubsidies = enabledDiscounts
  .reduce((sum, discount) => {
    if (discount.discount_type === 'percentage') {
      return sum + (implementationFee × discount.discount_value / 100)
    } else {
      return sum + discount.discount_value
    }
  }, 0)

// 7. Subtotal (after subsidies)
const subtotal = implementationFee - totalSubsidies

// 8. VAT
const vat = subtotal × (vatRate / 100)  // e.g., 27% = 0.27

// 9. Total (Final Price)
const total = subtotal + vat
```

### Example Calculation

**Scenario:**
- Investment 1 (Solar Panel): 10 panels × 50,000 Ft = 500,000 Ft
- Investment 2 (Solar + Battery): 8 panels × 50,000 Ft = 400,000 Ft + Battery 1 × 800,000 Ft = 800,000 Ft
- Commission Rate: 12% (0.12)
- VAT: 27%
- Subsidy: 30% percentage

**Calculation:**
```
Main Components Total:
  Solar Panel:     500,000 × 1.12 = 560,000 Ft
  Solar+Battery:  1,200,000 × 1.12 = 1,344,000 Ft
  ────────────────────────────────────────────
  Total Main:                      1,904,000 Ft

Solar Extra Costs:                   100,000 Ft
General Extra Costs:                  50,000 Ft
────────────────────────────────────────────
Implementation Fee:                2,054,000 Ft

Subsidy (30%):                      -616,200 Ft
────────────────────────────────────────────
Subtotal:                          1,437,800 Ft

VAT (27%):                           388,206 Ft
────────────────────────────────────────────
TOTAL:                             1,826,006 Ft
```

---

## User Flows

### 1. Contract Creation from Scenario

1. User navigates to Offer/Contract tab
2. Selects a scenario from the buttons
3. `SurveyOfferContractTechnicalDetails` loads investments
4. Each investment shows its categories and components (filtered by `investment_id`)
5. User reviews/modifies technical details:
   - Add/remove components per investment
   - Adjust quantities
   - Configure roof (if solar)
   - Check compatibility (if solar)
6. User reviews/configures extra costs and discounts
7. User reviews contract details and prices
8. User clicks "Save Contract" or "Save Offer"
9. `collectContractData()` gathers all data including `investment_id` per component
10. `contractsStore.createContract()` creates contract with proper investment tracking
11. Success message displayed

### 2. Adding Component to Investment

1. User expands investment accordion in Technical Details
2. User scrolls to desired category
3. User clicks "Add Component" button
4. System checks existing components for this investment-category pair
5. System finds first available component not yet added
6. System calls `addScenarioComponent(componentId, 1, investmentId)`
7. Database insert with `investment_id` field
8. Local state updated
9. Component appears in UI for that specific investment only

### 3. Component Filtering by Investment

**Before Fix (Bug):**
```typescript
// ❌ Problem: Components filtered only by category
getCategoryComponents(categoryId)
  → Returns ALL components for this category across ALL investments
  → Solar Panel shows: Solar Panel's panels + Solar+Battery's panels
```

**After Fix:**
```typescript
// ✅ Solution: Components filtered by category AND investment
getCategoryComponents(categoryId)
  → scenariosStore.getScenarioComponentForCategory(categoryId, scenarioId, investmentId)
  → Returns ONLY components for this specific investment
  → Solar Panel shows: Solar Panel's panels only
  → Solar+Battery shows: Solar+Battery's panels only
```

---

## Investment-Specific Component Tracking

### Problem Statement

When a scenario contains multiple investments (e.g., "Solar Panel" and "Solar Panel + Battery"), and both require the same component category (e.g., "panels"), the system needs to:

1. ✅ Allow the same component to be selected for both investments
2. ✅ Track quantity separately per investment
3. ✅ Display components only in their respective investment sections
4. ✅ Prevent unique constraint violations in the database

### Solution Architecture

#### Database Level

**Old Schema (Before Migration 070):**
```sql
-- ❌ Constraint: UNIQUE(scenario_id, main_component_id)
-- Problem: Can't add same component twice even for different investments
```

**New Schema (After Migration 070):**
```sql
-- ✅ Constraint: UNIQUE(scenario_id, main_component_id, investment_id)
-- Solution: Same component allowed for different investments
```

#### Application Level

**1. Component Creation (useScenarioCreation.ts):**
```typescript
// For each investment, create components with investment_id
for (const investment of investments) {
  const baseQuantities = getBaseQuantities(investment.name)

  for (const category of investmentCategories) {
    const selectedComponent = selectComponentByQuality(...)

    componentsToInsert.push({
      scenario_id: scenarioId,
      main_component_id: selectedComponent.id,
      investment_id: investment.id,  // ← Critical field!
      quantity: calculateQuantity(...),
      price_snapshot: selectedComponent.price
    })
  }
}
```

**2. Component Filtering (scenarios.ts store):**
```typescript
getScenarioComponentForCategory: (state) => (
  categoryId: string,
  scenarioId?: string,
  investmentId?: string  // ← Optional filter
) => {
  const scenarioComponents = state.scenarioComponents[targetScenarioId] || []

  return scenarioComponents.filter(sc => {
    const component = state.mainComponents.find(mc => mc.id === sc.main_component_id)
    const categoryMatch = component?.main_component_category_id === categoryId
    const investmentMatch = investmentId ? sc.investment_id === investmentId : true
    return categoryMatch && investmentMatch  // ← Both conditions!
  })
}
```

**3. Component Display (SurveyOfferContractCategories.vue):**
```typescript
// Always pass investmentId to filter components
const getCategoryComponents = (categoryId: string) => {
  return scenariosStore.getScenarioComponentForCategory(
    categoryId,
    props.scenarioId,
    props.investmentId  // ← Must be passed!
  )
}
```

### Data Flow Example

**Scenario:** "Solar Panel" + "Solar Panel + Battery"

**Database Records:**
```sql
scenario_main_components:
  id  | scenario_id | main_component_id | investment_id          | quantity
  ────┼─────────────┼───────────────────┼────────────────────────┼─────────
  1   | scenario-1  | panel-500w        | investment-solar       | 10
  2   | scenario-1  | inverter-5kw      | investment-solar       | 1
  3   | scenario-1  | panel-500w        | investment-solar-bat   | 8
  4   | scenario-1  | inverter-5kw      | investment-solar-bat   | 1
  5   | scenario-1  | battery-10kwh     | investment-solar-bat   | 1
```

**UI Display:**

```
Solar Panel Accordion:
  ├─ Solar Panels
  │  └─ Panel 500W: 10 pcs  ← Row ID 1
  └─ Inverters
     └─ Inverter 5kW: 1 pcs ← Row ID 2

Solar Panel + Battery Accordion:
  ├─ Solar Panels
  │  └─ Panel 500W: 8 pcs   ← Row ID 3 (different from row 1!)
  ├─ Inverters
  │  └─ Inverter 5kW: 1 pcs ← Row ID 4 (different from row 2!)
  └─ Batteries
     └─ Battery 10kWh: 1 pcs ← Row ID 5
```

**Key Points:**
- ✅ Same component (Panel 500W) appears in both investments
- ✅ Each has separate database row with different `investment_id`
- ✅ Quantities tracked independently (10 vs 8)
- ✅ Each investment section shows only its own components
- ✅ No duplicate constraint violations

---

## Technical Implementation

### Provide/Inject Pattern

The Offer/Contract page uses Vue's `provide/inject` pattern for data communication between parent and child components.

**Parent Component (SurveyOfferContract.vue):**
```typescript
// Data storage refs
const solarExtraCostsData = ref<any[]>([])
const generalExtraCostsData = ref<any[]>([])
const discountsData = ref<any[]>([])
const roofConfigurationData = ref<any>([])
const vatData = ref(27)
const totalPriceData = ref(0)

// Provide update functions to children
provide('updateSolarExtraCostsData', (data: any[]) => {
  solarExtraCostsData.value = data
})

provide('updateGeneralExtraCostsData', (data: any[]) => {
  generalExtraCostsData.value = data
})

provide('updateDiscountsData', (data: any[]) => {
  discountsData.value = data
})

provide('updateRoofConfigurationData', (data: any) => {
  roofConfigurationData.value = data
})

provide('updateVatData', (vat: number) => {
  vatData.value = vat
})

provide('updateTotalPriceData', (total: number) => {
  totalPriceData.value = total
})
```

**Child Components:**
```typescript
// Inject update function
const updateSolarExtraCostsData = inject<(data: any[]) => void>('updateSolarExtraCostsData')

// Send data to parent
watch(() => selectedCosts.value, () => {
  updateSolarExtraCostsData?.(selectedCosts.value)
}, { deep: true })
```

### Contract Data Collection

```typescript
const collectContractData = () => {
  if (!selectedScenarioId.value) {
    throw new Error('No scenario selected')
  }

  const scenarioComponents = scenariosStore.scenarioComponents[selectedScenarioId.value] || []
  const investments = scenarioInvestments.value[selectedScenarioId.value] || []

  return {
    scenario_id: selectedScenarioId.value,
    survey_id: props.surveyId,
    contract_mode: props.contractMode || 'offer',
    commission_rate: commissionRate.value,
    vat: vatData.value,
    total_price: totalPriceData.value,
    roof_configuration: roofConfigurationData.value,
    notes: '',

    // Main components with investment_id
    main_components: scenarioComponents.map(sc => {
      const mainComponent = scenariosStore.getMainComponentById(sc.main_component_id)
      return {
        main_component_id: sc.main_component_id,
        investment_id: sc.investment_id,  // ← Critical field!
        quantity: sc.quantity,
        price_snapshot: mainComponent?.price || sc.price_snapshot
      }
    }),

    investments,
    solar_extra_costs: solarExtraCostsData.value,
    general_extra_costs: generalExtraCostsData.value,
    discounts: discountsData.value
  }
}
```

### Loading Contract Data

When loading an existing contract, the component must reconstruct the scenario selection and all configurations:

```typescript
watch(() => contractsStore.activeContractId, async (contractId) => {
  if (!contractId) return

  const contract = contractsStore.activeContract
  if (!contract) return

  // Set scenario from contract
  if (contract.scenario_id) {
    selectedScenarioId.value = contract.scenario_id
  }

  // Set commission rate
  commissionRate.value = contract.commission_rate

  // Set VAT
  vatData.value = contract.vat

  // Set total price
  totalPriceData.value = contract.total_price

  // Set roof configuration
  if (contract.roof_configuration) {
    roofConfigurationData.value = contract.roof_configuration
  }

  // Load extra costs and separate by type
  const contractExtraCosts = contractsStore.activeContractExtraCosts
  // ... complex logic to separate solar vs general costs

  // Load discounts
  const contractDiscounts = contractsStore.activeContractDiscounts
  discountsData.value = contractDiscounts.map(cd => ({
    discount_id: cd.discount_id,
    discount_snapshot: cd.discount_snapshot,
    is_enabled: true
  }))
})
```

---

## Testing Checklist

### Component Management
- [ ] Add component to Solar Panel investment
- [ ] Add same component to Solar Panel + Battery investment
- [ ] Verify each investment shows only its components
- [ ] Delete component from one investment (doesn't affect other)
- [ ] Modify quantity in one investment (doesn't affect other)
- [ ] Change component selection in one investment (doesn't affect other)

### Investment Filtering
- [ ] Create scenario with multiple investments
- [ ] Verify no duplicate components across investment sections
- [ ] Verify component filtering by `investment_id`
- [ ] Test with overlapping component categories
- [ ] Test with same component in different investments

### Contract Creation
- [ ] Select scenario with multiple investments
- [ ] Review technical details per investment
- [ ] Configure roof (if solar scenario)
- [ ] Check compatibility (if solar scenario)
- [ ] Add/remove extra costs
- [ ] Add/remove discounts
- [ ] Verify price calculations
- [ ] Save contract successfully
- [ ] Verify contract data includes `investment_id`

### Contract Loading
- [ ] Load existing contract
- [ ] Verify scenario selected correctly
- [ ] Verify all components loaded with correct investments
- [ ] Verify extra costs separated correctly
- [ ] Verify discounts loaded
- [ ] Verify prices calculated correctly

### UI/UX
- [ ] Investment accordions expand/collapse smoothly
- [ ] Category headers display correctly
- [ ] Component dropdowns populate correctly
- [ ] Quantity inputs work properly
- [ ] Delete buttons confirm before action
- [ ] Loading states display during operations
- [ ] Error messages display on failures

---

## Troubleshooting

### Common Issues

**Issue:** Duplicate key constraint violation when creating contract
- **Symptom:** Error 409 with message about unique constraint violation
- **Root Cause:** `investment_id` missing from component data
- **Solution:** Verify `collectContractData()` includes `investment_id` in main_components array

**Issue:** Components appear in wrong investment sections
- **Symptom:** Solar Panel shows components from Solar+Battery
- **Root Cause:** `investmentId` parameter not passed to store getter
- **Solution:** Ensure `getCategoryComponents()` passes `props.investmentId`

**Issue:** Same component can't be added to multiple investments
- **Symptom:** "Component already exists" error or silent failure
- **Root Cause:** Old unique constraint without `investment_id`
- **Solution:** Run migration 070 to update database schema

**Issue:** Contract creation fails silently
- **Symptom:** No error shown but contract not created
- **Root Cause:** Missing required fields in contract data
- **Solution:** Check browser console for detailed error, verify all required fields

### Migration Issues

**Issue:** Migration 070 fails to apply
- **Error:** Column already exists or constraint already exists
- **Solution:** Check if migration was partially applied, manually fix inconsistencies

**Issue:** Existing data incompatible after migration
- **Problem:** Old scenario_main_components lack `investment_id`
- **Solution:** Run data migration to populate `investment_id` from scenario_investments

---

## Future Enhancements

### Planned Features

1. **Component Templates**
   - Save common component configurations
   - Quick apply to new scenarios
   - Investment-specific templates

2. **Bulk Component Operations**
   - Copy all components from one investment to another
   - Apply quantity multiplier to all components
   - Bulk delete/update

3. **Advanced Price Calculations**
   - Discount rules engine
   - Tiered pricing based on quantity
   - Seasonal pricing adjustments

4. **Contract Versioning**
   - Track contract modifications
   - Compare versions side-by-side
   - Restore previous versions

5. **PDF Generation**
   - Professional contract PDF export
   - Customizable templates
   - Digital signatures

6. **Validation Engine**
   - Required components per investment
   - Minimum/maximum quantity rules
   - Compatibility checks automated

---

## Related Documentation

- [Survey System Architecture](./survey-system-architecture.md) - Overall system architecture
- [Consultation Page](./survey-consultation-page.md) - Consultation page details
- [Database Schema](./survey-system-architecture.md#database-schema) - Complete schema documentation
- [State Management](./survey-consultation-page.md#state-management) - Store patterns and usage

---

**Document Maintainers:** Development Team
**Last Review:** 2025-10-24
**Next Review:** 2025-11-24
