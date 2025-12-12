# GJ Energiamegtakarítás Kalkulációk Átemelési Terv

## Áttekintés

A Flow-ba átemeljük az OFP-ből a GJ (gigajoule) alapú energiamegtakarítás kalkulációkat, amelyek szükségesek a KEHOP Plusz pályázati kalkulációkhoz és a részletes energetikai elemzésekhez.

## Jelenlegi Állapot

### OFP (Sherpa)
Az OFP-ben jelenleg teljes körű GJ kalkulációs rendszer működik:

**Fő komponensek:**
- `EnergyEfficiencyConsultingProtocolProvider::getEnergySavingsAvailableThroughUpgrades()` - Beruházásonkénti energiamegtakarítás számítás
- `SavingThirtyPercentProvider` - GJ és kWh konverziók, elméleti maximum kalkuláció
- `GlobalDataProvider::calculateConsumption()` - Fűtési energia fogyasztás számítás
- `EnergyCostProvider::getCostSavingCalculation()` - Költségmegtakarítás GJ alapján

**Számított értékek beruházásonként:**
- Éves átlagos fűtési energiamegtakarítás (GJ)
- Éves átlagos fűtési energiamegtakarítás (kWh)
- Százalékos megtakarítás (%)
- Számított felület (m²) - szigeteléseknél

**KEHOP összesítés értékei:**
- Összes GJ megtakarítás (összegzett)
- Összes kWh megtakarítás
- Százalékos teljes megtakarítás
- 30%-os megtakarítási küszöb ellenőrzése (KEHOP feltétel)

### Flow (Jelenlegi)
A Flow-ban jelenleg csak magas szintű ROI kalkulációk vannak:
- Energia hatékonysági javulás százalék (compound logikával)
- Éves megtakarítás (Ft)
- Visszatérülési idő
- Nincs GJ/kWh alapú részletes energiamegtakarítás kalkuláció

## Terv: Átemelendő Funkciók

### 1. Új Composable: `useEnergyCalculations.ts`

```typescript
export interface EnergySavingsPerInvestment {
  // Beruházás azonosítók (pl. "facadeInsulation", "roofInsulation")
  investmentKey: string

  // Energia megtakarítás
  annualHeatingSavingsGJ: number  // GJ/év
  annualHeatingSavingsKWh: number // kWh/év
  savingsPercentage: number       // %

  // Valós adatok (nem becsült!)
  actualArea?: number      // m² - scenario_main_components táblából (szigeteléseknél)
  capacity?: number        // kW (hőszivattyúnál)
}

export interface KEHOPSummary {
  totalGJ: number          // Összes GJ megtakarítás
  totalKWh: number         // Összes kWh megtakarítás
  totalPercentage: number  // Összes % megtakarítás
  meets30Percent: boolean  // 30%-os küszöb teljesítése
}
```

**Fő metódusok:**
- `calculateEnergySavings(surveyId, scenarioId)` - Beruházásonkénti GJ/kWh kalkuláció
- `calculateKEHOPSummary(surveyId, scenarioId)` - KEHOP összesítés
- `calculateTheoreticalMaximum(surveyId)` - Elméleti maximum energia igény
- `convertGJtoKWh(gj)` - Konverziós függvény
- `convertKWhToGJ(kwh)` - Konverziós függvény
- `getInvestmentQuantity(scenarioId, persistName)` - Mennyiség lekérése scenario_main_components táblából

**Mennyiségek adatforrásai (scenario_main_components tábla):**
- **Homlokzati szigetelés:** `main_components.persist_name = 'default-facade-insulation'` → `quantity` mező (m²)
- **Tetőszigetelés:** `main_components.persist_name = 'default-roof-insulation'` → `quantity` mező (m²)
- **Nyílászárók:** `main_components.persist_name = 'window-surface-area'` → `quantity` mező (m²)
- **Hőszivattyú:** `main_components` táblából a kiválasztott hőszivattyú termék kapacitása (kW)

### 2. Kalkulációs Konstansok

```typescript
// energia-savings-constants.ts
export const ENERGY_CONSTANTS = {
  // Átlagos külső hőmérséklet
  AVERAGE_OUTSIDE_TEMP: 3.6, // °C

  // Éves fűtési időtartam
  ANNUAL_HEATING_DURATION: 4392, // óra

  // Konverziós faktorok
  GJ_TO_KWH: 277.778, // 1 GJ = 277.778 kWh
  KWH_TO_GJ: 0.0036,  // 1 kWh = 0.0036 GJ

  // Hatékonyság faktorok (OFP-specifikus)
  EFFICIENCY_FACTOR: 0.9,
  OFP_CALCULATION_FACTOR: 70, // OFP pályázatokhoz 70%, egyébként 100%
}
```

