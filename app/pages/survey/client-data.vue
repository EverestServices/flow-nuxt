<template>
  <div class="min-h-screen relative">
    <!-- Full Screen Map Container (behind everything, only shown when address is complete) -->
    <div v-if="showMap" class="fixed left-24 right-6 top-8 bottom-8 z-0 rounded-3xl overflow-hidden">
      <ClientAddressMap :address="fullAddress" />
    </div>

    <!-- Content Layout -->
    <div class="relative p-6 overflow-y-auto pointer-events-none">
      <!-- Form Column -->
      <div :class="showMap ? 'w-1/2' : 'w-full max-w-2xl mx-auto'" class="pointer-events-auto relative">

        <!-- Progress Section - Fixed Top Center -->
        <div class="absolute left-1/2 transform -translate-x-1/2 z-20 w-full max-w-96 text-center px-6 pointer-events-auto">
          <UIBox>
            <div class="p-4">
              <div class="flex items-center gap-3">
                <div class="flex-1">
                  <div class="flex items-center justify-between mb-2">
                    <h2 class="text-base font-semibold text-gray-900 dark:text-white">
                      {{ progressPercentage < 100 ? (isEditMode ? 'Editing Client' : 'Creating New Client') : 'All Data Filled!' }}
                    </h2>
                    <span class="text-sm font-medium text-gray-600 dark:text-gray-400">
                      {{ Math.round(progressPercentage) }}%
                    </span>
                  </div>
                  <!-- Progress Bar -->
                  <div class="relative h-1.5 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                    <div
                      class="absolute top-0 left-0 h-full bg-blue-500 transition-all duration-300"
                      :style="{ width: `${progressPercentage}%` }"
                    />
                  </div>
                </div>
              </div>
            </div>
          </UIBox>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSaveAndStart" class="space-y-6 mt-24">
          <!-- Personal Information Section -->
          <UIBox>
            <div class="p-6">
              <div class="flex items-center gap-3 mb-6">
                <div class="bg-blue-500 rounded-full p-2">
                  <Icon name="i-lucide-user" class="w-5 h-5 text-white" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Personal Information</h3>
              </div>

              <div class="space-y-4 w-full">
                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Name <span class="text-red-500">*</span>
                  </label>
                  <UIInput
                    v-model="form.name"
                    placeholder="Enter client name"
                    icon="i-lucide-user"
                  />
                </div>

                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Email
                  </label>
                  <UIInput
                    v-model="form.email"
                    type="email"
                    placeholder="Enter email address"
                    icon="i-lucide-mail"
                  />
                </div>

                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Phone
                  </label>
                  <UIInput
                    v-model="form.phone"
                    type="tel"
                    placeholder="Enter phone number"
                    icon="i-lucide-phone"
                  />
                </div>
              </div>
            </div>
          </UIBox>

          <!-- Address Information Section -->
          <UIBox>
            <div class="p-6">
              <div class="flex items-center gap-3 mb-6">
                <div class="bg-blue-500 rounded-full p-2">
                  <Icon name="i-lucide-map-pin" class="w-5 h-5 text-white" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Address Information</h3>
              </div>

              <div class="space-y-4 w-full">
                <!-- Postal Code + City Row -->
                <div class="flex gap-4 w-full">
                  <div class="w-1/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Postal Code <span class="text-red-500">*</span>
                    </label>
                    <UIInput
                      v-model="form.postalCode"
                      placeholder="1234"
                      icon="i-lucide-hash"
                    />
                  </div>

                  <div class="w-2/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      City <span class="text-red-500">*</span>
                    </label>
                    <UIInput
                      v-model="form.city"
                      placeholder="Enter city"
                      icon="i-lucide-building"
                    />
                  </div>
                </div>

                <!-- Street + House Number Row -->
                <div class="flex gap-4 w-full">
                  <div class="w-2/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Street <span class="text-red-500">*</span>
                    </label>
                    <UIInput
                      v-model="form.street"
                      placeholder="Enter street name"
                      icon="i-lucide-map"
                    />
                  </div>

                  <div class="w-1/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      House Number <span class="text-red-500">*</span>
                    </label>
                    <UIInput
                      v-model="form.houseNumber"
                      placeholder="123"
                      icon="i-lucide-home"
                    />
                  </div>
                </div>
              </div>
            </div>
          </UIBox>

          <!-- Error Message -->
          <div v-if="errorMessage">
            <UIBox>
              <div class="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl">
                <div class="flex items-center gap-3">
                  <Icon name="i-lucide-alert-circle" class="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0" />
                  <p class="text-sm text-red-600 dark:text-red-400">{{ errorMessage }}</p>
                </div>
              </div>
            </UIBox>
          </div>

          <!-- Action Buttons -->
          <div class="flex gap-3 justify-center">
            <UIButtonEnhanced
              variant="outline"
              size="lg"
              @click="handleCancel"
              :disabled="isLoading"
            >
              Cancel
            </UIButtonEnhanced>
            <UIButtonEnhanced
              type="submit"
              variant="primary"
              size="lg"
              :disabled="!isFormValid || isLoading"
            >
              <Icon v-if="isLoading" name="i-lucide-loader-2" class="w-4 h-4 mr-2 animate-spin" />
              <Icon v-else name="i-lucide-zap" class="w-4 h-4 mr-2" />
              {{ isLoading ? 'Saving...' : (isEditMode ? 'Save and Continue' : 'Save and Start') }}
            </UIButtonEnhanced>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

definePageMeta({
  layout: 'fullwidth'
})

const router = useRouter()
const route = useRoute()
const supabase = useSupabaseClient()

