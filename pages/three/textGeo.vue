<script lang="ts" setup>
import * as THREE from 'three'
import { FontLoader, OrbitControls, TextGeometry } from 'three/examples/jsm/Addons.js'
import { ref } from 'vue'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
const loops: Array<() => void> = []
const clock = new THREE.Clock()

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

  function animate() {
    loops.forEach(fn => fn())
    controls.update()
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const textureLoader = new THREE.TextureLoader()
  const tex_matcap = textureLoader.load(`${baseUrl}img/texture/matcap/3B6E10_E3F2C3_88AC2E_99CE51.png`)
  const tex_matcap2 = textureLoader.load(`${baseUrl}img/texture/matcap/8A6565_2E214D_D48A5F_ADA59C.png`)

  const mat = new THREE.MeshMatcapMaterial()
  mat.matcap = tex_matcap

  const mat2 = new THREE.MeshMatcapMaterial()
  mat2.matcap = tex_matcap2

  const fontLoader = new FontLoader()
  fontLoader.load(
    `${baseUrl}fonts/typeface/helvetiker_regular.typeface.json`,
    (font) => {
      const geo = new TextGeometry('Good Luck,yfj', {
        font,
        size: 1.0,
        depth: 0.5,
        curveSegments: 12,
        bevelEnabled: true,
        bevelSegments: 6,
        bevelThickness: 0.01,
        bevelOffset: 0,
        bevelSize: 0.02,
      })

      // geo.computeBoundingBox()
      // geo.translate(
      //   -geo.boundingBox!.max.x / 2.0,
      //   -geo.boundingBox!.max.y / 2.0,
      //   -geo.boundingBox!.max.z / 2.0,
      // )

      geo.center()

      // const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
      // mat.wireframe = true
      const mesh = new THREE.Mesh(geo, mat2)
      scene.add(mesh)
    },
  )

  {
    const geo = new THREE.TorusGeometry(1, 0.4)
    const group = new THREE.Group()
    scene.add(group)

    loops.push(() => {
      const t = clock.getElapsedTime() * 0.1
      group.rotation.x = t
      group.rotation.y = t
    })

    for (let i = 0.0; i < 300; i++) {
      const mesh = new THREE.Mesh(geo, mat)
      group.add(mesh)
      mesh.position.x = Math.random() * 40 - 20
      mesh.position.y = Math.random() * 40 - 20
      mesh.position.z = Math.random() * 40 - 20

      const rx = Math.random() * 6
      const ry = Math.random() * 6

      loops.push(() => {
        const t = clock.getElapsedTime()
        mesh.rotation.x = t + rx
        mesh.rotation.y = t + ry
      })

      const scale = Math.random() * 0.6 + 0.4
      mesh.scale.set(scale, scale, scale)
    }
  }
})

onUnmounted(() => {
  renderer.dispose()
  renderer.forceContextLoss()
  controls.dispose()
  disposeScene(scene)
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh" />
</template>

<style lang='less' scoped>
</style>
