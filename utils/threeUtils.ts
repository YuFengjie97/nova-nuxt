import type * as THREE from 'three'

export function disposeScene(scene: THREE.Scene) {
  scene.traverse((object: THREE.Object3D) => {
    // 只处理真正占用 GPU 资源的对象
    if (
      (object as THREE.Mesh).isMesh
      || (object as THREE.Line).isLine
      || (object as THREE.Points).isPoints
    ) {
      const mesh = object as THREE.Mesh

      // 1️⃣ geometry
      if (mesh.geometry) {
        mesh.geometry.dispose()
      }

      // 2️⃣ material（可能是数组）
      const material = mesh.material
      if (material) {
        const materials = Array.isArray(material) ? material : [material]
        materials.forEach((mat) => {
          // 3️⃣ dispose 材质里的所有纹理
          for (const key in mat) {
            const value = (mat as any)[key]
            if (value && value.isTexture) {
              value.dispose()
            }
          }
          // 4️⃣ dispose 材质本身
          mat.dispose()
        })
      }
    }
  })

  // 5️⃣ 移除所有对象
  scene.clear()
}
