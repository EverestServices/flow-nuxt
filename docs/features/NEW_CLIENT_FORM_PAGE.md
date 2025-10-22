# New Client Form Page

## Overview
The New Client Form Page provides a comprehensive interface for creating new client records with address information and real-time map visualization. The page features a two-column layout with the form on the left and an interactive Google Maps view on the right.

## Route
- **Path:** `/survey/client-data`
- **Navigation:** Accessible from Survey List via "Energy Consultation for new Client" button
- **Component:** `app/pages/survey/client-data.vue`

## Page Structure

### Header
- **Title:** "New Client - Energy Consultation"
- **Close Button (X)** - Returns to `/survey`

### Two-Column Layout

#### Left Column - Form Section
**Progress Indicator:**
- Dynamic progress bar showing completion percentage
- Icon: Check circle (blue background)
- Title: Changes based on completion
  - < 100%: "Creating New Client"
  - 100%: "All Data Filled!"
- Description: Shows percentage and guidance
- Animated progress bar with primary color

**Personal Information Section:**
- Section icon: User icon (white on primary background)
- Section title: "Personal Information"
- Fields:
  1. **Name*** (required)
     - Icon: User
     - Placeholder: "Enter client name"
     - Size: Large
  2. **Email** (optional)
     - Icon: Envelope
     - Type: email
     - Placeholder: "Enter email address"
     - Size: Large
  3. **Phone** (optional)
     - Icon: Phone
     - Type: tel
     - Placeholder: "Enter phone number"
     - Size: Large

**Address Information Section:**
- Section icon: Map pin icon (white on primary background)
- Section title: "Address Information"
- Fields:
  1. **Postal Code*** (required) - 1/3 width
     - Icon: Hashtag
     - Placeholder: "1234"
     - Size: Large
  2. **City*** (required) - 2/3 width
     - Icon: Building office
     - Placeholder: "Enter city"
     - Size: Large
  3. **Street*** (required) - 2/3 width
     - Icon: Map
     - Placeholder: "Enter street name"
     - Size: Large
  4. **House Number*** (required) - 1/3 width
     - Icon: Home
     - Placeholder: "123"
     - Size: Large

**Action Buttons:**
- **Cancel** - Gray outline button, navigates to `/survey`
- **Save and Start Consultation** - Primary button with bolt icon
  - Disabled when form is invalid
  - Creates client in database
  - Navigates to `/survey` on success

#### Right Column - Map Section
**Map Header:**
- Gradient background (blue-600 to blue-500)
- Icon: Map icon (white)
- Title: "Location on Map"

**Google Maps Integration:**
- Interactive map with satellite/roadmap toggle
- Draggable marker
- Real-time geocoding based on address input
- Dynamic zoom levels:
  - Postal code only: Zoom 14
  - Postal code + city: Zoom 14
  - Full address with street: Zoom 16
  - Full address with house number: Zoom 18
- Initial center: Budapest (47.497912, 19.040235)
- Info window showing current address

## Data Structure

### Form Data
```typescript
interface FormData {
  name: string
  email: string
  phone: string
  postalCode: string
  city: string
  street: string
  houseNumber: string
}
```

### Required Fields
Array of field names used for validation:
```typescript
const requiredFields = ['name', 'postalCode', 'city', 'street', 'houseNumber']
```

### Database Insert
```typescript
interface ClientInsert {
  company_id: string // From user profile
  name: string
  email: string | null
  phone: string | null
  postal_code: string
  city: string
  street: string
  house_number: string
  status: 'active'
}
```

## Components

### 1. Page Component
**File:** `app/pages/survey/client-data.vue`
- Manages form state
- Calculates progress percentage
- Validates required fields
- Handles Supabase insertion
- Builds full address for map

### 2. Address Map Component
**File:** `app/components/Client/AddressMap.vue`
- Props: `address` (string)
- Google Maps integration
- Dynamic script loading
- Geocoding service
- Draggable marker
- Map type controls (satellite/roadmap)

## Validation Logic

