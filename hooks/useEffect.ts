import { onMounted, onUnmounted } from 'vue'

type FN = () => void

/**
 * 只是为了方便
 * 弊端,如果是async,中间有很长时间的等待,
 * 如果此时退出页面,不会触发cleanup,大量的threejs资源都能释放
 * 如果像是全局变量,onMounted onUnmounted分开写,不会有这种问题
 * @param setup 传入的在onMounted执行,其返回值在onUnmounted执行
 * @param deps 没用
 */
export function useEffect(setup: () => FN | Promise<FN | undefined> | undefined, deps: any[]) {
  let cleanup: FN | undefined

  onMounted(async () => {
    const result = setup()
    if (result instanceof Promise) {
      cleanup = await result
    }
    else if (result) {
      cleanup = result
    }
  })

  onUnmounted(() => {
    cleanup && cleanup()
  })
}
