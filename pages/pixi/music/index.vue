<script lang="ts" setup>
import { Application } from 'pixi.js'
import { button } from './ui'

const pixiCon = ref<HTMLElement>()
const app = new Application()

async function initApp(app: Application, container: HTMLElement) {
  await app.init({ antialias: true, background: '#1099bb', resizeTo: container })
  container.appendChild(app.canvas)
}

onMounted(async () => {
  await initApp(app, pixiCon.value!)
  button(app, 'play').setPos(10, 10).onClick(() => {
    console.log('play')
  })
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style>

</style>
