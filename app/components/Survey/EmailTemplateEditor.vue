<template>
  <div class="space-y-2">
    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
      E-mail sablon szerkesztése
    </label>
    <div class="border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden">
      <!-- Toolbar -->
      <div class="bg-gray-50 dark:bg-gray-700 border-b border-gray-300 dark:border-gray-600 px-3 py-2 flex items-center gap-2">
        <UButton
          icon="i-lucide-bold"
          size="xs"
          color="gray"
          variant="ghost"
          @click="insertFormatting('**', '**')"
          title="Bold"
        />
        <UButton
          icon="i-lucide-italic"
          size="xs"
          color="gray"
          variant="ghost"
          @click="insertFormatting('_', '_')"
          title="Italic"
        />
        <UButton
          icon="i-lucide-underline"
          size="xs"
          color="gray"
          variant="ghost"
          @click="insertFormatting('<u>', '</u>')"
          title="Underline"
        />
        <div class="w-px h-6 bg-gray-300 dark:bg-gray-600"></div>
        <UButton
          icon="i-lucide-list"
          size="xs"
          color="gray"
          variant="ghost"
          @click="insertList"
          title="List"
        />
        <UButton
          icon="i-lucide-link"
          size="xs"
          color="gray"
          variant="ghost"
          @click="insertLink"
          title="Insert Link"
        />
      </div>

      <!-- Editor Area -->
      <textarea
        ref="textareaRef"
        v-model="content"
        class="w-full px-4 py-3 bg-white dark:bg-gray-800 text-gray-900 dark:text-white resize-none focus:outline-none"
        rows="10"
        placeholder="Írja be az e-mail szövegét..."
        @input="handleInput"
      ></textarea>
    </div>
    <p class="text-xs text-gray-500 dark:text-gray-400">
      Használható helyőrzők: {client_name}, {contract_name}, {total_price}
    </p>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  modelValue: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const textareaRef = ref<HTMLTextAreaElement | null>(null)
const content = ref(props.modelValue)

watch(() => props.modelValue, (newVal) => {
  content.value = newVal
})

const handleInput = () => {
  emit('update:modelValue', content.value)
}

const insertFormatting = (before: string, after: string) => {
  const textarea = textareaRef.value
  if (!textarea) return

  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = content.value.substring(start, end)

  const newText =
    content.value.substring(0, start) +
    before + selectedText + after +
    content.value.substring(end)

  content.value = newText
  emit('update:modelValue', content.value)

  // Restore cursor position
  setTimeout(() => {
    textarea.focus()
    textarea.setSelectionRange(start + before.length, end + before.length)
  }, 0)
}

const insertList = () => {
  const textarea = textareaRef.value
  if (!textarea) return

  const start = textarea.selectionStart
  const listItem = '\n- Lista elem\n'

  const newText =
    content.value.substring(0, start) +
    listItem +
    content.value.substring(start)

  content.value = newText
  emit('update:modelValue', content.value)

  setTimeout(() => {
    textarea.focus()
    textarea.setSelectionRange(start + listItem.length, start + listItem.length)
  }, 0)
}

const insertLink = () => {
  const url = prompt('Adja meg a link címét:')
  if (!url) return

  const linkText = prompt('Adja meg a link szövegét:', 'Link')
  if (!linkText) return

  const textarea = textareaRef.value
  if (!textarea) return

  const start = textarea.selectionStart
  const link = `[${linkText}](${url})`

  const newText =
    content.value.substring(0, start) +
    link +
    content.value.substring(start)

  content.value = newText
  emit('update:modelValue', content.value)

  setTimeout(() => {
    textarea.focus()
    textarea.setSelectionRange(start + link.length, start + link.length)
  }, 0)
}
</script>
