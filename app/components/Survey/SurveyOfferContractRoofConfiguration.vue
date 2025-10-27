<template>
  <div class="space-y-3">
    <!-- Empty state message when no instances -->
    <div v-if="localInstances.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-6">
      <p class="text-sm">Nincs még hozzáadott elem.</p>
      <p class="text-xs mt-1">Kattints az alábbi gombra új hozzáadásához.</p>
    </div>

    <!-- Roof Instances (Accordions) -->
    <UAccordion
      v-for="(instance, index) in localInstances"
      :key="index"
      :items="[{
        label: `${index + 1}. tető`,
        slot: `instance-${index}`,
        defaultOpen: index === 0
      }]"
    >
      <template #default="{ item, open }">
        <div class="flex items-center justify-between w-full">
          <span class="text-sm font-medium text-gray-900 dark:text-white">
            {{ index + 1 }}. tető
          </span>
          <!-- Delete button -->
          <button
            v-if="canDeleteInstance(index)"
            class="ml-2 p-1 rounded hover:bg-red-100 dark:hover:bg-red-900 text-red-600 dark:text-red-400"
            @click.stop="deleteInstance(index)"
          >
            <UIcon name="i-lucide-trash-2" class="w-4 h-4" />
          </button>
        </div>
      </template>

      <template #[`instance-${index}`]>
        <div class="p-4 space-y-6 bg-gray-50 dark:bg-gray-800 rounded-b-lg">
          <!-- Normal Questions -->
          <div
            v-for="question in normalQuestions"
            :key="question.id"
            class="space-y-2"
          >
            <SurveyQuestionRenderer
              :question="question"
              :model-value="getInstanceQuestionValue(index, question.name)"
              @update:model-value="updateInstanceQuestionValue(index, question.name, $event)"
            />
          </div>

          <!-- Special Questions Accordion -->
          <div v-if="specialQuestions.length > 0" class="mt-4">
            <UAccordion
              :items="[{
                label: 'Egyéb kérdések',
                slot: `special-${index}`,
                defaultOpen: false
              }]"
            >
              <template #[`special-${index}`]>
                <div class="p-4 space-y-6 bg-white dark:bg-gray-900 rounded-b-lg">
                  <div
                    v-for="question in specialQuestions"
                    :key="question.id"
                    class="space-y-2"
                  >
                    <SurveyQuestionRenderer
                      :question="question"
                      :model-value="getInstanceQuestionValue(index, question.name)"
                      @update:model-value="updateInstanceQuestionValue(index, question.name, $event)"
                    />
                  </div>
                  <!-- Close Button -->
                  <div class="flex justify-end pt-2">
                    <UButton
                      label="Becsuk"
                      color="gray"
                      variant="outline"
                      size="sm"
                      @click="closeAccordion"
                    />
                  </div>
                </div>
              </template>
            </UAccordion>
          </div>
        </div>
      </template>
    </UAccordion>

    <!-- Add Instance Button -->
    <div class="flex justify-center pt-2">
      <UButton
        label="Tető hozzáadása"
        icon="i-lucide-plus"
        color="primary"
        variant="outline"
        size="sm"
        @click="addInstance"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useSurveyInvestmentsStore } from '~/stores/surveyInvestments'
import type { SurveyQuestion } from '~/stores/surveyInvestments'
import SurveyQuestionRenderer from './SurveyQuestionRenderer.vue'

interface Props {
  surveyId: string
  scenarioId: string
}

const props = defineProps<Props>()

const store = useSurveyInvestmentsStore()

// Local state for roof instances (not saved to survey)
const localInstances = ref<Array<Record<string, any>>>([])

// Roof page and questions
const roofPage = ref<any>(null)
const allQuestions = ref<SurveyQuestion[]>([])

// Computed questions
const normalQuestions = computed(() => {
  return allQuestions.value.filter(q => !q.is_special)
})

const specialQuestions = computed(() => {
  return allQuestions.value.filter(q => q.is_special === true)
})

// Initialize with data from scenario
onMounted(async () => {
  try {
    // Find roof page from Solar Panel or Solar Panel + Battery investment
    const solarPanelInvestment = store.availableInvestments.find(inv =>
      inv.persist_name === 'solarPanel' || inv.persist_name === 'solarPanelBattery'
    )

    if (!solarPanelInvestment) {
      console.warn('Solar Panel investment not found')
      return
    }

    // Load investment pages and questions (questions are loaded automatically)
    await store.loadInvestmentData([solarPanelInvestment.id])

    // Find roof page (looking for 'Tető' or type 'roof')
    const pages = store.surveyPages[solarPanelInvestment.id] || []
    roofPage.value = pages.find(p => p.name === 'Tető' || p.type === 'roof')

    if (!roofPage.value) {
      console.warn('Roof page not found. Available pages:', pages.map(p => ({ name: p.name, type: p.type })))
      return
    }

    // Get questions for roof page (already loaded by loadInvestmentPages)
    allQuestions.value = store.surveyQuestions[roofPage.value.id] || []

    // Initialize with one empty instance
    if (localInstances.value.length === 0) {
      addInstance()
    }
  } catch (error) {
    console.error('Error initializing roof configuration:', error)
  }
})

// Instance management
const addInstance = () => {
  localInstances.value.push({})
}

const canDeleteInstance = (index: number) => {
  // Can delete any instance except when it's the last one
  return localInstances.value.length > 1
}

const deleteInstance = (index: number) => {
  if (canDeleteInstance(index)) {
    localInstances.value.splice(index, 1)
  }
}

const getInstanceQuestionValue = (instanceIndex: number, questionName: string) => {
  return localInstances.value[instanceIndex]?.[questionName]
}

const updateInstanceQuestionValue = (instanceIndex: number, questionName: string, value: any) => {
  if (!localInstances.value[instanceIndex]) {
    localInstances.value[instanceIndex] = {}
  }
  localInstances.value[instanceIndex][questionName] = value
}

const closeAccordion = (event: MouseEvent) => {
  // Navigate up the DOM to find the accordion and click its header button
  const target = event.target as HTMLElement

  // Find the parent accordion wrapper
  let current = target.parentElement
  while (current) {
    const buttons = current.querySelectorAll('button')
    for (const button of Array.from(buttons)) {
      if (button.textContent?.includes('Egyéb kérdések')) {
        button.click()
        return
      }
    }
    current = current.parentElement
  }
}
</script>
