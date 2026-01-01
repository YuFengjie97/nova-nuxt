/**
uniform -> ver + frag
ver -varying-> frag
attribute -> ver
*/

<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

import { ref } from 'vue'
import fragment from './fragment.glsl'
import vertex from './vertex.glsl'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
const loops: Array<(delta: number) => void> = []
const clock = new THREE.Clock()
let pane: Pane
let controls: OrbitControls

function handleResize() {
  if (!containerRef.value)
    return

  const width = containerRef.value.clientWidth
  const height = containerRef.value.clientHeight
  camera.aspect = width / height
  camera.updateProjectionMatrix()

  renderer.setSize(width, height)
}

onMounted(() => {
  if (!containerRef.value) {
    return
  }
  pane = new Pane()
  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  const cameraGroup = new THREE.Group()
  cameraGroup.add(camera)
  scene.add(cameraGroup)
  camera.position.z = 1.5
  camera.position.y = 1.0
  renderer = new THREE.WebGLRenderer()
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap

  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true

  handleResize()
  window.addEventListener('resize', handleResize)

  const uTime = {
    value: 0.0,
  }

  function animate() {
    const elapsedTime = clock.getElapsedTime()
    uTime.value = elapsedTime

    controls.update()
    const delta = clock.getDelta()
    loops.forEach(fn => fn(delta))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  {
    const geo = new THREE.PlaneGeometry(3, 3, 100, 100)
    // const geo = new THREE.SphereGeometry(0.5, 10, 10)

    const vertexCount = geo.getAttribute('position').count
    const aRandom = new Float32Array(vertexCount)
    for (let i = 0; i < vertexCount; i++) {
      aRandom[i] = Math.random()
    }
    geo.setAttribute('aRandom', new THREE.BufferAttribute(aRandom, 1))

    const tex = textureLoader.load(`${baseUrl}img/shaderToy/texture5.jpg`)

    const mat = new THREE.RawShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      side: THREE.DoubleSide,
      uniforms: {
        uFrequency: { value: 10.0 },
        uTime,
        uTexture: { value: tex },
        uDisableRandom: { value: false },
      },
    })

    pane.addBinding(mat.uniforms.uFrequency, 'value', { min: 1.0, max: 10.0, step: 0.1, label: 'freq' })
    pane.addBinding(mat.uniforms.uDisableRandom, 'value', { label: '禁用随机偏移' })

    // mat.wireframe = true
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.x -= Math.PI / 2.0
    scene.add(mesh)
  }
})

onUnmounted(() => {
  controls.dispose()

  renderer.dispose()
  renderer.forceContextLoss()
  disposeScene(scene)
  pane.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="w-full h-100vh fixed top-0 left-0" />
</template>

<style>

</style>
