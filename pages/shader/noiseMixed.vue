<script lang="ts" setup>
import type { ImageSource } from 'pixi.js'
import type { ListBladeApi } from 'tweakpane'
import { Application, Assets, Geometry, Mesh, Shader, UniformGroup } from 'pixi.js'
import { Pane } from 'tweakpane'
import fragment from '~/shaders/noiseMixed/frag.frag'
import vertex from '~/shaders/noiseMixed/vert.vert'

const pixiCon = ref<HTMLElement>()
const app = new Application()
let pane: Pane

const textures: Array<{
  alias: string
  src: string
}> = [
  { alias: 'texture1', src: '/img/noise/good/noise1.jpg' },
  { alias: 'texture2', src: '/img/noise/good/perlin.jpg' },
  { alias: 'texture3', src: '/img/noise/good/noise2.png' },
  { alias: 'texture4', src: '/img/noise/good/noise-texture-11.png' },
  { alias: 'texture5', src: '/img/noise/noise2.jpg' },
  { alias: 'texture6', src: '/img/noise/WaterDistortion.jpg' },
  { alias: 'texture7', src: '/img/noise/noiseTexture.png' },
  { alias: 'texture8', src: '/img/noise/2d perlin noise bw.png' },
  { alias: 'texture9', src: '/img/noise/2d perlin noise color.png' },
]

const shaderOptions: {
  distortStength: number
  textureNoise: string
  textureDistort: string
} = {
  distortStength: 0.2,
  textureNoise: 'texture1',
  textureDistort: 'texture1',
}

const uniformGroup = new UniformGroup({
  distortStength: { value: shaderOptions.distortStength, type: 'f32' },
  uTime: { value: 1, type: 'f32' },
})

async function loadTextures() {
  textures.forEach(({ alias, src }) => {
    Assets.add({ alias, src: runtimePath(src) })
  })
  const res = await Assets.load(textures.map(item => item.alias))
  return res
}

class ShaderMesh {
  app: Application
  mesh: Mesh<Geometry, Shader>
  uniformGroup: UniformGroup
  constructor(app: Application, texNoise: any, texDistort: any, uniformGroup: UniformGroup) {
    this.app = app
    this.uniformGroup = uniformGroup
    const geometry = this.createGeometry()
    const shader = this.createShader(texNoise, texDistort)

    this.mesh = new Mesh({
      geometry,
      shader,
    })
    this.mesh.position.set(0, 0)
    this.app.stage.addChild(this.mesh)
  }

  createGeometry() {
    const { width, height } = this.app.screen
    const scale = Math.min(width, height)

    const geometry = new Geometry({
      attributes: {
        aPosition: [0, 0, width, 0, width, height, 0, height],
        aUV: [0, 0, width / scale, 0, width / scale, height / scale, 0, height / scale],
      },
      indexBuffer: [0, 1, 2, 0, 2, 3],
    })
    return geometry
  }

  createShader(texNoise: any, texDistort: any) {
    const shader = Shader.from({
      gl: {
        vertex,
        fragment,
      },
      resources: {
        uniformGroup: this.uniformGroup,
        texNoise,
        texDistort,
      },
    })
    return shader
  }

  updateShaderBaseNoise(imgSource: ImageSource) {
    this.mesh.shader!.resources.texNoise = imgSource
  }

  updateShaderDistortNoise(imgSource: ImageSource) {
    this.mesh.shader!.resources.texDistort = imgSource
  }
}

onMounted(async () => {
  await app.init({ background: '#000', resizeTo: pixiCon.value, preference: 'webgl' })
  pixiCon.value?.appendChild(app.canvas)

  pane = new Pane()
  const textureResource = await loadTextures()
  const textureOptions = textures.map((item) => {
    return { text: item.alias, value: item.alias }
  })

  const shaderMesh = new ShaderMesh(app, textureResource[textureOptions[0].value].source, textureResource[textureOptions[1].value].source, uniformGroup)

  pane.addBinding(shaderOptions, 'distortStength', { min: 0, max: 2, step: 0.1 })
    .on('change', (event) => {
      const { value } = event
      uniformGroup.uniforms.distortStength = value
    })

  ; (pane.addBlade({
    view: 'list',
    label: 'textureNoise',
    options: textureOptions.slice(),
    value: textureOptions.slice()[0].value,
  }) as ListBladeApi<any>)
    .on('change', (ev) => {
      const textureName = ev.value
      shaderMesh.updateShaderBaseNoise(textureResource[textureName])
    })

  ; (pane.addBlade({
    view: 'list',
    label: 'textureDistortion',
    options: textureOptions.slice(),
    value: textureOptions.slice()[0].value,
  }) as ListBladeApi<any>)
    .on('change', (ev) => {
      const textureName = ev.value
      shaderMesh.updateShaderDistortNoise(textureResource[textureName])
    })

  let t = 0
  app.ticker.add(() => {
    t += 0.1
    uniformGroup.uniforms.uTime = t
  })
})

onUnmounted(() => {
  pane.dispose()
  app.destroy(true, { children: true })
  Assets.reset()
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style></style>
