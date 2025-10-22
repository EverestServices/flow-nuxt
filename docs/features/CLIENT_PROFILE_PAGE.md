# Client Profile Page

## Overview
The Client Profile Page displays detailed information about a specific client, including personal data, contact information, addresses, and related activities. The page features a tabbed interface for organizing different aspects of client information.

## Route
- **Path:** `/client/[clientId]?from=survey`
- **Navigation:** Accessible from Survey List via "Client profile" button
- **Component:** `app/pages/client/[clientId].vue`

## Page Structure

### Header Component (`ClientHeader.vue`)
- **Client Name** - Displayed as main title
- **Company Name** - Displayed as subtitle (if available)
- **Back Button** - Icon-based navigation
  - Returns to `/survey` if `from=survey`
  - Otherwise navigates back in history
- **Edit Button** - Icon-based action (currently logs to console)

### Tab Navigation (`ClientTabs.vue`)
Horizontal scrollable tab bar with 7 tabs:

1. **Basic Info** (default) - Personal and contact information
2. **Surveys** - Client survey history (placeholder)
3. **Contracts** - Contract documents (placeholder)
4. **Projects** - Related projects (placeholder)
5. **Events** - Timeline of interactions (placeholder)
6. **Emails** - Email communication (placeholder)
7. **Logs** - Activity logs (placeholder)

### Content Area

#### Basic Info Tab (`ClientBasicInfoTab.vue`)
Two-column grid layout:

**Left Column - Personal Data:**
- Name
- Email
- Phone
- Company

**Right Column - Status Information:**
- Join Date - Formatted from `created_at`
- Status - Active/Inactive badge with color coding
  - Active: Green badge
  - Inactive: Gray badge
- Status Change Date - Formatted from `updated_at`
- Last Contact - Formatted from `updated_at`
- Next Action - Planned next step
- Days in Status - Calculated from `updated_at`
- Priority - High/Medium/Low with color-coded badge
  - High: Red
  - Medium: Orange
  - Low: Blue

**Addresses Section:**
- Type label (e.g., "Primary Address")
- Full address (postal_code + city + street + house_number)

**Notes Section:**
- Free-text notes about the client
- Default: "No notes available"

#### Placeholder Tabs (`ClientPlaceholderTab.vue`)
For unimplemented tabs (Surveys, Contracts, Projects, Events, Emails, Logs):
- Centered icon and message
- "Under Development" status
- Gray theme

## Data Structure

### Client Entity (from Supabase)
```typescript
interface Client {
  id: string
  company_id: string
  name: string
  email: string | null
  phone: string | null
  postal_code: string | null
  city: string | null
  street: string | null
  house_number: string | null
  company: string | null
  status: 'active' | 'inactive'
  notes: string | null
  created_at: string // ISO timestamp
  updated_at: string // ISO timestamp
}
```

### Transformed Client Data (for BasicInfoTab)
```typescript
interface ClientData {
  name: string
  email: string
  phone: string
  company: string
  joinDate: string // Formatted MM/DD/YYYY
  status: 'Active' | 'Inactive'
  statusChangeDate: string // Formatted MM/DD/YYYY
  lastContact: string // Formatted MM/DD/YYYY
  nextAction: string
  daysInStatus: number
  priority: 'High' | 'Medium' | 'Low'
  notes: string
}
```

### Address Data
```typescript
interface Address {
  type: string
  street: string // Combined address parts
  city: string
  country: string
}
```

## Components

### 1. Page Component
**File:** `app/pages/client/[clientId].vue`
- Fetches client data from Supabase
- Manages active tab state
- Handles navigation
- Computes transformed data for tabs

### 2. Header Component
**File:** `app/components/Client/ClientHeader.vue`
- Props: `clientName`, `companyName`
- Emits: `back`, `edit`
- Displays client name and action buttons

### 3. Tabs Component
**File:** `app/components/Client/ClientTabs.vue`
- Props: `modelValue` (active tab)
- Emits: `update:modelValue`
- Horizontal scrollable tab navigation