### 3. Adatbázis Módosítások

**`scenarios` tábla bővítése:**
```sql
-- Új oszlopok a scenarios táblához
ALTER TABLE scenarios ADD COLUMN energy_savings JSONB;

-- Struktúra:
{
  "perInvestment": {
    "facadeInsulation": {
      "annualHeatingSavingsGJ": 32.074,
      "annualHeatingSavingsKWh": 8909,
      "savingsPercentage": 20.6,
      "calculatedArea": 120.5
    },
    // ... további beruházások
  },
  "kehopSummary": {
    "totalGJ": 60.38,
    "totalKWh": 16772,
    "totalPercentage": 37.8,
    "meets30Percent": true
  },
  "calculatedAt": "2025-12-08T10:30:00Z"
}
```

### 4. UI Megjelenítés

**Konzultáció oldal (`SurveyConsultationData.vue`) bővítése:**

**Pozíció:** Megtérülés szekció **ELŐTT**

**Új szekció: "Energiamegtakarítások részletezése"**
- **Collapsible:** Alapértelmezetten becsukva, nyitható/zárható
- **Minden survey esetén megjelenjen** (nem csak OFP-s survey-eknél)
- **Beruházásonként megjelenő értékek (kártyák):**
  - GJ/év - Éves átlagos fűtési energiamegtakarítás
  - kWh/év - Éves átlagos fűtési energiamegtakarítás
  - % - Százalékos megtakarítás
  - m² vagy kW - Valós mennyiség a `scenario_main_components` táblából (nem becsült!)

**KEHOP összesítő kártya:**
- **Pozíció:** Energiamegtakarítások részletezése után
- **Vizuális kiemelés:**
  - Zöld háttér ha `totalPercentage >= 30%` (megfelel a követelménynek)
  - Piros/narancssárga háttér ha `totalPercentage < 30%` (nem felel meg)
  - ✅ vagy ❌ ikon a 30%-os küszöb mellett
- **Tartalom:**
  - Összes GJ megtakarítás
  - Összes kWh megtakarítás
  - Összes % megtakarítás
  - "30%-os KEHOP követelmény:" jelzés státusszal

**UI Layout:**
```
┌─────────────────────────────────────────────┐
│ [Beruházások kiválasztása]                  │
│ [Energia hatékonysági javulás csúszka]      │
│ [Becslés pontossága csúszka]               │
├─────────────────────────────────────────────┤
│ 🆕 ▶ Energiamegtakarítások részletezése    │ <- Collapsible
│   ├─ 🏠 Homlokzati szigetelés              │
│   │   • 32.074 GJ/év                       │
│   │   • 8,909 kWh/év                       │
│   │   • 20.6%                              │
│   │   • 120.5 m² (valós mennyiség)         │
│   ├─ 📚 Tetőszigetelés                     │
│   ├─ 🚪 Nyílászárók                        │
│   └─ 💨 Hőszivattyú                        │
├─────────────────────────────────────────────┤
│ 🆕 KEHOP PLUSZ PÁLYÁZAT ÖSSZESÍTÉSE        │ <- Vizuális kiemelés
│   60.38 GJ | 16,771 kWh | 37.8%            │
│   ✅ 30%-os követelmény: MEGFELEL          │
├─────────────────────────────────────────────┤
│ [Megtérülés]                                │ <- Meglévő szekció
│ [Tervezett infláció]                        │
└─────────────────────────────────────────────┘
```

**Hiányzó adatok kezelése:**

Ha egy beruházáshoz nincs `quantity` a `scenario_main_components` táblában:

```
┌─────────────────────────────────────────────┐
│ 🏠 Homlokzati szigetelés                    │
│                                             │
│ ℹ️  A pontos energiamegtakarítás           │
│    számításához adjon meg adatokat         │
│    a "Rendszer tervezés" szekcióban:       │
│                                             │
│    → Homlokzati rendszer / Homlokzati      │
│      szigetelés rendszer                    │
│                                             │
│    Adja meg a szigetelendő felületet (m²)  │
└─────────────────────────────────────────────┘
```

