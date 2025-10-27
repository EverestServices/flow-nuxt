# Consultation Page Documentation

## Overview

A Consultation oldal a survey folyamat második fázisa, ahol az energetikai rendszer tervezése és ajánlatkészítés történik. Az oldal három fő részből áll: System Design, System Visualization és Consultation panel.

---

## Recent Updates

### 2025-10-22: Contract Details, Commission System & UI Enhancements

**Major Features Added:**

1. **Contract Details - Costs Breakdown (`ContractDetailsCosts.vue`)**
   - Teljes költségbontás megjelenítése MainComponents, ExtraCosts, Subsidies-zel
   - Kategóriánként csoportosított komponensek magyar nyelvű kategória nevekkel
   - Implementation Fee és Total kalkulációk commission rate figyelembevételével
   - Reactive updates commission rate vagy scenario változáskor

2. **Commission Rate System**
   - 4 szintű jutalék rendszer: Red (12%), Yellow (8%), Green (4%), Black (0%)
   - Interactive price display: kattintható, színes aláhúzással (2px border)
   - Price click cycling: automatikus váltás a commission szintek között
   - Direct selection: színes gombok a közvetlen beállításhoz
   - Database persistence: commission_rate mentése scenarios táblában
   - Migration 058: `commission_rate` oszlop hozzáadása

3. **Independent Investments Removal**
   - Teljes funkció eltávolítva (Scenarios-only mode)
   - UI toggle gomb eltávolítva a SurveyHeader-ből
   - "Container 1" section eltávolítva
   - Minden `consultationViewMode` referencia tisztítva
   - Migration 059: `consultation_view_mode` oszlop törlése surveys táblából

4. **UI/UX Enhancements**
   - **Scenario Button Scrolling:** Vízszintes scrollozás a header-ben (`overflow-x-auto flex-1`)
   - **Footer Eye Toggle:** Scenario action buttons láthatóságának vezérlése eye/eye-off ikonnal
   - **Auto-select After Deletion:** Első scenario automatikus kiválasztása törlés után
   - **Manual Scenario Creation:** "New Scenario" gomb üres scenariot hoz létre (no MainComponents)

**Bug Fixes:**

1. **Category Names "Other" Issue**
   - Root cause: `main_component_categories` tábla nem tartalmaz `name` mezőt
   - Fix: Query módosítva `.select('id, persist_name')` használatára
   - Category translations hozzáadva magyar névvel

2. **Subsidies Price Column Error**
   - Root cause: `subsidies` tábla nem tartalmaz `price` mezőt
   - Fix: `discount_type` és `discount_value` alapú kalkuláció implementálva
   - Percentage és fixed típusok külön kezelése

**Database Changes:**
- Migration 058: `scenarios.commission_rate DECIMAL(5,4) DEFAULT 0.12`
- Migration 059: `surveys.consultation_view_mode` DROP COLUMN

**Files Modified:**
- `app/components/Survey/ContractDetailsCosts.vue` (NEW)
- `app/components/Survey/FinancingModal.vue`
- `app/components/Survey/SurveyConsultation.vue`
- `app/components/Survey/SurveyHeader.vue`
- `app/components/Survey/SurveyFooter.vue`
- `app/pages/survey/[surveyId].vue`
- `supabase/migrations/058_add_commission_rate_to_scenarios.sql` (NEW)
- `supabase/migrations/059_remove_consultation_view_mode.sql` (NEW)

---

## Architecture

### Main Components

#### 1. `SurveyConsultation.vue`

**Location:** `app/components/Survey/SurveyConsultation.vue`

**Purpose:** A Consultation oldal fő komponense, amely három oszlopot kezel:
- System Design (bal oldal, összecsukható)
- System Visualization (közép)
- Consultation (jobb oldal, összecsukható)

**Props:**
- `surveyId: string` - A survey azonosítója
- `systemDesignOpen: boolean` - System Design panel állapota
- `consultationOpen: boolean` - Consultation panel állapota

**Events:**
- `update:system-design-open` - System Design panel toggle
- `update:consultation-open` - Consultation panel toggle
- `ai-scenarios` - AI scenarios létrehozás trigger
- `new-scenario` - Új scenario létrehozás trigger

**Features:**
- Collapsible side panels with smooth transitions
- Scenarios kezelés (Independent Investments funkció eltávolítva)
- AI Scenarios és New Scenario gombok a System Design panelben
- State persistence az adatbázisban (panel állapotok mentése)
- Contract Details accordion commission rate kezeléssel

---

#### 2. `SurveyScenarioInvestments.vue`

**Location:** `app/components/Survey/SurveyScenarioInvestments.vue`

**Purpose:** Megjeleníti az aktív scenario-hoz tartozó befektetéseket (investments) accordion formában.

**Props:**
- `surveyId: string` - Survey azonosító
- `scenarioId: string` - Scenario azonosító

