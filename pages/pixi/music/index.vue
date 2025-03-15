<script lang="ts" setup>
import { Application } from 'pixi.js'
import { BarChart, button, LineChart } from './ui'
import music from '/sound/savageLove.aac'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const fftSize = 1024

async function initApp(app: Application, container: HTMLElement) {
  await app.init({ antialias: true, background: '#1099bb', resizeTo: container })
  container.appendChild(app.canvas)
}

onMounted(async () => {
  await initApp(app, pixiCon.value!)

  const { audio, play, pause, reset, getByteFrequencyData, getByteTimeDomainData } = audioParse(music, fftSize)

  button(app, 'play').onClick(play)
  button(app, 'puase').setPos(0, 28).onClick(pause)
  button(app, 'reset').setPos(0, 56).onClick(reset)

  const dataSize = 100

  const frequencyChart = new BarChart(app, { w: 800, h: 200 }, dataSize)
  frequencyChart.setPos(80, 200)

  const timeDomainChart = new LineChart(app, { w: 800, h: 200 }, dataSize)
  timeDomainChart.setPos(80, 400)

  app.ticker.add(() => {
    if (!audio.paused) {
      const data = getByteFrequencyData(dataSize)
      frequencyChart.update(data)

      const data2 = getByteTimeDomainData(dataSize)
      timeDomainChart.update(data2)
    }
  })
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style></style>
