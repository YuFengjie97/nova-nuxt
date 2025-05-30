<script lang="ts" setup>
import type { Texture } from 'three'
import chroma from 'chroma-js'
import { AdvancedBloomFilter } from 'pixi-filters'
import { Application, Assets, Container, DisplacementFilter, Graphics, Sprite } from 'pixi.js'
import Stats from 'stats.js'

type FirePixels = Map<ReturnType<Vector2['toString']>, FirePixel>

const { ceil, round, random, min, max } = Math
const pixCon = ref<HTMLElement>()
const app = new Application()
const firePixelSize = 10
const fireScaleColors = chroma.scale(['#130f40', '#d63031', '#f9ca24', '#fff'])
  .mode('lch')
  .colors(36)

function showFireScaleColor(app: Application) {
  const group = new Container()
  const graph = new Graphics()
  app.stage.addChild(group)
  group.addChild(graph)
  group.zIndex = 100
  const size = 20

  function draw() {
    graph.clear()
    for (let i = 0; i < fireScaleColors.length; i++) {
      graph.rect(i * size, 0, size, size)
        .fill({ color: fireScaleColors[i] })
    }
  }

  draw()

  return draw
}

class FirePixel {
  pos: Vector2
  fireScaleInd: number = 0
  fireScaleIndLast: number = 0
  fireMaxHeight: number
  sprite: Sprite
  isOrigin = false
  constructor(pos: Vector2, fireMaxHeight: number, texture: Texture) {
    this.pos = pos
    this.fireMaxHeight = fireMaxHeight

    this.sprite = new Sprite(texture)
    this.sprite.anchor.set(0.5)
    const { x, y } = pos
    this.sprite.position.set(x * firePixelSize, y * firePixelSize)
    const scaleX = firePixelSize / this.sprite.texture.width
    const scaleY = firePixelSize / this.sprite.texture.height
    const scale = min(scaleX, scaleY)
    this.sprite.scale = scale
    this.sprite.tint = fireScaleColors[this.fireScaleInd]
  }

  updateFireScaleInd(fireScaleInd: number) {
    let colorInd = min(fireScaleInd, fireScaleColors.length - 1)
    colorInd = max(0, colorInd)

    this.fireScaleIndLast = this.fireScaleInd
    this.fireScaleInd = colorInd
  }

  spreadFire(firePixels: FirePixels) {
    // 没火不传播
    if (this.fireScaleInd === 0) {
      return
    }
    const power = ceil(random() * 3)
    const dist = 2
    const distVec = new Vector2(round(random() * dist - dist / 2), round(random() * dist))

    const toCoord = this.pos.clone().add(distVec)
    toCoord.y = min(toCoord.y, this.fireMaxHeight)
    const to = firePixels.get(toCoord.toString())

    if (!to?.isOrigin) {
      to?.updateFireScaleInd(this.fireScaleInd - power)
      to?.draw()
    }
    // if(this.pos.y !== 0) {
    //   this.updateFireScaleInd(this.fireScaleInd - random() < 0.2 ? 1 : 0)
    // }
  }

  draw() {
    // 同火不渲染
    if (this.fireScaleInd === this.fireScaleIndLast) {
      return
    }

    const color = fireScaleColors[this.fireScaleInd]
    this.sprite.tint = color
  }
}

async function initFirePixels(app: Application) {
  const firePixels: FirePixels = new Map()

  const texturePath = runtimePath('img/white.png')
  const texture = await Assets.load(texturePath)

  const { width, height } = app.canvas
  const rowNum = ceil(height / firePixelSize)
  const colNum = ceil(width / firePixelSize)
  const fireGroup = new Container()
  app.stage.addChild(fireGroup)
  fireGroup.scale.y = -1
  fireGroup.position.y = height

  for (let x = 0; x < colNum; x++) {
    for (let y = 0; y < rowNum; y++) {
      const coord = new Vector2(x, y)
      const firePixel = new FirePixel(coord, rowNum, texture)
      if (y === 0 || (x === ceil(colNum / 2) && y === ceil(rowNum / 2))) {
        firePixel.updateFireScaleInd(100)
        firePixel.isOrigin = true
      }
      fireGroup.addChild(firePixel.sprite)
      firePixels.set(coord.toString(), firePixel)
    }
  }

  return {
    get firePixels() {
      return firePixels
    },
    get fireGroup() {
      return fireGroup
    },
  }
}

function getBloomFilter() {
  const filter = new AdvancedBloomFilter({ bloomScale: 0.5, threshold: 0.1 })
  return filter
}

async function getDisplacementFilter() {
  // const texture = await Assets.load(runtimePath('/img/fire-texture.jpg'))
  const texture = await Assets.load(runtimePath('/img/displacement_map.png'))
  const sprite = new Sprite(texture)
  sprite.texture.source.addressMode = 'mirror-repeat'

  const filter = new DisplacementFilter({ sprite, scale: 10 })
  return filter
}

function initStats() {
  const stats = new Stats()
  pixCon.value?.appendChild(stats.dom)
  Object.assign(stats.dom.style, {
    left: null,
    right: '0px',
  })
  return stats
}

onMounted(async () => {
  await app.init({ background: fireScaleColors[0], antialias: true, resizeTo: pixCon.value })
  pixCon.value?.appendChild(app.canvas)

  const stats = initStats()

  showFireScaleColor(app)

  const { firePixels, fireGroup } = await initFirePixels(app)
  const bloomFilter = getBloomFilter()
  const displacementFilter = await getDisplacementFilter()
  fireGroup.filters = [bloomFilter, displacementFilter]

  app.ticker.add(() => {
    stats.begin()

    for (const pixel of firePixels.values()) {
      pixel.spreadFire(firePixels)
      pixel.draw()
    }

    stats.end()
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
