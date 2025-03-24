<script lang="ts" setup>
import chroma from 'chroma-js'
import { AdvancedBloomFilter } from 'pixi-filters'
import { Application, Graphics } from 'pixi.js'
import { Pane } from 'tweakpane'
import { Vector2 } from '~/utils/vector'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const points: Point[] = []

const colors = chroma.scale(['#ff6b6b', '#feca57']).mode('hsl').colors(6)

class Point {
  app: Application
  color: string
  radius: number
  graphics = new Graphics()
  pos: Vector2 = new Vector2(0, 0)
  acc: Vector2 = new Vector2(0, 0)
  vel: Vector2 = new Vector2(0, 0)
  velBase = new Vector2(0, 0)
  negAccLen = 0.1

  constructor(app: Application, color: string, radius: number) {
    this.app = app
    this.color = color
    this.radius = radius
    this.app.stage.addChild(this.graphics)
  }

  setStartPos(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      this.pos.set(...args as [number, number])
    }
    else {
      this.pos.set(...args as [Vector2])
    }
    return this
  }

  setVelBase(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      this.velBase.set(...args as [number, number])
    }
    else {
      this.velBase.set(...args as [Vector2])
    }
    return this
  }

  updateAcc(vec2: Vector2) {
    this.acc.set(vec2)
    return this
  }

  update() {
    const negAcc = this.vel.clone().normalize().multiply(-this.negAccLen)
    this.vel.set(this.velBase)

    if (this.acc.length > this.negAccLen && this.acc.length > 0.1) {
      this.vel.add(this.acc.add(negAcc))
    }

    this.pos.add(this.vel)

    this.edge()
    this.draw()
  }

  draw() {
    const { x, y } = this.pos
    this.graphics.clear()
      .circle(x, y, this.radius)
      .fill(this.color)
  }

  edge() {
    const { width, height } = this.app.canvas
    const { x, y } = this.pos
    const gap = 20
    if (x <= -gap) {
      this.pos.x = width + gap
    }
    if (x >= width + gap) {
      this.pos.x = -gap
    }
    if (y <= -gap) {
      this.pos.y = height + gap
    }
    if (y >= height + gap) {
      this.pos.y = -gap
    }
  }
}

const glowSettings = {
  bloomScale: 1.4,
  brightness: 1.2,
  threshold: 0.5,
  blur: 3,
  quality: 9,
  pixelSize: { x: 1, y: 1 },
}

onMounted(async () => {
  await app.init({ background: '#121212', antialias: true, resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)

  const { width, height } = app.canvas

  const glowFilter = new AdvancedBloomFilter(glowSettings)
  app.stage.filters = [glowFilter]

  const pane = new Pane()
  const f1 = pane.addFolder({ title: 'glow' })
  f1.addBinding(glowSettings, 'bloomScale', { min: 0, max: 2, step: 0.1 }).on('change', (e) => {
    glowFilter.bloomScale = e.value
  })
  f1.addBinding(glowSettings, 'brightness', { min: 0, max: 2, step: 0.1 }).on('change', (e) => {
    glowFilter.brightness = e.value
  })
  f1.addBinding(glowSettings, 'threshold', { min: 0, max: 1, step: 0.1 }).on('change', (e) => {
    glowFilter.threshold = e.value
  })
  f1.addBinding(glowSettings, 'blur', { min: 0, max: 10, step: 0.1 }).on('change', (e) => {
    glowFilter.blur = e.value
  })
  f1.addBinding(glowSettings, 'quality', { min: 0, max: 10, step: 1 }).on('change', (e) => {
    glowFilter.quality = e.value
  })
  f1.addBinding(glowSettings, 'pixelSize', { min: -10, max: 10, step: 1 }).on('change', (e) => {
    glowFilter.pixelSize = e.value
  })

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

  app.ticker.add(() => {
    points.forEach((p) => {
      p.update()
    })
  })
})

onUnmounted(() => {
  app.destroy()
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style lang='less' scoped>
.tttt{
  color: #121212;
}
</style>
