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
  camera.position.z = 4
  camera.position.y = 2
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

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)

  {
    const light = new THREE.AmbientLight()
    scene.add(light)
  }
  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  {
    const tex_particle = textureLoader.load(`${baseUrl}img/texture/particle/star_09.png`)

    // const geo = new THREE.SphereGeometry(1)
    const geo = new THREE.BufferGeometry()

    const count = 4000
    const position = new Float32Array(count * 3)
    const color = new Float32Array(count * 3)
    for (let i = 0; i < position.length; i++) {
      position[i] = Math.random() * 10 - 5
      color[i] = Math.random()
    }
    geo.setAttribute('position', new THREE.BufferAttribute(position, 3))
    geo.setAttribute('color', new THREE.BufferAttribute(color, 3))

    const mat = new THREE.PointsMaterial()
    // mat.color.set(0x992255)
    mat.vertexColors = true
    mat.size = 0.1
    mat.sizeAttenuation = true
    // mat.map = tex_particle  //完整保留材质

    /**
     * 粒子是按照创建顺序绘制,而不是位置绘制
     * 所以会有某些粒子明明处于当前粒子(相机最近粒子)的透明部分,却没有绘制
     */
    mat.transparent = true
    mat.alphaMap = tex_particle

    // mat.alphaTest = 0.001

    /**
     * 关闭深度测试,处于粒子后(相对相机而言)的粒子也会被完整绘制
     * 但是如果场景中有其他物体,缺点很明显,粒子明明被遮挡,却还是被绘制
     */
    // mat.depthTest = false

    /**
     * 这可能就是最好的方法了,(前提depthTest = true),透明物体
     */
    mat.depthWrite = false

    mat.blending = THREE.AdditiveBlending

    const points = new THREE.Points(geo, mat)
    scene.add(points)

    loops.push(() => {
      const t = clock.getElapsedTime()
      for (let i = 0; i < count; i++) {
        const i3 = i * 3
        const x = position[i3]
        position[i3 + 1] = Math.sin(t + x)
        // position[i3 + 2] = Math.cos(t + x)
      }
      geo.attributes.position.needsUpdate = true
    })
  }

  {
    const geo = new THREE.BoxGeometry()
    const mat = new THREE.MeshBasicMaterial()
    const mesh = new THREE.Mesh(geo, mat)
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

<style>

</style>
