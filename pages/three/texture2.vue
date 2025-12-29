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
  renderer = new THREE.WebGLRenderer()
  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))

  handleResize()
  window.addEventListener('resize', handleResize)

  const loadingManager = new THREE.LoadingManager()
  loadingManager.onStart = () => {
    console.log('start')
  }
  loadingManager.onProgress = () => {
    console.log('progress')
  }
  loadingManager.onError = (e) => {
    console.log('error', e)
  }
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const tex_amb = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_ambientOcclusion.jpg`)
  const tex_base = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_basecolor.jpg`)
  const tex_height = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_height.png`)
  const tex_metallic = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_metallic.jpg`)
  const tex_normal = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_normal.jpg`)
  const tex_opacity = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_opacity.jpg`)
  const tex_roughness = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_roughness.jpg`)

  const tex_matcap_1 = textureLoader.load(`${baseUrl}img/texture/matcap/6A3C15_EFC898_D59D59_B38346.png`)
  const tex_matcap_2 = textureLoader.load(`${baseUrl}img/texture/matcap/5E5855_C6C4CD_C89B67_8F8E98.png`)
  const tex_matcap_3 = textureLoader.load(`${baseUrl}img/texture/matcap/2A2A2A_B3B3B3_6D6D6D_848C8C.png`)

  tex_base.repeat.x = 1
  tex_base.repeat.y = 1
  tex_base.wrapS = THREE.RepeatWrapping
  tex_base.wrapT = THREE.RepeatWrapping
  // tex_base.center.x = .5
  // tex_base.center.y = .5
  // tex_base.rotation = Math.PI / 4;
  tex_base.generateMipmaps = false
  tex_base.minFilter = THREE.NearestFilter
  tex_base.magFilter = THREE.NearestFilter

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight(0xFFFFFF, 1)
    scene.add(light)
  }
  {
    const light = new THREE.HemisphereLight()
    light.intensity = 4
    // scene.add(light)
  }
  {
    const light = new THREE.PointLight()
    light.position.set(4, 0, 4)
    light.intensity = 20
    scene.add(light)
  }
  // const mat = new THREE.MeshPhongMaterial({map: tex_matcap_3})

  // const mat = new THREE.MeshMatcapMaterial()
  // mat.matcap = tex_matcap_3

  // const mat = new THREE.MeshNormalMaterial()
  // mat.flatShading = true

  // const mat = new THREE.MeshDepthMaterial()

  const mat = new THREE.MeshStandardMaterial()
  mat.roughness = 0
  mat.metalness = 1
  mat.map = tex_base
  mat.aoMap = tex_amb
  mat.aoMapIntensity = 2.0
  mat.displacementMap = tex_height
  mat.displacementScale = 0.1
  // mat.wireframe = true
  mat.roughnessMap = tex_roughness
  mat.metalnessMap = tex_metallic
  mat.normalMap = tex_normal
  mat.normalScale.set(1, 1)
  mat.transparent = true
  mat.alphaMap = tex_opacity

  pane.addBinding(mat, 'roughness', { min: 0, max: 1, step: 0.01 })
  pane.addBinding(mat, 'metalness', { min: 0, max: 1, step: 0.01 })
  pane.addBinding(mat, 'aoMapIntensity', { min: 0, max: 10, step: 0.1 })
  pane.addBinding(mat, 'displacementScale', { min: 0, max: 1, step: 0.01 })

  const loader = new THREE.CubeTextureLoader(loadingManager).setPath(`${baseUrl}img/texture/env/`)
  const cubeTexture = loader.load([
    'Standard-Cube-Map/px.png',
    'Standard-Cube-Map/nx.png',
    'Standard-Cube-Map/py.png',
    'Standard-Cube-Map/ny.png',
    'Standard-Cube-Map/pz.png',
    'Standard-Cube-Map/nz.png',
  ])

  mat.envMap = cubeTexture
  scene.background = cubeTexture

  {
    const geo = new THREE.SphereGeometry(1, 64, 64)
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.x = -3
    // loops.push(() => {
    //   const t = clock.getElapsedTime()
    //   mesh.rotation.x = t
    //   mesh.rotation.y = t
    // })
    scene.add(mesh)
  }
  {
    const geo = new THREE.PlaneGeometry(2, 2, 100, 100)
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
  }
  {
    const geo = new THREE.TorusGeometry(1, 0.4, 64, 64)
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.x = 3
    scene.add(mesh)
  }

  function animate() {
    loops.forEach(fn => fn())
    controls.update()
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)
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

<style lang='less' scoped>
</style>
