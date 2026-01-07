<script lang="ts" setup>
import * as THREE from 'three'
import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
import { GLTFLoader, OrbitControls } from 'three/examples/jsm/Addons.js'
import { mergeVertices } from 'three/examples/jsm/utils/BufferGeometryUtils.js'

import { Pane } from 'tweakpane'
import { ref } from 'vue'

import { useEffect } from '~/hooks/useEffect'
import fragment from './fragment.glsl'
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

useEffect(async () => {
  if (!containerRef.value) {
    return
  }

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  const renderer = new THREE.WebGLRenderer({ antialias: false })
  const loops: Array<(delta: number, elapsed: number) => void> = []
  const pane: Pane = new Pane({ container: containerRef.value })
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
  camera.position.z = 7.5
  // camera.position.y = 1.0
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap
  controls.enableDamping = true

  // renderer.outputColorSpace = THREE.SRGBColorSpace
  // renderer.toneMapping = THREE.NoToneMapping
  // renderer.toneMappingExposure = 1.0

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
  const cubeTexLoader = new THREE.CubeTextureLoader(loadingManager).setPath(`${baseUrl}img/texture/env/`)

  const texNoise = textureLoader.load(`${baseUrl}img/texture/noise/Perlin 6 - 512x512.png`)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
    const light = new THREE.AmbientLight()
    scene.add(light)
  }
  {
    const light = new THREE.DirectionalLight()
    light.castShadow = true
    light.position.set(4, 4, 4)
    light.shadow.mapSize.set(1024, 1024)
    scene.add(light)
    scene.add(light.target)

    pane.addBinding(light, 'intensity', { mix: 0.1, max: 10, step: 0.1, label: '光强度' })

    const helper = new THREE.DirectionalLightHelper(light)
    scene.add(helper)

    const shadowCamera = light.shadow.camera
    shadowCamera.far = 20

    const cameraHelper = new THREE.CameraHelper(shadowCamera)
    scene.add(cameraHelper)
  }

  {
    const cubeTexture = cubeTexLoader.load([
      'Standard-Cube-Map/px.png',
      'Standard-Cube-Map/nx.png',
      'Standard-Cube-Map/py.png',
      'Standard-Cube-Map/ny.png',
      'Standard-Cube-Map/pz.png',
      'Standard-Cube-Map/nz.png',
    ])
    scene.background = cubeTexture
  }

  {
    const geo = new THREE.PlaneGeometry(30, 20)
    const mat = new THREE.MeshStandardMaterial()
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.x = -Math.PI / 2.0
    mesh.position.y = -4
    mesh.receiveShadow = true
    scene.add(mesh)
  }

  {
    let geo: THREE.BufferGeometry = new THREE.IcosahedronGeometry(2, 50)
    geo = mergeVertices(geo)
    geo.computeTangents()

    const uniforms = {
      uTime,
      uDeltaTime,
      uNoisePosFre: new THREE.Uniform(1.0),
      uNoiseSpeed: new THREE.Uniform(1.0),
      uNoiseStrength: new THREE.Uniform(0.3),
      uWrapNoisePosFre: new THREE.Uniform(1.0),
      uWrapNoiseSpeed: new THREE.Uniform(1.0),
      uWrapNoiseStrength: new THREE.Uniform(0.3),
      uColorA: new THREE.Uniform(new THREE.Color(0x0000FF)),
      uColorB: new THREE.Uniform(new THREE.Color(0xFF0000)),
    }

    pane.addBinding(uniforms.uNoisePosFre, 'value', { min: 0.1, max: 3.0, step: 0.001, label: 'uNoisePosFre' })
    pane.addBinding(uniforms.uNoiseSpeed, 'value', { min: 0.1, max: 10.0, step: 0.001, label: 'uNoiseSpeed' })
    pane.addBinding(uniforms.uNoiseStrength, 'value', { min: 0.1, max: 3.0, step: 0.001, label: 'uNoiseStrength' })

    pane.addBinding(uniforms.uWrapNoisePosFre, 'value', { min: 0.1, max: 3.0, step: 0.001, label: 'uWrapNoisePosFre' })
    pane.addBinding(uniforms.uWrapNoiseSpeed, 'value', { min: 0.1, max: 10.0, step: 0.001, label: 'uWrapNoiseSpeed' })
    pane.addBinding(uniforms.uWrapNoiseStrength, 'value', { min: 0.1, max: 3.0, step: 0.001, label: 'uWrapNoiseStrength' })

    pane.addBinding(uniforms.uColorA, 'value', { color: { type: 'float' }, label: 'uColA' })
    pane.addBinding(uniforms.uColorB, 'value', { color: { type: 'float' }, label: 'uColB' })

    const mat = new CustomShaderMaterial<typeof THREE.MeshPhysicalMaterial>({
      baseMaterial: THREE.MeshPhysicalMaterial,
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms,
      metalness: 0,
      roughness: 0.0,
      // color: 0xff0000,
      ior: 1.5, // 非金属材料折射率
      thickness: 0.5, // 材质厚度(透明时)
      clearcoat: 0.0, // 清漆
      clearcoatRoughness: 0.0, // 清漆粗糙度
      transparent: false,
      transmission: 1.0, // 透射率
      wireframe: false,
    })

    pane.addBinding(mat, 'wireframe')
    pane.addBinding(mat, 'metalness', { min: 0, max: 1, step: 0.1 })
    pane.addBinding(mat, 'roughness', { min: 0, max: 1, step: 0.1 })
    pane.addBinding(mat, 'transparent')
    pane.addBinding(mat, 'transmission', { min: 0, max: 1, step: 0.1 })
    pane.addBinding(mat, 'thickness', { min: 0, max: 4, step: 0.1 })
    pane.addBinding(mat, 'ior', { min: 0, max: 2.3, step: 0.1 })

    const depthMat = new CustomShaderMaterial<typeof THREE.MeshDepthMaterial>({
      baseMaterial: THREE.MeshDepthMaterial,
      vertexShader: vertex,
      uniforms,
      depthPacking: THREE.RGBADepthPacking,
    })

    const mesh = new THREE.Mesh(geo, mat)
    mesh.customDepthMaterial = depthMat
    mesh.castShadow = true
    scene.add(mesh)
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
  <div ref="containerRef" class="w-full h-100vh relative three-con" @mousemove="upadteMouse" />
</template>

<style lang='less' scoped>
.three-con {
  ::v-deep .tp-rotv {
    position: absolute;
    top: 0;
    right: 0;
    width: 300px;
  }
}
</style>
