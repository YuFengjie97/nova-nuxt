<script lang="ts" setup>
import { RaycasterHelper } from '@gsimone/three-raycaster-helper'
import * as THREE from 'three'
import { GLTFLoader, OrbitControls } from 'three/examples/jsm/Addons.js'

import { Pane } from 'tweakpane'
import { ref } from 'vue'
import { useEffect } from '~/hooks/useEffect'

const baseUrl = useRuntimeConfig().public.baseURL || ''
const containerRef = ref<HTMLDivElement>()

const size = new THREE.Vector2(0, 0)
const mouse = new THREE.Vector2(0, 0)
function upadteMouse(ev: MouseEvent) {
  const { x, y } = ev
  mouse.x = x / size.x * 2 - 1
  mouse.y = -y / size.y * 2 + 1
}

useEffect(() => {
  if (!containerRef.value) {
    return
  }
  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, 2, 0.1, 100)
  const renderer = new THREE.WebGLRenderer()
  const loops: Array<(delta: number, elapsed: number) => void> = []
  const pane: Pane = new Pane()
  const controls: OrbitControls = new OrbitControls(camera, renderer.domElement)

  function handleResize() {
    if (!containerRef.value)
      return

    const width = containerRef.value.clientWidth
    const height = containerRef.value.clientHeight
    camera.aspect = width / height
    camera.updateProjectionMatrix()

    size.x = width
    size.y = height

    renderer.setSize(width, height)
  }

  scene.add(camera)
  camera.position.z = 5.5
  // camera.position.y = 1.0
  // renderer.setClearAlpha(0)
  containerRef.value?.appendChild(renderer.domElement)
  const dpr = window.devicePixelRatio
  renderer.setPixelRatio(Math.min(dpr, 2))
  // renderer.shadowMap.enabled = true
  // renderer.shadowMap.type = THREE.PCFSoftShadowMap
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
    scene.add(light)
  }

  const meshs: THREE.Mesh[] = []

  {
    const geo = new THREE.BoxGeometry(1, 1, 1, 2, 2, 2)
    const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
    mat.wireframe = true
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
    mesh.position.x = -3
    meshs.push(mesh)
    loops.push((delta, elapsed) => {
      mesh.position.y = Math.sin(elapsed * 0.1) * 2.0
    })
  }

  {
    const geo = new THREE.SphereGeometry(1)
    const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
    mat.wireframe = true

    const mesh = new THREE.Mesh(geo, mat)
    meshs.push(mesh)
    scene.add(mesh)
    loops.push((delta, elapsed) => {
      mesh.position.y = Math.sin(elapsed * 0.1 + 1.0) * 2.0
    })
  }
  {
    const geo = new THREE.TorusGeometry()
    const mat = new THREE.MeshBasicMaterial({ color: 0xFF0000 })
    mat.wireframe = true
    const mesh = new THREE.Mesh(geo, mat)
    meshs.push(mesh)
    scene.add(mesh)
    mesh.position.x = 3
    loops.push((delta, elapsed) => {
      mesh.position.y = Math.sin(elapsed * 0.1 + 2.0) * 2.0
      mesh.rotation.x += delta
      mesh.rotation.y += delta
    })
  }

  {
    const rayOrigin = new THREE.Vector3(-5, 0, 0)
    const rayDirection = new THREE.Vector3(1, 0, 0).normalize()
    // const rayCaster = new THREE.Raycaster(rayOrigin, rayDirection)
    const rayCaster = new THREE.Raycaster()
    rayCaster.near = 0.1
    rayCaster.far = 20

    const helper = new RaycasterHelper(rayCaster)
    scene.add(helper)

    let currentInstersect: null | THREE.Intersection<THREE.Object3D<THREE.Object3DEventMap>>
      = null

    renderer.domElement.addEventListener('click', () => {
      if (currentInstersect) {
        console.log('点击物体', currentInstersect)
      }
      else {
        console.log('没有点击任何物体')
      }
    })

    loops.push((delta) => {
      rayCaster.setFromCamera(mouse, camera)
      const intersects = rayCaster.intersectObjects(meshs)

      for (const mesh of meshs) {
        // @ts-ignore
        mesh.material.color.set(0xFF0000)
      }

      for (const mesh of intersects) {
        // @ts-ignore
        mesh.object.material.color.set(0x00FF00)
      }

      if (intersects.length) {
        if (!currentInstersect) {
          console.log('enter')
        }
        currentInstersect = intersects[0]
      }
      else {
        if (currentInstersect) {
          console.log('leave')
        }
        currentInstersect = null
      }

      // @ts-ignore
      helper.hits = intersects
      helper.update()
    })
  }

  return () => {
    disposeScene(scene, renderer)
    controls.dispose()
    pane.dispose()
    window.removeEventListener('resize', handleResize)
  }
}, [])
</script>

<template>
  <div ref="containerRef" class="w-full h-100vh" @mousemove="upadteMouse" />
</template>

<style></style>
