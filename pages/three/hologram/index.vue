<script lang="ts" setup>
import * as THREE from 'three'
import { GLTFLoader, OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

import { ref } from 'vue'
import fragment from './fragment.glsl'
import vertex from './vertex.glsl'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
const loops: Array<(delta: number, elapsed: number) => void> = []
let pane: Pane
let controls: OrbitControls

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
  camera.position.z = 3.5
  // camera.position.y = 1.0
  renderer = new THREE.WebGLRenderer()
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  // renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap

  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true

  handleResize()
  window.addEventListener('resize', handleResize)

  const uTime = {
    value: 0.0,
  }

  const clock = new THREE.Clock()
  const clock2 = new THREE.Clock()
  function animate() {
    const elapsedTime = clock.getElapsedTime()
    uTime.value = elapsedTime

    controls.update()
    const delta = clock2.getDelta()
    loops.forEach(fn => fn(delta, elapsedTime))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const gltfloader = new GLTFLoader(loadingManager)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight()
    light.intensity = 10
    scene.add(light)
  }

  const tex_mat = textureLoader.load(`${baseUrl}img/texture/matcap/3B6E10_E3F2C3_88AC2E_99CE51.png`)

  // const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
  // const mat = new THREE.MeshMatcapMaterial()
  // mat.matcap = tex_mat

  const mat = new THREE.ShaderMaterial(
    {
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms: {
        uTime,
        uColor: {
          value: new THREE.Color(0, 1, 0),
        },
      },
      transparent: true,
      side: THREE.DoubleSide,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    },
  )

  pane.addBinding(mat.uniforms.uColor, 'value', { color: { type: 'float' } })

  {
    const geo = new THREE.PlaneGeometry(10, 10)
    const mat = new THREE.MeshBasicMaterial({ color: 0x4477BB })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.z = -4
    scene.add(mesh)
  }

  {
    const geo = new THREE.BoxGeometry(1, 1, 1, 64, 64, 64)
    // const geo = new THREE.SphereGeometry()
    const mesh = new THREE.Mesh(geo, mat)
    mesh.position.x = -2
    scene.add(mesh)

    loops.push((delta) => {
      mesh.rotation.x += delta * 0.2
      mesh.rotation.y += delta * 0.2
    })
  }

  {
    gltfloader.load(`${baseUrl}model/skull_downloadable/scene.gltf`, (gltf) => {
      // console.log(gltf)

      gltf.scene.traverse((obj) => {
        // @ts-ignore
        if (obj.isMesh) {
          const mesh = obj as THREE.Mesh
          mesh.material = mat
        }
      })

      loops.push((delta, elapsed) => {
        gltf.scene.rotation.x += delta * 0.1
        gltf.scene.rotation.y += delta * 0.1

        gltf.scene.position.y = Math.sin(elapsed * 0.1) * 1.0
      })

      scene.add(gltf.scene)
    })
  }

  {
    const geo = new THREE.TorusKnotGeometry(1, 0.4, 200, 64)
    geo.scale(0.6, 0.6, 0.6)
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
    mesh.position.x = 2

    loops.push((delta) => {
      mesh.rotation.x += delta * 0.1
      mesh.rotation.y += delta * 0.1
    })
  }
})

onUnmounted(() => {
  controls.dispose()

  renderer.dispose()
  renderer.forceContextLoss()
  disposeScene(scene)
  pane.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="w-full h-100vh" />
</template>

<style lang='less' scoped>
</style>
