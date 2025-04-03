import type { Application } from 'pixi.js'
import { Container, Graphics, Text } from 'pixi.js'

interface Button {
  group: Container
  setPos: (x: number, y: number) => Button
  onClick: (cb: () => void) => Button
}

export function button(app: Application, text: string): Button {
  const group = new Container()
  app.stage.addChild(group)
  group.eventMode = 'static'
  group.cursor = 'pointer'

  const label = new Text({ text, style: { fontSize: 16 } })
  const { width, height } = label.getBounds()
  label.position.set(width / 2, height / 2)

  const rect = new Graphics()

  group.addChild(rect)
  group.addChild(label)

  const px = 10
  const py = 4
  const w = width + px * 2
  const h = height + py * 2

  label.anchor.set(0.5)
  label.position.set(w / 2, h / 2)

  rect
    .roundRect(0, 0, w, h, 4)
    .fill('#fff')

  const button: Button = {
    group,
    setPos(x: number, y: number) {
      group.position.set(x, y)
      return this
    },
    onClick(cb: () => void) {
      group.on('pointerdown', cb)
      return this
    },
  }

  return button
}

export class BarChart {
  app
  group: Container = new Container()
  barList: Graphics[] = []
  size

  constructor(app: Application, size: { w: number, h: number }) {
    this.app = app
    this.size = size
    this.app.stage.addChild(this.group)
    this.group.scale.y = -1

    this.drawAxis()
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
    return this
  }

  update(data: number[]) {
    this.drawBar(data)
  }

  drawAxis() {
    const lineX = new Graphics()
    this.group.addChild(lineX)
    lineX.moveTo(0, 0)
      .lineTo(this.size.w, 0)
      .stroke({ color: 'red', pixelLine: true, width: 2 })

    const lineY = new Graphics()
    this.group.addChild(lineY)
    lineY.moveTo(0, 0)
      .lineTo(0, this.size.h)
      .stroke({ color: 'blue', pixelLine: true, width: 2 })
  }

  drawBar(data: number[]) {
    const barWidth = Math.max(-Infinity, this.size.w / (data.length))
    for (let i = 0; i < data.length; i++) {
      const bar = this.barList[i] ? this.barList[i] : new Graphics()
      bar.clear()
      bar.rect(i * (barWidth), 0, barWidth, data ? data[i] * this.size.h : 100)
        .fill('#6c5ce7')

      if (!this.barList[i]) {
        this.group.addChild(bar)
        this.barList.push(bar)
      }
    }
  }
}

export class LineChart {
  app
  group: Container = new Container()
  line: Graphics = new Graphics()
  size

  constructor(app: Application, size: { w: number, h: number }) {
    this.app = app
    this.size = size
    this.app.stage.addChild(this.group)
    this.group.scale.y = -1

    this.group.addChild(this.line)

    this.drawAxis()
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
    return this
  }

  update(data: number[]) {
    this.drawLine(data)
  }

  drawAxis() {
    const lineX = new Graphics()
    this.group.addChild(lineX)
    lineX.moveTo(0, 0)
      .lineTo(this.size.w, 0)
      .stroke({ color: 'red', pixelLine: true, width: 2 })

    const lineY = new Graphics()
    this.group.addChild(lineY)
    lineY.moveTo(0, 0)
      .lineTo(0, this.size.h)
      .stroke({ color: 'blue', pixelLine: true, width: 2 })
  }

  drawLine(data: number[]) {
    const gap = this.size.w / data.length
    this.line.clear()
    for (let i = 0; i < data.length; i++) {
      const x = i * gap
      const y = data[i] * this.size.h
      if (i === 0) {
        this.line.moveTo(x, y)
      }
      else {
        this.line.lineTo(x, y)
      }
    }
    this.line.stroke({ pixelLine: true, width: 2, color: '#ffeaa7' })
  }
}

export async function cirle(app: Application) {
  const group = new Container()
  const grap = new Graphics()

  app.stage.addChild(group)
  group.addChild(grap)

  let _r = 0
  let _color = 'red'

  function update(nor: number) {
    grap.clear()
      .circle(0, 0, nor * _r)
      .fill({ color: _color })
  }

  return {
    setPos(x: number, y: number) {
      group.position.set(x, y)
      return this
    },
    setStyle(r: number, color: string) {
      _r = r
      _color = color
      return this
    },
    update,
  }
}

export class ProgressBar {
  app: Application
  size: { w: number, h: number }
  group = new Container()
  progressBottom = new Graphics()
  progress = new Graphics()
  constructor(app: Application, size: { w: number, h: number }) {
    this.app = app
    this.size = size
    const { w, h } = size

    app.stage.addChild(this.group)

    this.progressBottom.rect(0, 0, w, h)
      .fill({ color: '#00b894' })

    this.progressBottom.eventMode = 'static'
    this.progressBottom.cursor = 'pointer'

    this.group.addChild(this.progressBottom)
    this.group.addChild(this.progress)
  }

  draw(val: number) {
    this.progress.clear()
    this.progress
      .rect(0, 0, this.size.w * val, this.size.h)
      .fill({ color: '#81ecec' })
  }

  onClick(cb: (percentile: number) => void) {
    this.progressBottom.on('pointerdown', (event) => {
      const { x } = event.getLocalPosition(this.group)
      const percentile = x / this.size.w
      cb(percentile)
      this.draw(percentile)
    })

    return this
  }

  update(val: number) {
    this.draw(val)
  }
}
