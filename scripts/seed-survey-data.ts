/**
 * Seed Survey System Data
 *
 * This script seeds the survey system with base data:
 * - Investments
 * - Document Categories
 * - Heavy Consumers
 * - Survey Pages & Questions
 * - Extra Costs
 *
 * Usage:
 *   npx tsx scripts/seed-survey-data.ts
 */

import { createClient } from '@supabase/supabase-js'
import * as fs from 'fs'
import * as path from 'path'

// Load environment variables
const supabaseUrl = process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL
const supabaseKey = process.env.NUXT_PUBLIC_SUPABASE_KEY || process.env.SUPABASE_SERVICE_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing Supabase credentials')
  console.error('Set NUXT_PUBLIC_SUPABASE_URL and NUXT_PUBLIC_SUPABASE_KEY environment variables')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function runMigration() {
  console.log('🌱 Starting survey system seed...\n')

  try {
    // Read the SQL migration file
    const migrationPath = path.join(__dirname, '..', 'supabase', 'migrations', '004_seed_survey_base_data.sql')
    const sql = fs.readFileSync(migrationPath, 'utf-8')

    console.log('📄 Read migration file: 004_seed_survey_base_data.sql')
    console.log('⏳ Executing SQL...\n')

    // Note: Supabase client doesn't support raw SQL execution directly
    // This needs to be run via Supabase CLI or Dashboard
    console.log('⚠️  Direct SQL execution not supported via client.')
    console.log('Please run the migration using one of these methods:\n')
    console.log('1. Supabase CLI:')
    console.log('   npx supabase db push\n')
    console.log('2. Supabase Dashboard:')
    console.log('   - Go to SQL Editor')
    console.log('   - Paste the contents of: supabase/migrations/004_seed_survey_base_data.sql')
    console.log('   - Click Run\n')

    // Alternative: Seed data programmatically
    await seedDataProgrammatically()

  } catch (error: any) {
    console.error('❌ Error during seeding:', error.message)
    process.exit(1)
  }
}

async function seedDataProgrammatically() {
  console.log('🔄 Seeding data programmatically...\n')

  try {
    // 1. Seed Investments
    console.log('📦 Seeding investments...')
    const investments = [
      { name: 'Solar Panel', icon: 'i-lucide-sun', position: { top: 150, right: 300 } },
      { name: 'Solar Panel + Battery', icon: 'i-lucide-sun', position: { top: 150, right: 250 } },
      { name: 'Heat Pump', icon: 'i-lucide-thermometer', position: { top: 200, right: 300 } },
      { name: 'Facade Insulation', icon: 'i-lucide-home', position: { top: 250, right: 100 } },
      { name: 'Roof Insulation', icon: 'i-lucide-home', position: { top: 50, right: 300 } },
      { name: 'Windows', icon: 'i-lucide-square', position: { top: 200, right: 100 } },
      { name: 'Air Conditioner', icon: 'i-lucide-wind', position: { top: 300, right: 200 } },
      { name: 'Battery', icon: 'i-lucide-battery', position: { top: 350, right: 300 } },
      { name: 'Car Charger', icon: 'i-lucide-car', position: { top: 400, right: 350 } }
    ]

    const { data: investmentsData, error: investmentsError } = await supabase
      .from('investments')
      .upsert(investments, { onConflict: 'name', ignoreDuplicates: true })
      .select()

    if (investmentsError) throw investmentsError
    console.log(`✅ Seeded ${investmentsData?.length || investments.length} investments\n`)

    // 2. Seed Heavy Consumers
    console.log('🔌 Seeding heavy consumers...')
    const heavyConsumers = [
      { name: 'Pool Pump' },
      { name: 'Electric Heating' },
      { name: 'Industrial Equipment' },
      { name: 'Sauna' },
      { name: 'Hot Tub' },
      { name: 'Workshop Equipment' },
      { name: 'Server Room' },
      { name: 'Electric Oven' },
      { name: 'Washing Machine' }
    ]

    const { data: consumersData, error: consumersError } = await supabase
      .from('heavy_consumers')
      .upsert(heavyConsumers, { onConflict: 'name', ignoreDuplicates: true })
      .select()

    if (consumersError) throw consumersError
    console.log(`✅ Seeded ${consumersData?.length || heavyConsumers.length} heavy consumers\n`)

    // 3. Seed Document Categories
    console.log('📸 Seeding document categories...')
    const docCategories = [
      { name: 'General Property Photos', description: 'Overall property and building exterior', min_photos: 3, position: { top: 100, right: 200 } },
      { name: 'Roof Photos', description: 'Photos of roof structure, orientation, and condition', min_photos: 5, position: { top: 50, right: 300 } },
      { name: 'Electrical Panel', description: 'Main electrical panel and distribution board', min_photos: 2, position: { top: 250, right: 350 } },
      { name: 'Heating System', description: 'Current heating system and boiler', min_photos: 3, position: { top: 200, right: 300 } },
      { name: 'Facade Photos', description: 'Building facade from all sides', min_photos: 4, position: { top: 250, right: 100 } },
      { name: 'Windows and Doors', description: 'All windows and entry doors', min_photos: 3, position: { top: 200, right: 100 } },
      { name: 'Attic Space', description: 'Attic interior and insulation', min_photos: 2, position: { top: 30, right: 300 } },
      { name: 'Basement/Cellar', description: 'Basement or cellar space', min_photos: 2, position: { top: 400, right: 300 } },
      { name: 'Meter Readings', description: 'Electric, gas, and water meters', min_photos: 1, position: { top: 300, right: 350 } }
    ]

    const { data: categoriesData, error: categoriesError } = await supabase
      .from('document_categories')
      .upsert(docCategories, { onConflict: 'name', ignoreDuplicates: true })
      .select()

    if (categoriesError) throw categoriesError
    console.log(`✅ Seeded ${categoriesData?.length || docCategories.length} document categories\n`)

    // 4. Seed Extra Costs
    console.log('💰 Seeding extra costs...')
    const extraCosts = [
      { name: 'Installation Labor', price: 150000 },
      { name: 'Mounting System', price: 80000 },
      { name: 'Electrical Wiring', price: 45000 },
      { name: 'Smart Meter', price: 35000 },
      { name: 'Scaffolding Rental', price: 120000 },
      { name: 'Building Permit', price: 25000 },
      { name: 'Project Documentation', price: 50000 },
      { name: 'Transportation', price: 30000 },
      { name: 'System Monitoring', price: 40000 },
      { name: 'Extended Warranty', price: 75000 }
    ]

    const { data: costsData, error: costsError } = await supabase
      .from('extra_costs')
      .upsert(extraCosts, { onConflict: 'name', ignoreDuplicates: true })
      .select()

    if (costsError) throw costsError
    console.log(`✅ Seeded ${costsData?.length || extraCosts.length} extra costs\n`)

    console.log('✅ Seed completed successfully!')
    console.log('\n📝 Note: Survey pages and questions need to be seeded via SQL migration')
    console.log('   Run: npx supabase db push')

  } catch (error: any) {
    console.error('❌ Error during programmatic seeding:', error.message)
    throw error
  }
}

// Run the migration
runMigration()
  .then(() => {
    console.log('\n✨ Done!')
    process.exit(0)
  })
  .catch((error) => {
    console.error('\n❌ Failed:', error)
    process.exit(1)
  })
