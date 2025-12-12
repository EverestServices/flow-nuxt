# Energia Megtakarítási Százalék Számítás Javítása

**Dátum:** 2025-12-12
**Szerző:** Claude Code
**Típus:** Bugfix / Architectural Decision

---

## Probléma

Az OFP-ből átemelt energia megtakarítási százalék számítás **hibás logikát** használt, ami:

1. ❌ **Pontatlan százalékokat** eredményezett (gyakran >100%)
2. ❌ **Nem reagált** az energiafogyasztás változásaira (10x növelésnél sem változott a %)
3. ❌ **Építészeti hőveszteséget** használt nevezőnek a **valós energiafogyasztás** helyett

### A hibás logika (OFP és eredeti Flow):

```typescript
// ROSSZ ❌
savingsPercentage = megtakarítás / getTheoreticalMaximumHeatingPrimaryEnergyDemand() * 100
```

**getTheoreticalMaximumHeatingPrimaryEnergyDemand** = Fal + Tető + Padló + Ablak + Pince hőveszteség (építészeti adat)

**Probléma**: Ez az **elméleti hőveszteség**, **nem a valós energiafogyasztás**!
- Független a számlákban szereplő adatoktól
- Lehet kisebb vagy nagyobb a valósnál (épület típusától függ)
- **Ezért lehetett >100% a százalék**, mert a megtakarítás több volt, mint az elméleti hőveszteség

### Az OFP-ben lévő TODO komment:

```php
// EnergyEfficiencyConsultingProtocolProvider.php:362
// TODO: Helyett SavingThirtyPercentProvider::calculationActualStatedHeatingEnergyConsumption($clientSurvey)
return round($num / SavingThirtyPercentProvider::getTheoreticalMaximumHeatingPrimaryEnergyDemand($clientSurvey) * 100 ,1);
```

Ez jelzi, hogy az OFP-ben is **tudták a problémát**, de nem javították ki!

---

## Megoldás

### Helyes logika:

```typescript
// HELYES ✅
savingsPercentage = megtakarítás / actualStatedHeatingEnergyConsumption() * 100
```

**actualStatedHeatingEnergyConsumption** = A **tényleges fűtési energiafogyasztás** a számlákból (energy_consumption_table)

---

## Implementáció

### 1. Edge Function Változtatások

**Fájl:** `supabase/functions/calculate-energy-savings/index.ts`

#### Két számítási módszer:

**A) Consultant Mode (energy_consumption_table) - HELYES ✅**
```typescript
function calculateTotalEnergyFromConsultantMode(): number | null {
  // Lekéri az energy_consumption_table -> total_annual_consumption sort
  // Konvertálja GJ-ra minden energiahordozót (Villamos, Gáz, Tűzifa, stb.)

  // Példa:
  // Villamos energia: 3500 kWh × 3.6 MJ/kWh × 0.001 = 12.6 GJ
  // Földgáz: 1200 m³ × 35 MJ/m³ × 0.001 = 42.0 GJ
  // Összesen: 54.6 GJ ✅
}
```

**B) Architectural Calculation (fallback) - NEM AJÁNLOTT ⚠️**
```typescript
function calculateTheoreticalTotalHeatingEnergy(): number {
  // Építészeti hőveszteség számítás U-értékekkel
  // Fal + Tető + Padló + Ablak + Pince

  // Probléma: Ez az ELMÉLETI hőveszteség, nem a VALÓS fogyasztás!
  // Csak fallback-ként használjuk, ha nincs Consultant Mode adat
}
```

#### Új logika:

```typescript
// 6. Calculate theoretical total heating energy
let theoreticalTotalHeatingEnergyGJ = calculateTotalEnergyFromConsultantMode()
let usedConsultantMode = theoreticalTotalHeatingEnergyGJ !== null
const warnings: string[] = []

if (theoreticalTotalHeatingEnergyGJ === null) {
  console.log('❌ CRITICAL: Consultant Mode data (energy_consumption_table) is REQUIRED!')

  // Fallback to architectural calculation (NOT RECOMMENDED)
  const architecturalGJ = calculateTheoreticalTotalHeatingEnergy()
  theoreticalTotalHeatingEnergyGJ = architecturalGJ

  warnings.push('Az energia megtakarítási százalékok PONTATLANOK! Az "Energiafogyasztás" táblázat kitöltése szükséges a pontos számításhoz.')
  warnings.push('Az építészeti számítás NEM alkalmas százalék számításra.')
}
```

