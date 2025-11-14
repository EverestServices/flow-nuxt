# Flow - External Integrations (OFP & EKR)

## Áttekintés

A Flow rendszer két másik Everest Services rendszerrel integrálódik:
- **OFP (Otthon Felújítási Program)** - Symfony 6.4 alapú CRM rendszer
- **EKR** - Nuxt/Supabase alapú B2B CRM és projekt management rendszer

Az integráció célja, hogy az OFP és EKR rendszerekből indított energetikai felmérések a Flow-ban készüljenek el, majd az eredmények automatikusan visszakerüljenek az eredeti rendszerbe.

---

## Architektúra

### Rendszerek Közötti Kapcsolat

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│      OFP        │         │      Flow       │         │      EKR        │
│   (Symfony)     │◄───────►│     (Nuxt)      │◄───────►│    (Nuxt)       │
│                 │         │                 │         │                 │
│  MySQL 8.0      │         │  Supabase PG    │         │  Supabase PG    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

### Kommunikáció Módja

- **Authentikáció**: User-specifikus, nem lejáró API kulcsok
- **Protokoll**: REST API (JSON)
- **Szinkronizáció**: Manual trigger, unidirectional workflows
- **API Key Formátum**:
  - OFP generálja → Flow: `flow_ofp_abc123...` (64 karakter hex)
  - EKR generálja → Flow: `flow_ekr_xyz789...` (64 karakter hex)
- **API Key Flow**:
  1. User generál API kulcsot OFP/EKR-ben
  2. OFP/EKR automatikusan regisztrálja a kulcsot Flow-ban
  3. User használja az API kulcsot Flow műveletek indításához

---

## Adatmodell

### Flow Adatbázis Változások

#### 1. Clients Tábla Bővítése

```sql
ALTER TABLE public.clients
ADD COLUMN ofp_client_id UUID,
ADD COLUMN ekr_client_id UUID;
```

**Cél**: Kétirányú kapcsolat a Flow és external rendszerek között.

| Mező | Típus | Leírás |
|------|-------|--------|
| `ofp_client_id` | UUID | OFP Client UUID referencia |
| `ekr_client_id` | UUID | EKR Client UUID referencia |

#### 2. Surveys Tábla Bővítése

```sql
ALTER TABLE public.surveys
ADD COLUMN ofp_survey_id UUID,
ADD COLUMN ekr_survey_id UUID;
```

**Cél**: Survey-k azonosítása az eredeti rendszerben.

| Mező | Típus | Leírás |
|------|-------|--------|
| `ofp_survey_id` | UUID | OFP Survey UUID (ha OFP-ből indult) |
| `ekr_survey_id` | UUID | EKR Survey UUID (ha EKR-ből indult) |

**Logika**:
- Ha `ofp_survey_id` != NULL → Survey OFP-ből érkezett
- Ha `ekr_survey_id` != NULL → Survey EKR-ből érkezett
- Ha mindkettő NULL → Natív Flow survey

#### 3. User External API Keys Tábla

```sql
CREATE TABLE public.user_external_api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    external_system VARCHAR(20) NOT NULL CHECK (external_system IN ('OFP', 'EKR')),
    api_key_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ,
    UNIQUE(user_id, external_system)
);
```

**Cél**: User-specifikus API kulcsok tárolása external rendszerekhez.

#### 4. External Sync Logs Tábla

```sql
CREATE TABLE public.external_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    external_system VARCHAR(20) NOT NULL CHECK (external_system IN ('OFP', 'EKR')),
    direction ENUM('incoming', 'outgoing') NOT NULL,
    status ENUM('pending', 'success', 'failed', 'partial') NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    request_payload JSONB,
    response_payload JSONB,
    error_message TEXT,
    http_status_code INTEGER,
    duration_ms INTEGER,
    user_id UUID REFERENCES auth.users(id)
);
```

**Cél**: Audit trail és hibaelhárítás minden szinkronizációs művelethez.

---

### OFP Adatbázis Változások

#### 1. Clients Tábla Bővítése

```sql
ALTER TABLE clients
ADD COLUMN flow_client_id CHAR(36) NULL,
ADD COLUMN flow_survey_id CHAR(36) NULL;
```

