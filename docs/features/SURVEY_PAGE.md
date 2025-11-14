# Survey Page (Energy Consultation)

## Overview
The Survey Page is a comprehensive multi-step interface for conducting energy consultations. It features a tabbed workflow with conditional UI elements based on the active tab, guiding users through property assessment, consultation, offer creation, contract data entry, and summary generation.

## Route
- **Path:** `/survey/[surveyId]`
- **Navigation:** Accessible from Survey List via "Start Energy Consultation" button
- **Component:** `app/pages/survey/[surveyId].vue`
- **Parameter:** `surveyId` (UUID) - The ID of the survey to conduct

## Page Architecture

### Layout Structure
The page uses a fixed-height, non-scrollable layout with four main sections:

```
┌─────────────────────────────────────────┐
│           Header (Fixed)                │
├─────────────────────────────────────────┤
│       Navigation Tabs (Fixed)           │
├─────────────────────────────────────────┤
│                                         │
│      Main Content (Scrollable)          │
│                                         │
├─────────────────────────────────────────┤
│           Footer (Fixed)                │
└─────────────────────────────────────────┘
```

### Component Hierarchy
```
survey/[surveyId].vue (Main Page)
├── SurveyHeader.vue
├── SurveyNavigation.vue
├── Tab Content Components
│   ├── SurveyPropertyAssessment.vue
│   └── (4 placeholder tabs)
└── SurveyFooter.vue
```

## Workflow Tabs

The survey consists of 5 main tabs, executed in sequence:

1. **(1) Property Assessment** - Collect property data and photos
2. **(2) Consultation** - Energy consultation details
3. **(3) Offer/Contract** - Generate and manage offers/contracts
4. **(4) Contract Data** - Additional contract information
5. **(5) Summary** - Review and finalize

### Tab Navigation
- Numbered tabs (1-5) for clear progression
- Active tab highlighted with primary color
- Can navigate between tabs by clicking
- "Next" button in footer advances to next tab

## Header Component

**File:** `app/components/Survey/SurveyHeader.vue`

### Always Visible Elements

**Left Side:**
- **Back Button** (Arrow Left Icon)
  - Returns to `/survey` (survey list)
  - Gray ghost button

**Right Side:**
- **Client Name**
  - Displays the client's name
  - Right-aligned text

### Conditional Elements (Property Assessment Tab)

**Left Side (after Back button):**
1. **Investment Button** (Plus Icon)
   - Label: "Investment"
   - Action: Toggle investment mode
   - Gray outline button

2. **Edit Client Data Button** (User Icon)
   - Label: "Edit Client Data"
   - Action: Open client data editor
   - Gray outline button

**Right Side (before Client Name):**
1. **View Mode Toggle**
   - Three-state toggle: Photos | Data | All
   - Pill-style button group
   - Active state: White background with shadow
   - Inactive states: Gray text with hover effect

2. **Container Placeholder**
   - Gray rounded container
   - Text: "Container"
   - Placeholder for future feature

3. **Hide/Show Button** (Eye Slash Icon)
   - Toggle visibility of hidden items
   - Gray ghost button

### Header Props
```typescript
interface Props {
  activeTab: string
  clientName: string
  showModeToggle?: boolean // Show view mode toggle
}
```

### Header Events
```typescript
emit('back')                          // Navigate back
emit('toggle-investment')             // Toggle investment mode
emit('edit-client')                   // Edit client data
emit('toggle-view-mode', mode)        // Change view mode
emit('toggle-hidden')                 // Toggle hidden items
```

## Navigation Component

**File:** `app/components/Survey/SurveyNavigation.vue`

### Features
- Horizontal scrollable tab bar
- Numbered tabs with labels
- Active tab highlighted
- Responsive to narrow viewports

### Tab Structure
Each tab displays:
- **Number Badge** - Circular badge with tab number (1-5)
- **Label** - Tab name (e.g., "Property Assessment")

### Styling
- **Active Tab:**
  - Background: Primary-500
  - Text: White
  - Number badge: White with 20% opacity background

- **Inactive Tabs:**
  - Text: Gray-600
  - Number badge: Gray-200 background
  - Hover: Gray-100 background

### Navigation Props
```typescript
interface Props {
  modelValue: string  // Current active tab ID
  tabs: Tab[]        // Array of tab configurations
}

interface Tab {
  id: string         // Tab identifier
  label: string      // Display name
  number: number     // Tab sequence number
}
```

