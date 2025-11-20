# Survey System Migration Summary

**Date:** 2025-10-17
**Status:** ✅ Complete

---

## What Was Created

### 1. Database Structure (Migration 003)

Created complete relational database for survey system:

#### Core Tables (15)
- `surveys` - Main survey entity
- `investments` - Investment types catalog
- `electric_cars` - Electric vehicle tracking
- `heavy_consumers` - Heavy energy consumer catalog
- `scenarios` - Investment scenarios
- `contracts` - Contract data
- `extra_costs` - Additional cost catalog
- `survey_pages` - Survey form pages
- `survey_questions` - Dynamic questions
- `survey_answers` - User answers
- `document_categories` - Photo/document categories
- `documents` - Uploaded files

#### Junction Tables (7)
- `survey_investments` - Survey ↔ Investment
- `survey_heavy_consumers` - Survey ↔ Heavy Consumer (with status)
- `scenario_investments` - Scenario ↔ Investment
- `contract_investments` - Contract ↔ Investment
- `extra_cost_relations` - (Scenario OR Contract) ↔ Extra Cost
- `investment_document_categories` - Investment ↔ Document Category
- `survey_survey_pages` - Survey ↔ Survey Page

#### Client Table Modification
- Replaced `address` TEXT with structured fields:
  - `postal_code` VARCHAR(20)
  - `city` VARCHAR(100)
  - `street` VARCHAR(255)
  - `house_number` VARCHAR(50)

### 2. TypeScript Types (`/app/types/survey-new.ts`)

Created comprehensive type system:
- ✅ All entity interfaces
- ✅ Enums (ElectricCarStatus, SurveyQuestionType, etc.)
- ✅ Extended types with relations
- ✅ Insert/Update types
- ✅ Form types
- ✅ API response types

### 3. Composables (6 Files)

| Composable | Purpose | Key Methods |
|------------|---------|-------------|
| `useSurveys()` | Survey CRUD | create, update, delete, fetch with relations |
| `useInvestments()` | Investment catalog | fetch all, fetch by ID, get document categories |
| `useSurveyAnswers()` | Questions & Answers | save answers, get completion %, fetch pages |
| `useDocuments()` | Photo uploads | upload to Storage, delete, track progress |
| `useScenarios()` | Scenarios | create, link investments & costs |
| `useContracts()` | Contracts | create, update, link investments & costs |

### 4. Seed Data (Migration 004)

Prepared seed script with data from FlowFrontend project:
- 9 Investment types
- 6 Heavy consumers (sauna, jacuzzi, poolHeating, cryptoMining, heatPump, electricHeating)
- 26 Document categories with `persist_name` (from photoUploadConfig.ts)
- Survey pages for all 9 investment types (Solar Panel, Solar Panel + Battery, Heat Pump, Facade Insulation, Roof Insulation, Windows, Air Conditioner, Battery, Car Charger)
- 50+ Survey questions across all investment types
- 18 Extra costs with `persist_name` (from ExtraCostsPanel.tsx)
- Investment ↔ Category links

### 5. Add persist_name and survey_pages Columns (Migration 005)

Required migration to add programmatic string identifiers and survey features:
- Adds `persist_name VARCHAR(255) UNIQUE` to `document_categories` table
- Adds `persist_name VARCHAR(255) UNIQUE` to `extra_costs` table
- Adds `investment_id`, `allow_multiple`, `allow_delete_first`, `item_name_template` to `survey_pages` table
- Must be run **before** migration 004 (seed data) to ensure data can be inserted
- Allows programmatic access to categories and costs by string identifier alongside UUID

### 6. Documentation

Created comprehensive docs:
- `survey-system-architecture.md` - Full system reference
- `SEED_SURVEY_DATA.md` - Seeding guide
- `MIGRATION_SUMMARY.md` - This file

---

## Migration Steps (How to Apply)

**⚠️ Important:** Migrations must be run in the correct order: 003 → 005 → 004

### Step 1: Run Database Migration (Create Tables)

**Option A - Supabase Dashboard:**
1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `supabase/migrations/004_create_survey_system.sql`
3. Click Run
4. ✅ Tables created

**Option B - Supabase CLI:**
```bash
npx supabase db push
```

### Step 2: Add persist_name and survey_pages Columns

**Option A - Supabase Dashboard:**
1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `supabase/migrations/007_fix_document_categories_extra_costs_ids.sql`
3. Click Run
4. ✅ persist_name and survey_pages columns added

**Option B - Supabase CLI:**
```bash
npx supabase db push
```

### Step 3: Seed Base Data

**Option A - SQL (Recommended):**
1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `supabase/migrations/004_seed_survey_base_data.sql`
3. Click Run
4. ✅ Data seeded

**Option B - TypeScript:**
```bash
npm run seed:survey
```
(Note: This only seeds Investments, Heavy Consumers, Document Categories, Extra Costs. Survey Pages/Questions must use SQL.)

### Step 4: Create Storage Bucket

```sql
-- Create storage bucket for documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('survey-documents', 'survey-documents', true);

-- Set up storage policies
CREATE POLICY "Authenticated users can upload survey documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'survey-documents');

CREATE POLICY "Anyone can view survey documents"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'survey-documents');

CREATE POLICY "Authenticated users can delete their survey documents"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'survey-documents');
```

### Step 5: Verify

Run verification queries:
```sql
SELECT COUNT(*) FROM investments;  -- 9
SELECT COUNT(*) FROM heavy_consumers;  -- 6
SELECT COUNT(*) FROM document_categories;  -- 26
SELECT COUNT(*) FROM survey_pages;  -- 27 (across all investment types)
SELECT COUNT(*) FROM survey_questions;  -- 50+
SELECT COUNT(*) FROM extra_costs;  -- 18
SELECT COUNT(*) FROM investment_document_categories;  -- ~50+ links
```

