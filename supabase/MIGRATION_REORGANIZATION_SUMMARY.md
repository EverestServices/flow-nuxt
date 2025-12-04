# Migration Reorganization Summary

**Date:** 2025-11-24
**Status:** ✅ Complete

## Overview

Successfully reorganized 204 chaotic Supabase migrations into a clean, dependency-ordered structure. The new migrations are based entirely on the remote production database schema.

## What Was Done

### 1. Analysis Phase
- Connected to remote Supabase database (green-flow) in read-only mode
- Exported full schema dump (5,587 lines) and data dump (3,353 lines)
- Identified 34 tables to manage
- Analyzed dependency levels across all tables

### 2. Created New Migrations (53 total)

#### Structure Migrations (400-433)
- **Level 1 (400-408):** Basic reference tables with no FK dependencies
  - heavy_consumers, monthly_climate_data, discounts, subsidies, etc.
- **Level 2 (409-415):** Tables with single-level FK dependencies
  - companies, clients, main_components, investments, etc.
- **Level 3-7 (416-433):** Complex dependencies
  - surveys, scenarios, contracts, and all pivot tables

#### Data Migrations (450-491)
- **450-458:** Reference data (heavy_consumers, climate data, discounts, subsidies)
- **461-465:** Configuration data (document categories, survey settings, pages)
- **471:** Main components and categories data
- **490-491:** Post-insert foreign keys (self-references)

#### Security & Automation (495-496)
- **495:** RLS Policies
  - 17 ENABLE ROW LEVEL SECURITY statements
  - 37 policies for company-scoped access control

- **496:** Functions and Triggers
  - 10 Functions (RLS helpers, survey automation, sync tracking)
  - 27 Triggers (updated_at automation, survey answer synchronization)

### 3. Cleaned Up Old Migrations

**Moved to backup:** 101 migrations that are now fully covered
- All old structure definitions for managed tables
- All old seed data migrations
- All old RLS/function/trigger migrations for managed tables

**Kept in place:** 101 migrations for tables outside our scope
- user_profiles, tickets, todos, news, library, courses, electric_cars
- Storage buckets, auth triggers, etc.

## Current State

**Total migrations:** 154
- **101 old migrations:** For unmanaged tables (user_profiles, todos, news, etc.)
- **53 new migrations:** For our 34 managed tables (400-496)

**Backup location:** `/supabase/migrations_backup/` (101 files)

## Tables Managed (34)

### Core Tables
- companies, clients, surveys, scenarios, contracts, documents

### Survey System
- survey_pages, survey_questions, survey_answers
- survey_heavy_consumers, survey_investments, survey_subsidies
- survey_survey_pages, survey_value_copy_rules, survey_settings

### Reference Data
- heavy_consumers, monthly_climate_data, discounts, subsidies
- main_component_categories, document_categories

### Products & Costs
- main_components, investments, extra_costs
- main_component_category_investments
- investment_document_categories
- extra_cost_relations

### Contract Details
- scenario_investments, scenario_main_components
- contract_investments, contract_main_components
- contract_extra_costs, contract_discounts

### Integrations
- external_sync_logs

## Key Features Preserved

### Row Level Security (RLS)
All 37 policies implement company-scoped access control:
- Users can only access data from their own company
- Achieved through user_profiles.company_id matching
- Policies for SELECT, INSERT, UPDATE, DELETE on all user-facing tables

### Functions (10)
1. **get_user_company_id** - Get company for any user
2. **get_current_user_company_id** - Get current user's company
3. **get_default_value_from_source** - Survey question inheritance
4. **get_last_sync_for_entity** - External sync tracking
5. **handle_new_user** - Auto-create user profile
6. **set_ticket_number** - Auto-generate ticket numbers
7. **update_updated_at_column** - Auto-update timestamps
8. **sync_conditional_value_copy** - Survey conditional copying
9. **sync_default_value_inheritance** - Survey value inheritance
10. **sync_dependent_question_answers** - Survey dependency sync

### Triggers (27)
- **23 update_updated_at triggers** - Auto-update timestamps on all tables
- **sync_default_value_inheritance** - Survey answer inheritance
- **trigger_sync_dependent_answers** - Survey answer dependencies
- **trigger_sync_conditional_value_copy** - Conditional value copying
- **update_survey_value_copy_rules_updated_at** - Copy rules timestamps

## Migration Numbering System

- **400-408:** Level 1 structure (no dependencies)
- **409-415:** Level 2 structure (basic dependencies)
- **416-433:** Level 3-7 structure (complex dependencies)
- **450-458:** Reference data
- **461-465:** Configuration data
- **471:** Product data
- **490-491:** Post-insert foreign keys
- **495:** RLS policies
- **496:** Functions and triggers