## Footer Component

**File:** `app/components/Survey/SurveyFooter.vue`

### Always Visible Elements

**Left Side:**
- **Save and Exit Button**
  - Gray outline button, large size
  - Action: Save progress and return to survey list

**Right Side:**
- **Next Button** (with Arrow Right Icon)
  - Primary color, large size
  - Trailing icon position
  - Action: Advance to next tab
  - Disabled when `canProceed` is false

### Conditional Elements (Property Assessment Tab)

**Left Side (after Save and Exit):**
1. **Upload All Photos Button**
   - Primary outline button
   - Action: Batch upload photos

2. **Fill All Data Button**
   - Primary outline button
   - Action: Auto-fill form data

3. **Generate Assessment Sheet Button**
   - Primary outline button
   - Action: Create assessment document

**Right Side (before Next button):**
1. **Marker Mode Toggle**
   - Label: "Marker Mode"
   - UToggle switch component
   - Emits boolean value on change

2. **Missing Items Warning Button**
   - Label: "Missing Items (X)" where X is count
   - Warning triangle icon
   - Orange outline button
   - Action: Show list of missing required items

### Footer Props
```typescript
interface Props {
  activeTab: string
  showPropertyActions?: boolean  // Show Property Assessment buttons
  missingItemsCount?: number    // Number of missing items
  canProceed?: boolean          // Enable/disable Next button
}
```

### Footer Events
```typescript
emit('save-exit')                     // Save and exit to list
emit('upload-photos')                 // Upload all photos
emit('fill-all-data')                 // Fill all data fields
emit('generate-assessment')           // Generate assessment sheet
emit('toggle-marker-mode', enabled)   // Toggle marker mode
emit('show-missing-items')            // Show missing items modal
emit('next')                          // Proceed to next tab
```

## Property Assessment Tab

**File:** `app/components/Survey/SurveyPropertyAssessment.vue`

### Current Status ✅
- **Fully implemented with advanced features**
- Real-time database persistence
- Multi-instance survey page support
- Default value inheritance across questions
- Dynamic readonly fields

### Key Features

**Survey Answer Persistence:**
- All answers automatically saved to database
- Support for multi-instance pages (e.g., multiple wall surfaces)
- Real-time sync between frontend state and database
- Automatic data loading on survey initialization

**Default Value Inheritance:**
- Questions can inherit values from other questions
- Example: "Basic Data" → "External Wall Structure" auto-populates all facade insulation walls
- Database trigger ensures backend consistency
- Frontend immediate updates for better UX

**Dynamic Readonly Fields:**
- Fields become readonly when source data is available
- User can manually edit when source is empty
- Automatic re-enable when source is cleared
- Visual feedback with opacity and disabled state

**Multi-Instance Pages:**
- Support for `allow_multiple: true` pages
- Add/remove instances dynamically
- Each instance saved with unique `item_group` identifier
- Default values auto-loaded for new instances

**Hierarchical Survey Pages (NEW):**
- Support for parent-child page relationships via `parent_page_id`
- Nested instances: each parent instance can have multiple child instances
- Example: "Falak" (Walls) → "Nyílászárók" (Openings)
  - Wall #1 can have Opening #1, Opening #2, etc.
  - Wall #2 can have Opening #1, Opening #2, etc.
- Child answers linked to parent via `parent_item_group` in database
- Nested accordion UI for intuitive navigation
- Automatic data synchronization between parent and child instances

**Automated Wall Metrics Calculations (NEW):**
- Real-time calculations for facade insulation metrics
- Per-wall calculations displayed in each wall accordion:
  - Homlokzat bruttó (Gross facade area)
  - Homlokzat bruttó, lábazat nélkül (Gross facade without foundation)
  - Lábazat felülete (Foundation surface area)
  - Falon lévő nyílászárók homlokzati felülete (Opening surface area on wall)
  - Homlokzat nettó (Net facade area)
  - Káva felületek ezen a falon (Reveal surfaces on this wall)
- Aggregate calculations for all walls combined
- Opening-type-specific káva calculations:
  - Windows: 4 sides (full perimeter)
  - Doors/Balcony doors: 3 sides (no bottom)
