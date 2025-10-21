# Consultation Page Documentation

## Overview

A Consultation oldal a survey folyamat második fázisa, ahol az energetikai rendszer tervezése és ajánlatkészítés történik. Az oldal három fő részből áll: System Design, System Visualization és Consultation panel.

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
- `viewMode: 'scenarios' | 'independent'` - Megtekintési mód

**Events:**
- `update:system-design-open` - System Design panel toggle
- `update:consultation-open` - Consultation panel toggle
- `ai-scenarios` - AI scenarios létrehozás trigger
- `new-scenario` - Új scenario létrehozás trigger

**Features:**
- Collapsible side panels with smooth transitions
- Scenarios / Independent Investments toggle
- AI Scenarios és New Scenario gombok a System Design panelben
- State persistence az adatbázisban (panel állapotok mentése)

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

---

## State Persistence

### Panel States

A panel állapotok (nyitva/zárva) perzisztensen mentésre kerülnek a `surveys` táblában:

```typescript
{
  consultation_system_design_open: boolean
  consultation_panel_open: boolean
  consultation_view_mode: 'scenarios' | 'independent'
}
```

**Load:**
```typescript
onMounted(async () => {
  const { data: survey } = await supabase
    .from('surveys')
    .select('*')
    .eq('id', surveyId)
    .single()

  consultationSystemDesignOpen.value = survey.consultation_system_design_open
  // ...
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

## Performance Considerations

1. **Lazy Loading:** Csak az aktív scenario komponenseit töltjük be
2. **Debouncing:** Quantity input változásoknál debounce használata
3. **Optimistic Updates:** Lokális state azonnal frissül, háttérben megy az API hívás
4. **Memoization:** Computed properties a felesleges újraszámítások elkerülésére

---

## Testing Checklist

- [ ] AI scenarios létrehozása multiple investments-tel
- [ ] Scenario váltás a headerben
- [ ] Komponens hozzáadása minden kategóriában
- [ ] Komponens módosítása dropdown-ból
- [ ] Mennyiség módosítása
- [ ] Komponens törlése
- [ ] Panel collapse/expand
- [ ] View mode toggle (Scenarios/Independent)
- [ ] State persistence (panel states)
- [ ] Duplicate prevention
- [ ] Loading states
- [ ] Error handling

---

## Related Documentation

- [Survey Architecture](./survey-architecture.md)
- [Database Schema](./database-schema.md)
- [Component Library](./component-library.md)
- [State Management](./state-management.md)