**Features:**
- Investment accordionok dinamikus betöltése
- Befektetés típusok szerinti ikonok
- Technikai adatok (main components) megjelenítése kategóriánként

**Data Flow:**
```
scenariosStore.scenarioInvestments[scenarioId]
  → investment IDs
  → investmentsStore.availableInvestments
  → full investment details
```

---

#### 3. `SurveyScenarioCategories.vue`

**Location:** `app/components/Survey/SurveyScenarioCategories.vue`

**Purpose:** Main component kategóriák és komponensek kezelése egy adott befektetéshez.

**Props:**
- `scenarioId: string` - Scenario azonosító
- `investmentId: string` - Befektetés azonosító

**Features:**
- **Add Component:** Új komponens hozzáadása kategóriához
  - Automatikusan kiválasztja a következő elérhető komponenst
  - Megakadályozza a duplikációkat
  - Loading state kezelés
- **Component Selection:** Dropdown lista a komponensek közötti váltáshoz
- **Quantity Management:** Mennyiség szerkesztése
- **Delete:** Komponens eltávolítása

**Implementation Details:**

```typescript
// Duplikátum megelőzés
const existingComponentIds = getCategoryComponents(categoryId)
  .map(c => c.main_component_id)

const availableComponent = components
  .find(c => !existingComponentIds.includes(c.value))
```

---

#### 4. `UISelect.vue`

**Location:** `app/components/UI/Select.vue`

**Purpose:** Egyedi HTML select komponens natív `<select>` és `<option>` elemekkel.

**Props:**
- `modelValue: string | number | null | undefined` - Aktuális érték
- `options: any[]` - Opciók listája
- `valueAttribute?: string` - Value mező neve (default: 'value')
- `labelAttribute?: string` - Label mező neve (default: 'label')
- `disabled?: boolean` - Letiltott állapot
- `size?: 'sm' | 'md' | 'lg'` - Méret

**Usage:**
```vue
<UISelect
  v-model="selectedId"
  :options="[
    { value: '1', label: 'Option 1' },
    { value: '2', label: 'Option 2' }
  ]"
  value-attribute="value"
  label-attribute="label"
  size="sm"
/>
```

---

#### 5. `ContractDetailsCosts.vue`

**Location:** `app/components/Survey/ContractDetailsCosts.vue`

**Purpose:** Megjeleníti a scenario teljes költségbontását commission rate figyelembevételével.

**Props:**
- `surveyId: string` - Survey azonosító
- `scenarioId: string | null` - Scenario azonosító (lehet null)
- `commissionRate: number` - Jutalék mértéke (0-1 közötti érték, pl. 0.12 = 12%)

**Features:**
- **MainComponents megjelenítés** - Kategóriánként csoportosítva
  - Kategória név megjelenítése (magyar fordítással)
  - Komponens név és total költség (quantity × price_snapshot × (1 + commission))
  - Üres állapot kezelése ("No components added")
- **ExtraCosts összesítés** - "Járulékos költségek" sorban
- **Implementation Fee** - MainComponents + ExtraCosts összesen (nagyobb betűméret)
- **Subsidies** - Egyenként listázva zöld színnel, mínusz előjellel
  - Percentage típus: Implementation Fee × discount_value / 100
  - Fixed típus: discount_value érték
- **Total (Összesen)** - Implementation Fee - Subsidies (legnagyobb, bold)

**Data Loading:**
```typescript
// MainComponents betöltése kategória információkkal
const { data: componentsData } = await supabase
  .from('scenario_main_components')
  .select(`
    id,
    quantity,
    price_snapshot,
    main_component:main_components (
      id,
      name,
      main_component_category_id
    )
  `)
  .eq('scenario_id', props.scenarioId)

// Kategóriák betöltése és fordítása
const { data: categoriesData } = await supabase
  .from('main_component_categories')
  .select('id, persist_name')
  .in('id', categoryIds)

// Category translations
const categoryTranslations: Record<string, string> = {
  'solar_panels': 'Napelemek',
  'inverters': 'Inverterek',
  'batteries': 'Akkumulátorok',
  'mounting_systems': 'Rögzítőrendszerek',
  'insulation': 'Szigetelés',
  'adhesive': 'Ragasztó',
  'plaster': 'Vakolat',
  'heat_pumps': 'Hőszivattyúk',
  'water_heaters': 'Vízmelegítők',
  'ventilation': 'Szellőztetés',
  'other': 'Egyéb'
}
```

