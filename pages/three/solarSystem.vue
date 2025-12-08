<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'

const threeContainer = ref<HTMLElement>()
const guiContainer = ref<HTMLElement>()

let camera: THREE.PerspectiveCamera
let scene: THREE.Scene
let renderer: THREE.WebGLRenderer

const loops: Array<() => void> = []

onMounted(() => {
  if (!threeContainer.value) {
    return
  }
  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.set(0, 10, -10)
  camera.lookAt(new THREE.Vector3(0, 0, 0))
  scene = new THREE.Scene()
  renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  threeContainer.value.appendChild(renderer.domElement)

  {
    const axisHelper = new THREE.AxesHelper(10000)
    scene.add(axisHelper)
  }

  {
    const control = new OrbitControls(camera, threeContainer.value)
    console.log(control)
  }

  if (false) {
    // test cube
    const geo = new THREE.BoxGeometry(3, 3, 3)
    const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
    function update() {
      mesh.rotation.x += 0.01
      mesh.rotation.y += 0.01
    }
    loops.push(update)
  }

  function animate() {
    loops.forEach(fn => fn())
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)
})
</script>

<template>
  <div class="absolute top-0 w-100vw h-100vh">
    <div ref="threeContainer" class="absolute top-0 left-0 w-100vw h-100vh" />
    <div ref="guiContainer" />
  </div>
</template>

<style>

</style>
