<template>
  <!-- Main Footer Container - centered -->
  <div class="fixed bottom-3 left-1/2 -translate-x-1/2 z-30">
    <div class="flex items-center gap-4">
      <!-- Scenario Footer - slides in from left -->
      <Transition name="slide-in-left">
        <div
          v-if="activeTab === 'consultation' && showScenarioFooter"
          class="border border-white dark:border-black/10 py-2 px-4 rounded-4xl backdrop-blur-xs bg-white/20 dark:bg-black/20"
        >
          <slot name="scenario-footer" />
        </div>
      </Transition>

      <!-- Main Footer - slides right when scenario footer appears -->
      <div
        class="border border-white dark:border-black/10 py-1 px-3 rounded-4xl backdrop-blur-xs bg-white/20 dark:bg-black/20 transition-transform duration-300"
        :class="{ 'translate-x-0': !showScenarioFooter || activeTab !== 'consultation' }"
      >
        <div class="flex items-center justify-between">
      <!-- Left Section -->
      <div class="flex items-center gap-3 flex-1">
        <!-- Save and Exit - Always visible -->
        <UIButtonEnhanced
          variant="primary"
          size="sm"
          @click="$emit('save-exit')"
          class="grow whitespace-nowrap"
        >
          {{ t('survey.footer.saveAndExit')}}
        </UIButtonEnhanced>

        <!-- Property Assessment specific actions -->
        <template v-if="showPropertyActions">
          <!-- Upload All Photos -->
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            @click="$emit('upload-photos')"
            class="whitespace-nowrap"
          >
            {{ t('survey.footer.uploadPhotos') }}
          </UIButtonEnhanced>

          <!-- Fill All Data -->
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            @click="$emit('fill-all-data')"
            class="whitespace-nowrap"
          >
            {{ t('survey.footer.fillData') }}
          </UIButtonEnhanced>

          <!-- Generate Assessment Sheet -->
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            @click="$emit('generate-assessment')"
            class="whitespace-nowrap"
          >
            {{ t('survey.footer.generateAssessment') }}
          </UIButtonEnhanced>
        </template>

        <!-- Consultation specific actions -->
        <template v-if="activeTab === 'consultation'">
          <!-- Use Scenarios Button -->
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            @click="$emit('toggle-scenario-footer')"
            class="whitespace-nowrap"
          >
            <Icon name="i-lucide-eye" class="w-4 h-4 mr-2" />
            Use Scenarios
          </UIButtonEnhanced>
        </template>
      </div>

      <!-- Right Section -->
      <div class="flex items-center gap-3 flex-1 justify-end">
        <!-- Offer/Contract specific actions - Only on offer-contract tab -->
        <template v-if="activeTab === 'offer-contract'">
          <!-- Save Investment Contract Button -->
          <UIButtonEnhanced
            v-if="canSaveContract"
            variant="outline"
            size="sm"
            @click="$emit('save-investment-contract')"
            class="whitespace-nowrap"
          >
            <Icon name="i-lucide-save" class="w-4 h-4 mr-2" />
            {{ t('survey.footer.saveContract') }}
          </UIButtonEnhanced>

          <!-- Modify Contract Button -->
          <UIButtonEnhanced
            v-if="activeContract"
            variant="outline"
            size="sm"
            @click="$emit('modify-contract')"
            class="whitespace-nowrap"
          >
            <Icon name="i-lucide-pencil" class="w-4 h-4 mr-2" />
            {{ t('survey.footer.modifyContract', { name: activeContract.name }) }}
          </UIButtonEnhanced>
        </template>

        <!-- Offer/Contract specific Container - Contract Management - Only on offer-contract tab -->
        <template v-if="activeTab === 'offer-contract' && activeContract">
          <div class="flex items-center gap-3 px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ activeContract.name }}
            </span>
            <div class="flex items-center gap-2">
              <UIButtonEnhanced
                size="xs"
                variant="outline"
                @click="$emit('rename-contract')"
                class="whitespace-nowrap"
              >
                {{ t('survey.footer.rename') }}
              </UIButtonEnhanced>
              <UIButtonEnhanced
                size="xs"
                variant="outline"
                @click="$emit('duplicate-contract')"
                class="whitespace-nowrap"
              >
                {{ t('survey.footer.duplicate') }}
              </UIButtonEnhanced>
              <UIButtonEnhanced
                size="xs"
                variant="outline"
                @click="$emit('delete-contract')"
                class="text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 whitespace-nowrap"
              >
                {{ t('survey.footer.delete') }}
              </UIButtonEnhanced>
            </div>
          </div>
        </template>

        <!-- Summary specific actions - Only on summary tab -->
        <template v-if="activeTab === 'summary'">
          <!-- Save All and Send -->
          <UIButtonEnhanced
            variant="outline"
            size="sm"
            @click="$emit('save-all-and-send')"
            class="whitespace-nowrap"
          >
            <Icon name="i-lucide-send" class="w-4 h-4 mr-2" />
            {{ t('survey.footer.saveAllAndSend') }}
          </UIButtonEnhanced>

          <!-- Sign All Contracts -->
          <UIButtonEnhanced
            variant="primary"
            size="sm"
            @click="$emit('sign-all-contracts')"
            class="whitespace-nowrap"
          >
            <Icon name="i-lucide-pen-tool" class="w-4 h-4 mr-2" />
            {{ t('survey.footer.signAllContracts', { count: contractCount }) }}
          </UIButtonEnhanced>
        </template>

        <!-- Next Button - Visible on all tabs except summary -->
        <UIButtonEnhanced
          v-if="activeTab !== 'summary'"
          variant="primary"
          size="sm"
          :disabled="!canProceed"
          @click="$emit('next')"
          class="whitespace-nowrap"
        >
          {{ t('survey.footer.next') }}
          <Icon name="i-lucide-arrow-right" class="w-4 h-4 ml-2" />
        </UIButtonEnhanced>
        </div>
      </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()

interface Scenario {
  id: string
  name: string
}

interface Contract {
  id: string
  name: string
}

interface Props {
  activeTab: string
  showPropertyActions?: boolean
  missingItemsCount?: number
  canProceed?: boolean
  activeContract?: Contract | null
  canSaveContract?: boolean
  contractCount?: number
  showScenarioFooter?: boolean
}

withDefaults(defineProps<Props>(), {
  showPropertyActions: false,
  missingItemsCount: 0,
  canProceed: true,
  canSaveContract: false,
  contractCount: 0,
  showScenarioFooter: false
})

defineEmits<{
  'save-exit': []
  'upload-photos': []
  'fill-all-data': []
  'generate-assessment': []
  'show-missing-items': []
  'toggle-scenario-footer': []
  'rename-contract': []
  'duplicate-contract': []
  'delete-contract': []
  'save-investment-contract': []
  'modify-contract': []
  'save-all-and-send': []
  'sign-all-contracts': []
  next: []
}>()
</script>

<style scoped>
/* Slide in from left animation */
.slide-in-left-enter-active,
.slide-in-left-leave-active {
  transition: all 0.3s ease;
}

.slide-in-left-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.slide-in-left-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
