# Supabase Storage Warning

## A "UNION types text and uuid cannot be matched" hiba

Amikor `npx supabase db reset --local` parancsot futtatsz, látni fogsz egy hibát a végén:

```
Error status 500: {"statusCode":"500","code":"DatabaseError","error":"DatabaseError",
"message":"select * from ((select \"id\", \"name\", ... UNION types text and uuid cannot be matched"}
```

## Ez nem probléma!

**Ez a hibaüzenet nem akadályozza meg a rendszer működését.** A Supabase minden szolgáltatás sikeresen elindul és működik, még akkor is, ha ez a hibaüzenet megjelenik.

### Miért jelenik meg ez a hiba?

A Supabase storage-api v1.29.0 verziója a `storage.buckets` és `storage.buckets_analytics` táblákat próbálja UNION-nel egyesíteni, de:
- `storage.buckets.id` típusa: `text`
- `storage.buckets_analytics.id` típusa: `uuid`

PostgreSQL nem tudja ezeket a típusokat automatikusan egyesíteni.

### Ellenőrzés

A `db reset` után futtasd ezt a parancsot, hogy ellenőrizd, minden szolgáltatás fut-e:

```bash
docker ps --filter "name=supabase" --format "table {{.Names}}\t{{.Status}}"
```

Mindnek `Up` és `healthy` állapotban kell lennie.

### Alternatív megoldás

Használd az új wrapper scriptet a könnyebb reset-hez:

```bash
./supabase/db-reset-local.sh
```

Ez a script automatikusan:
1. Lefuttatja a `db reset` parancsot
2. Ellenőrzi, hogy minden szolgáltatás elindult-e
3. Megerősíti, hogy az adatbázis elérhető

### További információ

- Supabase Studio: http://localhost:54323
- API endpoint: http://localhost:54321
- PostgreSQL: postgresql://postgres:postgres@localhost:54322/postgres

## Jövőbeli megoldás

Ez a hiba várhatóan megoldódik egy későbbi Supabase CLI vagy storage-api verzióban. Addig is nyugodtan használhatod a rendszert, mert a hiba nem befolyásolja a működést.