**Cost Calculations:**
```typescript
// MainComponent cost with commission
const mainComponentCost = quantity * price_snapshot * (1 + commissionRate)

// ExtraCost with commission
const extraCostTotal = extraCostsData.reduce((sum, item) => {
  return sum + (item.quantity * item.snapshot_price * (1 + commissionRate))
}, 0)

// Implementation Fee
const implementationFee = mainTotal + extraCostTotal

// Subsidy calculation
if (subsidy.discount_type === 'percentage') {
  calculatedPrice = implementationFee * subsidy.discount_value / 100
} else if (subsidy.discount_type === 'fixed') {
  calculatedPrice = subsidy.discount_value
}

// Total
const total = implementationFee - subsidyTotal
```

**Reactive Updates:**
- Watch-ol a `scenarioId` és `commissionRate` változásokat
- Automatikus újratöltés prop változás esetén
- Loading state kezelés

---

#### 6. `FinancingModal.vue`

**Location:** `app/components/Survey/FinancingModal.vue`

**Purpose:** Contract Details megjelenítése commission rate kezeléssel.

**Commission System:**

```typescript
const COMMISSION_RATES = {
  red: 0.12,    // 12% - Highest
  yellow: 0.08, // 8%
  green: 0.04,  // 4%
  black: 0      // 0% - No commission
}

const COMMISSION_COLORS = ['red', 'yellow', 'green', 'black'] as const
```

**Features:**

**1. Interactive Price Display:**
- Total price megjelenítés színes aláhúzással (2px border)
- Kattintható - cycle through commission levels
- Border színe a selected commission alapján

```typescript
const handlePriceClick = async () => {
  const currentIndex = COMMISSION_COLORS.indexOf(commissionColor.value)
  const nextIndex = (currentIndex + 1) % COMMISSION_COLORS.length
  commissionColor.value = COMMISSION_COLORS[nextIndex]
  await calculateTotalPrice()
}

const priceUnderlineColor = computed(() => {
  const colors = {
    red: 'border-red-500',
    yellow: 'border-yellow-500',
    green: 'border-green-500',
    black: 'border-black dark:border-gray-900'
  }
  return colors[commissionColor.value]
})
```

**2. Commission Rate Buttons:**
- 4 színes gomb (red, yellow, green, black)
- Ring effect az aktív gombon
- Direct commission rate beállítás

```typescript
const handleCommissionChange = async (color: 'red' | 'yellow' | 'green' | 'black') => {
  commissionColor.value = color
  await calculateTotalPrice()
}
```

**3. Database Persistence:**
- Commission rate mentése a scenarios táblában
- Automatikus betöltés scenario váltáskor

```typescript
// Save to database
await supabase
  .from('scenarios')
  .update({ commission_rate: COMMISSION_RATES[commissionColor.value] })
  .eq('id', props.scenarioId)

// Load on scenario change
watch(() => props.scenarioId, async () => {
  const { data: scenario } = await supabase
    .from('scenarios')
    .select('commission_rate')
    .eq('id', props.scenarioId)
    .single()

  // Set commission color based on rate
  const rate = scenario?.commission_rate || 0.12
  commissionColor.value = Object.entries(COMMISSION_RATES)
    .find(([_, value]) => value === rate)?.[0] as CommissionColor || 'red'
})
```

---

## State Management

### Scenarios Store (`app/stores/scenarios.ts`)

**Purpose:** Centralizált state management a scenarios, investments, és main components kezelésére.

#### State Structure

```typescript
{
  scenarios: Scenario[]                          // Összes scenario
  activeScenarioId: string | null                // Aktív scenario ID
  scenarioInvestments: Record<string, string[]>  // scenarioId → investmentIds
  scenarioComponents: Record<string, ScenarioMainComponent[]> // scenarioId → components
  mainComponents: MainComponent[]                // Elérhető komponensek
  mainComponentCategories: MainComponentCategory[] // Kategóriák
  categoryInvestments: Record<string, string[]>  // categoryId → investmentIds
  loading: boolean
}
```

#### Key Actions

**`loadScenarios(surveyId: string)`**
- Betölti a survey-hoz tartozó összes scenariot
- Betölti a scenario investments kapcsolatokat
- Betölti a scenario main components-eket
- Beállítja az első scenariot aktívként

**`addScenarioComponent(mainComponentId: string, quantity: number)`**
- Új komponens hozzáadása az aktív scenariohoz
- Price snapshot mentése
- Lokális state frissítése

**`updateScenarioComponent(componentId: string, mainComponentId: string, quantity?: number)`**
- Meglévő scenario component módosítása
- Új price snapshot beállítása

**`updateComponentQuantity(componentId: string, quantity: number)`**
- Komponens mennyiségének frissítése

**`removeScenarioComponent(componentId: string)`**
- Scenario component törlése

#### Getters

**`getComponentsByCategoryId(categoryId: string)`**
- Visszaadja az adott kategóriához tartozó main components-eket

**`getCategoriesForInvestment(investmentId: string)`**
- Visszaadja az adott befektetéshez tartozó kategóriákat

**`getScenarioComponentForCategory(categoryId: string)`**
- Visszaadja az aktív scenario-hoz tartozó komponenseket egy kategóriában

