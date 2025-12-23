<script lang="ts" setup>
import * as THREE from 'three'
import { BufferGeometryUtils, OrbitControls } from 'three/examples/jsm/Addons.js'
import { ref } from 'vue'

const containerRef = ref<HTMLDivElement>()
const scene = new THREE.Scene()
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls

const baseUrl = useRuntimeConfig().public.baseURL || ''

async function getData() {
  const res = await fetch(`${baseUrl}data/gpw_v4_basic_demographic_characteristics_rev10_a000_014mt_2010_cntm_1_deg.asc?raw`)
  return res.text()
}

function parseData(res: any) {
  const data: Array<Array<number | undefined>> = []
  const settings = { data }
  let max: number
  let min: number
  res.split('\n').forEach((line: string) => {
    const parts = line.trim().split(/\s+/)
    if (parts.length === 2) {
      // @ts-ignore
      settings[parts[0]] = Number.parseFloat(parts[1])
    }
    else if (parts.length > 2) {
      const values = parts.map((v) => {
        const value = Number.parseFloat(v)
        // @ts-ignore
        if (value === settings.NODATA_value) {
          return undefined
        }

        max = Math.max(max === undefined ? value : max, value)
        min = Math.min(min === undefined ? value : min, value)
        return value
      })
      data.push(values)
    }
  })
  // @ts-ignore
  return Object.assign(settings, { min, max })
}

function addBoxes(file: ReturnType<typeof parseData>) {
  const { min, max, data } = file
  const range = max - min
  const lonHelper = new THREE.Object3D()// 经度
  const latHelper = new THREE.Object3D()// 维度
  const posHelper = new THREE.Object3D()// 位置
  const oriHelper = new THREE.Object3D()// box原点
  scene.add(lonHelper)
  lonHelper.add(latHelper)
  latHelper.add(posHelper)
  posHelper.add(oriHelper)
  posHelper.position.z = 1.0 // 这里z轴平移对应球体半径
  oriHelper.position.z = 0.5 // 平移.5对应box高度的一半

  const lonFudge = Math.PI * 0.5
  const latFudge = Math.PI * -0.135

  const color = new THREE.Color()

  const geometries: THREE.BoxGeometry[] = []

  data.forEach((row, latNdx) => {
    row.forEach((value, lonNdx) => {
      if (value === undefined) {
        return
      }
      const amount = (value - min) / range

      const geo = new THREE.BoxGeometry(1, 1, 1)

      // @ts-ignore
      lonHelper.rotation.y = THREE.MathUtils.degToRad(lonNdx + file.xllcorner) + lonFudge
      // @ts-ignore
      latHelper.rotation.x = THREE.MathUtils.degToRad(latNdx + file.yllcorner) + latFudge

      posHelper.scale.set(0.005, 0.005, THREE.MathUtils.lerp(0.01, 0.5, amount)) // 为什么缩放是posHelper,而不是geo/mesh?
      oriHelper.updateWorldMatrix(true, false)
      geo.applyMatrix4(oriHelper.matrixWorld)

      const hue = THREE.MathUtils.lerp(0.7, 0.3, amount)
      const saturation = 1
      const lightness = THREE.MathUtils.lerp(0.4, 1.0, amount)
      color.setHSL(hue, saturation, lightness)
      const rgb = color.toArray().map(item => item * 255)

      const numVerts = geo.getAttribute('position').count
      const itemSize = 3 // r, g, b
      const colors = new Uint8Array(itemSize * numVerts)

      colors.forEach((v, ndx) => {
        colors[ndx] = rgb[ndx % 3]
      })

      const colorAttrib = new THREE.BufferAttribute(colors, itemSize, true)
      geo.setAttribute('color', colorAttrib)

      geometries.push(geo)
    })
  })

  const mergedGeometry = BufferGeometryUtils.mergeGeometries(
    geometries,
    false,
  )
  // console.log(mergedGeometry);

  const material = new THREE.MeshBasicMaterial({
    vertexColors: true,
  })
  const mesh = new THREE.Mesh(mergedGeometry, material)
  scene.add(mesh)
}

function handleResize() {
  const width = containerRef.value!.clientWidth
  const height = containerRef.value!.clientHeight

  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize(width, height)
}

onMounted(() => {
  if (!containerRef.value) {
    return
  }
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 10)
  camera.position.set(0, 0, -2.5)
  camera.lookAt(new THREE.Vector3(0, 0, 0))
  controls = new OrbitControls(camera, containerRef.value)
  renderer = new THREE.WebGLRenderer({ antialias: true })
  containerRef.value.append(renderer.domElement)
  handleResize()

  const loops: Array<(time?: number) => void> = []

  const loader = new THREE.TextureLoader()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight()
    scene.add(light)
  }

  {
    const group = new THREE.Group()
    scene.add(group)
    const geo = new THREE.SphereGeometry(1, 64, 32)
    const tex = loader.load(`${baseUrl}img/texture/world.jpg`)
    tex.colorSpace = THREE.SRGBColorSpace
    const mat = new THREE.MeshBasicMaterial({ map: tex })
    const mesh = new THREE.Mesh(geo, mat)
    group.add(mesh)
  }

  {
    getData()
      .then(parseData)
      .then(addBoxes)
  }

  function animate(time: number) {
    loops.forEach(fn => fn(time))
    renderer.render(scene, camera)
  }
  renderer.setAnimationLoop(animate)

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  controls.dispose()

  disposeScene(scene)

  renderer.dispose()
  renderer.forceContextLoss()

  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh">
    <!-- <canvas ref="renderCanvas" class="h-full w-full block m-0"/> -->
  </div>
</template>

<style lang='less' scoped></style>
