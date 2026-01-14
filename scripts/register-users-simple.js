/**
 * Simple User Registration Script (No TypeScript required)
 *
 * Usage: node scripts/register-users-simple.js email1@example.com email2@example.com
 */

import 'dotenv/config'

const emails = process.argv.slice(2)

if (emails.length === 0) {
  console.error('\n❌ Error: No email addresses provided\n')
  console.log('Usage: node scripts/register-users-simple.js email1@example.com email2@example.com\n')
  process.exit(1)
}

const supabaseUrl = process.env.SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env file')
  process.exit(1)
}

console.log('\n🚀 Starting user registration process...\n')
console.log(`📧 Registering ${emails.length} user(s):\n`)

const functionUrl = `${supabaseUrl}/functions/v1/register-user-with-email`

fetch(functionUrl, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${supabaseServiceKey}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ emails }),
})
  .then(response => {
    if (!response.ok) {
      return response.text().then(text => {
        throw new Error(`HTTP ${response.status}: ${text}`)
      })
    }
    return response.json()
  })
  .then(result => {
    if (!result.success) {
      console.error('❌ Registration failed:', result.error)
      process.exit(1)
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('                    REGISTRATION RESULTS')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

    let successCount = 0
    let failureCount = 0

    result.results.forEach((user, index) => {
      console.log(`${index + 1}. ${user.email}`)

      if (user.success) {
        successCount++
        console.log(`   ✅ Status: SUCCESS`)
        console.log(`   🔑 Password: ${user.password}`)
        if (user.error) {
          console.log(`   ⚠️  Warning: ${user.error}`)
        }
      } else {
        failureCount++
        console.log(`   ❌ Status: FAILED`)
        console.log(`   ⚠️  Error: ${user.error}`)
      }

      console.log('')
    })

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('                         SUMMARY')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log(`Total users: ${emails.length}`)
    console.log(`✅ Successful: ${successCount}`)
    console.log(`❌ Failed: ${failureCount}`)
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

    console.log('⚠️  IMPORTANT SECURITY NOTES:')
    console.log('   • Save the passwords above in a secure location')
    console.log('   • Users should change their password after first login')
    console.log('   • Do not share passwords via insecure channels')
    console.log('   • Share the passwords with users via a secure channel\n')
  })
  .catch(error => {
    console.error('❌ Error:', error.message)
    process.exit(1)
  })
