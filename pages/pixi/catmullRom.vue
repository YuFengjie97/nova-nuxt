<script lang="ts" setup>
import { Application, Container, Graphics, Text, TextStyle } from 'pixi.js'
import { Pane } from 'tweakpane'

const pixiCon = ref<HTMLElement>()
const app = new Application()

class CatmullRomPath {
  app: Application
  controlNum: number
  controls: Vector2[] = []
  segementNum: number = 20
  points: Vector2[] = []

  group: Container

  constructor(app: Application, controlNum: number) {
    this.app = app
    this.controlNum = controlNum

    this.group = new Container()
    app.stage.addChild(this.group)
  }

  destroy() {
    this.group.destroy({ children: true })
  }

  initRandomControl() {
    const { controlNum } = this

    const controls: Vector2[] = []
    for (let i = 0; i < controlNum; i++) {
      const x = Math.random() * (app.canvas.width - 40)
      const y = Math.random() * (app.canvas.height - 40)
      controls.push(new Vector2(x, y))
    }
    this.controls = controls
  }

  drawControls() {
    const { controls, group: baseGroup } = this

    for (let i = 0; i < controls.length; i++) {
      const p = controls[i]
      const group = new Container()
      group.label = 'control'
      const graph = new Graphics()
      const style = new TextStyle({ fontSize: 12 })
      const text = new Text({ text: `${i}`, style })
      text.anchor.set(0.5)
      text.position.set(0, 0)
      graph.circle(0, 0, 10).fill({ color: 'white' })
      group.position.set(p.x, p.y)
      group.zIndex = 100

      group.addChild(graph)
      group.addChild(text)
      baseGroup.addChild(group)
    }
  }

  getSegementPoints(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) {
    const { segementNum } = this
    const points = []

    for (let i = 0; i <= segementNum; i++) {
      const t = i / segementNum
      const x = catmullRom(p0.x, p1.x, p2.x, p3.x, t)
      const y = catmullRom(p0.y, p1.y, p2.y, p3.y, t)
      points.push(new Vector2(x, y))
    }

    return points
  }

  initPathPoints() {
    const { controls, controlNum, points } = this
    points.length = 0

    const end = controls[controls.length - 1]
    controls.push(controls[0], controls[1])
    controls.unshift(end)

    for (let i = 1; i < controlNum + 1; i++) {
      const p = controls[i]
      const p0 = controls[i - 1]
      const p1 = p
      const p2 = controls[i + 1]
      const p3 = controls[i + 2]
      const segementPoints = this.getSegementPoints(p0, p1, p2, p3)
      points.push(...segementPoints)
    }
  }

  drawPath() {
    const { points, group } = this
    const start = points[0]

    const graph = new Graphics()
    group.addChild(graph)

    graph.moveTo(start.x, start.y)
    for (let i = 1; i < points.length; i++) {
      const p = points[i]
      graph.lineTo(p.x, p.y)
    }
    graph.stroke({ color: 'red', width: 10, join: 'round' })
  }
}

let path: CatmullRomPath
let pane: Pane
onMounted(async () => {
  await app.init({ background: '#111', resizeTo: pixiCon.value, antialias: true })
  pixiCon.value?.appendChild(app.canvas)

  function reset() {
    if (path) {
      path.destroy()
    }
    path = new CatmullRomPath(app, 10)
    path.initRandomControl()
    path.drawControls()
    path.initPathPoints()
    path.drawPath()
  }

  reset()

  pane = new Pane()
  pane.addButton({ title: 'redraw' }).on('click', () => {
    reset()
  })
})

onUnmounted(() => {
  pane.dispose()
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped></style>
