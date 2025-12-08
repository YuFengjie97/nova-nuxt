<script lang="ts" setup>
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'
import { Pane } from 'tweakpane'

const threeContainer = ref<HTMLElement>()

let scene: THREE.Scene
let renderer: THREE.WebGLRenderer

const loops: Array<() => void> = []

let pane: Pane

onMounted(() => {
  if (!threeContainer.value) {
    return
  }

  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  const camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.set(0, 40, -40)
  camera.lookAt(new THREE.Vector3(0, 0, 0))
  scene = new THREE.Scene()
  renderer = new THREE.WebGLRenderer()
  renderer.shadowMap.enabled = true
  renderer.setSize(resolution.x, resolution.y)
  threeContainer.value.append(renderer.domElement)

  // 坦克第一视角
  const cameraTankPov = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 2, 1000)
  cameraTankPov.position.y = 3.0
  cameraTankPov.position.z = -3.0
  // 目标球第一视角
  const cameraTarPov = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 4, 1000)
  let cameraActive: THREE.PerspectiveCamera = cameraTarPov

  const tankPos = new THREE.Vector3() // 坦克位置
  const tankLook = new THREE.Vector3() // 坦克朝向
  let tankTar: THREE.Mesh // 坦克目标球
  let tank: THREE.Group // 坦克对象组

  {
    loops.push(() => {
      if (cameraActive === cameraTarPov) {
        tank && cameraActive.lookAt(tank.position)
      }
      if (cameraActive === cameraTankPov) {
        tankTar && cameraActive.lookAt(tankTar.position)
      }
      if (cameraActive === camera) {
        cameraActive.lookAt(new THREE.Vector3(0, 0, 0))
      }
    })
  }

  pane = new Pane()
  pane.addBlade({
    view: 'list',
    label: 'scene',
    options: [
      { text: '普通相机', value: camera },
      { text: '坦克POV', value: cameraTankPov },
      { text: '目标球POV', value: cameraTarPov },
    ],
    value: camera,
  })
  pane.on('change', (ev) => {
    cameraActive = ev.value as THREE.PerspectiveCamera
  })

  {
    const axisHelper = new THREE.AxesHelper(10000)
    scene.add(axisHelper)
  }
  {
    const light = new THREE.AmbientLight('rgb(255,255,255)', 1)
    scene.add(light)
  }
  {
    const light = new THREE.PointLight('rgb(255,255,255)', 10.0, 50, 0.1)
    const helper = new THREE.PointLightHelper(light, 3)
    scene.add(helper)
    light.position.set(0, 20, 0)
    light.castShadow = true
    scene.add(light)
  }

  // 地面
  {
    const geo = new THREE.PlaneGeometry(100, 100, 1, 1)
    const mat = new THREE.MeshLambertMaterial({ color: 'rgb(0, 184, 148)' })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.rotation.x = -Math.PI / 2.0
    mesh.receiveShadow = true
    scene.add(mesh)
    // 行进路径
    {
      const points = []
      const random = () => Math.random() * 80 - 40
      for (let i = 0.0; i < 10.0; i++) {
        const p = new THREE.Vector2(random(), random())
        points.push(p)
      }
      points.push(points[0])
      const path = new THREE.SplineCurve(points)

      const _tankPos = new THREE.Vector2(0, 0)
      const _tankLook = new THREE.Vector2(0, 0)
      loops.push(() => {
        const t = Date.now() * 0.001
        path.getPoint((t % 60) / 60, _tankPos)
        path.getPoint(((t + 1.0) % 60) / 60, _tankLook)
        tankPos.set(_tankPos.x, 2.0, _tankPos.y)
        tankLook.set(_tankLook.x, 2.0, _tankLook.y)
      })

      const positions = path.getPoints(50)
      const geo = new THREE.BufferGeometry().setFromPoints(positions)
      const mat = new THREE.LineBasicMaterial({ color: 'rgb(253, 121, 168)', linewidth: 400 })
      const line = new THREE.Line(geo, mat)
      line.rotateX(Math.PI)
      mesh.add(line)
    }
  }

  // 目标球
  {
    const geo = new THREE.SphereGeometry(1, 6, 6)
    const mat = new THREE.MeshNormalMaterial()
    const mesh = new THREE.Mesh(geo, mat)
    tankTar = mesh
    scene.add(mesh)
    const s1 = (val: number) => Math.sin(val) * 0.5 + 0.5

    mesh.add(cameraTarPov)

    loops.push(() => {
      const t = Date.now() * 0.0005
      const y = s1(t * 10.0) * 8 + 2
      const x = Math.cos(t) * 40
      const z = Math.sin(t) * 40
      mesh.position.set(x, y, z)
    })
  }

  {
    tank = new THREE.Group()
    // tank.scale.set(2, 2, 2)
    scene.add(tank)
    loops.push(() => {
      tank.position.set(tankPos.x, tankPos.y, tankPos.z)
      tank.lookAt(tankLook)
    })
    // 坦克头
    {
      const geo = new THREE.SphereGeometry(1.2, 6, 6)
      const mat = new THREE.MeshPhongMaterial({ color: 'rgb(255, 234, 167)' })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.castShadow = true
      tank.add(mesh)
      loops.push(() => {
        mesh.lookAt(tankTar.position)
      })

      {
        mesh.add(cameraTankPov)
      }

      // 炮筒
      {
        const geo = new THREE.BoxGeometry(0.4, 0.4, 4)
        const mat = new THREE.MeshPhongMaterial({ color: 'rgb(108, 92, 231)' })
        const mesh1 = new THREE.Mesh(geo, mat)
        mesh1.castShadow = true
        mesh1.position.y = 0.5
        mesh1.position.z = 2

        mesh.add(mesh1)
      }
    }
    // 坦克身子
    {
      const geo = new THREE.BoxGeometry(3, 1.3, 6)
      const mat = new THREE.MeshPhongMaterial({ color: 'rgb(225, 112, 85)' })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.castShadow = true
      mesh.translateY(-0.6)
      tank.add(mesh)
    }
    // 轮子
    {
      const geo = new THREE.CylinderGeometry(1, 1, 1, 6, 6)
      const mat = new THREE.MeshPhongMaterial({ color: 'rgb(214, 48, 49)' })
      {
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        mesh.position.set(1.5, -1, 2)
        mesh.rotateZ(Math.PI / 2.0)
        tank.add(mesh)

        loops.push(() => {
          mesh.rotation.x += 0.1
        })
      }
      {
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        mesh.position.set(-1.5, -1, 2)
        mesh.rotateZ(Math.PI / 2.0)
        tank.add(mesh)

        loops.push(() => {
          mesh.rotation.x += 0.1
        })
      }
      {
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        mesh.position.set(1.5, -1, -2)
        mesh.rotateZ(Math.PI / 2.0)
        tank.add(mesh)

        loops.push(() => {
          mesh.rotation.x += 0.1
        })
      }
      {
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        mesh.position.set(-1.5, -1, -2)
        mesh.rotateZ(Math.PI / 2.0)
        tank.add(mesh)

        loops.push(() => {
          mesh.rotation.x += 0.1
        })
      }
    }
  }

  {
    const control = new OrbitControls(camera, threeContainer.value)
  }

  window.onresize = () => {
    const { width, height } = threeContainer.value!.getBoundingClientRect()
    camera.aspect = width / height
    camera.updateProjectionMatrix()
    renderer.setSize(width, height)
  }

  function animate() {
    loops.forEach(fn => fn())
    renderer.render(scene, cameraActive)
  }
  renderer.setAnimationLoop(animate)
})

onUnmounted(() => {
  pane.dispose()
  renderer.dispose()
})
</script>

<template>
  <div class="w-100vw h-100vh">
    <div ref="threeContainer" class="w-100vw h-100vh" />
  </div>
</template>

<style>

</style>
