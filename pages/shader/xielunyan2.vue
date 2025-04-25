<script lang="ts" setup>
import { Application, Geometry, Mesh, Shader, UniformGroup } from 'pixi.js'
import fragment from '~/shaders/xielunyan2/frag.frag'
import vertex from '~/shaders/xielunyan2/vert.vert'

const pixiCon = ref<HTMLElement>()
const app = new Application()

onMounted(async () => {
  await app.init({ background: '#000', resizeTo: pixiCon.value, preference: 'webgl' })
  pixiCon.value?.appendChild(app.canvas)
  const { width, height } = app.screen

  const geometry = new Geometry({
    attributes: {
      aPosition: [0, 0, width, 0, width, height, 0, height],
    },
    indexBuffer: [0, 1, 2, 0, 2, 3],
  })

  const uniforms = new UniformGroup({
    iResolution: { value: [width, height], type: 'vec2<f32>' },
    iTime: { value: 0, type: 'f32' },
  })

  const shader = Shader.from({
    gl: {
      vertex,
      fragment,
    },
    resources: {
      uniforms,
    },
  })

  const mesh = new Mesh({
    geometry,
    shader,
  })
  app.stage.addChild(mesh)

  let t = 0
  app.ticker.add(() => {
    t += 0.01
    uniforms.uniforms.iTime = t
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
