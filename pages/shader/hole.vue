<script lang="ts" setup>
import { Application, Assets, Geometry, Mesh, Shader, UniformGroup } from 'pixi.js'
import { Pane } from 'tweakpane'
import fragment from '~/shaders/hole/frag.frag'
import vertex from '~/shaders/hole/vert.vert'

const pixiCon = ref<HTMLElement>()
const app = new Application()
let pane: Pane

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

  const u = {
    noise_distort_scale: 0.8,
    noise_distort_uv_scale: 0.2,
    smooth_dist: 0.1,
  }

  const uniforms = new UniformGroup({
    iTime: { value: 0, type: 'f32' },
    noise_distort_scale: { value: u.noise_distort_scale, type: 'f32' },
    noise_distort_uv_scale: { value: u.noise_distort_scale, type: 'f32' },
    smooth_dist: { value: u.smooth_dist, type: 'f32' },
    iResolution: { value: [width, height], type: 'vec2<f32>' },
  })

  pane = new Pane()
  pane.addBinding(u, 'noise_distort_scale', { min: 0.1, max: 1, step: 0.1 })
    .on('change', (ev) => {
      const { value } = ev
      uniforms.uniforms.noise_distort_scale = value
    })
  pane.addBinding(u, 'noise_distort_uv_scale', { min: 0.1, max: 1, step: 0.1 })
    .on('change', (ev) => {
      const { value } = ev
      uniforms.uniforms.noise_distort_uv_scale = value
    })
  pane.addBinding(u, 'smooth_dist', { min: 0.1, max: 1, step: 0.1 })
    .on('change', (ev) => {
      const { value } = ev
      uniforms.uniforms.smooth_dist = value
    })

  const shader = Shader.from({
    gl: {
      vertex,
      fragment,
    },
    resources: {
      uniforms,
      iChannel0: (await Assets.load(runtimePath('/img/noise/shaderToy/noise_1.jpg'))).source,
      iChannel1: (await Assets.load(runtimePath('/img/noise/shaderToy/noise_2.png'))).source,
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
    t += 0.01
    uniforms.uniforms.iTime = t
  })
})

onUnmounted(() => {
  app.destroy(true, { children: true })
  pane.dispose()
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style></style>
