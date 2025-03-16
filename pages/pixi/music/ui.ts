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
  dataLength: number

  constructor(app: Application, size: { w: number, h: number }, dataLength: number) {
    this.app = app
    this.size = size
    this.dataLength = dataLength
    this.app.stage.addChild(this.group)
    this.group.scale.y = -1

    this.drawAxis()
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
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
    const gap = 2
    const barWidth = Math.max(2, this.size.w / (this.dataLength) - gap)
    for (let i = 0; i < this.dataLength; i++) {
      const bar = this.barList[i] ? this.barList[i] : new Graphics()
      bar.clear()
      bar.rect(i * (barWidth + gap), 0, barWidth, data ? data[i] * this.size.h : 100)
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
  dataLength: number

  constructor(app: Application, size: { w: number, h: number }, dataLength: number) {
    this.app = app
    this.size = size
    this.dataLength = dataLength
    this.app.stage.addChild(this.group)
    this.group.scale.y = -1

    this.group.addChild(this.line)

    this.drawAxis()
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
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
    const gap = this.size.w / (this.dataLength)
    this.line.clear()
    for (let i = 0; i < this.dataLength; i++) {
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

export function cirle(app: Application) {
  const grap = new Graphics()
  app.stage.addChild(grap)

  let _x = 0
  let _y = 0
  let _r = 0
  let _color = 'red'

  function update(nor: number) {
    grap.clear()
      .circle(_x, _y, nor * _r)
      .fill({ color: _color })
  }

  return {
    setPos(x: number, y: number) {
      grap.position.set(x, y)
      _x = x
      _y = y
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