### 2. Új Mezők az EnergySavingsResult Interface-ben

```typescript
interface EnergySavingsResult {
  perInvestment: { ... }
  kehopSummary: { ... }
  theoreticalTotalHeatingEnergyGJ: number
  calculatedAt: string
  usedConsultantMode: boolean // ← ÚJ: true = Consultant Mode (HELYES), false = Architectural (HIBÁS)
  warnings?: string[] // ← ÚJ: Figyelmeztetések, ha pontatlan a számítás
}
```

### 3. UI Változtatások

**Fájl:** `app/components/Survey/SurveyConsultationData.vue`

**Figyelmeztetés megjelenítése**, ha architectural calculation-t használt:

```vue
<!-- Warning if architectural calculation was used -->
<div v-if="energySavingsResult.warnings && energySavingsResult.warnings.length > 0" class="mt-3">
  <div class="p-4 bg-yellow-50 dark:bg-yellow-900/20 border-2 border-yellow-500 rounded-lg">
    <div class="flex items-start gap-3">
      <UIcon name="i-lucide-alert-triangle" class="w-5 h-5 text-yellow-600 dark:text-yellow-400" />
      <div class="flex-1">
        <h6 class="text-sm font-semibold text-yellow-900 dark:text-yellow-100 mb-2">
          ⚠️ Figyelmeztetés: Pontatlan számítás
        </h6>
        <ul class="space-y-2">
          <li
            v-for="(warning, index) in energySavingsResult.warnings"
            :key="index"
            class="text-xs text-yellow-800 dark:text-yellow-200"
          >
            {{ warning }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>
```

### 4. Részletes Logging

Az Edge Function minden lépést részletesen logol a Supabase Dashboard-on:

```
╔════════════════════════════════════════════════╗
║  THEORETICAL TOTAL HEATING ENERGY CALCULATION  ║
╚════════════════════════════════════════════════╝

=== CONSULTANT MODE: Energy Consumption Table ===
✅ energy_consumption_table found
✅ total_annual_consumption row found
Energy carriers:
  - Villamos energia: 3500 units × 3.6 MJ/unit = 12.600 GJ
  - Földgáz: 1200 units × 35 MJ/unit = 42.000 GJ
📊 Total from Consultant Mode: 54.600 GJ

╔════════════════════════════════════════════════╗
║  FINAL THEORETICAL TOTAL: 54.600 GJ            ║
║  Method: CONSULTANT MODE ✅                    ║
╚════════════════════════════════════════════════╝
```

**Ha nincs Consultant Mode adat:**

```
❌ CRITICAL: Consultant Mode data (energy_consumption_table) is REQUIRED for percentage calculation!
   The architectural calculation is NOT suitable for percentage calculation.
   Running architectural calculation for diagnostic purposes only...

=== ARCHITECTURAL CALCULATION: Detailed Heat Loss ===
🌡️  Internal temperature: 20°C
🌡️  Temperature difference: 16.4°C

📐 WALL HEAT LOSS CALCULATION
  floor_nm_ground: 100 m²
  ✅ Estimated wall area: 112.00 m²
  ...

📊 TOTAL THEORETICAL HEATING ENERGY: 155.600 GJ

⚠️  Architectural calculation result: 155.600 GJ
   This value is NOT used for percentage calculation.
   Please fill in the energy_consumption_table to get accurate percentages.

⚠️  Using architectural calculation as fallback (NOT RECOMMENDED)

╔════════════════════════════════════════════════╗
║  FINAL THEORETICAL TOTAL: 155.600 GJ           ║
║  Method: ARCHITECTURAL ⚠️                      ║
╚════════════════════════════════════════════════╝
```

---

## Eredmény

### Előtte (hibás):

**Scenario adatok:**
- Homlokzati szigetelés 120 m²: 31.2 GJ megtakarítás
- Elméleti építészeti hőveszteség: 15.6 GJ (rossz nevező!)

**Százalék:**
```
31.2 / 15.6 × 100 = 200% ❌ HIBÁS!
```

### Utána (helyes):

**Scenario adatok:**
- Homlokzati szigetelés 120 m²: 31.2 GJ megtakarítás
- Valós energiafogyasztás (számlák): 54.6 GJ (helyes nevező!)

