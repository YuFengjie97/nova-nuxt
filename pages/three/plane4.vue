<!-- 几何体取样 -->
<script lang="ts" setup>
// import model from '@/assets/models/character.fbx'
import * as THREE from 'three'
import { MeshSurfaceSampler, OrbitControls } from 'three/examples/jsm/Addons.js'

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
  {
    // 地面
    const geo = new THREE.PlaneGeometry(10000, 10000)
    // const mat = new THREE.MeshLambertMaterial({ color: 'rgb(100,100,100)' })
    const mat = new THREE.MeshPhongMaterial({ color: 'rgb(100,100,100)' })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.y = -30
    mesh.rotation.x = -Math.PI / 2
    mesh.receiveShadow = true
    scene.add(mesh)
  }

  let cube: THREE.Mesh // 取样表面
  const group = new THREE.Group() // cube + 取样结果
  {
    function update() {
      group.rotation.x += 0.01
      group.rotation.y += 0.01
      group.rotation.z += 0.01
    }
    anims.push(update)
    scene.add(group)
  }
  {
    // cube
    const geo = new THREE.BoxGeometry(20, 20, 20, 10, 10, 10)
    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mat = new THREE.MeshPhongMaterial({ color: 0xFFFF00, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    cube = mesh
    group.add(cube)
    mesh.castShadow = true
  }
  {
    // 取样实例"们"
    const vertexCount = cube.geometry.getAttribute('position').count
    let count = 100
    count = count < vertexCount ? count : vertexCount

    const geo = new THREE.SphereGeometry(1)
    // const geo = new THREE.BoxGeometry(2)
    const mat = new THREE.MeshPhongMaterial({ color: 0xFFFFFF })
    const mesh = new THREE.InstancedMesh(geo, mat, count)
    for (let i = 0.0; i < count; i++) {
      const color = new THREE.Vector3(3, 2, 1).add(new THREE.Vector3(i, i, i))
      const r = Math.floor((Math.sin(color.x) * 0.5 + 0.5) * 255)
      const g = Math.floor((Math.sin(color.y) * 0.5 + 0.5) * 255)
      const b = Math.floor((Math.sin(color.z) * 0.5 + 0.5) * 255)

      const c = new THREE.Color(`rgb(${r},${g},${b})`) // 记得取整,rgb只识别整数
      // const c = new THREE.Color(`rgb(255,100,0)`)
      mesh.setColorAt(i, c)
    }
    group.add(mesh)
    // mesh.instanceColor.needsUpdate = true

    const sampler = new MeshSurfaceSampler(cube).setWeightAttribute(null).build()
    const _pos = new THREE.Vector3(0, 0, 0)
    const _nor = new THREE.Vector3(0, 0, 0)
    // const dummy = new THREE.Object3D()
    for (let i = 0.0; i < count; i++) {
      sampler.sample(_pos, _nor)
      const pos = _pos.add(_nor.multiply(new THREE.Vector3(0.1)))

      // 用一个空物体来自动计算变换矩阵
      // dummy.position.copy(pos)
      // dummy.updateMatrix()
      // mesh.setMatrixAt(i, dummy.matrix)

      const matrix = new THREE.Matrix4()
      const scale = Math.random() * 1.0 + 0.5
      matrix.scale(new THREE.Vector3(scale, scale, scale))
      matrix.setPosition(pos)
      mesh.setMatrixAt(i, matrix)
    }
    mesh.castShadow = true
    mesh.instanceMatrix.needsUpdate = true
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
