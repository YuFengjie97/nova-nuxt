<script lang="ts" setup>
import { gsap } from 'gsap'
import { MotionPathPlugin } from 'gsap/MotionPathPlugin'
import { Application, FillGradient, Graphics, Rectangle } from 'pixi.js'
import { createNoise2D } from 'simplex-noise'
import Stats from 'stats.js'

gsap.registerPlugin(MotionPathPlugin)
const noise2D = createNoise2D()
const app = new Application()
const pixiCon = ref<HTMLElement>()
const bubbleGroups: BubbleGroup[] = []

class HSLA {
  constructor(public h: number, public s: number, public l: number, public a: number = 1) {
  }

  toString() {
    const { h, s, l, a } = this
    return `hsla(${h},${s * 100}%,${l * 100}%,${a})`
  }
}

class Bubble {
  pos: Vector2
  basePointsNum = 8
  segementsNum = 8
  basePoints: Vector2[] = []
  points: Vector2[] = []

  radius: number = 0.1
  radiusMax: number = 0

  app: Application
  graph: Graphics
  noiseBase = Math.random() * 100
  noiseOffset = Math.random() * 100
  noiseInc: number = 0.02
  color: HSLA = new HSLA(210, 1, 0.84, 1)
  isDestroyed = false

  life: number = 1
  lifeDecay: number = 0.01

  onDestroy: () => void = () => { }

  constructor(app: Application, graph: Graphics, pos: Vector2) {
    this.app = app

    this.pos = pos
    this.initPoint()
    const isSmall = Math.random() < 0.8
    if (isSmall) {
      this.radiusMax = randomRange(4, 8)
    }
    else {
      this.radiusMax = randomRange(11, 20)
    }

    this.life = 100 / this.radiusMax

    this.graph = graph
  }

  initPoint() {
    for (let i = 0; i < this.basePointsNum; i++) {
      this.basePoints.push(this.pos.clone())
    }
  }

  noise() {
    const { basePointsNum, radius, pos, basePoints, noiseOffset } = this
    const a = Math.PI * 2 / basePointsNum

    for (let i = 0; i < basePoints.length; i++) {
      const angle = i * a
      const dist = noise2D(noiseOffset + i * 10, noiseOffset) * (radius / 4) + radius

      const x = Math.cos(angle) * dist
      const y = Math.sin(angle) * dist
      const { x: cx, y: cy } = pos
      basePoints[i].set(x + cx, y + cy)
    }
  }

  catmullRom() {
    const { basePoints, segementsNum } = this

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
      const p = catmullRomPoint(p0, p1, p2, p3, segementsNum)
      res.push(...p)
    }
    this.points = res
  }

  update() {
    if (this.isDestroyed) {
      return
    }
    this.noiseOffset += this.noiseInc
    this.life -= this.lifeDecay

    this.noise()
    this.catmullRom()
    this.updatePos()
    this.edge()

    if (this.radius < this.radiusMax) {
      this.radius += this.radiusMax / 20 // 气泡越大,膨胀速度越大
    }

    if (this.life <= 0) {
      let a = this.color.a
      a -= 0.03
      this.color.a = a <= 0 ? 0.01 : a
    }
    if (this.color.a <= 0.01) {
      this.destroy()
    }
  }

  updatePos() {
    const { noiseOffset, noiseBase, radius } = this
    const angle = Math.PI / 6 * noise2D(noiseBase, noiseOffset) - Math.PI / 2
    const vel = Vector2.fromAngle(angle).multiply(radius / 10 * 2) // 气泡越大,上升速度越快
    this.pos.add(vel)
  }

  edge() {
    if (this.isDestroyed) {
      return
    }
    const { width } = this.app.screen
    const gap = this.radius
    const { x, y } = this.pos
    if (x < -gap || x > width + gap || y < -gap) {
      this.destroy()
    }
  }

  draw() {
    if (this.isDestroyed) {
      return
    }
    const { graph, points, color } = this
    const fir = points[0]
    graph.moveTo(fir.x, fir.y)
    for (let i = 1; i < points.length; i++) {
      const p = points[i]
      graph.lineTo(p.x, p.y)
    }
    graph.lineTo(fir.x, fir.y)
    graph.stroke({ color: color.toString(), width: 2 })
  }

  destroy() {
    this.isDestroyed = true
    this.onDestroy()
  }
}

class BubbleGroup {
  pos: Vector2
  bubbles: Bubble[] = []
  bubbleDesotryNum = 0
  constructor(app: Application, graph: Graphics, pos: Vector2) {
    this.pos = pos
    const bubbleNum = Math.floor(randomRange(2, 4))
    for (let i = 0; i < bubbleNum; i++) {
      const bubble = new Bubble(app, graph, pos.clone())
      bubble.onDestroy = this.onBubbleDestroy
      this.bubbles.push(bubble)
    }
  }

  onBubbleDestroy = () => {
    this.bubbleDesotryNum += 1
    if (this.bubbleDesotryNum === this.bubbles.length) {
      this.destroy()
    }
  }

  update() {
    this.bubbles.forEach((b) => {
      b.update()
    })
  }

  draw() {
    this.bubbles.forEach((bubble) => {
      bubble.draw()
    })
  }

  destroy() {
    const index = bubbleGroups.indexOf(this)
    bubbleGroups.splice(index, 1)
  }
}

let lastCreate = 0
const createWait = 80

function createBubbleGroup(app: Application, graph: Graphics, pos: Vector2) {
  const now = performance.now()
  if (now - lastCreate > createWait) {
    const bubbles = new BubbleGroup(app, graph, pos.clone())
    bubbleGroups.push(bubbles)
    lastCreate = now
  }
}

onMounted(async () => {
  await app.init({ background: '#74b9ff', resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)

  const { width, height } = app.screen

  const linearBg = new FillGradient({
    type: 'linear',
    start: { x: 0, y: 0 },
    end: { x: 0, y: height },
    colorStops: [
      { offset: 0, color: '#0984e3' },
      { offset: 1, color: '#000' },
    ],
    textureSpace: 'global',
  })
  const bg = new Graphics()
  app.stage.addChild(bg)
  bg.rect(0, 0, width, height)
    .fill(linearBg)

  const stats = new Stats()
  pixiCon.value?.appendChild(stats.dom)

  app.stage.hitArea = new Rectangle(0, 0, width, height)

  const graph = new Graphics()
  app.stage.addChild(graph)

  app.stage.eventMode = 'static'
  let pointerDownPos: null | Vector2 = new Vector2(width / 2, height * 0.8)
  app.stage.on('pointerdown', (event) => {
    const { x, y } = event.getLocalPosition(app.stage)
    pointerDownPos = new Vector2(x, y)
  })
  app.stage.on('pointerup', () => {
    pointerDownPos = null
  })
  app.stage.on('pointermove', (event) => {
    const { x, y } = event.getLocalPosition(app.stage)
    pointerDownPos?.set(x, y)
  })

  app.ticker.add(() => {
    stats.update()

    graph.clear()

    if (pointerDownPos) {
      createBubbleGroup(app, graph, pointerDownPos)
    }

    bubbleGroups.forEach((bg) => {
      bg.update()
      bg.draw()
    })
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
d{
  color: hsl(210, 100%, 84%);
}
</style>
