<template>
  <div class="bg-[#f4f6fa] flex flex-col items-start relative w-full min-h-screen">
    <div class="box-border flex flex-col gap-[10px] h-[1024px] items-start overflow-clip px-[24px] py-0 relative shrink-0 w-full">

      <div class="basis-0 flex gap-[16px] grow items-start min-h-px min-w-px overflow-clip relative shrink-0 w-full">
        <!-- Sidebar Menu -->
        <div class="box-border flex flex-col gap-[8px] h-[1024px] items-center overflow-clip px-0 py-[12px] relative shrink-0">
          <!-- Logo -->
          <div class="flex flex-col h-[48px] items-start justify-center relative shrink-0 w-full">
            <div class="aspect-[180/108.614] relative shrink-0 w-full">
              <div class="relative w-full h-full">
                <EverestLogo class="w-full h-full object-cover bg-center bg-cover bg-no-repeat" />
              </div>
            </div>
          </div>

          <!-- Navigation Options -->
          <div class="basis-0 flex flex-col gap-[8px] grow items-start justify-center min-h-px min-w-px relative shrink-0">
            <!-- Dashboard -->
            <button
                class="bg-[rgba(255,255,255,0.31)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
                @click="navigateTo('/')"
            >
              <IconDashboard class="w-[24px] h-[24px] text-black" />
            </button>

            <!-- Summit -->
            <button
                class="bg-[rgba(255,255,255,0.31)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
                @click="navigateTo('/summit')"
            >
              <IconSummit class="w-[24px] h-[24px] text-black" />
            </button>

            <!-- Ascent (Active) -->
            <div class="bg-[rgba(0,0,0,0.8)] box-border flex flex-col gap-[10px] items-center justify-center p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px]">
              <IconAscent class="w-[24px] h-[24px] text-white" />
            </div>

            <!-- Academy -->
            <button
                class="bg-[rgba(255,255,255,0.31)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
                @click="navigateTo('/academy')"
            >
              <IconAcademy class="w-[24px] h-[24px] text-black" />
            </button>

            <!-- Share Location -->
            <button
                class="bg-[rgba(239,255,234,0.8)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(239,255,234,0.9)] transition-colors"
                @click="shareLocation"
            >
              <IconLocation class="w-[24px] h-[24px] text-black" />
            </button>

            <!-- Settings -->
            <button
                class="bg-[rgba(255,255,255,0.31)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
                @click="navigateTo('/settings')"
            >
              <IconSettings class="w-[24px] h-[24px] text-black" />
            </button>
          </div>

          <!-- Dark Mode Toggle -->
          <button
              class="bg-[rgba(255,255,255,0.31)] box-border cursor-pointer flex flex-col gap-[10px] items-center justify-center overflow-visible p-[12px] relative rounded-[28px] shrink-0 w-[56px] h-[56px] hover:bg-[rgba(255,255,255,0.4)] transition-colors"
              @click="toggleDarkMode"
          >
            <IconDarkMode class="w-[24px] h-[24px] text-black" />
          </button>
        </div>

        <!-- Main Content -->
        <div class="basis-0 flex flex-col gap-[10px] grow h-full items-start min-h-px min-w-px overflow-x-clip overflow-y-auto relative shrink-0">
          <!-- Header -->
          <div class="box-border flex items-center pb-0 pt-[12px] px-0 relative shrink-0 w-full">
            <div class="basis-0 capitalize flex flex-col grow justify-center leading-[0] min-h-px min-w-px not-italic relative shrink-0 text-black">
              <p class="text-[24px] leading-normal font-light">
                <span class="font-extralight">Ascent</span> Hub
              </p>
            </div>

            <div class="flex gap-[8px] items-center justify-end relative shrink-0">
              <button class="bg-black bg-cover bg-center block cursor-pointer relative rounded-[28px] shrink-0 w-[48px] h-[48px] overflow-hidden">
                <img
                    :src="userAvatar"
                    alt="User Avatar"
                    class="w-full h-full object-cover"
                />
              </button>
            </div>
          </div>

          <!-- Welcome Section -->
          <div class="flex gap-[10px] items-start relative shrink-0 w-full">
            <div class="basis-0 box-border flex flex-col gap-[70px] grow items-start min-h-px min-w-px px-0 py-[60px] relative shrink-0">
              <div class="box-border flex flex-col gap-[8px] items-start justify-center leading-[0] not-italic overflow-clip px-0 py-[4px] relative shrink-0 text-black whitespace-nowrap w-full">
                <div class="flex flex-col justify-center relative shrink-0 text-[36px] font-extralight">
                  <p class="leading-normal mb-0">
                    Manage your <span class="font-medium">business operations</span>
                  </p>
                  <p class="leading-normal">
                    with <span class="font-medium">ease</span>
                  </p>
                </div>
                <div class="flex flex-col justify-center relative shrink-0 text-[14px] font-extralight">
                  <p class="leading-normal whitespace-pre">Access all your operational tools from one place.</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Ascent Modules Grid -->
          <div class="grid grid-cols-2 gap-[10px] items-start relative shrink-0 w-full">
            <!-- Clients Module -->
            <div class="bg-[rgba(255,255,255,0.4)] relative rounded-[32px] border border-white/50 cursor-pointer hover:bg-[rgba(255,255,255,0.5)] transition-colors" @click="navigateTo('/ascent/clients')">
              <div class="box-border flex flex-col items-start overflow-clip p-[24px] relative w-full h-full">
                <!-- Module Header -->
                <div class="box-border flex items-center justify-between pb-[24px] pt-0 px-0 relative shrink-0 w-full">
                  <div class="flex gap-[8px] items-center leading-[0] not-italic relative shrink-0 text-black text-center">
                    <div class="text-[32px]">👥</div>
                    <div class="flex flex-col justify-center relative shrink-0 text-[20px] font-medium">
                      Clients
                    </div>
                  </div>
                  <button class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer">
                    <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                      Manage
                    </div>
                  </button>
                </div>

                <!-- Module Content -->
                <div class="flex flex-col gap-[12px] items-start relative shrink-0 w-full">
                  <p class="text-gray-700 text-sm">
                    Manage client relationships, contact information, and business details.
                  </p>
                  <div class="grid grid-cols-2 gap-4 w-full text-xs text-gray-600">
                    <div>• Search & filter clients</div>
                    <div>• Contact management</div>
                    <div>• Client status tracking</div>
                    <div>• Notes & documentation</div>
                  </div>
                  <div class="flex gap-[4px] items-center mt-4">
                    <div class="text-[14px] font-medium text-black">{{ totalClients }}</div>
                    <div class="text-[12px] text-gray-600">total clients</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Tickets Module -->
            <div class="bg-[rgba(255,255,255,0.4)] relative rounded-[32px] border border-white/50 cursor-pointer hover:bg-[rgba(255,255,255,0.5)] transition-colors" @click="navigateTo('/ascent/tickets')">
              <div class="box-border flex flex-col items-start overflow-clip p-[24px] relative w-full h-full">
                <!-- Module Header -->
                <div class="box-border flex items-center justify-between pb-[24px] pt-0 px-0 relative shrink-0 w-full">
                  <div class="flex gap-[8px] items-center leading-[0] not-italic relative shrink-0 text-black text-center">
                    <div class="text-[32px]">🎫</div>
                    <div class="flex flex-col justify-center relative shrink-0 text-[20px] font-medium">
                      Tickets
                    </div>
                  </div>
                  <button class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer">
                    <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                      Manage
                    </div>
                  </button>
                </div>

                <!-- Module Content -->
                <div class="flex flex-col gap-[12px] items-start relative shrink-0 w-full">
                  <p class="text-gray-700 text-sm">
                    Track and manage support tickets efficiently with priority handling.
                  </p>
                  <div class="grid grid-cols-2 gap-4 w-full text-xs text-gray-600">
                    <div>• Priority management</div>
                    <div>• Status tracking</div>
                    <div>• Client assignment</div>
                    <div>• Category filtering</div>
                  </div>
                  <div class="flex gap-[4px] items-center mt-4">
                    <div class="text-[14px] font-medium text-black">{{ totalTickets }}</div>
                    <div class="text-[12px] text-gray-600">open tickets</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Calendar Module -->
            <div class="bg-[rgba(255,255,255,0.4)] relative rounded-[32px] border border-white/50 cursor-pointer hover:bg-[rgba(255,255,255,0.5)] transition-colors" @click="navigateTo('/ascent/calendar')">
              <div class="box-border flex flex-col items-start overflow-clip p-[24px] relative w-full h-full">
                <!-- Module Header -->
                <div class="box-border flex items-center justify-between pb-[24px] pt-0 px-0 relative shrink-0 w-full">
                  <div class="flex gap-[8px] items-center leading-[0] not-italic relative shrink-0 text-black text-center">
                    <div class="text-[32px]">📅</div>
                    <div class="flex flex-col justify-center relative shrink-0 text-[20px] font-medium">
                      Calendar
                    </div>
                  </div>
                  <button class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer">
                    <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                      Manage
                    </div>
                  </button>
                </div>

                <!-- Module Content -->
                <div class="flex flex-col gap-[12px] items-start relative shrink-0 w-full">
                  <p class="text-gray-700 text-sm">
                    Schedule and manage your appointments, meetings, and events.
                  </p>
                  <div class="grid grid-cols-2 gap-4 w-full text-xs text-gray-600">
                    <div>• Event scheduling</div>
                    <div>• Multiple view types</div>
                    <div>• Attendee management</div>
                    <div>• Time blocking</div>
                  </div>
                  <div class="flex gap-[4px] items-center mt-4">
                    <div class="text-[14px] font-medium text-black">{{ totalEvents }}</div>
                    <div class="text-[12px] text-gray-600">events today</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Todo Module -->
            <div class="bg-[rgba(255,255,255,0.4)] relative rounded-[32px] border border-white/50 cursor-pointer hover:bg-[rgba(255,255,255,0.5)] transition-colors" @click="navigateTo('/ascent/todo')">
              <div class="box-border flex flex-col items-start overflow-clip p-[24px] relative w-full h-full">
                <!-- Module Header -->
                <div class="box-border flex items-center justify-between pb-[24px] pt-0 px-0 relative shrink-0 w-full">
                  <div class="flex gap-[8px] items-center leading-[0] not-italic relative shrink-0 text-black text-center">
                    <div class="text-[32px]">✅</div>
                    <div class="flex flex-col justify-center relative shrink-0 text-[20px] font-medium">
                      Todo
                    </div>
                  </div>
                  <button class="box-border flex gap-[10px] h-[36px] items-center justify-center px-[18px] py-0 relative rounded-[32px] border border-[#a0a0a0] hover:bg-gray-100 transition-colors cursor-pointer">
                    <div class="flex flex-col justify-center leading-[0] not-italic relative shrink-0 text-[12px] text-black whitespace-nowrap font-light">
                      Manage
                    </div>
                  </button>
                </div>

                <!-- Module Content -->
                <div class="flex flex-col gap-[12px] items-start relative shrink-0 w-full">
                  <p class="text-gray-700 text-sm">
                    Organize tasks and track your daily productivity goals.
                  </p>
                  <div class="grid grid-cols-2 gap-4 w-full text-xs text-gray-600">
                    <div>• Task management</div>
                    <div>• Priority levels</div>
                    <div>• Due date tracking</div>
                    <div>• Progress monitoring</div>
                  </div>
                  <div class="flex gap-[4px] items-center mt-4">
                    <div class="text-[14px] font-medium text-black">{{ totalTodos }}</div>
                    <div class="text-[12px] text-gray-600">pending tasks</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import EverestLogo from "~/components/EverestLogo.vue";