- Automatic unit conversion (cm to m²)
- Real-time updates as user inputs data

### Data Storage

**Store:** `/app/stores/surveyInvestments.ts`

```typescript
// Regular responses (non-multiple pages)
investmentResponses: {
  [investmentId]: {
    [questionName]: value
  }
}

// Instance responses (allow_multiple pages)
pageInstances: {
  [investmentId]: {
    [pageId]: {
      instances: [
        { questionName: value, ... },  // item_group 0
        { questionName: value, ... },  // item_group 1
        ...
      ],
      // Hierarchical subpage instances (NEW)
      subpageInstances: {
        [parentItemGroup: number]: [
          { questionName: value, ... },  // child item_group 0
          { questionName: value, ... },  // child item_group 1
          ...
        ]
      }
    }
  }
}
```

**Example Hierarchical Structure:**
```typescript
// Wall #0 (parent_item_group: null, item_group: 0)
//   → Opening #0 (parent_item_group: 0, item_group: 0)
//   → Opening #1 (parent_item_group: 0, item_group: 1)
// Wall #1 (parent_item_group: null, item_group: 1)
//   → Opening #0 (parent_item_group: 1, item_group: 0)
//   → Opening #1 (parent_item_group: 1, item_group: 1)

pageInstances: {
  'facade-investment-id': {
    'walls-page-id': {
      instances: [
        { wall_length: '1000', wall_height: '300' },  // Wall #0
        { wall_length: '800', wall_height: '300' }    // Wall #1
      ]
    },
    'openings-page-id': {
      subpageInstances: {
        0: [  // Openings for Wall #0
          { opening_type: 'Ablak', opening_width: '120', opening_height: '150' },
          { opening_type: 'Ajtó', opening_width: '90', opening_height: '210' }
        ],
        1: [  // Openings for Wall #1
          { opening_type: 'Ablak', opening_width: '100', opening_height: '120' }
        ]
      }
    }
  }
}
```

### Database Schema

**survey_answers Table:**
```sql
CREATE TABLE survey_answers (
  id UUID PRIMARY KEY,
  survey_id UUID NOT NULL,
  survey_question_id UUID NOT NULL,
  answer TEXT,
  item_group INTEGER,         -- NULL for regular pages, 0,1,2,... for multiple
  parent_item_group INTEGER,  -- NEW: Links child to parent instance
  UNIQUE (
    survey_id,
    survey_question_id,
    COALESCE(item_group, -1),
    COALESCE(parent_item_group, -1)  -- NEW: Part of unique constraint
  )
);

-- Indexes for hierarchical queries
CREATE INDEX idx_survey_answers_parent_item_group
  ON survey_answers(parent_item_group)
  WHERE parent_item_group IS NOT NULL;
```

**survey_pages Table:**
```sql
ALTER TABLE survey_pages
ADD COLUMN parent_page_id UUID REFERENCES survey_pages(id) ON DELETE CASCADE;

-- Index for efficient parent-child lookups
CREATE INDEX idx_survey_pages_parent_page_id
  ON survey_pages(parent_page_id)
  WHERE parent_page_id IS NOT NULL;
```

**survey_questions Table:**
```sql
ALTER TABLE survey_questions
ADD COLUMN default_value_source_question_id UUID REFERENCES survey_questions(id);

ALTER TABLE survey_questions
ADD COLUMN is_readonly BOOLEAN DEFAULT FALSE;
```

**Migrations:**
- `102_add_hierarchical_survey_pages.sql` - Adds parent_page_id and parent_item_group support
- `104_create_openings_survey_page.sql` - Creates Nyílászárók (Openings) subpage
- `105_add_planned_investment_and_site_conditions_pages.sql` - Adds additional facade insulation pages

### Hierarchical Survey Pages - Implementation Details

**Store Methods (surveyInvestments.ts):**

The following methods were added to support hierarchical pages:

```typescript
// Get all subpages for a given parent page
getSubPages: (state) => (parentPageId: string): SurveyPage[]

// Get subpage instances for a specific parent instance
getSubPageInstances(subpageId: string, parentItemGroup: number): Record<string, any>[]

// Add a new subpage instance under a parent instance
addSubPageInstance(subpageId: string, parentItemGroup: number): void

// Remove a subpage instance
removeSubPageInstance(
  subpageId: string,
  parentItemGroup: number,
  index: number,
  allowDeleteFirst: boolean
): void

// Get a specific subpage instance response
getSubPageInstanceResponse(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number,
  questionName: string
): any

// Save a subpage instance response
saveSubPageInstanceResponse(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number,
  questionName: string,
  value: any
): Promise<void>

// Load default values for a new subpage instance
loadDefaultValuesForSubPageInstance(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number
): Promise<void>
```

