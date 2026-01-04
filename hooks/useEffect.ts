import { onMounted, onUnmounted } from 'vue'

type FN = () => void

/**
 * 一个简陋版的useEffect,对依赖没什么处理
 * 只是为了简化threejs的编写方式,只能算个语法糖
 * 不用把全局变量分离出去了,用闭包的方式管理
 *
 *
 * @param setup 传入的函数在onMounted运行,函数返回的函数在onUnmounted运行
 * @param deps 暂时没用
 */
export function useEffect(setup: () => FN | undefined, deps: any[]) {
  let cleanup: FN | undefined

  onMounted(() => {
    cleanup = setup()
  })

  onUnmounted(() => {
    cleanup && cleanup()
  })
}
