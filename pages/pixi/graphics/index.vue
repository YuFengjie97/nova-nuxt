<script lang="ts" setup>
import chroma from 'chroma-js'
import { AdvancedBloomFilter } from 'pixi-filters'
import { Application, Container } from 'pixi.js'
import { Pane } from 'tweakpane'
import { Point } from '~/utils/pixi/point'
import { ProgressBar } from '~/utils/pixi/ui'
import { Vector2 } from '~/utils/vector'
import music from '/sound/savageLove.aac'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const inputAudio = ref<HTMLInputElement>()
let pane: Pane
const colors = chroma.scale(['#ff6b6b', '#feca57']).mode('hsl').colors(6)
const glowSettings = {
  show: true,
  bloomScale: 1.4,
  brightness: 1.2,
  threshold: 0.4,
  blur: 3,
  quality: 9,
  pixelSize: { x: 1, y: 1 },
}
const { show, ...filterSettins } = glowSettings
const glowFilter = new AdvancedBloomFilter(filterSettins)
const fftSize = 1024
let audioParse: AudioParse
const pointNum = 20

function glowPane(pane: Pane) {
  const folder = pane.addFolder({ title: 'glow' })
  folder.addBinding(glowSettings, 'show').on('change', (e) => {
    if (e.value) {
      app.stage.filters = [glowFilter]
    }
    else {
      app.stage.filters = []
    }
  })
  folder.addBinding(glowSettings, 'bloomScale', { min: 0, max: 2, step: 0.1 }).on('change', (e) => {
    glowFilter.bloomScale = e.value
  })
  folder.addBinding(glowSettings, 'brightness', { min: 0, max: 2, step: 0.1 }).on('change', (e) => {
    glowFilter.brightness = e.value
  })
  folder.addBinding(glowSettings, 'threshold', { min: 0, max: 1, step: 0.1 }).on('change', (e) => {
    glowFilter.threshold = e.value
  })
  folder.addBinding(glowSettings, 'blur', { min: 0, max: 10, step: 0.1 }).on('change', (e) => {
    glowFilter.blur = e.value
  })
  folder.addBinding(glowSettings, 'quality', { min: 0, max: 10, step: 1 }).on('change', (e) => {
    glowFilter.quality = e.value
  })
  folder.addBinding(glowSettings, 'pixelSize', { min: -10, max: 10, step: 1 }).on('change', (e) => {
    glowFilter.pixelSize = e.value
  })
}

function musicPane(pane: Pane) {
  const floder = pane.addFolder({ title: 'music' })
  floder.addButton({ title: 'upload' }).on('click', () => {
    inputAudio.value?.click()
  })
  floder.addButton({ title: 'play' }).on('click', () => {
    audioParse.play()
  })
  floder.addButton({ title: 'pause' }).on('click', () => {
    audioParse.pause()
  })
}

function handleMusicUpload(e: Event) {
  const target = e.target as HTMLInputElement
  if (!target.files) {
    return
  }
  const file = target.files[0]
  const url = getFileUrl(file)

  audioParse.setUrl(url)
}

function initPoints(num: number) {
  const { width, height } = app.canvas
  const points: Point[] = []
  const group = new Container()
  for (let i = 0; i < num; i++) {
    const x = Math.random() * width
    const y = Math.random() * height
    const point = new Point(colors[i % 6], 4 + Math.random() * 10)
      .setEdge(width, height)
      .setStartPos(x, y)
      .setVelBase(new Vector2(1, 0))
    group.addChild(point.graphics)
    points.push(point)
  }

  group.filters = [glowFilter]

  return {
    group,
    points,
  }
}

let interval: NodeJS.Timeout

onMounted(async () => {
  await app.init({ background: '#121212', antialias: true, resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)
  const progress = new ProgressBar(app, { w: 700, h: 20 }).onClick((percentile: number) => {
    audioParse.currentTimePercentile = percentile
  })

  audioParse = new AudioParse(fftSize, music)

  pane = new Pane()
  glowPane(pane)
  musicPane(pane)
  const { points, group } = initPoints(pointNum)
  app.stage.addChild(group)

  function getBeat() {
    const bassFrequency = audioParse.getBass()
    const data = new DataProcessor(bassFrequency).avgBucket(1).normalize(255).data[0]
    return data
  }
  interval = setInterval(() => {
    let beat: number
    if (!audioParse.paused) {
      beat = getBeat()
    }
    points.forEach((p) => {
      if (!audioParse.paused && beat > 0.7) {
        p.updateAcc(new Vector2(10, 0).multiply(beat))
      }
    })
  }, 1500)

  app.ticker.add(() => {
    points.forEach((p) => {
      p.update()
    })

    progress.update(audioParse.currentTimePercentile)
  })
})

onUnmounted(() => {
  app.destroy()
  pane.dispose()
  audioParse.destroy()
  clearInterval(interval)
})
</script>

<template>
  <div class="w-full h-100vh">
    <input ref="inputAudio" type="file" accept="audio/*" class="hidden" @change="handleMusicUpload">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style lang='less' scoped>
.tttt {
  color: #121212;
}
</style>