**Component Methods (SurveyPropertyAssessment.vue):**

```typescript
// Get subpages of a parent page
getSubPages(parentPageId: string): SurveyPage[]

// Get instances for a subpage under a specific parent
getSubPageInstances(subpageId: string, parentItemGroup: number): any[]

// Get instance name with index
getSubPageInstanceName(subpage: SurveyPage, index: number): string

// Check if instance can be deleted
canDeleteSubPageInstance(subpage: SurveyPage, parentItemGroup: number, index: number): boolean

// Add new subpage instance
addSubPageInstance(subpageId: string, parentItemGroup: number): void

// Delete subpage instance
deleteSubPageInstance(subpage: SurveyPage, parentItemGroup: number, index: number): void

// Get question value from subpage instance
getSubPageInstanceQuestionValue(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number,
  questionName: string
): any

// Update question value in subpage instance
updateSubPageInstanceQuestionValue(
  subpageId: string,
  parentItemGroup: number,
  instanceIndex: number,
  questionName: string,
  value: any
): Promise<void>
```

**UI Structure:**

Hierarchical pages are rendered as nested accordions:
```vue
<UAccordion>  <!-- Parent instance accordion -->
  <div class="p-4">
    <!-- Parent questions -->

    <!-- Subpage section -->
    <div v-for="subpage in getSubPages(page.id)">
      <h5>{{ subpage.name }}</h5>

      <UAccordion>  <!-- Child instance accordion -->
        <!-- Child questions -->
      </UAccordion>

      <UButton @click="addSubPageInstance(subpage.id, parentIndex)">
        Add {{ subpage.name }}
      </UButton>
    </div>
  </div>
</UAccordion>
```

### Wall Metrics Calculations - Implementation Details

**Calculation Methods (SurveyPropertyAssessment.vue:463-552):**

```typescript
// Calculate metrics for a single wall instance
const calculateWallMetrics = (pageId: string, parentItemGroup: number) => {
  // 1. Get wall dimensions
  const wallLength = Number(getInstanceQuestionValue(pageId, parentItemGroup, 'wall_length')) || 0
  const wallHeight = Number(getInstanceQuestionValue(pageId, parentItemGroup, 'wall_height')) || 0
  const foundationHeight = Number(getInstanceQuestionValue(pageId, parentItemGroup, 'foundation_height')) || 0

  // 2. Calculate basic metrics (in m²)
  const bruttoHomlokzat = wallLength * wallHeight
  const bruttoLabazatNelkul = wallLength * (wallHeight - foundationHeight)
  const labazatFeluletePostpone = wallLength * foundationHeight

  // 3. Get all openings (nyílászárók) for this wall
  const openings = getSubPageInstances(nyilaszarokPageId, parentItemGroup)

  let nyilaszarokFeluletePostpone = 0
  let kavaFeluletek = 0

  openings.forEach((opening, index) => {
    // Get opening data
    const type = getSubPageInstanceQuestionValue(..., 'opening_type')
    const width = Number(getSubPageInstanceQuestionValue(..., 'opening_width')) / 100  // cm to m
    const height = Number(getSubPageInstanceQuestionValue(..., 'opening_height')) / 100
    const quantity = Number(getSubPageInstanceQuestionValue(..., 'opening_quantity'))
    const revealDepth = Number(getSubPageInstanceQuestionValue(..., 'reveal_depth')) / 100

    // Calculate opening surface area
    nyilaszarokFeluletePostpone += width * height * quantity

    // Calculate káva based on opening type
    if (type === 'Ablak') {
      // Window: 4 sides (full perimeter)
      kavaFeluletek += (width * 2 + height * 2) * revealDepth * quantity
    } else if (type === 'Ajtó' || type === 'Erkélyajtó') {
      // Door/Balcony door: 3 sides (no bottom)
      kavaFeluletek += (width + height * 2) * revealDepth * quantity
    }
  })

  // 4. Calculate net facade
  const nettoHomlokzat = bruttoLabazatNelkul - nyilaszarokFeluletePostpone

  return {
    bruttoHomlokzat: bruttoHomlokzat.toFixed(2),
    bruttoLabazatNelkul: bruttoLabazatNelkul.toFixed(2),
    labazatFeluletePostpone: labazatFeluletePostpone.toFixed(2),
    nyilaszarokFeluletePostpone: nyilaszarokFeluletePostpone.toFixed(2),
    nettoHomlokzat: nettoHomlokzat.toFixed(2),
    kavaFeluletek: kavaFeluletek.toFixed(2)
  }
}

// Calculate aggregate metrics for all walls
const calculateAllWallsMetrics = (pageId: string) => {
  const instances = getPageInstances(pageId)

  // Sum up all wall metrics
  let totals = { /* ... */ }
  instances.forEach((instance, index) => {
    const metrics = calculateWallMetrics(pageId, index)
    // Add to totals...
  })

  return totals
}
```

