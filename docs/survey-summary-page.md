# Survey Summary Page - Functional Documentation

**Created:** 2025-10-24
**Version:** 1.0.0
**Components:** SurveySummary.vue, Contract Modals, SignaturePad, EmailTemplateEditor, ContractPreview

---

## Table of Contents

1. [Overview](#overview)
2. [Component Architecture](#component-architecture)
3. [View Modes](#view-modes)
4. [Contract Cards](#contract-cards)
5. [Modal Windows](#modal-windows)
6. [Supporting Components](#supporting-components)
7. [User Flows](#user-flows)
8. [Technical Implementation](#technical-implementation)
9. [State Management](#state-management)
10. [Testing Checklist](#testing-checklist)
11. [Related Documentation](#related-documentation)

---

## Overview

The **Summary Page** is the final step (Tab 5) in the survey workflow where users can:

- Review all contracts created during the survey
- View comprehensive contract information in list or card format
- Send individual or multiple contracts via email
- Digitally sign contracts with touch/mouse support
- Manage contract lifecycle (save, send, sign)

### Key Features

✅ **Dual View Modes**: Toggle between List and Card layouts
✅ **Contract Overview**: Display all contract details with client information
✅ **Email Integration**: Send contracts with customizable email templates
✅ **Digital Signatures**: Touch and mouse-friendly signature capture
✅ **Batch Operations**: Send or sign multiple contracts simultaneously
✅ **Smart Data Display**: Automatic fallback to Survey Client data
✅ **Responsive Design**: Adapts to different screen sizes

---

## Component Architecture

### Component Hierarchy

```
SurveySummary.vue (Main Page)
├── View Toggle (List/Card)
├── Contract Cards (1-N)
│   ├── Client Information
│   ├── Contract Details
│   │   ├── Selected Investments
│   │   └── Cost Summary
│   └── Action Buttons
│       ├── Save without send
│       ├── Save and Send → Opens SurveySendContractModal
│       └── Sign Now → Opens SurveySignContractModal
│
└── Modals (triggered from cards or footer)
    ├── SurveySendContractModal
    │   ├── ContractPreview
    │   └── EmailTemplateEditor
    ├── SurveySignContractModal
    │   ├── ContractPreview
    │   ├── Acceptance Switches
    │   └── SignaturePad
    ├── SurveySendAllContractsModal
    │   ├── Multiple ContractPreviews
    │   └── EmailTemplateEditor
    └── SurveySignAllContractsModal
        ├── Multiple ContractPreviews
        ├── Per-Contract SignaturePad
        └── Global Switches
```

### File Structure

```
app/components/Survey/
├── SurveySummary.vue              # Main summary page
├── SurveySendContractModal.vue    # Send single contract
├── SurveySignContractModal.vue    # Sign single contract
├── SurveySendAllContractsModal.vue # Send all contracts
├── SurveySignAllContractsModal.vue # Sign all contracts
├── ContractPreview.vue            # Contract preview display
├── SignaturePad.vue               # Digital signature capture
└── EmailTemplateEditor.vue        # Rich text email editor

app/pages/survey/[surveyId].vue    # Parent page integration
```

---

## View Modes

The Summary page offers two distinct view modes for displaying contracts.

### List View

**Layout:** Full-width contract cards stacked vertically

**Features:**
- One contract per row
- Maximum visibility of all information
- Action buttons show **icons + labels**
- Best for detailed review

**Use Case:** When users need to carefully review contract details

### Card View

**Layout:** Grid layout with up to 3 contracts per row

**Features:**
- Compact card design
- `grid-cols-1 md:grid-cols-2 xl:grid-cols-3` responsive grid
- Action buttons show **icons only** (no labels)
- 4th contract starts a new row

**Use Case:** When users want an overview of multiple contracts

### Toggle Implementation

```vue
<UButton
  :icon="viewMode === 'list' ? 'i-lucide-list' : 'i-lucide-layout-grid'"
  :color="viewMode === 'list' ? 'primary' : 'gray'"
  @click="viewMode = 'list'"
>
  List
</UButton>
```

**Icons:**
- List view: `i-lucide-list`
- Card view: `i-lucide-layout-grid`

---

## Contract Cards

Each contract displays comprehensive information in a card format.

### Card Structure

#### Header
- **Contract Name** (e.g., "Contract 1", "Solar Installation Offer")

#### Body

**1. Client Information**
- Name (icon: `i-lucide-user`)
- Address (icon: `i-lucide-map-pin`)
- Phone (icon: `i-lucide-phone`)
- Email (icon: `i-lucide-mail`)

**Data Source Priority:**
1. Contract's `client_*` fields (if saved)
2. Survey Client data (fallback)
3. "No client information available" (if neither exists)

**2. Contract Details**

**Selected Investments:**
- Display as colored badges with icons
- Investment name + icon from `investments` table
- Example: `[Solar Icon] Solar Panel System`

**Cost Summary:**
- **Implementation Fee** (total_price)
- Formatted as Hungarian Forint (HUF)
- Large, bold display (text-2xl)

#### Footer

**Action Buttons (3):**

| Button | Icon | List View | Card View | Action |
|--------|------|-----------|-----------|--------|
| Save without send | `i-lucide-save` | Icon + Label | Icon only | Auto-save contract data |
| Save and Send | `i-lucide-send` | Icon + Label | Icon only | Open Send Modal |
| Sign Now | `i-lucide-pen-tool` | Icon + Label | Icon only | Open Sign Modal |

**Button Variants:**
- Save without send: Gray, Outline
- Save and Send: Primary, Outline
- Sign Now: Primary, Solid

---

## Modal Windows

### 1. Send Contract Modal (Single)

**Trigger:** "Save and Send" button on contract card

**Title:** "Send Contract"

**Content:**
1. **Contract Preview** (read-only)
   - Full contract details
   - Client information
   - Selected investments
   - Components breakdown
   - Extra costs
   - Discounts
   - Total price

2. **E-mail sablon szerkesztése**
   - Rich text editor with toolbar
   - Default template with placeholders
   - Placeholders: `{client_name}`, `{contract_name}`, `{total_price}`

**Footer Buttons:**
- **Mégse** (Cancel) - Gray, Outline
- **Küldés** (Send) - Primary, Solid
  - Disabled if email template is empty

**Emitted Event:** `@send(emailTemplate: string)`

---

### 2. Sign Contract Modal (Single)

**Trigger:** "Sign Now" button on contract card

**Title:** "Szerződés aláírása"

**Content:**
1. **Contract Preview** (read-only)
   - Same as Send Modal

2. **Acceptance Switches** (3)
   - **Elfogadom az Adatkezelési Tájékoztatót**
   - **Elfogadom a szerződésben foglaltakat**
   - **Szerződés elküldése e-mailben** (client email in parentheses)

3. **Aláírás:** (Signature Pad)
   - Canvas-based signature capture
   - Touch and mouse support
   - "Törlés" button (top-right)
   - Placeholder: "Kérem írja alá itt"

**Footer Buttons:**
- **Mégse** (Cancel) - Gray, Outline
- **Aláírás** (Sign) - Primary, Solid
  - **Enabled only when:**
    - Privacy policy accepted (switch ON)
    - Contract accepted (switch ON)
    - Signature exists (not empty)

**Emitted Event:**
```typescript
@sign({
  signature: string,              // Data URL
  acceptPrivacyPolicy: boolean,
  acceptContract: boolean,
  sendByEmail: boolean
})
```

---

### 3. Send All Contracts Modal

**Trigger:** "Save All and Send" button in footer

**Title:** "Send Contracts ({count})"

**Content:**
1. **Multiple Contract Previews**
   - Each contract in a numbered card
   - Number badge (1, 2, 3, etc.)
   - Full preview for each contract
   - Dividers between contracts

2. **E-mail sablon szerkesztése** (below all previews)
   - Shared email template for all contracts
   - Default template for multiple contracts

**Footer Buttons:**
- **Mégse** (Cancel) - Gray, Outline
- **Küldés** (Send) - Primary, Solid
  - Disabled if email template is empty

**Emitted Event:** `@send(emailTemplate: string)`

---

### 4. Sign All Contracts Modal

**Trigger:** "Sign All Contracts ({count})" button in footer

**Title:** "Szerződések aláírása ({count})"

**Content:**
1. **Per-Contract Section** (for each contract)
   - Contract Preview
   - **Switch:** "Elfogadom a szerződésben foglaltakat"
   - **SignaturePad** (individual for each contract)
   - Divider

2. **Global Switches** (after all contracts)
   - **Elfogadom az Adatkezelési Tájékoztatót**
   - **Szerződés elküldése e-mailben** (client email)

**Footer Buttons:**
- **Mégse** (Cancel) - Gray, Outline
- **Összes aláírása** (Sign All) - Primary, Solid
  - **Enabled only when:**
    - Privacy policy accepted (global)
    - ALL contracts accepted (per-contract switches)
    - ALL contracts signed (all signature pads have signatures)

**Emitted Event:**
```typescript
@sign({
  signatures: Record<contractId, dataUrl>,
  acceptContracts: Record<contractId, boolean>,
  acceptPrivacyPolicy: boolean,
  sendByEmail: boolean
})
```

---

## Supporting Components

### ContractPreview.vue

Displays a comprehensive, read-only view of a contract.

**Props:**
```typescript
{
  contract: Contract,
  contractInvestments: string[],
  contractComponents: ContractMainComponent[],
  contractExtraCosts: ContractExtraCost[],
  contractDiscounts: ContractDiscount[],
  investments: Investment[],
  mainComponents: MainComponent[],
  clientData?: ClientData
}
```

**Sections:**

1. **Header**
   - Contract name
   - Mode (Offer/Contract)
   - Creation date

2. **Client Information** (2-column grid)
   - Name, Email, Phone, Address

3. **Selected Investments**
   - List with icons

4. **Components Breakdown**
   - Component name × quantity
   - Individual prices
   - Subtotals

5. **Extra Costs**
   - Item name × quantity (if applicable)
   - Prices

6. **Discounts**
   - Discount name
   - Amount (in green)

7. **Total Price**
   - Large, bold display
   - VAT and commission rate info

8. **Notes**
   - Additional comments (if any)

**Data Source Priority:**
```typescript
clientName = contract.client_name || clientData?.name || 'N/A'
clientAddress = contract.client_address || buildAddress(clientData) || 'N/A'
```

---

### SignaturePad.vue

Canvas-based signature capture component with touch and mouse support.

**Props:**
```typescript
{
  modelValue?: string  // Data URL of signature
}
```

**Features:**

1. **Input Support**
   - Mouse events: mousedown, mousemove, mouseup, mouseleave
   - Touch events: touchstart, touchmove, touchend
   - Automatic device detection

2. **Canvas Configuration**
   - Width: 800px
   - Height: 200px
   - Line width: 2px
   - Stroke style: Black (#000000)
   - Background: White (for proper export)

3. **Clear Functionality**
   - "Törlés" button (top-right)
   - Icon: `i-lucide-eraser`
   - Resets canvas to white background

4. **Empty State**
   - Placeholder text: "Kérem írja alá itt"
   - Centered, gray text

**Methods (Exposed):**
```typescript
clear(): void                    // Clear signature
getSignatureDataUrl(): string    // Export as PNG
isEmpty(): boolean               // Check if empty
```

**Coordinate Transformation:**
```typescript
const getCoordinates = (e: MouseEvent | Touch) => {
  const rect = canvas.getBoundingClientRect()
  const scaleX = canvasWidth / rect.width
  const scaleY = canvasHeight / rect.height
  return {
    x: (e.clientX - rect.left) * scaleX,
    y: (e.clientY - rect.top) * scaleY
  }
}
```

**Why Transformation is Needed:**
- Canvas may be scaled by CSS
- Touch/mouse coordinates are in viewport space
- Need to convert to canvas coordinate space

---

### EmailTemplateEditor.vue

Simple rich text editor for composing email messages.

**Props:**
```typescript
{
  modelValue: string  // Email content
}
```

**Toolbar Actions:**

| Button | Icon | Formatting | Syntax |
|--------|------|------------|--------|
| Bold | `i-lucide-bold` | **text** | `**text**` |
| Italic | `i-lucide-italic` | _text_ | `_text_` |
| Underline | `i-lucide-underline` | <u>text</u> | `<u>text</u>` |
| List | `i-lucide-list` | • Item | `\n- Item\n` |
| Link | `i-lucide-link` | [text](url) | `[text](url)` |

**Placeholders:**
- `{client_name}` - Client's name
- `{contract_name}` - Contract name
- `{total_price}` - Formatted total price

**Note:** Placeholders shown at bottom for user reference

**Implementation:**
```typescript
const insertFormatting = (before: string, after: string) => {
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = content.value.substring(start, end)

  const newText =
    content.value.substring(0, start) +
    before + selectedText + after +
    content.value.substring(end)

  content.value = newText
  // Restore cursor position
  setTimeout(() => {
    textarea.setSelectionRange(start + before.length, end + before.length)
  }, 0)
}
```

---

## User Flows

### Flow 1: Send Single Contract

1. User navigates to Summary tab
2. User clicks "Save and Send" on a contract card
3. **SurveySendContractModal** opens
4. User reviews contract preview
5. User edits email template (optional)
6. User clicks "Küldés"
7. Modal closes
8. Event emitted: `@send(emailTemplate)`
9. Parent handles email sending (TODO: implementation)

---

### Flow 2: Sign Single Contract

1. User navigates to Summary tab
2. User clicks "Sign Now" on a contract card
3. **SurveySignContractModal** opens
4. User reviews contract preview
5. User toggles privacy policy switch ON
6. User toggles contract acceptance switch ON
7. User signs on the signature pad
8. User optionally toggles email switch
9. "Aláírás" button becomes enabled
10. User clicks "Aláírás"
11. Modal closes
12. Event emitted: `@sign(data)`
13. Parent handles signature storage (TODO: implementation)

**Validation Logic:**
```typescript
const canSign = computed(() => {
  return acceptPrivacyPolicy.value &&
    acceptContract.value &&
    signature.value &&
    signaturePadRef.value &&
    !signaturePadRef.value.isEmpty()
})
```

---

### Flow 3: Send All Contracts

1. User navigates to Summary tab
2. User clicks "Save All and Send" in footer
3. **SurveySendAllContractsModal** opens
4. User reviews all contract previews (scrollable)
5. User edits shared email template
6. User clicks "Küldés"
7. Modal closes
8. Event emitted: `@send(emailTemplate)`
9. Parent handles batch email sending (TODO: implementation)

---

### Flow 4: Sign All Contracts

1. User navigates to Summary tab
2. User clicks "Sign All Contracts ({count})" in footer
3. **SurveySignAllContractsModal** opens
4. For each contract:
   - User reviews preview
   - User toggles "Elfogadom a szerződésben foglaltakat" ON
   - User signs on the signature pad
5. User toggles global privacy policy switch ON
6. User optionally toggles global email switch
7. "Összes aláírása" button becomes enabled
8. User clicks "Összes aláírása"
9. Modal closes
10. Event emitted: `@sign(data)`
11. Parent handles all signature storage (TODO: implementation)

**Validation Logic:**
```typescript
const canSignAll = computed(() => {
  if (!acceptPrivacyPolicy.value) return false

  for (const contract of contracts) {
    const isAccepted = acceptContracts[contract.id]
    const signature = signatures[contract.id]
    const signaturePad = signaturePadRefs.value[contract.id]

    if (!isAccepted || !signature || !signaturePad || signaturePad.isEmpty()) {
      return false
    }
  }

  return true
})
```

---

## Technical Implementation

### Data Loading

**Parent Component** (`survey/[surveyId].vue`) loads:

```typescript
onMounted(async () => {
  await loadSurveyData()                            // Load survey + client
  await scenariosStore.loadScenarios(surveyId)      // Load scenarios
  await scenariosStore.loadMainComponentsData()     // Load components catalog
  await contractsStore.loadContracts(surveyId)      // Load contracts + relations
})
```

**Data Available to Summary Page:**
- `contracts` - All contracts for the survey
- `contractInvestments` - Investment IDs per contract
- `contractComponents` - Main components per contract
- `contractExtraCosts` - Extra costs per contract
- `contractDiscounts` - Discounts per contract
- `investments` - Investment catalog (for names/icons)
- `mainComponents` - Component catalog (for names/prices)
- `clientData` - Survey client information

---

### Smart Data Fallback

When displaying client information, the system uses a priority chain:

```typescript
// Example: Client Name
const getClientName = (contract: Contract): string => {
  return contract.client_name ||        // 1. Saved in contract
         clientData?.name ||             // 2. From Survey Client
         ''                              // 3. Empty
}

// Example: Client Address
const getClientAddress = (contract: Contract): string => {
  if (contract.client_address) {
    return contract.client_address      // 1. Saved address
  }

  // 2. Build from Survey Client
  if (clientData) {
    const parts = [
      clientData.postal_code,
      clientData.city,
      clientData.street,
      clientData.house_number
    ].filter(Boolean)
    return parts.join(', ')
  }

  return ''                             // 3. Empty
}
```

**Why This Works:**
- Contract Data page auto-populates from Survey Client
- User may not have saved yet (data in inputs, not DB)
- Summary shows what user sees on Contract Data page
- Consistent experience across pages

---

### Modal State Management

**Parent Component State:**
```typescript
// Modal visibility
const showSendContractModal = ref(false)
const showSignContractModal = ref(false)
const showSendAllContractsModal = ref(false)
const showSignAllContractsModal = ref(false)

// Selected contract for single-contract modals
const selectedContractForSend = ref<Contract | null>(null)
const selectedContractForSign = ref<Contract | null>(null)
```

**Opening a Modal:**
```typescript
const handleSaveAndSendSingle = (contractId: string) => {
  const contract = contracts.value.find(c => c.id === contractId)
  if (contract) {
    selectedContractForSend.value = contract
    showSendContractModal.value = true
  }
}
```

**Modal Reset on Open:**
```typescript
watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    // Reset form when modal opens
    acceptPrivacyPolicy.value = false
    acceptContract.value = false
    sendByEmail.value = false
    signature.value = ''
    if (signaturePadRef.value) {
      signaturePadRef.value.clear()
    }
  }
})
```

---

### Price Formatting

All prices are displayed in Hungarian Forint (HUF) format:

```typescript
const formatPrice = (price: number): string => {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency',
    currency: 'HUF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(price)
}
```

**Example Output:** `1 500 000 Ft`

---

### Date Formatting

Contract creation dates are displayed in Hungarian long format:

```typescript
const formatDate = (dateString: string): string => {
  return new Date(dateString).toLocaleDateString('hu-HU', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
```

**Example Output:** `2025. október 24.`

---

## State Management

### Contracts Store

**Location:** `/app/stores/contracts.ts`

**Key State:**
```typescript
{
  contracts: Contract[],
  activeContractId: string | null,
  contractMainComponents: Record<contractId, ContractMainComponent[]>,
  contractInvestments: Record<contractId, string[]>,
  contractExtraCosts: Record<contractId, ContractExtraCost[]>,
  contractDiscounts: Record<contractId, ContractDiscount[]>,
  loading: boolean
}
```

**Key Actions:**
```typescript
loadContracts(surveyId: string)              // Load all contracts + relations
updateContract(contractId, data)             // Update contract fields
renameContract(contractId, newName)          // Rename contract
duplicateContract(contractId)                // Create copy
deleteContract(contractId)                   // Delete contract
setActiveContract(contractId)                // Set active contract
```

**Usage in Summary:**
```typescript
const contractsStore = useContractsStore()

const contracts = computed(() => contractsStore.contracts)
const getContractInvestments = (id) => contractsStore.contractInvestments[id] || []
```

---

### Scenarios Store

**Used for:** Loading main components catalog (for contract preview)

```typescript
const scenariosStore = useScenariosStore()

await scenariosStore.loadMainComponentsData()
const mainComponents = scenariosStore.mainComponents
```

---

### Investments Store

**Used for:** Investment names and icons

```typescript
const investmentsStore = useSurveyInvestmentsStore()

await investmentsStore.initializeForSurvey(surveyId)
const investments = investmentsStore.availableInvestments
```

---

## Testing Checklist

### View Modes
- [ ] Toggle switches correctly between List and Card views
- [ ] List view shows full-width cards
- [ ] Card view shows 3 columns (responsive: 1 on mobile, 2 on tablet, 3 on desktop)
- [ ] Action buttons show labels in List view
- [ ] Action buttons show only icons in Card view

### Contract Cards
- [ ] All contracts are displayed
- [ ] Client information shows correctly (with fallback)
- [ ] Selected investments display with correct icons
- [ ] Total price is formatted correctly (HUF)
- [ ] "No client information available" shows when data is missing

### Send Contract Modal (Single)
- [ ] Modal opens when clicking "Save and Send"
- [ ] Contract preview displays all sections
- [ ] Email template editor works (toolbar buttons)
- [ ] Placeholders are documented at bottom
- [ ] "Küldés" button is disabled when template is empty
- [ ] Modal closes after sending
- [ ] Event is emitted with email template

### Sign Contract Modal (Single)
- [ ] Modal opens when clicking "Sign Now"
- [ ] Contract preview displays correctly
- [ ] All 3 switches work (privacy, contract, email)
- [ ] Client email is shown in email switch label
- [ ] Signature pad accepts input (mouse)
- [ ] Signature pad accepts input (touch)
- [ ] "Törlés" button clears signature
- [ ] "Aláírás" button is disabled when:
  - [ ] Privacy policy not accepted
  - [ ] Contract not accepted
  - [ ] Signature is empty
- [ ] "Aláírás" button is enabled when all conditions met
- [ ] Modal closes after signing
- [ ] Event is emitted with signature data

### Send All Contracts Modal
- [ ] Modal opens when clicking footer "Save All and Send"
- [ ] All contract previews are displayed
- [ ] Contracts are numbered (1, 2, 3, etc.)
- [ ] Dividers separate contracts
- [ ] Email template editor works
- [ ] "Küldés" button is disabled when template is empty
- [ ] Modal closes after sending
- [ ] Event is emitted with email template

### Sign All Contracts Modal
- [ ] Modal opens when clicking footer "Sign All Contracts"
- [ ] All contract previews are displayed
- [ ] Each contract has its own acceptance switch
- [ ] Each contract has its own signature pad
- [ ] Global privacy policy switch works
- [ ] Global email switch works
- [ ] Client email is shown in email switch label
- [ ] All signature pads work independently
- [ ] "Összes aláírása" button is disabled when:
  - [ ] Privacy policy not accepted
  - [ ] Any contract not accepted
  - [ ] Any signature is empty
- [ ] "Összes aláírása" button is enabled when all conditions met
- [ ] Modal closes after signing all
- [ ] Event is emitted with all signatures data

### SignaturePad Component
- [ ] Canvas is visible and sized correctly
- [ ] Placeholder text shows when empty
- [ ] Mouse drawing works smoothly
- [ ] Touch drawing works smoothly
- [ ] Drawing stays within canvas bounds
- [ ] "Törlés" button clears signature
- [ ] Signature is saved as data URL (PNG)
- [ ] isEmpty() method works correctly
- [ ] Signature persists when modal is kept open

### EmailTemplateEditor Component
- [ ] Toolbar is visible
- [ ] Bold button works
- [ ] Italic button works
- [ ] Underline button works
- [ ] List button works
- [ ] Link button works (prompts for URL and text)
- [ ] Text area is editable
- [ ] Placeholder documentation is visible
- [ ] v-model binding works correctly

### ContractPreview Component
- [ ] All sections are displayed
- [ ] Client data shows with correct fallback
- [ ] Address is formatted correctly
- [ ] Investments are listed with icons
- [ ] Components show quantity and prices
- [ ] Extra costs are displayed
- [ ] Discounts show in green
- [ ] Total price is prominent
- [ ] VAT and commission info is shown
- [ ] Notes section displays (or "Nincsenek megjegyzések")

### Data Loading
- [ ] Contracts load on mount
- [ ] Investments catalog loads
- [ ] Main components catalog loads
- [ ] Client data loads
- [ ] Loading state is shown during fetch
- [ ] Error state is handled gracefully
- [ ] Empty state shows when no contracts

### Footer Integration
- [ ] "Next" button is hidden on Summary tab
- [ ] "Save All and Send" button is visible
- [ ] "Sign All Contracts ({count})" button is visible
- [ ] Contract count is accurate
- [ ] Buttons trigger correct modals

### Responsive Design
- [ ] Works on mobile (320px+)
- [ ] Works on tablet (768px+)
- [ ] Works on desktop (1024px+)
- [ ] Card view adapts columns based on screen size
- [ ] Modals are scrollable on small screens
- [ ] Touch events work on mobile devices

---

## Related Documentation

- [Survey System Architecture](survey-system-architecture.md) - Overall system design
- [Contract Data Page](survey-contract-data-page.md) - Contract data entry
- [Contracts Store](../app/stores/contracts.ts) - State management

---

## Future Enhancements

### Planned Features
- [ ] PDF generation from contract preview
- [ ] Email template library (save/load templates)
- [ ] Email preview before sending
- [ ] Send confirmation messages
- [ ] Signature verification
- [ ] Contract status tracking (draft/sent/signed)
- [ ] Batch operations progress indicator
- [ ] Undo/redo for signature
- [ ] Multiple signature fields per contract
- [ ] QR code for mobile signing
- [ ] Export signed contracts as PDF
- [ ] Email delivery tracking
- [ ] Signature timestamp and IP logging

### Known Limitations
- Email sending is placeholder (not implemented)
- Signature storage is placeholder (not implemented)
- No email validation
- No signature image compression
- No offline mode for signing
- No signature verification/authentication

---

## Troubleshooting

### Issue: Signature doesn't work on touch device
**Solution:** Ensure `touch-action: none` is set on canvas element (already in component)

### Issue: Contract preview shows "N/A" for all fields
**Solution:** Check that client data is loaded and passed as prop to Summary component

### Issue: "Sign" button never enables
**Solution:** Check all three conditions:
1. Privacy policy switch is ON
2. Contract acceptance switch is ON
3. Signature pad has a signature (not empty)

### Issue: Email template placeholders not replaced
**Solution:** Placeholder replacement happens on backend (not yet implemented). This is expected behavior.

### Issue: Modal doesn't close after action
**Solution:** Ensure parent component is handling the emitted event and setting modal visibility to false

### Issue: Signature gets cut off or distorted
**Solution:** Canvas uses fixed dimensions (800×200). CSS scaling is handled by coordinate transformation.

### Issue: Can't scroll in modal on mobile
**Solution:** Modal content area has `overflow-y-auto` and `max-h-[90vh]`. Check that parent div isn't preventing scroll.

---

**Last Updated:** 2025-10-24
**Maintainer:** Development Team
**Status:** ✅ Complete