---

## Composables

### `useScenarioCreation.ts`

**Location:** `app/composables/useScenarioCreation.ts`

**Purpose:** AI scenarios létrehozása a kiválasztott befektetések alapján.

#### Main Function: `createAIScenarios`

**Parameters:**
- `surveyId: string` - Survey azonosító
- `selectedInvestmentIds: string[]` - Kiválasztott befektetések

**Process:**
1. 3 scenario típus létrehozása (Optimum, Minimum, Premium)
2. Scenario-investment kapcsolatok létrehozása
3. Main components automatikus kiválasztása minden scenariohoz
4. Mennyiségek kalkulálása scenario típus alapján

**Return:**
```typescript
{
  success: boolean
  scenarios?: Scenario[]
  error?: string
}
```

#### Component Selection Logic

```typescript
selectComponentByQuality(
  components: MainComponent[],
  qualityLevel: 'high' | 'medium' | 'low',
  preferredBrands?: string[]
)
```

- **High:** Első komponens (legmagasabb minőség/ár)
- **Medium:** Középső komponens
- **Low:** Utolsó komponens (legalacsonyabb ár)
- Preferred brands figyelembevétele

---

## Utilities

### `scenarioGenerator.ts`

**Location:** `app/utils/scenarioGenerator.ts`

**Purpose:** Scenario típusok, konfigurációk és mennyiség kalkulációk.

#### Scenario Types

```typescript
type ScenarioType = 'optimum' | 'minimum' | 'premium'
```

#### Scenario Configurations

```typescript
{
  optimum: {
    qualityLevel: 'medium',
    quantityMultiplier: 1.0,
    preferredBrands: []
  },
  minimum: {
    qualityLevel: 'low',
    quantityMultiplier: 0.8,
    preferredBrands: []
  },
  premium: {
    qualityLevel: 'high',
    quantityMultiplier: 1.2,
    preferredBrands: ['Huawei', 'Fronius', 'SMA']
  }
}
```

#### Base Quantities per Investment

Példa Solar Panel befektetéshez:
```typescript
{
  panel: { value: 10, unit: 'pcs' },
  inverter: { value: 1, unit: 'pcs' },
  mounting: { value: 1, unit: 'set' },
  // ...
}
```

---

## Database Schema

### Tables

#### `scenarios`
```sql
- id: uuid
- survey_id: uuid (FK → surveys)
- name: text
- sequence: integer
- description: text
- commission_rate: decimal(5,4) DEFAULT 0.12  -- Commission rate for pricing (0-1)
- created_at: timestamp
- updated_at: timestamp
```

#### `scenario_investments`
```sql
- scenario_id: uuid (FK → scenarios)
- investment_id: uuid (FK → investments)
- PRIMARY KEY (scenario_id, investment_id)
```

#### `scenario_main_components`
```sql
- id: uuid
- scenario_id: uuid (FK → scenarios)
- main_component_id: uuid (FK → main_components)
- quantity: integer
- price_snapshot: numeric
- UNIQUE (scenario_id, main_component_id)
```

#### `main_components`
```sql
- id: uuid
- name: text
- persist_name: text
- unit: text
- price: numeric
- main_component_category_id: uuid (FK)
- manufacturer: text
- details: text
- power: numeric
- capacity: numeric
- efficiency: numeric
- u_value: numeric
- thickness: numeric
- cop: numeric
- energy_class: text
- sequence: integer
```

#### `main_component_categories`
```sql
- id: uuid
- persist_name: text
- sequence: integer
```

#### `main_component_category_investments`
```sql
- main_component_category_id: uuid (FK)
- investment_id: uuid (FK)
- sequence: integer
- PRIMARY KEY (main_component_category_id, investment_id)
```

---

## Cost Calculations

### Overview

A költségkalkulációk központi szerepet töltenek be a Consultation oldalon. Minden ár a következő összetevőkből áll:
- **Base Price (price_snapshot):** Komponens eredeti ára
- **Commission Rate:** Jutalék mértéke (0-12%)
- **Quantity:** Mennyiség
- **Subsidies:** Támogatások (percentage vagy fixed)

### Formulas

#### MainComponent Total Cost
```typescript
componentTotalCost = quantity × price_snapshot × (1 + commission_rate)
```

**Példa:**
- Quantity: 10 pcs
- Price Snapshot: 50,000 HUF
- Commission Rate: 12% (0.12)
- **Total:** 10 × 50,000 × 1.12 = 560,000 HUF

#### ExtraCost Total
```typescript
extraCostTotal = Σ (quantity × snapshot_price × (1 + commission_rate))
```

**Példa:**
- Item 1: 5 × 10,000 × 1.12 = 56,000 HUF
- Item 2: 2 × 25,000 × 1.12 = 56,000 HUF
- **Total:** 112,000 HUF

