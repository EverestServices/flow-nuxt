/**
 * Test Resend API directly
 * Usage: node scripts/test-resend.js
 */

import 'dotenv/config'

const RESEND_API_KEY = process.env.RESEND_API_KEY

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY not found in .env file')
  console.log('\nPlease add to .env:')
  console.log('RESEND_API_KEY=re_your_key_here\n')
  process.exit(1)
}

console.log('🔍 Testing Resend API...\n')
console.log(`API Key: ${RESEND_API_KEY.substring(0, 10)}...${RESEND_API_KEY.substring(RESEND_API_KEY.length - 4)}\n`)

// Test email
const testEmail = {
  from: 'Flow <onboarding@resend.dev>',
  to: ['malikricsi@hotmail.com'],
  subject: 'Test Email from Flow',
  html: '<h1>Hello!</h1><p>This is a test email from Flow system.</p>',
}

console.log('📧 Sending test email to:', testEmail.to[0])
console.log('📤 From:', testEmail.from)
console.log('')

fetch('https://api.resend.com/emails', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${RESEND_API_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(testEmail),
})
  .then(async response => {
    const responseData = await response.json()

    console.log('Response Status:', response.status)
    console.log('Response Data:', JSON.stringify(responseData, null, 2))
    console.log('')

    if (!response.ok) {
      console.error('❌ Email sending FAILED\n')

      if (responseData.message) {
        console.log('Error message:', responseData.message)
      }

      if (responseData.name === 'validation_error') {
        console.log('\n💡 Common solutions:')
        console.log('   1. In Resend sandbox mode, you can only send to verified emails')
        console.log('      → Go to https://resend.com/emails and verify malikricsi@hotmail.com')
        console.log('   2. Or add a custom domain in Resend dashboard')
        console.log('      → https://resend.com/domains')
      }

      process.exit(1)
    }

    console.log('✅ Email sent successfully!')
    console.log(`📧 Email ID: ${responseData.id}`)
    console.log('\n💡 Check your inbox at malikricsi@hotmail.com')
    console.log('   (It might take a few seconds to arrive)')
  })
  .catch(error => {
    console.error('❌ Network error:', error.message)
    process.exit(1)
  })