**Hibaüzenet szöveg beruházásonként:**
- **Homlokzati szigetelés:** "A számításhoz adjon meg adatokat a 'Rendszer tervezés' → 'Homlokzati rendszer' → 'Homlokzati szigetelés rendszer' terméknél. Adja meg a szigetelendő felületet (m²)."
- **Tetőszigetelés:** "A számításhoz adjon meg adatokat a 'Rendszer tervezés' → 'Tetőszigetelő rendszer' terméknél. Adja meg a szigetelendő felületet (m²)."
- **Nyílászárók:** "A számításhoz adjon meg adatokat a 'Felmérő' oldalon. Rögzítse a nyílászárókat és azok felületét (m²)."
- **Hőszivattyú:** "A számításhoz válasszon ki egy hőszivattyú terméket a 'Rendszer tervezés' → 'Hőszivattyú' szekcióban."

### 5. Backend Edge Function

**Implementációs megközelítés:**
- A kalkulációs logika **Backend Edge Function-ben** fut
- **OFP logika átemelése:** Az OFP-ben lévő PHP kalkulációk TypeScript-be átírva
- **NINCS aktív OFP API kapcsolat** (nem hívjuk az OFP backend-et)
- **Automatikus újraszámítás:** Minden adat változáskor (beruházás ki/be kapcsolás, mennyiség módosítás)

```typescript
// supabase/functions/calculate-energy-savings/index.ts

import { corsHeaders } from '../_shared/cors.ts'

interface CalculateEnergySavingsRequest {
  surveyId: string
  scenarioId: string
}

interface EnergySavingsResult {
  perInvestment: {
    [key: string]: {
      annualHeatingSavingsGJ: number
      annualHeatingSavingsKWh: number
      savingsPercentage: number
      actualArea?: number
      capacity?: number
    }
  }
  kehopSummary: {
    totalGJ: number
    totalKWh: number
    totalPercentage: number
    meets30Percent: boolean
  }
  calculatedAt: string
}

// Fő kalkulációs logika (OFP-ből átmásolva)
async function calculateEnergySavings(
  surveyId: string,
  scenarioId: string
): Promise<EnergySavingsResult> {
  // 1. Lekérjük a scenario_main_components táblából a mennyiségeket
  // 2. Alkalmazzuk az OFP kalkulációs formulákat (GJ/kWh számítás)
  // 3. Összesítés és KEHOP ellenőrzés
  // 4. Eredmény visszaadása
}
```

**Trigger pontok (automatikus újraszámítás):**
1. Beruházás hozzáadása/törlése (`scenario_investments` tábla változás)
2. Mennyiség módosítása (`scenario_main_components.quantity` változás)
3. Scenario aktiválása (ha még nincs energia kalkuláció)

## Implementációs Lépések

### Fázis 1: Backend Edge Function Alapok (Prioritás: Magas)
1. **Edge Function létrehozása: `calculate-energy-savings`**
   - TypeScript boilerplate és Supabase kapcsolat
   - Request/Response interfészek
   - CORS headers

2. **OFP Kalkulációs Logika Átemelése**
   - `EnergyEfficiencyConsultingProtocolProvider::getEnergySavingsAvailableThroughUpgrades()` logika TypeScript-be
   - `SavingThirtyPercentProvider` konverziós függvények
   - `GlobalDataProvider::calculateConsumption()`
   - Konstansok (átlagos külső hőmérséklet, fűtési időtartam, stb.)

3. **Adatok lekérése és feldolgozása**
   - `scenario_main_components` tábla query (mennyiségek lekérése)
   - `scenario_investments` tábla query (aktív beruházások)
   - Survey adatok lekérése (hőmérséklet, stb.)

4. **Eredmény mentése scenarios táblába**
   - `energy_savings` JSONB oszlop frissítése
   - Timestamp hozzáadása (`calculatedAt`)

### Fázis 2: UI Megjelenítés (Prioritás: Magas)
5. **`SurveyConsultationData.vue` bővítése**
   - **Új collapsible szekció** beruházásonkénti GJ/kWh megjelenítéshez
   - Alapértelmezetten **becsukva**, `UDisclosure` vagy accordion komponens használata
   - Értékek formázása (pl. "32.074 GJ", "8,909 kWh", "20.6%")
   - **Mennyiségek** megjelenítése (valós értékek a `scenario_main_components`-ből)
   - Pozíció: **Megtérülés szekció előtt**
   - **Minden survey esetén** megjelenjen (nem csak OFP-nél)

