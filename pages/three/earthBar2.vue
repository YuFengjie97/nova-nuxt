<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { mergeGeometries } from 'three/examples/jsm/utils/BufferGeometryUtils.js'

const containerRef = ref<HTMLDivElement>()
let scene: THREE.Scene
let camera: THREE.PerspectiveCamera
let renderer: THREE.WebGLRenderer
let controls: OrbitControls
const loops: Array<() => void> = []

function handleResize() {
  const width = containerRef.value!.clientWidth
  const height = containerRef.value!.clientHeight

  const canvas = renderer.domElement
  const needResize = width !== canvas.width || height !== canvas.height

  if (needResize) {
    camera.aspect = width / height
    camera.updateProjectionMatrix()
    renderer.setSize(width, height)
  }

  return needResize
}

onMounted(() => {
  if (!containerRef.value) {
    return
  }

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  camera.position.set(0, 0, -2.5)
  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setPixelRatio(window.devicePixelRatio)
  containerRef.value.appendChild(renderer.domElement)
  controls = new OrbitControls(camera, renderer.domElement)
  handleResize()

  // function animate() {
  //   loops.forEach(fn => fn())
  //   renderer.render(scene, camera)
  // }
  // renderer.setAnimationLoop(animate)

  // 按需渲染
  function render() {
    renderer.render(scene, camera)
  }
  controls.addEventListener('change', render) // 控制器鼠标事件后的 事件渲染

  window.addEventListener('resize', handleResize)

  {
    const helper = new THREE.AxesHelper(100)
    scene.add(helper)
  }

  {
    const light = new THREE.AmbientLight(0xFFFFFF, 0.1)
    scene.add(light)
  }

  {
    const light = new THREE.HemisphereLight(0xFFFFFF, 0x666666, 2)
    scene.add(light)
  }

  {
    const rotXHelper = new THREE.Object3D()
    const rotYHelper = new THREE.Object3D()
    const posHelper = new THREE.Object3D()
    const oriHelper = new THREE.Object3D()
    const r = 1
    posHelper.position.z = r
    rotXHelper.add(rotYHelper)
    rotYHelper.add(posHelper)
    posHelper.add(oriHelper)
    scene.add(rotXHelper)
    const numX = 9
    const numY = 17
    const geos: Array<THREE.BoxGeometry | THREE.SphereGeometry> = []
    const colors: number[] = []
    for (let i = 0; i < numX; i++) {
      for (let j = 0; j < numY; j++) {
        const angX = i / numX * Math.PI * 2
        const angY = j / numY * Math.PI * 2
        rotXHelper.rotation.x = angX
        rotYHelper.rotation.y = angY

        const zHeight = Math.random() * 0.5 + 0.1
        const geo = new THREE.BoxGeometry(0.04, 0.04, zHeight)
        oriHelper.position.z = zHeight / 2

        oriHelper.updateWorldMatrix(true, false)
        geo.applyMatrix4(oriHelper.matrixWorld)
        geos.push(geo)

        const vertNum = geo.getAttribute('position').count
        const v = Math.random()
        const H = v
        const col = new THREE.Color().setHSL(H, 1, 0.5)
        for (let i = 0; i < vertNum; i++) {
          colors.push(...col.toArray())
        }

        // 追加顶部球体
        {
          const gap = 0.1
          const r = 0.03
          const geo = new THREE.SphereGeometry(r, 4, 2)

          oriHelper.position.z += zHeight / 2 + gap
          oriHelper.updateWorldMatrix(true, false)
          geo.applyMatrix4(oriHelper.matrixWorld)
          geos.push(geo)

          {
            const vertNum = geo.getAttribute('position').count
            const col = new THREE.Color().setHSL(H, 1.0, 0.5)
            for (let i = 0; i < vertNum; i++) {
              colors.push(...col.toArray())
            }
          }
        }
      }
    }
    const geo = mergeGeometries(geos, false)
    geo.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3))
    geo.attributes.color.needsUpdate = true

    const mat = new THREE.MeshPhongMaterial({ vertexColors: true })
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)

    {
      const geo = new THREE.SphereGeometry(r)
      const mat = new THREE.MeshBasicMaterial({ wireframe: true })
      const mesh1 = new THREE.Mesh(geo, mat)
      mesh.add(mesh1)
    }

    render() // 按需渲染,创建完所有mesh后的第一次渲染
  }
})
onUnmounted(() => {
  disposeScene(scene)
  renderer.dispose()
  renderer.forceContextLoss()

  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="containerRef" class="h-100vh" />
</template>

<style>

</style>
