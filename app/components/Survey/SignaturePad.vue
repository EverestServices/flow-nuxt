<template>
  <div class="space-y-2">
    <div class="flex items-center justify-between">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        Aláírás:
      </label>
      <UButton
        icon="i-lucide-eraser"
        size="xs"
        color="gray"
        variant="ghost"
        @click="clear"
      >
        Törlés
      </UButton>
    </div>
    <div
      class="relative border-2 border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 overflow-hidden"
      :class="{ 'border-primary': isDrawing }"
    >
      <canvas
        ref="canvasRef"
        :width="canvasWidth"
        :height="canvasHeight"
        class="touch-none cursor-crosshair"
        @mousedown="handleMouseDown"
        @mousemove="handleMouseMove"
        @mouseup="handleMouseUp"
        @mouseleave="handleMouseLeave"
        @touchstart="handleTouchStart"
        @touchmove="handleTouchMove"
        @touchend="handleTouchEnd"
      ></canvas>
      <div
        v-if="isEmpty"
        class="absolute inset-0 flex items-center justify-center pointer-events-none"
      >
        <p class="text-gray-400 dark:text-gray-500 text-sm">
          Kérem írja alá itt
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'

interface Props {
  modelValue?: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const canvasRef = ref<HTMLCanvasElement | null>(null)
const canvasWidth = 800
const canvasHeight = 200

const isDrawing = ref(false)
const isEmpty = ref(true)
const lastX = ref(0)
const lastY = ref(0)

let ctx: CanvasRenderingContext2D | null = null

onMounted(() => {
  const canvas = canvasRef.value
  if (!canvas) return

  ctx = canvas.getContext('2d')
  if (!ctx) return

  // Set up canvas context
  ctx.lineWidth = 2
  ctx.lineCap = 'round'
  ctx.lineJoin = 'round'
  ctx.strokeStyle = '#000000'

  // Set canvas background to white for proper export
  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, canvasWidth, canvasHeight)

  // Load initial signature if provided
  if (props.modelValue) {
    loadSignature(props.modelValue)
  }
})

const loadSignature = (dataUrl: string) => {
  if (!ctx || !canvasRef.value) return

  const img = new Image()
  img.onload = () => {
    ctx!.drawImage(img, 0, 0)
    isEmpty.value = false
  }
  img.src = dataUrl
}

const getCoordinates = (e: MouseEvent | Touch): { x: number; y: number } => {
  const canvas = canvasRef.value
  if (!canvas) return { x: 0, y: 0 }

  const rect = canvas.getBoundingClientRect()
  const scaleX = canvasWidth / rect.width
  const scaleY = canvasHeight / rect.height

  return {
    x: (e.clientX - rect.left) * scaleX,
    y: (e.clientY - rect.top) * scaleY
  }
}

const startDrawing = (x: number, y: number) => {
  isDrawing.value = true
  lastX.value = x
  lastY.value = y
}

const draw = (x: number, y: number) => {
  if (!isDrawing.value || !ctx) return

  ctx.beginPath()
  ctx.moveTo(lastX.value, lastY.value)
  ctx.lineTo(x, y)
  ctx.stroke()

  lastX.value = x
  lastY.value = y
  isEmpty.value = false
}

const stopDrawing = () => {
  if (isDrawing.value) {
    isDrawing.value = false
    emitSignature()
  }
}

// Mouse events
const handleMouseDown = (e: MouseEvent) => {
  e.preventDefault()
  const { x, y } = getCoordinates(e)
  startDrawing(x, y)
}

const handleMouseMove = (e: MouseEvent) => {
  e.preventDefault()
  const { x, y } = getCoordinates(e)
  draw(x, y)
}

const handleMouseUp = (e: MouseEvent) => {
  e.preventDefault()
  stopDrawing()
}

const handleMouseLeave = (e: MouseEvent) => {
  e.preventDefault()
  stopDrawing()
}

// Touch events
const handleTouchStart = (e: TouchEvent) => {
  e.preventDefault()
  const touch = e.touches[0]
  const { x, y } = getCoordinates(touch)
  startDrawing(x, y)
}

const handleTouchMove = (e: TouchEvent) => {
  e.preventDefault()
  const touch = e.touches[0]
  const { x, y } = getCoordinates(touch)
  draw(x, y)
}

const handleTouchEnd = (e: TouchEvent) => {
  e.preventDefault()
  stopDrawing()
}

const clear = () => {
  if (!ctx || !canvasRef.value) return

  // Clear canvas
  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, canvasWidth, canvasHeight)

  isEmpty.value = true
  emit('update:modelValue', '')
}

const emitSignature = () => {
  if (!canvasRef.value) return

  const dataUrl = canvasRef.value.toDataURL('image/png')
  emit('update:modelValue', dataUrl)
}

// Export signature as data URL (for external use)
const getSignatureDataUrl = (): string => {
  if (!canvasRef.value) return ''
  return canvasRef.value.toDataURL('image/png')
}

defineExpose({
  clear,
  getSignatureDataUrl,
  isEmpty: () => isEmpty.value
})
</script>

<style scoped>
canvas {
  display: block;
  width: 100%;
  height: auto;
}
</style>
