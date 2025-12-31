<script lang="ts" setup>
import { gsap } from 'gsap'
import * as THREE from 'three'
import { Pane } from 'tweakpane'
import { ref } from 'vue'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
const loops: Array<(delta: number) => void> = []
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
  const cameraGroup = new THREE.Group()
  cameraGroup.add(camera)
  scene.add(cameraGroup)
  camera.position.z = 1.5
  renderer = new THREE.WebGLRenderer({
    alpha: true,
  })
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap

  handleResize()
  window.addEventListener('resize', handleResize)

  function animate() {
    const delta = clock.getDelta()
    loops.forEach(fn => fn(delta))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  {
    const light = new THREE.DirectionalLight()
    scene.add(light)
    light.position.set(1, 1, 0)
  }

  const loadingManager = new THREE.LoadingManager()
  const textureLoader = new THREE.TextureLoader(loadingManager)
  const tex_gradient = textureLoader.load(`${baseUrl}img/texture/gradient/gradient_3.png`)
  tex_gradient.generateMipmaps = false
  tex_gradient.magFilter = THREE.NearestFilter

  // const mat = new THREE.MeshNormalMaterial()
  const mat = new THREE.MeshToonMaterial({
    gradientMap: tex_gradient,
  })

  const tex_matcap_1 = textureLoader.load(`${baseUrl}img/texture/matcap/3E2335_D36A1B_8E4A2E_2842A5.png`)
  const tex_matcap_2 = textureLoader.load(`${baseUrl}img/texture/matcap/3B6E10_E3F2C3_88AC2E_99CE51.png`)
  const tex_matcap_3 = textureLoader.load(`${baseUrl}img/texture/matcap/8A6565_2E214D_D48A5F_ADA59C.png`)
  const mat1 = new THREE.MeshMatcapMaterial({ matcap: tex_matcap_1 })
  const mat2 = new THREE.MeshMatcapMaterial({ matcap: tex_matcap_2 })
  const mat3 = new THREE.MeshMatcapMaterial({ matcap: tex_matcap_3 })

  const objDistance = 4

  const mesh1 = new THREE.Mesh(new THREE.TorusGeometry(0.5, 0.2), mat1)
  mesh1.position.x = 1
  scene.add(mesh1)

  const mesh2 = new THREE.Mesh(new THREE.TorusKnotGeometry(0.5, 0.2), mat2)
  mesh2.position.x = -1
  scene.add(mesh2)

  const mesh3 = new THREE.Mesh(new THREE.ConeGeometry(0.5, 1, 6), mat3)
  mesh3.position.x = 1
  scene.add(mesh3)

  const meshs = [mesh1, mesh2, mesh3]
  loops.push((delta) => {
    meshs.forEach((mesh) => {
      // 因为gsap控制了一部分的旋转,这里是 += ,并改为delta
      mesh.rotation.x += delta * 0.1
      mesh.rotation.y += delta * 0.1
    })
  })

  mesh1.position.y -= objDistance * 0
  mesh2.position.y -= objDistance * 1
  mesh3.position.y -= objDistance * 2

  // 粒子
  {
    const tex_particle = textureLoader.load(`${baseUrl}img/texture/particle/star_04.png`)

    const count = 1000
    const position = new Float32Array(count * 3)
    for (let i = 0; i < count; i++) {
      position[i * 3] = (Math.random() - 0.5) * 10
      position[i * 3 + 1] = -Math.random() * objDistance * meshs.length + objDistance * 0.5
      position[i * 3 + 2] = (Math.random() - 0.5) * 10
    }
    const geo = new THREE.BufferGeometry()
    geo.setAttribute('position', new THREE.BufferAttribute(position, 3))
    const mat = new THREE.PointsMaterial({
      size: 0.18,
      sizeAttenuation: true,
      transparent: true,
      alphaMap: tex_particle,
      depthWrite: false,
    })
    const points = new THREE.Points(geo, mat)
    scene.add(points)
    loops.push(() => {
      const t = clock.getElapsedTime()
      points.rotation.y = t * 0.1
    })
  }

  // 滚动
  let scrollY = window.scrollY
  let currentSection = 0
  window.addEventListener('scroll', () => {
    scrollY = window.scrollY

    const newSection = Math.round(scrollY / window.innerHeight) // 用round而不是floor,可以将判定标准移动到section中心
    if (currentSection !== newSection) {
      currentSection = newSection
      gsap.to(meshs[currentSection].rotation, {
        duration: 1.5,
        ease: 'power1.inOut',
        x: '+=6',
        y: '+=3',
      })
    }
  })

  // 鼠标移动--视差
  const cursor = { x: 0, y: 0 }
  window.addEventListener('mousemove', (ev) => {
    cursor.x = ev.clientX / window.innerWidth - 0.5
    cursor.y = ev.clientY / window.innerHeight - 0.5
  })

  // let previouseTime = 0

  loops.push((delta) => {
    // const elapsedTime = clock.getElapsedTime()
    // const delta = elapsedTime - previouseTime
    // previouseTime = elapsedTime

    const parallaxX = cursor.x * 1.0
    const parallaxY = -cursor.y * 1.0

    // 视差 + easing
    /**
     * parallax是目标值, camera.position是当前值, 5.是累加系数, dleta为了让不同帧率的设备相同速度
     */
    camera.position.x += (parallaxX - camera.position.x) * 5.0 * delta
    camera.position.y += (parallaxY - camera.position.y) * 5.0 * delta

    // scroll移动camera到物体
    cameraGroup.position.y = -scrollY / window.innerHeight * objDistance
  })
})

onUnmounted(() => {
  renderer.dispose()
  renderer.forceContextLoss()
  disposeScene(scene)
  pane.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div class="relative base">
    <div ref="containerRef" class="w-full h-100vh fixed top-0 left-0" />
    <div class="title-container">
      <h1>YuFengjie</h1>
    </div>
    <div class="title-container" style="justify-content: flex-end;">
      <h1>Good Morning</h1>
    </div>
    <div class="title-container">
      <h1>Good Luck</h1>
    </div>
  </div>
</template>

<style lang="less" scoped>
  .base{
    background: #160404;
    .title-container{
      width: 100%;
      height: 100vh;
      display: flex;
      align-items: center;
      h1{
        font-size: 3rem;
        padding: 0 6rem;
        color: white
      }
    }
  }
</style>
