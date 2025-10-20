<template>
  <div class="box-border flex flex-col items-center overflow-clip shrink-0 w-24 h-screen fixed top-0 left-0">
    <!-- Logo -->
    <div class="h-24 flex flex-col items-start justify-center relative shrink-0 w-full">
      <div class="aspect-[180/108.614] relative shrink-0 w-full">
        <div class="relative w-full h-full">
          <EverestLogo class="w-full h-full object-cover bg-center bg-cover bg-no-repeat" />
        </div>
      </div>
    </div>
    <div class="basis-0 flex flex-col gap-[8px] grow items-start justify-center min-h-px min-w-px relative shrink-0">
      <!-- Dashboard -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         bg-black/30
         backdrop-blur-md
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-white/30
         transition"
          @click="openMenuSection('Dashboard')"
          style="background: linear-gradient(0deg, rgba(180, 192, 219, 0.45) 0%, rgba(180, 192, 219, 0.45) 100%), linear-gradient(90deg, rgba(249, 249, 249, 0.70) 7.65%, rgba(239, 255, 174, 0.70) 92.18%);"
      >
        <IconDashboard class="w-6 h-6 text-green-800" />
      </button>

      <!-- Summit -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         bg-white/30
         backdrop-blur-md
         border border-white
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Summit')"
      >
        <IconSummit class="w-6 h-6" />
      </button>

      <!-- Ascent (Active) -->
      <button class="rounded-full flex items-center justify-center w-14 h-14
         bg-white/30
         backdrop-blur-md
         border border-white
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         transition"
         @click="openMenuSection('Ascent')"
      >
        <IconAscent class="w-6 h-6 text-black" />
      </button>

      <!-- Academy -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         bg-white/30
         backdrop-blur-md
         border border-white
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Academy')"
      >
        <IconAcademy class="w-6 h-6 text-black" />
      </button>

      <!-- Share Location -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         bg-white/30
         backdrop-blur-md
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Location')"
      >
        <IconLocation class="w-6 h-6 text-black" />
      </button>

      <!-- Settings -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         bg-white/30
         backdrop-blur-md
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Settings')"
      >
        <IconSettings class="w-6 h-6 text-black" />
      </button>
    </div>
    <div class="h-24">
      <!-- Dark Mode Toggle -->
      <button
          class="bg-black/30 box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
          @click="toggleDarkMode"
      >
        <IconDarkMode class="w-6 h-6 text-black" />
      </button>
    </div>
  </div>

  <!-- first level menu -->
  <Transition name="slide-menu">
    <div
      v-if="menuOpen"
      key="main-menu"
      class="bottom-2 left-2 top-2 fixed  dark:bg-slate-800/20 backdrop-blur-xl w-96 p-4 border border-white/60 dark:border-slate-700/30 rounded-2xl flex flex-col gap-4 divide-y divide-white/10 dark:divide-slate-700/30 shadow-2xl z-40"
    >
      <div class="flex items-center justify-between w-full pb-4 h-full">
        <div class="basis-0 flex flex-col gap-4 grow items-start justify-center min-h-px min-w-px relative shrink-0">
          <div v-for="menu in items" :key="menu.label" class="flex items-center">
            <button
                class="border border-white bg-color-white bg-white/30 w-14 h-14 rounded-full flex items-center justify-center mr-4"
                @click="handleMenuItemClick(menu)"
            >
              <IconDashboard class="w-6 h-6" v-if="menu.label === 'Dashboard'" />
              <IconSummit class="w-6 h-6" v-else-if="menu.label === 'Summit'" />
              <IconAscent class="w-6 h-6" v-else-if="menu.label === 'Ascent'" />
              <IconAcademy class="w-6 h-6" v-else-if="menu.label === 'Academy'" />
              <IconLocation class="w-6 h-6" v-else-if="menu.label === 'Location'" />
              <IconSettings class="w-6 h-6" v-else-if="menu.label === 'Settings'" />
            </button>

            <div v-if="menu.children" class="outfit  font-medium text-xl">
              <div
                  @click="toggleSubmenu(menu.label)"
                  @mouseenter="showSubmenu(menu.label)"
                  @mouseleave="scheduleHideSubmenu"
              >
                {{ menu.label }}
              </div>
            </div>
            <div class="outfit  font-medium text-xl" v-else>
              <NuxtLink :to="menu.to"  @click="closeMenu" class="">{{ menu.label }}</NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Transition>

  <!-- Right-sliding submenu -->
  <Transition name="slide-submenu">
    <div
        v-if="activeSubmenu && currentSubmenuItems.length > 0"
        key="submenu"
        class="bottom-2 left-100 top-2 fixed bg-black/30 dark:bg-black/40 backdrop-blur-2xl backdrop-saturate-180 w-80 p-4 border border-white/10 dark:border-white/5 rounded-2xl flex flex-col gap-2 shadow-2xl z-50"
        @mouseenter="cancelHideSubmenu"
        @mouseleave="scheduleHideSubmenu"
        style="backdrop-filter: blur(20px) saturate(180%);"
    >
      <div class="pb-3 mb-3 border-b border-white/10 dark:border-white/5">
        <h3 class="text-white font-semibold text-lg drop-shadow-sm">{{ activeSubmenu }}</h3>
      </div>

      <div class="flex-grow space-y-1">
        <NuxtLink
            v-for="submenu in currentSubmenuItems"
            :key="submenu.to"
            :to="submenu.to"
            @click="closeMenu"
            class="block hover:bg-white/15 dark:hover:bg-white/10 w-full px-4 py-3 rounded-lg text-white/90 hover:text-white transition-all duration-200 hover:translate-x-1 backdrop-blur-sm"
        >
          {{ submenu.label }}
        </NuxtLink>
      </div>
    </div>
  </Transition>

  <div class="w-12 h-12 bg-white rounded-full top-6.5 right-8 fixed z-20" @click="menuOpen=true">
    <div class="relative">
      <img :src="userAvatar" alt="User Avatar" class="w-12 h-12 rounded-full" />
      <OnlineStatusBadge
        :is-online="currentUserOnline"
        size="sm"
        variant="dot"
        class="absolute bottom-0 right-0 bg-white rounded-full p-1"
      />
    </div>
  </div>

