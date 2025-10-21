<template>
  <UDashboardPage>
    <UDashboardPanel grow>
      <UDashboardNavbar
        :title="isEditMode ? 'Edit Client - Energy Consultation' : 'New Client - Energy Consultation'"
      >
        <template #right>
          <UButton
            icon="i-heroicons-x-mark"
            color="gray"
            variant="ghost"
            @click="handleCancel"
          />
        </template>
      </UDashboardNavbar>

      <!-- Two Column Layout -->
      <div class="flex h-full">
        <!-- Left Column: Form -->
        <div class="flex-1 p-6 overflow-y-auto w-full">
          <!-- Progress Section -->
          <div class="bg-gradient-to-r from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-4 mb-4">
              <div class="bg-primary-500 rounded-full p-3">
                <UIcon name="i-heroicons-check-circle" class="w-6 h-6 text-white" />
              </div>
              <div class="flex-1">
                <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
                  {{ progressPercentage < 100 ? (isEditMode ? 'Editing Client' : 'Creating New Client') : 'All Data Filled!' }}
                </h2>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  {{ progressPercentage < 100 ? `${Math.round(progressPercentage)}% completed - fill in required fields` : 'Ready to save' }}
                </p>
              </div>
            </div>

            <!-- Progress Bar -->
            <div class="relative h-2 bg-blue-200 dark:bg-blue-800 rounded-full overflow-hidden">
              <div
                class="absolute top-0 left-0 h-full bg-primary-500 transition-all duration-300"
                :style="{ width: `${progressPercentage}%` }"
              />
            </div>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleSaveAndStart" class="space-y-6">
            <!-- Personal Information Section -->
            <div class="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm border border-gray-200 dark:border-gray-700">
              <div class="flex items-center gap-3 mb-6">
                <div class="bg-primary-500 rounded-full p-2">
                  <UIcon name="i-heroicons-user" class="w-5 h-5 text-white" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Personal Information</h3>
              </div>

              <div class="space-y-4 w-full">
                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Name <span class="text-red-500">*</span>
                  </label>
                  <UInput
                    v-model="form.name"
                    placeholder="Enter client name"
                    icon="i-heroicons-user"
                    size="lg"
                  />
                </div>

                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Email
                  </label>
                  <UInput
                    v-model="form.email"
                    type="email"
                    placeholder="Enter email address"
                    icon="i-heroicons-envelope"
                    size="lg"
                  />
                </div>

                <div class="w-full">
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Phone
                  </label>
                  <UInput
                    v-model="form.phone"
                    type="tel"
                    placeholder="Enter phone number"
                    icon="i-heroicons-phone"
                    size="lg"
                  />
                </div>
              </div>
            </div>

            <!-- Address Information Section -->
            <div class="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm border border-gray-200 dark:border-gray-700">
              <div class="flex items-center gap-3 mb-6">
                <div class="bg-primary-500 rounded-full p-2">
                  <UIcon name="i-heroicons-map-pin" class="w-5 h-5 text-white" />
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
                    <UInput
                      v-model="form.postalCode"
                      placeholder="1234"
                      icon="i-heroicons-hashtag"
                      size="lg"
                    />
                  </div>

                  <div class="w-2/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      City <span class="text-red-500">*</span>
                    </label>
                    <UInput
                      v-model="form.city"
                      placeholder="Enter city"
                      icon="i-heroicons-building-office-2"
                      size="lg"
                    />
                  </div>
                </div>

                <!-- Street + House Number Row -->
                <div class="flex gap-4 w-full">
                  <div class="w-2/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Street <span class="text-red-500">*</span>
                    </label>
                    <UInput
                      v-model="form.street"
                      placeholder="Enter street name"
                      icon="i-heroicons-map"
                      size="lg"
                    />
                  </div>

                  <div class="w-1/3">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      House Number <span class="text-red-500">*</span>
                    </label>
                    <UInput
                      v-model="form.houseNumber"
                      placeholder="123"
                      icon="i-heroicons-home"
                      size="lg"
                    />
                  </div>
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex gap-3 justify-end">
              <UButton
                color="gray"
                variant="outline"
                size="lg"
                @click="handleCancel"
              >
                Cancel
              </UButton>
              <UButton
                type="submit"
                color="primary"
                size="lg"
                icon="i-heroicons-bolt"
                :disabled="!isFormValid"
              >
                {{ isEditMode ? 'Save and Continue Consultation' : 'Save and Start Consultation' }}
              </UButton>
            </div>
          </form>
        </div>

        <!-- Right Column: Map -->
        <div class="flex-1 border-l border-gray-200 dark:border-gray-800 w-full">
          <ClientAddressMap :address="fullAddress" />
        </div>
      </div>
    </UDashboardPanel>
  </UDashboardPage>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const supabase = useSupabaseClient()

// Check if we're editing from a survey
const surveyId = computed(() => route.query.surveyId as string | undefined)
const isEditMode = computed(() => !!surveyId.value)

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
    return
  }

  try {
    if (isEditMode.value && clientId.value) {
      // Update existing client
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

      if (error) throw error

      // Navigate back to survey
      router.push(`/survey/${surveyId.value}`)
    } else {
      // Get company_id from user profile
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('company_id')
        .single()

      if (!profile?.company_id) {
        console.error('No company_id found')
        return
      }

      // Create new client
      const { data: newClient, error } = await supabase
        .from('clients')
        .insert({
          company_id: profile.company_id,
          name: form.value.name.trim(),
          email: form.value.email.trim() || null,
          phone: form.value.phone.trim() || null,
          postal_code: form.value.postalCode.trim(),
          city: form.value.city.trim(),
          street: form.value.street.trim(),
          house_number: form.value.houseNumber.trim(),
          status: 'active'
        })
        .select()
        .single()

      if (error) throw error

      // TODO: Navigate to survey page with new client
      console.log('New client created:', newClient)

      // For now, navigate back to survey list
      router.push('/survey')
    }
  } catch (error) {
    console.error('Error saving client:', error)
  }
}
</script>

<style scoped>
/* Make UInput wrapper full width */
:deep(.relative.inline-flex) {
  display: flex !important;
  width: 100%;
}
</style>
