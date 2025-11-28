# OFP → Flow Client Sync Edge Function

Supabase Edge Function that synchronizes client and survey data from OFP (Otthon Felújítási Program) to Flow.

## File Structure

```
integrations-client-sync/
├── index.ts         # Main Edge Function logic
├── mappings.ts      # Configuration and mapping data
└── README.md        # This file
```

## Files

### `index.ts`
Main Edge Function containing the abstract business logic:
- HTTP request handling and validation
- Authentication and authorization
- Client and survey creation
- Orchestration of prefill and planned investments

### `mappings.ts`
Configuration file containing all mapping data:
- **INVESTMENT_MAPPING**: Maps OFP prefillData keys to Flow investment persist_names
- **PLANNED_INVESTMENT_MAPPING**: Maps OFP planned investment names to Flow persist_names
- **DEBUG_FLOOR_AREA**: Debug mode configuration
- **FLOOR_AREA_QUESTION_IDS**: Question UUIDs for floor area fields

## API Endpoint

```
POST /functions/v1/integrations-client-sync
```

### Required Headers
- `X-API-Key`: OFP user's Flow API key
- `X-User-Email`: OFP user's email address
- `X-External-System`: Must be "OFP" or "EKR"
- `apikey`: Supabase anon key

### Request Body
```typescript
{
  externalClientId: string,        // OFP client UUID
  externalSurveyId?: string | null,// OFP survey UUID (optional)
  client: {
    name: string,
    email: string,
    phone?: string,
    postal_code?: string,
    city?: string,
    street?: string,
    house_number?: string,
    contact_person?: string,
    notes?: string
  },
  prefillData?: {
    basicData?: Record<string, any>,
    facadeInsulation?: Record<string, any>,
    heatPump?: Record<string, any>,
    [key: string]: Record<string, any> | undefined
  },
  plannedInvestments?: string[]    // OFP planned investment names
}
```

### Response
```typescript
{
  success: true,
  flowClientId: string,             // Flow client UUID
  flowSurveyId: string,             // Flow survey UUID
  surveyUrl: string                 // Direct link to Flow survey
}
```

## Features

### 1. Client Synchronization
- Creates new clients in Flow or links to existing clients
- Uses `ofp_client_id` field for matching
- Stores basic client information

### 2. Survey Creation
- Always creates a new survey in Flow
- Links to OFP survey via `ofp_survey_id`
- Generates shareable survey URL

### 3. Prefill Data Processing
- Automatically fills survey questions based on OFP data
- Supports multiple investment types (basicData, facadeInsulation, heatPump, etc.)
- Handles different data types (strings, numbers, booleans, arrays)
- Currently prefills ~27 fields across different investments

### 4. Planned Investments
- Automatically sets up which investments are planned for the survey
- Maps OFP investment names to Flow persist_names
- Always includes "basicData" investment

## Configuration

To modify mappings, edit `/mappings.ts`:

```typescript
// Add new investment type
export const INVESTMENT_MAPPING: Record<string, string> = {
  'newInvestment': 'newInvestmentPersistName',
  // ...
}

// Add new planned investment mapping
export const PLANNED_INVESTMENT_MAPPING: Record<string, string> = {
  'New Investment Name': 'newInvestmentPersistName',
  // ...
}
```

## Debugging

Set `DEBUG_FLOOR_AREA = true` in `mappings.ts` to enable detailed logging for floor area fields.

## Deployment

```bash
npx supabase functions deploy integrations-client-sync --no-verify-jwt
```

## Related Documentation

- [OFP Integration Prefill Documentation](../../../doc/FLOW_INTEGRATION_PREFILL.md) (in sherpa project)
- [External Integrations API](../../../docs/external-integrations.md)
