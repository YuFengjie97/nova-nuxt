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
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 1000)
  scene.add(camera)
  renderer = new THREE.WebGLRenderer()
  containerRef.value.appendChild(renderer.domElement)
  controls = new OrbitControls(camera, renderer.domElement)

  // camera.position.y = 2
  camera.position.z = 15
  controls.update()

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }
  {
    const light = new THREE.AmbientLight()
    scene.add(light)
  }
  if (true) {
    const group = new THREE.Group()
    const light = new THREE.PointLight(0xFFFFFF, 100)
    light.position.z = 7
    const helper = new THREE.PointLightHelper(light)
    group.add(light)
    group.add(helper)
    scene.add(group)

    loops.push(() => {
      // const time = Date.now() * 0.0008
      // group.position.x = Math.sin(time) * 8.0
      group.rotation.y += 0.01
      // group.rotation.y += 0.01
      // group.rotation.z += 0.01
    })
  }
  async function getData() {
    const res = await fetch(`${baseUrl}data/100000.json`)
    return res.text()
  }

  type Coord = [number, number]
  type Coords = Array<Coord>

  function drawMesh(coords: Coords, color: THREE.Color) {
    const position: number[] = [] // 收集的侧面顶点buffer
    const index: number[] = [] // 侧面三角形
    let ndx = 0
    const zHeight = 1 // 侧面高度
    for (let i = 0; i < coords.length - 1; i++) {
      const p_cur = coords[i]
      const p_nex = coords[i + 1]

      // p_cur[0] -= 116.3683244/2
      // p_cur[1] -= 39.915085/2
      // p_nex[0] -= 116.3683244/2
      // p_nex[1] -= 39.915085/2

      const p1 = new THREE.Vector3(p_cur[0], p_cur[1], 0)
      const p2 = new THREE.Vector3(p_cur[0], p_cur[1], zHeight)
      const p3 = new THREE.Vector3(p_nex[0], p_nex[1], 0)
      const p4 = new THREE.Vector3(p_nex[0], p_nex[1], zHeight)
      position.push(...p1.toArray(), ...p2.toArray(), ...p3.toArray(), ...p4.toArray())
      index.push(ndx, ndx + 1, ndx + 2, ndx + 1, ndx + 2, ndx + 3)
      ndx += 4
    }

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
    faceGeo.deleteAttribute('normal')
    const faceGeo2 = faceGeo.clone()
    faceGeo.translate(0, 0, zHeight)

    const geo = new THREE.BufferGeometry()
    geo.setAttribute('position', new THREE.Float32BufferAttribute(position, 3))
    geo.setIndex(index)
    // geo.computeVertexNormals()

    const geoMerge = mergeGeometries([geo, faceGeo, faceGeo2], false)

    geoMerge.computeVertexNormals()
    const mat = new THREE.MeshPhongMaterial({ color, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geoMerge, mat)
    return mesh
  }
  function drawProvince(coordss: Coords[]) {
    const group = new THREE.Group() // 一个省下的所有mesh
    coordss.forEach((coords, ndx) => {
      const col = new THREE.Color()
      col.setHSL(Math.random(), 0.8, 0.3)
      const mesh = drawMesh(coords, col)
      mesh.position.x -= 116.3683244
      mesh.position.y -= 39.915085
      group.add(mesh)
    })
    return group
  }
  function drawChina(res: any) {
    const group = new THREE.Group()
    scene.add(group)
    res.features.forEach((data: any) => {
      let coordss
      const geoType = data.geometry.type
      if (geoType === 'MultiLineString') {
        return
      }
      if (geoType === 'Polygon') {
        coordss = data.geometry.coordinates
      }
      else if (geoType === 'MultiPolygon') {
        // const arr = []
        // data.geometry.coordinates.forEach(item => {
        //   arr.push(...item)
        // })
        // coordss = arr
        coordss = data.geometry.coordinates.flat()
      }

      const provinceMesh = drawProvince(coordss)
      group.add(provinceMesh)

      const zOff = Math.random() * 4 + 2
      loops.push(() => {
        const time = Date.now() * 0.005
        provinceMesh.position.z = Math.sin(time + zOff)
      })
    })
    // group.rotation.y = Math.PI
    group.scale.set(0.4, 0.4, 1)
  }
  getData()
    .then((res) => {
      res = JSON.parse(res)
      drawChina(res)
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
