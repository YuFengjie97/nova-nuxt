<!-- 几何体取样 -->
<script lang="ts" setup>
// import model from '@/assets/models/character.fbx'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const threeContainer = ref<HTMLElement>()
// const noise2D = createNoise2D()
// const noise3D = createNoise3D()

let renderer: THREE.WebGLRenderer
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera

onMounted(() => {
  if (!threeContainer.value) {
    return
  }
  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.z = -50
  camera.position.y = 10

  camera.lookAt(new THREE.Vector3(0, 0, 0))
  renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap
  threeContainer.value.append(renderer.domElement)
  {
    // 坐标系helper
    const helper = new THREE.AxesHelper(10000)
    scene.add(helper)
  }

  {
    // 平行光
    const light = new THREE.DirectionalLight(0xFFFFFF, 1.5)
    light.position.set(20, 20, -10)
    light.target.position.set(0, 0, 0)
    light.castShadow = true
    scene.add(light)
    const helper = new THREE.DirectionalLightHelper(light, 20)
    scene.add(helper)
  }
  {
    // 半球光
    const light = new THREE.HemisphereLight('rgb(255,255,255)')
    light.position.set(-40, 30, 20)
    // light.castShadow = true
    scene.add(light)
    const helper = new THREE.HemisphereLightHelper(light, 10)
    scene.add(helper)
  }

  const control = new OrbitControls(camera, threeContainer.value)
  console.log(control)

  const anims: Array<() => void> = []

  // const time = Date.now()

  let map_grid_opengl: THREE.Texture
  {
    const map = new THREE.TextureLoader().load(`${baseUrl}img/texture/uv_grid_opengl.jpg`)
    map_grid_opengl = map
    map.wrapS = map.wrapT = THREE.RepeatWrapping
    map.anisotropy = 16
    map.colorSpace = THREE.SRGBColorSpace
  }
  {
    // 地面
    const geo = new THREE.PlaneGeometry(200, 200, 2, 2)
    // const mat = new THREE.MeshLambertMaterial({ color: 'rgb(100,100,100)' })
    const mat = new THREE.MeshLambertMaterial({ map: map_grid_opengl })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.y = -30
    mesh.rotation.x = -Math.PI / 2
    mesh.receiveShadow = true
    scene.add(mesh)
  }

  let cube: THREE.Mesh
  const group = new THREE.Group()
  {
    function update() {
      // group.rotation.x += 0.01
      // group.rotation.y += 0.01
      // group.rotation.z += 0.01
    }
    anims.push(update)
    scene.add(group)
  }

  {
    // cube
    const geo = new THREE.BoxGeometry(20, 20, 20, 10, 10, 10)

    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mat = new THREE.MeshPhongMaterial({ map: map_grid_opengl, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    cube = mesh
    group.add(cube)
    mesh.castShadow = true
  }

  {
    function animate() {
      anims.forEach(fn => fn())

      renderer.render(scene, camera)
    }
    renderer.setAnimationLoop(animate)
  }
})

onUnmounted(() => {
  renderer.dispose()
})
</script>

<template>
  <div ref="threeContainer" class="h-100vh" />
</template>

<style></style>