#### Implementation Fee
```typescript
implementationFee = Σ mainComponentTotalCosts + extraCostTotal
```

**Példa:**
- MainComponents Total: 2,450,000 HUF
- ExtraCosts Total: 112,000 HUF
- **Implementation Fee:** 2,562,000 HUF

#### Subsidy Calculation

**Percentage Type:**
```typescript
subsidyAmount = implementationFee × (discount_value / 100)
```

**Példa:**
- Implementation Fee: 2,562,000 HUF
- Discount: 30%
- **Subsidy:** 2,562,000 × 0.30 = 768,600 HUF

**Fixed Type:**
```typescript
subsidyAmount = discount_value
```

**Példa:**
- Discount Value: 500,000 HUF
- **Subsidy:** 500,000 HUF

#### Total (Final Price)
```typescript
total = implementationFee - Σ subsidyAmounts
```

**Példa:**
- Implementation Fee: 2,562,000 HUF
- Subsidy 1 (30%): -768,600 HUF
- Subsidy 2 (Fixed): -500,000 HUF
- **Total:** 1,293,400 HUF

### Commission Rate Impact

A commission rate változtatása minden komponens árát befolyásolja:

| Commission Level | Rate | Példa (Base: 100,000 HUF) | Multiplier |
|------------------|------|---------------------------|------------|
| Red              | 12%  | 112,000 HUF               | 1.12       |
| Yellow           | 8%   | 108,000 HUF               | 1.08       |
| Green            | 4%   | 104,000 HUF               | 1.04       |
| Black            | 0%   | 100,000 HUF               | 1.00       |

**Implementation Fee változása:**
```typescript
// 10 komponens, mindegyik 100,000 HUF base árral

Red (12%):    10 × 100,000 × 1.12 = 1,120,000 HUF  (+120,000)
Yellow (8%):  10 × 100,000 × 1.08 = 1,080,000 HUF  (+80,000)
Green (4%):   10 × 100,000 × 1.04 = 1,040,000 HUF  (+40,000)
Black (0%):   10 × 100,000 × 1.00 = 1,000,000 HUF  (base)
```

### Price Snapshot

A `price_snapshot` mező biztosítja, hogy a komponensek árai ne változzanak meg az eredeti Main Component ár frissítése esetén:

```typescript
// Component hozzáadásakor
const mainComponent = await getMainComponent(mainComponentId)
await createScenarioComponent({
  main_component_id: mainComponentId,
  quantity: 10,
  price_snapshot: mainComponent.price  // Jelenlegi ár rögzítése
})

// Későbbi árkeresésnél
const cost = quantity × price_snapshot × (1 + commission_rate)
// NEM: quantity × mainComponent.current_price × (1 + commission_rate)
```

**Előny:** Garantálja az árfolyam stabilitást a scenario létrehozása után.

---

## User Flows

### 1. AI Scenarios létrehozása

1. Felhasználó a "AI Scenarios" gombra kattint
2. Modal megnyílik a befektetések kiválasztásával
3. Felhasználó kiválasztja a befektetéseket
4. `useScenarioCreation.createAIScenarios()` meghívása
5. 3 scenario létrehozása (Optimum, Minimum, Premium)
6. Automatikus komponens kiválasztás és mennyiség kalkuláció
7. Scenarios lista frissítése
8. Első scenario beállítása aktívként

### 2. Scenario megtekintése és szerkesztése

1. Felhasználó kiválaszt egy scenariot a headerben
2. `scenariosStore.setActiveScenario(scenarioId)` meghívása
3. System Design panel megjeleníti a scenario befektetéseit
4. Minden befektetés accordionban megjelenik
5. Kategóriánként láthatók a komponensek

### 3. Komponens hozzáadása

1. Felhasználó az "Add Component" gombra kattint
2. Rendszer ellenőrzi az elérhető komponenseket
3. Kiválasztja az első olyan komponenst, ami még nincs hozzáadva
4. `scenariosStore.addScenarioComponent()` hívás
5. Adatbázisba mentés
6. Lokális state frissítése
7. UI automatikusan frissül

### 4. Komponens módosítása

1. Felhasználó kiválaszt egy másik komponenst a dropdown-ból
2. `handleComponentChange()` meghívása
3. `scenariosStore.updateScenarioComponent()` hívás
4. Új price snapshot mentése
5. Lokális és remote state szinkronizálása

### 5. Commission Rate módosítása

**Method 1: Price Click Cycling**
1. Felhasználó a "Contract Details" modalt megnyitja
2. Total price-ra kattint
3. Commission rate automatikusan vált a következő szintre (red → yellow → green → black → red)
4. Összes ár újraszámítódik
5. Új commission rate mentésre kerül az adatbázisban

