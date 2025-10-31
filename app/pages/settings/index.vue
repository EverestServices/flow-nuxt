<template>
  <div class="flex h-24 items-center">
    <div class="text-2xl font-light">{{ $t('settings.title') }}</div>
  </div>

  <div class="flex flex-col space-y-8">
    <!-- Profile Header -->
    <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">
      <div class="basis-0 flex flex-col items-start justify-center">
        <div class="text-5xl font-thin outfit">
          Manage your <strong class="font-black">profile</strong> and<br />
          <strong class="font-black">preferences</strong>
        </div>
        <div class="text-2xl outfit font-thin text-gray-600 dark:text-gray-400 mt-4">
          {{ $t('settings.subtitle') }}
        </div>
      </div>

      <!-- Avatar Upload Section -->
      <div class="flex flex-col basis-0 items-start justify-center">
        <UIBox class="w-full p-6">
          <div class="flex items-center gap-6">
            <div class="relative">
              <img
                :src="profileData.avatar_url || user?.user_metadata?.avatar_url || 'https://github.com/benjamincanac.png'"
                alt="Profile Avatar"
                class="w-24 h-24 rounded-full object-cover border-4 border-white dark:border-gray-700"
              />
              <label
                for="avatar-upload"
                :class="[
                  'absolute bottom-0 right-0 w-8 h-8 rounded-full flex items-center justify-center transition',
                  uploadingAvatar ? 'bg-gray-400 cursor-not-allowed' : 'bg-green-500 cursor-pointer hover:bg-green-600'
                ]"
              >
                <Icon v-if="!uploadingAvatar" name="i-lucide-camera" class="w-4 h-4 text-white" />
                <svg v-else class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              </label>
              <input
                id="avatar-upload"
                type="file"
                accept="image/*"
                class="hidden"
                :disabled="uploadingAvatar"
                @change="handleAvatarUpload"
              />
            </div>
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ $t('settings.avatar.title') }}</h3>
              <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                {{ $t('settings.avatar.description') }}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-500 mt-1">
                {{ $t('settings.avatar.requirements') }}
              </p>
              <p v-if="uploadingAvatar" class="text-xs text-blue-600 dark:text-blue-400 mt-2 font-medium">
                Uploading...
              </p>
            </div>
          </div>
        </UIBox>
      </div>
    </div>

    <!-- Personal Information & Preferences -->
    <div class="grid lg:grid-cols-2 gap-x-4 gap-y-8">
      <!-- Personal Information -->
      <UIBox>
        <div class="w-full p-6">
          <div class="flex justify-between mb-6">
            <UIH2>{{ $t('settings.personalInfo.title') }}</UIH2>
          </div>

          <form @submit.prevent="savePersonalInfo" class="space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  {{ $t('settings.personalInfo.firstName') }}
                </label>
                <UIInput
                  v-model="profileData.first_name"
                  placeholder="John"
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  {{ $t('settings.personalInfo.lastName') }}
                </label>
                <UIInput
                  v-model="profileData.last_name"
                  placeholder="Doe"
                  class="w-full"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.email') }}
              </label>
              <UIInput
                v-model="profileData.email"
                type="email"
                disabled
                class="w-full opacity-60"
              />
              <p class="text-xs text-gray-500 mt-1">{{ $t('settings.personalInfo.emailNote') }}</p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.phone') }}
              </label>
              <UIInput
                v-model="profileData.phone"
                type="tel"
                placeholder="+1 (555) 123-4567"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.jobTitle') }}
              </label>
              <UIInput
                v-model="profileData.job_title"
                placeholder="Senior Developer"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.department') }}
              </label>
              <UIInput
                v-model="profileData.department"
                placeholder="Engineering"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.bio') }}
              </label>
              <textarea
                v-model="profileData.bio"
                :placeholder="$t('settings.personalInfo.bioPlaceholder')"
                rows="4"
                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-800 dark:text-white"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.personalInfo.location') }}
              </label>
              <UIInput
                v-model="profileData.location"
                placeholder="San Francisco, CA"
                class="w-full"
              />
            </div>

            <UIButtonEnhanced
              type="submit"
              :loading="savingPersonalInfo"
              class="w-full"
            >
              {{ $t('settings.personalInfo.save') }}
            </UIButtonEnhanced>
          </form>
        </div>
      </UIBox>

      <!-- Preferences -->
      <UIBox>
        <div class="w-full p-6">
          <div class="flex justify-between mb-6">
            <UIH2>{{ $t('settings.preferences.title') }}</UIH2>
          </div>

          <form @submit.prevent="savePreferences" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.preferences.timezone') }}
              </label>
              <UISelect
                v-model="profileData.timezone"
                :options="timezoneOptions"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.preferences.language') }}
              </label>
              <UISelect
                v-model="profileData.language"
                :options="languageOptions"
                class="w-full"
                @update:model-value="handleLanguageChange"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.preferences.dateFormat') }}
              </label>
              <UISelect
                v-model="profileData.date_format"
                :options="dateFormatOptions"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.preferences.timeFormat') }}
              </label>
              <UISelect
                v-model="profileData.time_format"
                :options="timeFormatOptions"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.preferences.theme') }}
              </label>
              <UISelect
                v-model="profileData.theme"
                :options="themeOptions"
                class="w-full"
              />
            </div>

            <UIButtonEnhanced
              type="submit"
              :loading="savingPreferences"
              class="w-full"
            >
              {{ $t('settings.preferences.save') }}
            </UIButtonEnhanced>
          </form>
        </div>
      </UIBox>
    </div>

    <!-- Social Links & Notification Settings -->
    <div class="grid lg:grid-cols-2 gap-x-4 gap-y-8">
      <!-- Social Links -->
      <UIBox>
        <div class="w-full p-6">
          <div class="flex justify-between mb-6">
            <UIH2>Social Links</UIH2>
          </div>

          <form @submit.prevent="saveSocialLinks" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                <Icon name="i-lucide-linkedin" class="inline w-4 h-4 mr-2" />
                LinkedIn
              </label>
              <UIInput
                v-model="profileData.linkedin_url"
                placeholder="https://linkedin.com/in/username"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                <Icon name="i-lucide-twitter" class="inline w-4 h-4 mr-2" />
                Twitter
              </label>
              <UIInput
                v-model="profileData.twitter_url"
                placeholder="https://twitter.com/username"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                <Icon name="i-lucide-github" class="inline w-4 h-4 mr-2" />
                GitHub
              </label>
              <UIInput
                v-model="profileData.github_url"
                placeholder="https://github.com/username"
                class="w-full"
              />
            </div>

            <UIButtonEnhanced
              type="submit"
              :loading="savingSocialLinks"
              class="w-full"
            >
              Save Social Links
            </UIButtonEnhanced>
          </form>
        </div>
      </UIBox>

      <!-- Notification Settings -->
      <UIBox>
        <div class="w-full p-6">
          <div class="flex justify-between mb-6">
            <UIH2>Notifications</UIH2>
          </div>

          <form @submit.prevent="saveNotifications" class="space-y-6">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">Email Notifications</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Receive notifications via email</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.notification_email"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">Push Notifications</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Receive push notifications in browser</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.notification_push"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">SMS Notifications</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Receive notifications via SMS</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.notification_sms"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <UIButtonEnhanced
              type="submit"
              :loading="savingNotifications"
              class="w-full"
            >
              Save Notification Settings
            </UIButtonEnhanced>
          </form>
        </div>
      </UIBox>
    </div>

    <!-- Privacy Settings -->
    <UIBox>
      <div class="w-full p-6">
        <div class="flex justify-between mb-6">
          <UIH2>Privacy Settings</UIH2>
        </div>

        <form @submit.prevent="savePrivacySettings" class="space-y-6">
          <div class="grid lg:grid-cols-3 gap-6">
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">Show Email</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Make email visible to others</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.privacy_show_email"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">Show Phone</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Make phone visible to others</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.privacy_show_phone"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-sm font-medium text-gray-900 dark:text-white">Show Online Status</h3>
                <p class="text-xs text-gray-500 dark:text-gray-400">Display when you're online</p>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="profileData.privacy_show_online_status"
                  class="sr-only peer"
                />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
              </label>
            </div>
          </div>

          <UIButtonEnhanced
            type="submit"
            :loading="savingPrivacySettings"
            class="w-full lg:w-auto"
          >
            Save Privacy Settings
          </UIButtonEnhanced>
        </form>
      </div>
    </UIBox>
  </div>
