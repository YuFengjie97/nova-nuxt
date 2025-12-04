<script lang="ts" setup>
import { createNoise3D } from 'simplex-noise'
// import model from '@/assets/models/character.fbx'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'

const threeContainer = ref<HTMLElement>()
// const noise2D = createNoise2D()
const noise3D = createNoise3D()

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

  {
    const dirLig = new THREE.DirectionalLight(0xFFFFFF, 1.5)
    dirLig.position.set(10, 10, 10)
    dirLig.target.position.set(0, 0, 0)
    scene.add(dirLig)
  }
  {
    const dirLig = new THREE.DirectionalLight(0xFFFFFF, 1.5)
    dirLig.position.set(10, -10, 10)
    dirLig.target.position.set(0, 0, 0)
    scene.add(dirLig)
  }
  // scene.add(dirLig.target)

  const control = new OrbitControls(camera, threeContainer.value)
  console.log(control)

  const planeSize = { x: 100, y: 100 }
  const sampleSize = { x: 50, y: 50 }

  {
    const geo = new THREE.BoxGeometry(8, 8, 8)
    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mat = new THREE.MeshPhongMaterial({ color: 0xFFFF00, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
  }

  {
    const geo = new THREE.PlaneGeometry(planeSize.x, planeSize.y, sampleSize.x, sampleSize.y)
    const mat = new THREE.MeshPhongMaterial({ color: 0xFF00FF, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    // const mesh = new THREE.Plane(geo, mat)
    // const helper = new THREE.PlaneHelper(mesh, 1, 0xFFFF00)
    // scene.add(helper)

    const positions = geo.attributes.position.array
    const total = positions.length / 3

    function updatePositions() {
      const time = Date.now() * 0.001
      for (let i = 0; i < total; i++) {
        const x = positions[i * 3]
        const y = positions[i * 3 + 1]
        // const z = positions[i*3+2]
        const zOff = noise3D(x * 0.1, y * 0.1, time % 60) * 4

        positions[i * 3 + 2] = zOff
      }
      mesh.geometry.attributes.position.needsUpdate = true
      mesh.geometry.computeVertexNormals()
    }

    mesh.rotation.x = -Math.PI / 2.0
    mesh.position.y = -2.0

    scene.add(mesh)

    function animate() {
      updatePositions()
      // mesh.geometry.attributes.position.needsUpdate = true
      // mesh.geometry.computeVertexNormals()
      // mesh.geometry.computeBoundingBox()
      // mesh.geometry.computeBoundingSphere()

      renderer.render(scene, camera)
    }
    renderer.setAnimationLoop(animate)
  }
})
</script>

<template>
  <div ref="threeContainer" class="h-100vh" />
</template>

<style></style>
