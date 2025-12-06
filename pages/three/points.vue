<!-- 点云 -->
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
  const control = new OrbitControls(camera, threeContainer.value)
  console.log(control)
  renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap
  threeContainer.value.append(renderer.domElement)

  const anims: Array<() => void> = []
  const textureLoader = new THREE.TextureLoader()

  let time: number

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

  const group = new THREE.Group()
  scene.add(group)
  {
    function update() {
      // group.rotation.x += 0.01
      // group.rotation.y += 0.01
      // group.rotation.z += 0.01
    }
    anims.push(update)
  }

  {
    const vertices: number[] = [] // 初始化顶点位置

    const colors = []
    const geo = new THREE.BufferGeometry()
    const count = 1000
    for (let i = 0; i < count; i++) {
      const x = Math.random() * 100 - 50
      const y = Math.random() * 100 - 50
      const z = Math.random() * 100 - 50
      vertices.push(x, y, z)

      const r = (Math.sin(3 + x) * 0.5 + 0.5)
      const g = (Math.sin(3 + y) * 0.5 + 0.5)
      const b = (Math.sin(3 + z) * 0.5 + 0.5)
      colors.push(r, g, b)
    }

    geo.setAttribute('position', new THREE.Float32BufferAttribute(vertices, 3))
    // geo.setAttribute('position', new THREE.BufferAttribute(new Float32Array(vertices), 3))
    geo.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3))

    const matrix = new THREE.Matrix4()
    const pos = new THREE.Vector3()

    function update() {
      const position = geo.attributes.position.array // 不是修改初始的vertices,而是重新从几何体上获取
      for (let i = 0; i < count; i++) {
        pos.x = vertices[i * 3]
        pos.y = vertices[i * 3 + 1]
        pos.z = vertices[i * 3 + 2]

        const rotDir = i % 2 === 0 ? 1 : -1
        matrix.setPosition(pos).makeRotationY(rotDir * time * 0.001)
        // matrix.makeRotationY(rotDir*time*.001).setPosition(pos)
        pos.applyMatrix4(matrix)
        position[i * 3] = pos.x
        position[i * 3 + 1] = pos.y
        position[i * 3 + 2] = pos.z
      }

      geo.attributes.position.needsUpdate = true
    }
    anims.push(update)

    const texture = textureLoader.load(`${baseUrl}img/texture/particle.png`)
    const mat = new THREE.PointsMaterial({ map: texture, vertexColors: true })
    // const mat = new THREE.MeshPhongMaterial({map: texture, vertexColors: true})
    const points = new THREE.Points(geo, mat)
    group.add(points)
  }

  {
    function animate() {
      time = Date.now()
      anims.forEach(fn => fn())

      renderer.render(scene, camera)
    }
    renderer.setAnimationLoop(animate)
  }
})

onUnmounted(() => {
  renderer.dispose()
  // scene.traverse((child)=>{
  //   if(Object.hasOwn(child, 'dispose')){
  //     child.dispose()
  //   }
  // })
})
</script>

<template>
  <div ref="threeContainer" class="h-100vh" />
</template>

<style></style>
