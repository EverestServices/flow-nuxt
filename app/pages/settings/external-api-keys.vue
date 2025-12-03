<template>
  <div class="flex h-24 items-center">
    <div class="text-2xl font-light">External API Keys</div>
  </div>

  <div class="flex flex-col space-y-8">
    <!-- Header -->
    <div class="grid grid-cols-1 lg:grid-cols-2 min-h-48">
      <div class="basis-0 flex flex-col items-start justify-center">
        <div class="text-5xl font-thin outfit">
          View <strong class="font-black">External</strong><br />
          <strong class="font-black">API Keys</strong>
        </div>
        <div class="text-2xl outfit font-thin text-gray-600 dark:text-gray-400 mt-4">
          Monitor API keys registered by external systems
        </div>
      </div>

      <div class="flex flex-col basis-0 items-start justify-center">
        <UIBox class="w-full p-6">
          <div class="flex items-start gap-4">
            <Icon name="i-lucide-info" class="w-12 h-12 text-blue-500" />
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">About API Keys</h3>
              <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                External systems (OFP, EKR) register their API keys here to access Flow on your behalf. Keys are sent from the external systems.
              </p>
            </div>
          </div>
        </UIBox>
      </div>
    </div>

    <!-- OFP API Key Section -->
    <UIBox>
      <div class="w-full p-6">
        <div class="flex justify-between items-center mb-6">
          <div>
            <UIH2>OFP Integration</UIH2>
            <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
              API key for Otthon Felújítási Program integration
            </p>
          </div>
        </div>

        <div v-if="ofpKey" class="space-y-4">
          <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
            <div class="flex items-start gap-3">
              <Icon name="i-lucide-check-circle" class="w-5 h-5 text-green-600 dark:text-green-400 mt-0.5" />
              <div class="flex-1">
                <h4 class="font-medium text-green-900 dark:text-green-100">API Key Active</h4>
                <p class="text-sm text-green-700 dark:text-green-300 mt-1">
                  Created: {{ formatDate(ofpKey.created_at) }}
                </p>
                <p v-if="ofpKey.last_used_at" class="text-sm text-green-700 dark:text-green-300">
                  Last used: {{ formatDate(ofpKey.last_used_at) }}
                </p>
              </div>
              <UIButtonEnhanced
                variant="outline"
                color="red"
                size="sm"
                @click="deactivateKey('OFP')"
                :loading="deactivating.OFP"
              >
                Deactivate
              </UIButtonEnhanced>
            </div>
          </div>
        </div>

        <div v-else class="space-y-4">
          <div class="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4">
            <div class="flex items-start gap-3">
              <Icon name="i-lucide-circle-off" class="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">No API key registered</p>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  The OFP system needs to generate and send their API key to activate this integration.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </UIBox>

    <!-- EKR API Key Section -->
    <UIBox>
      <div class="w-full p-6">
        <div class="flex justify-between items-center mb-6">
          <div>
            <UIH2>EKR Integration</UIH2>
            <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
              API key for Everest Kliens Rendszer integration
            </p>
          </div>
        </div>

        <div v-if="ekrKey" class="space-y-4">
          <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
            <div class="flex items-start gap-3">
              <Icon name="i-lucide-check-circle" class="w-5 h-5 text-green-600 dark:text-green-400 mt-0.5" />
              <div class="flex-1">
                <h4 class="font-medium text-green-900 dark:text-green-100">API Key Active</h4>
                <p class="text-sm text-green-700 dark:text-green-300 mt-1">
                  Created: {{ formatDate(ekrKey.created_at) }}
                </p>
                <p v-if="ekrKey.last_used_at" class="text-sm text-green-700 dark:text-green-300">
                  Last used: {{ formatDate(ekrKey.last_used_at) }}
                </p>
              </div>
              <UIButtonEnhanced
                variant="outline"
                color="red"
                size="sm"
                @click="deactivateKey('EKR')"
                :loading="deactivating.EKR"
              >
                Deactivate
              </UIButtonEnhanced>
            </div>
          </div>
        </div>

        <div v-else class="space-y-4">
          <div class="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4">
            <div class="flex items-start gap-3">
              <Icon name="i-lucide-circle-off" class="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">No API key registered</p>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  The EKR system needs to generate and send their API key to activate this integration.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </UIBox>

  </div>
</template>

<script setup lang="ts">
const { getApiKeys, deactivateApiKey } = useExternalApiKeys()
const toast = useToast()

// Page metadata
useHead({
  title: 'External API Keys - EverestFlow'
})

// State
const ofpKey = ref<any>(null)
const ekrKey = ref<any>(null)
const deactivating = ref({ OFP: false, EKR: false })

// Fetch existing keys
const fetchKeys = async () => {
  try {
    const keys = await getApiKeys()
    ofpKey.value = keys.find((k: any) => k.external_system === 'OFP' && k.is_active)
    ekrKey.value = keys.find((k: any) => k.external_system === 'EKR' && k.is_active)
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'Failed to load API keys',
      color: 'red'
    })
  }
}

// Deactivate API key
const deactivateKey = async (system: 'OFP' | 'EKR') => {
  const key = system === 'OFP' ? ofpKey.value : ekrKey.value
  if (!key) return

  deactivating.value[system] = true
  try {
    await deactivateApiKey(key.id)

    if (system === 'OFP') {
      ofpKey.value = null
    } else {
      ekrKey.value = null
    }

    toast.add({
      title: 'Success',
      description: `${system} API key deactivated`,
      color: 'green'
    })
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'Failed to deactivate API key',
      color: 'red'
    })
  } finally {
    deactivating.value[system] = false
  }
}

// Format date
const formatDate = (date: string) => {
  return new Date(date).toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Load keys on mount
onMounted(() => {
  fetchKeys()
})
</script>

<style scoped>
.outfit {
  font-family: 'Outfit', sans-serif;
}
</style>
