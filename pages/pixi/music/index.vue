<script lang="ts" setup>
import { Application } from 'pixi.js'
import { Pane } from 'tweakpane'
import { ProgressBar } from './ui'
import music from '/sound/savageLove.aac'

// class ProgressBar {
//   app: Application
//   size: { w: number, h: number }
//   group = new Container()
//   progressBottom = new Graphics()
//   progress = new Graphics()
//   constructor(app: Application, size: { w: number, h: number }) {
//     this.app = app
//     this.size = size
//     const { w, h } = size

//     app.stage.addChild(this.group)

//     this.progressBottom.rect(0, 0, w, h)
//       .fill({ color: '#00b894' })

//     this.progressBottom.eventMode = 'static'
//     this.progressBottom.cursor = 'pointer'

//     this.group.addChild(this.progressBottom)
//     this.group.addChild(this.progress)
//   }

//   draw(val: number) {
//     this.progress.clear()
//     this.progress
//       .rect(0, 0, this.size.w * val, this.size.h)
//       .fill({ color: '#81ecec' })
//   }

//   onClick(cb: (percentile: number) => void) {
//     this.progressBottom.on('pointerdown', (event) => {
//       const { x } = event.getLocalPosition(this.group)
//       const percentile = x / this.size.w
//       cb(percentile)
//       this.draw(percentile)
//     })

//     return this
//   }

//   update(val: number) {
//     this.draw(val)
//   }
// }

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

  ap = new AudioParse(fftSize, music)

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

  const progress = new ProgressBar(app, { w: 800, h: 20 }).onClick((percentile: number) => {
    ap.currentTimePercentile = percentile
  })

  app.ticker.add(() => {
    if (ap.audio && !ap.audio.paused) {
      progress.update(ap.currentTimePercentile)
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
