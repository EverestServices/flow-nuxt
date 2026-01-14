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

    <!-- Password Change & Notification Settings -->
    <div class="grid lg:grid-cols-2 gap-x-4 gap-y-8">
      <!-- Password Change -->
      <UIBox>
        <div class="w-full p-6">
          <div class="flex justify-between mb-6">
            <UIH2>{{ $t('settings.password.title') }}</UIH2>
          </div>

          <!-- Success message -->
          <div v-if="passwordChangeSuccess" class="mb-4 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
            <div class="flex items-start">
              <Icon name="i-lucide-check-circle" class="w-5 h-5 text-green-600 dark:text-green-400 mt-0.5 mr-3 flex-shrink-0" />
              <div>
                <h3 class="text-sm font-semibold text-green-800 dark:text-green-300">
                  {{ $t('settings.password.changeSuccess') }}
                </h3>
                <p class="text-xs text-green-700 dark:text-green-400 mt-1">
                  {{ $t('settings.password.successMessage') }}
                </p>
              </div>
            </div>
          </div>

          <!-- Error message -->
          <div v-if="passwordChangeError" class="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
            <div class="flex items-start">
              <Icon name="i-lucide-alert-circle" class="w-5 h-5 text-red-600 dark:text-red-400 mt-0.5 mr-3 flex-shrink-0" />
              <div>
                <h3 class="text-sm font-semibold text-red-800 dark:text-red-300">
                  {{ $t('common.error') }}
                </h3>
                <p class="text-xs text-red-700 dark:text-red-400 mt-1">
                  {{ passwordChangeError }}
                </p>
              </div>
            </div>
          </div>

          <form @submit.prevent="changePassword" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.password.currentPassword') }}
              </label>
              <UIInput
                v-model="passwordData.currentPassword"
                type="password"
                :placeholder="$t('settings.password.currentPasswordPlaceholder')"
                class="w-full"
                required
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.password.newPassword') }}
              </label>
              <UIInput
                v-model="passwordData.newPassword"
                type="password"
                :placeholder="$t('settings.password.newPasswordPlaceholder')"
                class="w-full"
                required
              />
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                {{ $t('settings.password.requirements') }}
              </p>
              <!-- Password strength indicator -->
              <div v-if="passwordData.newPassword" class="mt-2">
                <div class="flex items-center gap-2 text-xs">
                  <span :class="passwordValidation.minLength ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
                    {{ passwordValidation.minLength ? '✓' : '○' }} {{ $t('settings.password.minLength') }}
                  </span>
                </div>
                <div class="flex items-center gap-2 text-xs mt-1">
                  <span :class="passwordValidation.hasLowercase ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
                    {{ passwordValidation.hasLowercase ? '✓' : '○' }} {{ $t('settings.password.hasLowercase') }}
                  </span>
                </div>
                <div class="flex items-center gap-2 text-xs mt-1">
                  <span :class="passwordValidation.hasUppercase ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
                    {{ passwordValidation.hasUppercase ? '✓' : '○' }} {{ $t('settings.password.hasUppercase') }}
                  </span>
                </div>
                <div class="flex items-center gap-2 text-xs mt-1">
                  <span :class="passwordValidation.hasNumber ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
                    {{ passwordValidation.hasNumber ? '✓' : '○' }} {{ $t('settings.password.hasNumber') }}
                  </span>
                </div>
                <div class="flex items-center gap-2 text-xs mt-1">
                  <span :class="passwordValidation.hasSpecialChar ? 'text-green-600 dark:text-green-400' : 'text-gray-400'">
                    {{ passwordValidation.hasSpecialChar ? '✓' : '○' }} {{ $t('settings.password.hasSpecialChar') }}
                  </span>
                </div>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('settings.password.confirmPassword') }}
              </label>
              <UIInput
                v-model="passwordData.confirmPassword"
                type="password"
                :placeholder="$t('settings.password.confirmPasswordPlaceholder')"
                class="w-full"
                required
              />
              <p v-if="passwordData.confirmPassword && passwordData.newPassword !== passwordData.confirmPassword"
                 class="text-xs text-red-600 dark:text-red-400 mt-1">
                {{ $t('settings.password.passwordsMustMatch') }}
              </p>
            </div>

            <UIButtonEnhanced
              type="submit"
              :loading="changingPassword"
              :disabled="!isPasswordValid"
              class="w-full"
            >
              {{ $t('settings.password.changePassword') }}
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
// Import locale files statically
import enMessages from '../../../i18n/locales/en.json'
import huMessages from '../../../i18n/locales/hu.json'

// Create a locale map for easy access
const localeFiles: Record<string, any> = {
  en: enMessages,
  hu: huMessages
}

