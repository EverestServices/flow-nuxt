# Új Migrációs Rendszer - Dokumentáció

## Áttekintés

Összesen **51 új migráció** készült el a remote Supabase adatbázis alapján, tiszta függőségi sorrendben.

## Migráció Struktúra

### 1. Szint - Alapvető referencia táblák (400-408)
**Struktúra migrációk:**
- `400` - heavy_consumers (háztartási fogyasztók katalógus)
- `401` - monthly_climate_data (havi klíma adatok)
- `402` - discounts (kedvezmények)
- `403` - subsidies (támogatások)
- `404` - main_component_categories (fő komponens kategóriák)
- `405` - document_categories (dokumentum kategóriák)
- `406` - survey_settings (survey globális beállítások)
- `407` - survey_pages (survey oldal sablonok)
- `408` - survey_question_type ENUM + survey_questions (survey kérdések)

**Adat migrációk (450-458):**
- Minden fenti táblához tartozó referencia/seed adatok

---

### 2. Szint - Másodlagos táblák (409-415)
**Struktúra migrációk:**
- `409` - companies (cégek)
- `410` - clients* (ügyfelek - csak struktúra)
- `411` - main_components (fő komponensek katalógus)
- `412` - investments (befektetés típusok)
- `413` - extra_costs (extra költségek)
- `414` - survey_value_copy_rules (érték másolási szabályok)
- `415` - external_sync_logs (sync logok + ENUMs)

**Adat migrációk (461-465):**
- `461` - main_components data
- `462` - investments data
- `463` - extra_costs data
- `464` - survey_value_copy_rules data
- `465` - external_sync_logs data

---

### 3-7. Szint - Komplex függőségek (416-433)

**3. Szint - Pivot táblák és survey:**
- `416` - main_component_category_investments* (pivot)
- `417` - investment_document_categories* (pivot)
- `418` - extra_cost_relations* (kapcsolatok)
- `419` - surveys* (felmérések - csak struktúra)
- `420` - survey_survey_pages* (pivot)

**4. Szint - Survey függő táblák:**
- `421` - scenarios (forgatókönyvek) + **471 adat**
- `422` - documents* (dokumentumok)
- `423` - survey_answers* (válaszok)
- `424` - survey_heavy_consumers* (pivot)
- `425` - survey_investments* (pivot)
- `426` - survey_subsidies* (pivot)

**5. Szint - Scenario függő táblák:**
- `427` - contracts* (szerződések)
- `428` - scenario_investments* (pivot)
- `429` - scenario_main_components* (pivot)

**6. Szint - Contract függő táblák:**
- `430` - contract_investments* (pivot)
- `431` - contract_main_components* (pivot)
- `432` - contract_extra_costs* (pivot)
- `433` - contract_discounts* (pivot)

---

### Post-insert Foreign Keys (490-491)
- `490` - Self-reference FK-k (survey_pages, survey_questions)
- `491` - Deferred FK-k (survey_pages.investment_id)

## Futtatási Sorrend

A migrációkat a következő sorrendben kell futtatni:

1. **Struktúra létrehozás**: 400 → 433 (sorrendben)
2. **Adatok beszúrása**: 450-458, 461-465, 471 (sorrendben)
3. **Post-insert FK-k**: 490-491

## Fontos Megjegyzések

### Csak Struktúra Táblák (*)
A csillaggal jelölt táblák **nem tartalmaznak seed adatokat**, mert:
- Pivot táblák (kapcsoló táblák)
- User-generated content (frontend-ről jönnek az adatok)
- Üzleti adatok (clients, surveys, contracts stb.)

### Self-Reference Kapcsolatok
Bizonyos táblák saját magukra hivatkoznak:
- `survey_pages.parent_page_id` → `survey_pages.id`
- `survey_questions.default_value_source_question_id` → `survey_questions.id`
- `survey_questions.shared_question_id` → `survey_questions.id`

Ezeket az FK-kat csak az adatok beszúrása **után** lehet hozzáadni (490-es migráció).

### Circular Dependencies
A `survey_pages.investment_id` egy "deferred" FK, mert:
- A survey_pages-t az 1. szintben kell létrehozni
- De az investments csak a 2. szintben jön létre
- Az FK-t ezért a 491-es migrációban adjuk hozzá

## Régi Migrációk Kezelése

A régi `000-205` és `996-999` számú migrációk most már **nem szükségesek**, mert:
- Az új migrációk teljes mértékben lefedik az adatbázis struktúrát
- Tiszta függőségi sorrend
- Konzisztens számozás

**Ajánlott lépések:**
1. Backup készítése a régi migrációkról
2. Régi migrációk törlése vagy archiválása
3. Új migrációk futtatása clean adatbázison

## Tesztelés

### Local tesztelés:
```bash
# Local Supabase indítása
npx supabase start

# Migrációk futtatása
npx supabase db reset

# Ellenőrzés
npx supabase db diff
```

### Migrate parancs nélkül (kézi futtatás):
```bash
# Kapcsolódás local DB-hez
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Migrációk egyenkénti futtatása
\i supabase/migrations/400_create_heavy_consumers_table.sql
\i supabase/migrations/401_create_monthly_climate_data_table.sql
# ... stb
```

## Következő Lépések

1. ✅ Migrációk elkészítve
2. ⏳ Local tesztelés
3. ⏳ Staging környezetben tesztelés
4. ⏳ Production deployment (ha szükséges)

## Kontakt & Support

Ha kérdés merül fel a migrációkkal kapcsolatban, ellenőrizd a specific migration fájlt - minden migráció tartalmaz:
- Description (leírás)
- Dependencies (függőségek)
- Kommentált SQL kód

---

*Generálva: 2025-11-24*
*Remote DB: green-flow (ybwyuzjaaoxvbvjqfods)*
