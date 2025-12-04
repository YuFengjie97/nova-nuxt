<!-- 定义顶点,cpu计算,定义三角形顶点索引,好像算错了 -->
<script lang="ts" setup>
import { createNoise2D } from 'simplex-noise'
// import model from '@/assets/models/character.fbx'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'

const threeContainer = ref<HTMLElement>()
const noise2D = createNoise2D()
// const noise3D = createNoise3D()

onMounted(() => {
  if (!threeContainer.value) {
    return
  }
  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.z = -60
  camera.position.y = 10

  camera.lookAt(new THREE.Vector3(0, 0, 0))
  const renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  threeContainer.value.append(renderer.domElement)

  const dirLig = new THREE.DirectionalLight(0xFFFFFF, 1.5)
  dirLig.position.set(10, 10, 10)
  dirLig.target.position.set(0, 0, 0)
  scene.add(dirLig)
  // scene.add(dirLig.target)

  const control = new OrbitControls(camera, threeContainer.value)
  console.log(control)

  const planeSize = { x: 100, y: 100 }
  const sampleSize = { x: 20, y: 20 }
  const vertexs: Float32Array = new Float32Array(sampleSize.x * sampleSize.y * 3)
  function updateVertexs() {
    const time = Date.now() * 0.001
    for (let x = 0; x < sampleSize.x; x++) {
      for (let y = 0; y < sampleSize.y; y++) {
        const p = { x: planeSize.x / sampleSize.x * x, y: planeSize.y / sampleSize.y * y }
        p.x -= planeSize.x / 2
        p.y -= planeSize.y / 2

        const height = noise2D(p.x * 0.1, p.y * 0.1 + (time % 60)) * 5.0

        const ind = x * sampleSize.y + y
        vertexs[ind * 3] = p.x
        vertexs[ind * 3 + 1] = p.y
        vertexs[ind * 3 + 2] = height
      }
    }
  }
  // const inds = new Uint16Array(sampleSize.x * sampleSize.y * 2)
  const inds: number[] = []
  // 设置三角形顶点索引
  /**
   * y
   * ^
   * |__>x
   *
   * b--c
   * | /|
   * |/ |
   * a--d
   */

  function initInd() {
    for (let x = 0; x < sampleSize.x; x++) {
      for (let y = 0; y < sampleSize.y; y++) {
        const a = x * sampleSize.y + y
        const b = a + 1 // x * sampleSize.y + y + 1
        const c = (x + 1) * sampleSize.y + y
        const d = c - 1 // (x + 1) * sampleSize.y + y - 1
        inds.push(a, b, c)
        inds.push(c, d, a)
      }
    }
  }
  updateVertexs()
  initInd()

  {
    const geo = new THREE.BoxGeometry(8, 8, 8)
    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mat = new THREE.MeshPhongMaterial({ color: 0xFFFF00, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
  }

  {
    const geo = new THREE.BufferGeometry()
    geo.setAttribute('position', new THREE.BufferAttribute(vertexs, 3)) // 设置顶点位置
    geo.setIndex(inds) // 设置三角形图元的顶点索引
    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(100,100,0)', side: THREE.DoubleSide })
    const mat = new THREE.MeshPhongMaterial({ color: 0xFF0000, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    // const mesh = new THREE.Plane(geo, mat)
    // const helper = new THREE.PlaneHelper(mesh, 1, 0xFFFF00)
    // scene.add(helper)
    mesh.rotation.x = -Math.PI / 2.0
    mesh.position.y = -2.0

    scene.add(mesh)

    function animate() {
      updateVertexs()
      mesh.geometry.computeVertexNormals()
      mesh.geometry.attributes.position.needsUpdate = true

      renderer.render(scene, camera)
    }
    renderer.setAnimationLoop(animate)
  }
})
</script>

<template>
  <div ref="threeContainer" class="h-100vh" />
</template>

<style>

</style>
