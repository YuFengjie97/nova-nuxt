<script lang="ts" setup>
import * as THREE from 'three'
import { GLTFLoader, GPUComputationRenderer, OrbitControls } from 'three/examples/jsm/Addons.js'
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

useEffect(() => {
  if (!containerRef.value) {
    return
  }

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  const renderer = new THREE.WebGLRenderer()
  const loops: Array<(delta: number, elapsed: number) => void> = []
  const pane: Pane = new Pane()
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
  }

  {
    const geo = new THREE.SphereGeometry(2, 64, 32) // 粒子整体形状
    geo.setIndex(null)
    const particles = {
      geo,
      count: geo.attributes.position.count,
    }
    // geo.setDrawRange(0, );

    // const mat = new THREE.PointsMaterial({ size: 0.1 })
    const mat = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms: {
        uTime,
        uResolution: new THREE.Uniform(new THREE.Vector2(size.x * dpr, size.y * dpr)),
        uDPR: new THREE.Uniform(renderer.getPixelRatio()),
      },
      transparent: true,
      depthWrite: false,
      // blending: THREE.AdditiveBlending
    })
    const points = new THREE.Points(particles.geo, mat)
    scene.add(points)

    /**
     * size * size >= particles.count
     */
    const texSize = Math.ceil(Math.sqrt(particles.count))

    const gpuCompute = new GPUComputationRenderer(texSize, texSize, renderer)
    /**
     * posTex 用于计算存储结果的材质, posTex <--乒乓--> particleFrag
     * posVar 我理解的是一种关联关系,或者是一组操作,又或者是利于管理的一组值
     * addVariable 将uPos传入particleFrag,并将paricleFrag和posTex关联,最后返回的posVar是相关信息的整合对象
     * uPosTex 材质传入frag中的uniform sampler2D的变量名
     */
    const posTex = gpuCompute.createTexture()
    const posVar = gpuCompute.addVariable('uPosTex', particleFrag, posTex)
    /**
     * 变量之间关联,关联自己的意思,frag中的pos关联tex中的pos
     */
    gpuCompute.setVariableDependencies(posVar, [posVar])

    posVar.material.uniforms.uTime = uTime
    posVar.material.uniforms.uDeltaTime = uDeltaTime
    posVar.material.uniforms.uPosDefault = new THREE.Uniform(posTex) // 后续计算在glsl中tex颜色更改,不会同步到之间的js对象,所以可以用作位置初始值
    posVar.material.uniforms.uTexNoise = new THREE.Uniform(texNoise)

    // 根据粒子初始位置 初始化(存储为) 材质像素颜色
    for (let i = 0.0; i < particles.count; i++) {
      const i3 = i * 3
      const i4 = i * 4
      const position = particles.geo.attributes.position.array
      const texData = posTex.image.data!

      texData[i4 + 0] = position[i3 + 0] // r--x
      texData[i4 + 1] = position[i3 + 1] // g--y
      texData[i4 + 2] = position[i3 + 2] // b--z
      texData[i4 + 3] = Math.random() // z--life
    }

    gpuCompute.init()

    /**
     * 每个粒子通过此uv映射数据材质
     */
    const particleUv = new Float32Array(particles.count * 2)
    for (let y = 0.0; y < texSize; y++) {
      for (let x = 0.0; x < texSize; x++) {
        const i = y * texSize + x
        const i2 = i * 2
        const uvX = (x + 0.5) / texSize
        const uvY = (y + 0.5) / texSize
        particleUv[i2] = uvX
        particleUv[i2 + 1] = uvY
      }
    }
    geo.setAttribute('aParticleUv', new THREE.BufferAttribute(particleUv, 2.0))

    // debug mesh
    {
      const geo = new THREE.PlaneGeometry(2, 2)
      const mat = new THREE.MeshBasicMaterial()
      const mesh = new THREE.Mesh(geo, mat)
      scene.add(mesh)
      mesh.position.x = 4

      // 为什么设置一次就行了
      mat.map = gpuCompute.getCurrentRenderTarget(posVar).texture
    }

    loops.push(() => {
      gpuCompute.compute()
      // mat.uniforms.uPosTex.value = gpuCompute.getCurrentRenderTarget(posVar).texture
    })
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
  <div ref="containerRef" class="w-full h-100vh" @mousemove="upadteMouse" />
</template>

<style lang='less' scoped>
</style>
