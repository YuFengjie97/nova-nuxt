<script lang="ts" setup>
import { gsap } from 'gsap'
import { MotionPathPlugin } from 'gsap/MotionPathPlugin'
import { Application, Container, Graphics, Rectangle, Text, TextStyle } from 'pixi.js'
import { Pane } from 'tweakpane'

gsap.registerPlugin(MotionPathPlugin)
const pixiCon = ref<HTMLElement>()
const app = new Application()

let dragControl: Control | null = null
const controls: Control[] = []
let lastClick = 0

class Control {
  pos: Vector2
  group = new Container()
  graphp = new Graphics()
  text: Text
  constructor(app: Application, pos: Vector2) {
    this.pos = pos
    this.group.position.set(pos.x, pos.y)

    this.group.eventMode = 'static'
    this.group.addChild(this.graphp)
    app.stage.addChild(this.group)
    this.group.cursor = 'pointer'

    this.text = new Text({
      text: '1',
      style: new TextStyle({
        fill: 'black',
      }),
    })
    this.text.anchor.set(0.5)
    this.text.position.set(0, 0)
    this.group.addChild(this.text)

    this.group.on('pointerdown', (event) => {
      event.stopPropagation()
      this.handlePointerDown(this)
    })

    this.group.on('pointerup', () => {
      dragControl = null
    })

    this.graphp.circle(0, 0, 16)
      .fill({ color: 'yellow' })
  }

  handlePointerDown(control: Control) {
    const now = Date.now()
    // 双击事件删除,单击事件选中
    if (now - lastClick < 300) {
      this.destory()
    }
    else {
      dragControl = control
    }
    lastClick = now
  }

  updatePos(x: number, y: number) {
    this.pos.set(x, y)
    this.group.position.set(x, y)
  }

  updateText() {
    const index = controls.indexOf(this) + 1
    this.text.text = `${index}`
  }

  destory() {
    const index = controls.indexOf(this)
    if (index !== -1) {
      controls.splice(index, 1)
    }

    this.group.destroy({ children: true })
    updateControlText()
  }
}

class Particle {
  app: Application
  graph: Graphics
  pos: Vector2
  constructor(app: Application) {
    this.app = app
    this.graph = new Graphics()

    const { width, height } = app.screen
    const x = Math.random() * width
    const y = Math.random() * height
    this.pos = new Vector2(x, y)
    this.app.stage.addChild(this.graph)

    const bezierPath = this.getBezier()
    gsap.to(this.pos, {
      duration: 10,
      ease: 'power2.inOut',
      motionPath: {
        path: bezierPath,
      },
      onUpdate: () => {
        const { x, y } = this.pos
        this.graph.clear()
          .circle(x, y, 10)
          .fill({ color: 'red' })
      },
      onComplete: () => {
        this.graph.destroy()
      },
    })
  }

  getBezier() {
    return controls.map((item) => {
      return {
        x: item.pos.x,
        y: item.pos.y,
      }
    })
  }
}

function updateControlText() {
  controls.forEach((c) => {
    c.updateText()
  })
}

onMounted(async () => {
  await app.init({ background: '#111', resizeTo: pixiCon.value })
  pixiCon.value?.appendChild(app.canvas)

  const { width, height } = app.screen
  app.stage.eventMode = 'static'
  app.stage.hitArea = new Rectangle(0, 0, width, height)
  app.stage.addEventListener('pointerleave', () => {
    dragControl = null
  })
  app.stage.on('pointermove', (event) => {
    if (!dragControl) {
      return
    }
    const { x, y } = event.getLocalPosition(app.stage)
    dragControl.updatePos(x, y)
  })

  // 双击添加控制点
  app.stage.on('pointerdown', (event) => {
    const now = Date.now()
    if (now - lastClick < 300) {
      const { x, y } = event.getLocalPosition(app.stage)
      controls.push(new Control(app, new Vector2(x, y)))
      updateControlText()
    }
    else {
      lastClick = now
    }
  })

  const pane = new Pane()
  pane.addButton({ title: 'add particle' }).on('click', () => {
    const particle = new Particle(app)
    console.log(particle)
  })

  controls.push(
    new Control(app, new Vector2(100, 100)),
    new Control(app, new Vector2(300, 100)),
    new Control(app, new Vector2(500, 400)),
    new Control(app, new Vector2(700, 500)),
  )
  updateControlText()
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped></style>
