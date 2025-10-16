<template>
  <div class="video-background-container">
    <video
        class="video-background"
        autoplay
        muted
        loop
        playsinline
    >
      <source src="~assets/mounteverest.mov" type="video/quicktime">
    </video>
    <UPage>
      <UPageBody>
        <slot />
      </UPageBody>
    </UPage>
  </div>
</template>

<style scoped>
.video-background-container {
  position: relative;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.video-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  z-index: -1;
}
</style>