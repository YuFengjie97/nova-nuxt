<script lang="ts" setup>
import * as THREE from 'three'
import { CSS2DObject, CSS2DRenderer } from 'three/examples/jsm/Addons.js'

const threeContainer = ref<HTMLElement>()
onMounted(() => {
  const clock = new THREE.Clock()

  const { scene, camera, renderer, resolution } = initScene()
  const cube = addCube()
  const labelRenderer = add2DLable()
  addLine()
  console.log(scene.children)

  function initScene() {
    if (!threeContainer.value) {
      console.error('three container 未定义')
      return
    }
    const { width, height } = threeContainer.value.getBoundingClientRect()
    const resolution = {
      x: width,
      y: height,
    }
    const aspect = resolution.x / resolution.y

    const scene = new THREE.Scene()
    const camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 1000)
    // camera.lookAt(new THREE.Vector3(0, 0, 0))
    camera.position.z = 5.0

    const renderer = new THREE.WebGLRenderer()
    renderer.setSize(resolution.x, resolution.y)

    threeContainer.value?.appendChild(renderer.domElement)

    return { scene, camera, renderer, resolution }
  }

  function addCube() {
    const geometry = new THREE.BoxGeometry(1, 1, 1)
    const material = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const cube = new THREE.Mesh(geometry, material)
    scene.add(cube)
    return cube
  }

  function add2DLable() {
    const labelRenderer = new CSS2DRenderer()
    labelRenderer.setSize(resolution.x, resolution.y)
    labelRenderer.domElement.style.position = 'absolute'
    labelRenderer.domElement.style.top = '0'
    labelRenderer.domElement.style.pointerEvents = 'none' // 允许鼠标事件穿透到WebGL画布
    // document.body.appendChild(labelRenderer.domElement)
    threeContainer.value!.appendChild(labelRenderer.domElement)

    const div = document.createElement('div')
    div.textContent = '我是一个标签'
    div.style.color = 'white'
    div.style.backgroundColor = 'rgba(0,0,0,0.5)'
    div.style.padding = '5px'
    const label = new CSS2DObject(div) // 将div包装为2D标签对象
    cube.add(label)
    return labelRenderer
  }

  function addLine() {
    // const material = new THREE.LineBasicMaterial({ color: 'rgb(255,255,0)' })
    const material = new THREE.LineBasicMaterial({ color: 0x0000FF })

    const points = []
    const random = Math.random
    for (let i = 0.0; i < 4.0; i++) {
      const v = new THREE.Vector3(random() * 4 - 2, random() * 4 - 2, random() * 4 - 2)
      points.push(v)
    }
    // points.push(new THREE.Vector3(-2, 0, 0))
    // points.push(new THREE.Vector3(0, 2, 0))
    // points.push(new THREE.Vector3(2, 0, 0))
    const geometry = new THREE.BufferGeometry().setFromPoints(points)
    const line = new THREE.Line(geometry, material)
    scene.add(line)
  }
  // const css3DRender = css3DTexTest()

  function animate() {
    cube.rotation.x += 0.02
    cube.rotation.y += 0.02
    cube.rotation.z += 0.02

    const t = clock.getElapsedTime()
    {
      const R = 2
      const x = Math.cos(t) * R
      const y = Math.sin(t) * R
      cube.position.x = x
      cube.position.y = y
    }

    renderer.render(scene, camera)
    labelRenderer.render(scene, camera)
    // css3DRender.render(scene, camera)
  }

  renderer.setAnimationLoop(animate)
})
</script>

<template>
  <div ref="threeContainer" class="three-con h-100vh" />
</template>

<style lang='less' scoped></style>
