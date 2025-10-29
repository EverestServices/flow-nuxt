# Measure Wizard – Functional Overview

This document describes the functional behavior of the Measure Wizard flow, focusing on the wall-by-wall measurement process, data model, user interactions, and persistence. It is intended for developers and product stakeholders.

## Platform assumptions

- The UI is designed tablet-first (touch primary), desktop-second.
- Interaction assumptions on tablets:
  - Single-finger tap = click. Long-press opens context where applicable.
  - Two-finger pinch/zoom and pan in the image container are supported; point dragging suppresses scrolling only while a point is actively dragged.
  - Controls use large touch targets (min 40x40 px), compact labels are hidden on narrow widths and replaced by tooltips.

## High-level flow

- **Entry**: `pages/energy/consultation/[clientId]/measure.vue` wraps content with `MeasureWizard`.
- **Stepper**: `components/measure/MeasureWizard/WallProgressStepper.vue` renders navigable steps for each wall (status-aware pills with chevrons and badges).
- **List vs Detail**:
  - Without `wallId` param: show list and the “Mérés indítása” button (if all prerequisites met).
  - With `wallId`: show the wall measurement screen powered by `ArucoMeasurer.vue`.

## Key components

- `MeasureWizard.vue`
  - Provides the wizard shell and navigation buttons.
  - Computes readiness/prerequisites and routes to the first/next/previous wall.
  - Guards:
    - `MIN_WALL_COUNT = 4`.
    - `allImagesReady`: each wall must have at least one image with `uploadStatus === 'success'` and a `processedImageUrl`.

- `WallProgressStepper.vue`
  - Horizontal, scrollable, clickable steps per wall.
  - Color coding (Nuxt UI Pro color tokens):
    - `success` – the wall has at least one closed polygon (`store.hasPolygons`).
    - `primary` – the wall has at least one uploaded image with success.
    - `neutral` – no image yet.
  - Each step links to `/energy/consultation/[clientId]/measure/[wallId]`.
  - Shows a status badge: `Kész`, `Kép kész`, or `Nincs kép`.

- `ArucoMeasurer.vue`
  - Main measurement UI: image canvas, polygon editing, zoom, calibration, and a polygon list panel (`PolygonList.vue`).
  - Image source fallback: `processedImageUrl || previewUrl` to ensure the canvas can render after upload even before processing completes.
  - Canvas overlays:
    - Draw polygons (fill, stroke, points) with type-based coloring.
    - While editing, show provisional segment to cursor.
    - Show lengths (m) for polygon edges and area (m²) label at center when closed.
  - Editing modes:
    - Toggle edit mode – add points by clicking; close polygon by clicking near the first point (>= 3 points required).
    - Drag points (mouse and touch) with a proximity threshold.
    - Visibility toggles per polygon (does not delete). Hidden polygons are skipped in drawing and area computations.
  - Zoom controls:
    - `zoomScale` with center-preserving scrolling on scale change.
    - Canvas re-renders on zoom/window resize.
  - Calibration mode:
    - User sets two points, enters real length (m), then `meterPerPixel` is recalculated.
    - `restoreCalibration` resets to stored value from the image metadata.
  - Persistence of derived image sizes:
    - On image load, stores `processedImageWidth/Height` for accurate area calculations.

- `PolygonList.vue`
  - Shows each polygon with:
    - Visibility toggle (soft colored icon button).
    - Type selector (USelectMenu) with options for `SurfaceType`.
    - Calculated area in m² if closed.
    - Delete button for a single polygon.
  - "Felületek törlése" clears all polygons (with confirm prompt).

## Data model

- `model/Measure/ArucoWallSurface.ts`
  - `Wall`: `{ id, name, images: WallImage[], polygons: PolygonSurface[], clientId? }`
  - `WallImage`: file metadata + URLs and processed image dims. Key fields:
    - `processedImageUrl?`, `previewUrl?`, `meterPerPixel?`, `processedImageWidth?`, `processedImageHeight?`
  - `PolygonSurface`: `{ id, points: Point[], closed: boolean, visible?, type?, name? }`
  - `SurfaceType`: enum: `WALL_PLINTH`, `FACADE`, `WINDOW_DOOR`.

## Store and persistence

- `stores/WallStore.ts` (Pinia)
  - Holds all walls in `walls: Record<string, Wall>`.
  - API:
    - `setWall(id, wall)` – upsert.
    - `removeWall(id)` – delete.
    - `hasPolygons(wallId)` – at least one closed polygon.
    - `getWallSurfaceAreas(wallId)` – returns grouped areas (gross/net/plinth/window) in m² using image size + `meterPerPixel`.
    - `getTotalAreaByType(type)` and totals as computed props.
  - Persistence:
    - Client-side hydration from `localStorage['wallStore.v1.walls']`.
    - Deep watch writes back on change.
    - Note: blob URLs from uploaded images are not persistent across full reloads.

