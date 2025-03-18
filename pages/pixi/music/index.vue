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

  const { audio, play, pause, reset, getByteFrequencyData, getByteTimeDomainData, getFloatFrequencyData, getSubBass, getBass, getLowMid, getMid, getHighMid, getPresence, Brilliance } = audioParse(music, fftSize, dataLength)
  _reset = reset

  button(app, 'play').onClick(play)
  button(app, 'puase').setPos(0, 28).onClick(pause)
  button(app, 'reset').setPos(0, 56).onClick(reset)

  const dataSize = 100

  const frequencyChart = new BarChart(app, { w: 500, h: 200 }, dataSize).setPos(80, 200)
  const timeDomainChart = new LineChart(app, { w: 500, h: 200 }, dataSize).setPos(80, 420)

  const frequencyChart2 = new BarChart(app, { w: 500, h: 200 }, dataSize).setPos(600, 200)

  const cy = 440
  const cx = 80
  const xGap = 30
  const cr = 20
  const c1 = (await cirle(app)).setPos(0 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[0])
  const c2 = (await cirle(app)).setPos(1 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[1])
  const c3 = (await cirle(app)).setPos(2 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[2])
  const c4 = (await cirle(app)).setPos(3 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[3])
  const c5 = (await cirle(app)).setPos(4 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[4])
  const c6 = (await cirle(app)).setPos(5 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[5])
  const c7 = (await cirle(app)).setPos(6 * (cr * 2 + xGap) + cx, cy).setStyle(cr, frequencyColors[6])

  app.ticker.add(() => {
    if (!audio.paused) {
      const data = getByteFrequencyData()
      frequencyChart.update(data)

      const data2 = getByteTimeDomainData()
      timeDomainChart.update(data2)

      const data3 = decorateAudioFrequency(getFloatFrequencyData(), { baseBarCount: dataLength })
      console.log(data3)
      frequencyChart2.update(data3)

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
    <div ref="pixiCon" class="w-full h-650px" />
  </div>
</template>

<style></style>
