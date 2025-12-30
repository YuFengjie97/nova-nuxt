<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'
import { ref } from 'vue'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
const loops: Array<() => void> = []
const clock = new THREE.Clock()
let pane: Pane

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
  camera.position.z = 5
  camera.position.y = 4
  renderer = new THREE.WebGLRenderer()
  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap

  handleResize()
  window.addEventListener('resize', handleResize)

  function animate() {
    loops.forEach(fn => fn())
    controls.update()
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  {
    const light = new THREE.AmbientLight()
    light.intensity = 0.3
    scene.add(light)
    pane.addBinding(light, 'intensity', { min: 0, max: 4, step: 0.1, label: '环境光强度' })
  }

  {
    const light = new THREE.DirectionalLight()
    light.castShadow = true
    light.position.set(3, 3, 0)
    light.shadow.mapSize.width = 1024
    light.shadow.mapSize.height = 1024
    light.shadow.radius = 20 // 阴影边缘模糊

    scene.add(light)
    scene.add(light.target)

    const helper = new THREE.DirectionalLightHelper(light)
    scene.add(helper)

    const shadowCamera = light.shadow.camera
    shadowCamera.near = 0.1
    shadowCamera.far = 10
    shadowCamera.top = 2
    shadowCamera.left = -2
    shadowCamera.bottom = -2
    shadowCamera.right = 2
    const cameraHelper = new THREE.CameraHelper(shadowCamera)
    scene.add(cameraHelper)

    pane.addBinding(light, 'intensity', { min: 0, max: 10, step: 0.1, label: '平行光强度' })
    pane.addBinding(helper, 'visible', { label: '光源helper' })
    pane.addBinding(cameraHelper, 'visible', { label: '光源相机helper' })
    pane.addBinding(shadowCamera, 'near', { min: 0.1, max: 4, step: 0.1, label: 'near' })
      .on('change', () => {
        shadowCamera.updateProjectionMatrix()
        cameraHelper.update()
      })
    pane.addBinding(shadowCamera, 'far', { min: 0, max: 40, step: 1, label: 'far' }).on('change', () => {
      shadowCamera.updateProjectionMatrix()
      cameraHelper.update()
    })
  }

  const mat = new THREE.MeshStandardMaterial()
  mat.roughness = 0.7
  mat.metalness = 0.1
  pane.addBinding(mat, 'roughness', { min: 0, max: 1.0, step: 0.1 })
  pane.addBinding(mat, 'metalness', { min: 0, max: 1.0, step: 0.1 })

  {
    const geo = new THREE.PlaneGeometry(10, 10)
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.x = -Math.PI / 2.0
    mesh.receiveShadow = true
    scene.add(mesh)
  }
  {
    const geo = new THREE.SphereGeometry(1)
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.y = 1
    mesh.castShadow = true
    scene.add(mesh)
  }
})

onUnmounted(() => {
  renderer.dispose()
  renderer.forceContextLoss()
  controls.dispose()
  disposeScene(scene)
  pane.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh" />
</template>

<style></style>