</template>

<script setup lang="ts">
const client = useSupabaseClient()
const user = useSupabaseUser()
const toast = useToast()
const { locale, t } = useI18n()

// Page metadata
useHead({
  title: 'Profile Settings - EverestFlow'
})

// Reactive state
const profileData = ref({
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  job_title: '',
  department: '',
  bio: '',
  location: '',
  avatar_url: '',
  timezone: 'UTC',
  language: 'en',
  date_format: 'MM/DD/YYYY',
  time_format: '12h',
  theme: 'system',
  linkedin_url: '',
  twitter_url: '',
  github_url: '',
  notification_email: true,
  notification_push: true,
  notification_sms: false,
  privacy_show_email: false,
  privacy_show_phone: false,
  privacy_show_online_status: true,
})

// Loading states
const savingPersonalInfo = ref(false)
const savingPreferences = ref(false)
const savingSocialLinks = ref(false)
const savingNotifications = ref(false)
const savingPrivacySettings = ref(false)

// Dropdown options
const timezoneOptions = [
  { label: 'UTC', value: 'UTC' },
  { label: 'America/New_York (EST)', value: 'America/New_York' },
  { label: 'America/Chicago (CST)', value: 'America/Chicago' },
  { label: 'America/Denver (MST)', value: 'America/Denver' },
  { label: 'America/Los_Angeles (PST)', value: 'America/Los_Angeles' },
  { label: 'Europe/London (GMT)', value: 'Europe/London' },
  { label: 'Europe/Paris (CET)', value: 'Europe/Paris' },
  { label: 'Asia/Tokyo (JST)', value: 'Asia/Tokyo' },
  { label: 'Australia/Sydney (AEST)', value: 'Australia/Sydney' },
]

