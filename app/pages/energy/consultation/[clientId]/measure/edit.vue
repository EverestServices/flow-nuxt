<template></template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
const route = useRoute()
await navigateTo(`/energy/consultation/${String(route.params.clientId)}/measure`)
</script>
