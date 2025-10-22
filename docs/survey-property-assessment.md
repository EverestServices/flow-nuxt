# Survey Property Assessment - Dokumentáció

Ez a dokumentum az Survey Property Assessment funkció fejlesztése során implementált funkcionalitásokat írja le.

## Tartalomjegyzék

1. [Investment és Page címek megjelenítése](#investment-és-page-címek-megjelenítése)
2. [Fordítási rendszer](#fordítási-rendszer)
3. [Feltételes page navigáció](#feltételes-page-navigáció)
4. [Switch komponensek](#switch-komponensek)
5. [DocumentCategory pozíciók és vizualizáció](#documentcategory-pozíciók-és-vizualizáció)

---

## Investment és Page címek megjelenítése

### Probléma
A felmérési oldalon az Investment és SurveyPage navigációs gombok között nem jelentek meg a címek.

### Megoldás
A `SurveyPropertyAssessment.vue` komponensben hiányzó computed property-k pótlása:

```typescript
const activeInvestment = computed(() => store.activeInvestment)
const activePage = computed(() => store.activePage)
```

### Érintett fájlok
- `/app/components/Survey/SurveyPropertyAssessment.vue`

### UI Változások
- Az Investment neve megjelenik a bal és jobb nyíl gombok között
- A SurveyPage neve megjelenik a page navigációs gombok között
- Ikonnal együtt jelennek meg a nevek

---

## Fordítási rendszer

### Probléma
A felmérési kérdések nevei nyers formátumban (pl. `roof_type`) jelentek meg a felületen, magyar fordítások helyett (pl. `Tető típusa`).

### Megoldás
Egyedi fordítási rendszer implementálása a FlowFrontend projektből származó fordításokkal.

### Implementáció

#### 1. Fordítási fájl létrehozása
**Fájl:** `/app/locales/hu.ts`

A fájl két fő részből áll:
- `surveyFields`: Általános felmérési mezők fordításai
- `heatPumpSurvey`: Hőszivattyú-specifikus fordítások

```typescript
export default {
  surveyFields: {
    roof: {
      sectionName: 'Tető',
      roofType: 'Zárófödém típusa',
      roofArea: 'Tető alapterülete',
      // ...
    },
    // ...
  },
  heatPumpSurvey: {
    // ...
  }
}
```

#### 2. Fordítási composable létrehozása
**Fájl:** `/app/composables/useI18n.ts`

A composable három fő funkciót biztosít:

```typescript
export const useI18n = () => {
  const t = (key: string, fallback?: string): string => { /* ... */ }
  const translateField = (fieldName: string): string => { /* ... */ }
  const translatePage = (pageName: string): string => { /* ... */ }

  return { t, translateField, translatePage }
}
```

**Funkciók:**

1. **`t(key, fallback?)`**: Általános fordítás
   - Kulcs alapján keres fordítást
   - Visszaadja a fallback értéket vagy a kulcsot, ha nem talál fordítást

2. **`translateField(fieldName)`**: Mező név fordítása
   - Snake_case-t camelCase-re konvertál
   - Többszintű keresést végez a fordítási objektumban
   - Ha nem talál fordítást, visszaadja az eredeti nevet

3. **`translatePage(pageName)`**: Oldal név fordítása
   - Oldal neveket fordít le
   - Ha nem talál fordítást, visszaadja az eredeti nevet

#### 3. Komponensek frissítése

**SurveyQuestionRenderer.vue:**
```typescript
const { translateField } = useI18n()

const questionLabel = computed(() => {
  return props.question.placeholder_value || translateField(props.question.name)
})
```

**SurveyPropertyAssessment.vue:**
```typescript
const { translatePage } = useI18n()

// Template-ben:
<span>{{ activePage ? translatePage(activePage.name) : '' }}</span>
```

### Érintett fájlok
- `/app/locales/hu.ts` (új)
- `/app/composables/useI18n.ts` (új)
- `/app/components/Survey/SurveyQuestionRenderer.vue`
- `/app/components/Survey/SurveyPropertyAssessment.vue`

### Használat
```typescript
// Komponensben
const { translateField, translatePage } = useI18n()

// Mező fordítása
const label = translateField('roof_type') // => "Tető típusa"

// Oldal fordítása
const pageName = translatePage('roof') // => "Tető"
```

---

## Feltételes page navigáció

### Probléma
Ha egy Investment-hez csak egy SurveyPage tartozott, a page navigációs UI (címke és nyilak) akkor is megjelent, amikor nem volt szükség rá.

### Megoldás
A navigációs UI megjelenítési feltételének módosítása:

**Előtte:**
```vue
<div v-if="activeSurveyPages.length > 0">
```

**Utána:**
```vue
<div v-if="activeSurveyPages.length > 1">
```

### Érintett fájlok
- `/app/components/Survey/SurveyPropertyAssessment.vue` (2 helyen)

### UI Változások
- Ha csak 1 oldal tartozik az Investment-hez, a page navigáció nem jelenik meg
- Több oldal esetén továbbra is működik a navigáció

---

## Switch komponensek

### Probléma
A switch (toggle) komponensek nem renderelődtek a felmérési oldalakon, csak a címkék voltak láthatók.

### Ok
1. **Rossz komponens név**: `UToggle` helyett `USwitch`-et kellett használni (Nuxt UI)
2. **Hibás v-model kezelés**: `:model-value` és `@update:model-value` helyett computed property-vel kellett dolgozni

### Megoldás

#### 1. Komponens név javítása
`UToggle` → `USwitch` minden előfordulási helyen

#### 2. Computed property implementálása
**SurveyQuestionRenderer.vue:**

```typescript
const toggleValue = computed({
  get: () => parseBoolean(props.modelValue ?? props.question.default_value),
  set: (value: boolean) => emit('update:modelValue', value)
})
```

**Template:**
```vue
<USwitch v-model="toggleValue" />
```

#### 3. parseBoolean helper
```typescript
function parseBoolean(value: any): boolean {
  if (typeof value === 'boolean') return value
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true' || value === '1'
  }
  return false
}
```

### Érintett fájlok
- `/app/components/Survey/SurveyQuestionRenderer.vue`
- `/app/components/Survey/SurveyInvestmentModal.vue`
- `/app/components/Survey/SurveyFooter.vue`

### Működés
- A switch komponens most már megfelelően renderelődik
- Az érték változások megfelelően propagálódnak a parent komponensnek
- Boolean értékek helyesen konvertálódnak stringekből

---

## DocumentCategory pozíciók és vizualizáció

### Áttekintés
A DocumentCategory entitások pozicionálása és megjelenítése a házvisualizáció komponensen.

### 1. Adatbázis migráció

#### Fájl: `/supabase/migrations/033_add_positions_to_document_categories.sql`

A migráció a `document_categories` táblában lévő összes kategória `position` mezőjét frissíti JSONB formátumban:

```sql
UPDATE document_categories
SET position = '{"top": 120, "right": 350}'::jsonb
WHERE persist_name = 'roof-condition';
```

#### Kategória csoportok

**Tető-related (roof area):**
- roof-condition
- roof-structure
- roof-access
- attic-condition

**Elektromos (electrical areas):**
- electrical-meter
- electrical-system
- meter-box-interior

**Beltéri berendezések (indoor equipment):**
- inverter-room
- battery-placement
- indoor-unit
- heating-system
- ac-indoor-unit

**Kültéri berendezések (outdoor):**
- outdoor-unit
- ac-outdoor-unit

**Fal-related (wall areas):**
- wall-insulation-area
- wall-condition

**Ablak-related (window areas):**
- window-condition
- window-frame

**Csővezetékek (piping routes):**
- piping-route
- ac-piping-route

**Autó töltő (charging):**
- car-charger-placement
- parking-area

**Solar Panel Battery:**
- site-survey-photos
- meter-location-photos
- connection-point
- electricity-meter-number

**Összesen:** 28 kategória

### 2. Store módosítások

#### Fájl: `/app/stores/surveyInvestments.ts`

**DocumentCategory interface frissítése:**

```typescript
export interface DocumentCategory {
  id: string
  persist_name: string
  name: string
  description: string
  min_photos: number
  position?: { top: number; right: number }  // JSONB pozíció
  investmentPosition?: number  // Junction tábla pozíció
}
```

**Adatbázis lekérdezés:**

```typescript
const { data: docCats, error: docCatsError } = await supabase
  .from('investment_document_categories')
  .select(`
    position,
    investment_id,
    document_category:document_categories (
      id,
      persist_name,
      name,
      description,
      min_photos,
      position
    )
  `)
  .in('investment_id', investmentIds)
  .order('position')
```

**Két pozíció kezelése:**
- `position` (document_categories táblából): Vizualizációs pozíció `{top, right}`
- `investmentPosition` (junction táblából): Sorrend az investment-en belül

### 3. HouseVisualization komponens

#### Fájl: `/app/components/Survey/SurveyHouseVisualization.vue`

**Kategóriák csoportosítása:**

```typescript
const groupedCategories = computed(() => {
  const groups: Record<string, DocumentCategoryWithInvestment[]> = {}

  props.documentCategories.forEach(cat => {
    if (!groups[cat.persist_name]) {
      groups[cat.persist_name] = []
    }
    groups[cat.persist_name].push(cat)
  })

  return groups
})
```

**Miért van szükség csoportosításra?**
- Több investment is használhatja ugyanazt a kategóriát
- Ilyenkor egy gomb több kamera ikonnal jelenik meg
- A `persist_name` alapján csoportosítunk

**Pozicionálás:**

```typescript
const getCategoryButtonPosition = (category: DocumentCategoryWithInvestment, index: number) => {
  if (category.position && category.position.top && category.position.right) {
    return {
      top: `${category.position.top}px`,
      right: `${category.position.right}px`
    }
  }

  // Fallback pozíció, ha nincs megadva
  const baseTop = 150
  const baseRight = 50
  const offset = index * 60

  return {
    top: `${baseTop + offset}px`,
    right: `${baseRight}px`
  }
}
```

**Gomb méret dinamikus beállítása:**

```typescript
const getCategoryButtonSizeByCount = (count: number) => {
  if (count === 1) return 'w-8 h-8'
  if (count === 2) return 'w-10 h-8'
  if (count === 3) return 'w-12 h-8'
  return 'w-14 h-8'
}
```

**Template struktúra:**

```vue
<button
  v-for="(categories, persistName, index) in groupedCategories"
  :key="`category-${persistName}`"
  :class="getCategoryButtonSizeByCount(categories.length)"
  :style="getCategoryButtonPosition(categories[0], index)"
  @click="$emit('category-click', categories[0].id)"
>
  <div class="flex items-center justify-center space-x-0.5">
    <UIcon
      v-for="n in categories.length"
      :key="n"
      name="i-lucide-camera"
      class="w-4 h-4 text-blue-600 dark:text-blue-400"
    />
  </div>
</button>
```

### 4. Parent komponens integráció

#### Fájl: `/app/components/Survey/SurveyPropertyAssessment.vue`

**Összes kategória összegyűjtése:**

```typescript
const allDocumentCategories = computed(() => {
  const categories: Array<{
    id: string
    persist_name: string
    name: string
    description: string
    min_photos: number
    position?: { top: number; right: number }
    investmentPosition?: number
    investmentId: string
    investmentIcon: string
  }> = []

  selectedInvestments.value.forEach(inv => {
    const invCategories = store.documentCategories[inv.id] || []
    invCategories.forEach(cat => {
      categories.push({
        ...cat,
        investmentId: inv.id,
        investmentIcon: inv.icon
      })
    })
  })

  return categories
})
```

**Props átadása:**

```vue
<SurveyHouseVisualization
  :survey-id="surveyId"
  :selected-investments="selectedInvestments"
  :survey-pages="allSurveyPages"
  :document-categories="allDocumentCategories"
  @page-click="handlePageClick"
  @category-click="handleCategoryClick"
/>
```

### Érintett fájlok
- `/supabase/migrations/033_add_positions_to_document_categories.sql` (új)
- `/app/stores/surveyInvestments.ts`
- `/app/components/Survey/SurveyHouseVisualization.vue`
- `/app/components/Survey/SurveyPropertyAssessment.vue`

### UI Működés
1. A házvizualizáción megjelennek a DocumentCategory gombok
2. A gombok pozíciója az adatbázisból jön (JSONB format)
3. Ha több investment használja ugyanazt a kategóriát, több kamera ikon jelenik meg
4. A gomb mérete dinamikusan változik a kamerák száma alapján
5. Tooltip mutatja a kategória nevét hover-re
6. Klikk esemény triggerel a parent komponensben

### Debugging
A következő console.log üzenetek segítenek hibakeresésben:

**Store szint:**
- "Document categories from database:" - Supabase válasz
- "Adding document category:" - Kategória hozzáadása

**Parent komponens:**
- "Document categories for investment X:" - Investment kategóriák
- "All document categories:" - Kombinált tömb

**Child komponens:**
- "Received document categories in HouseVisualization:" - Kapott props
- "Grouped categories:" - Csoportosított struktúra

---

## Egyéb javítások

### CSS padding eltávolítása
**Fájl:** `/app/layouts/default.vue`

Eltávolítva az indokolatlan padding:
- `pb-12` (bottom padding)
- `pr-8` (right padding)

---

---

## Három megjelenítési mód a felmérőlapokhoz

### Áttekintés
A bal oldalon megjelenő felmérőlapok három különböző módban jeleníthetők meg a felhasználói igényeknek megfelelően.

### Módok

#### 1. mód (single)
**Leírás:** Egyetlen SurveyPage jelenik meg egyszerre.

**Elérés:** HouseVisualization SurveyPage gombjára kattintva

**Navigáció:**
- Investment lapozó gombok (← →) - ha több investment van
- Page lapozó gombok (← →) - ha több page van az investment-en belül

**Implementáció:**
```typescript
pageDisplayMode.value = 'single'
```

#### 2. mód (investment)
**Leírás:** Egy Investment összes SurveyPage-e listázódik egymás alatt.

**Elérés:** HouseVisualization jobb felső sarkában lévő lista ikon gombra kattintva

**Navigáció:**
- Csak Investment lapozó gombok (← →) - ha több investment van
- Page lapozó gombok nem jelennek meg

**Megjegyzés:** A lista ikon gomb csak Data vagy All view módban jelenik meg.

**Implementáció:**
```typescript
pageDisplayMode.value = 'investment'
```

#### 3. mód (all)
**Leírás:** Minden kiválasztott Investment összes SurveyPage-e egymás alatt.

**Elérés:** "Fill All Data" gombra kattintva a footer-ben

**Navigáció:**
- Nincs lapozó gomb
- Minden tartalom scrollozható

**Implementáció:**
```typescript
pageDisplayMode.value = 'all'
```

### Technikai megvalósítás

#### State kezelés
**Fájl:** `/app/pages/survey/[surveyId].vue`

```typescript
const pageDisplayMode = ref<'single' | 'investment' | 'all'>('single')
```

#### Computed property-k
**Fájl:** `/app/components/Survey/SurveyPropertyAssessment.vue`

**Megjelenített investments:**
```typescript
const displayedInvestments = computed(() => {
  if (props.pageDisplayMode === 'single') {
    return activeInvestment.value ? [activeInvestment.value] : []
  } else if (props.pageDisplayMode === 'investment') {
    return activeInvestment.value ? [activeInvestment.value] : []
  } else {
    // Mode 3: All selected investments
    return selectedInvestments.value
  }
})
```

**Megjelenített pages per investment:**
```typescript
const getDisplayedPagesForInvestment = (investmentId: string) => {
  const pages = store.surveyPages[investmentId] || []

  if (props.pageDisplayMode === 'single') {
    return pages.filter(p => p.id === activePageId.value)
  } else {
    // Mode 2 & 3: All pages
    return pages
  }
}
```

**Navigációs gombok megjelenítése:**
```typescript
const showInvestmentNavigation = computed(() => {
  return props.pageDisplayMode !== 'all' && selectedInvestments.value.length > 1
})

const showPageNavigation = computed(() => {
  return props.pageDisplayMode === 'single' && activeSurveyPages.value.length > 1
})
```

#### Template struktúra

```vue
<div v-for="investment in displayedInvestments" :key="investment.id">
  <!-- Investment Header -->
  <div v-if="showInvestmentNavigation">
    <!-- Navigation arrows -->
  </div>

  <!-- Pages -->
  <div v-for="page in getDisplayedPagesForInvestment(investment.id)" :key="page.id">
    <!-- Page Header -->
    <div v-if="showPageNavigation">
      <!-- Page navigation arrows -->
    </div>

    <!-- Questions -->
    <div v-for="question in store.surveyQuestions[page.id]">
      <SurveyQuestionRenderer />
    </div>
  </div>
</div>
```

### Lista ikon gomb

**Fájl:** `/app/components/Survey/SurveyHouseVisualization.vue`

```vue
<button
  v-if="viewMode === 'data' || viewMode === 'all'"
  class="absolute top-4 right-4 w-10 h-10 rounded-full bg-white dark:bg-gray-800 border-2 border-primary-500 shadow-lg hover:scale-110 transition-transform flex items-center justify-center z-10"
  @click="$emit('toggle-list-view')"
>
  <UIcon name="i-lucide-list" class="w-5 h-5 text-primary-600 dark:text-primary-400" />
</button>
```

### Érintett fájlok
- `/app/pages/survey/[surveyId].vue`
- `/app/components/Survey/SurveyPropertyAssessment.vue`
- `/app/components/Survey/SurveyHouseVisualization.vue`

---

## Missing Items Modal

### Áttekintés
A Missing Items Modal lehetővé teszi a hiányzó elemek (fotók és kérdések) áttekintését és gyors navigálást hozzájuk.

### Funkciók

#### 1. Hiányos fotó kategóriák

**Listázás:** Azok a DocumentCategory-k, ahol `uploadedCount < min_photos`

**Kártya tartalom:**
- Investment ikon + DocumentCategory név
- "x/y fénykép feltöltve" státusz

**Kattintás hatása:** Upload Photos modal nyílik meg single módban az adott kategóriához

#### 2. Megválaszolatlan kérdések

**Listázás:** Kötelező kérdések (`is_required: true`), amik nincsenek megválaszolva

**Kártya tartalom:**
- Investment név - SurveyPage név (mindkettő fordítva)
- Kérdés címke (fordítva `translateQuestion` segítségével)

**Kattintás hatása:** A megfelelő SurveyPage megnyílik az aktuális display módban

### Footer integráció

**Dinamikus számláló:**
```typescript
const missingItemsCount = computed(() => {
  let count = 0

  // Count missing photo categories
  investmentsStore.selectedInvestments.forEach(investment => {
    const categories = investmentsStore.documentCategories[investment.id] || []
    categories.forEach(category => {
      const uploadedCount = 0 // TODO: Get from store/database
      if (uploadedCount < category.min_photos) {
        count++
      }
    })
  })

  // Count unanswered required questions
  investmentsStore.selectedInvestments.forEach(investment => {
    const pages = investmentsStore.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = investmentsStore.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          const response = investmentsStore.getResponse(question.name)
          if (!response || response === '' || response === null || response === undefined) {
            count++
          }
        }
      })
    })
  })

  return count
})
```

**Warning icon feltételes megjelenítés:**
```vue
<UButton
  :label="`Missing Items (${missingItemsCount})`"
  :icon="missingItemsCount > 0 ? 'i-heroicons-exclamation-triangle' : undefined"
  color="orange"
  variant="outline"
  size="md"
  @click="$emit('show-missing-items')"
/>
```

### Modal szerkezet

**Fájl:** `/app/components/Survey/SurveyMissingItemsModal.vue`

**Struktúra:**
- Külön backdrop div (z-40) - azonnali megjelenés/eltűnés
- Modal tartalma Transition wrapper-be csomagolva (z-50) - animált
- CSS animációk: fade + scale effektek

**Miért fontos ez a struktúra?**
- Biztosítja a helyes Vue reactivity-t
- A modal minden kattintásra újramegjelenik
- Smooth animációk

```vue
<!-- Backdrop -->
<div
  v-if="modelValue"
  class="fixed inset-0 bg-black/50 z-40"
  @click="close"
></div>

<!-- Modal -->
<Transition name="modal-fade">
  <div
    v-if="modelValue"
    class="fixed inset-0 z-50 flex items-center justify-center p-4"
    @click.self="close"
  >
    <!-- Modal content -->
  </div>
</Transition>
```

### Fordítások

**translateQuestion használata:**
```typescript
const { translatePage, translateQuestion } = useI18n()

const label = translateQuestion(question.name)
```

### Érintett fájlok
- `/app/components/Survey/SurveyMissingItemsModal.vue` (új)
- `/app/pages/survey/[surveyId].vue`
- `/app/components/Survey/SurveyFooter.vue`
- `/app/composables/useI18n.ts`

---

## Photo Upload Modal központosítása

### Probléma
A photo upload modal több helyről is nyitható (HouseVisualization, felmérőlap, Missing Items Modal), de az állapotok szétszóródtak.

### Megoldás
Az állapotok (mode, categoryId, investmentId) a survey page szintre kerültek központosításra.

### Implementáció

**State kezelés:**
```typescript
// Photo upload modal states
const showPhotoUploadModal = ref(false)
const photoUploadMode = ref<'single' | 'investment' | 'all'>('single')
const photoUploadCategoryId = ref<string | undefined>()
const photoUploadInvestmentId = ref<string | undefined>()
```

**Eseménykezelők:**

```typescript
// Single mode - category click
const handleOpenPhotoUpload = (categoryId: string) => {
  photoUploadMode.value = 'single'
  photoUploadCategoryId.value = categoryId
  photoUploadInvestmentId.value = undefined
  showPhotoUploadModal.value = true
}

// Investment mode - camera button
const handleOpenCamera = (investmentId: string) => {
  photoUploadMode.value = 'investment'
  photoUploadCategoryId.value = undefined
  photoUploadInvestmentId.value = investmentId
  showPhotoUploadModal.value = true
}

// All mode - upload all photos button
const handleUploadPhotos = () => {
  photoUploadMode.value = 'all'
  photoUploadCategoryId.value = undefined
  photoUploadInvestmentId.value = undefined
  showPhotoUploadModal.value = true
}

// From Missing Items Modal
const handleOpenPhotoUploadFromMissing = (categoryId: string, investmentId: string) => {
  photoUploadMode.value = 'single'
  photoUploadCategoryId.value = categoryId
  photoUploadInvestmentId.value = investmentId
  showPhotoUploadModal.value = true
}
```

### Előnyök
- Központi állapotkezelés
- Különböző helyekről nyitható
- Egységes interface
- Könnyebb karbantartás

### Érintett fájlok
- `/app/pages/survey/[surveyId].vue`
- `/app/components/Survey/SurveyPropertyAssessment.vue`

---

## HouseVisualization toggle

### Funkció
Eye/Eye-slash ikon a fejlécben ki/be kapcsolja a HouseVisualization oszlopot.

### Implementáció

**State:**
```typescript
const showVisualization = ref<boolean>(true)
```

**Handler:**
```typescript
const handleToggleVisualization = (show: boolean) => {
  showVisualization.value = show
}
```

**Dinamikus grid classes:**
```vue
<div :class="showVisualization ? 'grid-cols-1 lg:grid-cols-2' : 'grid-cols-1'">
```

**Ikon váltás:**
```vue
<UButton
  :icon="showVisualization ? 'i-heroicons-eye-slash' : 'i-heroicons-eye'"
  color="gray"
  variant="ghost"
  size="lg"
  @click="handleToggleVisualization"
/>
```

**Feltételes megjelenítés:**
```vue
<div v-if="showVisualization" class="flex items-center justify-center">
  <SurveyHouseVisualization ... />
</div>
```

### Érintett fájlok
- `/app/pages/survey/[surveyId].vue`
- `/app/components/Survey/SurveyHeader.vue`
- `/app/components/Survey/SurveyPropertyAssessment.vue`

---

## Survey Pages sequence (sorrend)

### Áttekintés
A SurveyPage-ek megjelenítési sorrendje a `sequence` oszlop alapján történik, amely az egyes investment-ekhez tartozó oldalak helyes sorrendjét biztosítja.

### 1. Adatbázis módosítások

#### Migration 1: Sequence oszlop hozzáadása
**Fájl:** `/supabase/migrations/036_5_add_sequence_to_survey_pages_table.sql`

```sql
ALTER TABLE public.survey_pages
ADD COLUMN IF NOT EXISTS sequence INTEGER;
```

#### Migration 2: Sequence értékek feltöltése
**Fájl:** `/supabase/migrations/037_add_sequence_to_survey_pages.sql`

A migration feltölti minden investment SurveyPage-einek sequence értékeit a FlowFrontend fixtures alapján.

**Példa - Solar Panel:**
```sql
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'solar_panel' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');
```

**Sorrendek investment-enként:**

- **Solar Panel:** 1. Általános adatok, 2. Napelem, 3. Inverter, 4. Tető
- **Solar Panel + Battery:** 1. Általános adatok, 2. Napelem, 3. Inverter, 4. Akkumulátor, 5. Tető
- **Heat Pump:** 1. Általános adatok, 2. Helyiségek, 3. Nyílászárók, 4. Fűtés alapadatok, 5. Radiátorok, 6. Igényelt konstrukció, 7. Egyéb kérdések
- **Facade Insulation:** 1. Általános adatok, 2. Falak, 3. Tető
- **Battery:** 1. Akkumulátor
- **Car Charger:** 1. Elektromos autó adatok, 2. Helyszín adatok, 3. Teljesítménybővítés
- **Air Conditioner:** 1. Általános adatok, 2. Napelem, 3. Inverter, 4. Tető
- **Roof Insulation:** 1. Általános adatok, 2. Falak, 3. Tető, 4. Nyílászárók
- **Windows:** 1. Általános adatok, 2. Falak, 3. Tető, 4. Nyílászárók

### 2. TypeScript Interface frissítése

**Fájl:** `/app/stores/surveyInvestments.ts`

```typescript
export interface SurveyPage {
  id: string
  investment_id: string
  name: string
  type: string
  position: { top: number; right: number }
  sequence: number  // Új mező
  allow_multiple: boolean
  allow_delete_first: boolean
  item_name_template?: string
}
```

### 3. Store lekérdezés módosítása

**Előtte:**
```typescript
.order('position')
```

**Utána:**
```typescript
.order('sequence')
```

**Teljes kód:**
```typescript
const { data: pages, error: pagesError } = await supabase
  .from('survey_pages')
  .select('*')
  .in('investment_id', investmentIds)
  .order('sequence')  // Sequence alapján rendezi
```

### Érintett fájlok
- `/supabase/migrations/036_5_add_sequence_to_survey_pages_table.sql` (új)
- `/supabase/migrations/037_add_sequence_to_survey_pages.sql` (új)
- `/app/stores/surveyInvestments.ts`

### Előnyök
- Egyértelmű és konfigurálható sorrend
- Függetlenség a position JSONB értékektől
- Könnyű módosíthatóság (sequence érték változtatásával)
- FlowFrontend kompatibilitás

---

## Allow Multiple pages és példánykezelés

### Áttekintés
Bizonyos SurveyPage-ek lehetővé teszik több példány hozzáadását (pl. több tető, több nyílászáró). Ez az `allow_multiple` flag segítségével valósul meg.

### 1. Adatbázis séma

A `survey_pages` táblában:
- `allow_multiple`: BOOLEAN - engedélyezi-e több példány létrehozását
- `allow_delete_first`: BOOLEAN - törölhető-e az utolsó példány is
- `item_name_template`: VARCHAR(255) - példány elnevezési sablon (pl. `{index}. tető`)

### 2. Store implementáció

**Fájl:** `/app/stores/surveyInvestments.ts`

#### PageInstanceData interface
```typescript
export interface PageInstanceData {
  instances: Record<string, any>[]
}
```

#### State bővítése
```typescript
state: () => ({
  // ...
  pageInstances: {} as Record<string, Record<string, PageInstanceData>>,
  activeInstanceIndex: {} as Record<string, number>,
})
```

**Adatstruktúra:**
```
pageInstances: {
  [investmentId]: {
    [pageId]: {
      instances: [
        { roof_type: 'Sátortető', roof_width: '10', ... },
        { roof_type: 'Nyeregtető', roof_width: '8', ... }
      ]
    }
  }
}
```

#### Példánykezelő függvények

**Példányok lekérdezése:**
```typescript
getPageInstances(pageId: string): Record<string, any>[] {
  if (!this.activeInvestmentId) return []

  if (!this.pageInstances[this.activeInvestmentId]) {
    this.pageInstances[this.activeInvestmentId] = {}
  }

  if (!this.pageInstances[this.activeInvestmentId][pageId]) {
    this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
  }

  return this.pageInstances[this.activeInvestmentId][pageId].instances
}
```

**Új példány hozzáadása:**
```typescript
addPageInstance(pageId: string) {
  if (!this.activeInvestmentId) return

  // Initialize if doesn't exist
  if (!this.pageInstances[this.activeInvestmentId]) {
    this.pageInstances[this.activeInvestmentId] = {}
  }
  if (!this.pageInstances[this.activeInvestmentId][pageId]) {
    this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
  }

  // Add new instance
  this.pageInstances[this.activeInvestmentId][pageId].instances.push({})

  // Set as active
  const newIndex = this.pageInstances[this.activeInvestmentId][pageId].instances.length - 1
  this.activeInstanceIndex[pageId] = newIndex
}
```

**Példány törlése:**
```typescript
removePageInstance(pageId: string, index: number, allowDeleteLast: boolean = false) {
  if (!this.activeInvestmentId) return

  const instances = this.pageInstances[this.activeInvestmentId]?.[pageId]?.instances
  if (!instances || instances.length === 0) return

  // Remove the instance
  instances.splice(index, 1)

  // Ensure at least one instance exists (unless allowDeleteLast is true)
  if (instances.length === 0 && !allowDeleteLast) {
    instances.push({})
  }

  // Adjust active index if needed
  const currentActive = this.activeInstanceIndex[pageId] || 0
  if (instances.length > 0 && currentActive >= instances.length) {
    this.activeInstanceIndex[pageId] = instances.length - 1
  } else if (instances.length === 0) {
    this.activeInstanceIndex[pageId] = 0
  }
}
```

**Példány adatok mentése:**
```typescript
saveInstanceResponse(pageId: string, instanceIndex: number, questionName: string, value: any) {
  if (!this.activeInvestmentId || !this.currentSurveyId) return

  // Initialize if doesn't exist
  if (!this.pageInstances[this.activeInvestmentId]) {
    this.pageInstances[this.activeInvestmentId] = {}
  }
  if (!this.pageInstances[this.activeInvestmentId][pageId]) {
    this.pageInstances[this.activeInvestmentId][pageId] = { instances: [{}] }
  }

  const instances = this.pageInstances[this.activeInvestmentId][pageId].instances

  // Ensure instance exists
  while (instances.length <= instanceIndex) {
    instances.push({})
  }

  // Save the value
  instances[instanceIndex][questionName] = value
}
```

### 3. UI Implementáció

**Fájl:** `/app/components/Survey/SurveyPropertyAssessment.vue`

#### Accordion-alapú megjelenítés

```vue
<div v-if="page.allow_multiple" class="space-y-3">
  <!-- Empty state message -->
  <div v-if="getPageInstances(page.id).length === 0" class="text-center">
    <p class="text-sm">Nincs még hozzáadott elem.</p>
    <p class="text-xs mt-1">Kattints az alábbi gombra új hozzáadásához.</p>
  </div>

  <!-- Accordions for each instance -->
  <UAccordion
    v-for="(instance, index) in getPageInstances(page.id)"
    :key="index"
    :items="[{
      label: getInstanceName(page, index),
      slot: `instance-${page.id}-${index}`,
      defaultOpen: index === 0
    }]"
  >
    <template #default="{ item, open }">
      <div class="flex items-center justify-between w-full">
        <span>{{ getInstanceName(page, index) }}</span>
        <!-- Delete button -->
        <button
          v-if="canDeleteInstance(page, index)"
          @click.stop="deleteInstance(page, index)"
        >
          <UIcon name="i-lucide-trash-2" class="w-4 h-4" />
        </button>
      </div>
    </template>

    <template #[`instance-${page.id}-${index}`]>
      <div class="p-4 space-y-6">
        <!-- Normal Questions -->
        <div v-for="question in getNormalQuestions(page.id)" :key="question.id">
          <SurveyQuestionRenderer
            :question="question"
            :model-value="getInstanceQuestionValue(page.id, index, question.name)"
            @update:model-value="updateInstanceQuestionValue(page.id, index, question.name, $event)"
          />
        </div>

        <!-- Special Questions Accordion -->
        <div v-if="getSpecialQuestions(page.id).length > 0">
          <UAccordion :items="[{
            label: 'Egyéb kérdések',
            slot: `special-${page.id}-${index}`,
            defaultOpen: false
          }]">
            <!-- Special questions content -->
          </UAccordion>
        </div>
      </div>
    </template>
  </UAccordion>

  <!-- Add Instance Button -->
  <div class="flex justify-center pt-2">
    <UButton
      :label="`${page.name} hozzáadása`"
      icon="i-lucide-plus"
      @click="addInstance(page.id)"
    />
  </div>
</div>
```

#### Helper függvények

```typescript
const getInstanceName = (page: SurveyPage, index: number) => {
  if (!page.item_name_template) {
    return `${page.name} ${index + 1}`
  }
  return page.item_name_template.replace('{index}', (index + 1).toString())
}

const canDeleteInstance = (page: SurveyPage, index: number) => {
  const instances = store.getPageInstances(page.id)

  if (page.allow_delete_first) {
    return true  // Can delete any instance, even the last one
  }

  return index > 0  // Can only delete non-first instances
}

const deleteInstance = (page: SurveyPage, index: number) => {
  store.removePageInstance(page.id, index, page.allow_delete_first || false)
}
```

### 4. Speciális kérdések kezelése

**Normal vs Special kérdések szétválasztása:**

```typescript
const getNormalQuestions = (pageId: string) => {
  const questions = store.surveyQuestions[pageId] || []
  return questions.filter(q => !q.is_special)
}

const getSpecialQuestions = (pageId: string) => {
  const questions = store.surveyQuestions[pageId] || []
  return questions.filter(q => q.is_special === true)
}
```

**Becsuk gomb az Egyéb kérdések accordion-ban:**

```vue
<UButton
  label="Becsuk"
  color="gray"
  variant="outline"
  size="sm"
  @click="closeAccordion"
/>
```

```typescript
const closeAccordion = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  let current = target.parentElement

  while (current) {
    const buttons = current.querySelectorAll('button')
    for (const button of Array.from(buttons)) {
      if (button.textContent?.includes('Egyéb kérdések')) {
        button.click()
        return
      }
    }
    current = current.parentElement
  }
}
```

### Érintett fájlok
- `/app/stores/surveyInvestments.ts`
- `/app/components/Survey/SurveyPropertyAssessment.vue`
- `/supabase/migrations/036_set_special_questions.sql`

### Példák

**Tető példányok (Solar Panel):**
- allow_multiple: true
- allow_delete_first: false
- item_name_template: "{index}. tető"
- Eredmény: "1. tető", "2. tető", "3. tető"

**Nyílászárók (Heat Pump):**
- allow_multiple: true
- allow_delete_first: true
- item_name_template: "{index}. nyílászáró"
- Eredmény: Minden példány törölhető, akár az utolsó is

### UI Működés
1. Minden példány egy accordion elemben jelenik meg
2. Az első példány alapértelmezetten nyitva van
3. Törlés gomb csak akkor jelenik meg, ha engedélyezett
4. "+ Hozzáadás" gomb mindig elérhető
5. Speciális kérdések külön nested accordion-ban

---

## Investment Icon Management (Database-Driven)

### Áttekintés
Az investment ikonok kezelése teljes mértékben adatbázis-alapúvá vált. A korábban használt hardcoded iconMap objektumok eltávolításra kerültek.

### Változások

**Migrációk:**
- **Migration 061:** `update_solar_battery_icon.sql` - Solar Panel + Battery investment ikonjának frissítése `i-lucide-battery-charging` értékre

**Érintett komponensek:**

#### 1. SurveyScenarioInvestments.vue
**Előtte:**
```typescript
const iconMap: Record<string, string> = {
  'Solar Panel': 'i-lucide-sun',
  'Solar Panel + Battery': 'i-lucide-battery-charging',
  'Heat Pump': 'i-lucide-wind',
  // ... hardcoded mapping
}

const getInvestmentIcon = (investmentName: string) => {
  return iconMap[investmentName] || 'i-lucide-package'
}
```

**Utána:**
```typescript
// Directly use investment.icon from database
icon: investment.icon
```

#### 2. SurveyHeader.vue
**Előtte:**
```typescript
const getScenarioInvestmentIcons = (scenarioId: string) => {
  const investmentIds = props.scenarioInvestments[scenarioId] || []
  const iconMap: Record<string, string> = { /* hardcoded */ }

  return investmentIds
    .map(id => {
      const investment = props.selectedInvestments.find(inv => inv.id === id)
      return investment ? iconMap[investment.name] || 'i-lucide-package' : null
    })
    .filter(Boolean)
}
```

**Utána:**
```typescript
const getScenarioInvestmentIcons = (scenarioId: string) => {
  const investmentIds = props.scenarioInvestments[scenarioId] || []

  return investmentIds
    .map(id => {
      const investment = props.selectedInvestments.find(inv => inv.id === id)
      return investment ? investment.icon : null
    })
    .filter(Boolean)
}
```

### Előnyök
- **Single Source of Truth:** Ikonok az adatbázisban tárolódnak
- **Könnyebb karbantartás:** Új investment hozzáadása nem igényel kódmódosítást
- **Dinamikus:** Ikonok módosíthatók migration-ökkel vagy admin felületről
- **Konzisztencia:** Minden komponens ugyanazt az ikont használja

### Érintett fájlok
- `/supabase/migrations/061_update_solar_battery_icon.sql` (új)
- `/app/components/Survey/SurveyScenarioInvestments.vue`
- `/app/components/Survey/SurveyHeader.vue`

---

## Survey Page Progress Indicators

### Áttekintés
A házvisualizáció SurveyPage gombjai cirkuláris progress indikátorral jelenítik meg a kitöltöttségi százalékot.

### Megjelenés
- **Progress Ring:** SVG-alapú körgyűrű a gomb körül
- **Kezdőpont:** Felül (12 óra pozíció)
- **Irány:** Óramutató járása szerint (clockwise)
- **Színek:**
  - **100% kitöltöttség:** Zöld (`text-green-500 dark:text-green-400`)
  - **<100% kitöltöttség:** Primary kék (`text-primary-500`)
- **Méret:** 40px × 40px (pontosan a gomb mérete)
- **Vastagság:** 2px stroke width
- **Nincs tooltip:** A százalék nem jelenik meg hover-re

### Implementáció

**Fájl:** `/app/components/Survey/SurveyHouseVisualization.vue`

#### Template struktúra
```vue
<div class="absolute group" :style="{ top: page.position.top + 'px', right: page.position.right + 'px' }">
  <!-- Button -->
  <button
    class="relative w-10 h-10 rounded-full bg-white dark:bg-gray-800 shadow-lg transition-transform flex items-center justify-center"
    @click="$emit('page-click', page.id)"
  >
    <UIcon
      :name="getInvestmentIcon(page.investment_id)"
      class="w-5 h-5 text-primary-600 dark:text-primary-400"
    />
  </button>

  <!-- Circular Progress SVG -->
  <svg
    class="absolute inset-0 w-10 h-10 -rotate-90 pointer-events-none"
    viewBox="0 0 40 40"
  >
    <circle
      cx="20"
      cy="20"
      r="18"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      :class="[
        'transition-all duration-300',
        getPageCompletionPercentage(page) === 100
          ? 'text-green-500 dark:text-green-400'
          : 'text-primary-500'
      ]"
      :stroke-dasharray="113.097"
      :stroke-dashoffset="getProgressDashoffset(getPageCompletionPercentage(page))"
    />
  </svg>
</div>
```

#### Completion kalkuláció (Investment-specific)
```typescript
const getPageCompletionPercentage = (page: SurveyPage): number => {
  const questions = store.surveyQuestions[page.id] || []

  // Get only required questions
  const requiredQuestions = questions.filter(q => q.is_required)

  if (requiredQuestions.length === 0) {
    return 100 // If no required questions, consider it complete
  }

  // Count answered required questions (investment-specific)
  const answeredCount = requiredQuestions.filter(question => {
    const response = store.investmentResponses[page.investment_id]?.[question.name]
    return response !== null && response !== undefined && response !== ''
  }).length

  return Math.round((answeredCount / requiredQuestions.length) * 100)
}
```

#### SVG stroke-dashoffset kalkuláció
```typescript
const getProgressDashoffset = (percentage: number): number => {
  const circumference = 2 * Math.PI * 18 // radius is 18
  return circumference - (percentage / 100) * circumference
}
```

### Matematikai alapok
- **Circumference (kerület):** `2 × π × r = 2 × π × 18 ≈ 113.097`
- **stroke-dasharray:** `113.097` (teljes kerület)
- **stroke-dashoffset:** `113.097 - (percentage / 100) × 113.097`
- **-rotate-90:** SVG elforgatása, hogy felülről induljon a progress
- **pointer-events-none:** SVG ne fogja el a kattintás eseményt

### Design döntések
- **Nincs hover scale:** A gombok mérete állandó
- **Nincs z-index:** DOM sorrend biztosítja a helyes rétegelést (SVG a button után)
- **Smooth transition:** 300ms `transition-all duration-300`
- **Rounded linecap:** `stroke-linecap="round"` elegánsabb végpontok

### Érintett fájlok
- `/app/components/Survey/SurveyHouseVisualization.vue` (lines 29-65, 135-159)

---

## Investment-Aware Question Response Tracking (Bugfix)

### Probléma
Ha ugyanolyan kérdés név (`name` mező) létezett 3 különböző Investment-hez tartozó SurveyPage-eken, a Missing Items számláló és a progress indicator helytelenül működött:
- Néha 3-mal csökkent egyetlen válaszadás után a Missing Items értéke
- Néha egyáltalán nem csökkent

### Alapvető ok (Root Cause)
A kérdésekre adott válaszok **investment-specifikusan** vannak tárolva a store-ban:
```typescript
investmentResponses: {
  [investmentId]: {
    [questionName]: value
  }
}
```

**Példa:**
```typescript
investmentResponses: {
  'uuid-solar-panel': {
    'electrical_network_condition': 'Jó állapotú'
  },
  'uuid-heat-pump': {
    'electrical_network_condition': 'Felújítandó'
  },
  'uuid-battery': {
    'electrical_network_condition': '' // Még nincs válasz
  }
}
```

**Probléma a kódban:**
- A `store.getResponse(questionName)` csak az **aktív investment** válaszát nézte
- A Missing Items Modal végigiterált minden investment-en, de mindig a `getResponse()` függvényt hívta
- Így nem az adott investment válaszát kapta, hanem az épp aktív investment-ét

### Megoldás

#### 1. SurveyMissingItemsModal.vue (lines 172-210)

**Előtte (hibás):**
```typescript
const unansweredQuestions = computed<UnansweredQuestion[]>(() => {
  const unanswered: UnansweredQuestion[] = []

  store.selectedInvestments.forEach(investment => {
    const pages = store.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = store.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          const response = store.getResponse(question.name) // ❌ WRONG - uses active investment only
          if (!response || response === '' || response === null || response === undefined) {
            unanswered.push({...})
          }
        }
      })
    })
  })

  return unanswered
})
```

**Utána (helyes):**
```typescript
const unansweredQuestions = computed<UnansweredQuestion[]>(() => {
  const unanswered: UnansweredQuestion[] = []
  const seenQuestions = new Set<string>() // Track by investment + question name

  store.selectedInvestments.forEach(investment => {
    const pages = store.surveyPages[investment.id] || []
    pages.forEach(page => {
      const questions = store.surveyQuestions[page.id] || []
      questions.forEach(question => {
        if (question.is_required) {
          // ✅ Get investment-specific response
          const response = store.investmentResponses[investment.id]?.[question.name]
          if (!response || response === '' || response === null || response === undefined) {
            // Create unique key: investmentId + questionName
            const questionKey = `${investment.id}:${question.name}`

            // Only add if we haven't seen this investment+question combination before
            if (!seenQuestions.has(questionKey)) {
              seenQuestions.add(questionKey)
              unanswered.push({
                id: question.id,
                label: translateField(question.name),
                pageId: page.id,
                pageName: translatePage(page.name),
                investmentId: investment.id,
                investmentName: investment.name,
                investmentIcon: investment.icon
              })
            }
          }
        }
      })
    })
  })

  return unanswered
})
```

#### 2. SurveyHouseVisualization.vue (lines 135-153)

**Előtte (hibás):**
```typescript
const getPageCompletionPercentage = (pageId: string): number => {
  const questions = store.surveyQuestions[pageId] || []
  const requiredQuestions = questions.filter(q => q.is_required)

  if (requiredQuestions.length === 0) {
    return 100
  }

  const answeredCount = requiredQuestions.filter(question => {
    const response = store.getResponse(question.name) // ❌ WRONG - active investment only
    return response !== null && response !== undefined && response !== ''
  }).length

  return Math.round((answeredCount / requiredQuestions.length) * 100)
}
```

**Utána (helyes):**
```typescript
const getPageCompletionPercentage = (page: SurveyPage): number => {
  const questions = store.surveyQuestions[page.id] || []

  // Get only required questions
  const requiredQuestions = questions.filter(q => q.is_required)

  if (requiredQuestions.length === 0) {
    return 100 // If no required questions, consider it complete
  }

  // ✅ Count answered required questions (investment-specific)
  const answeredCount = requiredQuestions.filter(question => {
    const response = store.investmentResponses[page.investment_id]?.[question.name]
    return response !== null && response !== undefined && response !== ''
  }).length

  return Math.round((answeredCount / requiredQuestions.length) * 100)
}
```

### Kulcsváltozások
1. **Direct access:** `store.investmentResponses[investment.id][question.name]` helyett `store.getResponse()`
2. **Page object használata:** `getPageCompletionPercentage` most teljes `page` objektumot kap, nem csak `pageId`-t
3. **Deduplication key:** `investmentId:questionName` formátum a duplikáció elkerülésére
4. **Investment context:** Minden válasz ellenőrzés a megfelelő investment kontextusban történik

### Eredmény
- **Helyes Missing Items számláló:** Minden investment kérdései külön követettek
- **Helyes progress indicator:** Minden page-hez a megfelelő investment válaszai alapján számított progress
- **Nincs duplikáció:** Ugyanolyan nevű kérdések különböző investment-ekhez külön kezeltek

### Érintett fájlok
- `/app/components/Survey/SurveyMissingItemsModal.vue` (lines 172-210)
- `/app/components/Survey/SurveyHouseVisualization.vue` (lines 135-153)

---

## Következő lépések

1. ✅ DocumentCategory gombok renderelése
2. ✅ Fotó feltöltési modal implementálása (3 mód)
3. ✅ "Upload All Photos" funkció
4. ✅ "Fill All Data" funkció (display mode váltás)
5. ✅ Investment icon management (database-driven)
6. ✅ Survey page progress indicators (circular progress)
7. ✅ Investment-aware question response tracking (bugfix)
8. "Generate Assessment Sheet" funkció implementálása
9. Marker Mode implementálása
10. Fotók tényleges feltöltése és tárolása adatbázisban
11. Megválaszolt kérdések mentése adatbázisba

---

## Technológiai stack

- **Frontend:** Nuxt 4.1.2, Vue 3 Composition API
- **State Management:** Pinia
- **Database:** Supabase/PostgreSQL
- **Styling:** Tailwind CSS
- **UI Components:** Nuxt UI
- **Icons:** Lucide (via Nuxt Icon)
- **Type Safety:** TypeScript

---

## Megjegyzések

- A fordítási rendszer jelenleg csak magyar nyelvet támogat
- A DocumentCategory pozíciók a FlowFrontend projektből lettek átmásolva
- A switch komponensek computed property-vel kezelik a boolean értékeket
- A house visualization pozícionálás pixel alapú (absolute positioning)