**Method 2: Direct Button Selection**
1. Felhasználó a "Contract Details" modalt megnyitja
2. Egyik színes gombot kiválasztja (red/yellow/green/black)
3. Commission rate azonnal beállítódik
4. Összes ár újraszámítódik
5. Gomb ring effect mutatja az aktív szintet
6. Új commission rate mentésre kerül az adatbázisban

**Data Flow:**
```typescript
// 1. User clicks price or button
handleCommissionChange('yellow')

// 2. Update local state
commissionColor.value = 'yellow'
const newRate = COMMISSION_RATES['yellow'] // 0.08

// 3. Recalculate all costs
const newTotal = implementationFee * (1 + newRate)

// 4. Save to database
await supabase
  .from('scenarios')
  .update({ commission_rate: newRate })
  .eq('id', scenarioId)

// 5. ContractDetailsCosts watches commissionRate prop
// Automatically recalculates all component costs
```

**Visual Feedback:**
- Price border színe változik (red/yellow/green/black)
- Aktív gomb ring-4 effekttel kiemelődik
- Összes ár real-time frissül

### 6. Scenario törlése és automatikus váltás

1. Felhasználó a "Delete" gombra kattint
2. Confirmation dialog megjelenik
3. Felhasználó megerősíti a törlést
4. Scenario törlése az adatbázisból
5. Scenarios lista újratöltése
6. **Automatikus logic:** Ha maradtak scenarios:
   - Első scenario ID lekérése: `scenarios[0].id`
   - `scenariosStore.setActiveScenario(scenarios[0].id)` hívás
   - UI frissül az új aktív scenariohoz
7. Ha nem maradtak scenarios: üres állapot

**Code:**
```typescript
await supabase.from('scenarios').delete().eq('id', activeScenario.id)
await scenariosStore.loadScenarios(surveyId)

if (scenarios.value.length > 0) {
  scenariosStore.setActiveScenario(scenarios.value[0].id)
}
```

---

## State Persistence

### Panel States

A panel állapotok (nyitva/zárva) perzisztensen mentésre kerülnek a `surveys` táblában:

```typescript
{
  consultation_system_design_open: boolean
  consultation_panel_open: boolean
}
```

**Note:** A `consultation_view_mode` mező el lett távolítva (migration 059), mivel az Independent Investments funkció megszűnt.

**Load:**
```typescript
onMounted(async () => {
  const { data: survey } = await supabase
    .from('surveys')
    .select('*')
    .eq('id', surveyId)
    .single()

  consultationSystemDesignOpen.value = survey.consultation_system_design_open
  consultationPanelOpen.value = survey.consultation_panel_open
})
```

**Save:**
```typescript
const handleConsultationPanelToggle = async (panelName, isOpen) => {
  await supabase
    .from('surveys')
    .update({ consultation_system_design_open: isOpen })
    .eq('id', surveyId)
}
```

### Scenario Commission Rates

A commission rate minden scenariohoz külön mentésre kerül:

```typescript
// Save commission rate
await supabase
  .from('scenarios')
  .update({ commission_rate: 0.12 })
  .eq('id', scenarioId)

// Load commission rate
const { data: scenario } = await supabase
  .from('scenarios')
  .select('commission_rate')
  .eq('id', scenarioId)
  .single()
```

---

## UI Features & Enhancements

### Scenario Button Scrolling (SurveyHeader)

**Feature:** Vízszintes scrollozás a scenario gombok között.

**Implementation:**
```vue
<div class="flex gap-2 overflow-x-auto flex-1 scrollbar-hide">
  <button
    v-for="scenario in scenarios"
    :key="scenario.id"
    class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm transition-colors whitespace-nowrap flex-shrink-0"
    @click="emit('select-scenario', scenario.id)"
  >
    <!-- Investment icons -->
    <div class="flex -space-x-1">
      <UIcon
        v-for="(icon, index) in getScenarioInvestmentIcons(scenario.id)"
        :key="index"
        :name="icon"
        class="w-4 h-4"
      />
    </div>
    <span>{{ scenario.name }}</span>
  </button>
</div>
```

**Key Classes:**
- `overflow-x-auto` - Vízszintes scrollozás engedélyezése
- `flex-1` - Container kitölti a rendelkezésre álló helyet
- `scrollbar-hide` - Scrollbar elrejtése vizuális tisztaság érdekében
- `whitespace-nowrap` - Gomb szövegének törésgátlása
- `flex-shrink-0` - Gombok méretének megőrzése scroll közben

### Footer Action Buttons Toggle (SurveyFooter)

**Feature:** Eye icon gomb a scenario action buttons láthatóságának vezérlésére.

**Implementation:**
```typescript
const showScenarioButtons = ref(true)
```

