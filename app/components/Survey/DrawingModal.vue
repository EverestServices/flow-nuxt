<!--
  DrawingModal Component

  A simple drawing interface with pen, eraser, and undo functionality.
  Saves drawings as PNG base64 strings.
-->
<template>
  <UIModal
    v-model="isOpen"
    :scrollable="false"
    :max-width="`${canvasWidth + 80}px`"
    @close="cancel"
  >
    <template #header>
      <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
        {{ title }}
      </h3>
    </template>

    <div>
      <!-- Toolbar -->
      <div class="flex items-center gap-2 mb-4 p-3 bg-gray-100 dark:bg-gray-800 rounded-lg">
        <!-- Pen tool -->
        <button
          type="button"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2',
            currentTool === 'pen'
              ? 'bg-primary-500 text-white'
              : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600'
          ]"
          @click="selectTool('pen')"
        >
          <UIcon name="i-lucide-pencil" class="w-5 h-5" />
          Toll
        </button>

        <!-- Eraser tool -->
        <button
          type="button"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2',
            currentTool === 'eraser'
              ? 'bg-primary-500 text-white'
              : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600'
          ]"
          @click="selectTool('eraser')"
        >
          <UIcon name="i-lucide-eraser" class="w-5 h-5" />
          Radír
        </button>

        <div class="w-px h-8 bg-gray-300 dark:bg-gray-600 mx-2" />

        <!-- Undo button -->
        <button
          type="button"
          class="px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="!canUndo"
          @click="undo"
        >
          <UIcon name="i-lucide-undo" class="w-5 h-5" />
          Visszavonás
        </button>

        <!-- Clear all button -->
        <button
          type="button"
          class="px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 bg-white dark:bg-gray-700 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
          @click="clearCanvas"
        >
          <UIcon name="i-lucide-trash-2" class="w-5 h-5" />
          Törlés
        </button>
      </div>

      <!-- Canvas -->
      <div class="border-2 border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden bg-white">
        <canvas
          ref="canvasRef"
          :width="canvasWidth"
          :height="canvasHeight"
          class="cursor-crosshair touch-none"
          @mousedown="startDrawing"
          @mousemove="draw"
          @mouseup="stopDrawing"
          @mouseleave="stopDrawing"
          @touchstart.prevent="handleTouchStart"
          @touchmove.prevent="handleTouchMove"
          @touchend.prevent="stopDrawing"
        />
      </div>
    </div>

    <template #footer>
      <div class="flex justify-end gap-3 w-full">
        <button
          type="button"
          class="px-4 py-2 rounded-lg font-medium transition-colors bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600"
          @click="cancel"
        >
          Mégse
        </button>
        <button
          type="button"
          class="px-4 py-2 rounded-lg font-medium transition-colors bg-primary-500 text-white hover:bg-primary-600"
          @click="save"
        >
          Mentés
        </button>
      </div>
    </template>
  </UIModal>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'

interface Props {
  modelValue: boolean
  title?: string
  canvasWidth?: number
  canvasHeight?: number
  initialImage?: string // Base64 image string
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Rajzolás',
  canvasWidth: 800,
  canvasHeight: 600,
  initialImage: ''
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'save': [imageData: string]
}>()

const isOpen = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit('update:modelValue', value)
})

// Canvas and drawing state
const canvasRef = ref<HTMLCanvasElement | null>(null)
const currentTool = ref<'pen' | 'eraser'>('pen')
const isDrawing = ref(false)
const undoStack = ref<string[]>([]) // Stack of canvas states as base64 strings

// Drawing properties
const PEN_WIDTH = 2
const ERASER_WIDTH = 20

// Initialize canvas when modal opens
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    nextTick(() => {
      initializeCanvas()
    })
  }
})

onMounted(() => {
  if (props.modelValue) {
    initializeCanvas()
  }
})

function initializeCanvas() {
  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  // Set white background
  ctx.fillStyle = 'white'
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  // Load initial image if provided
  if (props.initialImage) {
    loadImageFromBase64(props.initialImage)
  } else {
    // Save initial state to undo stack
    saveState()
  }
}

function loadImageFromBase64(base64: string) {
  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const img = new Image()
  img.onload = () => {
    ctx.drawImage(img, 0, 0)
    // Save initial state to undo stack
    saveState()
  }
  img.src = base64
}

function selectTool(tool: 'pen' | 'eraser') {
  currentTool.value = tool
}

function getMousePos(e: MouseEvent): { x: number; y: number } {
  const canvas = canvasRef.value
  if (!canvas) return { x: 0, y: 0 }

  const rect = canvas.getBoundingClientRect()
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top
  }
}

function getTouchPos(e: TouchEvent): { x: number; y: number } {
  const canvas = canvasRef.value
  if (!canvas) return { x: 0, y: 0 }

  const rect = canvas.getBoundingClientRect()
  const touch = e.touches[0]
  return {
    x: touch.clientX - rect.left,
    y: touch.clientY - rect.top
  }
}

function startDrawing(e: MouseEvent) {
  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  isDrawing.value = true

  const pos = getMousePos(e)

  ctx.beginPath()
  ctx.moveTo(pos.x, pos.y)

  if (currentTool.value === 'pen') {
    ctx.strokeStyle = 'black'
    ctx.lineWidth = PEN_WIDTH
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
  } else {
    ctx.strokeStyle = 'white'
    ctx.lineWidth = ERASER_WIDTH
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
  }
}

function draw(e: MouseEvent) {
  if (!isDrawing.value) return

  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const pos = getMousePos(e)

  ctx.lineTo(pos.x, pos.y)
  ctx.stroke()
}

function stopDrawing() {
  if (!isDrawing.value) return

  isDrawing.value = false

  // Save state to undo stack
  saveState()
}

function handleTouchStart(e: TouchEvent) {
  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  isDrawing.value = true

  const pos = getTouchPos(e)

  ctx.beginPath()
  ctx.moveTo(pos.x, pos.y)

  if (currentTool.value === 'pen') {
    ctx.strokeStyle = 'black'
    ctx.lineWidth = PEN_WIDTH
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
  } else {
    ctx.strokeStyle = 'white'
    ctx.lineWidth = ERASER_WIDTH
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
  }
}

function handleTouchMove(e: TouchEvent) {
  if (!isDrawing.value) return

  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const pos = getTouchPos(e)

  ctx.lineTo(pos.x, pos.y)
  ctx.stroke()
}

function saveState() {
  const canvas = canvasRef.value
  if (!canvas) return

  // Save current canvas state as base64
  const state = canvas.toDataURL('image/png')
  undoStack.value.push(state)

  // Limit undo stack to 20 states
  if (undoStack.value.length > 20) {
    undoStack.value.shift()
  }
}

const canUndo = computed(() => undoStack.value.length > 1)

function undo() {
  if (!canUndo.value) return

  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  // Remove current state
  undoStack.value.pop()

  // Get previous state
  const previousState = undoStack.value[undoStack.value.length - 1]

  // Load previous state
  const img = new Image()
  img.onload = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.drawImage(img, 0, 0)
  }
  img.src = previousState
}

function clearCanvas() {
  const canvas = canvasRef.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  if (!ctx) return

  // Fill with white background
  ctx.fillStyle = 'white'
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  // Save state
  saveState()
}

function save() {
  const canvas = canvasRef.value
  if (!canvas) return

  // Export canvas as PNG base64
  const imageData = canvas.toDataURL('image/png')

  emit('save', imageData)
  emit('update:modelValue', false)
}

function cancel() {
  emit('update:modelValue', false)
}
</script>
