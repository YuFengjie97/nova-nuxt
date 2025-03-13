<script lang="ts" setup>
import type { Renderer, Texture } from 'pixi.js'
import { AnimatedSprite, Application, Assets, Graphics, Spritesheet } from 'pixi.js'

let app: Application<Renderer>
const canvasWrap = ref<HTMLElement>()

async function initApp(container: HTMLElement) {
  const app = new Application()
  await app.init({ antialias: true, background: '#1099bb', resizeTo: canvasWrap.value })
  container.appendChild(app.canvas)

  return app
}

function getRect() {
  const rectangle = new Graphics()
  let isScale = false

  rectangle.rect(0, 0, 64, 64)
    .stroke({
      color: 'red',
      width: 4,
    })
    .fill(0x66CCFF)

  rectangle.eventMode = 'static'

  rectangle.on('pointerdown', () => {
    rectangle.scale.set(isScale ? 1 : 0.5)
    isScale = !isScale
  })

  rectangle.x = 200
  rectangle.y = 200
  const bounds = rectangle.bounds
  rectangle.pivot.set(bounds.width / 2, bounds.height / 2)

  const pivotCircle = new Graphics().circle(0, 0, 4).fill('red')
  pivotCircle.position.set(rectangle.x, rectangle.y)

  return [rectangle, pivotCircle]
}

function getLine() {
  const line = new Graphics()
    .moveTo(100, 100)
    .lineTo(100, 400)
    .lineTo(200, 110)
    .stroke({
      color: 'green',
      width: 10,
      cap: 'round',
      join: 'round',
    })
  return line
}

function getGrid() {
  const { width, height } = app.screen
  const gap = 50
  const grid = new Graphics()
  for (let i = 0; i < Math.ceil(width / gap); i++) {
    grid.moveTo(i * gap, 0)
      .lineTo(i * gap, height)
  }
  for (let i = 0; i < Math.ceil(height / gap); i++) {
    grid.moveTo(0, i * gap)
      .lineTo(width, i * gap)
  }
  grid.stroke({ color: 0xFFFFFF, pixelLine: true })

  return grid
}

async function getDogeSprite() {
  const texture = await Assets.load<Texture>(runtimePath(`img/spriteSheet/danceDoge/texture.png`))
  const { data } = await Assets.load(runtimePath(`img/spriteSheet/danceDoge/texture.json`))

  const spritesheet = new Spritesheet(texture, data)

  await spritesheet.parse()

  const anim = new AnimatedSprite(spritesheet.animations.anime1)

  anim.animationSpeed = 0.1666
  anim.play()
  return anim
}

onMounted(async () => {
  app = await initApp(canvasWrap.value!)

  const [rect, rectPivot] = getRect()
  const line = getLine()
  const grid = getGrid()

  const dogeSprite = await getDogeSprite()

  app.stage.addChild(grid, rect, rectPivot, line, dogeSprite)

  app.ticker.add((time) => {
    const { deltaTime } = time
    rect.rotation += 0.01 * deltaTime
  })
})

onUnmounted(() => {
  app.destroy()
})
</script>

<template>
  <div ref="canvasWrap" class="w-full h-100vh" />
</template>

<style lang='less' scoped>

</style>
