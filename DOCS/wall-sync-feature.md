# Fal és Nyílászáró Szinkronizáció - Marker Mód ↔ Graphic Mód

## Áttekintés

A szinkronizáció funkció automatikusan összekapcsolja a marker módban létrehozott falakat és nyílászárókat a "Homlokzati szigetelés → Falak → Nyílászárók" survey oldallal.

**Előnyök:**
- ✅ Nem kell kétszer bevinni a fal adatokat
- ✅ Marker módban mért területek automatikusan átmásolódnak
- ✅ Fal nevek és tájolások szinkronizálódnak
- ✅ **Nyílászárók (ablakok/ajtók) is automatikusan szinkronizálódnak**
- ✅ Méretek (szélesség, magasság) automatikusan átkerülnek
- ✅ A két rendszer össze van kötve, mindig aktuális adatok

## Működés

### 1. Marker Módban (Mérés)

Amikor a marker módban dolgozol (`/survey/[surveyId]/measure/[wallId]`):

**Falak:**
1. **Falak létrehozása**: A measure wizard-dal hozz létre falakat
2. **Polygonok rajzolása**: Jelöld ki a falfelületeket (homlokzat, nyílászárók, lábazat)
3. **Tájolás beállítása**: Válaszd ki a fal tájolását (É, ÉK, K, DK, D, DNy, Ny, ÉNy)
4. **Név megadása**: Adj egyedi nevet a falnak (pl. "Északi fal", "Déli fal")

**Nyílászárók (Ablakok/Ajtók):**
1. **Rajzolás**: Rajzold be az ablakokat és ajtókat a falon (zöld polygon)
2. **Típus kiválasztása**: Állítsd be, hogy ablak, ajtó vagy erkélyajtó
3. **Árnyékolás** (opcionális): Add meg a külső árnyékoló típusát
4. **Automatikus méret**: A szélesség és magasság automatikusan számolódik a rajzolt területből

### 2. Automatikus Szinkronizáció (Kétirányú!)

A szinkronizáció **automatikusan és kétirányúan** működik:

#### A. Marker mód → Survey (Graphic mód)
- **Kilépéskor**: Amikor a "lista" ikonra kattintasz a marker módban
- **Survey oldal betöltésekor**: Amikor megnyitod a "Homlokzati szigetelés" oldalt
- ✅ **Falak**: nevek, tájolások, területek átmásolódnak
- ✅ **Nyílászárók**: típus, szélesség (cm), magasság (cm), árnyékolás átmásolódik

#### B. Survey (Graphic mód) → Marker mód
- **Új fal létrehozása**: Ha létrehozol egy új fal instance-t a survey oldalon, automatikusan létrejön a marker módban is
- **Fal törlése**: Ha törlöd a falat a survey oldalon, törlődik a marker módból is
- **Tájolás módosítása**: Ha megváltoztatod a tájolást a survey oldalon, frissül a marker módban is
- **Nyílászáró törlése**: Ha törlöd a nyílászárót (ablak/ajtó) a survey oldalon, a rajzolt polygon törlődik a marker módból is
- ✅ A változások azonnal életbe lépnek
- ✅ Ha marad egy "első falfelület" a survey oldalon (alapértelmezett), az a marker módban is létrejön

### 3. Graphic Módban (Survey)

A "Homlokzati szigetelés → Falak" oldalon:

**Falak - Automatikusan kitöltött mezők:**
- ✅ **Fal neve**: A marker módban megadott név (pl. "Északi fal")
- ✅ **Tájolás**: Automatikusan beállított (pl. "É", "K", "D")
- ✅ **Területek** (háttérben tárolva):
  - Homlokzat bruttó terület
  - Homlokzat nettó terület
  - Nyílászárók területe
  - Lábazat területe

**Falak - Manuálisan kitöltendő mezők:**
- ⏳ Fal hossza (m)
- ⏳ Fal magassága (m)
- ⏳ Fal vastagsága (cm)
- ⏳ Lábazat magassága (m)
- ⏳ Egyéb specifikus adatok

**Nyílászárók (Subpage) - Automatikusan kitöltött mezők:**
- ✅ **Típus**: Ablak / Ajtó / Erkélyajtó
- ✅ **Szélesség (cm)**: Automatikusan számolva a rajzból
- ✅ **Magasság (cm)**: Automatikusan számolva a rajzból
- ✅ **Külső árnyékoló típusa**: Nincs / Redőny / Zsalugáter / Zsalúzia / Textil roló

