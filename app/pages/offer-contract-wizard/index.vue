<template>
  <div>
    <!-- Header -->
    <div class="flex h-24 items-center justify-between mr-16">
      <div class="text-2xl font-light"><span class="font-black">{{ $t('wizard.list.title') }}</span></div>
      <div class="flex gap-3">
        <UIButtonEnhanced
          icon="i-lucide-file-text"
          variant="primary"
          size="md"
          to="/survey/client-data?type=offer"
        >
          {{ $t('wizard.list.offerForNewClient') }}
        </UIButtonEnhanced>
        <UIButtonEnhanced
          icon="i-lucide-file-signature"
          variant="primary"
          size="md"
          to="/survey/client-data?type=contract"
        >
          {{ $t('wizard.list.contractForNewClient') }}
        </UIButtonEnhanced>
      </div>
    </div>

    <div class="flex flex-col space-y-8">
      <!-- Filters Section -->
      <div class="flex items-start gap-3">
        <!-- Filter Buttons -->
        <div class="grow">
          <div class="flex flex-wrap gap-2">
            <button
              v-for="option in dateFilterOptions"
              :key="option.value"
              @click="selectedDateFilter = option.value"
              :class="[
                'px-4 py-3 rounded-full text-sm font-medium transition-all duration-200 cursor-pointer',
                selectedDateFilter === option.value
                  ? 'bg-blue-500 text-white shadow-lg shadow-blue-500/30'
                  : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-black hover:text-white dark:hover:bg-gray-700'
              ]"
            >
              {{ option.label }}
            </button>
          </div>
        </div>

        <!-- Search Input -->
        <div class="w-64">
          <UIInput
            v-model="searchQuery"
            :placeholder="$t('wizard.list.searchPlaceholder')"
            icon="i-lucide-search"
          />
        </div>
      </div>

      <!-- Loading State -->
      <UIBox v-if="loading" class="p-12">
        <div class="flex justify-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      </UIBox>

      <!-- Empty State -->
      <UIBox v-else class="p-12">
        <div class="text-center">
          <Icon name="i-lucide-clipboard-list" class="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">{{ $t('wizard.list.noWizardsFound') }}</h3>
          <p class="text-gray-500 dark:text-gray-400 mb-4">
            {{ selectedDateFilter !== 'all' ? $t('wizard.list.noClientsForFilter') : $t('wizard.list.startByCreating') }}
          </p>
          <div class="flex gap-3 justify-center">
            <UIButtonEnhanced to="/survey/client-data?type=offer">
              <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
              {{ $t('wizard.list.offerForNewClient') }}
            </UIButtonEnhanced>
            <UIButtonEnhanced to="/survey/client-data?type=contract" variant="secondary">
              <Icon name="i-lucide-plus" class="w-4 h-4 mr-2" />
              {{ $t('wizard.list.contractForNewClient') }}
            </UIButtonEnhanced>
          </div>
        </div>
      </UIBox>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

// State
const selectedDateFilter = ref<'today' | 'yesterday' | 'thisWeek' | 'lastWeek' | 'pending' | 'all'>('all')
const searchQuery = ref('')
const loading = ref(false)

// Filter options
const dateFilterOptions = computed(() => [
  { label: t('wizard.list.filters.allTime'), value: 'all' },
  { label: t('wizard.list.filters.today'), value: 'today' },
  { label: t('wizard.list.filters.yesterday'), value: 'yesterday' },
  { label: t('wizard.list.filters.thisWeek'), value: 'thisWeek' },
  { label: t('wizard.list.filters.lastWeek'), value: 'lastWeek' },
  { label: t('wizard.list.filters.pending'), value: 'pending' }
])
</script>
