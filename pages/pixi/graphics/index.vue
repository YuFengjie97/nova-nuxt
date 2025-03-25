<script lang="ts" setup>
import type { Coord } from './line'
import chroma from 'chroma-js'
import { AdvancedBloomFilter } from 'pixi-filters'
import { Application } from 'pixi.js'
import { Pane } from 'tweakpane'
import { Vector2 } from '~/utils/vector'
import { BezierLine } from './line'
import { Point } from './point'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const points: Point[] = []

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
const glowFilter = new AdvancedBloomFilter(glowSettings)

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

let pane: Pane
onMounted(async () => {
  await app.init({ background: '#121212', antialias: true, resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)

  pane = new Pane()
  glowPane(pane)
  app.stage.filters = [glowFilter]

  const { width, height } = app.canvas

  for (let i = 0; i < 20; i++) {
    const x = Math.random() * width
    const y = Math.random() * height
    const point = new Point(app, colors[i % 6], 4 + Math.random() * 10).setStartPos(x, y).setVelBase(new Vector2(4, 0))
    points.push(point)
  }

  setInterval(() => {
    points.forEach((point) => {
      const flag = Math.random() < 0.5
      if (flag) {
        point.updateAcc(new Vector2(4, 0))
      }
    })
  }, 1000)

  const bezierLine = new BezierLine(app).setPos(0, height / 2)

  function getBezierLineCoords() {
    const { width } = app.canvas
    const coordsNum = 10
    const gap = Math.floor(width / coordsNum)
    const coords: Coord[] = Array.from({ length: coordsNum }).fill(0).map((item, i) => ({ x: i * gap, y: 0 }))
    const yRange = [-40, 40]

    let t = 0
    function getCoords() {
      t += 0.1
      coords.forEach((item, i) => {
        const m = Math.sin(t + i * 10) * 0.5 + 0.5
        const y = map(m, 0, 1, yRange[0], yRange[1])
        item.y = y
      })

      return coords
    }

    return getCoords
  }

  const getCoords = getBezierLineCoords()

  app.ticker.add(() => {
    points.forEach((p) => {
      p.update()
    })
    bezierLine.update(getCoords())
  })
})

onUnmounted(() => {
  app.destroy()
  pane.dispose()
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style lang='less' scoped>
.tttt {
  color: #121212;
}
</style>
