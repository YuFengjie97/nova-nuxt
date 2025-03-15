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

  const label = new Text({ text })
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
