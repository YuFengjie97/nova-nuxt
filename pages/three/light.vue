<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const threeContainerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
const loops: Array<() => void> = []

let pane: Pane

function handleResize() {
  const { width, height } = threeContainerRef.value!.getBoundingClientRect()
  camera.aspect = width / height
  camera.updateProjectionMatrix()

  renderer.setSize(width, height)
}

class ColorUIHelper {
  light: THREE.Light
  colorKey: string
  constructor(light: THREE.Light, colorKey: string) {
    this.light = light
    this.colorKey = colorKey
  }

  get value() {
    // @ts-ignore
    return `#${this.light[this.colorKey].getHexString()}`
  }

  set value(hexString) {
    // @ts-ignore
    this.light[this.colorKey].set(hexString)
  }
}

onMounted(() => {
  const threeContainer = threeContainerRef.value
  if (!threeContainer)
    return

  pane = new Pane()

  const { width, height } = threeContainer.getBoundingClientRect()
  const resolution = { x: width, y: height }

  scene = new THREE.Scene()

  camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.set(0, 20, -20)
  camera.lookAt(new THREE.Vector3(0, 0, 0))

  controls = new OrbitControls(camera, threeContainer)

  renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  renderer.shadowMap.enabled = true

  threeContainer.appendChild(renderer.domElement)

  const loader = new THREE.TextureLoader()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  {
    const planeSize = 40
    const geo = new THREE.PlaneGeometry(planeSize, planeSize)
    const tex = loader.load(`${baseUrl}img/texture/checker.png`)
    tex.wrapS = THREE.RepeatWrapping
    tex.wrapT = THREE.RepeatWrapping
    tex.magFilter = THREE.NearestFilter
    // tex.magFilter = THREE.LinearFilter
    tex.colorSpace = THREE.SRGBColorSpace
    const repeats = planeSize / 2.0
    tex.repeat.set(repeats, repeats)
    const mat = new THREE.MeshPhongMaterial({
      map: tex,
      side: THREE.DoubleSide,
    })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.receiveShadow = true
    mesh.rotation.x = Math.PI * -0.5
    scene.add(mesh)
  }

  {
    const geo = new THREE.BoxGeometry(5, 5, 5)
    const mat = new THREE.MeshPhongMaterial({ color: 0xFDCB6E })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.set(-10, 5, 0)
    scene.add(mesh)
    mesh.receiveShadow = true

    loops.push(() => {
      mesh.rotation.x += 0.05
      mesh.rotation.y += 0.05
    })
  }
  {
    const geo = new THREE.SphereGeometry(5)
    const mat = new THREE.MeshPhongMaterial({ color: 0x0984E3 })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.receiveShadow = true
    mesh.position.set(10, 5, 0)
    scene.add(mesh)
  }
  {
    const light = new THREE.AmbientLight()
    light.visible = false
    scene.add(light)
    const folder = pane.addFolder({ title: '环境光' })
    folder.addBinding(light, 'visible', { label: 'visible' })
    folder.addBinding(new ColorUIHelper(light, 'color'), 'value', { label: 'color' })
    folder.addBinding(light, 'intensity', { min: 0, max: 100 })
  }

  {
    const group = new THREE.Group()
    group.visible = false
    scene.add(group)
    const light = new THREE.HemisphereLight()
    group.add(light)
    const helper = new THREE.HemisphereLightHelper(light, 10)
    group.add(helper)
    const f = pane.addFolder({ title: '半球光' })
    f.addBinding(group, 'visible')
    f.addBinding(new ColorUIHelper(light, 'color'), 'value', { label: 'skyColor' })
    f.addBinding(new ColorUIHelper(light, 'groundColor'), 'value', { label: 'groundColor' })
    f.addBinding(light, 'intensity', { min: 0, max: 100 })
  }
  {
    const group = new THREE.Group()
    group.visible = false
    scene.add(group)
    const light = new THREE.DirectionalLight()
    light.position.set(0, 20, 5)
    light.target.position.set(0, 0, 0)
    const helper = new THREE.DirectionalLightHelper(light, 4)
    group.add(light)
    group.add(helper)
    const f = pane.addFolder({ title: '方向光' })
    f.addBinding(group, 'visible')
    f.addBinding(new ColorUIHelper(light, 'color'), 'value', { label: 'color' })
    f.addBinding(light, 'intensity', { min: 0, max: 100 })
    loops.push(() => {
      const time = Date.now() * 1e-3
      light.target.position.x = Math.cos(time) * 10
      light.target.position.z = Math.sin(time) * 10
      light.target.updateWorldMatrix(false, false)
      helper.update()
    })
  }
  {
    const group = new THREE.Group()
    group.visible = false
    scene.add(group)
    const light = new THREE.PointLight()
    light.position.set(0, 10, 0)
    const helper = new THREE.PointLightHelper(light, 5)
    group.add(light)
    group.add(helper)
    const f = pane.addFolder({ title: '点光源' })
    f.addBinding(group, 'visible')
    f.addBinding(new ColorUIHelper(light, 'color'), 'value', { label: 'color' })
    f.addBinding(light, 'intensity', { min: 0, max: 100 })
    loops.push(() => {
      const time = Date.now() * 1e-3
      light.position.x = Math.cos(time) * 10
      light.position.z = Math.sin(time) * 10
      light.updateWorldMatrix(false, false)
      helper.update()
    })
  }

  {
    const group = new THREE.Group()
    const light = new THREE.SpotLight(0xFFFFFF, 120, 30)
    const helper = new THREE.SpotLightHelper(light)

    function updateLight() {
      light.updateMatrixWorld()
      light.target.updateMatrixWorld()
      helper.update()
    }

    // group.add(light.target)
    group.visible = true
    light.position.set(10, 20, 0)
    light.target.position.set(0, 0, 0)

    light.castShadow = true

    scene.add(group)
    group.add(light)
    group.add(light.target)
    group.add(helper)
    updateLight()

    const f = pane.addFolder({ title: '聚光灯' })
    f.addBinding(group, 'visible')
    f.addBinding(new ColorUIHelper(light, 'color'), 'value', { label: 'color' }).on('change', updateLight)
    f.addBinding(light, 'intensity', { min: 0, max: 200 }).on('change', updateLight)
    f.addBinding(light, 'distance', { min: 0, max: 40 }).on('change', updateLight)
    f.addBinding(light, 'angle', { min: 0, max: 2 }).on('change', updateLight)
    f.addBinding(light, 'penumbra', { min: 0, max: 1 }).on('change', updateLight)
    f.addBinding(light, 'decay', { min: 0, max: 10 }).on('change', updateLight)
  }

  function animate() {
    loops.forEach(fn => fn())
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  pane.dispose()

  renderer.dispose()
  renderer.forceContextLoss()
  threeContainerRef.value?.removeChild(renderer.domElement)

  controls.dispose()

  disposeScene(scene)
})
</script>

<template>
  <div ref="threeContainerRef" class="h-100vh" />
</template>

<style></style>
