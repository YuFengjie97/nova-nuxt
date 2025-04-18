<script lang="ts" setup>
import { Application, Assets, Geometry, Mesh, Shader } from 'pixi.js'
import fragment from '~/shaders/begin/frag.frag'
import vertex from '~/shaders/begin/vert.vert'

const pixiCon = ref<HTMLElement>()
const app = new Application()

onMounted(async () => {
  await app.init({ background: '#000', resizeTo: pixiCon.value, preference: 'webgl' })
  pixiCon.value?.appendChild(app.canvas)
  const { width, height } = app.screen

  const geometry = new Geometry({
    attributes: {
      aPosition: [
        0,
        0, // x, y
        width,
        0, // x, y
        width,
        height, // x, y,
        0,
        height, // x, y,
      ],
    },
    indexBuffer: [0, 1, 2, 0, 2, 3],
  })

  const shader = Shader.from({
    gl: {
      vertex,
      fragment,
    },
    resources: {
      shaderToyUniforms: {
        iResolution: { value: [width, height, 1], type: 'vec3<f32>' },
        iTime: { value: 0, type: 'f32' },
      },
      uTexture: (await Assets.load(runtimePath('/img/noise/perlin.jpg'))).source,
    },
  })

  const mesh = new Mesh({
    geometry,
    shader,
  })
  mesh.position.set(0, 0)
  app.stage.addChild(mesh)

  app.ticker.add(() => {
    shader.resources.shaderToyUniforms.uniforms.iTime += 0.1
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