**PHP Entity** (`src/Clients/Entity/Client.php`):
```php
#[ORM\Column(type: 'guid', nullable: true)]
private ?string $flowClientId = null;

#[ORM\Column(type: 'guid', nullable: true)]
private ?string $flowSurveyId = null;
```

#### 2. Users Tábla Bővítése (API Key)

```sql
ALTER TABLE users
ADD COLUMN flow_api_key_hash VARCHAR(255) NULL,
ADD COLUMN flow_api_key_created_at DATETIME NULL,
ADD COLUMN flow_api_key_last_used_at DATETIME NULL;
```

**PHP Entity** (`src/Users/Entity/User.php`):
```php
#[ORM\Column(type: 'string', length: 255, nullable: true)]
private ?string $flowApiKeyHash = null;

#[ORM\Column(type: 'datetime', nullable: true)]
private ?\DateTimeInterface $flowApiKeyCreatedAt = null;

#[ORM\Column(type: 'datetime', nullable: true)]
private ?\DateTimeInterface $flowApiKeyLastUsedAt = null;
```

---

### EKR Adatbázis Változások

#### 1. Clients Tábla Bővítése

```sql
ALTER TABLE public.clients
ADD COLUMN flow_client_id UUID,
ADD COLUMN flow_survey_id UUID;
```

#### 2. Surveys Tábla Bővítése

```sql
ALTER TABLE public.surveys
ADD COLUMN flow_survey_id UUID;
```

#### 3. User Flow API Keys Tábla

```sql
CREATE TABLE public.user_flow_api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    api_key_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ,
    UNIQUE(user_id)
);
```

---

## API Végpontok

### Flow API Endpoints

#### 1. Register API Key

```http
POST /functions/v1/integrations-register-api-key
```

**Headers**:
```
Authorization: Bearer flow_ofp_abc123... vagy flow_ekr_xyz789...
X-User-Email: user@example.com
X-External-System: OFP | EKR
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "API key registered successfully",
  "userId": "user-uuid",
  "externalSystem": "OFP"
}
```

**Response (400 Bad Request)**:
```json
{
  "success": false,
  "error": "Invalid API key format. Expected prefix: flow_ofp_"
}
```

**Response (404 Not Found)**:
```json
{
  "success": false,
  "error": "User not found with email: user@example.com"
}
```

**Funkció**: OFP/EKR rendszer regisztrálja az API kulcsot a Flow-ban a user számára.

**Viselkedés**:
- Ha már létezik API kulcs a usernek az adott rendszerre → UPDATE
- Ha még nincs API kulcs → INSERT new record
- API kulcs hash (SHA-256) tárolása az `user_external_api_keys` táblában

---

#### 2. External Authentication

```http
POST /functions/v1/integrations/auth/login
```

**Headers**:
```
Authorization: Bearer flow_ofp_abc123... vagy flow_ekr_xyz789...
X-User-Email: user@example.com
X-External-System: OFP | EKR
X-Redirect-To: /survey/123 (optional)
```

**Response (200 OK)**:
```json
{
  "success": true,
  "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "redirectUrl": "https://flow.app/auth/external-callback?token=...&redirect=/survey/123"
}
```

**Response (401 Unauthorized)**:
```json
{
  "success": false,
  "error": "Invalid API key or email"
}
```

**Funkció**: External rendszerből érkező user bejelentkeztetése a Flow-ba.

---

#### 3. Client & Survey Sync (Incoming)

```http
POST /functions/v1/integrations/client/sync
```

**Headers**:
```
Authorization: Bearer flow_ofp_abc123...
X-User-Email: user@example.com
X-External-System: OFP | EKR
```

**Request Body**:
```json
{
  "externalClientId": "uuid",
  "externalSurveyId": "uuid",
  "client": {
    "name": "Kovács János",
    "email": "kovacs.janos@example.com",
    "phone": "+36301234567",
    "postal_code": "1234",
    "city": "Budapest",
    "street": "Fő utca",
    "house_number": "12",
    "contact_person": "Kovács János",
    "notes": "Lead source: Website form"
  }
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "flowClientId": "550e8400-e29b-41d4-a716-446655440000",
  "flowSurveyId": "660e8400-e29b-41d4-a716-446655440000",
  "surveyUrl": "https://flow.app/survey/660e8400-e29b-41d4-a716-446655440000"
}
```