// Check if we're editing from a survey
const surveyId = computed(() => route.query.surveyId as string | undefined)
const isEditMode = computed(() => !!surveyId.value)

// Loading and error states
const isLoading = ref(false)
const errorMessage = ref('')

const form = ref({
  name: '',
  email: '',
  phone: '',
  postalCode: '',
  city: '',
  street: '',
  houseNumber: ''
})

const clientId = ref<string | null>(null)

// Calculate progress based on required fields
const progressPercentage = computed(() => {
  const requiredFields = ['name', 'postalCode', 'city', 'street', 'houseNumber']
  const filledFields = requiredFields.filter(field => {
    const value = form.value[field as keyof typeof form.value]
    return value && value.trim() !== ''
  })
  return (filledFields.length / requiredFields.length) * 100
})

// Check if form is valid
const isFormValid = computed(() => {
  return form.value.name.trim() &&
         form.value.postalCode.trim() &&
         form.value.city.trim() &&
         form.value.street.trim() &&
         form.value.houseNumber.trim()
})

// Build full address for map
const fullAddress = computed(() => {
  const parts = [
    form.value.postalCode,
    form.value.city,
    form.value.street,
    form.value.houseNumber
  ].filter(part => part && part.trim() !== '')
  return parts.join(' ')
})

// Show map only when all address fields are filled
const showMap = computed(() => {
  return form.value.postalCode.trim() !== '' &&
         form.value.city.trim() !== '' &&
         form.value.street.trim() !== '' &&
         form.value.houseNumber.trim() !== ''
})

// Load client data if editing from survey
onMounted(async () => {
  if (surveyId.value) {
    try {
      // Get survey with client data
      const { data: survey, error } = await supabase
        .from('surveys')
        .select(`
          client_id,
          client:clients (
            id,
            name,
            email,
            phone,
            postal_code,
            city,
            street,
            house_number
          )
        `)
        .eq('id', surveyId.value)
        .single()

      if (error) throw error

      if (survey?.client) {
        clientId.value = survey.client.id
        form.value = {
          name: survey.client.name || '',
          email: survey.client.email || '',
          phone: survey.client.phone || '',
          postalCode: survey.client.postal_code || '',
          city: survey.client.city || '',
          street: survey.client.street || '',
          houseNumber: survey.client.house_number || ''
        }
      }
    } catch (error) {
      console.error('Error loading client data:', error)
    }
  }
})

const handleCancel = () => {
  if (surveyId.value) {
    router.push(`/survey/${surveyId.value}`)
  } else {
    router.push('/survey')
  }
}

const handleSaveAndStart = async () => {
  if (!isFormValid.value) {
    errorMessage.value = 'Please fill in all required fields'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    console.log('Starting save operation...', { isEditMode: isEditMode.value, clientId: clientId.value })

    if (isEditMode.value && clientId.value) {
      // Update existing client
      console.log('Updating existing client:', clientId.value)
      const { error } = await supabase
        .from('clients')
        .update({
          name: form.value.name.trim(),
          email: form.value.email.trim() || null,
          phone: form.value.phone.trim() || null,
          postal_code: form.value.postalCode.trim(),
          city: form.value.city.trim(),
          street: form.value.street.trim(),
          house_number: form.value.houseNumber.trim()
        })
        .eq('id', clientId.value)

      if (error) {
        console.error('Update error:', error)
        throw error
      }

      console.log('Client updated successfully')
      // Navigate back to survey
      router.push(`/survey/${surveyId.value}`)
    } else {
      // Get authenticated user first
      console.log('Getting authenticated user...')
      const { data: { user }, error: authError } = await supabase.auth.getUser()

      if (authError || !user) {
        console.error('Auth error:', authError)
        throw new Error('Not authenticated. Please log in again.')
      }

      console.log('Authenticated user:', user.id)

      // Get company_id from user profile
      console.log('Fetching user profile for company_id...')
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('company_id')
        .eq('user_id', user.id)
        .single()

      console.log('Profile fetch result:', { profile, profileError })

      if (profileError) {
        console.error('Profile fetch error:', profileError)
        throw new Error('Failed to fetch user profile: ' + profileError.message)
      }

      if (!profile?.company_id) {
        console.error('No company_id found in profile')
        throw new Error('No company_id found. Please ensure your profile is set up correctly.')
      }

      // Create new client
      console.log('Creating new client with company_id:', profile.company_id)
      const clientData = {
        company_id: profile.company_id,
        name: form.value.name.trim(),
        email: form.value.email.trim() || null,
        phone: form.value.phone.trim() || null,
        postal_code: form.value.postalCode.trim(),
        city: form.value.city.trim(),
        street: form.value.street.trim(),
        house_number: form.value.houseNumber.trim(),
        status: 'active'
      }
      console.log('Client data to insert:', clientData)

      const { data: newClient, error } = await supabase
        .from('clients')
        .insert(clientData)
        .select()
        .single()

      if (error) {
        console.error('Insert error:', error)
        throw error
      }

      console.log('New client created successfully:', newClient)

      // Create a new survey for this client
      const { data: newSurvey, error: surveyError } = await supabase
        .from('surveys')
        .insert({
          client_id: newClient.id,
          company_id: profile.company_id,
          status: 'draft'
        })
        .select()
        .single()

      if (surveyError) {
        console.error('Survey creation error:', surveyError)
        throw surveyError
      }

      console.log('New survey created successfully:', newSurvey)

      // Navigate to the new survey
      router.push(`/survey/${newSurvey.id}`)
    }
  } catch (error: any) {
    console.error('Error saving client:', error)
    errorMessage.value = error.message || 'Failed to save client data. Please try again.'
  } finally {
    isLoading.value = false
  }
}
</script>