## Geometry and calculations

- `service/Measurment/polygonDifference.ts`
  - Used by the store to compute union/difference areas between polygon groups.
- `ArucoMeasurer.vue`
  - Converts normalized points to image pixel space using natural image width/height.
  - Edge lengths: Euclidean distance in pixels converted to meters via `meterPerPixel`.
  - Area: polygon shoelace formula in pixels² converted to m².

## Image pipeline (dev/mock)

- `app/mock/index.ts` provides mock endpoints used during local development:
  - `POST /measure/aruco/api/facade/process` → `{ distortion_corrected, real_pixel_size, image_url }` (image_url is a blob URL derived from the uploaded file).
  - `POST /measure/aruco/api/facade/align` → `{ url, pixelSizeInMeter }`.
  - `POST /measure/aruco/api/image/real-size` → `{ pixelSizeInMeter }`.
  - Save/Load: in-memory by `clientId` for quick iteration.
  - Limitation: blob URLs are session-scoped; a hard reload drops them.

## User interactions (summary)

- **Upload image** → wall image `uploadStatus` becomes `success` and `previewUrl/processedImageUrl` updated.
- **Open wall** → `ArucoMeasurer` loads image, sets canvas to image dimension, draws polygons.
- **Zoom** → affects canvas scale; drawing re-renders accordingly.
- **Add polygon** → enter edit mode, click points, close near the first point; polygon becomes closed, area/lengths rendered, affects store totals.
- **Drag points** → hover/click near existing point to move; canvas updates instantly.
- **Toggle visibility** → hide/show polygon rendering and exclude from area calculations.
- **Change type** → selector updates `polygon.type`, totals by type update via store computations.
- **Calibration** → select two points + real length; recompute `meterPerPixel`; lengths/areas update.
- **Delete polygon(s)** → remove a single polygon or all (confirm prompt for all).

## Navigation logic

- **Start measurement** (`Mérés indítása`): Navigates to first wall if `MIN_WALL_COUNT` and image prerequisites are met.
- **Next/Prev**: Buttons call router to move to adjacent wall IDs based on the current route param.
- **Stepper click**: Directly routes to selected wall.

## Known limitations (dev)

- Blob URLs for images do not survive hard reloads.
- SSR hydration: store persistence only runs on client; initial render should tolerate missing image URLs and populate on image load.

## Extensibility notes

- Add new `SurfaceType` by extending enum + options + color mapping in `ArucoMeasurer`.
- Swap mock API to real endpoints without touching UI code as long as response shapes match.
- Consider extracting canvas logic into composables if reuse is planned.

## Measure Canvas UI (tablet-first)

### Layout and overlays

- **[Top-right floating toolbar]** Zoom−, 100%, Zoom+, px/m, Undo, Redo, Reset current edit. Mindig látható a vászonon belül, nagy érintési célokkal.
- **[Top-center helper]** Kalibrációs segédüzenet vékony sávban. Csak kalibráció módban jelenik meg, gombok nélkül.
- **[Top-left reference controls]** Csak kalibráció módban jelennek meg.
  - Láthatóság: kizárólag `calibrationMode === true` esetén.
  - Elrendezés: kompakt, tabletre optimalizált gombcsoport (ikon + rövid címke), nagy érintési célok (≥44px), halvány háttér.
  - Gombok és viselkedés:
    - **Új hozzáadása**
      - Művelet: új referencia indítása; törli a vázlatot (`calibrationStart/End/Length`), kikapcsolja az overlay megjelenítést, és engedélyezi a felülírást.
      - Állapot: mindig aktív kalibráció módban.
    - **Méret módosítása**
      - Művelet: a már mentett referencia hosszát cm-ben módosítja; újraszámolja a m/px-t a két mentett pont távolsága alapján.
      - Állapot: csak akkor aktív, ha `referenceStart` és `referenceEnd` léteznek.
    - **Törlés**
      - Művelet: törli a `referenceStart/End/Length` értékeket; elrejti a mentett vonalat; a mód és gombok újraértékelődnek.
      - Állapot: csak akkor aktív, ha van mentett referencia.
  - Megjegyzés: nincs külön „Show/Hide” gomb; a referencia vonal mentés után mindig látható.
- **[Bottom-center mode bar]** View • Draw Surface • Edit • Setup Reference. Mindig látható.
- **[Bottom-left]** Letöltés (összevont kép poligonokkal, PNG).

### Reference: megjelenítés és státusz

- **[Always visible]** Ha be van állítva referencia, a zöld szaggatott vonal és a végpontok látszanak; View módban a végpont markerek halványabbak lehetnek.
- **[Hossz címke]** A mentett referencia közepe felett „XX cm” jelzés látható.
- **[Kiemelés]** Mentés után rövid “pulse” kiemelés és középre görgetés a gyors visszajelzéshez.