**Funkció**:
1. Ellenőrzi, hogy létezik-e már a client (`ofp_client_id` vagy `ekr_client_id`)
2. Létrehozza vagy frissíti a clientet
3. Létrehoz egy új survey-t és beállítja az `ofp_survey_id` vagy `ekr_survey_id` mezőt
4. Visszaadja a Flow URL-t

---

#### 4. Survey Export (Outgoing)

```http
POST /functions/v1/integrations/survey/export
```

**Headers**:
```
Authorization: Bearer flow_ofp_abc123...
X-User-Email: user@example.com
```

**Request Body**:
```json
{
  "surveyId": "660e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "externalSystem": "OFP",
  "externalClientId": "550e8400-e29b-41d4-a716-446655440000",
  "externalSurveyId": "770e8400-e29b-41d4-a716-446655440000",
  "data": {
    "surveyAnswers": [
      {
        "questionName": "property_type",
        "questionLabel": "Ingatlan típusa",
        "answer": "house",
        "answerLabel": "Családi ház",
        "type": "dropdown"
      },
      {
        "questionName": "roof_area",
        "questionLabel": "Tetőfelület",
        "answer": 120,
        "unit": "m²",
        "type": "number"
      }
    ],
    "scenarioMainComponents": [
      {
        "persistName": "solar_panel_500w",
        "mainComponentName": "500W Napelem Panel",
        "mainComponentId": "uuid",
        "quantity": 20,
        "priceSnapshot": 150000,
        "unit": "db",
        "specifications": {
          "power": 500,
          "efficiency": 21.5,
          "manufacturer": "Suntech"
        }
      }
    ],
    "calculatedValues": {
      "totalInvestmentCost": 3000000,
      "estimatedAnnualSavings": 400000,
      "estimatedPaybackPeriod": 7.5,
      "totalPanelPower": 10000,
      "estimatedAnnualProduction": 12000,
      "co2Reduction": 6000
    }
  }
}
```

**Funkció**:
1. Ellenőrzi a survey tulajdonjogát (user csak saját survey-jét exportálhatja)
2. Azonosítja az external rendszert (`ofp_survey_id` vagy `ekr_survey_id`)
3. Összegyűjti az összes survey adatot
4. Elküldi az external rendszer API-jának
5. Naplózza a sync műveletet

---

### OFP API Endpoints

#### 1. Authentication & Login

```http
POST /everest-admin/flow-integration/api/auth/login
```

**Headers**:
```
Authorization: Bearer ofp_flow_abc123...
X-User-Email: user@example.com
X-External-System: FLOW
X-Redirect-To: /client/detail/123 (optional)
```

**Response (200 OK)**:
```json
{
  "success": true,
  "sessionToken": "symfony_session_token",
  "redirectUrl": "https://ofp.app/auth/external-callback?token=...&redirect=/client/detail/123"
}
```

**Symfony Controller** (`src/Clients/Controller/FlowIntegration/FlowIntegrationController.php`):
```php
#[Route('/everest-admin/flow-integration', name: 'flow_integration_')]
class FlowIntegrationController extends AbstractController
{
    #[Route('/api/auth/login', name: 'auth_login', methods: ['POST'])]
    public function login(Request $request): JsonResponse
    {
        // 1. Validate Bearer token
        // 2. Check users.flow_api_key_hash
        // 3. Create Symfony session
        // 4. Return session token + redirect URL
    }
}
```

---

#### 2. Survey Data Import

```http
POST /everest-admin/flow-integration/api/survey/import
```

**Headers**:
```
Authorization: Bearer ofp_flow_abc123...
```

**Request Body**:
```json
{
  "ofpClientId": "uuid",
  "ofpSurveyId": "uuid",
  "surveyData": {
    "surveyAnswers": [...],
    "scenarioMainComponents": [...],
    "calculatedValues": {...}
  }
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Survey data imported successfully",
  "processedAnswers": 25,
  "processedComponents": 15
}
```

**Funkció**:
1. Validálja az API key-t
2. Megkeresi a clientet `flow_client_id` alapján
3. Feldolgozza a survey válaszokat (JSONB mezőbe tárolás)
4. MainComponent-ek párosítása `persistName` alapján
5. Számított értékek tárolása
6. Client adatok frissítése

---

### EKR API Endpoints

#### 1. Authentication & Login