```vue
<!-- Eye/Eye-off toggle button -->
<UButton
  :icon="showScenarioButtons ? 'i-lucide-eye' : 'i-lucide-eye-off'"
  color="gray"
  variant="outline"
  @click="showScenarioButtons = !showScenarioButtons"
/>

<!-- Conditional sections -->
<div v-if="activeTab === 'consultation' && showScenarioButtons">
  <UButton label="AI Scenarios" @click="emit('ai-scenarios')" />
  <UButton label="New Scenario" @click="emit('new-scenario')" />
</div>

<template v-if="activeTab === 'consultation' && activeScenario && showScenarioButtons">
  <UButton label="Rename" @click="emit('rename-scenario')" />
  <UButton label="Duplicate" @click="emit('duplicate-scenario')" />
  <UButton label="Delete" @click="emit('delete-scenario')" />
</template>
```

**Behavior:**
- Toggle gomb ikon változik: `i-lucide-eye` ↔ `i-lucide-eye-off`
- Elrejti/mutatja az összes scenario action gombot
- Helytakarékosság a láblécben

### Auto-select First Scenario After Deletion

**Feature:** Scenario törlése után automatikusan az első megmaradt scenario lesz aktív.

**Implementation:**
```typescript
const handleDeleteScenario = async () => {
  if (!activeScenario.value) return

  if (!confirm(`Are you sure you want to delete "${activeScenario.value.name}"?`)) {
    return
  }

  try {
    const supabase = useSupabaseClient()

    const { error } = await supabase
      .from('scenarios')
      .delete()
      .eq('id', activeScenario.value.id)

    if (error) throw error

    // Refresh scenarios list
    await scenariosStore.loadScenarios(surveyId.value)

    // Set first scenario as active if any scenarios remain
    if (scenarios.value.length > 0) {
      scenariosStore.setActiveScenario(scenarios.value[0].id)
    }

  } catch (error) {
    console.error('Error deleting scenario:', error)
  }
}
```

**User Experience:**
- Folyamatos munkamenet törlés után
- Nincs "üres" állapot, ha vannak scenarios
- Automatikus váltás, nincs szükség manuális kiválasztásra

### Manual vs AI Scenario Creation

**Feature:** "New Scenario" gomb csak egy üres scenariot hoz létre investment kapcsolatokkal, MainComponents nélkül.

**Implementation:**
```typescript
// In SelectInvestmentsModal
interface Props {
  mode: 'ai' | 'manual'
  // ...
}

// Manual scenario creation
const createManualScenario = async () => {
  // Create empty scenario with investments only
  const newScenario = await createScenario({
    surveyId,
    name: `Version ${nextSequence}`,
    investmentIds: selectedInvestmentIds.value
  })

  // NO MainComponents are added automatically
  // User manually adds components via UI
}
```

**Difference:**
- **AI Scenarios:** 3 darab, automatikus MainComponent kiválasztással
- **Manual Scenario:** 1 darab üres, csak investment kapcsolatokkal

---

## Error Handling

### Duplicate Component Prevention

```typescript
// Check existing components
const existingComponentIds = getCategoryComponents(categoryId)
  .map(c => c.main_component_id)

// Find available component
const availableComponent = components
  .find(c => !existingComponentIds.includes(c.value))

if (!availableComponent) {
  console.warn('All components already added')
  return
}
```

### Loading States

```typescript
const loadingCategories = ref<Record<string, boolean>>({})

const handleAddRow = async (categoryId: string) => {
  if (loadingCategories.value[categoryId]) return

  try {
    loadingCategories.value[categoryId] = true
    // ... operation
  } finally {
    loadingCategories.value[categoryId] = false
  }
}
```

---

## Future Enhancements

### Planned Features

1. **Toast Notifications**
   - Success/error messages komponens műveletekhez
   - User feedback javítása

2. **Category Info Modal**
   - Részletes információ a kategóriákról
   - Ajánlások és best practices

3. **Bulk Operations**
   - Több komponens egyidejű hozzáadása
   - Komponensek másolása scenarios között

4. **Price Calculation**
   - Real-time ár kalkuláció
   - Összehasonlítás scenarios között

5. **Validation**
   - Kötelező kategóriák ellenőrzése
   - Mennyiség validáció (min/max)

6. **Export/Import**
   - Scenario export JSON formátumban
   - Scenario template import

---

## Troubleshooting

### Common Issues

**Issue:** Scenarios eltűnnek az "Add Component" gomb után
- **Cause:** `loadScenarios()` reseteli az active scenario state-et
- **Solution:** Ne töltsük újra az egész listát, a store már frissíti a lokális state-et

**Issue:** UUID jelenik meg a dropdown-ban név helyett
- **Cause:** USelect nem megfelelően kezeli a `valueAttribute` és `optionAttribute` prop-okat
- **Solution:** Custom `UISelect` komponens használata natív HTML select-tel