6. **Hiányzó adatok kezelése**
   - Informatív üzenetek amikor nincs `quantity`
   - Útmutatás hol kell megadni az adatokat:
     - Homlokzati/Tetőszigetelés → "Rendszer tervezés" szekció
     - Nyílászárók → "Felmérő" oldal
     - Hőszivattyú → "Rendszer tervezés" / "Hőszivattyú" szekció

7. **KEHOP összesítő kártya vizuális kiemelése**
   - Teljes megtakarítások összegzése (GJ, kWh, %)
   - 30%-os küszöb ellenőrzése
   - **Vizuális kiemelés:**
     - Zöld háttér (`bg-green-100/dark:bg-green-900`) ha >= 30%
     - Piros/narancssárga háttér (`bg-red-100/dark:bg-red-900`) ha < 30%
   - ✅ vagy ❌ ikon a küszöb státusz mellett
   - Formázott számok (ezres elválasztó)

8. **Automatikus újraszámítás trigger a frontend-en**
   - Watch scenario aktív beruházásaira (`scenario_investments`)
   - Watch mennyiség változásaira (`scenario_main_components.quantity`)
   - Edge Function hívása változás esetén

### Fázis 3: Tesztelés és Finomhangolás (Prioritás: Közepes)
9. **Unit tesztek írása**
   - Konverziós függvények tesztelése (GJ ↔ kWh)
   - Kalkulációs logika tesztelése ismert input/output párokkal
   - Edge Function végpontok tesztelése

10. **Integrácios tesztelés**
    - Teljes flow tesztelése: beruházás kiválasztás → kalkuláció → UI frissülés
    - Automatikus újraszámítás ellenőrzése
    - Hiányzó adatok kezelésének tesztelése

11. **Teljesítmény optimalizálás**
    - Edge Function válaszidő mérése
    - Cache stratégia finomhangolása
    - Felesleges újraszámítások elkerülése (debounce)

### Fázis 4: Dokumentáció és Képzés (Prioritás: Alacsony)
12. **Fejlesztői dokumentáció**
    - Edge Function API dokumentáció
    - Kalkulációs formulák leírása
    - Adatbázis séma frissítések

13. **Felhasználói dokumentáció**
    - Használati útmutató (hogyan értelmezendők a GJ/kWh értékek)
    - KEHOP 30%-os követelmény magyarázata
    - Hibaelhárítás (mi tegyek ha nincs adat)

## Függőségek és Külső Rendszerek

- **OFP Backend (Sherpa):** A kalkulációs logika át lesz másolva, **NINCS aktív API kapcsolat**
- **Supabase Edge Functions:** Új Edge Function: `calculate-energy-savings`
- **Adatbázis táblák:**
  - `scenarios` (energy_savings JSONB oszlop)
  - `scenario_main_components` (mennyiségek)
  - `scenario_investments` (aktív beruházások)
  - `surveys` (survey adatok: hőmérséklet, stb.)

## Kockázatok és Megoldások

| Kockázat | Megoldás |
|----------|----------|
| Komplex kalkulációs logika (PHP → TypeScript) | OFP kód alapos áttanulmányozása, fokozatos implementáció, unit tesztek |
| Adatkonzisztencia | Automatikus újraszámítás minden adat módosításkor (watch + Edge Function hívás) |
| Teljesítmény (gyakori újraszámítások) | Debounce mechanizmus, kalkulált értékek cache-elése DB-ben |
| Hiányzó mennyiségek | Informatív hibaüzenetek, útmutatás a felhasználónak |
| Edge Function timeout | Optimalizált SQL query-k, max 10 sec timeout figyelembe vétele |

## Megjegyzések

### Kalkulációs Logika
- A GJ kalkulációk az OFP-ben **külön logikát** használnak, nem ugyanaz mint a ROI kalkulációk
- **OFP PHP kód átemelése TypeScript-be** (Backend Edge Function)
- **NINCS aktív OFP API kapcsolat** - önálló kalkuláció

### KEHOP Követelmények
- A KEHOP 30%-os küszöb **kötelező** az OFP pályázatokhoz
- Minden survey-nél releváns és megjelenítendő (nem csak OFP-nél)

### Adatforrások
- **Mennyiségek forrása:** `scenario_main_components` tábla `quantity` mezője (nem becsült értékek!)
- **Beruházások:** `scenario_investments` tábla
- **Survey adatok:** `surveys` tábla (hőmérséklet, stb.)