```typescript
// /app/server/api/integrations/auth/login.post.ts
export default defineEventHandler(async (event) => {
  // 1. Extract Bearer token
  // 2. Validate against user_flow_api_keys
  // 3. Create Supabase session
  // 4. Return session token + redirect URL
});
```

#### 2. Survey Data Import

```typescript
// /app/server/api/integrations/survey/import.post.ts
export default defineEventHandler(async (event) => {
  // 1. Validate API key
  // 2. Find client by flow_client_id
  // 3. Process survey data
  // 4. Store in survey_technical_data (JSONB)
  // 5. Match MainComponents by persistName
  // 6. Update calculated totals
});
```

---

## Munkafolyamatok (Workflows)

### Workflow 1: OFP/EKR → Flow (Survey Indítás)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. User az OFP/EKR-ben: "Create Survey in Flow" gomb                       │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  2. OFP/EKR Backend: Check if client already synced                         │
│     - If flow_client_id exists → use it                                     │
│     - If NOT → Call Flow API: POST /integrations/client/sync                │
│                Store returned flow_client_id and flow_survey_id             │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  3. OFP/EKR Backend: Generate SSO Link                                      │
│     - Get user's Flow API key (from DB)                                     │
│     - Call Flow: POST /integrations/auth/login                              │
│     - Get session token from Flow                                           │
│     - Build redirect URL: https://flow.app/auth/external-callback?token=... │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  4. OFP/EKR Frontend: Redirect user to Flow                                 │
│     - window.open(redirectUrl, '_blank')                                    │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  5. Flow Frontend: /auth/external-callback                                  │
│     - Set Supabase session cookie                                           │
│     - Redirect to /survey/{surveyId}                                        │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  6. User fills out survey in Flow                                           │
│     - Property Assessment page                                              │
│     - Technical Data page (MainComponents)                                  │
│     - Questions filtered by visible_for_sources                             │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  7. User clicks "Mentés és kilépés" (Save & Exit)                           │
│     - Flow saves survey to database                                         │
│     - If ofp_survey_id OR ekr_survey_id != NULL:                            │
│       → Call POST /integrations/survey/export                               │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  8. Flow Backend: Export survey data                                        │
│     - Collect all survey answers                                            │
│     - Collect all ScenarioMainComponents                                    │
│     - Calculate all metrics                                                 │
│     - Call OFP/EKR: POST /api/survey/import                                 │
│     - Log sync to external_sync_logs                                        │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
                                    ┌───────┴───────┐
                                    │               │
                           ┌────────▼────────┐ ┌───▼──────────┐
                           │  9a. Success    │ │  9b. Failed  │
                           │  - Toast        │ │  - Warning   │
                           │    success      │ │  - Log error │
                           └────────┬────────┘ └───┬──────────┘
                                    │               │
                                    └───────┬───────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  10. OFP/EKR Backend: Process imported survey data                          │
│      - Match MainComponents by persistName                                  │
│      - Store survey answers in JSONB field                                  │
│      - Store calculated values                                              │
│      - Update client record                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Workflow 2: Manual Retry (Ha Sync Sikertelen)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. User a Flow-ban: Survey detail page                                     │
│     - Látja a "Sync Failed" badge-t                                         │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  2. User clicks "Retry Sync" button                                         │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  3. Flow Frontend: Call POST /integrations/survey/export                    │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
┌───────────────────────────────────────────▼─────────────────────────────────┐
│  4. Flow Backend: Re-attempt export                                         │
│     - Same logic as initial export                                          │
│     - Update external_sync_logs with new attempt                            │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
                                    ┌───────┴───────┐
                                    │               │
                           ┌────────▼────────┐ ┌───▼──────────┐
                           │  5a. Success    │ │  5b. Failed  │
                           │  - Toast        │ │  - Error msg │
                           │  - Remove badge │ │  - Keep badge│
                           └─────────────────┘ └──────────────┘
