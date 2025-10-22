import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// Supabase configuration
const supabaseUrl = 'https://ybwyuzjaaoxvbvjqfods.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlid3l1emphYW94dmJ2anFmb2RzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY5MTEwMiwiZXhwIjoyMDQyMjY3MTAyfQ.VbKrFZz4vjIHN3YDIDJmY_pKjhON--lrMnmY0J3TKkg'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function runMigration() {
  try {
    console.log('📦 Reading migration file...')

    const migrationPath = join(__dirname, 'supabase/migrations/040_enhance_user_profiles_for_settings.sql')
    const sql = readFileSync(migrationPath, 'utf8')

    console.log('🚀 Executing migration...')
    console.log('SQL Preview:', sql.substring(0, 200) + '...\n')

    // Split SQL by semicolons and execute each statement
    const statements = sql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'))

    console.log(`Found ${statements.length} SQL statements to execute\n`)

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i]
      if (!statement) continue

      console.log(`Executing statement ${i + 1}/${statements.length}...`)
      console.log(`Preview: ${statement.substring(0, 80)}...`)

      const { data, error } = await supabase.rpc('exec_sql', {
        sql_query: statement + ';'
      })

      if (error) {
        // Try direct execution via REST API
        const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseServiceKey,
            'Authorization': `Bearer ${supabaseServiceKey}`,
          },
          body: JSON.stringify({ sql_query: statement + ';' })
        })

        if (!response.ok) {
          console.error(`❌ Error executing statement ${i + 1}:`, error)
          console.error('Statement:', statement)

          // Continue with next statement
          continue
        }
      }

      console.log(`✅ Statement ${i + 1} executed successfully\n`)
    }

    console.log('✨ Migration completed!')
    console.log('\n📋 Next steps:')
    console.log('1. Go to Supabase Dashboard → Storage')
    console.log('2. Create a bucket named "avatars" (public)')
    console.log('3. Navigate to /settings in your app to test')

  } catch (error) {
    console.error('💥 Migration failed:', error)
    process.exit(1)
  }
}

runMigration()
