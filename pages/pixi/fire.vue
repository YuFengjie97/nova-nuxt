<script lang="ts" setup>
import { AdvancedBloomFilter } from 'pixi-filters'
import { Application, Assets, Container, DisplacementFilter, Graphics, Rectangle, Sprite } from 'pixi.js'
import { createNoise2D } from 'simplex-noise'

const pixCon = ref<HTMLElement>()

const app = new Application()
const noise = createNoise2D()

/**
 *
 * trackHalfWidth = a火焰宽度,一半
 * trackBottomHeight = b火焰底部高度
 * trackHeight = m火焰高度
 * 右侧一半
 * y属于(0,b), y = b/a * x
 * y属于(b,m), y = (b-m)/a * x + m
 */

class Flame {
  graph = new Graphics()

  pos: Vector2
  size: number
  sizeMax = 30
  ySpeed = Math.random() * 10 + 2
  seed: number = Math.random() * 100
  isShrink = true

  trackHalfWidth: number
  trackHeight: number
  trackBottomHeight: number
  constructor(op: { trackHalfWidth: number, trackHeight: number, trackBottomHeight: number }) {
    this.trackHalfWidth = op.trackHalfWidth
    this.trackHeight = op.trackHeight
    this.trackBottomHeight = op.trackBottomHeight
    this.pos = new Vector2(0, 0)
    this.size = Math.random() * this.sizeMax
  }

  update(delta: number, last: number) {
    const { trackHalfWidth, trackHeight, trackBottomHeight } = this

    this.pos.y += delta * this.ySpeed
    const { y } = this.pos
    let x
    if (y < trackBottomHeight) {
      x = y / trackBottomHeight * trackHalfWidth
      this.isShrink = false
    }
    else {
      x = (y - trackHeight) / (trackBottomHeight - trackHeight) * trackHalfWidth
      this.isShrink = true
    }
    if (y > trackHeight) {
      this.pos.y = 0
    }

    this.pos.x = x
    this.pos.x += noise(this.pos.y, last)

    if (this.isShrink) {
      this.size -= delta * 0.4
      this.size = Math.max(0.1, this.size)
    }
    else {
      this.size += delta * 4
      this.size = Math.min(this.sizeMax, this.size)
    }
  }

  draw() {
    const { x, y } = this.pos

    this.graph.clear()
      .circle(x, y, this.size)
      .fill({ color: 'orange' })
  }
}

const trackHalfWidth = 200
const trackHeight = 600
const trackBottomHeight = 150

class Fire {
  app: Application
  group = new Container()
  displacementFilter: DisplacementFilter
  glowFilter: AdvancedBloomFilter
  flames: Flame[] = []
  constructor(app: Application, sprite: Sprite) {
    this.app = app
    app.stage.addChild(this.group)

    this.displacementFilter = new DisplacementFilter(sprite, 10)
    this.displacementFilter.scale.set(100)
    this.glowFilter = new AdvancedBloomFilter({ bloomScale: 0.5, threshold: 0.2 })
    this.group.filters = [this.displacementFilter, this.glowFilter]
    const w = trackHalfWidth + 80
    const h = trackHeight + 80
    this.group.filterArea = new Rectangle(-w, -40, w * 2, h)
    this.group.scale.y = -1

    const num = 100
    for (let i = 0; i < num; i++) {
      const flame = new Flame({
        trackHalfWidth: Math.random() * trackHalfWidth * 2 - trackHalfWidth,
        trackHeight: (Math.random() * 0.5 + 0.5) * trackHeight,
        trackBottomHeight: (Math.random() * 0.5 + 0.5) * trackBottomHeight,
      })
      this.flames.push(flame)
      this.group.addChild(flame.graph)
    }
  }

  update(delta: number, last: number) {
    this.flames.forEach((flame) => {
      flame.update(delta, last)
    })
  }

  draw() {
    this.flames.forEach((flame) => {
      flame.draw()
    })
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
    return this
  }
}

onMounted(async () => {
  await app.init({ background: '#111', antialias: true, resizeTo: pixCon.value })
  pixCon.value?.appendChild(app.canvas)

  const texture = await Assets.load(runtimePath('/img/fire-texture.jpg'))
  // const texture = await Assets.load(runtimePath('/img/displacement_map.png'))
  const sprite = new Sprite(texture)
  sprite.texture.source.wrapMode = 'mirror-repeat'

  const { width, height } = app.canvas
  const fire = new Fire(app, sprite).setPos(width / 2, height - 100)

  app.ticker.add((time) => {
    const { deltaTime, lastTime } = time

    fire.update(deltaTime, lastTime / 1000)
    fire.draw()
  })
})

onUnmounted(() => {
  app.destroy()
})
</script>

<template>
  <div ref="pixCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped></style>
