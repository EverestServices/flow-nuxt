#!/bin/bash
# Wrapper script for supabase db reset that handles the storage bucket type mismatch warning
# Usage: ./supabase/db-reset-local.sh

set -e

echo "===================================================================================="
echo "RESETTING LOCAL SUPABASE DATABASE"
echo "===================================================================================="
echo ""

# Run db reset and capture output (the storage error is expected and can be ignored)
echo "Running: npx supabase db reset --local"
echo ""
npx supabase db reset --local 2>&1 || true

echo ""
echo "===================================================================================="
echo "VERIFYING SERVICES"
echo "===================================================================================="
echo ""

# Wait a moment for services to stabilize
echo "[1/3] Waiting for services to stabilize..."
sleep 5

# Check if all key services are running
echo ""
echo "[2/3] Checking service status..."
SERVICES=(
  "supabase_db_flow-nuxt"
  "supabase_storage_flow-nuxt"
  "supabase_auth_flow-nuxt"
  "supabase_kong_flow-nuxt"
  "supabase_realtime_flow-nuxt"
)

ALL_HEALTHY=true
for service in "${SERVICES[@]}"; do
  STATUS=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "not_found")
  HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no_healthcheck{{end}}' "$service" 2>/dev/null || echo "unknown")

  if [ "$STATUS" = "running" ] && ([ "$HEALTH" = "healthy" ] || [ "$HEALTH" = "no_healthcheck" ]); then
    echo "  ✓ $service: $STATUS ($HEALTH)"
  else
    echo "  ✗ $service: $STATUS ($HEALTH)"
    ALL_HEALTHY=false
  fi
done

echo ""
echo "[3/3] Checking database connectivity..."
if docker exec supabase_db_flow-nuxt psql -U postgres -d postgres -c "SELECT COUNT(*) as bucket_count FROM storage.buckets;" > /dev/null 2>&1; then
  BUCKET_COUNT=$(docker exec supabase_db_flow-nuxt psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM storage.buckets;" | tr -d '[:space:]')
  echo "  ✓ Database is accessible (found $BUCKET_COUNT storage buckets)"
else
  echo "  ✗ Database connection failed"
  ALL_HEALTHY=false
fi

echo ""
echo "===================================================================================="
if [ "$ALL_HEALTHY" = true ]; then
  echo "✓ SUCCESS: Local Supabase is ready!"
  echo ""
  echo "Services:"
  echo "  - Studio:   http://localhost:54323"
  echo "  - API:      http://localhost:54321"
  echo "  - Database: postgresql://postgres:postgres@localhost:54322/postgres"
else
  echo "⚠ WARNING: Some services may not be fully ready"
  echo "  Please check: docker ps | grep supabase"
  echo "  And logs: docker logs <container_name>"
fi
echo "===================================================================================="
echo ""

echo "Note: The 'UNION types text and uuid cannot be matched' error during reset"
echo "      is a known issue with Supabase storage-api v1.29.0 but does not prevent"
echo "      the system from functioning correctly."
echo ""
