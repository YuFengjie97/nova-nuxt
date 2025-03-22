<script lang="ts" setup>
import { Application } from 'pixi.js'
import { Pane } from 'tweakpane'
import { BarChart, LineChart } from './ui'
import music from '/sound/savageLove.aac'

const inputFile = ref<HTMLInputElement>()
const pixiCon = ref<HTMLElement>()
const app = new Application()
const fftSize = 1024
const targetSize = 100
// const frequencyColors = chroma.scale(['#fdcb6e', '#6c5ce7'])
//   .mode('lch')
//   .colors(7)

async function initApp(app: Application, container: HTMLElement) {
  await app.init({ antialias: true, background: '#1099bb', resizeTo: container })
  container.appendChild(app.canvas)
}

let ap: AudioParse
let bassMaxMaginatude = 0
let wideMaxMaginatude = 0

async function handelMusicChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (!target.files) {
    return
  }
  const file = target.files[0]
  const arrayBuffer = await getArrayBufferByFile(file)
  const audioBuffer = await getAudioBufferByArrayBuffer(arrayBuffer)
  const sampleRage = audioBuffer.sampleRate
  console.log('audioBuffer', audioBuffer, 'sampleRage', sampleRage)

  const mixedTimeDomainData = mixedTimeDomain(audioBuffer)
  console.log('mixedTimeDomainData', mixedTimeDomainData)

  const frequencyFrames = getFrequencyFrames(mixedTimeDomainData, fftSize)
  console.log('frequencyFrames', frequencyFrames)

  const maxMaginatude = getMaxBassAndWideMagnitude(frequencyFrames, sampleRage, fftSize)
  bassMaxMaginatude = maxMaginatude.bassMaxMaginatude
  wideMaxMaginatude = maxMaginatude.wideMaxMaginatude
  console.log({ bassMaxMaginatude, wideMaxMaginatude })
}

onMounted(async () => {
  await initApp(app, pixiCon.value!)

  const settings = {
    smoothingTimeConstant: 0.8,
  }

  ap = new AudioParse(music, fftSize)

  function initPane() {
    const pane = new Pane()
    pane.addButton({ title: 'play' }).on('click', () => ap.play())
    pane.addButton({ title: 'pause' }).on('click', () => ap.pause())
    pane.addButton({ title: 'reset' }).on('click', () => ap.reset())
    pane.addBinding(settings, 'smoothingTimeConstant', { min: 0, max: 1, step: 0.1 }).on('change', (ev) => {
      ap.setSmoothingTimeConstant(ev.value)
    })
    pane.addButton({ title: 'upload' }).on('click', () => {
      inputFile.value?.click()
    })
  }
  initPane()

  const frequencyChart = new BarChart(app, { w: 500, h: 200 }).setPos(0, 200)
  const timeDomainChart = new LineChart(app, { w: 500, h: 200 }).setPos(500, 200)
  const frequencyChart2 = new BarChart(app, { w: 500, h: 200 }).setPos(0, 400)

  function update1() {
    const dp = new DataProcessor(Array.from(ap.getByteFrequencyData()))
    const data = dp
      .avgBucket(targetSize)
      .smooth()
      .normalize()
      .data
    frequencyChart.update(data)
  }
  function update2() {
    const dp = new DataProcessor(Array.from(ap.getByteTimeDomainData()))
    const data = dp
      .avgBucket(targetSize)
      .smooth()
      .normalize()
      .data
    timeDomainChart.update(data)
  }

  function update3() {
    const timeDomainData = ap.getFloatTimeDomainData()
    const frequencyData = getFrequency(timeDomainData, fftSize)
    const dp = new DataProcessor(Array.from(frequencyData))
    const data = dp
      .avgBucket(targetSize)
      .normalize(bassMaxMaginatude)
      .data
    frequencyChart2.update(data)
  }

  app.ticker.add(() => {
    if (ap.audio && !ap.audio.paused) {
      update1()
      update2()
      update3()
    }
  })
})

onUnmounted(() => {
  ap.destroy()
  app.destroy(true, { children: true, texture: true })
})
</script>

<template>
  <div class="w-full h-100vh">
    <input ref="inputFile" type="file" class="hidden" accept="audio/*" @change="handelMusicChange">
    <div ref="pixiCon" class="w-full h-650px" />
  </div>
</template>

<style></style>
