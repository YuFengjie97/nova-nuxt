<script lang="ts" setup>
import type { Font } from 'three/examples/jsm/Addons.js'
import * as THREE from 'three'
import { FontLoader, MeshSurfaceSampler, OrbitControls, TextGeometry } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

import { ref } from 'vue'
import fragment from './fragment.glsl'
import vertex from './vertex.glsl'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
const loops: Array<(delta: number) => void> = []
const clock = new THREE.Clock()
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
  camera.position.z = 1.5
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

  function animate() {
    const elapsedTime = clock.getElapsedTime()
    uTime.value = elapsedTime

    controls.update()
    const delta = clock.getDelta()
    loops.forEach(fn => fn(delta))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const fontLoader = new FontLoader()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  function surfaceSample(surface: THREE.Mesh, count: number) {
    const position = new Float32Array(count * 3)

    const sampler = new MeshSurfaceSampler(surface)
      .setWeightAttribute(null)
      .build()

    const tempPos = new THREE.Vector3(0, 0, 0)
    for (let i = 0.0; i < count; i++) {
      sampler.sample(tempPos)
      position[i * 3 + 0] = tempPos.x
      position[i * 3 + 1] = tempPos.y
      position[i * 3 + 2] = tempPos.z
    }

    return position
  }

  function getTextMesh(font: Font, txt: string) {
    const fontGeoOp = {
      size: 0.5,
      depth: 0.2,
      curveSegments: 4,
      // bevelEnabled: false,
      // bevelSegments: 6,
      // bevelThickness: 0.01,
      // bevelOffset: 0,
      // bevelSize: 0.02,
    }
    const geo = new TextGeometry(
      txt,
      {
        font,
        ...fontGeoOp,
      },
    )
    geo.center()
    const mat = new THREE.MeshBasicMaterial()
    const mesh = new THREE.Mesh(geo, mat)
    return mesh
  }

  {
    fontLoader.load(`${baseUrl}fonts/typeface/helvetiker_regular.typeface.json`, (font) => {
      // scene.add(mesh)

      const sampleCount = 10000

      const text1 = getTextMesh(font, 'yufengjie')
      const position1 = surfaceSample(text1, sampleCount)
      const text2 = getTextMesh(font, 'GoodLuck')
      const position2 = surfaceSample(text2, sampleCount)

      const pointsGeo = new THREE.BufferGeometry()
      pointsGeo.setAttribute('position', new THREE.BufferAttribute(position1, 3))
      pointsGeo.setAttribute('position1', new THREE.BufferAttribute(position1, 3))
      pointsGeo.setAttribute('position2', new THREE.BufferAttribute(position2, 3))

      // const pointsMat = new THREE.PointsMaterial({size: .01, sizeAttenuation: true})
      const pointsMat = new THREE.ShaderMaterial({
        vertexShader: vertex,
        fragmentShader: fragment,
        uniforms: {
          uTime,
          uDPR: {
            value: renderer.getPixelRatio(),
          },
        },
        depthWrite: false,
        transparent: true,
        blending: THREE.AdditiveBlending,
      })
      const points = new THREE.Points(pointsGeo, pointsMat)
      scene.add(points)
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