```

---

## Frontend Változások

### 1. SurveyQuestion Láthatósági Logika

**Fájl**: `/app/composables/useSurveyQuestions.ts`

```typescript
export function useSurveyQuestions() {
  const survey = ref<Survey>();

  function isQuestionVisible(question: SurveyQuestion): boolean {
    if (!question.display_conditions) return true;

    const conditions = question.display_conditions;

    // Check external source visibility
    if (conditions.visible_for_sources && Array.isArray(conditions.visible_for_sources)) {
      const isOFPSurvey = !!survey.value?.ofp_survey_id;
      const isEKRSurvey = !!survey.value?.ekr_survey_id;
      const isNormalSurvey = !isOFPSurvey && !isEKRSurvey;

      if (isNormalSurvey) {
        // Normal Flow survey - evaluate field conditions only
        return evaluateFieldCondition(conditions);
      }

      // External survey - check if source is in list
      const shouldShowForOFP = isOFPSurvey && conditions.visible_for_sources.includes('OFP');
      const shouldShowForEKR = isEKRSurvey && conditions.visible_for_sources.includes('EKR');

      if (!shouldShowForOFP && !shouldShowForEKR) {
        return false; // Hide question
      }
    }

    // Check field-based conditions
    if (conditions.field) {
      return evaluateFieldCondition(conditions);
    }

    return true;
  }

  return { isQuestionVisible };
}
```

**display_conditions példák**:

```json
// 1. Csak OFP survey-kben jelenjen meg
{
  "visible_for_sources": ["OFP"]
}

// 2. OFP és EKR survey-kben is látható
{
  "visible_for_sources": ["OFP", "EKR"]
}

// 3. Field condition + source restriction
{
  "field": "heating_solution",
  "operator": "equals",
  "value": "heat_pump",
  "visible_for_sources": ["OFP"]
}

// 4. Nincs megadva - minden survey-ben látszik
{
  "field": "property_type",
  "operator": "equals",
  "value": "house"
}
```

---

### 2. Survey Footer - Auto Sync Logic

**Fájl**: `/app/components/SurveyFooter.vue`

```typescript
async function saveAndExit() {
  // 1. Save survey (existing logic)
  const { success } = await saveSurvey();

  if (!success) {
    toast.error('Failed to save survey');
    return;
  }

  // 2. Check if external survey
  const isExternalSurvey = survey.value.ofp_survey_id || survey.value.ekr_survey_id;

  if (isExternalSurvey) {
    try {
      // 3. Trigger sync
      const { data } = await $fetch('/api/integrations/survey/export', {
        method: 'POST',
        body: { surveyId: survey.value.id }
      });

      toast.success('Survey saved and synced successfully');
    } catch (error) {
      // 4. Log error but don't block exit
      console.error('Sync failed:', error);
      toast.warning('Survey saved, but sync failed. You can retry from survey details.');

      // Logged automatically to external_sync_logs table
    }
  } else {
    toast.success('Survey saved successfully');
  }

  // 5. Redirect
  await navigateTo('/clients');
}
```

---

### 3. Client Header - External Badges

**Fájl**: `/app/components/ClientHeader.vue`

```vue
<template>
  <div class="flex items-center justify-between mb-6">
    <div class="flex items-center gap-4">
      <h1 class="text-3xl font-bold">{{ client.name }}</h1>

      <!-- OFP Badge -->
      <UBadge
        v-if="client.ofp_client_id"
        color="blue"
        variant="subtle"
        class="flex items-center gap-1"
      >
        <Icon name="i-heroicons-link" class="w-4 h-4" />
        OFP Client
      </UBadge>

      <!-- EKR Badge -->
      <UBadge
        v-if="client.ekr_client_id"
        color="green"
        variant="subtle"
        class="flex items-center gap-1"
      >
        <Icon name="i-heroicons-link" class="w-4 h-4" />
        EKR Client
      </UBadge>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  client: Client
}>();
</script>
```

---

### 4. Survey Detail Page - Retry Sync Button

**Fájl**: `/app/pages/survey/[id].vue`

```vue
<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1>Survey Details</h1>

      <!-- Show sync status -->
      <div class="flex items-center gap-2">
        <UBadge
          v-if="lastSyncLog && lastSyncLog.status === 'failed'"
          color="red"
        >
          Sync Failed
        </UBadge>

        <UButton
          v-if="lastSyncLog && lastSyncLog.status === 'failed'"
          @click="retrySync"
          :loading="syncing"
          icon="i-heroicons-arrow-path"
          color="primary"
        >
          Retry Sync
        </UButton>
      </div>
    </div>

    <!-- Survey content... -->
  </div>
</template>

<script setup lang="ts">
const route = useRoute();
const surveyId = route.params.id;

const { data: survey } = await useFetch(`/api/surveys/${surveyId}`);
const { data: lastSyncLog } = await useFetch(`/api/integrations/sync-logs/last`, {
  query: { surveyId }
});

