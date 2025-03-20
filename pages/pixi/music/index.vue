<script lang="ts" setup>
import chroma from 'chroma-js'
import { Application } from 'pixi.js'
import { Pane } from 'tweakpane'
import { BarChart, cirle, LineChart } from './ui'
import music from '/sound/savageLove.aac'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const fftSize = 1024
const targetSize = 100
const frequencyColors = chroma.scale(['#fdcb6e', '#6c5ce7'])
  .mode('lch')
  .colors(7)

async function initApp(app: Application, container: HTMLElement) {
  await app.init({ antialias: true, background: '#1099bb', resizeTo: container })
  container.appendChild(app.canvas)
}

let ap: AudioParse

onMounted(async () => {
  await initApp(app, pixiCon.value!)

  const settings = {
    smoothingTimeConstant: 0.8,
  }

  ap = new AudioParse(music, fftSize)

  function initPane() {
    const pane = new Pane()
    pane.addButton({ title: 'play' }).on('click', () => ap.play())
    pane.addButton({ title: 'pause' }).on('click', () => ap.pause())
    pane.addButton({ title: 'reset' }).on('click', () => ap.reset())
    pane.addBinding(settings, 'smoothingTimeConstant', { min: 0, max: 1, step: 0.1 }).on('change', (ev) => {
      ap.setSmoothingTimeConstant(ev.value)
    })
  }
  initPane()

  const frequencyChart = new BarChart(app, { w: 500, h: 200 }).setPos(0, 200)
  const timeDomainChart = new LineChart(app, { w: 500, h: 200 }).setPos(500, 200)

  // const frequencyChart2 = new BarChart(app, { w: 500, h: 200 }).setPos(0, 400)

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
    if (!ap.audio.paused) {
      const res = dataProcessor(Array.from(ap.getByteFrequencyData()))
        .avgNormalChian(targetSize)
        .smoothChian()
        .normalizeChain()
      frequencyChart.update(res.data)

      const res2 = dataProcessor(Array.from(ap.getByteTimeDomainData()))
        .avgNormalChian(targetSize)
        .smoothChian()
        .normalizeChain()
      timeDomainChart.update(res2.data)

      c1.update(dataProcessor(ap.getSubBass()).avgNormalChian(1).normalizeChain(255).data[0])
      c2.update(dataProcessor(ap.getBass()).avgNormalChian(1).normalizeChain(255).data[0])
      c3.update(dataProcessor(ap.getLowMid()).avgNormalChian(1).normalizeChain(255).data[0])
      c4.update(dataProcessor(ap.getMid()).avgNormalChian(1).normalizeChain(255).data[0])
      c5.update(dataProcessor(ap.getHighMid()).avgNormalChian(1).normalizeChain(255).data[0])
      c6.update(dataProcessor(ap.getPresence()).avgNormalChian(1).normalizeChain(255).data[0])
      c7.update(dataProcessor(ap.Brilliance()).avgNormalChian(1).normalizeChain(255).data[0])
    }
  })
})

onUnmounted(() => {
  ap.destroy()
})
</script>

<template>
  <div class="w-full h-100vh">
    <div ref="pixiCon" class="w-full h-650px" />
  </div>
</template>

<style></style>
