<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { ref } from 'vue'

import data from '/data/gpw_v4_basic_demographic_characteristics_rev10_a000_014mt_2010_cntm_1_deg.asc?raw'

console.log(data)

const containerRef = ref<HTMLDivElement>()
const scene = new THREE.Scene()
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls

const baseUrl = useRuntimeConfig().public.baseURL || ''

function handleResize() {
  const width = containerRef.value!.clientWidth
  const height = containerRef.value!.clientHeight

  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize(width, height)
}

onMounted(() => {
  if (!containerRef.value) {
    return
  }
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 10)
  camera.position.set(0, 0, -2.5)
  camera.lookAt(new THREE.Vector3(0, 0, 0))
  controls = new OrbitControls(camera, containerRef.value)
  renderer = new THREE.WebGLRenderer({ antialias: true })
  containerRef.value.append(renderer.domElement)
  handleResize()

  const loops: Array<(time?: number) => void> = []

  const loader = new THREE.TextureLoader()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight()
    scene.add(light)
  }

  {
    const group = new THREE.Group()
    scene.add(group)
    const geo = new THREE.SphereGeometry(1, 64, 32)
    const tex = loader.load(`${baseUrl}img/texture/world.jpg`)
    tex.colorSpace = THREE.SRGBColorSpace
    const mat = new THREE.MeshBasicMaterial({ map: tex })
    const mesh = new THREE.Mesh(geo, mat)
    group.add(mesh)
  }

  function animate(time: number) {
    loops.forEach(fn => fn(time))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  controls.dispose()

  disposeScene(scene)

  renderer.dispose()
  renderer.forceContextLoss()

  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh">
    <!-- <canvas ref="renderCanvas" class="h-full w-full block m-0"/> -->
  </div>
</template>

<style lang='less' scoped>
</style>