</template>

<script setup lang="ts">
import type {NavigationMenuItem} from "@nuxt/ui";

// Reactive state
const menuOpen = ref(false);
const activeSubmenu = ref<string | null>(null);
const hideTimeout = ref<NodeJS.Timeout | null>(null);
const collapsed = ref(false);

// Store references
const authStore = useAuthStore();
const user = useSupabaseUser();

// Online status
const { currentUserOnline } = useOnlineStatus();

// Debug log for online status
watch(currentUserOnline, (newValue) => {
  console.log('SideMenu - currentUserOnline changed to:', newValue)
}, { immediate: true })

// Function to close menu
const closeMenu = () => {
  menuOpen.value = false;
  activeSubmenu.value = null;
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value);
    hideTimeout.value = null;
  }
};

// Submenu functions
const showSubmenu = (menuLabel: string) => {
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value);
    hideTimeout.value = null;
  }
  activeSubmenu.value = menuLabel;
};

const scheduleHideSubmenu = () => {
  hideTimeout.value = setTimeout(() => {
    activeSubmenu.value = null;
  }, 200);
};

const cancelHideSubmenu = () => {
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value);
    hideTimeout.value = null;
  }
};

const toggleSubmenu = (menuLabel: string) => {
  if (activeSubmenu.value === menuLabel) {
    activeSubmenu.value = null;
  } else {
    activeSubmenu.value = menuLabel;
  }
};

// Add ref for user profile data
const userProfile = ref({
  firstName: '',
  lastName: ''
})

// Computed property for display name
const displayName = computed(() => {
  if (userProfile.value.firstName || userProfile.value.lastName) {
    return `${userProfile.value.firstName} ${userProfile.value.lastName}`.trim();
  }

  return user.value?.email || '';
})

// Computed property for current submenu items
const currentSubmenuItems = computed(() => {
  if (!activeSubmenu.value) return [];

  const menu = items.find(item => item.label === activeSubmenu.value);
  return menu?.children || [];
});

// Logout function
const handleLogout = async () => {
  await authStore.logout();
  await navigateTo('/login');
};