---

## Usage Examples

### Example 1: Create Survey

```typescript
import { useSurveys } from '~/composables/useSurveys'

const { createSurvey } = useSurveys()

const survey = await createSurvey({
  client_id: 'client-uuid',
  at: '2025-10-17',
  investments: ['solar-panel-uuid', 'heat-pump-uuid'],
  electric_cars: [
    { annual_mileage: 15000, status: 'existing' }
  ],
  heavy_consumers: [
    { id: 'pool-pump-uuid', status: 'existing' }
  ],
  answers: {
    'question-uuid-1': 'Answer 1',
    'question-uuid-2': 'Answer 2'
  }
})
```

### Example 2: Upload Document

```typescript
import { useDocuments } from '~/composables/useDocuments'

const { addDocument } = useDocuments()

const file = // ... File from input
await addDocument(
  'survey-uuid',
  'roof-photos-category-uuid',
  file,
  'Roof photo 1.jpg'
)
```

### Example 3: Create Scenario

```typescript
import { useScenarios } from '~/composables/useScenarios'

const { createScenario } = useScenarios()

await createScenario({
  survey_id: 'survey-uuid',
  investments: ['solar-uuid', 'battery-uuid'],
  extra_costs: [
    {
      id: 'installation-uuid',
      quantity: 1,
      snapshot_price: 150000
    }
  ]
})
```

---

## Breaking Changes

### From Previous Implementation (if any)

**Database:**
- `clients.address` → `postal_code + city + street + house_number`
- Completely new survey structure (not backwards compatible)

**Frontend:**
- Old survey composables replaced with new ones
- Component props/events may differ

**Migration Required:**
- If you have existing survey data, you'll need to migrate it manually
- Client addresses need to be parsed and split

---

## File Structure

```
flow-nuxt/
├── supabase/
│   └── migrations/
│       ├── 004_create_survey_system.sql              # Main migration (creates base tables)
│       ├── 004_seed_survey_base_data.sql             # Seed data from FlowFrontend
│       └── 007_fix_document_categories_extra_costs_ids.sql  # Adds persist_name & survey_pages columns
├── scripts/
│   └── seed-survey-data.ts                           # TypeScript seeder (deprecated)
├── app/
│   ├── types/
│   │   └── survey-new.ts                             # All types
│   └── composables/
│       ├── useSurveys.ts                             # Survey CRUD
│       ├── useInvestments.ts                         # Investments
│       ├── useSurveyAnswers.ts                       # Questions/Answers
│       ├── useDocuments.ts                           # Photo uploads
│       ├── useScenarios.ts                           # Scenarios
│       └── useContracts.ts                           # Contracts
└── docs/
    ├── survey-system-architecture.md                 # Full reference
    ├── SEED_SURVEY_DATA.md                           # Seeding guide
    └── MIGRATION_SUMMARY.md                          # This file
```

---

## RLS & Security

All tables have Row Level Security enabled with company-based policies:

```sql
-- Example policy
CREATE POLICY "Users can view surveys from their company"
    ON public.surveys FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );
```

**Protected tables:**
- surveys
- electric_cars
- scenarios
- contracts
- survey_answers
- documents

---

## Testing Checklist

After migration:

- [ ] Verify all tables exist
- [ ] Verify seed data loaded
- [ ] Create test survey via composable
- [ ] Upload test document
- [ ] Save test answers
- [ ] Create test scenario
- [ ] Create test contract
- [ ] Verify RLS policies work
- [ ] Check storage bucket access

---

## Rollback

If you need to rollback:

```sql
-- Drop all survey tables
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS survey_answers CASCADE;
DROP TABLE IF EXISTS survey_questions CASCADE;
DROP TABLE IF EXISTS survey_survey_pages CASCADE;
DROP TABLE IF EXISTS survey_pages CASCADE;
DROP TABLE IF EXISTS extra_cost_relations CASCADE;
DROP TABLE IF EXISTS extra_costs CASCADE;
DROP TABLE IF EXISTS contract_investments CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS scenario_investments CASCADE;
DROP TABLE IF EXISTS scenarios CASCADE;
DROP TABLE IF EXISTS investment_document_categories CASCADE;
DROP TABLE IF EXISTS document_categories CASCADE;
DROP TABLE IF EXISTS survey_heavy_consumers CASCADE;
DROP TABLE IF EXISTS heavy_consumers CASCADE;
DROP TABLE IF EXISTS electric_cars CASCADE;
DROP TABLE IF EXISTS survey_investments CASCADE;
DROP TABLE IF EXISTS investments CASCADE;
DROP TABLE IF EXISTS surveys CASCADE;

-- Drop enums
DROP TYPE IF EXISTS survey_question_type CASCADE;
DROP TYPE IF EXISTS heavy_consumer_status CASCADE;
DROP TYPE IF EXISTS electric_car_status CASCADE;

-- Restore client address
ALTER TABLE public.clients DROP COLUMN IF EXISTS postal_code;
ALTER TABLE public.clients DROP COLUMN IF EXISTS city;
ALTER TABLE public.clients DROP COLUMN IF EXISTS street;
ALTER TABLE public.clients DROP COLUMN IF EXISTS house_number;
ALTER TABLE public.clients ADD COLUMN address TEXT;
```

---

## Support

- **Architecture Docs**: `/docs/survey-system-architecture.md`
- **Seed Guide**: `/docs/SEED_SURVEY_DATA.md`
- **Code Examples**: See composables usage in architecture docs

---

**Migration completed successfully! 🎉**
