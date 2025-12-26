<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { mergeGeometries } from 'three/examples/jsm/utils/BufferGeometryUtils.js'

const baseUrl = useRuntimeConfig().public.baseURL || ''

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls

const loops: Array<() => void> = []

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
  if (!containerRef.value)
    return
  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  renderer = new THREE.WebGLRenderer()
  containerRef.value.appendChild(renderer.domElement)
  controls = new OrbitControls(camera, renderer.domElement)

  camera.position.z = -10
  controls.update()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight()
    scene.add(light)
  }
  {
    const light = new THREE.PointLight(0xFFFFFF, 20)
    light.position.y = 3
    const helper = new THREE.PointLightHelper(light)
    scene.add(light)
    scene.add(helper)
  }
  {
    const geo = new THREE.BoxGeometry(1, 1, 1)
    const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
    const mesh = new THREE.Mesh(geo, mat)
    // scene.add(mesh)
  }
  async function getData() {
    const res = await fetch(`${baseUrl}data/100000.json`)
    return res.text()
  }

  type Coord = [number, number]
  type Coords = Array<Coord>

  function drawProvinceGeo(coords: Coords) {
    const position: number[] = []
    const index: number[] = []
    let ndx = 0
    const face: number[] = []
    const zHeight = 1
    for (let i = 0; i < coords.length - 1; i++) {
      const p_cur = coords[i]
      const p_nex = coords[i + 1]
      const p1 = new THREE.Vector3(p_cur[0], p_cur[1], 0)
      const p2 = new THREE.Vector3(p_cur[0], p_cur[1], zHeight)
      const p3 = new THREE.Vector3(p_nex[0], p_nex[1], 0)
      const p4 = new THREE.Vector3(p_nex[0], p_nex[1], zHeight)
      position.push(...p1.toArray(), ...p2.toArray(), ...p3.toArray(), ...p4.toArray())
      // index.push(0,1,2, 1,2,3)
      index.push(ndx, ndx + 1, ndx + 2, ndx + 3, ndx + 2, ndx + 1)
      ndx += 4
    }
    const coordsFlat: number[] = []
    coords.forEach((item) => {
      coordsFlat.push(...item)
    })

    const shape = new THREE.Shape()
    coords.forEach(([x, y], ndx) => {
      if (ndx === 0) {
        shape.moveTo(x, y)
      }
      else {
        shape.lineTo(x, y)
      }
    })
    shape.closePath()
    const faceGeo = new THREE.ShapeGeometry(shape)
    faceGeo.deleteAttribute('uv')
    const faceGeo2 = faceGeo.clone()
    faceGeo2.translate(0, 0, zHeight)

    console.log(position)
    console.log(index)
    const geo = new THREE.BufferGeometry()
    geo.setAttribute('position', new THREE.Float32BufferAttribute(position, 3))
    geo.setIndex(index)
    geo.computeVertexNormals()

    const geoMerge = mergeGeometries([geo, faceGeo, faceGeo2], false)

    geoMerge.center()
    geoMerge.computeVertexNormals()
    const mat = new THREE.MeshPhongMaterial({ color: 0x990000, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geoMerge, mat)

    {
      loops.push(() => {
        mesh.rotation.y += 0.01
      })
    }

    mesh.scale.set(0.4, 0.4, 1)
    scene.add(mesh)
  }
  getData()
    .then((res) => {
      res = JSON.parse(res)
      console.log(res)

      // @ts-ignore
      const p = res.features[4].geometry.coordinates[0] as Coords
      drawProvinceGeo(p)
    })

  function animate() {
    loops.forEach(fn => fn())
    renderer.render(scene, camera)
  }

  renderer.setAnimationLoop(animate)

  handleResize()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  disposeScene(scene)
  renderer.dispose()
  renderer.forceContextLoss()
  controls.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh" />
</template>

<style></style>
