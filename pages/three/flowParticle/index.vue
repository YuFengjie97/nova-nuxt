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
  camera.position.z = 5.5
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

  const tex_noise = textureLoader.load(`${baseUrl}img/texture/noise/Perlin 6 - 512x512.png`)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  // {
  //   const fog = new THREE.Fog(0x111111, .1, 4)
  //   scene.fog = fog
  // }

  // {
  //   const geo = new THREE.PlaneGeometry(10,10)
  //   const mat = new THREE.MeshBasicMaterial({color: 0xffffff})
  //   const mesh = new THREE.Mesh(geo, mat)
  //   mesh.rotation.x = -Math.PI / 2.;
  //   mesh.position.y = -2.
  //   scene.add(mesh)
  // }

  {
    const geo1 = new THREE.BufferGeometry()
    const count = 20000
    const position = new Float32Array(count * 3)
    for (let i = 0.0; i < count; i++) {
      const x = (Math.random() - 0.5) * 4.0
      const y = (Math.random() - 0.5) * 4.0
      const z = (Math.random() - 0.5) * 4.0
      position[i * 3 + 0] = x
      position[i * 3 + 1] = y
      position[i * 3 + 2] = z
    }
    geo1.setAttribute('position', new THREE.BufferAttribute(position, 3))

    const geo2 = new THREE.SphereGeometry(3, 100, 100)
    const geo3 = new THREE.TorusKnotGeometry(3, 0.3, 200, 50)
    const geo4 = new THREE.BoxGeometry(3, 3, 3, 40, 40, 40)

    let geo: THREE.BufferGeometry = geo1
    let points: THREE.Points

    // console.log(geo.attributes.position.count);

    const mat = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms: {
        uTime,
        uDPR: { value: renderer.getPixelRatio() },
        uNoise: { value: tex_noise },
      },
      transparent: true,
      depthWrite: false,
    })

    function generatePoints() {
      if (points) {
        scene.remove(points)
      }

      points = new THREE.Points(geo, mat)
      scene.add(points)
    }

    generatePoints()

    pane.addBlade({
      view: 'list',
      label: 'Geometry',
      options: [
        { text: '随机顶点BufferGeo', value: geo1 },
        { text: '球', value: geo2 },
        { text: '环面纽结', value: geo3 },
        { text: '正方体', value: geo4 },
      ],
      value: geo1,
      // @ts-ignore
    }).on('change', (ev) => {
      geo = ev.value
      generatePoints()
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

<style></style>
