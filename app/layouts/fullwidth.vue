<template>
  <div class="bg-[#e7eae9] dark:bg-slate-800">
    <!-- User Avatar (fixed top right) - Click to show menu -->
    <div class="fixed top-2 right-4 z-50 cursor-pointer group" @click="menuOpen = true">
      <div class="relative">
        <img
          :src="userAvatar"
          alt="User Avatar"
          class="w-14 h-14 rounded-full border-2 border-white dark:border-gray-700 shadow-lg transition-transform group-hover:scale-105"
        />
        <OnlineStatusBadge
          :is-online="currentUserOnline"
          size="sm"
          variant="dot"
          class="absolute bottom-0 right-0 bg-white rounded-full p-1"
        />
      </div>
    </div>

    <!-- Main Content - Full Width -->
    <div class="min-h-screen w-screen px-4">
      <slot></slot>
    </div>

    <!-- Backdrop overlay -->
    <Transition name="fade">
      <div
        v-if="menuOpen"
        class="fixed inset-0 backdrop-blur-sm z-30"
        @click="closeMenu"
      />
    </Transition>

    <!-- Menu Panel (slides in from left) -->
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
              :class="[
                'flex items-center w-full transition transition-all rounded-4xl px-4 py-2 cursor-pointer',
                menu.label === 'Logout' ? 'hover:bg-red-500/20' : 'hover:bg-white/30 dark:hover:bg-white/10'
              ]"
              @mouseenter="menu.children ? showSubmenu(menu.label) : null"
              @mouseleave="menu.children ? scheduleHideSubmenu() : null"
            >
              <button
                :class="[
                  'border backdrop-blur-sm w-14 h-14 rounded-full flex items-center justify-center mr-4',
                  menu.label === 'Logout'
                    ? 'border-red-300 dark:border-red-900/50 bg-red-100/40 dark:bg-red-900/30 text-red-600 dark:text-red-400'
                    : 'border-white dark:border-black/50 bg-white/40 dark:bg-black/30 text-black dark:text-white'
                ]"
                @click="handleMenuItemClick(menu)"
              >
                <IconDashboard class="w-6 h-6" v-if="menu.label === 'Dashboard'" />
                <IconSummit class="w-6 h-6" v-else-if="menu.label === 'Summit'" />
                <IconAscent class="w-6 h-6" v-else-if="menu.label === 'Ascent'" />
                <IconAcademy class="w-6 h-6" v-else-if="menu.label === 'Academy'" />
                <IconSettings class="w-6 h-6" v-else-if="menu.label === 'Settings'" />
                <svg v-else-if="menu.label === 'Logout'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
              </button>

              <div v-if="menu.children" class="outfit font-medium text-xl text-black dark:text-white cursor-pointer">
                {{ menu.label }}
              </div>
              <div
                v-else
                :class="[
                  'outfit font-medium text-xl cursor-pointer',
                  menu.label === 'Logout' ? 'text-red-600 dark:text-red-400' : 'text-black dark:text-white'
                ]"
              >
                <NuxtLink v-if="menu.to !== '#'" :to="menu.to" @click="closeMenu">{{ menu.label }}</NuxtLink>
                <span v-else>{{ menu.label }}</span>
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
  </div>
</template>

<script setup lang="ts">
interface NavigationMenuItem {
  label: string
  to?: string
  icon?: string
  children?: NavigationMenuItem[]
}

const menuOpen = ref(false)
const activeSubmenu = ref<string | null>(null)
const hideTimeout = ref<NodeJS.Timeout | null>(null)

const authStore = useAuthStore()
const user = useSupabaseUser()
const { currentUserOnline } = useOnlineStatus()

const closeMenu = () => {
  menuOpen.value = false
  activeSubmenu.value = null
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value)
    hideTimeout.value = null
  }
}

const showSubmenu = (menuLabel: string) => {
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value)
    hideTimeout.value = null
  }
  activeSubmenu.value = menuLabel
}

const scheduleHideSubmenu = () => {
  hideTimeout.value = setTimeout(() => {
    activeSubmenu.value = null
  }, 200)
}

const cancelHideSubmenu = () => {
  if (hideTimeout.value) {
    clearTimeout(hideTimeout.value)
    hideTimeout.value = null
  }
}

const currentSubmenuItems = computed(() => {
  if (!activeSubmenu.value) return []
  const menu = items.find(item => item.label === activeSubmenu.value)
  return menu?.children || []
})

const handleLogout = async () => {
  try {
    const supabaseClient = useSupabaseClient()
    await supabaseClient.auth.signOut()
    await authStore.logout()
    closeMenu()
    await navigateTo('/login')
  } catch (error) {
    console.error('Logout error:', error)
  }
}

const handleMenuItemClick = (menu: any) => {
  if (menu.label === 'Logout') {
    handleLogout()
    return
  }

  if (!menu.children || menu.children.length === 0) {
    navigateTo(menu.to)
    closeMenu()
  }
}

const items: NavigationMenuItem[] = [
  {
    label: 'Dashboard',
    to: '/'
  },
  {
    label: 'Summit',
    children: [
      { label: 'Leads to Clients', to: '/ascent/leadstoclients' },
      { label: 'Energy Consultation', to: '/survey' },
      { label: 'Offer/Contract Wizard', to: '/ascent/contractwizard' },
      { label: 'Back in the Car', to: '/summit/backinthecar' },
      { label: 'Contracts to Collect', to: '/ascent/contractstocollect' }
    ]
  },
  {
    label: 'Ascent',
    children: [
      { label: 'ToDo', to: '/ascent/todo' },
      { label: 'Calendar', to: '/ascent/calendar' },
      { label: 'Leads & Clients', to: '/ascent/leadsandclients' },
      { label: 'Status', to: '/ascent/status' },
      { label: 'Tickets', to: '/ascent/tickets' }
    ]
  },
  {
    label: 'Academy',
    children: [
      { label: 'News', to: '/academy/news' },
      { label: 'Library', to: '/academy/library' },
      { label: 'Courses & Exams', to: '/academy/courses' },
      { label: 'AI Sherpa', to: '/academy/aisherpa' }
    ]
  },
  {
    label: 'Settings',
    to: '/settings'
  },
  {
    label: 'Logout',
    to: '#'
  }
]

const userAvatar = computed(() => user.value?.user_metadata?.avatar_url || 'https://github.com/benjamincanac.png')
</script>

<style scoped>
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

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
