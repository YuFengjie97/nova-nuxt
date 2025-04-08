<script lang="ts" setup>
import { Application, Container, Graphics, Rectangle } from 'pixi.js'
import { Pane } from 'tweakpane'

const pixiCon = ref<HTMLElement>()
const app = new Application()
// const { atan2 } = Math
// const noise2d = createNoise2D()

const fbmOptions = {
  octaves: 3,
  lacunarity: 2, // 间隙度,调高频率
  gain: 0.5, // 减益,降低振幅
  amplitude: 0.5,
  frequency: 1.0,
}

function fbmPane(pane: Pane) {
  const folder = pane.addFolder({ title: 'fbm' })
  folder.addBinding(fbmOptions, 'octaves', { min: 1, max: 10, step: 1 })
  folder.addBinding(fbmOptions, 'lacunarity', { min: 1, max: 10, step: 0.1 })
  folder.addBinding(fbmOptions, 'gain', { min: 1, max: 10, step: 0.1 })
  folder.addBinding(fbmOptions, 'amplitude', { min: 1, max: 10, step: 0.1 })
  folder.addBinding(fbmOptions, 'frequency', { min: 1, max: 10, step: 0.1 })
}

class Lightning {
  app: Application
  group = new Container()
  controls: Map<Graphics, Vector2> = new Map()
  points: Vector2[] = []
  pathGraph = new Graphics()
  segementNum = 8

  dragControl: Graphics | null = null

  constructor(app: Application) {
    this.app = app
    app.stage.addChild(this.group)
    this.group.addChild(this.pathGraph)

    this.app.stage.on('pointermove', (event) => {
      const { dragControl } = this
      if (!dragControl) {
        return
      }
      const { x, y } = event.getLocalPosition(this.group)
      this.controls.get(dragControl)?.set(x, y)

      this.updatePoints()
    })

    this.app.stage.on('pointerleave', () => {
      this.dragControl = null
    })
  }

  addControls(pos: Vector2) {
    const graph = new Graphics()
    this.group.addChild(graph)
    this.controls.set(graph, pos)

    graph.eventMode = 'static'
    graph.on('pointerdown', () => {
      this.dragControl = graph
    })
    graph.on('pointerup', () => {
      this.dragControl = null
    })

    this.updatePoints()
  }

  updatePoints() {
    this.points = []
    this.initPoinsByControl()
  }

  initPoinsByControl() {
    const { segementNum } = this
    const points = Array.from(this.controls.values())
    const first = points[0]
    const last = points[points.length - 1]
    points.unshift(first)
    points.push(last)

    const segementPoints: Vector2[] = []
    for (let i = 1; i < points.length - 2; i++) {
      const p0 = points[i - 1]
      const p1 = points[i]
      const p2 = points[i + 1]
      const p3 = points[i + 2]
      const segement = catmullRomPoint(p0, p1, p2, p3, segementNum)

      segementPoints.push(...segement)
    }
    this.points = segementPoints
  }

  update() {

  }

  draw() {
    const { points, controls } = this
    for (const [graph, pos] of controls.entries()) {
      const { x, y } = pos
      graph.clear()
        .circle(x, y, 20)
        .fill({ color: 'red' })
    }

    const fir = points[0]
    if (fir) {
      this.pathGraph.clear()
        .moveTo(fir.x, fir.y)
      for (let i = 1; i < this.points.length; i++) {
        const { x, y } = points[i]
        this.pathGraph.lineTo(x, y)
      }
      this.pathGraph.stroke({ color: 'yellow', width: 2 })
    }
  }
}

onMounted(async () => {
  await app.init({ background: '#111', resizeTo: pixiCon.value, antialias: true })
  app.stage.eventMode = 'static'
  app.stage.hitArea = new Rectangle(0, 0, app.screen.width, app.screen.height)
  pixiCon.value?.appendChild(app.canvas)

  const pane = new Pane()
  fbmPane(pane)

  const lightning = new Lightning(app)
  lightning.addControls(new Vector2(100, 100))
  lightning.addControls(new Vector2(400, 100))
  lightning.addControls(new Vector2(400, 400))
  lightning.addControls(new Vector2(100, 400))

  lightning.draw()

  app.ticker.add(() => {
    lightning.update()
    lightning.draw()
  })
})

onUnmounted(() => {
  app.destroy(true, { children: true, texture: true })
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped></style>
