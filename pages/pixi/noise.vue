<script lang="ts" setup>
import { Application, Graphics, RenderTexture, Sprite } from 'pixi.js'
import { createNoise3D } from 'simplex-noise'
import Stats from 'stats.js'
import { Pane } from 'tweakpane'

const pixiCon = ref<HTMLElement>()
const noise3D = createNoise3D()
const { PI, random } = Math

let app: Application
let renderTexture: RenderTexture

let stats: Stats
let pane: Pane

const particles: Particle[] = []
const background = 'rgb(251, 248, 235)'

const particleOptions = {
  useFbm: true,
  noiseBaseScale: 600,
  gain: 13,

  count: 1000,
  hueBase: 20,
  lineWidth: 1,
}

interface HSLA {
  h: number
  s: number
  l: number
  a: number
}

let offset = 0

function fbm3D(x: number, y: number, z: number) {
  const octaves = 4
  const fallout = 0.5
  let amp = 1
  let f = 1
  let sum = 0
  let i

  for (i = 0; i < octaves; ++i) {
    amp *= fallout
    sum += amp * (noise3D(x * f, y * f, z * f) + 1) * 0.5
    f *= 2
  }

  return sum
}

class Particle {
  app: Application
  pos: Vector2 = new Vector2(0, 0)
  lastPos = this.pos.clone()
  hsla: HSLA = { h: 360, s: 0.1, l: 0.5, a: 0.1 }
  firstDraw = true

  constructor(app: Application) {
    this.app = app

    this.resetPos()

    this.hsla.s = 1
    this.hsla.l = 0.5
    this.hsla.a = 0
  }

  resetPos() {
    const { width, height } = this.app.canvas
    this.pos = new Vector2(random() * width, random() * height)
    this.lastPos = this.pos.clone()

    const { x, y } = this.pos
    const angle = Math.atan2(y, x)
    const h = angle / PI * 2 * 360 + particleOptions.hueBase
    this.hsla.h = h
    this.hsla.a = 0
  }

  update() {
    const { pos: { x, y } } = this
    const { gain, noiseBaseScale, useFbm } = particleOptions
    const nx = x / noiseBaseScale
    const ny = y / noiseBaseScale

    this.lastPos = this.pos.clone()

    const n = useFbm ? fbm3D(offset, nx, ny) : noise3D(offset, nx, ny)

    const angle = n * Math.PI * 6
    this.hsla.h += 0.1

    if (this.hsla.a < 1) {
      this.hsla.a += 0.003
    }

    const dir = Vector2.fromAngle(angle)
    const force = dir.multiply(gain)
    this.pos.add(force)
    if (this.edge()) {
      this.resetPos()
    }
  }

  edge() {
    const { x, y } = this.pos
    const { width, height } = this.app.screen
    const gap = 0
    if (x < -gap) {
      this.pos.x = width + gap
      return true
    }
    if (x > width + gap) {
      this.pos.x = -gap
      return true
    }
    if (y < -gap) {
      this.pos.y = height + gap
      return true
    }
    if (y > height + gap) {
      this.pos.y = -gap
      return true
    }
    return false
  }

  getColor() {
    const { hsla: { h, s, l, a } } = this
    return `hsla(${h},${s * 100}%,${l * 100}%,${a})`
  }

  draw(graph: Graphics) {
    const color = this.getColor()
    const { pos, lastPos } = this
    const { lineWidth } = particleOptions

    graph.moveTo(lastPos.x, lastPos.y)
      .lineTo(pos.x, pos.y)
      .stroke({ color, width: lineWidth, join: 'round', cap: 'round' })
  }
}

function clearCanvas(app: Application, renderTexture: RenderTexture) {
  const renderer = app.renderer
  const { width, height } = app.screen

  const clearGraph = new Graphics()
  clearGraph.clear()
    .rect(0, 0, width, height)
    .fill({ color: background })

  renderer.render({
    container: clearGraph,
    target: renderTexture,
    clear: true,
  })
}

function initPane(pane: Pane) {
  const folder = pane.addFolder({ title: 'noise' })
  folder.addButton({ title: 'redraw' }).on('click', () => {
    clearCanvas(app, renderTexture)
  })

  folder.addBinding(particleOptions, 'noiseBaseScale', { min: 1, max: 4000, step: 1 })
  folder.addBinding(particleOptions, 'useFbm')
  folder.addBinding(particleOptions, 'count', { min: 1, max: 1000, step: 1 })
  folder.addBinding(particleOptions, 'hueBase', { min: 1, max: 360, step: 1 })
  folder.addBinding(particleOptions, 'lineWidth', { min: 0.3, max: 10, step: 0.1 })
  folder.addBinding(particleOptions, 'gain', { min: 0.1, max: 20, step: 0.1 })
}

onMounted(async () => {
  app = new Application()
  await app.init({ resizeTo: pixiCon.value, antialias: true, background })
  pixiCon.value?.appendChild(app.canvas)
  const { width, height } = app.screen

  stats = new Stats()
  pixiCon.value?.appendChild(stats.dom)

  pane = new Pane()
  initPane(pane)

  for (let i = 0; i < particleOptions.count; i++) {
    particles.push(new Particle(app))
  }

  const praticleGraph = new Graphics()
  renderTexture = RenderTexture.create({ width, height })
  const renderSprite = new Sprite(renderTexture)
  app.stage.addChild(renderSprite)
  app.stage.addChild(praticleGraph)

  app.ticker.add(() => {
    stats.update()
    offset += 0.001

    const need = particleOptions.count - particles.length
    if (need > 0) {
      for (let i = 0; i < need; i++) {
        particles.push(new Particle(app))
      }
    }
    if (need < 0) {
      for (let i = 0; i < Math.abs(need); i++) {
        particles.pop()
      }
    }

    praticleGraph.clear()
    for (const particle of particles) {
      particle.update()
      particle.draw(praticleGraph)
    }

    app.renderer.render({ container: praticleGraph, target: renderTexture, clear: false })
  })
})
onUnmounted(() => {
  app.destroy(true, { children: true })
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped>
a {
  color: rgb(251, 248, 235)
}
</style>