**Issue:** Duplicate key constraint error
- **Cause:** Ugyanazt a komponenst próbáljuk hozzáadni kétszer
- **Solution:** Ellenőrzés a hozzáadás előtt + loading state

---

### Fixed Issues (2025-10-22)

**Issue:** Category names megjelennek "Other"-ként a ContractDetailsCosts komponensben
- **Error:** `GET main_component_categories?select=id,name,persist_name... 400 (Bad Request)`
- **Root Cause:** A `main_component_categories` tábla NEM tartalmaz `name` mezőt, csak `persist_name` és `id` mezőket
- **Solution:**
  - Query módosítva: `.select('id, persist_name')` (name mező eltávolítva)
  - Kategória mapping frissítve: csak `persist_name` használata fordításhoz
  ```typescript
  // BEFORE (hibás):
  const { data: categoriesData } = await supabase
    .from('main_component_categories')
    .select('id, name, persist_name')  // ❌ 'name' nem létezik

  // AFTER (helyes):
  const { data: categoriesData } = await supabase
    .from('main_component_categories')
    .select('id, persist_name')  // ✅ Csak létező mezők

  categoriesMap = Object.fromEntries(
    categoriesData.map((cat: any) => [
      cat.id,
      categoryTranslations[cat.persist_name] || 'Egyéb'
    ])
  )
  ```

**Issue:** Subsidies price column nem létezik
- **Error:** `GET survey_subsidies?select=subsidy:subsidies(price)... 400 (Bad Request)`
- **Error Message:** `column subsidies_1.price does not exist`
- **Root Cause:** A `subsidies` tábla NEM tartalmaz `price` mezőt. A kedvezmények `discount_type` és `discount_value` mezőkkel vannak tárolva
- **Solution:**
  - Query módosítva: `.select('discount_type, discount_value')`
  - Subsidy ár kalkuláció hozzáadva mindkét komponensben (FinancingModal és ContractDetailsCosts):
  ```typescript
  let calculatedPrice = 0
  if (subsidy.discount_type === 'percentage') {
    calculatedPrice = implementationFee.value * subsidy.discount_value / 100
  } else if (subsidy.discount_type === 'fixed') {
    calculatedPrice = subsidy.discount_value
  }
  ```

**Issue:** Independent Investments funkció elavult, de hivatkozások maradtak
- **Problem:** `consultationViewMode` és kapcsolódó UI elemek már nem használtak
- **Solution:**
  - UI toggle gomb eltávolítva a SurveyHeader-ből
  - "Container 1" section eltávolítva
  - Minden `consultationViewMode` prop és ellenőrzés eltávolítva az összes komponensből
  - Database migration létrehozva (059): `consultation_view_mode` oszlop törlése a surveys táblából
  - Dokumentáció frissítve: Independent Investments referenciák eltávolítva

---

## Performance Considerations

1. **Lazy Loading:** Csak az aktív scenario komponenseit töltjük be
2. **Debouncing:** Quantity input változásoknál debounce használata
3. **Optimistic Updates:** Lokális state azonnal frissül, háttérben megy az API hívás
4. **Memoization:** Computed properties a felesleges újraszámítások elkerülésére

---

## Testing Checklist

### Scenario Management
- [ ] AI scenarios létrehozása multiple investments-tel (3 scenarios: Optimum, Minimum, Premium)
- [ ] Manual scenario létrehozása (1 üres scenario)
- [ ] Scenario váltás a headerben
- [ ] Scenario gombok vízszintes scrollozása
- [ ] Scenario törlése és automatikus első scenario kiválasztás
- [ ] Scenario rename és duplicate funkciók

### Component Management
- [ ] Komponens hozzáadása minden kategóriában
- [ ] Komponens módosítása dropdown-ból
- [ ] Mennyiség módosítása
- [ ] Komponens törlése
- [ ] Duplicate prevention működése
- [ ] Loading states minden műveletnél

### Contract Details & Costs
- [ ] MainComponents megjelenítése kategóriánként (magyar nevek)
- [ ] ExtraCosts összesítése
- [ ] Implementation Fee kalkuláció
- [ ] Subsidies megjelenítése (percentage és fixed típusok)
- [ ] Total kalkuláció helyessége
- [ ] Commission rate váltás (4 szint)
- [ ] Price click cycling (red → yellow → green → black)
- [ ] Commission button selection
- [ ] Commission rate persistence scenario váltáskor

### UI & State
- [ ] Panel collapse/expand (System Design, Consultation)
- [ ] State persistence (panel states)
- [ ] Footer eye icon toggle (scenario buttons visibility)
- [ ] Category név fordítások helyessége
- [ ] Loading states
- [ ] Error handling
- [ ] Empty states (no components, no scenarios)

---

## Related Documentation

- [Survey Architecture](./survey-architecture.md)
- [Database Schema](./database-schema.md)
- [Component Library](./component-library.md)
- [State Management](./state-management.md)
