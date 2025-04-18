<script lang="ts" setup>
import { Application, Container, Graphics, RenderTexture, Sprite } from 'pixi.js'

const pixiCon = ref<HTMLElement>()
const noisePreviewCon = ref<HTMLElement>()
const app = new Application()
const noisePreviewApp = new Application()

function getNoiseSprite(app: Application, width: number, height: number) {
  const renderTexture = RenderTexture.create({ width, height })
  const container = new Container()
  const graph = new Graphics()
  for (let x = 0; x < width; x++) {
    for (let y = 0; y < height; y++) {
      // const n = (noise2D(x, y) * 0.5 + 0.5)
      const fbmOptions = {
        octaves: 8,
        lacunarity: 1,
        gain: 1,
        amplitude: 1,
        frequency: 1,
      }
      const n = fbm2D(x, y, fbmOptions) * 0.5 + 0.5

      const gray = n * 255
      const color = `rgb(${gray},${gray},${gray})`

      graph.rect(x, y, 1, 1)
      graph.fill({ color })
    }
  }
  container.addChild(graph)

  app.renderer.render({ container, target: renderTexture })

  const sprite = new Sprite(renderTexture)
  sprite.width = width
  sprite.height = height
  return sprite
}

const showNoisePreview = ref(false)

onMounted(async () => {
  await app.init({ background: '#111', resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)
  const { width, height } = app.screen

  await noisePreviewApp.init({ background: '#000', resizeTo: noisePreviewCon.value })
  noisePreviewCon.value?.appendChild(noisePreviewApp.canvas)

  const noiseSprite = getNoiseSprite(noisePreviewApp, width, height)
  noisePreviewApp.stage.addChild(noiseSprite)
})

onUnmounted(() => {
  app.destroy(true, { children: true })
  noisePreviewApp.destroy(true, { children: true })
})
</script>

<template>
  <div class="w-full h-100vh relative">
    <div ref="pixiCon" class="w-full h-full" />
    <div ref="noisePreviewCon" :class="{ 'show-noise-preview': showNoisePreview }" class="absolute transition-top transition-duration-300 top--100% left-0 w-full h-full border-inset border-solid border-10px border-amber" />
    <div class="bg-amber fixed left-50% top-0 p-y-10px p-x-20px cursor-pointer b-rd-4px transform-translate-x--50%" @click="() => { showNoisePreview = !showNoisePreview }">
      {{ showNoisePreview ? 'hide' : 'show' }} noise Preview
    </div>
  </div>
</template>

<style lang='less' scoped>
.show-noise-preview{
  top: 0;
}
</style>
