<template>
  <div class="relative w-full h-full">
    <!-- Time labels -->
    <div v-for="(time, index) in timeSlots" :key="time"
         class="absolute flex flex-col font-extralight justify-center leading-[0] left-[50px] not-italic text-[10px] text-black text-right translate-x-[-100%] translate-y-[-50%] w-[50px]"
         :style="{ top: `${65.5 + (index * 30)}px` }">
      <p class="leading-normal">{{ time }}</p>
    </div>

    <!-- Vertical line -->
    <div class="absolute flex h-[335px] items-center justify-center left-[69px] top-[11px] w-[0px]">
      <div class="flex-none rotate-[90deg]">
        <div class="h-0 relative w-[335px]">
          <div class="absolute bottom-0 left-0 right-0 top-[-1px] border-t border-gray-300"></div>
        </div>
      </div>
    </div>

    <!-- Horizontal lines -->
    <div v-for="(time, index) in timeSlots" :key="`line-${time}`"
         class="absolute h-0 left-[57px] w-[513px] border-t border-gray-300"
         :style="{ top: `${66 + (index * 30)}px` }">
    </div>

    <!-- Events -->
    <div v-for="(event, index) in events" :key="index"
         class="absolute bg-[rgba(255,255,255,0.5)] box-border flex gap-[10px] h-[29px] items-center justify-center left-[85px] px-[16px] py-[19px] rounded-[8px] w-[481px] border border-white"
         :style="{ top: `${getEventPosition(event.time)}px` }">
      <div class="flex flex-col font-extralight justify-center leading-[0] not-italic relative shrink-0 text-[16px] text-black whitespace-nowrap">
        <p class="leading-normal whitespace-pre">{{ event.title }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  events: Array
})

const timeSlots = [
  '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'
]

const getEventPosition = (time) => {
  const hour = parseInt(time.split(':')[0])
  const basePosition = 96
  return basePosition + ((hour - 9) * 30)
}
</script>