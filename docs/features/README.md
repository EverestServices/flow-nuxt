# Feature Documentation

This directory contains detailed documentation for all implemented features in the Flow Nuxt application.

## Available Features

### 1. Survey Management

#### [Survey List Page](./SURVEY_LIST_PAGE.md)
- **Route:** `/survey`
- **Status:** ✅ Implemented
- **Description:** Main entry point for Energy Consultation workflow. Displays a filterable list of clients pending surveys with date filters and search functionality.
- **Key Features:**
  - Date filtering (Today, Yesterday, This Week, Last Week, Pending)
  - Real-time search across client data
  - Navigation to client profiles
  - New client creation button
  - Survey date/time display

#### [New Client Form Page](./NEW_CLIENT_FORM_PAGE.md)
- **Route:** `/survey/client-data`
- **Status:** ✅ Implemented
- **Description:** Comprehensive form for creating new client records with real-time map visualization.
- **Key Features:**
  - Two-column layout (form + map)
  - Real-time progress indicator
  - Google Maps integration with geocoding
  - Address autocomplete via map
  - Form validation
  - Supabase integration

### 2. Client Management

#### [Client Profile Page](./CLIENT_PROFILE_PAGE.md)
- **Route:** `/client/[clientId]`
- **Status:** ✅ Implemented (Basic Info tab only)
- **Description:** Detailed client information view with tabbed interface for different data aspects.
- **Key Features:**
  - Tabbed navigation (7 tabs)
  - Basic information display
  - Status tracking
  - Address management
  - Client notes
  - Back navigation

## Feature Status Overview

| Feature | Route | Status | Components |
|---------|-------|--------|------------|
| Survey List | `/survey` | ✅ Complete | 3 components |
| New Client Form | `/survey/client-data` | ✅ Complete | 2 components |
| Client Profile | `/client/[clientId]` | 🔄 Partial | 5 components |

**Legend:**
- ✅ Complete: Fully implemented and functional
- 🔄 Partial: Core functionality implemented, additional features pending
- 🚧 In Progress: Currently being developed
- 📋 Planned: Documented but not yet started

## Component Architecture

### Survey Module
```
app/pages/survey/
├── index.vue                    # Survey list page
└── client-data.vue              # New client form

app/components/Survey/
├── SurveyListItem.vue          # Individual survey item
└── SurveyDateFilterButtonGroup.vue  # Date filter buttons
```

### Client Module
```
app/pages/client/
└── [clientId].vue               # Client profile page

app/components/Client/
├── ClientHeader.vue             # Profile header with navigation
├── ClientTabs.vue               # Tab navigation
├── ClientBasicInfoTab.vue       # Basic info display
├── ClientPlaceholderTab.vue     # Placeholder for unimplemented tabs
└── AddressMap.vue               # Google Maps integration
```

## Database Integration

### Tables Used
- **clients** - Client personal and contact information
- **surveys** - Survey scheduling and status
- **user_profiles** - User company relationships

### Key Relationships
```
surveys → clients (many-to-one)
clients → user_profiles.company_id (many-to-one)
```

## API Integration

### Supabase
All features use Supabase for:
- Data persistence
- Real-time updates (future)
- Row Level Security (RLS)
- Authentication integration

### Google Maps
Client-data form uses Google Maps for:
- Address geocoding
- Location visualization
- Interactive marker placement

## Navigation Flow

```
/survey (Survey List)
  ├─→ /survey/client-data (New Client Form)
  │    └─→ Creates client → Returns to /survey
  │
  └─→ /client/[id]?from=survey (Client Profile)
       └─→ Back button → Returns to /survey
```

## Upcoming Features

### High Priority
- [ ] Survey form implementation
- [ ] Contract generation
- [ ] Email integration
- [ ] Client editing functionality

### Medium Priority
- [ ] Client history tab
- [ ] Document management
- [ ] Activity timeline
- [ ] Real-time notifications

### Low Priority
- [ ] Advanced search filters
- [ ] Bulk operations
- [ ] Data export
- [ ] Custom reporting

## Development Guidelines

### Adding New Features
1. Create feature documentation in this directory
2. Follow existing documentation template
3. Include route, components, and data structure
4. Add implementation status checklist
5. Link to related features

### Documentation Template
Each feature documentation should include:
- Overview and purpose
- Route and navigation
- Page structure and components
- Data structures and types
- API integration details
- Styling guidelines
- Implementation status
- Future enhancements
- Related files

## Resources

### Internal Documentation
- [Project Setup](../setup/README.md)
- [Database Schema](../database/README.md)
- [Component Guidelines](../components/README.md)

### External References
- [Nuxt 3 Documentation](https://nuxt.com)
- [Nuxt UI Documentation](https://ui.nuxt.com)
- [Supabase Documentation](https://supabase.com/docs)
- [Google Maps JavaScript API](https://developers.google.com/maps/documentation/javascript)

---

**Last Updated:** 2025-10-20
**Maintained By:** Development Team