**Százalék:**
```
31.2 / 54.6 × 100 = 57.1% ✅ HELYES!
```

---

## Hogyan kell használni

### 1. **Tanácsadó mód (Consultant Mode) - KÖTELEZŐ!**

A pontos százalék számításhoz **kötelező kitölteni** az `energy_consumption_table` táblázatot:

**Survey Questions → energy_consumption_table → total_annual_consumption sor:**
- Villamos energia (kWh/év)
- Földgáz (m³/év)
- PB gáz (kg/év)
- Tűzifa, vegyes tüzelő (kg/év)
- Szén (kg/év)
- Napkollektorok éves hőtermelése (kWh/év)

**Példa:**
```
total_annual_consumption: {
  "Villamos energia": 3500,
  "Földgáz": 1200,
  "PB gáz": 0,
  "Tűzifa, vegyes tüzelő": 0,
  "Szén": 0,
  "Napkollektorok éves hőtermelése": 0
}
```

### 2. **Részletes felmérés (Architectural) - NEM AJÁNLOTT százalék számításra**

Ha nincs kitöltve az `energy_consumption_table`, akkor **fallback**-ként használja a részletes építészeti adatokat:
- Fal típusok, vastagsságok, szigetelések
- Tető adatok
- Ablak típusok
- stb.

**DE**: Ez **NEM megfelelő** százalék számításra, mert:
- Elméleti hőveszteséget számol, nem valós fogyasztást
- Gyakran irreális százalékokat ad (>100% vagy <10%)

---

## Logok Nézése

### CLI:
```bash
npx supabase functions logs calculate-energy-savings --tail
```

### Dashboard:
1. [Supabase Dashboard](https://supabase.com/dashboard/project/ybwyuzjaaoxvbvjqfods/functions)
2. Functions → `calculate-energy-savings`
3. Logs tab
4. Indíts számítást a UI-on → Frissítsd a Logs oldalt

---

## Kapcsolódó Fájlok

- `supabase/functions/calculate-energy-savings/index.ts` - Edge Function (fő logika)
- `app/composables/useEnergyCalculations.ts` - Frontend composable
- `app/components/Survey/SurveyConsultationData.vue` - UI komponens
- `supabase/migrations/100_add_total_consumption_row_to_energy_table.sql` - Migráció az energy_consumption_table-hez

---

## Architectural Decision

**Döntés:** Mindig a **Consultant Mode (energy_consumption_table)** adatot használjuk a százalék számításhoz.

**Indoklás:**
1. ✅ A **valós energiafogyasztást** tükrözi (számlák alapján)
2. ✅ **Realisztikus százalékokat** ad (tipikusan 20-40%)
3. ✅ **Reagál az energiafogyasztás változásaira** (ha 10x-esére növeled, változik a %)
4. ✅ **Megegyezik az OFP TODO-ban jelzett helyes módszerrel**

**Fallback (Architectural):**
- Csak **diagnózis/debug** célra használjuk
- **NEM ajánlott** százalék számításra
- **Figyelmeztetést jelez** a UI-on, ha ezt használjuk

---

## Tesztelés

### 1. Helyes működés (Consultant Mode):

1. Töltsd ki az `energy_consumption_table` → `total_annual_consumption` sort
2. Számítsd ki az energia megtakarítást
3. Ellenőrizd a logokban:
   ```
   Method: CONSULTANT MODE ✅
   ```
4. Ellenőrizd a százalékokat: 20-40% körüliek (reális)

### 2. Fallback működés (Architectural - NEM AJÁNLOTT):

1. **NE** töltsd ki az `energy_consumption_table`-t
2. Számítsd ki az energia megtakarítást
3. Ellenőrizd a logokban:
   ```
   Method: ARCHITECTURAL ⚠️
   ```
4. Ellenőrizd a UI-on: **Figyelmeztetés jelenik meg** sárga dobozban

---

## Következő Lépések (Opcionális)

1. **Kötelezővé tenni** az `energy_consumption_table` kitöltését Tanácsadó módban
2. **Eltávolítani** az architectural fallback-et (csak hiba esetén használható)
3. **OFP-ben is javítani** a TODO-ban jelzett problémát

---

**Kérdések esetén:** Nézd meg a logokat (`npx supabase functions logs calculate-energy-savings --tail`)