**Nyílászárók - Manuálisan kitöltendő/finomítandó mezők:**
- ⏳ **Mennyiség (db)**: Alapértelmezett 1, de módosítható
- ⏳ **Káva mélység (cm)**: Opcionálisan
- ⏳ **Méretek finomítása**: A számolt értékek felülírhatók

## Technikai Részletek

### Adatstruktúra

#### Marker Mód (WallStore)
```typescript
{
  [surveyId]: {
    [wallId]: {
      id: string,
      name: string,
      orientation: Orientation,
      images: [],
      polygons: PolygonSurface[]
    }
  }
}
```

#### Survey Mód (Page Instances)
```typescript
{
  [investmentId]: {
    [pageId]: {
      instances: [
        {
          _markerWallId: string,    // Hidden: kapcsolat a marker wall-hoz
          wall_name: string,          // Megjelenített név
          wall_orientation: string,   // Tájolás
          _facadeGrossArea: string,   // Háttér: bruttó terület
          _facadeNetArea: string,     // Háttér: nettó terület
          _windowDoorArea: string,    // Háttér: nyílászáró terület
          _wallPlinthArea: string,    // Háttér: lábazat terület
          wall_length: number,        // Manuális
          wall_height: number,        // Manuális
          // ... további mezők
        }
      ]
    }
  }
}
```

### Kapcsolat

A `_markerWallId` hidden field tartalmazza a marker mode wall ID-t, így:
- Egy marker wall mindig ugyanahhoz a survey instance-hoz kapcsolódik
- Ha törölsz egy falat marker módban, a survey instance is törlődik
- Ha módosítod a fal nevét/tájolását, az automatikusan szinkronizálódik

## Használati Esetek

### 1. Új Projekt Indítása

1. Menj a measure oldalra
2. Hozz létre falakat a wizard-dal
3. Minden falnál rajzold meg a felületeket
4. Állítsd be a tájolást és adj nevet
5. Lépj vissza a measure list-re (automatikus sync)
6. Menj a "Homlokzati szigetelés" oldalra
7. ✅ Az összes fal megjelenik, névvel és tájolással

### 2. Fal Módosítása

1. Menj vissza marker módba
2. Módosítsd a fal nevét vagy tájolását
3. Rajzolj további felületeket vagy módosítsd a meglévőket
4. Lépj vissza (automatikus sync)
5. ✅ A változások átkerültek a survey oldalra

### 3. Új Fal Hozzáadása

1. Marker módban hozz létre új falat
2. Rajzold meg a felületeket
3. Lépj vissza (automatikus sync)
4. ✅ Az új fal automatikusan megjelenik a survey oldalon

### 4. Új Fal Hozzáadása Survey Oldalon

1. Graphic módban (Survey → Homlokzati szigetelés → Falak) kattints az "Új hozzáadása" gombra
2. ✅ Automatikusan létrejön egy üres fal a marker módban is
3. ✅ A fal megjelenik a marker mode lista oldalon
4. Később a marker módban kitöltheted képekkel és felületekkel

### 5. Fal Törlése

#### Marker módban törölsz:
1. Marker módban töröld a falat
2. Lépj vissza (automatikus sync)
3. ✅ A fal törlődik a survey oldalról is
4. ✅ Az összes nyílászáró is törlődik

#### Survey oldalon törölsz:
1. Graphic módban (Survey → Homlokzati szigetelés → Falak) töröld a fal instance-t
2. ✅ A fal azonnal törlődik a marker módból is
3. ✅ Az összes nyílászáró (polygon) is törlődik a marker módból
4. ✅ A localStorage-ból is törlődik

### 6. Nyílászáró (Ablak/Ajtó) Törlése

#### Marker módban törölsz:
1. Marker módban töröld a zöld polygon-t (ablak/ajtó)
2. Lépj vissza (automatikus sync)
3. ✅ A nyílászáró törlődik a survey oldalról is

#### Survey oldalon törölsz:
1. Graphic módban (Survey → Homlokzati szigetelés → Falak → Nyílászárók) töröld a nyílászáró instance-t
2. ✅ A rajzolt polygon azonnal törlődik a marker módból is
3. ✅ A localStorage-ból is törlődik

## Korlátok és Tudnivalók

