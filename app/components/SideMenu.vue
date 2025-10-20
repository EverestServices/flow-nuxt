<template>
  <div class="box-border flex flex-col items-center overflow-clip shrink-0 w-24 h-screen fixed top-0 left-0">
    <!-- Logo -->
    <div class="h-24 flex flex-col items-start justify-center relative shrink-0 w-full">
      <div class="aspect-[180/108.614] relative shrink-0 w-full">
        <div class="relative w-full h-full">
          <NuxtLink to="/"><EverestLogo class="w-16 ml-4 mt-8 object-cover bg-center bg-cover bg-no-repeat" /></NuxtLink>
        </div>
      </div>
    </div>
    <div class="basis-0 flex flex-col gap-[8px] grow items-start justify-center min-h-px min-w-px relative shrink-0">
      <!-- Dashboard -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         backdrop-blur-sm
         border border-white
         text-black font-medium
         shadow-lg
         dark:bg-black/30
         dark:border-black/70
         hover:bg-[#FAE696]/30 hover:text-white
         transition
          cursor-pointer"
          @click="openMenuSection('Dashboard')"
      >
        <IconDashboard class="w-6 h-6 text-black dark:text-white" />
      </button>

      <!-- Summit -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         backdrop-blur-sm
         border border-white
         text-black
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         dark:bg-black/30 dark:border-black/70
         transition"
          @click="openMenuSection('Summit')"
      >
        <IconSummit class="w-6 h-6 text-black dark:text-white" />
      </button>

      <!-- Ascent (Active) -->
      <button class="rounded-full flex items-center justify-center w-14 h-14

         backdrop-blur-md
         border border-white
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         dark:bg-black/30 dark:border-black/70
         hover:text-white
         cursor-pointer
         transition"
         @click="openMenuSection('Ascent')"
      >
        <IconAscent class="w-6 h-6 text-black dark:text-white" />
      </button>

      <!-- Academy -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         backdrop-blur-sm
         border border-white
         font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         dark:bg-black/30 dark:border-black/70
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Academy')"
      >
        <IconAcademy class="w-6 h-6 text-black dark:text-white" />
      </button>

      <!-- Share Location -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14

         backdrop-blur-sm
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         dark:bg-black/30 dark:border-black/70
         hover:text-white
         cursor-pointer
         transition"
          @click="openMenuSection('Location')"
      >
        <IconLocation class="w-6 h-6 text-black dark:text-white" />
      </button>

      <!-- Settings -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         backdrop-blur-sm
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         dark:bg-black/30 dark:border-black/70
         transition"
          @click="openMenuSection('Settings')"
      >
        <IconSettings class="w-6 h-6 text-black dark:text-white" />
      </button>
    </div>
    <div class="h-24">
      <!-- Dark Mode Toggle -->
      <button
          class="rounded-full flex items-center justify-center w-14 h-14
         backdrop-blur-sm
         border border-white
         text-white font-medium
         shadow-lg
         hover:bg-[#FAE696]/30
         hover:text-white
         cursor-pointer
         dark:bg-black/30 dark:border-black/70
         transition"          @click="toggleDarkMode"
      >
        <IconDarkMode class="w-6 h-6 text-black dark:text-white" />
      </button>
    </div>
  </div>

  <!-- Backdrop overlay -->
  <Transition name="fade">
    <div
      v-if="menuOpen"
      class="fixed inset-0 backdrop-blur-sm z-30"
      @click="closeMenu"
    />
  </Transition>

  <!-- first level menu -->
  <Transition name="slide-menu">
    <div
      v-if="menuOpen"
      key="main-menu"
      class="bottom-2 left-2 top-2 fixed dark:bg-slate-800/20 backdrop-blur-xl w-96 p-4 border border-white/60 dark:border-slate-700/30 rounded-2xl flex flex-col gap-4 divide-y divide-white/10 dark:divide-slate-700/30 shadow-2xl z-40"
    >
      <div class="flex items-center justify-between w-full pb-4 h-full">
        <div class="basis-0 flex flex-col gap-4 grow items-start justify-center min-h-px min-w-px relative shrink-0">
          <div
            v-for="menu in items"
            :key="menu.label"
            class="flex items-center hover:bg-white/30 dark:hover:bg-white/10 w-full transition transition-all rounded-4xl px-4 py-2 cursor-pointer"
            @mouseenter="menu.children ? showSubmenu(menu.label) : null"
            @mouseleave="menu.children ? scheduleHideSubmenu() : null"
          >
            <button
                class="border border-white dark:border-black/50 bg-white/40 dark:bg-black/30 backdrop-blur-sm w-14 h-14 rounded-full flex items-center justify-center mr-4 text-black dark:text-white"
                @click="handleMenuItemClick(menu)"
            >
              <IconDashboard class="w-6 h-6" v-if="menu.label === 'Dashboard'" />
              <IconSummit class="w-6 h-6" v-else-if="menu.label === 'Summit'" />
              <IconAscent class="w-6 h-6" v-else-if="menu.label === 'Ascent'" />
              <IconAcademy class="w-6 h-6" v-else-if="menu.label === 'Academy'" />
              <IconLocation class="w-6 h-6" v-else-if="menu.label === 'Location'" />
              <IconSettings class="w-6 h-6" v-else-if="menu.label === 'Settings'" />
            </button>

            <div v-if="menu.children" class="outfit font-medium text-xl text-black dark:text-white cursor-pointer">
              {{ menu.label }}
            </div>
            <div class="outfit font-medium text-xl text-black dark:text-white" v-else>
              <NuxtLink :to="menu.to" @click="closeMenu" class="">{{ menu.label }}</NuxtLink>
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
        class="bottom-2 left-100 top-2 fixed dark:bg-slate-800/20 backdrop-blur-xl w-96 p-4 border border-white/60 dark:border-slate-700/30 rounded-2xl flex flex-col gap-4 divide-y divide-white/10 dark:divide-slate-700/30 shadow-2xl z-50"
        @mouseenter="cancelHideSubmenu"
        @mouseleave="scheduleHideSubmenu"
    >
      <div class="flex items-center justify-between w-full pb-4 h-full">
        <div class="basis-0 flex flex-col gap-4 grow items-start justify-center min-h-px min-w-px relative shrink-0">
          <div v-for="submenu in currentSubmenuItems" :key="submenu.to" class="flex items-center hover:bg-white/30 dark:hover:bg-white/10 w-full transition transition-all rounded-4xl px-4 py-2">
            <NuxtLink :to="submenu.to" @click="closeMenu" class="flex items-center w-full">
              <button
                  class="border border-white dark:border-black/50 bg-white/40 dark:bg-black/30 backdrop-blur-sm w-14 h-14 rounded-full flex items-center justify-center mr-4 text-black dark:text-white"
              >
                <!-- Generic icon for submenu items -->
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </button>

              <div class="outfit font-medium text-xl text-black dark:text-white cursor-pointer">
                {{ submenu.label }}
              </div>
            </NuxtLink>
          </div>
        </div>
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
  // Special handling for Location - request geolocation
  if (sectionLabel === 'Location') {
    shareLocation();
    return;
  }

  const menuItem = items.find(item => item.label === sectionLabel);

  // If the menu item has children, only open the first level menu (not submenu)
  if (menuItem?.children && menuItem.children.length > 0) {
    menuOpen.value = true;
    activeSubmenu.value = null; // Don't auto-show submenu, user must hover
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
  if (!menu.children || menu.children.length === 0) {
    // If no children, navigate directly and close menu
    navigateTo(menu.to);
    closeMenu();
  }
  // If menu has children, do nothing on click (hover handles submenu)
};

// Share location function
const shareLocation = () => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        console.log('✅ Location access granted:', { latitude, longitude });

        // Store location in localStorage or state if needed
        localStorage.setItem('userLocation', JSON.stringify({ latitude, longitude, timestamp: new Date().toISOString() }));

        // Navigate to location page
        const menuItem = items.find(item => item.label === 'Location');
        if (menuItem?.to) {
          navigateTo(menuItem.to);
        }
      },
      (error) => {
        console.error('❌ Error getting location:', error);

        // Show user-friendly error message based on error code
        let errorMessage = 'Unable to get your location.';
        switch(error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = 'Location access denied. Please enable location permissions in your browser settings.';
            break;
          case error.POSITION_UNAVAILABLE:
            errorMessage = 'Location information is unavailable.';
            break;
          case error.TIMEOUT:
            errorMessage = 'Location request timed out.';
            break;
        }

        alert(errorMessage);

        // Still navigate to location page even if permission denied
        const menuItem = items.find(item => item.label === 'Location');
        if (menuItem?.to) {
          navigateTo(menuItem.to);
        }
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    );
  } else {
    alert('Geolocation is not supported by your browser.');

    // Navigate to location page anyway
    const menuItem = items.find(item => item.label === 'Location');
    if (menuItem?.to) {
      navigateTo(menuItem.to);
    }
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
        to : '/ascent/energyconsultation'
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