const languageOptions = [
  { label: 'English', value: 'en' },
  { label: 'Spanish', value: 'es' },
  { label: 'French', value: 'fr' },
  { label: 'German', value: 'de' },
  { label: 'Hungarian', value: 'hu' },
  { label: 'Japanese', value: 'ja' },
]

const dateFormatOptions = [
  { label: 'MM/DD/YYYY', value: 'MM/DD/YYYY' },
  { label: 'DD/MM/YYYY', value: 'DD/MM/YYYY' },
  { label: 'YYYY-MM-DD', value: 'YYYY-MM-DD' },
]

const timeFormatOptions = [
  { label: '12 Hour', value: '12h' },
  { label: '24 Hour', value: '24h' },
]

const themeOptions = [
  { label: 'System', value: 'system' },
  { label: 'Light', value: 'light' },
  { label: 'Dark', value: 'dark' },
]

// Fetch user profile
const fetchProfile = async () => {
  if (!user.value) return

  try {
    // Set email from user object
    profileData.value.email = user.value.email || ''

    const { data, error } = await client
      .from('user_profiles')
      .select('*')
      .eq('user_id', user.value.id)
      .maybeSingle()

    if (error && error.code !== 'PGRST116') { // PGRST116 is "no rows returned"
      console.error('Error fetching profile:', error)
      return
    }

    if (data) {
      profileData.value = { ...profileData.value, ...data, email: user.value.email }
    } else {
      // Profile doesn't exist yet, create it
      const { error: insertError } = await client
        .from('user_profiles')
        .insert({
          user_id: user.value.id,
          email: user.value.email,
          company_id: '550e8400-e29b-41d4-a716-446655440000', // Default company ID
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })

      if (insertError) {
        console.error('Error creating profile:', insertError)
      }
    }
  } catch (err) {
    console.error('Error:', err)
  }
}