## Testing Instructions

### 1. Clean Local Setup
```bash
# Stop local Supabase
supabase stop

# Remove volumes
docker volume prune -f

# Start fresh
supabase start
```

### 2. Verify Migration Order
```bash
# All new migrations should run in order
ls supabase/migrations/4*.sql
```

### 3. Check Database State
```bash
# Connect to local DB
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Verify tables exist
\dt public.*

# Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('surveys', 'clients', 'scenarios', 'contracts');

# Check functions exist
\df public.get_*

# Check triggers exist
SELECT tgname, tgrelid::regclass
FROM pg_trigger
WHERE tgname LIKE 'update_%' OR tgname LIKE 'sync_%' OR tgname LIKE 'trigger_%'
ORDER BY tgrelid::regclass::text;
```

### 4. Verify Data
```bash
# Check seed data loaded
SELECT COUNT(*) FROM public.heavy_consumers;
SELECT COUNT(*) FROM public.subsidies;
SELECT COUNT(*) FROM public.discounts;
SELECT COUNT(*) FROM public.monthly_climate_data;
```

## Rollback Instructions

If issues arise, restore old migrations:
```bash
# Move new migrations out
mv supabase/migrations/4*.sql /tmp/new_migrations_backup/

# Restore old migrations
mv supabase/migrations_backup/* supabase/migrations/

# Reset database
supabase db reset
```

## Next Steps

1. **Test locally:** Run all migrations on clean local instance
2. **Verify functionality:** Test survey creation, scenarios, contracts
3. **Deploy to staging:** Test on staging environment
4. **Production deployment:** Deploy to production (already matches this structure)

## Notes

- Remote production database was never modified (read-only approach)
- All structure/data extracted from production ensures accuracy
- Old migrations safely backed up (not deleted)
- Tables outside our scope (user_profiles, todos, news, etc.) remain unchanged

## Files Generated

- **53 migration files:** `/supabase/migrations/400-496_*.sql`
- **README:** `/supabase/migrations/README_NEW_MIGRATIONS.md`
- **Backup:** `/supabase/migrations_backup/` (101 files)
- **This summary:** `/supabase/MIGRATION_REORGANIZATION_SUMMARY.md`

## Update - Felesleges UPDATE Migrációk Törlése

**Dátum:** 2025-11-24 (Later)

### Törölt Felesleges Migrációk

Első körben (position/value UPDATE-ek): **11 db**
- 033_add_positions_to_document_categories.sql
- 042_update_sequences_in_seed_data.sql
- 049_update_solar_panel_efficiency.sql
- 050_update_insulation_u_values.sql
- 061_update_solar_battery_icon.sql
- 062_add_inverter_compatibility_specs.sql
- 094_rename_roof_insulation_to_attic_insulation.sql
- 156_update_windows_icon.sql
- 191_update_attic_insulation_icon.sql
- 1000_update_company_id.sql
- 1002_update_survey_times.sql

Második körben (translation/config UPDATE-ek): **15 db**
- 036_set_special_questions.sql
- 037_add_sequence_to_survey_pages.sql
- 075_seed_multilingual_translations.sql
- 076_complete_question_translations.sql
- 083_populate_main_component_category_translations.sql
- 087_add_phase_display_conditions.sql
- 1004_populate_add_button_translations.sql
- 144_set_question_widths.sql
- 146_convert_to_icon_selector_type.sql
- 147_fix_phase_power_widths.sql
- 149_configure_dynamic_consumption_placeholders.sql
- 151_simplify_heating_methods_label.sql
- 152_fix_facade_insulation_display_conditions.sql
- 153_convert_phase_count_to_icon_selector.sql
- 155_convert_window_door_type_to_dropdown.sql

**Összesen törölve:** 26 felesleges UPDATE migráció

### Végállapot

- **127 migráció** a backup-ban (101 eredeti + 26 UPDATE)
- **128 aktív migráció**
  - **53 új migráció** (400-496)
  - **75 régi migráció** (user_profiles, todos, news, stb.)

### Miért voltak feleslegesek?

Az új seed data migrációk (450-458, 461-465) már tartalmazzák az összes mezőt a végleges értékekkel:
- `position` JSON értékek
- `sequence` számok
- `name_translations` JSONB
- `is_special` boolean
- `efficiency`, `u_value`, `cop` értékek
- `specifications` JSONB
- Minden egyéb konfigurációs mező

Tehát az UPDATE migrációk redundánsak - csak olyan értékeket próbálnak beállítani, amelyek már az INSERT-ben benne vannak.
