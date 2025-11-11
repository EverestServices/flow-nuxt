<template>
  <div v-if="areas && hasAnyArea" class="pb-2">
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2">
      <AreaCard
        v-if="areas.windowDoorArea > 0"
        :value="areas.windowDoorArea"
        title="Nyílászáró"
        color="emerald"
      >
        <template #icon>
          <Icon name="i-lucide-door-open" class="w-7 h-7 mb-1 text-emerald-700" />
        </template>
      </AreaCard>

      <AreaCard
        v-if="areas.facadeGrossArea > 0"
        :value="areas.facadeGrossArea"
        title="Homlokzat (bruttó)"
        color="sky"
      >
        <template #icon>
          <Icon name="i-lucide-building-2" class="w-7 h-7 mb-1 text-sky-700" />
        </template>
      </AreaCard>

      <AreaCard
        v-if="areas.facadeNetArea > 0"
        :value="areas.facadeNetArea"
        title="Homlokzat (nettó)"
        color="sky"
      >
        <template #icon>
          <Icon name="i-lucide-building" class="w-7 h-7 mb-1 text-sky-700" />
        </template>
      </AreaCard>

      <AreaCard
        v-if="areas.wallPlinthArea > 0"
        :value="areas.wallPlinthArea"
        title="Lábazat (bruttó)"
        color="yellow"
      >
        <template #icon>
          <Icon name="i-lucide-layers" class="w-7 h-7 mb-1 text-yellow-700" />
        </template>
      </AreaCard>

      <AreaCard
        v-if="areas.wallPlinthNetArea > 0"
        :value="areas.wallPlinthNetArea"
        title="Lábazat (nettó)"
        color="yellow"
      >
        <template #icon>
          <Icon name="i-lucide-layout" class="w-7 h-7 mb-1 text-yellow-700" />
        </template>
      </AreaCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useWallStore } from '@/stores/WallStore';
import AreaCard from './AreaCard.vue';
import { useRoute } from 'vue-router';

const props = defineProps<{
  wallId: string;
}>();

const store = useWallStore();
const route = useRoute();
const areas = computed(() => store.getWallSurfaceAreas(String(route.params.surveyId), props.wallId));

const hasAnyArea = computed(
  () =>
    areas.value &&
    (areas.value.facadeGrossArea > 0 ||
      areas.value.facadeNetArea > 0 ||
      areas.value.windowDoorArea > 0 ||
      areas.value.wallPlinthArea > 0 ||
      areas.value.wallPlinthNetArea > 0),
);
</script>
