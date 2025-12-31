<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'
import { ref } from 'vue'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
const loops: Array<() => void> = []
const clock = new THREE.Clock()
let pane: Pane

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
  camera.position.z = 8
  camera.position.y = 2
  renderer = new THREE.WebGLRenderer()
  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap

  handleResize()
  window.addEventListener('resize', handleResize)

  function animate() {
    loops.forEach(fn => fn())
    controls.update()
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const tex_particle = textureLoader.load(`${baseUrl}img/texture/particle/star_09.png`)
  tex_particle.generateMipmaps = false
  tex_particle.minFilter = THREE.NearestFilter
  tex_particle.magFilter = THREE.NearestFilter

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  const params = {
    count: 15000,
    radius: 6,
    branch: 5,
    spin: 0.4,
    randomness: 1,
    randomnessPower: 4,
    size: 0.06,
    innerColor: 0xE14038,
    outerColor: 0x40BEF5,
  }
  let geo: THREE.BufferGeometry
  let mat: THREE.PointsMaterial
  let points: THREE.Points

  generateGalaxy()

  pane.addBinding(params, 'count', { min: 1000, max: 100000, step: 1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'radius', { min: 4, max: 10, step: 0.1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'branch', { min: 2, max: 10, step: 1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'spin', { min: -3, max: 3, step: 0.1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'randomness', { min: 0, max: 3, step: 0.1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'randomnessPower', { min: 0.1, max: 10, step: 0.1 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'size', { min: 0.01, max: 0.2, step: 0.01 })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'innerColor', { view: 'color' })
    .on('change', generateGalaxy)
  pane.addBinding(params, 'outerColor', { view: 'color' })
    .on('change', generateGalaxy)

  function generateGalaxy() {
    if (points) {
      geo.dispose()
      mat.dispose()
      scene.remove(points)
    }

    const { count, radius, branch, spin, randomness, randomnessPower, size, innerColor, outerColor } = params

    geo = new THREE.BufferGeometry()
    mat = new THREE.PointsMaterial({
      size,
      sizeAttenuation: true,
      depthWrite: false,
      transparent: true,
      alphaMap: tex_particle,
      blending: THREE.AdditiveBlending,
      vertexColors: true,
    })

    const position = new Float32Array(count * 3)
    const color = new Float32Array(count * 3)
    const col_inner = new THREE.Color(innerColor)
    const col_outer = new THREE.Color(outerColor)

    for (let i = 0.0; i < count; i++) {
      const angle = (i % branch) / branch * Math.PI * 2
      const i3 = i * 3
      const r = Math.random() * radius // 半径范围随机分布
      // 分支与扭曲旋转
      position[i3] = Math.cos(angle + r * spin) * r
      position[i3 + 1] = r
      position[i3 + 2] = Math.sin(angle + r * spin) * r

      // 范围围绕中心(轴心初始位置)随机偏移
      const offx = (Math.random() * randomness) ** randomnessPower * (Math.random() < 0.5 ? 1 : -1)
      const offy = (Math.random() * randomness) ** randomnessPower * (Math.random() < 0.5 ? 1 : -1)
      const offz = (Math.random() * randomness) ** randomnessPower * (Math.random() < 0.5 ? 1 : -1)

      position[i3] += offx
      position[i3 + 1] += offy
      position[i3 + 2] += offz

      const col_mix = col_inner.clone().lerp(col_outer, r / radius)
      color[i3] = col_mix.r
      color[i3 + 1] = col_mix.g
      color[i3 + 2] = col_mix.b
    }

    geo.setAttribute('position', new THREE.BufferAttribute(position, 3))
    geo.setAttribute('color', new THREE.BufferAttribute(color, 3))

    points = new THREE.Points(geo, mat)
    scene.add(points)

    loops.push(() => {
      const t = clock.getElapsedTime() * 0.2
      points.rotation.y = t
    })
  }
})

onUnmounted(() => {
  renderer.dispose()
  renderer.forceContextLoss()
  controls.dispose()
  disposeScene(scene)
  pane.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh" />
</template>

<style></style>
