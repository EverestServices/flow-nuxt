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

## Következő lépések

1. ✅ DocumentCategory gombok renderelése
2. ✅ Fotó feltöltési modal implementálása (3 mód)
3. ✅ "Upload All Photos" funkció
4. ✅ "Fill All Data" funkció (display mode váltás)
5. "Generate Assessment Sheet" funkció implementálása
6. Marker Mode implementálása
7. ✅ Missing Items tracking és megjelenítése
8. Fotók tényleges feltöltése és tárolása adatbázisban
9. Megválaszolt kérdések mentése adatbázisba

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
