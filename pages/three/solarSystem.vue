<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

const threeContainer = ref<HTMLElement>()

let camera: THREE.PerspectiveCamera
let scene: THREE.Scene
let renderer: THREE.WebGLRenderer

const loops: Array<() => void> = []

class AxisGridHelper {
  _visable = false
  node: THREE.Object3D
  axisHelper: THREE.AxesHelper
  gridHelper: THREE.GridHelper
  constructor(node: THREE.Object3D) {
    const axisHelper = new THREE.AxesHelper(4)
    const gridHelper = new THREE.GridHelper(4, 4)
    axisHelper.material.depthTest = false
    gridHelper.material.depthTest = false
    axisHelper.renderOrder = 2
    gridHelper.renderOrder = 1
    node.add(axisHelper)
    node.add(gridHelper)
    this.node = node
    this.axisHelper = axisHelper
    this.gridHelper = gridHelper
    this.visable = false
  }

  addPane(pane: Pane, label: string) {
    pane.addBinding(this, '_visable', { label }).on('change', (ev) => {
      this.visable = ev.value
    })
  }

  get visable() {
    return this._visable
  }

  set visable(visable: boolean) {
    this._visable = visable
    this.gridHelper.visible = visable
    this.axisHelper.visible = visable
  }
}

let pane: Pane
onMounted(() => {
  pane = new Pane()
  if (!threeContainer.value) {
    return
  }

  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.set(0, 20, 0)
  camera.lookAt(new THREE.Vector3(0, 0, 0))
  scene = new THREE.Scene()
  renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  threeContainer.value.append(renderer.domElement)

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
  const publicGeo = new THREE.SphereGeometry(1, 6, 6)
  // 太阳
  {
    const sun = new THREE.Mesh(publicGeo, new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' }))
    sun.scale.set(5, 5, 5)
    scene.add(sun)

    // 地球轨道和地球
    const earthOrbit = new THREE.Group()
    scene.add(earthOrbit)
    loops.push(() => {
      earthOrbit.rotation.y += 0.01
    })
    const earth = new THREE.Mesh(publicGeo, new THREE.MeshBasicMaterial({ color: 'rgb(0,255,255)' }))
    earth.position.x = 10.0
    earthOrbit.add(earth)

    // 月球轨道和月球
    const moonOrbit = new THREE.Group()
    earth.add(moonOrbit)
    loops.push(() => {
      moonOrbit.rotation.y += 0.1
    })
    const moon = new THREE.Mesh(publicGeo, new THREE.MeshBasicMaterial({ color: 'rgb(100,100,100)' }))
    moon.scale.set(0.5, 0.5, 0.5)
    moon.position.x = 4
    moonOrbit.add(moon)

    // helper
    {
      new AxisGridHelper(sun).addPane(pane, '太阳')
      new AxisGridHelper(earth).addPane(pane, '地球')
      new AxisGridHelper(earthOrbit).addPane(pane, '地球轨道')
      new AxisGridHelper(moon).addPane(pane, '月球')
      new AxisGridHelper(moonOrbit).addPane(pane, '月球轨道')
    }
  }

  window.onresize = () => {
    const { width, height } = threeContainer.value!.getBoundingClientRect()
    camera.aspect = width / height
    camera.updateProjectionMatrix()
    renderer.setSize(width, height)
  }

  function animate() {
    loops.forEach(fn => fn())
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)
})

onUnmounted(() => {
  pane.dispose()
  renderer.dispose()
})
</script>

<template>
  <div class="w-100vw h-100vh">
    <div ref="threeContainer" class="w-100vw h-100vh" />
  </div>
</template>

<style>

</style>