### 4. Basic Info Tab
**File:** `app/components/Client/ClientBasicInfoTab.vue`
- Props: `client` (ClientData), `addresses` (Address[])
- Two-column responsive grid
- Status badges with color coding
- Empty state handling

### 5. Placeholder Tab
**File:** `app/components/Client/ClientPlaceholderTab.vue`
- Props: `tabName` (string)
- Generic placeholder for unimplemented tabs

## API Integration

### Data Fetching
```typescript
// On component mount
const { data, error } = await supabase
  .from('clients')
  .select('*')
  .eq('id', clientId)
  .single()
```

### Computed Properties
- `clientData` - Transforms raw client data to display format
- `addresses` - Builds address array from client fields

## Styling

### Color Scheme
- **Active Status:** Green badge (`bg-green-100 text-green-800`)
- **Inactive Status:** Gray badge (`bg-gray-100 text-gray-800`)
- **High Priority:** Red badge
- **Medium Priority:** Orange badge
- **Low Priority:** Blue badge

### Layout
- Responsive grid: 1 column mobile, 2 columns desktop
- Consistent spacing with `gap-6`
- Card-based design with shadows
- Icon integration with Heroicons

### Typography
- Section titles: `text-lg font-semibold`
- Labels: `text-sm font-medium text-gray-600`
- Values: `text-base text-gray-900`

## Navigation Flow

### From Survey List
```
/survey → Click "Client profile" → /client/[id]?from=survey
```

### Back Navigation
```
/client/[id]?from=survey → Click back → /survey
/client/[id] → Click back → Browser history back
```

## Error Handling

### Loading State
- Displays loading spinner
- Shows "Loading..." text
- Centered in viewport

### Client Not Found
- Icon: User circle (gray)
- Message: "Client not found"
- Centered in viewport

## Implementation Notes

### Date Formatting
All dates use `toLocaleDateString('en-US')` with format:
```typescript
{
  year: 'numeric',
  month: '2-digit',
  day: '2-digit'
}
```

### Days Calculation
```typescript
Math.floor((Date.now() - new Date(updated_at).getTime()) / (1000 * 60 * 60 * 24))
```

### Address Building
```typescript
const parts = [postal_code, city, street, house_number].filter(Boolean)
const fullAddress = parts.join(', ')
```

## Future Enhancements

### Immediate
- [ ] Implement edit functionality
- [ ] Add real data for priority and next action
- [ ] Improve notes editing UI

### Medium Term
- [ ] Implement Surveys tab with survey history
- [ ] Implement Contracts tab with document management
- [ ] Implement Events tab with timeline
- [ ] Add real-time updates
- [ ] Client avatar/photo support

### Long Term
- [ ] Activity timeline
- [ ] Email integration
- [ ] Document attachments
- [ ] Custom fields
- [ ] Export client data
- [ ] Merge duplicate clients

## Related Files

### Components
- `app/pages/client/[clientId].vue`
- `app/components/Client/ClientHeader.vue`
- `app/components/Client/ClientTabs.vue`
- `app/components/Client/ClientBasicInfoTab.vue`
- `app/components/Client/ClientPlaceholderTab.vue`

### Related Pages
- `app/pages/survey/index.vue` - Survey list with navigation link
- `app/components/Survey/SurveyListItem.vue` - Contains "Client profile" button

### Database
- Table: `clients`
- Migration: `supabase/migrations/002_create_clients_table.sql`

## Implementation Status
- [x] Create page component with routing
- [x] Implement header component
- [x] Implement tab navigation
- [x] Create basic info tab
- [x] Create placeholder tabs
- [x] Connect to Supabase API
- [x] Add loading states
- [x] Add error states
- [x] Link from survey list
- [x] Implement back navigation
- [ ] Implement edit functionality
- [ ] Implement remaining tabs
- [ ] Add translations
- [ ] Add real-time updates

---

**Created:** 2025-10-20
**Source:** FlowFrontend `/app/client-profile.tsx`
**Route Parameter:** `clientId` (UUID)
**Query Parameter:** `from` (navigation source)
