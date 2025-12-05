<!-- shaderMaterial 顶点着色器,顶点偏移 -->
<script lang="ts" setup>
// import model from '@/assets/models/character.fbx'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/Addons.js'

const threeContainer = ref<HTMLElement>()
// const noise2D = createNoise2D()
// const noise3D = createNoise3D()

onMounted(() => {
  if (!threeContainer.value) {
    return
  }
  const { width, height } = threeContainer.value?.getBoundingClientRect()
  const resolution = { x: width, y: height }
  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(75, resolution.x / resolution.y, 0.1, 1000)
  camera.position.z = -60
  camera.position.y = 10

  const cameraTarget = new THREE.Vector3(0, 0, 0)
  camera.lookAt(cameraTarget)
  const renderer = new THREE.WebGLRenderer()
  renderer.setSize(resolution.x, resolution.y)
  threeContainer.value.append(renderer.domElement)

  {
    const dirLig = new THREE.DirectionalLight(0xFFFFFF, 1.5)
    dirLig.position.set(10, 10, 10)
    dirLig.target.position.set(0, 0, 0)
    scene.add(dirLig)
  }
  {
    const dirLig = new THREE.DirectionalLight(0xFFFFFF, 1.5)
    dirLig.position.set(10, -10, 10)
    dirLig.target.position.set(0, 0, 0)
    scene.add(dirLig)
  }
  // scene.add(dirLig.target)

  const control = new OrbitControls(camera, threeContainer.value)
  console.log(control)

  const planeSize = { x: 100, y: 100 }
  const sampleSize = { x: 50, y: 50 }

  // cube
  {
    const geo = new THREE.BoxGeometry(8, 8, 8)
    // const mat = new THREE.MeshBasicMaterial({ color: 'rgb(255,0,0)' })
    const mat = new THREE.MeshPhongMaterial({ color: 0xFFFF00, shininess: 100, specular: 0xFFFFFF, side: THREE.DoubleSide })
    const mesh = new THREE.Mesh(geo, mat)
    scene.add(mesh)
  }

  // Plane
  {
    const geo = new THREE.PlaneGeometry(planeSize.x, planeSize.y, sampleSize.x, sampleSize.y)
    const mat = new THREE.ShaderMaterial({
      uniforms: {
        time: { value: 1.0 },
        rd: { value: new THREE.Vector3(0, 0, 0) },
        resolution: { value: new THREE.Vector2(resolution.x, resolution.y) },
      },
      side: THREE.DoubleSide,
      vertexShader: `
      uniform float time;
      uniform vec3 rd;
      
      // 内置属性（Three.js自动提供）
      // attribute vec3 position;
      // attribute vec3 normal;
      // attribute vec2 uv;
      
      // 内置uniforms（Three.js自动提供）
      //uniform mat4 modelMatrix;
      //uniform mat4 viewMatrix;
      //uniform mat4 projectionMatrix;
      //uniform mat4 modelViewMatrix;
      //uniform mat3 normalMatrix;
      
      // 传递给片元着色器的变量
      varying vec3 vNormal;
      varying vec2 vUv;
      varying vec3 vPosition;
      varying vec3 vWorldPosition;


      void main() {
        vUv = uv;
        vNormal = normalize(normalMatrix * normal);
        
        // 修改顶点位置 - 波浪效果
        vec3 newPosition = position;
        float wave = sin(position.x * 10.0 + time) * 
                    sin(position.y * 10.0 + time) * 
                    2.;
        newPosition.z += wave;
        
        // 计算最终位置
        vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;

        // 计算世界坐标
        vWorldPosition = (modelMatrix * vec4(newPosition, 1.)).xyz;

        gl_Position = projectionMatrix * modelViewMatrix * 
                      vec4(newPosition, 1.0);
      }
      `,
      fragmentShader: `
      varying vec3 vNormal;
      varying vec2 vUv;
      varying vec3 vPosition;
      varying vec3 vWorldPosition;
      uniform float time;
      uniform vec3 rd;

      void main() {
        vec3 nor = normalize(vNormal);
        vec3 col = vec3(0);
        // float d = length(vUv-.5);
        // col += .1/d;

        vec3 l_pos = vec3(10,10,10);
        l_pos.xz = vec2(cos(time), sin(time))*10.;
        vec3 l_dir = normalize(l_pos-vWorldPosition);
        float diff = max(0.,dot(l_dir, nor));
        float spe = pow(max(0.,dot(reflect(-l_dir, nor), -rd)), 30.);
        vec3 c = sin(vec3(3,2,1)+time+dot(vUv, vec2(10.1)))*.5+.5;
        //vec3 c = vec3(1,0,0);
        
        col += c*.1 + c * diff + spe;
        

        gl_FragColor = vec4(col, 1.0);
      }
      `,
    })
    const mesh = new THREE.Mesh(geo, mat)

    mesh.rotation.x = -Math.PI / 2.0
    mesh.position.y = -2.0
    scene.add(mesh)

    function animate() {
      mat.uniforms.time.value += 0.1
      const rd = cameraTarget.clone().sub(camera.position).normalize()
      mat.uniforms.rd.value.copy(rd)

      renderer.render(scene, camera)
    }
    renderer.setAnimationLoop(animate)
  }
})
</script>

<template>
  <div ref="threeContainer" class="h-100vh" />
</template>

<style></style>