const syncing = ref(false);

async function retrySync() {
  syncing.value = true;

  try {
    await $fetch('/api/integrations/survey/export', {
      method: 'POST',
      body: { surveyId: survey.value.id }
    });

    toast.success('Sync successful!');

    // Refresh sync log
    await refreshNuxtData('lastSyncLog');
  } catch (error) {
    toast.error('Sync failed. Please contact IT support.');
  } finally {
    syncing.value = false;
  }
}
</script>
```

---

## Environment Variables

### Flow (.env)

```env
# Public URLs
NUXT_PUBLIC_OFP_BASE_URL=localhost:8080
NUXT_PUBLIC_EKR_BASE_URL=localhost:3001

# API Keys (for Flow calling external systems - if needed later)
# OFP_API_KEY=...
# EKR_API_KEY=...
```

### OFP (.env)

```env
# Flow integration
FLOW_BASE_URL=localhost:3000
```

### EKR (.env)

```env
# Public Flow URL
NUXT_PUBLIC_FLOW_BASE_URL=localhost:3000
```

---

## MainComponent Matching

### Stratégia

MainComponent-ek párosítása **`persistName` alapján** történik mindhárom rendszerben.

**Példák**:
- `solar_panel_500w`
- `heat_pump_air_water_8kw`
- `insulation_facade_15cm`
- `inverter_hybrid_10kw`

### Ha Nincs Találat

Ha az OFP/EKR-ben nincs olyan termék, aminek a `persistName`-je megegyezik:

**Stratégia A (Implementált)**:
```php
// OFP
foreach ($components as $component) {
    $product = $this->productRepository->findOneBy([
        'persistName' => $component['persistName']
    ]);

    if (!$product) {
        $this->logger->warning('Product not found in OFP', [
            'persistName' => $component['persistName'],
            'flowName' => $component['mainComponentName']
        ]);
        continue; // Skip this component
    }

    // Process component...
}
```

**Jövőbeli Bővítés** (ha szükséges):
- Mapping tábla létrehozása: `flow_ofp_product_mapping`
- Auto-create missing products from Flow data

---

## Calculated Values - Exportált Mezők

A Flow a következő számított értékeket küldi vissza az OFP/EKR-nek:

| Mező | Típus | Leírás | Egység |
|------|-------|--------|--------|
| `totalInvestmentCost` | number | Teljes beruházási költség | HUF |
| `estimatedAnnualSavings` | number | Becsült éves megtakarítás | HUF/év |
| `estimatedPaybackPeriod` | number | Becsült megtérülési idő | év |
| `totalPanelPower` | number (optional) | Összes panel teljesítmény (ha van napelem) | W |
| `estimatedAnnualProduction` | number (optional) | Becsült éves termelés (ha van napelem) | kWh/év |
| `co2Reduction` | number (optional) | CO2 kibocsátás csökkentés | kg/év |

**Tárolás OFP-ben**:
```php
// Client entity - új JSONB mező
#[ORM\Column(type: 'json', nullable: true)]
private ?array $flowCalculatedValues = null;
```

**Tárolás EKR-ben**:
```sql
-- surveys table - új JSONB mező
ALTER TABLE public.surveys
ADD COLUMN flow_calculated_values JSONB;
```

---

## Biztonsági Megfontolások

### API Key Management

1. **Generálás**: Crypto-secure random (32+ karakter)
2. **Tárolás**: SHA-256 hash (nem plain text)
3. **Továbbítás**: HTTPS Bearer token
4. **Érvényesség**: Nem jár le (de user bármikor regenerálhatja)
5. **Visszavonás**: `is_active = false` flag

### API Rate Limiting

- **External auth endpoints**: 10 request / perc / IP
- **Sync endpoints**: 100 request / perc / user
- **DoS védelem**: Cloudflare / nginx rate limit

### Data Validation

- **Minden input**: JSON schema validation
- **SQL injection**: Prepared statements (ORM)
- **XSS**: Sanitize external strings
- **JSONB fields**: Type validation

---

## Hibaelhárítás

### Sync Failed Esetek

#### 1. Network Error

**Tünet**: `external_sync_logs.status = 'failed'`, `http_status_code = NULL`

**Megoldás**:
1. Ellenőrizd a Flow internet kapcsolatát
2. Ping-eld az OFP/EKR szervert
3. Ellenőrizd a tűzfal szabályokat
4. Retry sync manually

#### 2. Invalid API Key

**Tünet**: `http_status_code = 401`, `error_message = 'Invalid API key'`

**Megoldás**:
1. Ellenőrizd, hogy a user létrehozta-e az API key-t
2. Ellenőrizd, hogy az `is_active = true`
3. Regeneráld az API key-t

#### 3. Product Not Found

**Tünet**: `http_status_code = 200`, de `processedComponents < total components`

**Megoldás**:
1. Nézd meg az OFP/EKR log-okat
2. Ellenőrizd a `persistName` egyezést
3. Hozd létre a hiányzó termékeket az external rendszerben
4. Retry sync

#### 4. Timeout

**Tünet**: `duration_ms > 30000`, `status = 'failed'`

**Megoldás**:
1. Növeld az API timeout-ot (default: 30s → 60s)
2. Ellenőrizd az external rendszer teljesítményét
3. Optimalizáld a survey data payload-ot (redukálj unnecessary fields)

---

## Audit & Logging

### external_sync_logs Tábla

Minden szinkronizációs kísérlet naplózva van:

```sql
SELECT
  external_system,
  direction,
  status,
  entity_type,
  created_at,
  duration_ms,
  error_message
