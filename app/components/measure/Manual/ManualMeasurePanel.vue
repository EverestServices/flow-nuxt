<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h3 class="text-sm font-semibold">Kézi kijelölés</h3>
      <UBadge color="warning" size="xs">Manual</UBadge>
    </div>

    <div class="grid grid-cols-3 gap-2">
      <USelect v-model="shapeType" :options="shapeOptions" size="sm" />
      <div class="col-span-2 text-right text-xs text-gray-500" v-if="areaM2 > 0">{{ areaM2.toFixed(2) }} m²</div>
    </div>

    <div v-if="shapeType==='rectangle'" class="grid grid-cols-2 gap-3">
      <UInput v-model.number="rect.width" type="number" min="0" step="0.01" size="sm" placeholder="Szélesség (m)" />
      <UInput v-model.number="rect.height" type="number" min="0" step="0.01" size="sm" placeholder="Magasság (m)" />
    </div>

    <div v-if="shapeType==='triangle'" class="space-y-3">
      <URadio v-model="triKind" :value="'base_height'" label="Alap + magasság" />
      <div v-if="triKind==='base_height'" class="grid grid-cols-2 gap-3">
        <UInput v-model.number="tri.base" type="number" min="0" step="0.01" size="sm" placeholder="Alap (m)" />
        <UInput v-model.number="tri.height" type="number" min="0" step="0.01" size="sm" placeholder="Magasság (m)" />
      </div>
      <URadio v-model="triKind" :value="'sides'" label="3 oldal" />
      <div v-if="triKind==='sides'" class="grid grid-cols-3 gap-3">
        <UInput v-model.number="tri.a" type="number" min="0" step="0.01" size="sm" placeholder="a (m)" />
        <UInput v-model.number="tri.b" type="number" min="0" step="0.01" size="sm" placeholder="b (m)" />
        <UInput v-model.number="tri.c" type="number" min="0" step="0.01" size="sm" placeholder="c (m)" />
      </div>
    </div>

    <div v-if="shapeType==='pentagon'" class="space-y-3">
      <div class="grid grid-cols-3 gap-3">
        <UInput v-model.number="pent.s1" type="number" min="0" step="0.01" size="sm" placeholder="s1 (m)" />
        <UInput v-model.number="pent.s2" type="number" min="0" step="0.01" size="sm" placeholder="s2 (m)" />
        <UInput v-model.number="pent.s3" type="number" min="0" step="0.01" size="sm" placeholder="s3 (m)" />
      </div>
      <div class="grid grid-cols-3 gap-3">
        <UInput v-model.number="pent.r1" type="number" min="0" step="0.01" size="sm" placeholder="r1 (m)" />
        <UInput v-model.number="pent.r2" type="number" min="0" step="0.01" size="sm" placeholder="r2 (m)" />
        <UInput v-model.number="pent.hrect" type="number" min="0" step="0.01" size="sm" placeholder="Téglalap H (m)" />
      </div>
    </div>

    <div v-if="errorMessage" class="text-xs text-red-600">{{ errorMessage }}</div>

    <div class="flex items-center justify-between">
      <div class="text-xs text-gray-500">Mentett kézi alakzatok: {{ savedCount }} db</div>
      <UButton size="sm" color="primary" :disabled="!canSave" @click="handleSave">Mentés</UButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useWallStore } from '@/stores/WallStore'
import { useMeasure } from '@/composables/useMeasure'
import type { ManualShape, Point, Wall, WallImage } from '@/model/Measure/ArucoWallSurface'

const props = defineProps<{ wallId: string; imageId: string }>()

const route = useRoute()
const surveyId = computed(() => String(route.params.surveyId))
const store = useWallStore()
const { appendManualShape, updateWallImage } = useMeasure()

const shapeType = ref<'rectangle'|'triangle'|'pentagon'>('rectangle')
const shapeOptions = [
  { label: 'Téglalap', value: 'rectangle' },
  { label: 'Háromszög', value: 'triangle' },
  { label: 'Ötszög', value: 'pentagon' },
]

const rect = reactive({ width: 0, height: 0 })
const triKind = ref<'base_height'|'sides'>('base_height')
const tri = reactive({ base: 0, height: 0, a: 0, b: 0, c: 0 })
const pent = reactive({ s1: 0, s2: 0, s3: 0, r1: 0, r2: 0, hrect: 0 })

const imageRef = computed<WallImage|undefined>(() => {
  const w = store.getWallsForSurvey(surveyId.value)[props.wallId] as Wall | undefined
  return w?.images?.find(i => i.imageId === props.imageId)
})

const savedCount = computed(() => imageRef.value?.manualShapes?.length ?? 0)

const errorMessage = computed(() => validate().message)
const canSave = computed(() => validate().ok)
const areaM2 = computed(() => computeArea())

