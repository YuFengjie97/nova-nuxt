<script lang="ts" setup>
import type { Variable } from 'three/examples/jsm/Addons.js'
import * as THREE from 'three'
import { BufferGeometryUtils, GLTFLoader, GPUComputationRenderer, OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

import { ref } from 'vue'
import { useEffect } from '~/hooks/useEffect'

import fragment from './fragment.glsl'
import particleFrag from './particles.glsl'
import vertex from './vertex.glsl'

const baseUrl = useRuntimeConfig().public.baseURL || ''
const containerRef = ref<HTMLDivElement>()

const size = new THREE.Vector2(0, 0)
const mouse = new THREE.Vector2(0, 0)
function upadteMouse(ev: MouseEvent) {
  const { x, y } = ev
  mouse.x = x / size.x * 2 - 1
  mouse.y = -y / size.y * 2 + 1
}

useEffect(async () => {
  if (!containerRef.value) {
    return
  }

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  const renderer = new THREE.WebGLRenderer()
  const loops: Array<(delta: number, elapsed: number) => void> = []
  const pane: Pane = new Pane({ container: containerRef.value })
  const controls: OrbitControls = new OrbitControls(camera, renderer.domElement)

  function handleResize() {
    if (!containerRef.value)
      return

    const width = containerRef.value.clientWidth
    const height = containerRef.value.clientHeight
    camera.aspect = width / height
    camera.updateProjectionMatrix()

    size.x = width
    size.y = height

    renderer.setSize(width, height)
  }

  scene.add(camera)
  camera.position.z = 5.5
  // camera.position.y = 1.0
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  // renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap
  controls.enableDamping = true

  handleResize()
  window.addEventListener('resize', handleResize)

  const uTime = {
    value: 0.0,
  }
  const uDeltaTime = {
    value: 0.0,
  }

  const clock = new THREE.Clock()
  const clock2 = new THREE.Clock()
  function animate() {
    const elapsedTime = clock.getElapsedTime()
    uTime.value = elapsedTime

    controls.update()
    const delta = clock2.getDelta()
    uDeltaTime.value = delta

    loops.forEach(fn => fn(delta, elapsedTime))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const gltfloader = new GLTFLoader(loadingManager)

  const texNoise = textureLoader.load(`${baseUrl}img/texture/noise/Perlin 6 - 512x512.png`)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
    const light = new THREE.AmbientLight()
    scene.add(light)
  }

  async function getModelGeo() {
    const model = await gltfloader.loadAsync(`${baseUrl}model/shiba/scene.gltf`).then(res => res.scene)
    const geos: THREE.BufferGeometry[] = []
    model.traverse((obj) => {
      // @ts-ignore
      if (obj.isMesh) {
        const mesh = obj as THREE.Mesh
        // @ts-ignore
        mesh.material.wireframe = true
        geos.push(mesh.geometry)
      }
    })
    const geo = BufferGeometryUtils.mergeGeometries(geos)
    return geo
  }

  class GPGPU {
    geo: THREE.BufferGeometry // 用于初始化的geo
    particleCount: number
    textureSize: number
    computer: GPUComputationRenderer
    particleTex: THREE.DataTexture
    particleVar: Variable
    constructor(geo: THREE.BufferGeometry, renderer: THREE.WebGLRenderer) {
      this.geo = geo
      this.particleCount = geo.attributes.position.count
      this.textureSize = Math.ceil(Math.sqrt(this.particleCount))
      this.computer = new GPUComputationRenderer(this.textureSize, this.textureSize, renderer)

      this.particleTex = this.computer.createTexture()
      this.particleVar = this.computer.addVariable('uParticle', particleFrag, this.particleTex)
      this.computer.setVariableDependencies(this.particleVar, [this.particleVar])

      this.initPosTex()
      this.initFragUniform()

      this.computer.init()
    }

    initPosTex() {
      const position = this.geo.attributes.position.array
      const texData = this.particleTex.image.data!
      for (let i = 0; i < this.particleCount; i++) {
        const i3 = i * 3
        const i4 = i * 4
        texData[i4 + 0] = position[i3 + 0] // x
        texData[i4 + 1] = position[i3 + 1] // y
        texData[i4 + 2] = position[i3 + 2] // z
        texData[i4 + 3] = Math.random() // life
      }
    }

    initFragUniform() {
      this.particleVar.material.uniforms.uTime = uTime
      this.particleVar.material.uniforms.uDeltaTime = uDeltaTime
      this.particleVar.material.uniforms.uParticleDefault = new THREE.Uniform(this.particleTex)
      this.particleVar.material.uniforms.uNoise = new THREE.Uniform(texNoise)

      // 自定义空间控制
      this.particleVar.material.uniforms.uFlowFieldStrength = new THREE.Uniform(2)
      pane.addBinding(
        this.particleVar.material.uniforms.uFlowFieldStrength,
        'value',
        { min: 0.1, max: 10.0, step: 0.1, label: 'FlowFieldStrength' },
      )
    }

    getComputeTex() {
      return this.computer.getCurrentRenderTarget(this.particleVar).texture
    }

    helper() {
      const geo = new THREE.PlaneGeometry(1, 1)
      const mat = new THREE.MeshBasicMaterial()
      // mat.map = this.particleTex
      mat.map = this.getComputeTex()
      const mesh = new THREE.Mesh(geo, mat)
      return mesh
    }

    // 获取粒子对应uv
    getParticleUV() {
      const uv = new Float32Array(this.particleCount * 2)
      for (let y = 0.0; y < this.textureSize; y++) {
        for (let x = 0.0; x < this.textureSize; x++) {
          const i = y * this.textureSize + x
          const i2 = i * 2
          const uvX = (x + 0.5) / this.textureSize
          const uvY = (y + 0.5) / this.textureSize
          uv[i2 + 0] = uvX
          uv[i2 + 1] = uvY
        }
      }

      return uv
    }
  }

  {
    const geo = await getModelGeo()
    geo.rotateX(-Math.PI / 2.0)
    geo.scale(4, 4, 4)
    geo.translate(0, 2, 0)
    // console.log(geo);

    const gpgpu = new GPGPU(geo, renderer)

    const helper = gpgpu.helper()
    helper.scale.set(10, 10, 10)
    helper.position.z = -10
    helper.position.x = -10
    scene.add(helper)

    geo.setAttribute('aParticleUV', new THREE.BufferAttribute(gpgpu.getParticleUV(), 2))

    const mat = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      transparent: true,
      blending: THREE.AdditiveBlending,
    })
    mat.uniforms.uTime = uTime
    mat.uniforms.uDeltaTime = uDeltaTime
    mat.uniforms.uParticleTex = new THREE.Uniform(gpgpu.getComputeTex())
    mat.uniforms.uDPR = new THREE.Uniform(renderer.getPixelRatio())
    mat.uniforms.uParticleSize = new THREE.Uniform(10)

    const points = new THREE.Points(geo, mat)
    scene.add(points)

    loops.push(() => {
      gpgpu.computer.compute()
      helper.material.map = gpgpu.getComputeTex()
      mat.uniforms.uParticleTex.value = gpgpu.getComputeTex()
    })

    pane.addBinding(helper, 'visible', { label: 'helper' })

    pane.addBinding(mat.uniforms.uParticleSize, 'value', { min: 1, max: 40, step: 1, label: 'particleSize' })
    pane.addBinding(mat.uniforms.uFlowFieldStrength, 'value', { min: 0.1, max: 4, step: 0.1, label: 'uFlowFieldStrength' })
  }

  return () => {
    disposeScene(scene, renderer)
    controls.dispose()
    pane.dispose()
    window.removeEventListener('resize', handleResize)
  }
}, [])
</script>

<template>
  <div ref="containerRef" class="w-full h-100vh relative three-con" @mousemove="upadteMouse" />
</template>

<style lang='less' scoped>
  .three-con{
    ::v-deep .tp-rotv{
      position: absolute;
      top: 0;
      right: 0;
      width: 300px;
    }
  }
</style>
