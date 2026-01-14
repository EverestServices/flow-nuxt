# Felhasználó Regisztráció és E-mail Küldés - Útmutató

Ez az útmutató bemutatja, hogyan lehet felhasználókat regisztrálni a Flow rendszerben, és automatikusan elküldeni nekik a bejelentkezési adataikat e-mailben.

## Előfeltételek

### 1. Resend API Kulcs Beszerzése

A Resend egy modern, fejlesztőbarát e-mail küldési szolgáltatás.

1. Látogass el a [https://resend.com](https://resend.com) oldalra
2. Regisztrálj egy fiókot (ingyenes 100 email/nap)
3. Hozz létre egy új API kulcsot a Dashboard-on
4. Másold ki az API kulcsot (ez csak egyszer jelenik meg!)

### 2. API Kulcs Beállítása Supabase-ben

Az API kulcsot a Supabase Edge Functions környezeti változóiban kell tárolni:

```bash
# Helyi fejlesztéshez (.env fájlban)
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxx

# Production környezethez (Supabase Dashboard vagy CLI)
npx supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxx
```

**Fontos:** Az API kulcsot SOHA ne commitáld a git repository-ba!

### 3. Edge Function Deploy-olása

A regisztrációs funkció egy Supabase Edge Function, amit először deploy-olni kell:

```bash
# Helyi Supabase indítása (ha még nem fut)
npx supabase start

# Edge Function deploy-olása
npx supabase functions deploy register-user-with-email
```

**Production környezetben:**
```bash
# Először állítsd be a projekt ID-t
npx supabase link --project-ref your-project-id

# Majd deploy-old
npx supabase functions deploy register-user-with-email
```

### 4. Resend Domain Beállítása (Opcionális, de ajánlott)

A Resend alapértelmezetten `onboarding@resend.dev` címről küld emaileket, de saját domain-t is használhatsz:

1. Resend Dashboard → Domains
2. Add meg a domain-edet (pl. `everestservices.hu`)
3. Állítsd be a DNS rekordokat (SPF, DKIM, DMARC)
4. Várj, míg a verifikáció sikeres lesz
5. Frissítsd az Edge Function-ben a `from` címet:

```typescript
// supabase/functions/register-user-with-email/index.ts
from: 'Flow <noreply@everestservices.hu>', // Saját domain használata
```

## Használat

### 1. Egy felhasználó regisztrálása

```bash
npm run register:users malikricsi@hotmail.com
```

### 2. Több felhasználó regisztrálása egyszerre

```bash
npm run register:users user1@example.com user2@example.com user3@example.com
```

### 3. Script kimenet

A script a következő információkat jeleníti meg:

```
🚀 Starting user registration process...

📧 Registering 1 user(s):

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    REGISTRATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. malikricsi@hotmail.com
   ✅ Status: SUCCESS
   🔑 Password: Xk9$mP2@wQ7&vL4%
   📧 Email: Sent successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total users: 1
✅ Successful: 1
❌ Failed: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  IMPORTANT SECURITY NOTES:
   • Save the passwords above in a secure location
   • Users should change their password after first login
   • Do not share passwords via insecure channels
   • Users have also received an email with their credentials
```

## E-mail Tartalom

A felhasználók egy szép, formázott HTML emailt kapnak a következő tartalommal:

- Üdvözlő üzenet
- Bejelentkezési adatok (e-mail cím és jelszó)
- Biztonsági figyelmeztetések
- "Bejelentkezés a Flow-ba" gomb (direkt link a login oldalra)
- Everest Services branding

## Biztonsági Szempontok

### Jelszó Generálás

- **Hossz:** 16 karakter
- **Karakterkészlet:** Nagybetűk, kisbetűk, számok, speciális karakterek (!@#$%^&*)
- **Algoritmus:** Kriptográfiailag biztonságos véletlenszám generátor (`crypto.getRandomValues()`)

### E-mail Biztonság

- Az e-mailek HTTPS kapcsolaton keresztül kerülnek elküldésre
- A Resend API TLS titkosítást használ
- Az API kulcsok nem kerülnek bele a git repository-ba

### Felhasználó Fiókok

- A felhasználók automatikusan megerősített email címmel jönnek létre (`email_confirm: true`)
- Első bejelentkezés után ajánlott a jelszó megváltoztatása
- A jelszavak csak a regisztráció során jelennek meg a konzolon és az emailben

## Hibaelhárítás

### "RESEND_API_KEY environment variable not set"

**Probléma:** A Resend API kulcs nincs beállítva.

**Megoldás:**
```bash
# Helyi környezetben
echo "RESEND_API_KEY=re_your_key_here" >> .env

# Production-ben
npx supabase secrets set RESEND_API_KEY=re_your_key_here
```

### "Email sending failed"

**Probléma:** Az email küldés sikertelen volt, de a felhasználó létrejött.

**Megoldás:**
- Ellenőrizd a Resend API kulcsot
- Nézd meg a Resend Dashboard-ot, hogy van-e hiba üzenet
- Ellenőrizd a Resend rate limit-et (ingyenes: 100 email/nap)
- A jelszó megjelenik a konzolon, így manuálisan is megosztható

### "User already registered"

**Probléma:** Az email cím már létezik a rendszerben.

**Megoldás:**
- Használj másik email címet, vagy
- Töröld a meglévő felhasználót a Supabase Dashboard-ról
- Vagy használd a Supabase "Reset Password" funkciót

### E-mail spam mappába kerül

**Probléma:** Az e-mail a spam mappában landol.

**Megoldás:**
- Állíts be saját domain-t a Resend-ben (SPF, DKIM, DMARC)
- Használj ismert domain-t (pl. `everestservices.hu` helyett ne `example.com`-ot)
- Kérd meg a felhasználókat, hogy whitelisteljék a küldő címet

## Továbbfejlesztési Lehetőségek

### 1. CSV Import

Nagyobb mennyiségű felhasználó importálásához:

```typescript
// scripts/register-users-from-csv.ts
import fs from 'fs'
import { parse } from 'csv-parse/sync'

const csvContent = fs.readFileSync('users.csv', 'utf-8')
const records = parse(csvContent, { columns: true })
const emails = records.map(r => r.email)

// Majd call register-users logic
```

### 2. Custom E-mail Template-ek

Különböző e-mail sablonok létrehozása különböző szerepkörökre:

```typescript
function getEmailTemplate(role: 'admin' | 'user' | 'viewer') {
  // Custom HTML template based on role
}
```

### 3. Felhasználói Profilok Automatikus Kitöltése

A regisztráció során a user_profiles táblába is írhatunk adatokat:

```typescript
// Edge Function-ben
await supabaseAdmin
  .from('user_profiles')
  .insert({
    id: authData.user.id,
    full_name: 'Default Name',
    role: 'user',
  })
```

## Kapcsolódó Fájlok

- **Edge Function:** `/supabase/functions/register-user-with-email/index.ts`
- **Script:** `/scripts/register-users.ts`
- **Config:** `/supabase/config.toml`
- **Package.json script:** `register:users`

## Támogatás

Ha bármilyen problémába ütközöl, ellenőrizd a következőket:

1. Supabase logs: `npx supabase functions logs register-user-with-email`
2. Resend Dashboard: [https://resend.com/emails](https://resend.com/emails)
3. .env fájl: Van-e beállítva minden szükséges környezeti változó?

---

**Verzió:** 1.0
**Utolsó frissítés:** 2025-01-13
**Szerző:** Claude (Anthropic)
