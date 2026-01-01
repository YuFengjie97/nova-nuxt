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
  scene.add(camera)
  camera.position.z = 1.5
  camera.position.y = 1.0
  renderer = new THREE.WebGLRenderer()
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  // renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap

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
    const tex_uv = textureLoader.load(`${baseUrl}img/texture/uv_grid_opengl.jpg`)

    const geo = new THREE.PlaneGeometry(10, 10, 1000, 1000)
    const mat = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      side: THREE.DoubleSide,
      uniforms: {
        uTime,
        texUv: {
          value: tex_uv,
        },
        colTop: {
          value: new THREE.Color(0xEE0011),
        },
        colBottom: {
          value: new THREE.Color(0x001100),
        },
      },
    })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.x = -Math.PI * 0.5
    // mesh.position.z = -8
    scene.add(mesh)

    pane.addBinding(mat.uniforms.colTop, 'value', { color: { type: 'float' }, label: 'colTop' })
    pane.addBinding(mat.uniforms.colBottom, 'value', { color: { type: 'float' }, label: 'colBottom' })
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
  <div ref="containerRef" class="w-full h-100vh" />
</template>

<style>

</style>