// Save functions
const savePersonalInfo = async () => {
  savingPersonalInfo.value = true
  try {
    const { error } = await client
      .from('user_profiles')
      .update({
        first_name: profileData.value.first_name,
        last_name: profileData.value.last_name,
        phone: profileData.value.phone,
        job_title: profileData.value.job_title,
        department: profileData.value.department,
        bio: profileData.value.bio,
        location: profileData.value.location,
      })
      .eq('user_id', user.value?.id)

    if (error) throw error

    toast.add({
      title: t('common.success'),
      description: t('settings.personalInfo.saveSuccess'),
      color: 'green',
    })
  } catch (error) {
    toast.add({
      title: t('common.error'),
      description: t('settings.personalInfo.saveError'),
      color: 'red',
    })
  } finally {
    savingPersonalInfo.value = false
  }
}

const savePreferences = async () => {
  savingPreferences.value = true
  try {
    const { error } = await client
      .from('user_profiles')
      .update({
        timezone: profileData.value.timezone,
        language: profileData.value.language,
        date_format: profileData.value.date_format,
        time_format: profileData.value.time_format,
        theme: profileData.value.theme,
      })
      .eq('user_id', user.value?.id)

    if (error) throw error

    toast.add({
      title: t('common.success'),
      description: t('settings.preferences.saveSuccess'),
      color: 'green',
    })
  } catch (error) {
    toast.add({
      title: t('common.error'),
      description: t('settings.preferences.saveError'),
      color: 'red',
    })
  } finally {
    savingPreferences.value = false
  }
}

const saveSocialLinks = async () => {
  savingSocialLinks.value = true
  try {
    const { error } = await client
      .from('user_profiles')
      .update({
        linkedin_url: profileData.value.linkedin_url,
        twitter_url: profileData.value.twitter_url,
        github_url: profileData.value.github_url,
      })
      .eq('user_id', user.value?.id)

    if (error) throw error

    toast.add({
      title: 'Success',
      description: 'Social links updated successfully',
      color: 'green',
    })
  } catch (error) {
    toast.add({
      title: 'Error',
      description: 'Failed to update social links',
      color: 'red',
    })
  } finally {
    savingSocialLinks.value = false
  }
}

const saveNotifications = async () => {
  savingNotifications.value = true
  try {
    const { error } = await client
      .from('user_profiles')
      .update({
        notification_email: profileData.value.notification_email,
        notification_push: profileData.value.notification_push,
        notification_sms: profileData.value.notification_sms,
      })
      .eq('user_id', user.value?.id)

    if (error) throw error

    toast.add({
      title: 'Success',
      description: 'Notification settings updated successfully',
      color: 'green',
    })
  } catch (error) {
    toast.add({
      title: 'Error',
      description: 'Failed to update notification settings',
      color: 'red',
    })
  } finally {
    savingNotifications.value = false
  }
}

const savePrivacySettings = async () => {
  savingPrivacySettings.value = true
  try {
    const { error } = await client
      .from('user_profiles')
      .update({
        privacy_show_email: profileData.value.privacy_show_email,
        privacy_show_phone: profileData.value.privacy_show_phone,
        privacy_show_online_status: profileData.value.privacy_show_online_status,
      })
      .eq('user_id', user.value?.id)

    if (error) throw error

    toast.add({
      title: 'Success',
      description: 'Privacy settings updated successfully',
      color: 'green',
    })
  } catch (error) {
    toast.add({
      title: 'Error',
      description: 'Failed to update privacy settings',
      color: 'red',
    })
  } finally {
    savingPrivacySettings.value = false
  }
}