### Progress Calculation
```typescript
const progressPercentage = computed(() => {
  const requiredFields = ['name', 'postalCode', 'city', 'street', 'houseNumber']
  const filledFields = requiredFields.filter(field => {
    const value = form.value[field]
    return value && value.trim() !== ''
  })
  return (filledFields.length / requiredFields.length) * 100
})
```

### Form Validation
```typescript
const isFormValid = computed(() => {
  return form.value.name.trim() &&
         form.value.postalCode.trim() &&
         form.value.city.trim() &&
         form.value.street.trim() &&
         form.value.houseNumber.trim()
})
```

### Full Address Building
```typescript
const fullAddress = computed(() => {
  const parts = [
    form.value.postalCode,
    form.value.city,
    form.value.street,
    form.value.houseNumber
  ].filter(part => part && part.trim() !== '')
  return parts.join(' ')
})
```

## API Integration

### Environment Variables
```bash
NUXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_api_key_here
```

### Runtime Configuration
```typescript
// nuxt.config.ts
runtimeConfig: {
  public: {
    googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY
  }
}
```

### Supabase Operations

#### Get User's Company ID
```typescript
const { data: profile } = await supabase
  .from('user_profiles')
  .select('company_id')
  .single()
```

#### Insert New Client
```typescript
const { data: newClient, error } = await supabase
  .from('clients')
  .insert({
    company_id: profile.company_id,
    name: form.value.name.trim(),
    email: form.value.email.trim() || null,
    phone: form.value.phone.trim() || null,
    postal_code: form.value.postalCode.trim(),
    city: form.value.city.trim(),
    street: form.value.street.trim(),
    house_number: form.value.houseNumber.trim(),
    status: 'active'
  })
  .select()
  .single()
```

## Google Maps Integration

### Map Initialization
```typescript
const initMap = () => {
  map.value = new google.maps.Map(mapContainer.value, {
    center: { lat: 47.497912, lng: 19.040235 },
    zoom: 13,
    mapTypeId: 'satellite',
    mapTypeControl: true,
    mapTypeControlOptions: {
      style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
      position: google.maps.ControlPosition.TOP_RIGHT,
      mapTypeIds: ['roadmap', 'satellite']
    }
  })
}
```

### Geocoding
```typescript
const geocodeAddress = async (address: string) => {
  return new Promise((resolve) => {
    geocoder.value.geocode({ address }, (results, status) => {
      if (status === 'OK' && results && results.length > 0) {
        const location = results[0].geometry.location
        resolve({
          lat: location.lat(),
          lng: location.lng()
        })
      }
    })
  })
}
```

### Dynamic Zoom Adjustment
```typescript
if (props.address.match(/\d+$/)) {
  // Has house number - zoom closer
  map.value.setZoom(18)
} else if (props.address.includes(',')) {
  // Has street - medium zoom
  map.value.setZoom(16)
} else {
  // Only postal code/city - wider zoom
  map.value.setZoom(14)
}
```

### Interactive Features
- **Marker Dragging:** Enabled for manual position adjustment
- **Map Click:** Updates marker position
- **Reverse Geocoding:** Shows address for clicked/dragged position
- **Info Window:** Displays current address as popup

## Styling

### Layout
- **Equal Width Columns:** Both form and map use `flex-1`
- **Full Width Inputs:** All input containers have `w-full` class
- **Responsive Padding:** `p-6` on form container
- **Overflow Handling:** `overflow-y-auto` on form to enable scrolling

### Custom Styles
```css
/* Make UInput wrapper full width */
:deep(.relative.inline-flex) {
  display: flex !important;
  width: 100%;
}
```

### Progress Bar
- Container: Blue gradient background with rounded corners
- Bar: Primary-500 color with smooth transition
- Height: 2rem (h-2)

### Field Layout
- Personal info: Full-width, stacked vertically
- Postal Code + City: Flex row with 1/3 and 2/3 width
- Street + House Number: Flex row with 2/3 and 1/3 width
- Gap between fields: 1rem (gap-4)

### Labels
- Required fields: Red asterisk (*)
- Font: `text-sm font-medium`
- Color: `text-gray-700 dark:text-gray-300`
- Margin: `mb-2`

