<script lang="ts" setup>
import chroma from 'chroma-js'
import { Application } from 'pixi.js'
import { BarChart, button, cirle, LineChart } from './ui'
import music from '/sound/savageLove.aac'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const fftSize = 1024
const dataLength = 100
const frequencyColors = chroma.scale(['#fdcb6e', '#6c5ce7'])
  .mode('lch')
  .colors(7)

async function initApp(app: Application, container: HTMLElement) {
  await app.init({ antialias: true, background: '#1099bb', resizeTo: container })
  container.appendChild(app.canvas)
}

let _reset: () => void

onMounted(async () => {
  await initApp(app, pixiCon.value!)

  const { audio, play, pause, reset, getByteFrequencyData, getByteTimeDomainData, getSubBass, getBass, getLowMid, getMid, getHighMid, getPresence, Brilliance } = audioParse(music, fftSize, dataLength)
  _reset = reset

  button(app, 'play').onClick(play)
  button(app, 'puase').setPos(0, 28).onClick(pause)
  button(app, 'reset').setPos(0, 56).onClick(reset)

  const dataSize = 100

  const frequencyChart = new BarChart(app, { w: 800, h: 200 }, dataSize)
  frequencyChart.setPos(80, 200)

  const timeDomainChart = new LineChart(app, { w: 800, h: 200 }, dataSize)
  timeDomainChart.setPos(80, 400)

  const c1 = cirle(app).setPos(40, 240).setStyle (20, frequencyColors[0])
  const c2 = cirle(app).setPos(80, 240).setStyle(20, frequencyColors[1])
  const c3 = cirle(app).setPos(120, 240).setStyle(20, frequencyColors[2])
  const c4 = cirle(app).setPos(160, 240).setStyle(20, frequencyColors[3])
  const c5 = cirle(app).setPos(200, 240).setStyle(20, frequencyColors[4])
  const c6 = cirle(app).setPos(240, 240).setStyle(20, frequencyColors[5])
  const c7 = cirle(app).setPos(280, 240).setStyle(20, frequencyColors[6])

  app.ticker.add(() => {
    if (!audio.paused) {
      const data = getByteFrequencyData()
      frequencyChart.update(data)

      const data2 = getByteTimeDomainData()
      timeDomainChart.update(data2)

      c1.update(getSubBass())
      c2.update(getBass())
      c3.update(getLowMid())
      c4.update(getMid())
      c5.update(getHighMid())
      c6.update(getPresence())
      c7.update(Brilliance())
    }
  })
})

onUnmounted(() => {
  _reset()
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-full" />
  </div>
</template>

<style></style>