**Calculation Formulas:**

1. **Homlokzat bruttó (Gross facade):**
   ```
   wall_length × wall_height
   ```

2. **Homlokzat bruttó, lábazat nélkül (Gross facade without foundation):**
   ```
   wall_length × (wall_height - foundation_height)
   ```

3. **Lábazat felülete (Foundation surface):**
   ```
   wall_length × foundation_height
   ```

4. **Falon lévő nyílászárók felülete (Opening surface):**
   ```
   Σ (opening_width × opening_height × opening_quantity)
   ```
   Unit conversion: cm → m (divide by 100)

5. **Homlokzat nettó (Net facade):**
   ```
   (Gross facade without foundation) - (Total opening surface)
   ```

6. **Káva felületek (Reveal surfaces):**
   - **For Windows (Ablak):**
     ```
     Σ ((width × 2 + height × 2) × reveal_depth × quantity)
     ```
   - **For Doors/Balcony Doors (Ajtó/Erkélyajtó):**
     ```
     Σ ((width + height × 2) × reveal_depth × quantity)
     ```
   Unit conversion: cm → m (divide by 100)

**UI Display:**

Per-wall metrics are displayed in a collapsible accordion inside each wall instance:
```vue
<UAccordion :items="[{ label: 'Számítások', slot: `metrics-${pageId}-${index}` }]">
  <template #[`metrics-${pageId}-${index}`]>
    <div class="p-4 bg-blue-50 dark:bg-blue-900/20">
      <table class="w-full text-sm">
        <!-- 6 metrics displayed here -->
      </table>
    </div>
  </template>
</UAccordion>
```

Total metrics are displayed in a separate accordion below the "Add Wall" button:
```vue
<div v-if="page.type === 'walls' && getPageInstances(page.id).length > 0">
  <UAccordion :items="[{ label: 'Összes falfelület számítások' }]">
    <template>
      <div class="p-4 bg-green-50 dark:bg-green-900/20">
        <table class="w-full text-sm">
          <!-- 6 aggregate metrics displayed here -->
        </table>
      </div>
    </template>
  </UAccordion>
</div>
```

**Styling:**
- Per-wall calculations: Blue background (`bg-blue-50` / `dark:bg-blue-900/20`)
- Total calculations: Green background (`bg-green-50` / `dark:bg-green-900/20`)
- Real-time updates as user types
- Automatic recalculation when openings are added/removed

### Implementation Details

