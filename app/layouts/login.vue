<template>
  <div class="w-screen h-screen fixed p-8">
    <video
        class=" w-full h-full object-cover rounded-4xl"
        autoplay
        muted
        loop
        playsinline
    >
      <source src="~assets/mounteverest.mov" type="video/quicktime">
    </video>

  </div>

  <slot />
</template>
<script setup lang="ts">
</script>