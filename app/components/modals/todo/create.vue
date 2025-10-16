<template>
  <UModal>
    <UButton color="neutral" variant="outline" class="py-2 px-4">+Add ToDo</UButton>

    <template #footer>
      <div class="flex justify-end gap-2">
        <UButton color="gray" variant="soft" @click="close">
          Cancel
        </UButton>
        <UButton color="primary" :loading="isSubmitting" @click="addTodo(close)">
          Create Todo
        </UButton>
      </div>
    </template>

  </UModal>
</template>