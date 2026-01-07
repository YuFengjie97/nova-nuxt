import * as THREE from 'three'

export function disposeScene1(scene: THREE.Scene) {
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

export function disposeScene(
  scene: THREE.Scene,
  renderer?: THREE.WebGLRenderer,
) {
  // 1. 停止 scene 中的动画 / 回调（如果你有自定义 loop）
  scene.traverse((object) => {
    // ===== Mesh / Line / Points =====
    if (
      object instanceof THREE.Mesh
      || object instanceof THREE.Line
      || object instanceof THREE.Points
    ) {
      // geometry
      if (object.geometry) {
        object.geometry.dispose()
      }

      // material（可能是数组）
      const materials = Array.isArray(object.material)
        ? object.material
        : [object.material]

      materials.forEach((material) => {
        if (!material)
          return

        // 释放 material 上的所有 texture
        for (const key in material) {
          const value = (material as any)[key]
          if (value instanceof THREE.Texture) {
            value.dispose()
          }
        }

        material.dispose()
      })
    }

    // ===== SkinnedMesh =====
    if (object instanceof THREE.SkinnedMesh) {
      if (object.skeleton) {
        object.skeleton.dispose?.()
      }
    }

    if (object instanceof THREE.Light) {
      object.dispose()
    }
  })

  // 2. 清空 scene
  scene.clear()

  // 3. 释放 renderer 相关缓存
  if (renderer) {
    renderer.renderLists.dispose()
    renderer.info.reset()

    renderer.dispose()
    renderer.forceContextLoss()
  }
}
