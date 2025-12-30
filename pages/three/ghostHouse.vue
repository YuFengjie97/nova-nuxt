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
  const textureLoader = new THREE.TextureLoader()

  function handleTexture(tex: THREE.Texture<HTMLImageElement>, x: number, y: number) {
    tex.repeat.set(x, y)
    tex.wrapS = THREE.RepeatWrapping
    tex.wrapT = THREE.RepeatWrapping
  }

  {
    const light = new THREE.AmbientLight()
    light.intensity = 0.4
    scene.add(light)
  }

  // 地面
  {
    const tex_albedo = textureLoader.load(`${baseUrl}img/texture/Ground037_1K-JPG/Ground037_1K-JPG_Color.jpg`)
    const tex_ao = textureLoader.load(`${baseUrl}img/texture/Ground037_1K-JPG/Ground037_1K-JPG_AmbientOcclusion.jpg`)
    const tex_displacement = textureLoader.load(`${baseUrl}img/texture/Ground037_1K-JPG/Ground037_1K-JPG_Displacement.jpg`)
    const tex_normal = textureLoader.load(`${baseUrl}img/texture/Ground037_1K-JPG/Ground037_1K-JPG_NormalDX.jpg`)
    const tex_roughness = textureLoader.load(`${baseUrl}img/texture/Ground037_1K-JPG/Ground037_1K-JPG_Roughness.jpg`)

    handleTexture(tex_albedo, 4, 4)
    handleTexture(tex_ao, 4, 4)
    handleTexture(tex_displacement, 4, 4)
    handleTexture(tex_normal, 4, 4)
    handleTexture(tex_roughness, 4, 4)

    const geo = new THREE.PlaneGeometry(30, 30, 100, 100)
    geo.setAttribute(
      'uv2',
      new THREE.Float32BufferAttribute(geo.attributes.uv.array, 2),
    )
    const mat = new THREE.MeshStandardMaterial({
      map: tex_albedo,
      displacementMap: tex_displacement,
      displacementScale: 0.1,
      normalMap: tex_normal,
      roughnessMap: tex_roughness,
      aoMap: tex_ao,
    })
    const mesh = new THREE.Mesh(geo, mat)
    mesh.receiveShadow = true
    mesh.rotation.x = -Math.PI / 2
    scene.add(mesh)
  }

  // 房子
  {
    const house = new THREE.Group()
    scene.add(house)
    // 墙壁
    {
      const tex_albedo = textureLoader.load(`${baseUrl}img/texture/Bricks085_1K-JPG/Bricks085_1K-JPG_Color.jpg`)
      const tex_ao = textureLoader.load(`${baseUrl}img/texture/Bricks085_1K-JPG/Bricks085_1K-JPG_AmbientOcclusion.jpg`)
      const tex_displacement = textureLoader.load(`${baseUrl}img/texture/Bricks085_1K-JPG/Bricks085_1K-JPG_Displacement.jpg`)
      const tex_normal = textureLoader.load(`${baseUrl}img/texture/Bricks085_1K-JPG/Bricks085_1K-JPG_NormalDX.jpg`)
      const tex_roughness = textureLoader.load(`${baseUrl}img/texture/Bricks085_1K-JPG/Bricks085_1K-JPG_Roughness.jpg`)

      const geo = new THREE.BoxGeometry(4, 3, 4, 200, 200, 200)
      geo.setAttribute(
        'uv2',
        new THREE.Float32BufferAttribute(geo.attributes.uv.array, 2),
      )
      const mat = new THREE.MeshStandardMaterial({
        map: tex_albedo,
        displacementMap: tex_displacement,
        displacementScale: 0.3,
        displacementBias: -0.26,
        normalMap: tex_normal,
        roughnessMap: tex_roughness,
        aoMap: tex_ao,
      })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.castShadow = true
      mesh.position.y = 3 / 2
      house.add(mesh)
    }
    // 门
    {
      const tex_amb = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_ambientOcclusion.jpg`)
      const tex_base = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_basecolor.jpg`)
      const tex_height = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_height.png`)
      const tex_metallic = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_metallic.jpg`)
      const tex_normal = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_normal.jpg`)
      const tex_opacity = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_opacity.jpg`)
      const tex_roughness = textureLoader.load(`${baseUrl}img/texture/door_wood/Door_Wood_001_roughness.jpg`)

      const geo = new THREE.PlaneGeometry(2, 2, 100, 100)
      geo.setAttribute(
        'uv2',
        new THREE.Float32BufferAttribute(geo.attributes.uv.array, 2),
      )
      const mat = new THREE.MeshStandardMaterial({
        map: tex_base,
        aoMap: tex_amb,
        transparent: true,
        alphaMap: tex_opacity,
        displacementMap: tex_height,
        displacementScale: 0.1,
        metalnessMap: tex_metallic,
        normalMap: tex_normal,
        roughnessMap: tex_roughness,
      })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.position.z = 4 / 2 + 0.001
      mesh.position.y = 2 / 2
      house.add(mesh)
    }
    // 屋顶
    {
      const geo = new THREE.ConeGeometry(4, 2, 4)
      const mat = new THREE.MeshStandardMaterial({ color: 0x0000FF })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.position.y = 3 + 2 / 2
      mesh.rotation.y = Math.PI / 4
      house.add(mesh)
    }
    // 灯
    {
      const light = new THREE.PointLight(0xFFFF00, 10, 4)
      // light.castShadow = true
      house.add(light)
      light.position.y = 2.5
      light.position.z = 2.1
      // const helper = new THREE.PointLightHelper(light)
      // scene.add(helper)
    }
  }

  // 草丛
  {
    const geo = new THREE.SphereGeometry(1)
    const mat = new THREE.MeshStandardMaterial({ color: 0x008800 })

    for (let i = 0; i < 10; i++) {
      const mesh = new THREE.Mesh(geo, mat)
      scene.add(mesh)
      mesh.castShadow = true

      const s = Math.random() * 0.4 + 0.2
      mesh.scale.set(s, s, s)

      const ang = Math.random() * Math.PI * 2.0
      const r = Math.random() * 5 + 4
      const x = Math.cos(ang) * r
      const z = Math.sin(ang) * r
      mesh.position.set(x, s / 2, z)
    }
  }
  // 墓碑
  {
    const tex_albedo = textureLoader.load(`${baseUrl}img/texture/Rock030_1K-JPG/Rock030_1K-JPG_Color.jpg`)
    const tex_ao = textureLoader.load(`${baseUrl}img/texture/Rock030_1K-JPG/Rock030_1K-JPG_AmbientOcclusion.jpg`)
    const tex_displacement = textureLoader.load(`${baseUrl}img/texture/Rock030_1K-JPG/Rock030_1K-JPG_Displacement.jpg`)
    const tex_normal = textureLoader.load(`${baseUrl}img/texture/Rock030_1K-JPG/Rock030_1K-JPG_NormalDX.jpg`)
    const tex_roughness = textureLoader.load(`${baseUrl}img/texture/Rock030_1K-JPG/Rock030_1K-JPG_Roughness.jpg`)

    // handleTexture(tex_albedo, 10, 10)
    // handleTexture(tex_ao, 10, 10)
    // handleTexture(tex_displacement, 10, 10)
    // handleTexture(tex_normal, 10, 10)
    // handleTexture(tex_roughness, 10, 10)

    const geo = new THREE.BoxGeometry(0.5, 1, 0.2, 50, 100, 20)
    const mat = new THREE.MeshStandardMaterial({
      map: tex_albedo,
      displacementMap: tex_displacement,
      displacementScale: 0.1,
      displacementBias: -0.1,
      normalMap: tex_normal,
      roughnessMap: tex_roughness,
      aoMap: tex_ao,
    })
    for (let i = 0; i < 10; i++) {
      const mesh = new THREE.Mesh(geo, mat)
      mesh.castShadow = true
      const ang = Math.random() * Math.PI * 2.0
      const r = Math.random() * 5 + 4
      const x = Math.cos(ang) * r
      const z = Math.sin(ang) * r
      mesh.position.set(x, 1 / 2, z)
      mesh.rotation.y = Math.random() * 2 - 1.0
      mesh.rotation.x = Math.random() * 0.8 - 0.4
      scene.add(mesh)
    }
  }

  // ghost point light
  {
    const light = new THREE.PointLight(0xE056FD, 20)
    light.castShadow = true
    light.shadow.mapSize.width = 256
    light.shadow.mapSize.height = 256
    light.shadow.camera.far = 7
    scene.add(light)
    loops.push(() => {
      const t = clock.getElapsedTime()
      const ang = t
      const r = 4
      const x = Math.cos(ang) * r
      const z = Math.sin(ang) * r
      const y = Math.sin(t * 4) * 2 + 1
      light.position.set(x, y, z)
    })
  }
  {
    const light = new THREE.PointLight(0xBADC58, 20)
    light.castShadow = true
    light.shadow.mapSize.width = 256
    light.shadow.mapSize.height = 256
    light.shadow.camera.far = 7
    scene.add(light)
    loops.push(() => {
      const t = -clock.getElapsedTime()
      const ang = t
      const r = 5
      const x = Math.cos(ang) * r
      const z = Math.sin(ang) * r
      const y = Math.sin(t * 4) * 2 + 1
      light.position.set(x, y, z)
    })
  }

  // fog
  {
    const color = {
      col: {
        r: 31,
        g: 12,
        b: 38,
      },
      rgb() {
        return `rgb(${this.col.r},${this.col.g},${this.col.b})`
      },
    }
    const fog = new THREE.Fog(color.rgb(), 0.1, 12)
    renderer.setClearColor(fog.color)

    scene.fog = fog
    pane.addBinding(color, 'col', { label: 'fogColor' })
      .on('change', (ev) => {
        let { r, g, b } = ev.value
        r /= 255
        g /= 255
        b /= 255
        fog.color.setRGB(r, g, b)
        renderer.setClearColor(fog.color)
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
