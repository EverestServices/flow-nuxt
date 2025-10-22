# Survey System Seed Data

This guide explains how to seed the survey system with base data.

## Overview

The seed script populates the survey system with data from the FlowFrontend project:
- ✅ **9 Investment Types** (Solar Panel, Solar Panel + Battery, Heat Pump, Facade Insulation, Roof Insulation, Windows, Air Conditioner, Battery, Car Charger)
- ✅ **6 Heavy Consumers** (sauna, jacuzzi, poolHeating, cryptoMining, heatPump, electricHeating)
- ✅ **26 Document Categories** with `persist_name` (from photoUploadConfig.ts)
- ✅ **27+ Survey Pages** with **50+ Questions** (from app/fixtures/surveys/)
- ✅ **18 Extra Costs** with `persist_name` (from ExtraCostsPanel.tsx)
- ✅ **Investment ↔ Document Category Links**

## Prerequisites

1. **Supabase Connection**: Ensure `.env` has Supabase credentials:
   ```env
   NUXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NUXT_PUBLIC_SUPABASE_KEY=your-anon-key
   ```

2. **Database Migrations**: Run all migrations first:
   ```bash
   npx supabase db push
   ```

3. **Install tsx** (if not already):
   ```bash
   npm install -D tsx
   ```

## Methods

### Method 1: SQL Migration (Recommended)

Run via **Supabase Dashboard**:

1. Go to your Supabase project
2. Navigate to **SQL Editor**
3. Create new query
4. Copy contents of `supabase/migrations/004_seed_survey_base_data.sql`
5. Click **Run**

Or via **Supabase CLI**:

```bash
npx supabase db push
```

### Method 2: TypeScript Script

Run programmatically (seeds Investments, Heavy Consumers, Document Categories, Extra Costs):

```bash
npm run seed:survey
```

**Note:** Survey Pages and Questions must still be seeded via SQL migration.

## What Gets Seeded

### 1. Investments (9)

| Name | Icon | Position |
|------|------|----------|
| Solar Panel | sun | top: 150, right: 300 |
| Solar Panel + Battery | sun | top: 150, right: 250 |
| Heat Pump | thermometer | top: 200, right: 300 |
| Facade Insulation | home | top: 250, right: 100 |
| Roof Insulation | home | top: 50, right: 300 |
| Windows | square | top: 200, right: 100 |
| Air Conditioner | wind | top: 300, right: 200 |
| Battery | battery | top: 350, right: 300 |
| Car Charger | car | top: 400, right: 350 |

### 2. Heavy Consumers (6)

- sauna
- jacuzzi
- poolHeating
- cryptoMining
- heatPump
- electricHeating

### 3. Document Categories (26)

All categories from FlowFrontend `photoUploadConfig.ts` with `persist_name` field:

| persist_name | Name (Hungarian) | Description | Min Photos |
|--------------|------------------|-------------|------------|
| roof-condition | Tető állapota | Különböző szögekből készült képek a teljes tetőfelületről | 3 |
| electrical-meter | Villanyóra és elektromos betáplálás | Villanyóra szekrény és mérőóra | 2 |
| roof-structure | Tető szerkezete | Tetőszerkezet és tetőtér belülről | 2 |
| roof-access | Tetőhöz való hozzáférés | Hozzáférési útvonalak a tetőhöz | 1 |
| inverter-room | Inverter hely | A tervezett inverter elhelyezési helye | 2 |
| facade-south | Homlokzat (déli oldal) | Épület déli oldala | 2 |
| facade-north | Homlokzat (északi oldal) | Épület északi oldala | 2 |
| facade-east | Homlokzat (keleti oldal) | Épület keleti oldala | 2 |
| facade-west | Homlokzat (nyugati oldal) | Épület nyugati oldala | 2 |
| ... (17 more categories) | ... | ... | ... |

**Note:** All 26 categories include `persist_name` for programmatic access alongside UUID `id`.

### 4. Investment ↔ Document Category Links

- **Solar Panel**: General Property Photos, Roof Photos, Electrical Panel, Meter Readings
- **Heat Pump**: General Property Photos, Heating System, Electrical Panel, Basement/Cellar
- **Facade Insulation**: General Property Photos, Facade Photos
- **Roof Insulation**: General Property Photos, Roof Photos, Attic Space
- **Windows**: General Property Photos, Windows and Doors

