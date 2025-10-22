#!/bin/bash

# Supabase configuration
PROJECT_URL="https://ybwyuzjaaoxvbvjqfods.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlid3l1emphYW94dmJ2anFmb2RzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY5MTEwMiwiZXhwIjoyMDQyMjY3MTAyfQ.VbKrFZz4vjIHN3YDIDJmY_pKjhON--lrMnmY0J3TKkg"

echo "📦 Reading migration file..."
SQL=$(cat supabase/migrations/040_enhance_user_profiles_for_settings.sql)

echo "🚀 Applying migration to Supabase..."

# Use curl to post SQL directly to Supabase REST API
curl -X POST \
  "${PROJECT_URL}/rest/v1/rpc/exec_sql" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -d "{\"query\": $(echo "$SQL" | jq -Rs .)}"

echo ""
echo "✨ Migration applied!"
echo ""
echo "📋 Next steps:"
echo "1. Go to Supabase Dashboard → Storage"
echo "2. Create a bucket named 'avatars' (make it public)"
echo "3. Run the storage policies from SUPABASE_SETUP.md"
echo "4. Navigate to /settings in your app to test"
