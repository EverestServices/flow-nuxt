<template>
  <div class="space-y-6">
    <!-- Two Column Layout -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Left Column - Personal Data -->
      <div>
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-heroicons-user" class="w-5 h-5 text-primary-500" />
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">{{ $t('client.basicInfo.personalData') }}</h2>
        </div>

        <div class="space-y-4">
          <div class="flex items-start gap-3">
            <UIcon name="i-heroicons-user" class="w-4 h-4 text-gray-400 mt-1" />
            <div>
              <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.name }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('client.basicInfo.individual') }}</p>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <UIcon name="i-heroicons-envelope" class="w-4 h-4 text-gray-400 mt-1" />
            <div>
              <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.email }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('client.basicInfo.emailAddress') }}</p>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <UIcon name="i-heroicons-phone" class="w-4 h-4 text-gray-400 mt-1" />
            <div>
              <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.phone }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('client.basicInfo.phoneNumber') }}</p>
            </div>
          </div>

          <div v-if="client.company" class="flex items-start gap-3">
            <UIcon name="i-heroicons-building-office" class="w-4 h-4 text-gray-400 mt-1" />
            <div>
              <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.company }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('client.basicInfo.company') }}</p>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <UIcon name="i-heroicons-calendar" class="w-4 h-4 text-gray-400 mt-1" />
            <div>
              <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.joinDate }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ $t('client.basicInfo.joinDate') }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column - Status -->
      <div>
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-heroicons-star" class="w-5 h-5 text-primary-500" />
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">{{ $t('client.basicInfo.status') }}</h2>
        </div>

        <div class="space-y-4">
          <div>
            <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">{{ $t('client.basicInfo.currentStatus') }}</p>
            <span
              :class="[
                'inline-block px-3 py-1 rounded-full text-sm font-medium',
                client.status === 'Active'
                  ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                  : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
              ]"
            >
              {{ $t(`client.basicInfo.${client.status.toLowerCase()}`) }}
            </span>
          </div>

          <div>
            <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">{{ $t('client.basicInfo.statusChangeDate') }}</p>
            <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.statusChangeDate }}</p>
          </div>

          <div>
            <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">{{ $t('client.basicInfo.lastContact') }}</p>
            <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.lastContact }}</p>
          </div>

          <div>
            <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">{{ $t('client.basicInfo.nextAction') }}</p>
            <p class="text-base font-medium text-gray-900 dark:text-white">{{ client.nextAction }}</p>
          </div>

          <div class="grid grid-cols-2 gap-3 pt-4">
            <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 text-center">
              <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ client.daysInStatus }}</p>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">{{ $t('client.basicInfo.daysInStatus') }}</p>
            </div>
            <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 text-center">
              <p
                :class="[
                  'text-2xl font-bold',
                  priorityColor(client.priority)
                ]"
              >
                {{ $t(`client.basicInfo.${client.priority.toLowerCase()}`) }}
              </p>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">{{ $t('client.basicInfo.priority') }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Addresses Section -->
    <div v-if="addresses && addresses.length > 0">
      <div class="flex items-center gap-2 mb-4">
        <UIcon name="i-heroicons-map-pin" class="w-5 h-5 text-primary-500" />
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">{{ $t('client.basicInfo.addresses') }}</h2>
      </div>

      <div v-for="(address, index) in addresses" :key="index" class="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 mb-3">
        <div class="flex items-center gap-2 mb-2">
          <UIcon name="i-heroicons-map-pin" class="w-4 h-4 text-gray-400" />
          <p class="font-medium text-gray-900 dark:text-white">{{ address.type }}</p>
        </div>
        <div class="ml-6">
          <p class="text-base text-gray-900 dark:text-white">{{ address.street }}</p>
          <p v-if="address.city && address.country" class="text-sm text-gray-500 dark:text-gray-400 mt-1">
            {{ address.city }}, {{ address.country }}
          </p>
        </div>
      </div>
    </div>

    <!-- Notes Section -->
    <div>
      <div class="flex items-center gap-2 mb-4">
        <UIcon name="i-heroicons-document-text" class="w-5 h-5 text-primary-500" />
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">{{ $t('client.basicInfo.notes') }}</h2>
      </div>
      <div class="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4">
        <p class="text-base text-gray-900 dark:text-white leading-relaxed">{{ client.notes }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Address {
  type: string
  street: string
  city: string
  country: string
}

interface Client {
  name: string
  email: string
  phone: string
  company?: string
  joinDate: string
  status: 'Active' | 'Inactive'
  statusChangeDate: string
  lastContact: string
  nextAction: string
  daysInStatus: number
  priority: 'High' | 'Medium' | 'Low'
  notes: string
}

defineProps<{
  client: Client
  addresses?: Address[]
}>()

const priorityColor = (priority: string) => {
  switch (priority) {
    case 'High':
      return 'text-green-600 dark:text-green-400'
    case 'Medium':
      return 'text-yellow-600 dark:text-yellow-400'
    case 'Low':
      return 'text-red-600 dark:text-red-400'
    default:
      return 'text-gray-900 dark:text-white'
  }
}
</script>
