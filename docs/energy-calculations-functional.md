# Energiamegtakarítás Számítások - Funkcionális Dokumentáció

## Tartalomjegyzék
1. [Bevezetés](#bevezetés)
2. [Napelemes Rendszerek](#napelemes-rendszerek)
3. [Hőszivattyúk](#hőszivattyúk)
4. [Homlokzati Szigetelés](#homlokzati-szigetelés)
5. [Tetőszigetelés](#tetőszigetelés)
6. [Ablakcsere](#ablakcsere)
7. [CO₂ Kibocsátás Csökkentés](#co₂-kibocsátás-csökkentés)
8. [Összesített Hatások](#összesített-hatások)

---

## Bevezetés

Ez a dokumentum részletesen bemutatja, hogyan számítjuk ki az egyes energetikai beruházások (napelem, hőszivattyú, szigetelés, ablakcsere) éves energiamegtakarítását, valamint a CO₂ kibocsátás csökkenését.

A számítások célja, hogy **valós, mérhető adatokat** szolgáltassunk a befektetési döntések támogatásához.

---

## Napelemes Rendszerek

### Mi történik?
A napelemes rendszer **elektromos áramot termel** a napfényből, csökkentve vagy akár nullára csökkentve a hálózatról vásárolt áram mennyiségét.

### Hogyan számítjuk?

**Éves áramtermelés (kWh/év) = Panel teljesítmény (kW) × Darabszám × Évi napsugárzás × Hatásfok × Rendszer veszteség korrekció**

#### Példa számítás:
Tegyük fel, hogy:
- **12 darab napelem panel**, egyenként **425W** teljesítménnyel
- Panel hatásfok: **20.5%**
- Magyarországi éves napsugárzás: **1200 kWh/m²**
- Rendszer veszteség (Performance Ratio): **80%**

**Számítás lépései:**
1. Összes panel teljesítmény: 12 × 425W = **5,100W = 5.1 kW**
2. Elméleti termelés: 5.1 kW × 1200 kWh/m²/év = **6,120 kWh/év**
3. Valós termelés (veszteségekkel): 6,120 × 0.80 = **4,896 kWh/év**

**Eredmény:** A rendszer évente mintegy **4,900 kWh** elektromos áramot termel.

### Mit jelent a gyakorlatban?
- Egy átlagos magyar háztartás éves villanyszámlája **50-70%-kal csökkenhet**
- Átlagos háztartási fogyasztás: ~3,500-4,500 kWh/év
- Többlet áram visszatáplálható a hálózatba (kompenzációs rendszer)

---

## Hőszivattyúk

### Mi történik?
A hőszivattyú **elektromos energiából** állít elő hőenergiát, hatékonyabban, mint a gázkazán. Lecseréli a gázfűtést villanyos fűtésre.

**Fontos:** A hőszivattyú **növeli** az áramfogyasztást, de **megszünteti** a gázfogyasztást.

### Hogyan számítjuk?

#### 1. Jelenlegi fűtési igény meghatározása

**Hőigény (kWh/év) = Éves gázfogyasztás (m³) × Gáz energiatartalma (10.55 kWh/m³) × Kazán hatásfoka**

##### Példa:
- Éves gázfogyasztás: **1,500 m³**
- Kazán típusa: **Kondenzációs kazán** (95% hatásfok)
- Hőigény: 1,500 × 10.55 × 0.95 = **15,033 kWh/év**

#### 2. Hőszivattyú áramfogyasztásának számítása

**Áramfogyasztás (kWh/év) = Hőigény / COP**

A **COP** (Coefficient of Performance) azt mutatja, hogy 1 kWh elektromos energiából hány kWh hőenergiát tud előállítani a hőszivattyú.

##### Példa:
- Hőszivattyú COP értéke: **4.5** (1 kWh áramból 4.5 kWh hőt állít elő)
- Áramfogyasztás: 15,033 / 4.5 = **3,341 kWh/év**

#### 3. Eredmény összesítése

| Hatás | Mennyiség |
|-------|-----------|
| **Gáz megtakarítás** | **1,500 m³/év** (teljes gázfogyasztás megszűnik) |
| **Áram többletfogyasztás** | **3,341 kWh/év** (új áramfogyasztás a fűtéshez) |

### Mit jelent a gyakorlatban?
- **Alacsonyabb működési költség:** Bár áramot fogyaszt, a COP miatt hatékonyabb
- **Környezetbarátabb:** Különösen ha napelemes rendszerrel kombinálják
- **Függetlenség a gázártól:** Nem érint a földgáz árának emelkedése

---

## Homlokzati Szigetelés

### Mi történik?
A homlokzati szigetelés **csökkenti a hőveszteséget** a falakon keresztül, így kevesebb fűtésre van szükség télen.

### Hogyan számítjuk?

**Éves hőveszteség csökkenés (kWh/év) = (U_régi - U_új) × Terület (m²) × Fűtési napfok × 24 óra / 1000**

**Gáz megtakarítás (m³/év) = Hőveszteség csökkenés / Gáz energiatartalma / Kazán hatásfoka**

#### Példa számítás:
Feltételek:
- **Szigeteletlen tégla fal:** U-érték = **1.7 W/m²K**
- **Új szigetelés (15 cm EPS):** U-érték = **0.25 W/m²K**
- **Homlokzat terület:** **120 m²**
- **Fűtési napfok:** 3,200 (Magyarország átlag)
- **Kazán hatásfok:** 90%

**Számítás lépései:**
1. U-érték javulás: 1.7 - 0.25 = **1.45 W/m²K**
2. Éves hőveszteség csökkenés:
   - 1.45 × 120 × 3,200 × 24 / 1000 = **13,363 kWh/év**
3. Gázmegtakarítás:
   - 13,363 / 10.55 / 0.90 = **1,408 m³/év**

**Eredmény:** Évi **~1,400 m³ gáz** megtakarítás

### Mit jelent a gyakorlatban?
- Egy átlagos családi házban **20-30% gázmegtakarítás**
- Melegebb, komfortosabb otthon
- Nyáron hűvösebb a ház (klímaköltség csökkenése is)

---

## Tetőszigetelés

### Mi történik?
A tető az épület egyik legnagyobb hőveszteségi felülete. A padlástér szigetelése **drámaian csökkenti** a felfelé távozó hőt.

### Hogyan számítjuk?
**Ugyanaz a módszer, mint a homlokzatnál**, csak más U-értékekkel:

#### Példa számítás:
Feltételek:
- **Szigeteletlen padlásfödém:** U-érték = **1.5 W/m²K**
- **Új szigetelés (18 cm ásványgyapot):** U-érték = **0.21 W/m²K**
- **Padlásfödém terület:** **80 m²**
- **Fűtési napfok:** 3,200
- **Kazán hatásfok:** 90%

**Számítás lépései:**
1. U-érték javulás: 1.5 - 0.21 = **1.29 W/m²K**
2. Éves hőveszteség csökkenés:
   - 1.29 × 80 × 3,200 × 24 / 1000 = **7,925 kWh/év**
3. Gázmegtakarítás:
   - 7,925 / 10.55 / 0.90 = **835 m³/év**

**Eredmény:** Évi **~835 m³ gáz** megtakarítás

---

## Ablakcsere

### Mi történik?
A régi, egyszerű üvegezésű vagy rossz szigetelésű ablakok cseréje **korszerű, háromrétegű üvegezésű** ablakokra jelentősen csökkenti a hőveszteséget.

### Hogyan számítjuk?
**Ugyanaz a módszer, mint a homlokzatnál és tetőnél.**

#### Példa számítás:
Feltételek:
- **Régi fa ablakok, kétréteű üveg:** U-érték = **2.8 W/m²K**
- **Új műanyag ablakok, háromrétegű üveg:** U-érték = **1.3 W/m²K**
- **Összes ablakfelület:** **25 m²**
- **Fűtési napfok:** 3,200
- **Kazán hatásfok:** 90%

**Számítás lépései:**
1. U-érték javulás: 2.8 - 1.3 = **1.5 W/m²K**
2. Éves hőveszteség csökkenés:
   - 1.5 × 25 × 3,200 × 24 / 1000 = **2,880 kWh/év**
3. Gázmegtakarítás:
   - 2,880 / 10.55 / 0.90 = **303 m³/év**

**Eredmény:** Évi **~300 m³ gáz** megtakarítás

---

## CO₂ Kibocsátás Csökkentés

### Mi történik?
Minden megtakarított energia egyben **kevesebb CO₂** kibocsátást is jelent.

### Hogyan számítjuk?

**CO₂ csökkenés (kg/év) = Villany hatás (kWh) × 0.27 + Gáz megtakarítás (m³) × 1.98**

#### Emissziós faktorok:
- **Elektromos áram:** 0.27 kg CO₂/kWh (magyar hálózat átlag)
- **Földgáz:** 1.98 kg CO₂/m³

#### Példa számítás (Kombinált beruházás):
Feltételezzük az alábbi beruházásokat:
- **Napelem:** +4,896 kWh/év áramtermelés
- **Homlokzati szigetelés:** +1,408 m³/év gázmegtakarítás
- **Tetőszigetelés:** +835 m³/év gázmegtakarítás
- **Ablakcsere:** +303 m³/év gázmegtakarítás

**Számítás:**
1. Villany hatás CO₂: 4,896 × 0.27 = **1,322 kg CO₂/év**
2. Gáz megtakarítás összesen: 1,408 + 835 + 303 = **2,546 m³/év**
3. Gáz hatás CO₂: 2,546 × 1.98 = **5,041 kg CO₂/év**
4. **Összes CO₂ csökkenés:** 1,322 + 5,041 = **6,363 kg CO₂/év**

**Eredmény:** Évi **~6.4 tonna CO₂** kibocsátás csökkenés

### Mit jelent a gyakorlatban?
- Megegyezik **~28,000 km autózással** (átlagos személyautó)
- Egyenértékű **~320 fa ültetésével** és 10 éven át történő fenntartásával

---

## Összesített Hatások

### Példa: Komplett Energetikai Felújítás

Egy átlagos családi házon az alábbi beruházások:

| Beruházás | Áram hatás (kWh/év) | Gáz hatás (m³/év) |
|-----------|---------------------|-------------------|
| **Napelemes rendszer (12 panel, 425W)** | +4,896 | 0 |
| **Hőszivattyú csere (COP 4.5)** | -3,341 | +1,500 |
| **Homlokzati szigetelés (120 m²)** | 0 | +1,408 |
| **Tetőszigetelés (80 m²)** | 0 | +835 |
| **Ablakcsere (25 m²)** | 0 | +303 |
| **ÖSSZESEN** | **+1,555 kWh/év** | **+4,046 m³/év** |

#### CO₂ Összesítés:
- Villany: 1,555 × 0.27 = **420 kg CO₂/év**
- Gáz: 4,046 × 1.98 = **8,011 kg CO₂/év**
- **Teljes CO₂ csökkenés: 8,431 kg/év ≈ 8.4 tonna/év**

### Eredmény értelmezése:
1. **Energiafüggetlenség:** Napelemmel fedezhetjük a hőszivattyú és háztartási áramfogyasztást
2. **Gázmentes otthon:** 100%-ban megszűnik a gázfüggőség
3. **Éves költségmegtakarítás:** Jelentős (az energia áraktól függően 500,000-800,000 Ft/év)
4. **Környezeti hatás:** Több mint 8 tonna CO₂ megtakarítás évente

---

## Záró Gondolatok

Ezek a számítások **konzervatív becslésen** alapulnak. A valós eredmények az alábbi tényezőktől függenek:
- Háztartás tényleges energiafogyasztása
- Lakók viselkedése (pl. termosztát beállítás)
- Időjárási viszonyok (hideg/meleg télek)
- Napelemes rendszer tényleges elhelyezkedése és árnyékoltsága

A rendszer célja, hogy **reális képet adjon** a várható megtakarításokról, segítve a megalapozott döntéshozatalt.
