<template>
  <UPopover v-if="infoMessage" mode="hover" :ui="{ content: 'max-w-sm' }">
    <UIcon
      name="i-lucide-info"
      class="w-4 h-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 cursor-help"
    />
    <template #content>
      <div class="p-3 text-sm whitespace-pre-line">
        {{ infoMessage }}
      </div>
    </template>
  </UPopover>
</template>

<script setup lang="ts">
interface Props {
  infoMessage?: string | null
}

defineProps<Props>()
</script>