// Function to open menu with specific section
const openMenuSection = (sectionLabel: string) => {
  const menuItem = items.find(item => item.label === sectionLabel);

  // If the menu item has children, open the slide panel and show submenu
  if (menuItem?.children && menuItem.children.length > 0) {
    menuOpen.value = true;
    activeSubmenu.value = sectionLabel;
  } else if (menuItem?.to) {
    // If no children but has a direct route, navigate there
    navigateTo(menuItem.to);
  } else {
    // Fallback: just open the menu panel
    menuOpen.value = true;
    activeSubmenu.value = null;
  }
};

// Handle menu item click in slide panel
const handleMenuItemClick = (menu: any) => {
  if (menu.children && menu.children.length > 0) {
    toggleSubmenu(menu.label);
  } else {
    // If no children, navigate directly and close menu
    navigateTo(menu.to);
    closeMenu();
  }
};

// Share location function
const shareLocation = () => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        // You can implement sharing logic here
        console.log('Current location:', { latitude, longitude });
        // For now, just open the menu section
        openMenuSection('Location');
      },
      (error) => {
        console.error('Error getting location:', error);
        // Fallback to just opening the menu
        openMenuSection('Location');
      }
    );
  } else {
    console.log('Geolocation is not supported');
    openMenuSection('Location');
  }
};

// Dark mode toggle function
const toggleDarkMode = () => {
  // Toggle dark mode - this depends on your dark mode implementation
  const html = document.documentElement;
  if (html.classList.contains('dark')) {
    html.classList.remove('dark');
  } else {
    html.classList.add('dark');
  }
};


const items: NavigationMenuItem[] = [
  {
    label: 'Dashboard',
    to: '/'
  },
  {
    label: 'Summit',
    icon: 'i-lucide-tag',
    children: [
      {
        label : 'Leads to Clients',
        to : '/ascent/leadstoclients'
      },
      {
        label : 'Energy Consultation',
        to : '/survey'
      },
      {
        label : 'Offer/Contract Wizard',
        to : '/ascent/contractwizard'
      },
      {
        label : 'Back in the Car',
        to : '/summit/backinthecar'
      },
      {
        label : 'Contracts to Collect',
        to : '/ascent/contractstocollect'
      }
    ]
  },
  {
    label: 'Ascent',
    icon: 'i-lucide-tag',
    children: [
      {
        label : 'ToDo',
        to : '/ascent/todo'
      },
      {
        label : 'Calendar',
        to : '/ascent/calendar'
      },
      {
        label : 'Leads & Clients',
        to : '/ascent/leadsandclients'
      },
      {
        label : 'Status',
        to : '/ascent/status'
      },
      {
        label : 'Tickets',
        to : '/ascent/tickets'
      }
    ]
  },
  {
    label: 'Academy',
    icon: 'i-lucide-tag',
    children: [
      {
        label : 'News',
        to: '/academy/news'
      },
      {
        label : 'Library',
        to: '/academy/library'
      },
      {
        label : 'Courses & Exams',
        to: '/academy/courses'
      },
      {
        label : 'AI Sherpa',
        to: '/academy/aisherpa'
      }
    ]
  },
  {
    label: 'Location',
    to: '/location'
  },
  {
    label: 'Settings',
    to: '/settings'
  },
]

// Computed properties
const userAvatar = computed(() => user.value?.user_metadata?.avatar_url || 'https://github.com/benjamincanac.png')
const userEmail = computed(() => user.value?.email || '')
const currentDay = computed(() => {
  return new Date().toLocaleDateString('en-US', { weekday: 'long' })
})
</script>


<style scoped>
/* Menu sliding animation */
.slide-menu-enter-active,
.slide-menu-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-menu-enter-from,
.slide-menu-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.slide-menu-enter-to,
.slide-menu-leave-from {
  transform: translateX(0);
  opacity: 1;
}

/* Submenu sliding animation */
.slide-submenu-enter-active,
.slide-submenu-leave-active {
  transition: transform 0.25s ease, opacity 0.25s ease;
}

.slide-submenu-enter-from,
.slide-submenu-leave-to {
  transform: translateX(20px);
  opacity: 0;
}

.slide-submenu-enter-to,
.slide-submenu-leave-from {
  transform: translateX(0);
  opacity: 1;
}

/* Backdrop fading animation */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>