// Page metadata
useHead({
  title: 'Ascent Hub - EverestFlow'
})

// Composables
const { clients } = useClients()
const { tickets, openTickets } = useTickets()
const { todos } = useTodos()
const { events: calendarEvents, todayEvents } = useCalendar()

// Reactive data
const isDarkMode = ref(false)
const userAvatar = ref('https://github.com/benjamincanac.png')

// Computed
const totalClients = computed(() => clients.value?.length || 0)
const totalTickets = computed(() => openTickets.value?.length || 0)
const totalTodos = computed(() => todos.value?.filter(todo => !todo.completed).length || 0)
const totalEvents = computed(() => todayEvents.value?.length || 0)

// Methods
const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
}

const shareLocation = () => {
  console.log('Sharing location...')
}

// Navigation helper
const router = useRouter()
const navigateTo = (path) => {
  return router.push(path)
}

// Load data on mount
onMounted(async () => {
  // Load data for counters
  const { fetchClients } = useClients()
  const { fetchTickets } = useTickets()
  const { fetchTodos } = useTodos()
  const { fetchEvents } = useCalendar()

  await Promise.all([
    fetchClients(),
    fetchTickets(),
    fetchTodos(),
    fetchEvents()
  ])
})
</script>

<style scoped>
/* Custom fonts - you'll need to add these to your Nuxt config */
.font-lufga-light {
  font-family: 'FONTSPRING DEMO - Lufga ExtraLight', sans-serif;
}

.font-lufga-medium {
  font-family: 'FONTSPRING DEMO - Lufga Medium', sans-serif;
}

.font-lufga-semibold {
  font-family: 'FONTSPRING DEMO - Lufga SemiBold', sans-serif;
}

.font-outfit {
  font-family: 'Outfit', sans-serif;
}
</style>