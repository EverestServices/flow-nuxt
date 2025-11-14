# Survey Contract Data Page - Functional Documentation

**Version:** 1.0.0
**Last Updated:** 2025-10-24
**Related Migrations:** 003, 068, 069, 070

---

## Table of Contents

1. [Overview](#overview)
2. [Database Schema](#database-schema)
3. [Component Hierarchy](#component-hierarchy)
4. [Key Features](#key-features)
5. [State Management](#state-management)
6. [User Flows](#user-flows)
7. [Technical Implementation](#technical-implementation)
8. [Testing Checklist](#testing-checklist)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The **Contract Data** page (Tab 4) is where users enter client personal information and contract-specific data for one or more contracts. This page allows users to:

- Select up to 3 contracts simultaneously for data entry
- Enter client contact information (name, address, phone, email)
- Enter personal details required for contracts (birth place, ID numbers, tax ID, etc.)
- Copy data between contracts to avoid redundant data entry
- Automatically populate fields with Survey Client data as defaults

### Purpose

The Contract Data page serves as a centralized interface for collecting all personal and legal information needed to generate formal contract documents. It bridges the gap between technical contract details (from the Offer/Contract page) and the personal information required for legal documentation.

### Key Design Principles

1. **Efficiency**: Multi-contract editing allows users to work on multiple contracts simultaneously
2. **Smart Defaults**: Automatically pre-fills fields with Survey Client data
3. **Data Reuse**: Copy functionality prevents duplicate data entry
4. **Auto-Save**: Changes are automatically saved after 1 second of inactivity
5. **Responsive Layout**: Adapts to 1, 2, or 3 selected contracts

---

## Database Schema

### Contracts Table - Client Data Fields

The `contracts` table stores both technical and personal data. The following fields are managed on the Contract Data page:

```sql
-- From migration 004_create_survey_system.sql and 068_update_contracts_table.sql
CREATE TABLE public.contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID REFERENCES public.surveys(id) ON DELETE SET NULL,

    -- Contract metadata (managed on Offer/Contract page)
    name VARCHAR(255) NOT NULL DEFAULT 'Contract 1',
    scenario_id UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,
    contract_mode VARCHAR(20) NOT NULL DEFAULT 'offer',
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    commission_rate DECIMAL(5, 4) NOT NULL DEFAULT 0.12,
    vat INTEGER NOT NULL DEFAULT 27,
    total_price DECIMAL(12, 2) DEFAULT 0,
    roof_configuration JSONB,
    notes TEXT,

    -- Client Data (managed on Contract Data page)
    client_name VARCHAR(255),
    client_address VARCHAR(500),
    client_phone VARCHAR(50),
    client_email VARCHAR(255),

    -- Personal Details (managed on Contract Data page)
    birth_place VARCHAR(255),
    date_of_birth DATE,
    id_card_number VARCHAR(50),
    tax_id VARCHAR(50),
    mother_birth_name VARCHAR(255),
    bank_account_number VARCHAR(100),
    citizenship VARCHAR(100),
    marital_status VARCHAR(50),
    residence_card_number VARCHAR(50),
    mailing_address VARCHAR(500)
);
```

### Field Descriptions

#### Client Data Section

| Field | Type | Description | Auto-Populated From |
|-------|------|-------------|---------------------|
| `client_name` | VARCHAR(255) | Full name of the client | `clients.name` |
| `client_address` | VARCHAR(500) | Full address of the client | Concatenated from `clients.postal_code`, `city`, `street`, `house_number` |
| `client_phone` | VARCHAR(50) | Phone number | `clients.phone` |
| `client_email` | VARCHAR(255) | Email address | `clients.email` |

#### Personal Details Section

| Field | Type | Description | Auto-Populated From |
|-------|------|-------------|---------------------|
| `birth_place` | VARCHAR(255) | Place of birth | None (manually entered) |
| `date_of_birth` | DATE | Date of birth | None (manually entered) |
| `id_card_number` | VARCHAR(50) | ID card or passport number | None (manually entered) |
| `tax_id` | VARCHAR(50) | Tax identification number | None (manually entered) |
| `mother_birth_name` | VARCHAR(255) | Mother's maiden name | None (manually entered) |
| `bank_account_number` | VARCHAR(100) | Bank account for payments | None (manually entered) |
| `citizenship` | VARCHAR(100) | Citizenship/nationality | None (manually entered) |
| `marital_status` | VARCHAR(50) | Marital status | None (manually entered) |
| `residence_card_number` | VARCHAR(50) | Residence permit number | None (manually entered) |
| `mailing_address` | VARCHAR(500) | Mailing address if different | None (manually entered) |

---

## Component Hierarchy

```
[surveyId].vue (Main Page)
└── SurveyContractData.vue
    ├── Contract Selection Buttons (max 3)
    │   ├── Contract Name + Scenario Name
    │   ├── Investment Icons
    │   └── Total Price
    └── Contract Cards (1-3 cards based on selection)
        ├── Card Header (Contract Name)
        ├── Client Data Section
        │   ├── Copy To Buttons
        │   ├── Name Input
        │   ├── Address Input
        │   ├── Phone Input
        │   └── Email Input
        └── Personal Details Section
            ├── Copy To Buttons
            ├── Birth Place Input
            ├── Date of Birth Input
            ├── ID Card Number Input
            ├── Tax ID Input
            ├── Mother's Name Input
            ├── Bank Account Number Input
            ├── Citizenship Input
            ├── Marital Status Input
            ├── Residence Card Number Input
            └── Mailing Address Input
```

---

## Key Features

### 1. Contract Selection (Maximum 3)

**Purpose**: Allow users to work on multiple contracts simultaneously while maintaining UI clarity.

**Behavior**:
- Users can select up to 3 contracts
- Contract buttons are sorted by `created_at` (earliest first, left to right)
- Selected contracts show with primary blue background
- Unselected contracts show with gray background
- Once 3 contracts are selected, remaining buttons are disabled

**Button Layout**:
```
┌─────────────────────────────────────────────────┐
│ Contract Name              Scenario Name        │
│ [icon] [icon] [icon]       1,234,567 Ft        │
└─────────────────────────────────────────────────┘
```

**Implementation Details**:
- Contracts are sorted using `created_at` field
- Selection state is tracked in `selectedContractIds` array
- Cards are displayed in selection order, not creation order
- First contract is auto-selected on page load

### 2. Smart Default Population

**Purpose**: Reduce data entry by automatically filling fields with Survey Client data.

**Auto-Population Logic**:

When a contract is first selected:

1. **Check if contract already has data** → Use contract data
2. **If contract is empty** → Use Survey Client data as defaults

**Address Concatenation**:
```typescript
const clientAddress = [
  clientData.postal_code,
  clientData.city,
  clientData.street,
  clientData.house_number
].filter(Boolean).join(', ')
```

**Example**:
```
Survey Client Data:
  - name: "John Doe"
  - postal_code: "1234"
  - city: "Budapest"
  - street: "Fő utca"
  - house_number: "42"
  - phone: "+36 30 123 4567"
  - email: "john@example.com"

Auto-Populated Contract Data:
  - client_name: "John Doe"
  - client_address: "1234, Budapest, Fő utca, 42"
  - client_phone: "+36 30 123 4567"
  - client_email: "john@example.com"
```

### 3. Client Data Section

**Fields**:
- Name (text)
- Address (text)
- Phone (text)
- Email (email type)

**Features**:
- Full-width input fields
- Auto-populated from Survey Client data
- "Copy to:" buttons for other selected contracts
- Auto-save after 1 second of inactivity

### 4. Personal Details Section

**Fields**:
- Birth Place (text)
- Date of Birth (date picker)
- ID Card Number (text)
- Tax ID (text)
- Mother's Name (text)
- Bank Account Number (text)
- Citizenship (text)
- Marital Status (text)
- Residence Card Number (text)
- Mailing Address (text)

**Features**:
- Full-width input fields
- Initially empty (not auto-populated)
- "Copy to:" buttons for other selected contracts
- Auto-save after 1 second of inactivity

### 5. Copy Functionality

**Purpose**: Quickly duplicate data between contracts to avoid redundant entry.

**Two Copy Scopes**:
1. **Copy Client Data**: Copies Name, Address, Phone, Email
2. **Copy Personal Details**: Copies all 10 personal detail fields

**UI Elements**:
- Located in section headers next to "Copy to:" label
- One button per other selected contract
- Button label shows full contract name (e.g., "Contract 1", "Contract 2")
- Clicking triggers immediate copy and auto-save

**Implementation**:
```typescript
// Copy Client Data
copyClientData(fromId, toId) {
  contractsData[toId].client_name = contractsData[fromId].client_name
  contractsData[toId].client_address = contractsData[fromId].client_address
  contractsData[toId].client_phone = contractsData[fromId].client_phone
  contractsData[toId].client_email = contractsData[fromId].client_email
  saveContractData(toId)
}

// Copy Personal Details
copyPersonalDetails(fromId, toId) {
  contractsData[toId].birth_place = contractsData[fromId].birth_place
  contractsData[toId].date_of_birth = contractsData[fromId].date_of_birth
  // ... all 10 fields
  saveContractData(toId)
}
```

### 6. Auto-Save

**Purpose**: Eliminate the need for manual save buttons and prevent data loss.

**Behavior**:
- Triggered on every field change (`@update:model-value`)
- Debounced with 1-second delay
- Each contract has independent save timer
- Previous timer is cleared on new changes
- Saves directly to database via store action

**Implementation**:
```typescript
const saveTimers = ref<Record<string, NodeJS.Timeout>>({})

const handleFieldUpdate = (contractId: string) => {
  // Clear existing timer
  if (saveTimers.value[contractId]) {
    clearTimeout(saveTimers.value[contractId])
  }

  // Set new timer for auto-save (1 second delay)
  saveTimers.value[contractId] = setTimeout(async () => {
    await saveContractData(contractId)
  }, 1000)
}
```

**Database Update**:
```typescript
await contractsStore.updateContract(contractId, {
  client_name: data.client_name,
  client_address: data.client_address,
  // ... all fields
})
```

---

## State Management

### Pinia Store: `useContractsStore`

**State**:
```typescript
{
  contracts: Contract[]           // All contracts for this survey
  activeContractId: string | null // Currently active contract (not used on this page)
  contractInvestments: Record<string, string[]>
  // ... other fields
}
```

**Key Actions**:
- `loadContracts(surveyId)`: Load all contracts
- `updateContract(contractId, data)`: Update contract fields
- `renameContract(contractId, newName)`: Rename contract
- `duplicateContract(contractId)`: Create copy of contract
- `deleteContract(contractId)`: Delete contract

**Updated Interface (Migration 068)**:
```typescript
interface Contract {
  id: string
  name: string
  scenario_id?: string | null
  survey_id?: string | null
  contract_mode: 'offer' | 'contract'
  status: 'draft' | 'sent' | 'accepted' | 'rejected'
  commission_rate: number
  vat: number
  total_price: number
  roof_configuration?: any
  notes?: string
  // Client Data
  client_name?: string | null
  client_address?: string | null
  client_phone?: string | null
  client_email?: string | null
  // Personal Details
  birth_place?: string | null
  date_of_birth?: string | null
  id_card_number?: string | null
  tax_id?: string | null
  mother_birth_name?: string | null
  bank_account_number?: string | null
  citizenship?: string | null
  marital_status?: string | null
  residence_card_number?: string | null
  mailing_address?: string | null
  created_at: string
  updated_at: string
}
```

### Component Local State

**SurveyContractData.vue**:
```typescript
// Selected contracts (max 3)
const selectedContractIds = ref<string[]>([])

// Contract data for each selected contract
const contractsData = ref<Record<string, any>>({})

// Debounce timers for auto-save
const saveTimers = ref<Record<string, NodeJS.Timeout>>({})
```

**Props**:
```typescript
interface Props {
  surveyId: string
  clientData?: any  // Survey client data for auto-population
}
```

---

## User Flows

### Flow 1: First Time Entering Contract Data

**Scenario**: User has created contracts on Offer/Contract page and now needs to add client information.

**Steps**:

1. User navigates to **Contract Data** tab
2. System automatically selects first contract (sorted by creation date)
3. Contract card appears with **Client Data** pre-filled from Survey Client:
   - Name: "John Doe"
   - Address: "1234, Budapest, Fő utca, 42"
   - Phone: "+36 30 123 4567"
   - Email: "john@example.com"
4. **Personal Details** section is empty
5. User fills in Personal Details:
   - Birth Place: "Budapest"
   - Date of Birth: "1985-05-15"
   - ID Card Number: "123456AB"
   - Tax ID: "1234567890"
   - Mother's Name: "Jane Doe"
   - Bank Account Number: "12345678-12345678"
   - Citizenship: "Hungarian"
   - Marital Status: "Married"
   - (optional fields left empty)
6. Each field auto-saves 1 second after typing stops
7. User moves to next tab

**Result**: Contract has complete client and personal information stored in database.

---

### Flow 2: Working with Multiple Contracts

**Scenario**: User needs to enter data for 3 different contracts with mostly similar client information.

**Steps**:

1. User navigates to **Contract Data** tab
2. First contract (Contract 1) is auto-selected
3. User clicks **Contract 2** button → Second card appears
4. User clicks **Contract 3** button → Third card appears
5. All three cards show Client Data pre-filled from Survey Client
6. User edits **Contract 1** Client Data:
   - Changes name to "John Doe Sr."
7. User clicks **"Copy to: Contract 2"** button in Client Data section of Contract 1
8. Contract 2's Client Data updates immediately with Contract 1's data
9. User fills Personal Details in **Contract 1**
10. User clicks **"Copy to: Contract 2"** and **"Copy to: Contract 3"** in Personal Details section
11. Both Contract 2 and Contract 3 receive the same Personal Details
12. User makes minor adjustments to Contract 2 and Contract 3 as needed
13. All changes auto-save

**Result**: Three contracts with mostly identical data, with minimal manual entry.

---

### Flow 3: Editing Existing Contract Data

**Scenario**: User needs to update phone number for a contract that already has data.

**Steps**:

1. User navigates to **Contract Data** tab
2. System auto-selects first contract
3. User clicks on desired contract button (e.g., Contract 3)
4. Contract 3 card appears with existing data:
   - Name: "John Doe"
   - Address: "1234, Budapest, Fő utca, 42"
   - Phone: "+36 30 123 4567" ← old number
   - Email: "john@example.com"
5. User clicks in Phone field
6. User updates phone: "+36 20 987 6543"
7. After 1 second of inactivity, change auto-saves
8. Console shows: "Contract [id] data saved successfully"

**Result**: Contract has updated phone number in database.

---

### Flow 4: Deselecting a Contract

**Scenario**: User selected wrong contract and wants to deselect it.

**Steps**:

1. User has 3 contracts selected
2. User clicks on already-selected contract button (e.g., Contract 2)
3. Contract 2 button becomes unselected (gray background)
4. Contract 2 card disappears from the grid
5. Remaining 2 cards expand to fill the space
6. Any unsaved changes in Contract 2 are lost (last auto-save is retained)

**Result**: Contract 2 is deselected but data remains in database from last auto-save.

---

## Technical Implementation

### Component Structure

**File**: `/app/components/Survey/SurveyContractData.vue`

**Key Functions**:

```typescript
// Toggle contract selection
const toggleContractSelection = (contractId: string) => {
  if (isSelected) {
    // Deselect
    selectedContractIds.value = selectedContractIds.value.filter(id => id !== contractId)
  } else if (selectedContractIds.value.length < 3) {
    // Select (if under limit)
    selectedContractIds.value.push(contractId)
    initializeContractData(contractId)
  }
}

// Initialize contract data with defaults
const initializeContractData = (contractId: string) => {
  const contract = contracts.value.find(c => c.id === contractId)

  // Build address from client data
  const clientAddress = [
    clientData?.postal_code,
    clientData?.city,
    clientData?.street,
    clientData?.house_number
  ].filter(Boolean).join(', ')

  contractsData.value[contractId] = {
    // Use existing contract data or fallback to Survey Client data
    client_name: contract.client_name || clientData?.name || '',
    client_address: contract.client_address || clientAddress || '',
    client_phone: contract.client_phone || clientData?.phone || '',
    client_email: contract.client_email || clientData?.email || '',
    // Personal details (no defaults)
    birth_place: contract.birth_place || '',
    date_of_birth: contract.date_of_birth || '',
    // ... rest of fields
  }
}

// Copy Client Data between contracts
const copyClientData = (fromId: string, toId: string) => {
  const fromData = contractsData.value[fromId]
  contractsData.value[toId].client_name = fromData.client_name
  contractsData.value[toId].client_address = fromData.client_address
  contractsData.value[toId].client_phone = fromData.client_phone
  contractsData.value[toId].client_email = fromData.client_email
  handleFieldUpdate(toId)
}

// Copy Personal Details between contracts
const copyPersonalDetails = (fromId: string, toId: string) => {
  const fromData = contractsData.value[fromId]
  contractsData.value[toId].birth_place = fromData.birth_place
  contractsData.value[toId].date_of_birth = fromData.date_of_birth
  contractsData.value[toId].id_card_number = fromData.id_card_number
  contractsData.value[toId].tax_id = fromData.tax_id
  contractsData.value[toId].mother_birth_name = fromData.mother_birth_name
  contractsData.value[toId].bank_account_number = fromData.bank_account_number
  contractsData.value[toId].citizenship = fromData.citizenship
  contractsData.value[toId].marital_status = fromData.marital_status
  contractsData.value[toId].residence_card_number = fromData.residence_card_number
  contractsData.value[toId].mailing_address = fromData.mailing_address
  handleFieldUpdate(toId)
}

// Auto-save with debounce
const handleFieldUpdate = (contractId: string) => {
  if (saveTimers.value[contractId]) {
    clearTimeout(saveTimers.value[contractId])
  }

  saveTimers.value[contractId] = setTimeout(async () => {
    await saveContractData(contractId)
  }, 1000)
}

// Save to database
const saveContractData = async (contractId: string) => {
  const data = contractsData.value[contractId]

  await contractsStore.updateContract(contractId, {
    client_name: data.client_name,
    client_address: data.client_address,
    client_phone: data.client_phone,
    client_email: data.client_email,
    birth_place: data.birth_place,
    date_of_birth: data.date_of_birth,
    id_card_number: data.id_card_number,
    tax_id: data.tax_id,
    mother_birth_name: data.mother_birth_name,
    bank_account_number: data.bank_account_number,
    citizenship: data.citizenship,
    marital_status: data.marital_status,
    residence_card_number: data.residence_card_number,
    mailing_address: data.mailing_address
  })
}
```

### Contract Sorting

**Implementation**:
```typescript
// Sort contracts by created_at (earliest first)
const contracts = computed(() => {
  return [...contractsStore.contracts].sort((a, b) => {
    return new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  })
})
```

**Display Order**:
- **Selection buttons**: Sorted by `created_at` (earliest → latest)
- **Contract cards**: Sorted by selection order (not creation order)

### Responsive Grid Layout

**CSS Grid**:
```vue
<div class="grid gap-6" :class="{
  'grid-cols-1': selectedContracts.length === 1,
  'grid-cols-2': selectedContracts.length === 2,
  'grid-cols-3': selectedContracts.length === 3
}">
```

**Behavior**:
- 1 selected → Full width card
- 2 selected → Two columns
- 3 selected → Three columns

---

## Testing Checklist

### Contract Selection

- [ ] First contract is auto-selected on page load
- [ ] Can select up to 3 contracts
- [ ] Cannot select more than 3 contracts (buttons disabled)
- [ ] Can deselect contracts by clicking again
- [ ] Contracts are sorted by creation date (earliest first)
- [ ] Investment icons display correctly
- [ ] Total price displays correctly
- [ ] Scenario name displays correctly

### Data Auto-Population

- [ ] Client Data pre-fills from Survey Client on first selection
- [ ] Name field matches `clients.name`
- [ ] Address field is correctly concatenated from postal_code, city, street, house_number
- [ ] Phone field matches `clients.phone`
- [ ] Email field matches `clients.email`
- [ ] Personal Details fields are initially empty
- [ ] If contract already has data, it takes priority over Survey Client data

### Data Entry

- [ ] All input fields are full-width
- [ ] Can type in all fields
- [ ] Date picker works for Date of Birth
- [ ] Email field validates email format
- [ ] Changes trigger auto-save after 1 second
- [ ] Multiple rapid changes only trigger one save (debouncing works)

### Copy Functionality

- [ ] "Copy to:" buttons appear when 2+ contracts selected
- [ ] "Copy to:" buttons show correct contract names
- [ ] Clicking "Copy Client Data" copies all 4 client fields
- [ ] Clicking "Copy Personal Details" copies all 10 personal fields
- [ ] Copy triggers immediate auto-save
- [ ] Can copy from any contract to any other contract

### Auto-Save

- [ ] Changes save after 1 second of inactivity
- [ ] Console logs "Contract [id] data saved successfully"
- [ ] Saved data persists after page refresh
- [ ] Each contract has independent save timer
- [ ] Rapid changes don't cause multiple saves

### Responsive Layout

- [ ] 1 selected contract → 1 column layout
- [ ] 2 selected contracts → 2 column layout
- [ ] 3 selected contracts → 3 column layout
- [ ] Cards maintain equal width
- [ ] Layout adjusts when contracts are added/removed

### Edge Cases

- [ ] Works with no contracts (shows "No contracts available" message)
- [ ] Works with no Survey Client data (fields are empty)
- [ ] Works when Survey Client has partial data
- [ ] Handles null/undefined values gracefully
- [ ] Deselecting contract doesn't lose last saved data

---

## Troubleshooting

### Issue: Contract Data Not Auto-Populating

**Symptoms**:
- Fields are empty when selecting a new contract
- Expected Survey Client data is not showing

**Possible Causes**:
1. Survey Client data not loaded yet
2. `clientData` prop is null or undefined
3. Contract already has empty strings stored (not null)

**Solution**:
```typescript
// Check if clientData is available in parent component
console.log('Client Data:', clientData.value)

// Check if contract has existing data
const contract = contractsStore.contracts.find(c => c.id === contractId)
console.log('Contract Data:', contract)

// Ensure fallback chain works
const name = contract.client_name || clientData?.name || ''
```

---

### Issue: Auto-Save Not Working

**Symptoms**:
- Changes not persisting after page refresh
- No console log showing save confirmation
- Fields revert to old values

**Possible Causes**:
1. Debounce timer not triggering
2. Store action failing silently
3. Database permissions issue

**Solution**:
```typescript
// Add more logging
const handleFieldUpdate = (contractId: string) => {
  console.log('Field updated for contract:', contractId)

  if (saveTimers.value[contractId]) {
    clearTimeout(saveTimers.value[contractId])
  }

  saveTimers.value[contractId] = setTimeout(async () => {
    console.log('Attempting to save contract:', contractId)
    await saveContractData(contractId)
  }, 1000)
}

const saveContractData = async (contractId: string) => {
  try {
    const data = contractsData.value[contractId]
    console.log('Saving data:', data)

    await contractsStore.updateContract(contractId, { ...data })
    console.log(`Contract ${contractId} data saved successfully`)
  } catch (error) {
    console.error(`Error saving contract ${contractId} data:`, error)
  }
}
```

---

### Issue: Copy Function Not Working

**Symptoms**:
- Clicking "Copy to:" button has no effect
- Data doesn't transfer between contracts

**Possible Causes**:
1. Contract data not initialized
2. Wrong contract ID being passed
3. Auto-save not triggered after copy

**Solution**:
```typescript
// Add logging to copy functions
const copyClientData = (fromId: string, toId: string) => {
  console.log('Copying client data from', fromId, 'to', toId)

  const fromData = contractsData.value[fromId]
  if (!fromData) {
    console.error('Source contract data not found:', fromId)
    return
  }

  const toData = contractsData.value[toId]
  if (!toData) {
    console.error('Target contract data not found:', toId)
    return
  }

  contractsData.value[toId].client_name = fromData.client_name
  contractsData.value[toId].client_address = fromData.client_address
  contractsData.value[toId].client_phone = fromData.client_phone
  contractsData.value[toId].client_email = fromData.client_email

  console.log('Copy complete, triggering save')
  handleFieldUpdate(toId)
}
```

---

### Issue: Contracts Not Sorted Correctly

**Symptoms**:
- Contracts appear in wrong order
- Newest contracts appear first instead of last

**Possible Causes**:
1. `created_at` field missing or incorrect
2. Timezone issues with date comparison
3. Sort function reversed

**Solution**:
```typescript
// Check created_at values
console.log('Contracts:', contracts.value.map(c => ({
  name: c.name,
  created_at: c.created_at,
  timestamp: new Date(c.created_at).getTime()
})))

// Ensure correct sort order (ascending)
const contracts = computed(() => {
  return [...contractsStore.contracts].sort((a, b) => {
    return new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  })
})
```

---

### Issue: Too Many Contracts Can Be Selected

**Symptoms**:
- Can select more than 3 contracts
- UI doesn't disable buttons after 3 selections

**Possible Causes**:
1. Selection logic not checking limit
2. `selectedContractIds` not updating correctly

**Solution**:
```typescript
const toggleContractSelection = (contractId: string) => {
  const index = selectedContractIds.value.indexOf(contractId)

  if (index > -1) {
    // Deselect
    selectedContractIds.value.splice(index, 1)
  } else {
    // Check limit before selecting
    if (selectedContractIds.value.length >= 3) {
      console.warn('Cannot select more than 3 contracts')
      return
    }
    selectedContractIds.value.push(contractId)
    // ... initialize data
  }
}

// Ensure button is disabled
:disabled="!isContractSelected(contract.id) && selectedContractIds.length >= 3"
```

---

## Related Documentation

- [Survey System Architecture](./survey-system-architecture.md) - Overall system design
- [Survey Offer/Contract Page](./survey-offer-contract-page.md) - Related contract management features
- [Migration 003](../supabase/migrations/004_create_survey_system.sql) - Initial contracts table
- [Migration 068](../supabase/migrations/068_update_contracts_table.sql) - Contract metadata fields
- [Migration 070](../supabase/migrations/070_add_investment_id_to_pivot_tables.sql) - Investment-specific tracking

---

**Document Status**: Complete
**Reviewed By**: Development Team
**Next Review Date**: When Contract Data features are updated
