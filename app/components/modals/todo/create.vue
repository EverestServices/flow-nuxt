<template>
  <UIModal v-model="isOpen" title="Add ToDo" size="md">
    <UIButtonEnhanced variant="outline" @click="isOpen = true">
      +Add ToDo
    </UIButtonEnhanced>

    <template #footer>
      <UIButtonEnhanced variant="ghost" @click="close">
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced variant="primary" :loading="isSubmitting" @click="addTodo(close)">
        Create Todo
      </UIButtonEnhanced>
    </template>

  </UIModal>
</template>

<script setup lang="ts">
const isOpen = ref(false)
const isSubmitting = ref(false)

const close = () => {
  isOpen.value = false
}

const addTodo = async (closeModal: () => void) => {
  isSubmitting.value = true
  // Add your todo creation logic here
  // For now, just close the modal
  setTimeout(() => {
    isSubmitting.value = false
    closeModal()
  }, 500)
}
</script>