const uploadingAvatar = ref(false)

const handleAvatarUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (!file) return

  // Validate file type
  const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
  if (!validTypes.includes(file.type)) {
    toast.add({
      title: t('common.error'),
      description: t('settings.avatar.invalidType'),
      color: 'red',
    })
    return
  }

  // Validate file size (5MB)
  if (file.size > 5 * 1024 * 1024) {
    toast.add({
      title: t('common.error'),
      description: t('settings.avatar.tooLarge'),
      color: 'red',
    })
    return
  }

  uploadingAvatar.value = true

  try {
    // Show uploading toast
    toast.add({
      title: 'Uploading...',
      description: 'Please wait while we upload your avatar',
      color: 'blue',
    })

    // Create unique file name
    const fileExt = file.name.split('.').pop()
    const fileName = `${user.value?.id}/${Date.now()}.${fileExt}`

    console.log('Uploading file:', fileName)

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await client.storage
      .from('avatars')
      .upload(fileName, file, {
        cacheControl: '3600',
        upsert: true, // Changed to true to allow overwriting
      })

    if (uploadError) {
      console.error('Upload error:', uploadError)
      throw uploadError
    }

    console.log('Upload successful:', uploadData)

    // Get public URL
    const { data: urlData } = client.storage
      .from('avatars')
      .getPublicUrl(fileName)

    const publicUrl = urlData.publicUrl
    console.log('Public URL:', publicUrl)

    // First check if user profile exists
    const { data: existingProfile, error: checkError } = await client
      .from('user_profiles')
      .select('*')
      .eq('user_id', user.value?.id)
      .maybeSingle()

    console.log('Existing profile:', existingProfile)

    if (checkError) {
      console.error('Check error:', checkError)
    }

    let profileUpdate, updateError

    if (existingProfile) {
      // Profile exists - UPDATE only
      console.log('Updating existing profile...')
      const result = await client
        .from('user_profiles')
        .update({
          avatar_url: publicUrl,
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', user.value?.id)
        .select()

      profileUpdate = result.data
      updateError = result.error
    } else {
      // Profile doesn't exist - INSERT
      console.log('Creating new profile...')
      const result = await client
        .from('user_profiles')
        .insert({
          user_id: user.value?.id,
          avatar_url: publicUrl,
          email: user.value?.email,
          company_id: '550e8400-e29b-41d4-a716-446655440000', // Default company ID
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .select()

      profileUpdate = result.data
      updateError = result.error
    }

    if (updateError) {
      console.error('Update error:', updateError)
      throw updateError
    }

    console.log('Profile updated:', profileUpdate)

    // Update local state
    profileData.value.avatar_url = publicUrl

    // Also update Supabase auth user metadata
    const { error: metadataError } = await client.auth.updateUser({
      data: {
        avatar_url: publicUrl
      }
    })

    if (metadataError) {
      console.warn('Metadata update error:', metadataError)
    }

    toast.add({
      title: t('common.success'),
      description: t('settings.avatar.uploadSuccess'),
      color: 'green',
    })
  } catch (error: any) {
    console.error('Avatar upload error:', error)
    toast.add({
      title: t('common.error'),
      description: error.message || t('settings.avatar.uploadError'),
      color: 'red',
    })
  } finally {
    uploadingAvatar.value = false
    // Reset input
    target.value = ''
  }
}

// Handle language change
const handleLanguageChange = async (newLanguage: string) => {
  // Update i18n locale immediately
  locale.value = newLanguage
}

// Fetch profile on mount
onMounted(() => {
  fetchProfile()
})

// Watch for profileData.language changes and sync with i18n
watch(() => profileData.value.language, (newLanguage) => {
  if (newLanguage && locale.value !== newLanguage) {
    locale.value = newLanguage
  }
})
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
