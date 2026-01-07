/**
逼真渲染
renderer开启tonemapping
物体环境贴图
阴影的控制
*/

<script lang="ts" setup>
import * as THREE from 'three'
import { GLTFLoader, OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

import { ref } from 'vue'
import { useEffect } from '~/hooks/useEffect'

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
  const renderer = new THREE.WebGLRenderer({ antialias: true })
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
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  controls.enableDamping = true

  renderer.outputColorSpace = THREE.SRGBColorSpace
  renderer.toneMapping = THREE.NoToneMapping
  renderer.toneMappingExposure = 2.0

  pane.addBlade({
    view: 'list',
    label: 'toneMapping',
    options: [
      { text: 'no', value: THREE.NoToneMapping },
      { text: 'cineon', value: THREE.CineonToneMapping },
      { text: 'custom', value: THREE.CustomToneMapping },
      { text: 'linear', value: THREE.LinearToneMapping },
      { text: 'neutral', value: THREE.NeutralToneMapping },
      { text: 'reinhard', value: THREE.ReinhardToneMapping },
      { text: 'aces', value: THREE.ACESFilmicToneMapping },
    ],
    value: THREE.NoToneMapping,
  })
  // @ts-ignore
    .on('change', (ev) => {
      renderer.toneMapping = ev.value
    })
  pane.addBinding(renderer, 'toneMappingExposure', { min: 0.1, max: 10, step: 0.1 })

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
    // light.intensity = 100
    light.position.set(4, 2, 0)
    light.shadow.mapSize.set(1024, 1024)
    /*
    光滑曲面的几何体,同时设置castShadow 和 receiveShadow,
    该面即会产生阴影,也会接受阴影,又因为是光滑曲面的原因,会在表面产生伪影(一小块一小块,又或者是一行又一行)
    也就是阴影和mesh表面重叠
    这个属性相当于将阴影沿着法线做细微偏移,让阴影贴图不再跟表面重叠,或者说是阴影不会在该表面产生阴影
    */
    light.shadow.normalBias = 0.05
    scene.add(light)

    const shadowCamera = light.shadow.camera
    shadowCamera.far = 20

    const helper = new THREE.DirectionalLightHelper(light)
    scene.add(helper)

    const cameraHelper = new THREE.CameraHelper(shadowCamera)
    scene.add(cameraHelper)

    pane.addBinding(light, 'intensity', { min: 0.1, max: 10, step: 0.1, label: 'light强度' })
    pane.addBinding(light, 'position', { label: 'light位置' }).on('change', () => {
      helper.update()
    })
  }
  {
    const geo = new THREE.PlaneGeometry(15, 25)
    const mat = new THREE.MeshPhongMaterial()
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.y = Math.PI / 2.0
    mesh.position.x = -4
    mesh.receiveShadow = true
    scene.add(mesh)
  }

  const cubeTexture = cubeTexLoader.load([
    'photo_studio_loft_hall_1k/px.png',
    'photo_studio_loft_hall_1k/nx.png',
    'photo_studio_loft_hall_1k/py.png',
    'photo_studio_loft_hall_1k/ny.png',
    'photo_studio_loft_hall_1k/pz.png',
    'photo_studio_loft_hall_1k/nz.png',
  ])
  scene.background = cubeTexture

  {
    const model = await gltfloader.loadAsync(`${baseUrl}model/2010_subaru_impreza_wrx_sti/scene.gltf`).then(res => res.scene)
    scene.add(model)

    const params = {
      intensity: 1,
      showEnvMap: true,
    }

    function updateModelMat() {
      const { intensity, showEnvMap } = params
      model.traverse((obj) => {
        if (obj instanceof THREE.Mesh && obj.material instanceof THREE.MeshStandardMaterial) {
          obj.castShadow = true
          obj.receiveShadow = true
          obj.material.envMap = showEnvMap ? cubeTexture : null
          obj.material.envMapIntensity = intensity
        }
      })
    }
    updateModelMat()

    pane.addBinding(params, 'intensity', { min: 0.1, max: 10, step: 0.1 }).on('change', ev => updateModelMat())
    pane.addBinding(params, 'showEnvMap').on('change', ev => updateModelMat())

    // const geo = new THREE.SphereGeometry(2)
    // const mat = new THREE.MeshStandardMaterial()
    // const mesh = new THREE.Mesh(geo, mat)
    // scene.add(mesh)
    // mesh.castShadow = true
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
  .three-con{
    ::v-deep .tp-rotv{
      position: absolute;
      top: 0;
      right: 0;
      width: 300px;
    }
  }
</style>