### 5. Survey Pages (27+) & Questions (50+)

Survey pages and questions extracted from FlowFrontend `app/fixtures/surveys/` for all 9 investment types:

#### Solar Panel (4 pages)
- Általános adatok (general)
- Napelemes rendszer (solar_panel)
- Inverteres rendszer (inverter)
- Tető (roof)

#### Solar Panel + Battery (5 pages)
- Same as Solar Panel + Battery specific page

#### Heat Pump (1 page)
- Basic information

#### Facade Insulation (3 pages)
- Általános adatok
- Homlokzat info
- Falszerkezetek (with allowMultiple)

#### Roof Insulation (4 pages)
- Általános adatok
- Tető info
- Padlástér
- Tetőszerkezetek (with allowMultiple)

#### Windows (4 pages)
- Általános adatok
- Ablak info
- Külső ajtók (with allowMultiple)
- Ablakok (with allowMultiple)

#### Air Conditioner, Battery, Car Charger
- Multiple pages with specific questions for each type

**Total:** 27+ pages with 50+ questions across all investment types

### 6. Extra Costs (18)

All costs from FlowFrontend `ExtraCostsPanel.tsx` with `persist_name` field:

| persist_name | Name (Hungarian) | Price (HUF) |
|--------------|------------------|-------------|
| gutter-reinstallation | Eresz visszahelyezése | 25,000 |
| downspout-removal | Függőleges lefolyó eltávolítása | 15,000 |
| snow-guard-removal | Hórács eltávolítása | 30,000 |
| antenna-removal | Antenna eltávolítása | 20,000 |
| satellite-dish-removal | Parabola antenna eltávolítása | 20,000 |
| chimney-work | Kéményhez kapcsolódó munka | 50,000 |
| roof-window-adjustment | Tetőablak körüli munka | 40,000 |
| ... (11 more costs) | ... | ... |

**Note:** All 18 costs include `persist_name` for programmatic access alongside UUID `id`.

## Verification

After seeding, verify the data:

```sql
-- Check investments
SELECT COUNT(*) FROM investments;  -- Should be 9

-- Check heavy consumers
SELECT COUNT(*) FROM heavy_consumers;  -- Should be 6

-- Check document categories
SELECT COUNT(*) FROM document_categories;  -- Should be 26

-- Check investment-category links
SELECT COUNT(*) FROM investment_document_categories;  -- Should be ~50+

-- Check survey pages
SELECT COUNT(*) FROM survey_pages;  -- Should be 27+

-- Check survey questions
SELECT COUNT(*) FROM survey_questions;  -- Should be 50+

-- Check extra costs
SELECT COUNT(*) FROM extra_costs;  -- Should be 18

-- Check persist_name columns exist
SELECT persist_name FROM document_categories LIMIT 1;
SELECT persist_name FROM extra_costs LIMIT 1;
```

## Re-seeding

The seed script uses `ON CONFLICT DO NOTHING` to prevent duplicates. You can safely run it multiple times.

To completely re-seed:

1. Delete all data:
   ```sql
   TRUNCATE investments, heavy_consumers, document_categories,
            survey_pages, survey_questions, extra_costs CASCADE;
   ```

2. Run seed again:
   ```bash
   npm run seed:survey
   # OR
   npx supabase db push
   ```

## Customization

Edit the seed data in:
- **SQL**: `supabase/migrations/004_seed_survey_base_data.sql`
- **TypeScript**: `scripts/seed-survey-data.ts`

## Troubleshooting

### Error: "relation does not exist"

**Solution**: Run migrations first:
```bash
npx supabase db push
```

### Error: "permission denied"

**Solution**: Use service role key instead of anon key:
```env
SUPABASE_SERVICE_KEY=your-service-role-key
```

### Questions not appearing

**Solution**: Survey questions can only be seeded via SQL migration (not TypeScript script). Run:
```bash
npx supabase db push
```

## Next Steps

After seeding:

1. ✅ Create a test survey using composables
2. ✅ Upload test documents
3. ✅ Create scenarios and contracts
4. ✅ Test the full workflow

See `/docs/survey-system-architecture.md` for usage examples.

---

**Created:** 2025-10-17
**Maintained by:** Development Team