### UI Követelmények
- **Collapsible** energiamegtakarítás részletezés (alapértelmezetten becsukva)
- **Vizuális kiemelés** (zöld/piros) a KEHOP 30%-os követelménynél
- **Minden survey esetén** megjelenjen (nem csak OFP-nél)
- **Pozíció:** Megtérülés szekció előtt
- **Hibaüzenetek:** Informatív útmutatás amikor nincs adat

### Automatizmus
- **Automatikus újraszámítás:** Beruházás ki/be kapcsolása vagy mennyiség módosítása esetén
- **Debounce:** Felesleges újraszámítások elkerülése
- **Cache:** Kalkulált értékek mentése `scenarios.energy_savings` JSONB mezőbe

## Tanácsadó Mód Specifikus Kalkuláció

### Probléma
A Tanácsadó módban az építészeti adatok (fal típusok, szigetelések, ablak kategóriák) **nincsenek kitöltve**, ezért a hagyományos `calculateTheoreticalTotalHeatingEnergy()` függvény irreálisan alacsony elméleti fűtési energia értéket ad vissza (pl. 0.0259 GJ), ami oda vezet, hogy a százalékos megtakarítások irreálisan magasak (pl. 31,460% homlokzati szigetelésre).

### Megoldás: Teljes Éves Energiafogyasztás Alapú Kalkuláció

**Migráció: `100_add_total_consumption_row_to_energy_table.sql`**
- Az `energy_consumption_table` dynamic_table kérdéshez hozzáadtunk egy **új sort a táblázat tetejére**
- **Kategória:** "Teljes éves energiafelhasználás"
- **Sor neve:** "Éves fogyasztás"
- Minden energiahordozóra megadható (Villamos energia kWh/év, Földgáz m³/év, PB gáz kg/év, Tűzifa kg/év, Szén kg/év)

**Edge Function Frissítés:**

Új helper függvény: `calculateTotalEnergyFromConsultantMode()`
- Lekérdezi az `energy_consumption_table` survey answer-t
- Beolvassa a `total_annual_consumption` sor értékeit
- Minden energiahordozóhoz alkalmazza a fűtőérték konverziót:

**Fűtőértékek (MJ per egység) - OFP Sherpa EnergyBalanceProvider alapján:**
```typescript
const HEATING_VALUES = {
  'Villamos energia': 3.6,        // MJ/kWh (1 kWh = 3.6 MJ)
  'Földgáz': 35,                  // MJ/m³
  'PB gáz': 46,                   // MJ/kg
  'Tűzifa, vegyes tüzelő': 16,   // MJ/kg
  'Szén': 22,                     // MJ/kg
  'Napkollektorok éves hőtermelése': 3.6, // MJ/kWh
}
```

**Konverzió GJ-re:**
```typescript
energyGJ = consumption × heatingValueMJ × 0.001 (MJ to GJ)
```

**Fallback logika:**
```typescript
// 6. Calculate theoretical total heating energy
// First, try Consultant Mode (energy_consumption_table)
let theoreticalTotalHeatingEnergyGJ = calculateTotalEnergyFromConsultantMode()

if (theoreticalTotalHeatingEnergyGJ === null) {
  // Fallback to architectural calculation (detailed survey data)
  theoreticalTotalHeatingEnergyGJ = calculateTheoreticalTotalHeatingEnergy()
}
```

**Eredmény:**
- Tanácsadó módban **valós energiafogyasztás alapján** számol a rendszer
- Nem függ az építészeti adatoktól (fal típusok, szigetelés, stb.)
- Realisztikus százalékos megtakarítások (pl. 20-30% homlokzati szigetelésre)
- Részletes felmérés esetén továbbra is működik az építészeti alapú kalkuláció

### Példa Számítás

**Input (Tanácsadó mód):**
- Villamos energia: 3500 kWh/év
- Földgáz: 1200 m³/év

**Konverzió:**
```
Villamos energia GJ = 3500 × 3.6 × 0.001 = 12.6 GJ
Földgáz GJ = 1200 × 35 × 0.001 = 42.0 GJ
─────────────────────────────────────────────
Teljes GJ = 54.6 GJ
```

**Beruházás megtakarítás:**
- Homlokzati szigetelés 120 m²: 8.14 GJ/év megtakarítás
- Százalék: `8.14 / 54.6 × 100 = 14.9%` ✅ (helyesen számolt)

## További Olvasnivaló

- [OFP Integration Documentation](./external-integrations.md)
- [Energy Calculations Technical](./energy-calculations-technical.md)
- [Survey Consultation Page](./survey-consultation-page.md)
