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

### Current Status
- **Placeholder implementation**
- Displays centered content with:
  - Home icon (gray)
  - Title: "Property Assessment"
  - Status: "Content under development"
  - Survey ID for debugging

### Future Implementation
Will include:
- Photo upload interface
- Property data forms
- Room-by-room assessment
- Marker mode for annotations
- Data validation

## Tab Content Structure

### Property Assessment
- **Status:** ✅ Placeholder created
- **Features:** Photo upload, data forms, assessment tools

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
- Migration: `supabase/migrations/003_create_survey_system.sql`

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

### In Progress 🚧
- [ ] Load survey data from Supabase
- [ ] Implement client name display
- [ ] Calculate missing items count
- [ ] Implement canProceed validation

### Planned 📋
- [ ] Property Assessment content
- [ ] Consultation tab content
- [ ] Offer/Contract tab content
- [ ] Contract Data tab content
- [ ] Summary tab content
- [ ] Form validation
- [ ] Photo upload
- [ ] Data auto-fill
- [ ] Assessment sheet generation
- [ ] Client data editing
- [ ] Missing items modal

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
**Status:** Phase 1 - Structure Complete
**Next Steps:** Implement Property Assessment content
**Dependencies:** Survey system migration, Supabase integration
