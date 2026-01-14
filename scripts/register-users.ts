/**
 * User Registration Script with Email Notification
 *
 * This script registers users in the Flow system and sends them
 * their login credentials via email.
 *
 * Usage:
 *   npx tsx scripts/register-users.ts <email1> <email2> ...
 *
 * Example:
 *   npx tsx scripts/register-users.ts user1@example.com user2@example.com
 */

import 'dotenv/config'

interface UserCredential {
  email: string
  password: string
  success: boolean
  error?: string
}

async function registerUsers(emails: string[]): Promise<void> {
  const supabaseUrl = process.env.SUPABASE_URL
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !supabaseServiceKey) {
    console.error('❌ Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env file')
    process.exit(1)
  }

  console.log('\n🚀 Starting user registration process...\n')
  console.log(`📧 Registering ${emails.length} user(s):\n`)

  try {
    // Call the Supabase Edge Function
    const functionUrl = `${supabaseUrl}/functions/v1/register-user-with-email`

    const response = await fetch(functionUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ emails }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('❌ Error calling Edge Function:', errorText)
      process.exit(1)
    }

    const result = await response.json()

    if (!result.success) {
      console.error('❌ Registration failed:', result.error)
      process.exit(1)
    }

    // Display results
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('                    REGISTRATION RESULTS')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

    let successCount = 0
    let failureCount = 0

    result.results.forEach((user: UserCredential, index: number) => {
      console.log(`${index + 1}. ${user.email}`)

      if (user.success) {
        successCount++
        console.log(`   ✅ Status: SUCCESS`)
        console.log(`   🔑 Password: ${user.password}`)
        if (user.error) {
          console.log(`   ⚠️  Warning: ${user.error}`)
        } else {
          console.log(`   📧 Email: Sent successfully`)
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
    console.log('   • Users have also received an email with their credentials\n')

  } catch (error) {
    console.error('❌ Unexpected error:', error)
    process.exit(1)
  }
}

// Main execution
const args = process.argv.slice(2)

if (args.length === 0) {
  console.error('\n❌ Error: No email addresses provided\n')
  console.log('Usage: npx tsx scripts/register-users.ts <email1> <email2> ...\n')
  console.log('Example:')
  console.log('  npx tsx scripts/register-users.ts user@example.com\n')
  process.exit(1)
}

// Validate email format
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const invalidEmails = args.filter(email => !emailRegex.test(email))

if (invalidEmails.length > 0) {
  console.error('\n❌ Error: Invalid email address(es):\n')
  invalidEmails.forEach(email => console.error(`   • ${email}`))
  console.log('')
  process.exit(1)
}

// Run registration
registerUsers(args).catch(error => {
  console.error('Fatal error:', error)
  process.exit(1)
})
