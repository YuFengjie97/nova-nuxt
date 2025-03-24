<script lang="ts" setup>
import { Application } from 'pixi.js'
import { Pane } from 'tweakpane'
import { BarChart, LineChart, ProgressBar } from './ui'
import music from '/sound/savageLove.aac'

const inputFile = ref<HTMLInputElement>()
const pixiCon = ref<HTMLElement>()
const app = new Application()
const fftSize = 1024
// const targetSize = 100
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
  const sampleRate = audioBuffer.sampleRate
  console.log('audioBuffer', audioBuffer, 'sampleRage', sampleRate)

  const mixedTimeDomainData = mixedTimeDomain(audioBuffer)
  console.log('mixedTimeDomainData', mixedTimeDomainData)

  const frequencyFrames = getFrequencyFrames(mixedTimeDomainData, fftSize)
  console.log('frequencyFrames', frequencyFrames)

  const maxMaginatude = getMaxBassAndWideMagnitude(frequencyFrames, sampleRate, fftSize)
  bassMaxMaginatude = maxMaginatude.bassMaxMaginatude
  wideMaxMaginatude = maxMaginatude.wideMaxMaginatude
  console.log({ bassMaxMaginatude, wideMaxMaginatude })

  const url = URL.createObjectURL(file)
  ap.setUrl(url)
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

  const frequencyChart = new BarChart(app, { w: 800, h: 200 }).setPos(0, 250)
  const timeDomainChart = new LineChart(app, { w: 800, h: 200 }).setPos(0, 450)
  const progress = new ProgressBar(app, { w: 800, h: 20 }).onClick((percentile: number) => {
    ap.setCurrentTimeByPercentile(percentile)
  })

  function update1() {
    const data = new DataProcessor(Array.from(ap.getByteFrequencyData()))
      .smooth(20)
      .normalize(255)
      .data
    frequencyChart.update(data)
  }
  function update2() {
    const data = new DataProcessor(Array.from(ap.getByteTimeDomainData()))
      .smooth()
      .normalize()
      .data
    timeDomainChart.update(data)
  }

  app.ticker.add(() => {
    if (ap.audio && !ap.audio.paused) {
      update1()
      update2()

      progress.update(ap.progress)
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
