<script lang="ts" setup>
import chroma from 'chroma-js'
import { Application, Graphics } from 'pixi.js'
import { createNoise2D } from 'simplex-noise'
import Stats from 'stats.js'

const noise2D = createNoise2D()
const app = new Application()
const pixiCon = ref<HTMLElement>()

class Wave {
  pos: Vector2
  basePointsNum = 8
  basePoints: Vector2[] = []
  points: Vector2[] = []
  baseRadius: number = 100
  gainRadius: number = 50
  graph = new Graphics()
  noiseOffset: number = 0
  noiseInc: number = 0.02
  color: string = 'red'
  constructor(app: Application, graph: Graphics, pos: Vector2) {
    this.pos = pos
    this.initPoint()

    this.graph = graph
    app.stage.addChild(this.graph)
  }

  setNoiseOffset(val: number) {
    this.noiseOffset = val
    return this
  }

  setColor(color: string) {
    this.color = color
    return this
  }

  initPoint() {
    for (let i = 0; i < this.basePointsNum; i++) {
      this.basePoints.push(this.pos.clone())
    }
  }

  noise() {
    const { basePointsNum, baseRadius, gainRadius, pos, basePoints, noiseOffset } = this
    const a = Math.PI * 2 / basePointsNum

    for (let i = 0; i < basePoints.length; i++) {
      const angle = i * a
      const dist = (noise2D(noiseOffset + i * 10, noiseOffset) * 0.5 + 0.5) * gainRadius + baseRadius

      const x = Math.cos(angle) * dist
      const y = Math.sin(angle) * dist
      const { x: cx, y: cy } = pos
      basePoints[i].set(x + cx, y + cy)
    }
  }

  catmullRom() {
    const { basePoints } = this

    const tail = basePoints[basePoints.length - 1]
    const head = basePoints[0]
    const sec = basePoints[1]

    const points = [tail, ...basePoints, head, sec]
    const res: Vector2[] = []
    for (let i = 0; i < points.length - 3; i++) {
      const p0 = points[i]
      const p1 = points[i + 1]
      const p2 = points[i + 2]
      const p3 = points[i + 3]
      const p = catmullRomPoint(p0, p1, p2, p3, 8)
      res.push(...p)
    }
    this.points = res
  }

  updatePos(pos: Vector2) {
    this.pos = pos
  }

  update() {
    this.noiseOffset += this.noiseInc
    this.noise()
    this.catmullRom()
  }

  draw() {
    const { graph, points, color } = this
    const fir = points[0]
    graph.moveTo(fir.x, fir.y)
    for (let i = 1; i < points.length; i++) {
      const p = points[i]
      graph.lineTo(p.x, p.y)
    }
    graph.lineTo(fir.x, fir.y)
    graph.closePath()
    graph.stroke({ color, width: 10 })
  }
}

onMounted(async () => {
  await app.init({ antialias: true, background: '#111', resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)

  const graph = new Graphics()
  graph.blendMode = 'add'
  app.stage.addChild(graph)

  const stats = new Stats()
  pixiCon.value?.appendChild(stats.dom)

  const { width, height } = app.screen
  const center = new Vector2(width / 2, height / 2)

  const waves: Wave[] = []

  const colors = chroma.scale(['#d63031', '#ffeaa7', '#0984e3'])
    .mode('lch')
    .colors(1)

  for (let i = 0; i < colors.length; i++) {
    const color = colors[i]
    const offset = i
    const wave = new Wave(app, graph, center).setNoiseOffset(offset).setColor(color)
    waves.push(wave)
  }

  app.ticker.add(() => {
    stats.update()

    graph.clear()

    for (const wave of waves) {
      wave.update()
      wave.draw()
    }
  })
})

onUnmounted(() => {
  app.destroy(true, { children: true })
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped></style>
