<script lang="ts" setup>
import chroma from 'chroma-js'
import { createNoise2D } from 'simplex-noise'
import Stats from 'stats.js'

const noise2D = createNoise2D()
const pixiCon = ref<HTMLElement>()
const canvas = ref<HTMLCanvasElement>()

class Wave {
  pos: Vector2
  basePointsNum = 8
  basePoints: Vector2[] = []
  points: Vector2[] = []
  baseRadius: number = 100
  gainRadius: number = 50
  noiseOffset: number = 0
  noiseInc: number = 0.02
  color: string = 'red'
  ctx: CanvasRenderingContext2D
  constructor(ctx: CanvasRenderingContext2D, pos: Vector2) {
    this.pos = pos
    this.initPoint()
    this.ctx = ctx
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
      const dist = (noise2D(noiseOffset + i / basePoints.length, noiseOffset) * 0.5 + 0.5) * gainRadius + baseRadius

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
    const { points, color, ctx } = this
    const fir = points[0]
    ctx.strokeStyle = color
    ctx.lineWidth = 10
    ctx.beginPath()
    ctx.moveTo(fir.x, fir.y)
    for (let i = 1; i < points.length; i++) {
      const p = points[i]
      ctx.lineTo(p.x, p.y)
    }
    ctx.closePath()
    ctx.stroke()
  }
}

onMounted(async () => {
  const ctx = canvas.value?.getContext('2d') as CanvasRenderingContext2D

  const stats = new Stats()
  pixiCon.value?.appendChild(stats.dom)

  const { width, height } = canvas.value!.getBoundingClientRect()
  canvas.value!.width = width
  canvas.value!.height = height

  const center = new Vector2(width / 2, height / 2)

  const waves: Wave[] = []

  const colors = chroma.scale(['#d63031', '#ffeaa7', '#0984e3'])
    .mode('lch')
    .colors(6)

  for (let i = 0; i < colors.length; i++) {
    const color = colors[i]
    const offset = i
    const wave = new Wave(ctx, center).setNoiseOffset(offset).setColor(color)
    waves.push(wave)
  }

  function loop() {
    stats.update()

    ctx.fillStyle = `rgba(0,0,0,0.3)`
    ctx.fillRect(0, 0, width, height)

    for (const wave of waves) {
      wave.update()
      wave.draw()
    }
    requestAnimationFrame(loop)
  }
  loop()
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh">
    <canvas ref="canvas" class="w-full h-full" />
  </div>
</template>

<style lang='less' scoped></style>