### Ami Automatikus (Falak)
- ✅ Fal neve
- ✅ Tájolás
- ✅ Területek (háttérben tárolva, később használható számításokhoz)

### Ami Manuális (Falak)
- ⏳ Fal hossza és magassága (pontos méretezés)
- ⏳ Fal vastagsága
- ⏳ Lábazat magassága
- ⏳ Egyéb specifikus kérdések

### Ami Automatikus (Nyílászárók)
- ✅ Típus (Ablak / Ajtó / Erkélyajtó)
- ✅ Szélesség (cm) - számolva a rajzból
- ✅ Magasság (cm) - számolva a rajzból
- ✅ Külső árnyékoló típusa

### Ami Manuális/Finomítandó (Nyílászárók)
- ⏳ Mennyiség (db) - alapértelmezett 1
- ⏳ Méretek finomítása (a számolt értékek felülírhatók)
- ⏳ Káva mélység

### Figyelmeztetések
- ⚠️ **Kétirányú törlés (Falak)**: Ha törlöd a falat bármelyik módban, mindkét helyről törlődik (nyílászárókkal együtt)
- ⚠️ **Kétirányú törlés (Nyílászárók)**: Ha törlöd a nyílászárót bármelyik módban, mindkét helyről törlődik
- ⚠️ **Tájolás szinkronizáció**: Ha megváltoztatod a tájolást a survey oldalon, frissül a marker módban is
- ⚠️ Ha manuálisan szerkeszted a survey instance-t, ne módosítsd a `_markerWallId` vagy `_markerPolygonId` mezőket
- ⚠️ A falak hossza/magassága nem számítható automatikusan (csak területek)
- ⚠️ A nyílászárók méretei bounding box alapján számolódnak - lehet, hogy finomítani kell őket

## Fejlesztési Lehetőségek

A jövőben implementálható:
- [ ] Automatikus hossz/magasság számítás a polygon adatokból
- [x] **Teljes kétirányú szinkronizáció (Falak)** - **Implementálva!** ✅
  - [x] Törlés kétirányú
  - [x] Tájolás frissítés kétirányú
  - [x] Új fal létrehozása survey oldalon → marker mód
  - [x] Automatikus fal létrehozás hiányzó instance-okhoz
- [x] **Nyílászárók szinkronizáció** - **Implementálva!** ✅
  - [x] Marker → Survey: típus, méretek, árnyékolás
  - [x] Survey → Marker: törlés szinkronizáció
  - [x] Automatikus méretszámítás a rajzolt területből
- [ ] Vizuális jelzés, hogy mely falak vannak szinkronizálva
- [ ] Szinkronizálási előzmények/napló
- [ ] Manuális szinkronizálás gomb (ne csak automatikus)
- [ ] Név szerkesztés a survey oldalon (jelenleg csak marker módban)

## Hibakeresés

### A falak nem jelennek meg a survey oldalon

**Ellenőrzés:**
1. Van-e "Homlokzati szigetelés" investment kiválasztva a survey-hez?
2. Van-e legalább egy fal létrehozva marker módban?
3. Láttad-e a sync üzenetet a console-ban?

**Megoldás:**
- Lépj be újra a survey oldalra (újra szinkronizál)
- Ellenőrizd a browser console-t hibákért
- Nézd meg a localStorage-t: `wallStore.v2.wallsBySurvey`

### A fal neve nem frissül

**Ellenőrzés:**
1. Elmentett a fal név a marker módban?
2. Visszaléptél-e a marker módból?

**Megoldás:**
- Lépj vissza a measure list-re és menj vissza a survey oldalra
- A sync automatikusan lefut

### Területek nem látszanak

**OK:** A területek háttérben vannak tárolva (`_facadeGrossArea`, stb.)

**Megoldás:** Ezek később használhatók számításokhoz, jelenleg nem jelennek meg a UI-ban.

## Kapcsolódó Fájlok

- `app/composables/useWallSync.ts` - Sync logika
- `app/stores/WallStore.ts` - Marker mód adatok
- `app/stores/surveyInvestments.ts` - Survey page instances
- `app/components/measure/Measure/ArucoMeasurer.vue` - Marker mód UI
- `app/components/Survey/SurveyPropertyAssessment.vue` - Survey UI

## Kérdések?

Ha további kérdéseid vannak, ellenőrizd a kódot vagy konzultálj a fejlesztővel.