### Calibration flow (state machine)

- **[Setup Reference]** Mindig kalibráció módba lép. Nem indít rajzolást automatikusan.
- **[Meglévő referencia]** Ha már van referencia, a vászonkattintás nem indít új rajzolást, amíg az **Új beállítása** gombot meg nem nyomjuk.
- **[Új rajzolás]** Új beállítása után:
  - **1/2**: első pont megérintése.
  - **2/2**: második pont megérintése. A segédsáv a becsült pixel hosszt is mutatja.
  - A referencia közepén egy lebegő kis panel jelenik meg: px infó + cm beviteli mező + Alkalmaz.
- **[Alkalmaz]** Elmenti a referencia pontokat és hosszt, újraszámolja a `meterPerPixel` értéket, View módba vált, törli a vázlatot, középre görget és kiemel.
- **[Méret módosítása]** Promptban (jelenlegi implementáció) vagy inline (tervezett) cm értéket fogad, és frissíti a `meterPerPixel`-t.
- **[Referencia törlése]** Nullázza a `referenceStart/End/Length` mezőket és eltünteti a vonalat; a módok és gombok az új állapotnak megfelelően frissülnek.

#### Disable/enable részletek

- **Új hozzáadása**: aktív, ha `calibrationMode === true`.
- **Méret módosítása**: aktív, ha `referenceStart && referenceEnd`.
- **Törlés**: aktív, ha `referenceStart && referenceEnd`.
- **Vászon-kattintás kalibráció módban**: ha van mentett referencia és nincs „Új hozzáadása” kezdeményezve (felülírás nincs engedélyezve), akkor a kattintás nem indít új rajzolást.

### Draw és Edit módok

- **[Draw Surface]**
  - Érintéssel pontok hozzáadása; 3+ pont után az első ponthoz közel érintve zárás.
  - Záráskor a poligon bekerül a listába; hosszak és terület (m²) címkék megjelennek.
- **[Edit]**
  - Pont húzás: pont közeli érintésre drag; több pont kijelölése Shift-tel (asztali) vagy UI-ból (tableten opcionális eszköztár).
  - Pont törlés: közeli overlay ikonból; több pont törlése kijelölés után.

### Tablet-first interakciók

- **[Tap]** egyszeri érintés = click.
- **[Pinch/Zoom]** két ujjal nagyítás/kicsinyítés a konténerben, középpont megtartásával.
- **[Pan]** két ujjal görgetés; pont húzás közben a görgetés blokkolva.
- **[Minimum hitbox]** 40–44 px érintési célok; rövid címkék és tooltip-ek keskeny módnál.

### Disable/enable logika (összefoglaló)

- **[Top-left controls]** csak kalibráció módban látszanak. **Méret módosítása** és **Törlés** gombok csak akkor aktívak, ha van referencia.
- **[Új hozzáadása]** mindig elérhető kalibráció módban; megnyomására engedélyezi a felülírást és törli a vázlatot.
- **[Setup Reference]** mindig módba lép; meglévő referencia esetén nem indít rajzolást.

### Top-left reference controls (részletek)

- **Elhelyezés és stílus**
  - Bal felső sarok, a vásznon belül, kompakt háttérrel (blur + féltranszparens), tabletre optimált (≥44px hitboxok).
  - Gombsorrend: Új hozzáadása • Méret módosítása • Referencia törlése.
  - Tooltip-ek: rövid magyarázat minden gombon.
- **Viselkedés (akciók)**
  - **Új hozzáadása**
    - Hatás: `allowRefOverride = true`, `calibrationStart/End/Length = null`, overlay elrejtése.
    - Visszajelzés: top-center segédsáv 1/2 → 2/2 lépései.
  - **Méret módosítása**
    - Hatás: prompt/inline input cm-ben; szám validálás (`> 0`, véges). `meterPerPixel` újraszámolása a mentett két pont távolságából.
    - Perzisztencia: `referenceLengthCm` mentése az aktuális kép meta-adataiba, `store.setWall(...)` hívással.
  - **Referencia törlése**
    - Hatás: `referenceStart/End/Length = null`, elrejtés; store update.
    - Visszajelzés: segédsáv marad, új referencia indítható.
- **Állapotok (enabled/disabled)**
  - Új hozzáadása: aktív, ha `calibrationMode === true`.
  - Méret módosítása: aktív, ha `referenceStart && referenceEnd`.
  - Referencia törlése: aktív, ha `referenceStart && referenceEnd`.
- **Elfogadási kritériumok**
  - A gombcsoport csak kalibráció módban jelenik meg.
  - Meglévő referencia esetén a vászonkattintás nem hoz létre új pontot, amíg az Új hozzáadása nincs megnyomva.
  - Alkalmaz után az overlay eltűnik, View módba vált, a referencia röviden kiemelve, majd stabilan látszik.