See [Survey System Architecture](../survey-system-architecture.md#advanced-features) for complete technical documentation.

## Tab Content Structure

### Property Assessment
- **Status:** ✅ Fully implemented (2025-10-30)
- **Features:**
  - Real-time database persistence
  - Multi-instance survey pages
  - Default value inheritance
  - Dynamic readonly fields
  - Investment-specific responses
  - Progress tracking

### Consultation
- **Status:** 📋 Placeholder only
- **Planned:** Energy consultation data, recommendations

### Offer/Contract
- **Status:** 📋 Placeholder only
- **Planned:** Offer generation, contract management

### Contract Data
- **Status:** 📋 Placeholder only
- **Planned:** Additional contract details, terms

### Summary
- **Status:** 📋 Placeholder only
- **Planned:** Review all data, finalization

## State Management

### Page-Level State
```typescript
// Active tab
const activeTab = ref<'property-assessment' | 'consultation' |
                      'offer-contract' | 'contract-data' | 'summary'>('property-assessment')

// Survey data
const surveyId = computed(() => route.params.surveyId as string)
const clientName = ref('Loading...')
const missingItemsCount = ref(0)
const canProceed = ref(false)
```

### Tab Configuration
```typescript
const tabs = [
  { id: 'property-assessment', label: 'Property Assessment', number: 1 },
  { id: 'consultation', label: 'Consultation', number: 2 },
  { id: 'offer-contract', label: 'Offer/Contract', number: 3 },
  { id: 'contract-data', label: 'Contract Data', number: 4 },
  { id: 'summary', label: 'Summary', number: 5 }
]
```

## Event Handlers

### Header Events
```typescript
handleBack()                  // Navigate to /survey
handleToggleInvestment()      // Toggle investment mode
handleEditClient()            // Open client editor
handleToggleViewMode(mode)    // Change view mode
handleToggleHidden()          // Toggle hidden items
```

### Footer Events
```typescript
handleSaveExit()                    // Save and navigate to /survey
handleUploadPhotos()                // Batch photo upload
handleFillAllData()                 // Auto-fill data
handleGenerateAssessment()          // Generate assessment sheet
handleToggleMarkerMode(enabled)     // Toggle marker mode
handleShowMissingItems()            // Show missing items
handleNext()                        // Advance to next tab
```

## Data Loading

### On Mount
```typescript
onMounted(async () => {
  await loadSurveyData()
})
```

### Load Survey Data
```typescript
const loadSurveyData = async () => {
  // TODO: Fetch from Supabase
  // - Load survey by ID
  // - Load related client data
  // - Calculate missing items count
  // - Determine if can proceed to next tab
}
```

### Expected Supabase Query
```typescript
const { data: survey } = await supabase
  .from('surveys')
  .select(`
    *,
    client:clients (
      id,
      name,
      email,
      phone,
      postal_code,
      city,
      street,
      house_number
    )
  `)
  .eq('id', surveyId)
  .single()
```

## Styling

### Layout Classes
- **Page Container:** `h-screen flex flex-col overflow-hidden`
- **Header:** Fixed height, border bottom
- **Navigation:** Fixed height, border bottom
- **Main Content:** `flex-1 overflow-hidden bg-gray-50`
- **Footer:** Fixed height, border top

### Responsive Behavior
- Navigation tabs scroll horizontally on narrow screens
- Header buttons may wrap on small screens
- Footer buttons stack vertically on mobile (future enhancement)

### Theme Support
- Full dark mode support throughout
- Uses Nuxt UI color system
- Consistent with existing page designs

## Navigation Flow

### From Survey List
```
/survey → Click "Start Energy Consultation"
  → /survey/[surveyId] (Property Assessment tab)
```

### Tab Progression
```
Property Assessment → Next → Consultation
Consultation → Next → Offer/Contract
Offer/Contract → Next → Contract Data
Contract Data → Next → Summary
```

### Exit Routes
```
/survey/[surveyId] → Back button → /survey
/survey/[surveyId] → Save and Exit → /survey
```

## Future Enhancements

### Immediate (Phase 1)
- [ ] Implement actual data loading from Supabase
- [ ] Add client data editing modal
- [ ] Implement Property Assessment content
- [ ] Add photo upload functionality
- [ ] Add form validation for each tab

### Medium Term (Phase 2)
- [ ] Implement Consultation tab
- [ ] Implement Offer/Contract tab
- [ ] Add contract generation
- [ ] Implement missing items validation
- [ ] Add auto-save functionality

### Long Term (Phase 3)
- [ ] Implement Contract Data tab
- [ ] Implement Summary tab
- [ ] Add PDF generation
- [ ] Add email integration
- [ ] Add real-time collaboration
- [ ] Add offline support

## Error Handling

### Survey Not Found
```typescript
if (!survey) {
  // Show error message
  // Redirect to /survey list
}
```

### Permission Check
```typescript
// Verify user has access to this survey's company
if (survey.company_id !== userProfile.company_id) {
  // Show unauthorized error
  // Redirect to /survey list
}
```

### Network Errors
```typescript
try {
  await loadSurveyData()
} catch (error) {
  // Show error toast
  // Offer retry option
}
```

## Related Files

### Pages
- `app/pages/survey/index.vue` - Survey list page
- `app/pages/survey/[surveyId].vue` - Main survey page
- `app/pages/survey/client-data.vue` - New client form

### Components
- `app/components/Survey/SurveyHeader.vue` - Survey page header
- `app/components/Survey/SurveyNavigation.vue` - Tab navigation
- `app/components/Survey/SurveyFooter.vue` - Survey page footer
- `app/components/Survey/SurveyPropertyAssessment.vue` - Property assessment tab
- `app/components/Survey/SurveyListItem.vue` - Survey list item (navigation source)

### Database
- Table: `surveys`
- Table: `clients`
- Table: `survey_pages`
- Table: `survey_questions`
- Table: `survey_answers`
- Migration: `supabase/migrations/004_create_survey_system.sql`
- Migration: `supabase/migrations/102_add_hierarchical_survey_pages.sql` - Hierarchical pages support
- Migration: `supabase/migrations/104_create_openings_survey_page.sql` - Openings subpage
- Migration: `supabase/migrations/105_add_planned_investment_and_site_conditions_pages.sql` - Additional pages

### Stores
- `app/stores/surveyInvestments.ts` - Survey data state management with hierarchical support

## Implementation Status

### Completed ✅
- [x] Create page routing with dynamic surveyId
- [x] Implement header component with conditional buttons
- [x] Implement navigation tabs with numbering
- [x] Implement footer component with conditional actions
- [x] Create Property Assessment placeholder tab
- [x] Set up tab state management
- [x] Implement Next button navigation
- [x] Link from Survey List (Start Consultation button)
- [x] Add view mode toggle (Photos/Data/All)
- [x] Add marker mode toggle
- [x] Add missing items counter
- [x] **Property Assessment full implementation (2025-10-30)**
- [x] **Real-time database persistence for survey answers**
- [x] **Multi-instance survey page support**
- [x] **Default value inheritance between questions**
- [x] **Dynamic readonly field behavior**
- [x] **Investment-specific response tracking**
- [x] **Hierarchical survey pages with parent-child relationships (2025-10-30)**
- [x] **Nested accordion UI for hierarchical pages (2025-10-30)**
- [x] **Wall metrics calculations with real-time updates (2025-10-30)**
- [x] **Opening-type-specific káva calculations (2025-10-30)**
- [x] Load survey data from Supabase
- [x] Implement client name display
- [x] Calculate missing items count
- [x] Implement canProceed validation

### In Progress 🚧
- [ ] Consultation tab content
- [ ] Offer/Contract tab content

### Planned 📋
- [ ] Consultation tab content
- [ ] Offer/Contract tab content
- [ ] Contract Data tab content
- [ ] Summary tab content
- [ ] Photo upload batch operations
- [ ] Data auto-fill enhancement
- [ ] Assessment sheet generation
- [ ] Client data editing modal
- [ ] Advanced form validation

## Technical Notes

### Component Communication
- Parent page manages all state
- Components emit events for user actions
- Props pass data down to components
- No direct child-to-child communication

### Performance Considerations
- Tab content lazy-loaded (v-if)
- Only active tab rendered in DOM
- Fixed layout prevents reflow
- Optimized for smooth transitions

### Accessibility
- Semantic HTML structure
- Keyboard navigation support
- ARIA labels on icon buttons
- Focus management between tabs

---

**Created:** 2025-10-20
**Last Updated:** 2025-10-30
**Status:** Phase 1 Complete - Property Assessment Fully Implemented with Hierarchical Pages & Calculations
**Next Steps:** Implement Consultation and Offer/Contract tabs
**Dependencies:** Survey system migration, Supabase integration

**Major Updates (2025-10-30):**
- ✅ Property Assessment tab fully implemented
- ✅ Real-time database persistence for survey answers
- ✅ Multi-instance survey page support with item_group
- ✅ Default value inheritance across questions
- ✅ Dynamic readonly field behavior
- ✅ Investment-specific response tracking
- ✅ **Hierarchical survey pages (parent-child relationships)**
- ✅ **Nested accordion UI for hierarchical data entry**
- ✅ **Automated wall metrics calculations**
- ✅ **Real-time facade insulation area calculations**
- ✅ **Opening-type-specific reveal (káva) calculations**