## User Experience

### Real-time Updates
- Progress bar updates instantly as fields are filled
- Map updates dynamically as address is typed
- Submit button enables/disables based on validation

### Visual Feedback
- Progress percentage shown in header
- Completion message changes at 100%
- Disabled button has reduced opacity
- Loading states during map initialization

### Navigation Flow
```
/survey → Click "New Client"
  → /survey/client-data → Fill form
  → Click "Save and Start"
  → /survey (with new client in list)
```

## Error Handling

### Supabase Errors
```typescript
try {
  // Insert client
} catch (error) {
  console.error('Error creating client:', error)
  // User sees console error (TODO: add user-facing error message)
}
```

### Map Loading Errors
```typescript
script.onerror = () => {
  console.error('Failed to load Google Maps')
  reject(new Error('Failed to load Google Maps'))
}
```

### Validation
- Submit button disabled when form invalid
- Required fields marked with red asterisk
- Empty company_id prevents submission

## Configuration

### Google Maps API Key Setup

#### Development (No restrictions)
1. Create API key in Google Cloud Console
2. Set Application restrictions to "None"
3. Add to `.env` file
4. Restart dev server

#### Production (With restrictions)
1. Set Application restrictions to "HTTP referrers"
2. Add authorized domains
3. Use environment-specific keys

### Required Google APIs
- **Maps JavaScript API** - For map display
- **Geocoding API** - For address to coordinates conversion

## Future Enhancements

### Immediate
- [ ] Add user-facing error messages (toasts/notifications)
- [ ] Navigate to survey page with new client selected
- [ ] Add form reset functionality
- [ ] Validation error messages per field

### Medium Term
- [ ] Save marker position if manually adjusted
- [ ] Add "Reset marker to address" button
- [ ] Support for multiple addresses per client
- [ ] Client photo/avatar upload
- [ ] Autocomplete for address fields
- [ ] Country selection for international addresses

### Long Term
- [ ] Import clients from CSV
- [ ] Duplicate client detection
- [ ] Batch client creation
- [ ] Custom fields configuration
- [ ] Integration with external address databases

## Related Files

### Components
- `app/pages/survey/client-data.vue` - Main form page
- `app/components/Client/AddressMap.vue` - Google Maps component

### Configuration
- `nuxt.config.ts` - Runtime config for API key
- `.env` - Environment variables

### Related Pages
- `app/pages/survey/index.vue` - Survey list with navigation button

### Database
- Table: `clients`
- Table: `user_profiles` (for company_id)
- Migration: `supabase/migrations/002_create_clients_table.sql`

## Implementation Status
- [x] Create page component
- [x] Implement form with validation
- [x] Add progress indicator
- [x] Create address map component
- [x] Integrate Google Maps
- [x] Implement geocoding
- [x] Connect to Supabase API
- [x] Add equal-width column layout
- [x] Make inputs full-width
- [x] Link from survey list
- [ ] Add error notifications
- [ ] Add success notifications
- [ ] Implement marker position saving
- [ ] Navigate to survey with new client
- [ ] Add translations
- [ ] Add form reset

## Technical Notes

### Google Maps Script Loading
- Dynamically loaded via `loadGoogleMaps()` function
- Checks if already loaded to avoid duplicates
- Uses Promise for async initialization
- Script added to `<head>` element

### Address Format
Input format: `[postal_code] [city] [street] [house_number]`
Example: `1234 Budapest Fő utca 10`

### Nuxt UI Components
- `UDashboardPage` - Page wrapper
- `UDashboardPanel` - Content panel
- `UDashboardNavbar` - Top navigation bar
- `UInput` - Form input fields
- `UButton` - Action buttons
- `UIcon` - Icon components

---

**Created:** 2025-10-20
**Source:** FlowFrontend `/app/survey/new-client.tsx` and `/components/NewClientForm.tsx`
**Google Maps:** Satellite view with roadmap toggle
**Default Location:** Budapest, Hungary (47.497912, 19.040235)