FROM external_sync_logs
WHERE user_id = 'current_user_uuid'
ORDER BY created_at DESC
LIMIT 50;
```

### Log Mezők

- `request_payload`: Teljes request body (JSON)
- `response_payload`: Teljes response body (JSON)
- `error_message`: Human-readable error (ha van)
- `http_status_code`: HTTP response code
- `duration_ms`: Request idő milliszekundumban

### Monitoring Dashboard (Jövőbeli)

- Success rate (%)
- Average sync duration
- Failed syncs by error type
- Top syncing users

---

## Implementációs Fázisok

### ✅ Fázis 1: Flow Alapok (1 hét)
- Database migrations
- API Key validáció middleware
- External auth endpoint
- Sync logs tábla

### ⏳ Fázis 2: OFP Integráció (1-2 hét)
- OFP database migrations
- Symfony entities + repositories
- FlowIntegrationController
- OFP Frontend: "Create Survey in Flow" button

### ⏳ Fázis 3: Flow Client Sync (1 hét)
- Client sync endpoint
- Survey auto-creation
- Frontend: Client badges
- Sync logging

### ⏳ Fázis 4: Flow Survey Export (1-2 hét)
- Survey export endpoint
- Data collection logic
- Webhook calling
- Error handling

### ⏳ Fázis 5: EKR Integráció (1 hét)
- EKR database migrations
- Nuxt server routes
- EKR Frontend: "Create Survey in Flow" button

### ⏳ Fázis 6: Display Conditions (3-5 nap)
- Frontend visibility logic
- Seed example questions

### ⏳ Fázis 7: Testing & Documentation (1 hét)
- E2E tests
- API documentation (OpenAPI)
- User guides

---

## Jövőbeli Bővítések

### 1. Bidirectional Links
- Flow → OFP/EKR direct navigation
- User stores external system API keys in Flow

### 2. Real-time Sync
- Webhook notifications
- WebSocket updates
- Background job queues

### 3. Product Auto-Import
- Ha `persistName` nem találat → auto-create product
- Flow product catalog export API

### 4. Advanced Mapping
- `flow_ofp_product_mapping` table
- Manual mapping UI
- Bulk import/export

### 5. Analytics Dashboard
- Sync statistics
- Performance metrics
- Error trends

---

## Kapcsolódó Dokumentumok

- [Survey System Architecture](./survey-system-architecture.md)
- [Energy Calculations - Functional](./energy-calculations-functional.md)
- [Energy Calculations - Technical](./energy-calculations-technical.md)
- OFP Projekt: `/home/ricsi/Projects/sherpa`
- EKR Projekt: `/home/ricsi/Projects/ekr-nuxt`
- EKR Database Schema: `/home/ricsi/Projects/ekr-nuxt/docs/DATABASE_SCHEMA.md`

---

**Verzió**: 1.0
**Utolsó frissítés**: 2025-11-06
**Szerző**: Claude (Anthropic)
**Státusz**: Draft - Implementálás előtt
