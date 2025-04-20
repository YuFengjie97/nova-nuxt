<script lang="ts" setup>
import { Application, Assets, Geometry, Mesh, Shader, UniformGroup } from 'pixi.js'
import fragment from '~/shaders/fire/frag.frag'
import vertex from '~/shaders/fire/vert.vert'

const pixiCon = ref<HTMLElement>()
const app = new Application()

onMounted(async () => {
  await app.init({ background: '#000', resizeTo: pixiCon.value, preference: 'webgl' })
  pixiCon.value?.appendChild(app.canvas)
  const { width, height } = app.screen

  const scale = Math.min(width, height)

  const geometry = new Geometry({
    attributes: {
      aPosition: [0, 0, width, 0, width, height, 0, height],
      aUV: [0, 0, width / scale, 0, width / scale, height / scale, 0, height / scale],
    },
    indexBuffer: [0, 1, 2, 0, 2, 3],
  })

  const uTime = new UniformGroup({
    uTime: { value: 1, type: 'f32' },
  })

  const shader = Shader.from({
    gl: {
      vertex,
      fragment,
    },
    resources: {
      uTime,
      texNoise: (await Assets.load(runtimePath('/img/noise/good/noise1.jpg'))).source,
      // texDistort: (await Assets.load(runtimePath('/img/noise/good/perlin.jpg'))).source,
      texDistort: (await Assets.load(runtimePath('/img/noise/WaterDistortion.jpg'))).source,
    },
  })

  const mesh = new Mesh({
    geometry,
    shader,
  })
  mesh.position.set(0, 0)
  app.stage.addChild(mesh)

  let t = 0
  app.ticker.add(() => {
    t += 0.1
    uTime.uniforms.uTime = t
  })
})

onUnmounted(() => {
  app.destroy(true, { children: true })
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style></style>