function validate(): { ok: boolean; message: string } {
  const positive = (n: number) => Number.isFinite(n) && n > 0 && n <= 1000
  if (shapeType.value === 'rectangle') {
    if (!positive(rect.width)) return { ok: false, message: 'Szélesség kötelező és > 0' }
    if (!positive(rect.height)) return { ok: false, message: 'Magasság kötelező és > 0' }
    return { ok: true, message: '' }
  }
  if (shapeType.value === 'triangle') {
    if (triKind.value === 'base_height') {
      if (!positive(tri.base)) return { ok: false, message: 'Alap kötelező és > 0' }
      if (!positive(tri.height)) return { ok: false, message: 'Magasság kötelező és > 0' }
      return { ok: true, message: '' }
    } else {
      if (!positive(tri.a) || !positive(tri.b) || !positive(tri.c)) return { ok: false, message: 'Minden oldal > 0' }
      const a=tri.a,b=tri.b,c=tri.c
      if (!(a+b>c && a+c>b && b+c>a)) return { ok: false, message: 'Háromszög-egyenlőtlenség nem teljesül' }
      return { ok: true, message: '' }
    }
  }
  if (shapeType.value === 'pentagon') {
    if (!positive(pent.s1) || !positive(pent.s2) || !positive(pent.s3)) return { ok: false, message: 'Alsó szegmensek > 0' }
    if (!positive(pent.hrect)) return { ok: false, message: 'Téglalap magasság > 0' }
    if (!positive(pent.r1) || !positive(pent.r2)) return { ok: false, message: 'Tető oldalak > 0' }
    const W = pent.s1+pent.s2+pent.s3
    const a=pent.r1,b=pent.r2,c=W
    if (!(a+b>c && a+c>b && b+c>a)) return { ok: false, message: 'Tető háromszög oldalai nem konzisztensek' }
    return { ok: true, message: '' }
  }
  return { ok: false, message: 'Ismeretlen alakzat' }
}

function computeArea(): number {
  if (!validate().ok) return 0
  if (shapeType.value==='rectangle') return rect.width*rect.height
  if (shapeType.value==='triangle') {
    if (triKind.value==='base_height') return tri.base*tri.height/2
    const a=tri.a,b=tri.b,c=tri.c
    const s=(a+b+c)/2
    return Math.sqrt(Math.max(0,s*(s-a)*(s-b)*(s-c)))
  }
  const W=pent.s1+pent.s2+pent.s3
  const rectA=W*pent.hrect
  const a=pent.r1,b=pent.r2,c=W
  const s=(a+b+c)/2
  const roofA=Math.sqrt(Math.max(0,s*(s-a)*(s-b)*(s-c)))
  return rectA+roofA
}

function computePolygons(): Array<{points: Point[]}> {
  if (!validate().ok) return []
  if (shapeType.value==='rectangle') {
    const W=rect.width,H=rect.height
    return [{ points:[{x:0,y:0},{x:W,y:0},{x:W,y:H},{x:0,y:H}] }]
  }
  if (shapeType.value==='triangle') {
    if (triKind.value==='base_height') {
      const b=tri.base,h=tri.height
      return [{ points:[{x:0,y:0},{x:b,y:0},{x:b/2,y:h}] }]
    }
    const a=tri.a,b=tri.b,c=tri.c
    const x=(a*a + c*c - b*b)/(2*c)
    const h=Math.sqrt(Math.max(0,a*a - x*x))
    return [{ points:[{x:0,y:0},{x:c,y:0},{x:x,y:h}] }]
  }
  const W=pent.s1+pent.s2+pent.s3
  const H=pent.hrect
  const a=pent.r1,b=pent.r2,c=W
  const x=(a*a + c*c - b*b)/(2*c)
  const h=Math.sqrt(Math.max(0,a*a - x*x))
  return [
    { points:[{x:0,y:0},{x:W,y:0},{x:W,y:H},{x:0,y:H}] },
    { points:[{x:0,y:H},{x:W,y:H},{x:x,y:H+h}] },
  ]
}

async function handleSave() {
  if (!canSave.value || !imageRef.value) return
  const shape: ManualShape = {
    id: crypto.randomUUID(),
    type: shapeType.value,
    params: shapeType.value==='rectangle'
      ? { width_m: rect.width, height_m: rect.height }
      : shapeType.value==='triangle'
        ? (triKind.value==='base_height'
          ? { kind:'base_height', base_m: tri.base, height_m: tri.height }
          : { kind:'sides', a_m: tri.a, b_m: tri.b, c_m: tri.c })
        : { bottom_segments_m:[pent.s1,pent.s2,pent.s3], rect_height_m: pent.hrect, roof_sides_m:[pent.r1,pent.r2] },
    polygons: computePolygons(),
    areaM2: computeArea(),
  }
  await appendManualShape(imageRef.value.imageId, shape)
  imageRef.value.manualShapes = [...(imageRef.value.manualShapes ?? []), shape]
  imageRef.value.manual = true
  await updateWallImage(imageRef.value.imageId, { manual: true })
  const w = store.getWallsForSurvey(surveyId.value)[props.wallId] as Wall
  store.setWall(surveyId.value, w.id, { ...w })
  ;(rect.width=0);(rect.height=0);(tri.base=0);(tri.height=0);(tri.a=0);(tri.b=0);(tri.c=0);(pent.s1=0);(pent.s2=0);(pent.s3=0);(pent.r1=0);(pent.r2=0);(pent.hrect=0)
}
</script>