const client = useSupabaseClient()
const user = useSupabaseUser()
const toast = useToast()
const { locale, t, getLocaleMessage, setLocaleMessage } = useI18n()

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
  notification_email: true,
  notification_push: true,
  notification_sms: false,
  privacy_show_email: false,
  privacy_show_phone: false,
  privacy_show_online_status: true,
})

// Password change state
const passwordData = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

// Loading states
const savingPersonalInfo = ref(false)
const savingPreferences = ref(false)
const savingNotifications = ref(false)
const savingPrivacySettings = ref(false)
const changingPassword = ref(false)
const passwordChangeSuccess = ref(false)
const passwordChangeError = ref('')

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

// Password validation
const passwordValidation = computed(() => {
  const password = passwordData.value.newPassword
  return {
    minLength: password.length >= 8,
    hasLowercase: /[a-z]/.test(password),
    hasUppercase: /[A-Z]/.test(password),
    hasNumber: /[0-9]/.test(password),
    hasSpecialChar: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
  }
})

const isPasswordValid = computed(() => {
  const validation = passwordValidation.value
  const passwordsMatch = passwordData.value.newPassword === passwordData.value.confirmPassword
  const allFieldsFilled = passwordData.value.currentPassword &&
                          passwordData.value.newPassword &&
                          passwordData.value.confirmPassword

  return allFieldsFilled &&
         passwordsMatch &&
         validation.minLength &&
         validation.hasLowercase &&
         validation.hasUppercase &&
         validation.hasNumber &&
         validation.hasSpecialChar
})

// Watch password data changes to hide success/error messages
watch(passwordData, (newVal) => {
  // Only hide messages if user is typing (fields have content)
  if ((passwordChangeSuccess.value || passwordChangeError.value) && (newVal.currentPassword || newVal.newPassword || newVal.confirmPassword)) {
    passwordChangeSuccess.value = false
    passwordChangeError.value = ''
  }
}, { deep: true })

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
    // Load the selected language file if not already loaded
    const selectedLanguage = profileData.value.language

    // Check if the locale messages are empty
    const currentMessages = getLocaleMessage(selectedLanguage)

    if (!currentMessages || Object.keys(currentMessages).length === 0) {
      try {
        // Load from statically imported locale files
        const messages = localeFiles[selectedLanguage]
        if (messages) {
          setLocaleMessage(selectedLanguage, messages)
        }
      } catch (err) {
        console.error(`Failed to load locale ${selectedLanguage}:`, err)
      }
    }

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

    // Update the locale after saving
    locale.value = selectedLanguage

    toast.add({
      title: t('common.success'),
      description: t('settings.preferences.saveSuccess'),
      color: 'green',
    })
  } catch (error) {
    console.error('Error in savePreferences:', error)
    toast.add({
      title: t('common.error'),
      description: t('settings.preferences.saveError'),
      color: 'red',
    })
  } finally {
    savingPreferences.value = false
  }
}

const changePassword = async () => {
  changingPassword.value = true
  // Clear any previous messages
  passwordChangeSuccess.value = false
  passwordChangeError.value = ''

  try {
    // First, verify the current password by signing in
    const { error: signInError } = await client.auth.signInWithPassword({
      email: profileData.value.email,
      password: passwordData.value.currentPassword,
    })

    if (signInError) {
      passwordChangeError.value = t('settings.password.currentPasswordIncorrect')
      return
    }

    // Update the password
    const { error: updateError } = await client.auth.updateUser({
      password: passwordData.value.newPassword,
    })

    if (updateError) {
      // Handle specific error for same password
      if (updateError.message.includes('should be different')) {
        passwordChangeError.value = t('settings.password.samePasswordError')
      } else {
        passwordChangeError.value = updateError.message || t('settings.password.changeError')
      }
      return
    }

    // Show success message in card FIRST
    passwordChangeSuccess.value = true

    // Clear the form AFTER setting success flag
    await nextTick()
    passwordData.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    }
  } catch (error: any) {
    console.error('Password change error:', error)
    passwordChangeError.value = error.message || t('settings.password.changeError')
  } finally {
    changingPassword.value = false
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

    // Get public URL
    const { data: urlData } = client.storage
      .from('avatars')
      .getPublicUrl(fileName)

    const publicUrl = urlData.publicUrl

    // First check if user profile exists
    const { data: existingProfile, error: checkError } = await client
      .from('user_profiles')
      .select('*')
      .eq('user_id', user.value?.id)
      .maybeSingle()

    if (checkError) {
      console.error('Check error:', checkError)
    }

    let profileUpdate, updateError

    if (existingProfile) {
      // Profile exists - UPDATE only
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

// Fetch profile on mount
onMounted(() => {
  fetchProfile()
})
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
