 <template>
  <div class="fixed top-3 right-20 z-40 wall-progress-dropdown">
    <!-- Dropdown Toggle Button -->
    <button
      @click="isOpen = !isOpen"
      class="bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-full backdrop-blur-xs flex h-12 items-center gap-2 px-4 shadow-sm hover:bg-white/30 dark:hover:bg-black/30 transition-all duration-200 text-gray-900 dark:text-gray-300"
    >
      <span
        v-if="activeWall"
        class="inline-flex items-center justify-center rounded-full w-5 h-5 text-xs font-bold bg-black/20 dark:bg-white/20 text-gray-900 dark:text-gray-300"
      >
        {{ activeWallIndex + 1 }}
      </span>
      <span class="text-sm font-medium whitespace-nowrap">
        {{ activeWall ? (activeWall.name || `Falfelület #${activeWallIndex + 1}`) : 'Válassz falfelületet' }}
      </span>
      <span
        v-if="activeWall"
        class="px-2 py-0.5 rounded-full text-xs font-semibold"
        :class="getBadgeClass(activeWall)"
      >
        {{ getStatusLabel(activeWall) }}
      </span>
      <Icon
        name="i-lucide-chevron-down"
        class="w-4 h-4 transition-transform duration-200"
        :class="isOpen ? 'rotate-180' : ''"
      />
    </button>

    <!-- Dropdown Menu -->
    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="isOpen"
        class="absolute top-14 right-0 bg-white/20 dark:bg-black/20 border border-white dark:border-black/10 rounded-2xl backdrop-blur-md shadow-2xl overflow-hidden min-w-[300px]"
      >
        <div class="max-h-[400px] overflow-y-auto p-2">
          <NuxtLink
            v-for="(wall, index) in walls"
            :key="wall.id"
            :to="`/survey/${String(route.params.surveyId)}/measure/${String(wall.id)}`"
            @click="isOpen = false"
            class="flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium transition-all duration-200 whitespace-nowrap mb-1 last:mb-0"
            :class="wallIsActive(wall) ? getButtonClass(wall) : 'text-gray-900 dark:text-gray-300 hover:bg-white/30 dark:hover:bg-black/30'"
          >
            <span
              class="inline-flex items-center justify-center rounded-full w-5 h-5 text-xs font-bold flex-shrink-0"
              :class="wallIsActive(wall) ? 'bg-white/30 text-white' : 'bg-black/20 dark:bg-white/20 text-gray-900 dark:text-gray-300'"
            >
              {{ index + 1 }}
            </span>
            <span class="truncate flex-1">
              {{ wall.name || `Falfelület #${index + 1}` }}
            </span>
            <span
              class="px-2 py-0.5 rounded-full text-xs font-semibold flex-shrink-0"
              :class="getBadgeClass(wall)"
            >
              {{ getStatusLabel(wall) }}
            </span>
          </NuxtLink>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import type { Wall } from '@/model/Measure/ArucoWallSurface';
import { useWallStore } from '@/stores/WallStore';
import { computed, ref, onMounted, onBeforeUnmount } from 'vue';
import { useRoute } from 'vue-router';

const store = useWallStore();
const route = useRoute();

const surveyId = computed(() => String(route.params.surveyId));
const walls = computed(() => Object.values(store.getWallsForSurvey(surveyId.value)));
const isOpen = ref(false);

// Close dropdown on click outside
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement;
  if (!target.closest('.wall-progress-dropdown')) {
    isOpen.value = false;
  }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside);
});

const activeWallId = computed(() => (route.params.wallId ? String(route.params.wallId) : null));

const activeWall = computed(() => walls.value.find((w) => w.id === activeWallId.value) || null);

const activeWallIndex = computed(() => walls.value.findIndex((w) => w.id === activeWallId.value));

const wallIsActive = (wall: Wall): boolean => wall.id === activeWallId.value;

const getButtonClass = (wall: Wall): string => {
  const isActive = wallIsActive(wall);
  const hasPolygons = store.hasPolygons(surveyId.value, wall.id);
  const hasImages = wall.images.some((img) => img.uploadStatus === 'success');

  if (isActive) {
    // Active state - matches survey header active button style
    if (hasPolygons) {
      return 'bg-green-500 text-white hover:bg-green-600';
    } else if (hasImages) {
      return 'bg-primary-600 text-white hover:bg-primary-700';
    } else {
      return 'bg-gray-600 dark:bg-gray-600 text-white hover:bg-gray-700';
    }
  } else {
    // Inactive state - subtle hover effect
    if (hasPolygons) {
      return 'text-green-600 dark:text-green-400 hover:bg-green-500/10 dark:hover:bg-green-500/20';
    } else if (hasImages) {
      return 'text-primary-600 dark:text-primary-400 hover:bg-primary-500/10 dark:hover:bg-primary-500/20';
    } else {
      return 'text-gray-900 dark:text-gray-300 hover:bg-gray-500/10 dark:hover:bg-gray-500/20';
    }
  }
};

const getBadgeClass = (wall: Wall): string => {
  const hasPolygons = store.hasPolygons(surveyId.value, wall.id);
  const hasImages = wall.images.some((img) => img.uploadStatus === 'success');

  if (hasPolygons) {
    return 'bg-green-500/20 text-green-700 dark:text-green-300';
  } else if (hasImages) {
    return 'bg-primary-500/20 text-primary-700 dark:text-primary-300';
  } else {
    return 'bg-gray-500/20 text-gray-600 dark:text-gray-400';
  }
};

const getStatusLabel = (wall: Wall): string => {
  if (store.hasPolygons(surveyId.value, wall.id)) return 'Kész';
  if (wall.images.some((img) => img.uploadStatus === 'success')) return 'Kép kész';
  return 'Nincs kép';
};
</script>
