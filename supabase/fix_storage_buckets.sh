#!/bin/bash
# Fix storage.buckets.id type mismatch with buckets_analytics
# Run this script after db reset: ./supabase/fix_storage_buckets.sh

set -e

echo "===================================================================================="
echo "FIXING STORAGE BUCKET TYPE MISMATCH"
echo "This script converts storage.buckets.id from text to uuid"
echo "===================================================================================="

# Stop storage container first to prevent conflicts
echo ""
echo "[1/5] Stopping storage container..."
docker stop supabase_storage_flow-nuxt > /dev/null 2>&1 || true

# Wait a moment for container to stop
sleep 2

echo "[2/5] Applying database schema changes..."
# Run the fix as postgres superuser via docker exec on the db container
docker exec -i supabase_db_flow-nuxt psql -U postgres -d postgres <<'EOF' 2>&1 | grep -v "must be owner"
\set ON_ERROR_STOP on

-- Backup existing buckets
CREATE TEMP TABLE IF NOT EXISTS temp_bucket_backup AS SELECT * FROM storage.buckets;

-- Drop FKs (errors are OK - we ignore them)
\set ON_ERROR_STOP off
ALTER TABLE storage.objects DROP CONSTRAINT IF EXISTS objects_bucketId_fkey;
ALTER TABLE storage.prefixes DROP CONSTRAINT IF EXISTS prefixes_bucketId_fkey;
ALTER TABLE storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_bucket_id_fkey;
ALTER TABLE storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_bucket_id_fkey;
\set ON_ERROR_STOP on

-- Change column types
ALTER TABLE storage.buckets ALTER COLUMN id TYPE uuid USING id::uuid;
ALTER TABLE storage.objects ALTER COLUMN bucket_id TYPE uuid USING bucket_id::uuid;
ALTER TABLE storage.prefixes ALTER COLUMN bucket_id TYPE uuid USING bucket_id::uuid;
ALTER TABLE storage.s3_multipart_uploads ALTER COLUMN bucket_id TYPE uuid USING bucket_id::uuid;
ALTER TABLE storage.s3_multipart_uploads_parts ALTER COLUMN bucket_id TYPE uuid USING bucket_id::uuid;

-- Recreate FKs (errors are OK)
\set ON_ERROR_STOP off
ALTER TABLE storage.objects ADD CONSTRAINT objects_bucketId_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE storage.prefixes ADD CONSTRAINT prefixes_bucketId_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE storage.s3_multipart_uploads ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
ALTER TABLE storage.s3_multipart_uploads_parts ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);
\set ON_ERROR_STOP on

\echo 'Schema conversion complete!'
\echo ''
\echo 'Buckets after conversion:'
SELECT id, name, pg_typeof(id) as id_type FROM storage.buckets ORDER BY name;
EOF

echo ""
echo "[3/5] Verifying changes..."
BUCKET_TYPE=$(docker exec supabase_db_flow-nuxt psql -U postgres -d postgres -t -c "SELECT data_type FROM information_schema.columns WHERE table_schema='storage' AND table_name='buckets' AND column_name='id';" | tr -d '[:space:]')

if [ "$BUCKET_TYPE" = "uuid" ]; then
  echo "✓ Bucket ID type is now: uuid"
else
  echo "✗ ERROR: Bucket ID type is still: $BUCKET_TYPE"
  echo "  The conversion may have failed. Please check the database manually."
  exit 1
fi

echo ""
echo "[4/5] Starting storage container..."
docker start supabase_storage_flow-nuxt > /dev/null

echo ""
echo "[5/5] Waiting for storage container to become healthy..."
for i in {1..30}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' supabase_storage_flow-nuxt 2>/dev/null || echo "unknown")
  if [ "$STATUS" = "healthy" ]; then
    echo "✓ Storage container is healthy"
    break
  fi
  echo -n "."
  sleep 1
done

if [ "$STATUS" != "healthy" ]; then
  echo ""
  echo "⚠ Warning: Storage container is not healthy yet (status: $STATUS)"
  echo "  It may still be starting up. Check with: docker ps"
fi

echo ""
echo "===================================================================================="
echo "✓ DONE! Storage bucket types have been fixed."
echo "===================================================================================="
