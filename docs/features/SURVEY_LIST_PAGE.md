# Survey List Page (Clients Pending Survey)

## Overview
The Survey List Page is the main entry point for the Energy Consultation workflow. It displays a list of surveys/clients filtered by date and search criteria.

## Route
- **Path:** `/survey`
- **Menu Item:** "Summit / Energy Consultation"
- **Component:** `app/pages/survey/index.vue`

## Page Structure

### Header
- **Title:** "Clients pending survey" (`survey.clientsPendingSurvey`)

### Filter Bar (Row 2)
Left side - Date Filter Button Group:
- **Today** - Shows surveys with `at` date = today
- **Yesterday** - Shows surveys with `at` date = yesterday
- **This week** - Shows surveys with `at` date in current week
- **Last week** - Shows surveys with `at` date in last week
- **Pending** - Shows surveys without completed contracts

Right side - Search & New Client:
- **Search field** - Free text search with placeholder "Search clients..." (`survey.searchPlaceholder`)
  - Searches in: client name, email, phone, address, survey date
- **New Client Button** - "Energy Consultation for new Client" (`survey.newClientConsultation`)
  - Icon: Zap (lucide-vue-next)
  - Action: Navigate to new client survey (inactive for now)

### Survey List
Each survey item displays 3 rows:

**Row 1 - Name & Date:**
- Left: Client name
- Right: Survey date with label "Survey date:" (`survey.surveyDate`)
  - Format: Formatted date/time

**Row 2 - Contact Info:**
- Client address
- Client email
- Client phone number
- All displayed in a single line, truncated with ellipsis if too long

**Row 3 - Actions (right-aligned):**
- **Client Profile Button:** "Client profile" (`survey.clientProfile`)
  - Style: Secondary/outline button
  - Action: Navigate to client profile (inactive for now)
- **Start Consultation Button:** "Start Energy Consultation" (`survey.startConsultation`)
  - Style: Primary button with Zap icon
  - Action: Navigate to survey form (inactive for now)

## Data Structure

### Survey Entity
```typescript
interface Survey {
  id: string
  client_id: string
  at: string // ISO date string
  // ... other fields
}
```

### Client Entity (from relationship)
```typescript
interface Client {
  id: string
  name: string
  email: string | null
  phone: string | null
  postal_code: string | null
  city: string | null
  street: string | null
  house_number: string | null
}
```

## Filtering Logic

### Date Filters
- **Today:** `at` date is same day as current date
- **Yesterday:** `at` date is 1 day before current date
- **This Week:** `at` date is in current week (Monday-Sunday)
- **Last Week:** `at` date is in last week (Monday-Sunday)
- **Pending:** Surveys without completed/sent contracts

### Search Filter
Free text search matches against:
- Client name (case-insensitive)
- Client email (case-insensitive)
- Client phone (case-insensitive)
- Client full address (postal_code + city + street + house_number)
- Survey `at` date (formatted)

## API Integration

### Composable: `useSurveys()`
```typescript
const {
  surveys,
  loading,
  fetchSurveysWithFilters
} = useSurveys()
```

### Query Structure
```typescript
// Fetch surveys with client relationships
const { data: surveys } = await supabase
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
  .order('at', { ascending: false })
```

## Translations

### English (en)
```json
{
  "survey": {
    "clientsPendingSurvey": "Clients pending survey",
    "searchPlaceholder": "Search clients...",
    "newClientConsultation": "Energy Consultation for new Client",
    "surveyDate": "Survey date:",
    "clientProfile": "Client profile",
    "startConsultation": "Start Energy Consultation",
    "continueConsultation": "Continue Energy Consultation",
    "noClientsFound": "No clients found",
    "noClientsFoundForFilter": "No clients found for selected filter"
  }
}
```

### Hungarian (hu)
```json
{
  "survey": {
    "clientsPendingSurvey": "Felmérésre váró ügyfelek",
    "searchPlaceholder": "Ügyfelek keresése...",
    "newClientConsultation": "Energiatanácsadás új ügyfélnek",
    "surveyDate": "Felmérés dátuma:",
    "clientProfile": "Ügyfél adatlap",
    "startConsultation": "Felmérés kezdése",
    "continueConsultation": "Felmérés folytatása",
    "noClientsFound": "Nem található ügyfél",
    "noClientsFoundForFilter": "Nincs ügyfél a kiválasztott szűrőhöz"
  }
}
```

## Components to Create

1. **Page Component:** `app/pages/survey/index.vue`
2. **Date Filter Component:** `app/components/Survey/SurveyDateFilterButtonGroup.vue`
3. **Survey List Item Component:** `app/components/Survey/SurveyListItem.vue`

## State Management
- Selected date filter (default: 'today')
- Search query string
- Loading state
- Filtered surveys list (computed)

## Styling Notes
- Use UnoCSS utility classes
- Follow existing color scheme (Colors.light)
- Responsive layout (mobile-first)
- Consistent spacing with other list views
- Button styles match existing patterns

## Future Enhancements
- Real-time updates when surveys change
- Pagination for large lists
- Export filtered list
- Bulk actions
- Advanced filters (by client type, status, etc.)

## Related Files
- Migration: `supabase/migrations/003_create_survey_system.sql`
- Composable: `app/composables/useSurveys.ts`
- Types: `app/types/survey-new.ts`

## Implementation Status
- [x] Create page component
- [x] Create date filter component
- [x] Create survey list item component
- [ ] Add translations (English hardcoded for now)
- [x] Connect to backend API
- [x] Implement date filtering
- [x] Implement search filtering
- [x] Add empty states
- [x] Add loading states
- [x] Update menu navigation

---

**Created:** 2025-10-17
**Source:** FlowFrontend `/app/(tabs)/surveyClientSelection.tsx`
